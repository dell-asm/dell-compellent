require 'net/https'
puppet_dir = Pathname.new(__FILE__).parent.parent
require "#{puppet_dir}/files/CommonLib"
require "#{puppet_dir}/files/ResponseParser"
require "#{puppet_dir}/compellent/util"
require 'puppet'

module Puppet
  module Compellent
    class Transport
      attr_accessor :host, :user, :password
      def initialize(connection_info=nil)
        @lib_path = CommonLib.get_path(1).to_s
        @log_path  = CommonLib.get_log_path(1).to_s

        script_run = false
        if connection_info != nil
          self.user = connection_info[:username]
          self.host = connection_info[:server]
          self.password = connection_info[:password]
          script_run = true
        else
          parsed_config = Puppet::Compellent::Util.get_transport
          self.user = parsed_config[:user]
          self.host = parsed_config[:host]
          self.password = parsed_config[:password]
        end

        Puppet.debug('Device login started')


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
    end
  end
end