# Class - initialize variable used for device connection

require 'net/https'
require 'puppet/lib/CommonLib'
require 'puppet/lib/ResponseParser'
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
    Puppet.debug("Executing compellent command: " + args.join(" "))
    ret = system("java", *args)
    parser_obj = ResponseParser.new('_')
    parser_obj.parse_exitcode(resp_xml)
    hash = parser_obj.return_response
    {:system_ret => ret,
     :xml_output_file => resp_xml,
     :xml_output_hash => hash, }
  end

end
