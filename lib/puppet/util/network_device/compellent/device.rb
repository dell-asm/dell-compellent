# Class - Making connection with device

require 'puppet/util/network_device'
require 'puppet/util/network_device/compellent/facts'
require 'puppet/util/network_device/transport_compellent'
require 'uri'
require 'net/https'
require 'puppet/lib/ResponseParser'

class Puppet::Util::NetworkDevice::Compellent::Device

  attr_accessor :url, :transport
  def initialize(url, option = {})
    Puppet.debug("Device login started")
    @url = URI.parse(url)
    redacted_url = @url.dup
    redacted_url.password = "****" if redacted_url.password
    Puppet.debug("Puppet::Device::Compellent: connecting to Compellent device #{redacted_url}")
    raise ArgumentError, "Invalid scheme #{@url.scheme}. Must be https" unless @url.scheme == 'https'
    raise ArgumentError, "no user specified" unless @url.user
    raise ArgumentError, "no password specified" unless @url.password
    Puppet.debug("Host IP is #{@url.host}  #{@url.scheme}")
    @transport = Puppet::Util::NetworkDevice::Transport_compellent.new
    @transport.host = @url.host
    @transport.user = @url.user
    @transport.password = @url.password
    Puppet.debug("host is #{@transport.host}")
    libpath = get_path(3)

    login_respxml = "#{get_log_path(3)}/loginResp_#{get_unique_refid}.xml"
    login_exitcodexml = "#{get_log_path(3)}/loginExitCode_#{get_unique_refid}.xml"
    
    response = system("java -jar #{libpath} -host  #{@url.host} -user #{@url.user} -password #{@url.password} -xmloutputfile #{login_exitcodexml} -c \"system show -xml #{login_respxml}\" ")
    parser_obj=ResponseParser.new('_')
    parser_obj.parse_exitcode(login_exitcodexml)
    hash= parser_obj.return_response
    if "#{hash['Success']}".to_str() == "TRUE"
      Puppet.debug("Login successful..")
    else
      raise Puppet::Error, "#{hash['Error']}"
    end
  end

   def get_log_path(num)
    temp_path = Pathname.new(__FILE__).parent
    Puppet.debug("Temp PATH - #{temp_path}")
    $i = 0
    $num = num
    path = Pathname.new(temp_path)
    while $i < $num  do
      path = Pathname.new(temp_path)
      temp_path = path.dirname
      $i +=1
    end
    temp_path = temp_path.join('logs')
    Puppet.debug("Log Path #{temp_path}")
    return  temp_path
  end

   def get_unique_refid()
    randno = Random.rand(100000)
    pid = Process.pid
    return "#{randno}_PID_#{pid}"
  end

  def get_path(num)
    temp_path = Pathname.new(__FILE__).parent
    Puppet.debug("Temp PATH - #{temp_path}")
    $i = 0
    $num = num
    path = Pathname.new(temp_path)
    while $i < $num  do
      path = Pathname.new(temp_path)
      temp_path = path.dirname
      $i +=1
    end
    temp_path = temp_path.join('lib/CompCU-6.3.jar')
    Puppet.debug("Path #{temp_path}")
    return  temp_path
  end

  def facts
    Puppet.debug("In facts")
    @facts ||= Puppet::Util::NetworkDevice::Compellent::Facts.new(@transport)
    facts = @facts.retrieve

    facts
  end
end


