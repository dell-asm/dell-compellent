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

    loginRespXML = "#{getLogPath(3)}/loginResp_#{getUniqueRefId}.xml"
    loginExitCodeXML = "#{getLogPath(3)}/loginExitCode_#{getUniqueRefId}.xml"
    
    response = system("java -jar #{libpath} -host  #{@url.host} -user #{@url.user} -password #{@url.password} -xmloutputfile #{loginExitCodeXML} -c \"system show -xml #{loginRespXML}\" ")
    parserObj=ResponseParser.new('_')
    parserObj.parse_exitcode(loginExitCodeXML)
    hash= parserObj.return_response
    if "#{hash['Success']}".to_str() == "TRUE"
      Puppet.debug("Login successful..")
    else
      raise Puppet::Error, "#{hash['Error']}"
    end
  end

   def getLogPath(num)
    temp_path = Pathname.new(__FILE__).parent
    Puppet.debug("Temp PATH - #{temp_path}")
    $i = 0
    $num = num
    p = Pathname.new(temp_path)
    while $i < $num  do
      p = Pathname.new(temp_path)
      temp_path = p.dirname
      $i +=1
    end
    temp_path = temp_path.join('logs')
    Puppet.debug("Log Path #{temp_path}")
    return  temp_path
  end

   def getUniqueRefId()
    randNo = Random.rand(100000)
    pid = Process.pid
    return "#{randNo}_PID_#{pid}"
  end

  def get_path(num)
    temp_path = Pathname.new(__FILE__).parent
    Puppet.debug("Temp PATH - #{temp_path}")
    $i = 0
    $num = num
    p = Pathname.new(temp_path)
    while $i < $num  do
      p = Pathname.new(temp_path)
      temp_path = p.dirname
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


