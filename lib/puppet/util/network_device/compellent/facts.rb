require 'puppet/util/network_device/compellent'
require 'puppet/util/network_device/transport_compellent'
require 'rexml/document'
require 'puppet/lib/ResponseParser'

include REXML

class Puppet::Util::NetworkDevice::Compellent::Facts

  attr_reader :transport
  attr_accessor :facts,:seperator
  def initialize(transport)
    Puppet.debug("In facts initialize")
    @facts = Hash.new
    @seperator="_"
    @transport = transport
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

  def get_path(num)
    temp_path = Pathname.new(__FILE__).parent
    Puppet.debug("Temp PATH #{temp_path}")
    $i = 0
    $num = num
    p = Pathname.new(temp_path)
    while $i < $num  do
      p = Pathname.new(temp_path)
      temp_path = p.dirname
      $i +=1
    end
    temp_path = temp_path.join('lib/CompCU-6.3.jar')
    Puppet.debug("Final Lib Path #{temp_path}")
    return temp_path
  end

  def retrieve
    libpath = get_path(3)
    Puppet.debug("In facts retrieve")
    Puppet.debug("IP Address is #{@transport.host} Username is #{@transport.user} Password is #{@transport.password}")

    systemRespXML = "#{getLogPath(2)}/systemResp_#{getUniqueRefId}.xml"
    systemExitCodeXML = "#{getLogPath(2)}/systemExitCode_#{getUniqueRefId}.xml"
    ctrlRespXML = "#{getLogPath(2)}/ctrlResp_#{getUniqueRefId}.xml"
    ctrlExitCodeXML = "#{getLogPath(2)}/ctrlExitCode_#{getUniqueRefId}.xml"
    diskfolderRespXML = "#{getLogPath(2)}/diskfolderResp_#{getUniqueRefId}.xml"
    diskfolderExitCodeXML = "#{getLogPath(2)}/diskfolderExitCode_#{getUniqueRefId}.xml"
    
    response = system("java -jar #{libpath} -host #{@transport.host} -user #{@transport.user} -password #{@transport.password} -xmloutputfile #{systemExitCodeXML} -c \"system show -xml #{systemRespXML}\" ")
    response = system("java -jar #{libpath} -host #{@transport.host} -user #{@transport.user} -password #{@transport.password} -xmloutputfile #{ctrlExitCodeXML} -c \"controller show -xml #{ctrlRespXML}\" ")
    response = system("java -jar #{libpath} -host #{@transport.host} -user #{@transport.user} -password #{@transport.password} -xmloutputfile #{diskfolderExitCodeXML} -c \"diskfolder show -xml #{diskfolderRespXML}\" ")

    Puppet.debug("Creating Parser Object")
    parserObj=ResponseParser.new('_')
    parserObj.parse_discovery(systemExitCodeXML,systemRespXML,0)
    parserObj.parse_discovery(ctrlExitCodeXML,ctrlRespXML,1)
    parserObj.parse_diskfolder_xml(diskfolderExitCodeXML,diskfolderRespXML)
    @facts =  parserObj.return_response
  end

end

