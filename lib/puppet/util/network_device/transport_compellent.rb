# Class - initialize variable used for device connection

require 'net/https'
require 'puppet/files/CommonLib'
require 'puppet/files/ResponseParser'
require 'puppet/util/network_device'

class Puppet::Util::NetworkDevice::Transport_compellent
  attr_accessor :host, :user, :password
  def initialize
    @lib_path = CommonLib.get_path(1).to_s
    @log_path = CommonLib.get_log_path(1).to_s
  end

  # Executes a compellent jar command for this transport
  def exec(command, *extra_args)
    ref_id = CommonLib.get_unique_refid
    resp_xml = "#{@log_path}/response_#{ref_id}.xml"
    args = ["-jar", @lib_path,
      "-host", @host,
      "-user", @user,
      "-password", @password,
      "-xmloutputfile", resp_xml,
      "-c", command] + extra_args
   # Puppet.debug("Executing compellent command: " + args.join(" "))
    ret = system("java", *args)
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
    args = ["-jar", libPath,
      "-host", @host,
      "-user", @user,
      "-password", @password,
      "-xmloutputfile", respXml,
      "-c", command]
    #   Puppet.debug("Executing compellent command: " + args.join(" "))
    ret = `/opt/puppet/bin/java #{args.join(' ')} 2>&1`
    Puppet.debug("Output: #{ret}")
    # Need to retry if there is any connection reset message
    if ret.match(/Connection reset|Couldn't connect to/i)
      Puppet.debug("Connection reset observed. sleep for 10 seconds and retry")
      sleep(10)
      ret = `/opt/puppet/bin/java #{args.join(' ')} 2>&1`
    else
      ret
    end
  end
end

