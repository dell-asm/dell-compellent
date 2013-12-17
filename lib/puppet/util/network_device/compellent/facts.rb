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
    response = system("java -jar #{libpath} -host #{@transport.host} -user #{@transport.user} -password #{@transport.password} -xmloutputfile /tmp/#{@transport.host}_systemExitCode.xml -c \"system show -xml /tmp/#{@transport.host}_systemResponse.xml\" ")
    response = system("java -jar #{libpath} -host #{@transport.host} -user #{@transport.user} -password #{@transport.password} -xmloutputfile /tmp/#{@transport.host}_controllerExitCode.xml -c \"controller show -xml /tmp/#{@transport.host}_controllerResponse.xml\" ")
    response = system("java -jar #{libpath} -host #{@transport.host} -user #{@transport.user} -password #{@transport.password} -xmloutputfile /tmp/#{@transport.host}_diskfolderExitCode.xml -c \"diskfolder show -xml /tmp/#{@transport.host}_diskfolderResponse.xml\" ")

    resp1 = "/tmp/#{@transport.host}_systemExitCode.xml"
    resp2 = "/tmp/#{@transport.host}_systemResponse.xml"

    resp3 = "/tmp/#{@transport.host}_controllerExitCode.xml"
    resp4 = "/tmp/#{@transport.host}_controllerResponse.xml"

    resp5 = "/tmp/#{@transport.host}_diskfolderExitCode.xml"
    resp6 = "/tmp/#{@transport.host}_diskfolderResponse.xml"

    resp7 = "/tmp/#{@transport.host}_alertExitCode.xml"
    resp8 = "/tmp/#{@transport.host}_alertResponse.xml"

    Puppet.debug("Creating Parser Object")
    parserObj=ResponseParser.new('_')
    parserObj.parse_discovery(resp1,resp2,0)
    parserObj.parse_discovery(resp3,resp4,1)
    parserObj.parse_diskfolder_xml(resp5,resp6)
    @facts =  parserObj.return_response
  end

end

