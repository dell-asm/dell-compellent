require 'puppet/util/network_device/compellent'
require 'puppet/util/network_device/transport_compellent'
require 'rexml/document'

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

  def read_node(node,key_name)
    if node.has_elements?
      node.each_element do |child|
        read_node(child,key_name)
      end
    else
      key_name="#{key_name}#{@seperator}#{node.name()}"
      self.facts[key_name]=node.text
    end
    key_name
  end

  def parse_discovery(result_file_name, output_file_name,index)
    result_file = File.new(result_file_name)
    result_doc = Document.new(result_file)
    result= XPath.first(result_doc, "//Success")
    if result.text.eql?'TRUE'
      result_file = File.new(output_file_name)
      output_doc = Document.new(result_file)
      #index=1;
      output_doc.root.each_element do |system|
        if index > 0
          key= "#{system.name()}#{@seperator}#{index}"
        else
          key= "#{system.name()}"
        end
        read_node(system,key)
        index=index+1
      end
    end
    @facts
  end

def get_index_value(node)
    node.elements["Index"].text
  end

  def read_diskfolder_node(node,key_name)
    if node.has_elements?
      node.each_element do |child|
        read_diskfolder_node(child,key_name)
      end
    else
      if node.parent.name().eql?"StorageType" then  key_name="#{key_name}#{@seperator}StorageType#{@seperator}#{get_index_value(node.parent)}#{@seperator}#{node.name()}"
      else
        key_name="#{key_name}#{@seperator}#{node.name()}"
      end
      self.facts[key_name]=node.text
    end
    key_name
  end

 def parse_diskfolder_xml(result_file_name, output_file_name)
    result_file = File.new(result_file_name)
    result_doc = Document.new(result_file)
    result= XPath.first(result_doc, "//Success")
    if result.text.eql?'TRUE'
      result_file = File.new(output_file_name)
      output_doc = Document.new(result_file)
      index=1;
      output_doc.root.each_element do |system|
        key= "#{system.name()}#{@seperator}#{index}"
        read_diskfolder_node(system,key)
        index=index+1
      end
    end
    @facts
  end


  def retrieve
    Puppet.debug("In facts retrieve")
    Puppet.debug("IP Address is #{@transport.host} Username is #{@transport.user} Password is #{@transport.password}")
    response = system("java -jar /etc/puppet/modules/compellent/lib/puppet/util/network_device/compellent/CompCU-6.3.jar -host #{@transport.host} -user #{@transport.user} -password P@ssw0rd -xmloutputfile /tmp/#{@transport.host}_systemExitCode.xml -c \"system show -xml /tmp/#{@transport.host}_systemResponse.xml\" ")
    response = system("java -jar /etc/puppet/modules/compellent/lib/puppet/util/network_device/compellent/CompCU-6.3.jar -host #{@transport.host} -user #{@transport.user} -password P@ssw0rd -xmloutputfile /tmp/#{@transport.host}_controllerExitCode.xml -c \"controller show -xml /tmp/#{@transport.host}_controllerResponse.xml\" ")
    response = system("java -jar /etc/puppet/modules/compellent/lib/puppet/util/network_device/compellent/CompCU-6.3.jar -host #{@transport.host} -user #{@transport.user} -password P@ssw0rd -xmloutputfile /tmp/#{@transport.host}_diskfolderExitCode.xml -c \"diskfolder show -xml /tmp/#{@transport.host}_diskfolderResponse.xml\" ")
 #  response = system("java -jar /etc/puppet/modules/compellent/lib/puppet/util/network_device/compellent/CompCU-6.3.jar -host #{@transport.host} -user #{@transport.user} -password P@ssw0rd -xmloutputfile /tmp/#{@transport.host}_alertExitCode.xml -c \"alert show -xml /tmp/#{@transport.host}_alertResponse.xml\" ")

    resp1 = "/tmp/#{@transport.host}_systemExitCode.xml"
    resp2 = "/tmp/#{@transport.host}_systemResponse.xml"

    resp3 = "/tmp/#{@transport.host}_controllerExitCode.xml"
    resp4 = "/tmp/#{@transport.host}_controllerResponse.xml"

    resp5 = "/tmp/#{@transport.host}_diskfolderExitCode.xml"
    resp6 = "/tmp/#{@transport.host}_diskfolderResponse.xml"

    resp7 = "/tmp/#{@transport.host}_alertExitCode.xml"
    resp8 = "/tmp/#{@transport.host}_alertResponse.xml"


    parse_discovery(resp1,resp2,0)
    parse_discovery(resp3,resp4,1)
    parse_diskfolder_xml(resp5,resp6)
#   parse_discovery(resp7,resp8,1)

    @facts
  end

end


