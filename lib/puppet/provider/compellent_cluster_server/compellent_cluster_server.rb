# encoding: utf-8
require "xmlsimple"

require "puppet/provider/compellent"
require "puppet/files/ResponseParser"
require "puppet/files/CommonLib"

Puppet::Type.type(:compellent_cluster_server).provide(:compellent_cluster_server, :parent => Puppet::Provider::Compellent) do
  @doc = "Manage Compellent Server creation and deletion."
  attr_accessor :server_information
  @server_information

  def create_server_commandline
    command = "server createcluster -name '#{@resource[:name]}'"

    server_server_folder = @resource[:folder]
    server_operating_system = @resource[:operatingsystem]

    command.concat(" -folder '%s'" % [server_server_folder]) unless server_server_folder.strip.empty?
    command.concat(" -os '%s'" % [server_operating_system]) unless server_operating_system.strip.empty?

    command
  end

  # Command line for getting all or specific server information
  #
  # @param server_name [String] name of server, or cluster server
  # @return [String]
  def show_server_commandline(server_name=nil)
    command = "server show"

    if server_name
      command.concat(" -name '%s'" % [server_name])
    end
    command.concat(" -folder '%s'" % [@resource[:folder]]) unless @resource[:folder].strip.empty?

    command
  end

  def create
    cluster_server_name = @resource[:name]
    folder_value = @resource[:folder]

    server_cli = create_server_commandline
    libpath = CommonLib.get_path(1)

    unless folder_value.empty?
      Puppet.debug("Creating folder with name %s" % [folder_value])
      server_folder_exit_code_xml = "#{CommonLib.get_log_path(1)}/serverFolderCreateExitCode_#{CommonLib.get_unique_refid}.xml"
      connection.command_exec("#{libpath}","#{server_folder_exit_code_xml}","\"serverfolder create -name '#{folder_value}'\"")

      parser_obj = ResponseParser.new("_")
      parser_obj.parse_exitcode(server_folder_exit_code_xml)
      response = parser_obj.return_response
      File.delete(server_folder_exit_code_xml)

      if response["Success"] == "TRUE"
        Puppet.info("Successfully created the server folder '%s'." % [folder_value])
      elsif response["Error"].match(/already exists/)
        Puppet.info("Server folder '%s' already exists" % [folder_value])
      else
        raise Puppet::Error, "#{response['Error']}"
      end
    end

    cluster_create_exit_code_xml = "#{CommonLib.get_log_path(1)}/serverCreateExitCode_#{CommonLib.get_unique_refid}.xml"
    connection.command_exec("#{libpath}", "#{cluster_create_exit_code_xml}", "\"#{server_cli}\"")

    parser_obj = ResponseParser.new("_")
    parser_obj.parse_exitcode(cluster_create_exit_code_xml)
    response = parser_obj.return_response
    File.delete(cluster_create_exit_code_xml)

    if response["Success"] == "TRUE"
      Puppet.info("Successfully created the cluster server '%s'" % [cluster_server_name])
    else
      Puppet.info("Unable to create the cluster server '%s'" % [cluster_server_name])
      raise Puppet::Error, response["Error"]
    end
  end

  def destroy
    server_name = @resource[:name]
    Puppet.debug("Destroying cluster server '%s'" % [server_name])

    libpath = CommonLib.get_path(1)
    server_destroy_exit_code_xml = "#{CommonLib.get_log_path(1)}/serverDestroyExitCode_#{CommonLib.get_unique_refid}.xml"
    server_folder = @resource[:folder]

    server_index = server_folder.length > 0 ? self.server_information["server_Index"] : self.server_information["Index"].first

    connection.command_exec("#{libpath}","#{server_destroy_exit_code_xml}","\"server delete -index #{server_index}\"")
    parser_obj = ResponseParser.new("_")
    parser_obj.parse_exitcode(server_destroy_exit_code_xml)

    response = parser_obj.return_response
    File.delete(server_destroy_exit_code_xml)

    if response["Success"] == "TRUE"
      Puppet.info("Successfully deleted the cluster server '%s'." % [server_name])
    else
      Puppet.info("Unable to delete the cluster server '%s'." % [server_name])
      raise Puppet::Error, response["Error"]
    end
  end

  def exists?
    cluster_server_name = @resource[:name]

    libpath = CommonLib.get_path(1)
    server_show_cli = show_server_commandline(cluster_server_name)

    server_show_exit_code_xml = "#{CommonLib.get_log_path(1)}/serverShowExitCode_#{CommonLib.get_unique_refid}.xml"
    server_show_response_xml = "#{CommonLib.get_log_path(1)}/serverShowResponse_#{CommonLib.get_unique_refid}.xml"
    connection.command_exec("#{libpath}","#{server_show_exit_code_xml}","\"#{server_show_cli} -xml #{server_show_response_xml}\"")

    parser_obj = ResponseParser.new("_")
    folder_value = @resource[:folder]
    server_index = ""

    if folder_value.length > 0
      parser_obj.parse_discovery(server_show_exit_code_xml, server_show_response_xml, 0)
      self.server_information = parser_obj.return_response
      Puppet.debug("Server folder is not null, server_information : %s" % [self.server_information])
      server_index = self.server_information["server_Index"]
    else
      self.server_information = parser_obj.retrieve_empty_folder_server_properties(server_show_response_xml, cluster_server_name)
      Puppet.debug("Server folder is null, server_information : %s" % [self.server_information])
      if self.server_information["Index"] != nil
        server_index = self.server_information["Index"].first
      end
    end

    Puppet.debug("Value of property ensure '%s'" % [@resource[:ensure]])
    File.delete(server_show_exit_code_xml, server_show_response_xml)

    if server_index.empty?
      Puppet.info("Server Cluster %s does not exist" % [cluster_server_name])
      false
    else
      Puppet.info("Server Cluster %s exist with index %s" % [cluster_server_name, server_index.to_s])
      if @resource[:ensure] == :absent
        # For removal, we want to indicate true existence only if there is no associated mappings for the server cluster
        server_cluster_mappings_empty?(server_index)
      else
        true
      end
    end
  end

  # Checks if there are any associated mappings for given server cluster
  #
  # @param cluster_server_index [String] index of server cluster object in compellent servers
  # @return [Boolean]
  def server_cluster_mappings_empty?(cluster_server_index)
    Puppet.debug("Getting Server Cluster Mappings for Index: %s" % cluster_server_index)
    # Get all servers and see if any of them is mapped to our server cluster
    libpath = CommonLib.get_path(1)

    exit_code_xml = "#{CommonLib.get_log_path(1)}/serverShowShowExitCode_#{CommonLib.get_unique_refid}.xml"
    show_response_xml = "#{CommonLib.get_log_path(1)}/serverShowShowResponse_#{CommonLib.get_unique_refid}.xml"

    connection.command_exec("#{libpath}","#{exit_code_xml}","\"#{show_server_commandline} -xml #{show_response_xml}\"")
    server_data = JSON.parse(JSON.pretty_generate(XmlSimple.xml_in(show_response_xml)))
    File.delete(exit_code_xml, show_response_xml)

    mapped_servers = server_data["server"].select do |server|
      folder_name = server["Folder"].first.is_a?(Hash) ? "" : server["Folder"].first
      server["ParentIndex"].first == cluster_server_index && folder_name.downcase == @resource[:folder].downcase
    end
    Puppet.debug("Found %d mapped servers for Server Cluster Index: %s" % [mapped_servers.length, cluster_server_index])

    mapped_servers.empty?
  end
end

