require 'puppet/util/network_device/compellent'
require 'puppet/util/network_device/transport_compellent'
require 'rexml/document'
require 'puppet/files/ResponseParser'
require 'puppet/files/CommonLib'
require 'json'
require 'xmlsimple'

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

  def retrieve
    libpath = CommonLib.get_path(1)
    Puppet.debug("In facts retrieve")
    #Puppet.debug("IP Address is #{@transport.host} Username is #{@transport.user} Password is #{@transport.password}")
    Puppet.debug("IP Address is #{@transport.host} Username is #{@transport.user}")

    system_respxml = "#{CommonLib.get_log_path(1)}/systemResp_#{CommonLib.get_unique_refid}.xml"
    system_exitcodexml = "#{CommonLib.get_log_path(1)}/systemExitCode_#{CommonLib.get_unique_refid}.xml"
    ctrl_respxml = "#{CommonLib.get_log_path(1)}/ctrlResp_#{CommonLib.get_unique_refid}.xml"
    ctrl_exitcodexml = "#{CommonLib.get_log_path(1)}/ctrlExitCode_#{CommonLib.get_unique_refid}.xml"
    diskfolder_respxml = "#{CommonLib.get_log_path(1)}/diskfolderResp_#{CommonLib.get_unique_refid}.xml"
    diskfolder_exitcodexml = "#{CommonLib.get_log_path(1)}/diskfolderExitCode_#{CommonLib.get_unique_refid}.xml"
    volume_respxml = "#{CommonLib.get_log_path(1)}/volumeResp_#{CommonLib.get_unique_refid}.xml"
    volume_exitcodexml = "#{CommonLib.get_log_path(1)}/volumeExitCode_#{CommonLib.get_unique_refid}.xml"
    server_respxml = "#{CommonLib.get_log_path(1)}/serverResp_#{CommonLib.get_unique_refid}.xml"
    server_exitcodexml = "#{CommonLib.get_log_path(1)}/serverExitCode_#{CommonLib.get_unique_refid}.xml"
    replayprofile_respxml = "#{CommonLib.get_log_path(1)}/replayprofileResp_#{CommonLib.get_unique_refid}.xml"
    replayprofile_exitcodexml = "#{CommonLib.get_log_path(1)}/replayprofileExitCode_#{CommonLib.get_unique_refid}.xml"
    storageprofile_respxml = "#{CommonLib.get_log_path(1)}/storageprofileResp_#{CommonLib.get_unique_refid}.xml"
    storageprofile_exitcodexml = "#{CommonLib.get_log_path(1)}/storageprofileExitCode_#{CommonLib.get_unique_refid}.xml"

    @transport.command_exec("#{libpath}","#{system_exitcodexml}","\"system show -xml #{system_respxml}\"")
    @transport.command_exec("#{libpath}","#{ctrl_exitcodexml}","\"controller show -xml #{ctrl_respxml}\"")
    @transport.command_exec("#{libpath}","#{diskfolder_exitcodexml}","\"diskfolder show -xml #{diskfolder_respxml}\"")
    @transport.command_exec("#{libpath}","#{volume_exitcodexml}","\"volume show -xml #{volume_respxml}\"")
    @transport.command_exec("#{libpath}","#{server_exitcodexml}","\"server show -xml #{server_respxml}\"")
    @transport.command_exec("#{libpath}","#{replayprofile_exitcodexml}","\"replayprofile show -xml #{replayprofile_respxml}\"")
    @transport.command_exec("#{libpath}","#{storageprofile_exitcodexml}","\"storageprofile show -xml #{storageprofile_respxml}\"")

    Puppet.debug("Creating Parser Object")
    parser_obj=ResponseParser.new('_')
    parser_obj.parse_discovery(system_exitcodexml,system_respxml,0)
    parser_obj.parse_discovery(ctrl_exitcodexml,ctrl_respxml,1)
    parser_obj.parse_diskfolder_xml(diskfolder_exitcodexml,diskfolder_respxml)
    @facts =  parser_obj.return_response
    self.facts["system_data"]=JSON.pretty_generate(XmlSimple.xml_in(system_respxml))
    self.facts["diskfolder_data"]=JSON.pretty_generate(XmlSimple.xml_in(diskfolder_respxml))
    self.facts["controller_data"]=JSON.pretty_generate(XmlSimple.xml_in(ctrl_respxml))
    self.facts["volume_data"]=JSON.pretty_generate(XmlSimple.xml_in(volume_respxml))
    self.facts["server_data"]=JSON.pretty_generate(XmlSimple.xml_in(server_respxml))
    self.facts["replayprofile_data"]=JSON.pretty_generate(XmlSimple.xml_in(replayprofile_respxml))
    self.facts["storageprofile_data"]=JSON.pretty_generate(XmlSimple.xml_in(storageprofile_respxml))
    self.facts["model"]="Compellent"

    File.delete(system_exitcodexml,system_respxml,ctrl_exitcodexml,ctrl_respxml,diskfolder_exitcodexml,diskfolder_respxml,volume_respxml,volume_exitcodexml,server_respxml,server_exitcodexml,replayprofile_respxml,replayprofile_exitcodexml,storageprofile_respxml,storageprofile_exitcodexml)
    @facts
  end

end

