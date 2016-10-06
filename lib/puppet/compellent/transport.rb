require 'net/https'
require 'rest-client'
require 'cgi'
require 'json'
puppet_dir = Pathname.new(__FILE__).parent.parent
require "#{puppet_dir}/files/CommonLib"
require "#{puppet_dir}/files/ResponseParser"
require "#{puppet_dir}/compellent/util"
require 'puppet'

module Puppet
  module Compellent
    class Transport
      attr_accessor :host, :port, :user, :password, :discovery_type, :jsessionid, :api_version
      def initialize(connection_info=nil)
        @lib_path = CommonLib.get_path(1).to_s
        @log_path  = CommonLib.get_log_path(1).to_s

        script_run = false
        if connection_info != nil
          self.user = connection_info[:username]
          self.host = connection_info[:server]
          self.port = connection_info[:port]
          self.password = connection_info[:password]
          self.discovery_type = connection_info[:discovery_type]
          script_run = true
        else
          parsed_config = Puppet::Compellent::Util.get_transport
          self.user = parsed_config[:user]
          self.host = parsed_config[:host]
          self.password = parsed_config[:password]
          self.port = parsed_config[:port]
          parsed_config[:discovery_type] != 'EM' ? self.discovery_type = 'Storage_Center' : self.discovery_type = 'EM'
        end

        Puppet.debug('Device login started')


        if self.discovery_type == 'EM'
          Puppet.debug("#{self.class}: connecting to Compellent EM #{self.host}")

          raise ArgumentError, 'no user specified' unless self.user
          raise ArgumentError, 'no password specified' unless self.password

          if self.jsessionid = get_jsession_id(em_login)
            Puppet.debug('Connection successful with EM') if !script_run
          else
            raise Puppet::Error, "Failed to get JSESSION ID from EM" if !script_run
          end
        else
          Puppet.debug("#{self.class}: connecting to Compellent device #{self.host}")

          raise ArgumentError, 'no user specified' unless self.user
          raise ArgumentError, 'no password specified' unless self.password

          Puppet.debug("Host IP is #{self.host}")
          login_respxml = "#{CommonLib.get_log_path(1)}/loginResp_#{CommonLib.get_unique_refid}.xml"
          login_exitcodexml = "#{CommonLib.get_log_path(1)}/loginExitCode_#{CommonLib.get_unique_refid}.xml"

          response = command_exec(@lib_path,login_exitcodexml,"\"system show -xml #{login_respxml}\"")

          parser_obj = ResponseParser.new('_')
          parser_obj.parse_exitcode(login_exitcodexml)
          hash = parser_obj.return_response

          File.delete(login_respxml,login_exitcodexml)
          if "#{hash['Success']}" == 'TRUE'
            Puppet.debug('Login successful') if !script_run
          else
            raise Puppet::Error, "#{hash['Error']}" if !script_run
          end
        end

      end

      def get_java_path
        if ENV["JAVA_HOME"]
          File.join(ENV["JAVA_HOME"], "/bin/java")
        else
          "/opt/java/bin/java"
        end
      end

      # Executes a compellent jar command with Exit Code and Response XMls
      def command_exec(libPath,respXml,command)
        #ref_id = CommonLib.get_unique_refid
        #resp_xml = "#{@log_path}/response_#{ref_id}.xml"
        args = ['-jar', libPath,
                '-host', self.host,
                '-user', self.user,
                '-password', self.password,
                '-xmloutputfile', respXml,
                '-c', command]
        #   Puppet.debug("Executing compellent command: " + args.join(" "))
        ret = `#{get_java_path} #{args.join(' ')} 2>&1`
        Puppet.debug("Output: #{ret}")
        # Need to retry if there is any connection reset message
        if ret.match(/Connection reset|Couldn't connect to/i)
          Puppet.debug('Connection reset observed. sleep for 10 seconds and retry')
          sleep(10)
          `#{get_java_path} #{args.join(' ')} 2>&1`
        else
          ret
        end
      end


      # Execute Storage Manager Login Endpoint and return response that contains cookie and other version information
      #
      # @return [Object] HTTP Response
      #
      # @example return
      #   {"hostName"=>"172.17.0.53",
      #   "provider"=>"EnterpriseManager",
      #    "locale"=>"en_US",
      #    "source"=>"REST",
      #    "userName"=>"SushilR@aidev.com",
      #    "connected"=>true,
      #    "userId"=>434228,
      #    "application"=>"",
      #    "providerVersion"=>"16.2.1.228",
      #    "webServicesPort"=>3033,
      #    "sessionKey"=>1475261164332,
      #    "applicationVersion"=>"",
      #    "apiBuild"=>651,
      #    "apiVersion"=>"3.1",
      #    "commandLine"=>false,
      #    "minApiVersion"=>"0.1",
      #    "connectionKey"=>"",
      #    "secureString"=>"",
      #    "useHttps"=>false,
      #    "objectType"=>"ApiConnection",
      #    "instanceId"=>"0",
      #    "instanceName"=>"ApiConnection"}
      def em_login
        login_base_url="https://#{CGI.escape(self.user)}:#{CGI.escape(self.password)}@#{self.host}:#{self.port}/api/rest"
        url = "#{login_base_url}/ApiConnection/Login"

        response = RestClient::Request.execute(:url => url,
                                               :method => :post,
                                               :verify_ssl => false ,
                                               :payload => '{}',
                                               :headers => {:content_type => :json,
                                                            :accept => :json ,
                                                            'x-dell-api-version'=> '2.0' })

        response
      end

      def get_jsession_id(login_info)
        set_cookie = login_info.raw_headers["set-cookie"]
        self.api_version = JSON.parse(em_login)["apiVersion"]

        # With EM version 3.1 format of JSession Id has changed. Now we are getting
        # ["JSESSIONID=yFZVpegI_iaClWgUqmDosTS1.aidev-smdc; path=/api"]
        # We just need to pass JSESSIONID=yFZVpegI_iaClWgUqmDosTS1.aidev-smdc
        if self.api_version.to_f >= 3.1
          set_cookie[0].scan(/(JSESSIONID=.*);/).flatten.first
        else
          set_cookie
        end
      end

      def get_url(end_point)
        return "https://#{self.host}:#{self.port}/api/rest/#{end_point}"
      end

      def post_request(url,payload,method)
        response = RestClient::Request.execute(:url => url,
                                           :method => method.to_sym,
                                           :verify_ssl => false,
                                           :payload => payload,
                                           :headers => headers
        )
        JSON.parse(response)
      end

      def headers
        {
            :content_type => :json,
            :accept => :json,
            'x-dell-api-version'=> self.api_version,
            'Cookie' => self.jsessionid
        }
      end
    end

  end
end
