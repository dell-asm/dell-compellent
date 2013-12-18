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

  def get_path(num)
    temp_path = Pathname.new(__FILE__).parent
    Puppet.debug("Temp PATH #{temp_path}")
    $i = 0
    $num = num
    path = Pathname.new(temp_path)
    while $i < $num  do
      path = Pathname.new(temp_path)
      temp_path = path.dirname
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

    system_respxml = "#{get_log_path(3)}/systemResp_#{get_unique_refid}.xml"
    system_exitcodexml = "#{get_log_path(3)}/systemExitCode_#{get_unique_refid}.xml"
    ctrl_respxml = "#{get_log_path(3)}/ctrlResp_#{get_unique_refid}.xml"
    ctrl_exitcodexml = "#{get_log_path(3)}/ctrlExitCode_#{get_unique_refid}.xml"
    diskfolder_respxml = "#{get_log_path(3)}/diskfolderResp_#{get_unique_refid}.xml"
    diskfolder_exitcodexml = "#{get_log_path(3)}/diskfolderExitCode_#{get_unique_refid}.xml"
    
    response = system("java -jar #{libpath} -host #{@transport.host} -user #{@transport.user} -password #{@transport.password} -xmloutputfile #{system_exitcodexml} -c \"system show -xml #{system_respxml}\" ")
    response = system("java -jar #{libpath} -host #{@transport.host} -user #{@transport.user} -password #{@transport.password} -xmloutputfile #{ctrl_exitcodexml} -c \"controller show -xml #{ctrl_respxml}\" ")
    response = system("java -jar #{libpath} -host #{@transport.host} -user #{@transport.user} -password #{@transport.password} -xmloutputfile #{diskfolder_exitcodexml} -c \"diskfolder show -xml #{diskfolder_respxml}\" ")

    Puppet.debug("Creating Parser Object")
    parser_obj=ResponseParser.new('_')
    parser_obj.parse_discovery(system_exitcodexml,system_respxml,0)
    parser_obj.parse_discovery(ctrl_exitcodexml,ctrl_respxml,1)
    parser_obj.parse_diskfolder_xml(diskfolder_exitcodexml,diskfolder_respxml)
    @facts =  parser_obj.return_response
  end

end

