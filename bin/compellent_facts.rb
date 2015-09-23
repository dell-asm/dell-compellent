#!/opt/puppet/bin/ruby
require 'trollop'
require 'json'
require 'pathname'
require 'xmlsimple'
require 'puppet'

puppet_dir = File.join(Pathname.new(__FILE__).parent.parent,'lib','puppet')
require "#{puppet_dir}/files/CommonLib"
require "#{puppet_dir}/files/ResponseParser"
require "#{puppet_dir}/compellent/transport"

opts = Trollop::options do
  opt :server, 'equallogic server address', :type => :string, :required => true
  opt :port, 'equallogic server port', :default => 443
  opt :username, 'equallogic server username', :type => :string, :required => true
  opt :password, 'equallogic server password', :type => :string, :default => ENV['PASSWORD']
  opt :timeout, 'command timeout', :default => 180
  opt :scheme, 'connection scheme', :default => 'https'
  opt :output, 'Output facts to file location', :type => :string, :required => true
end

@file_path = File.join(Pathname.new(__FILE__).parent.parent,'lib','files')
@seperator = ' '

begin
  args=['--trace']

  Puppet.settings.initialize_global_settings(args)
  Puppet.settings.initialize_app_defaults(Puppet::Settings.app_defaults_for_run_mode(Puppet.run_mode))
  if Puppet.respond_to?(:base_context) && Puppet.respond_to?(:push_context)
    Puppet.push_context(Puppet.base_context(Puppet.settings))
  end

  Puppet::Util::Log.newdestination("console")
  Puppet::Util::Log.level = :debug

  Puppet[:color] = false

  Puppet.debug('Puppet logging set to console')
rescue
  puts 'Error setting up console logging'
  exit 1
end


@transport ||= Puppet::Compellent::Transport.new(opts)

def retrieve
  libpath = CommonLib.get_path(1)

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


  parser_obj=ResponseParser.new('_')
  parser_obj.parse_discovery(system_exitcodexml,system_respxml,0)
  parser_obj.parse_discovery(ctrl_exitcodexml,ctrl_respxml,1)
  parser_obj.parse_diskfolder_xml(diskfolder_exitcodexml,diskfolder_respxml)
  facts =  parser_obj.return_response
  facts["system_data"]=JSON.pretty_generate(XmlSimple.xml_in(system_respxml))
  facts["diskfolder_data"]=JSON.pretty_generate(XmlSimple.xml_in(diskfolder_respxml))
  facts["controller_data"]=JSON.pretty_generate(XmlSimple.xml_in(ctrl_respxml))

  facts["volume_data"]=JSON.pretty_generate(XmlSimple.xml_in(volume_respxml))

  facts["server_data"]=JSON.pretty_generate(XmlSimple.xml_in(server_respxml))

  facts["replayprofile_data"]=JSON.pretty_generate(XmlSimple.xml_in(replayprofile_respxml))

  facts["storageprofile_data"]=JSON.pretty_generate(XmlSimple.xml_in(storageprofile_respxml))

  facts["model"]="Compellent"

  File.delete(system_exitcodexml,system_respxml,ctrl_exitcodexml,ctrl_respxml,diskfolder_exitcodexml,diskfolder_respxml,volume_respxml,volume_exitcodexml,server_respxml,server_exitcodexml,replayprofile_respxml,replayprofile_exitcodexml,storageprofile_respxml,storageprofile_exitcodexml)
  facts
end

begin
  results = retrieve.to_json
  if results.empty?
    puts "Unable to get updated facts"
    exit 1
  else
    File.write(opts[:output], results) unless results.empty?
  end
rescue Exception => e
  puts e.message
  puts e.backtrace
  exit 1
end