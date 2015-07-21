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
      attr_accessor :host, :port, :user, :password, :discovery_type, :jsessionid
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

          if self.jsessionid = get_jsession_id
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
          response = exec("system show -xml #{login_respxml}")
          hash = response[:xml_output_hash]
          response_output = response[:xml_output_file]
          File.delete(login_respxml,response_output)
          if "#{hash['Success']}" == 'TRUE'
            Puppet.debug('Login successful') if !script_run
          else
            raise Puppet::Error, "#{hash['Error']}" if !script_run
          end
        end

      end


      def exec(command, *extra_args)
        ref_id = CommonLib.get_unique_refid
        resp_xml = "#{@log_path}/response_#{ref_id}.xml"
        args = ['-jar', @lib_path,
                '-host', self.host,
                '-user', self.user,
                '-password', self.password,
                '-xmloutputfile', resp_xml,
                '-c', command] + extra_args
        # Puppet.debug("Executing compellent command: " + args.join(" "))
        ret = system('java', *args)
        parser_obj = ResponseParser.new('_')
        parser_obj.parse_exitcode(resp_xml)
        hash = parser_obj.return_response
        {:system_ret => ret,
         :xml_output_file => resp_xml,
         :xml_output_hash => hash, }
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
        ret = `/opt/puppet/bin/java #{args.join(' ')} 2>&1`
        Puppet.debug("Output: #{ret}")
        # Need to retry if there is any connection reset message
        if ret.match(/Connection reset|Couldn't connect to/i)
          Puppet.debug('Connection reset observed. sleep for 10 seconds and retry')
          sleep(10)
          `/opt/puppet/bin/java #{args.join(' ')} 2>&1`
        else
          ret
        end
      end

      def get_jsession_id
        # For EM we need a single backslash as we are passing the value in HTTP URL instead of commandline
        # username and password are already CGI escaped in the upper layer
        username = CGI.unescape(self.user)
        username = username.gsub('\\\\','\\')
        login_base_url="https://#{CGI.escape(username)}:#{CGI.escape(self.password)}@#{self.host}:#{self.port}/api/rest"

        url = "#{login_base_url}/ApiConnection/Login"

        response = RestClient::Request.execute(:url => url,
                                               :method => :post,
                                               :verify_ssl => false ,
                                               :payload => '{}',
                                               :headers => {:content_type => :json,
                                                            :accept => :json ,
                                                            'x-dell-api-version'=> '2.0' })

        response.raw_headers["set-cookie"]
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
            'x-dell-api-version'=> '2.0',
            'Cookie' => self.jsessionid
        }
      end
    end

  end
end
