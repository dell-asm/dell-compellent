# encoding: utf-8
require "xmlsimple"

require "puppet/provider/compellent"
require "puppet/files/ResponseParser"
require "puppet/files/CommonLib"

Puppet::Type.type(:compellent_cluster_server_map).provide(:compellent_cluster_server_map, :parent => Puppet::Provider::Compellent) do
  @doc = "Manage Compellent Server mapping / unmapping with cluster"
  attr_accessor :server_information, :server_index, :cluster_server_index
  @server_information

  def add_server_to_cluster_commandline
    "server addtocluster -index '%s' -parentindex '%s'" % [server_index, cluster_server_index]
  end

  def remove_server_from_cluster_commandline
    "server removefromcluster -name '%s'" % [@resource[:server_name]]
  end

  def show_server_commandline(cluster_name=nil)
    command = "server show"

    # If cluster name is not passed, then find all server information
    if cluster_name
      command.concat(" -name '%s'" % [cluster_name])
      command.concat(" -folder '%s'" % [@resource[:folder]]) unless @resource[:folder].strip.empty?
    end

    command
  end

  def create
    cluster_server_name = @resource[:cluster_server_name]
    server_name = @resource[:server_name]

    libpath = CommonLib.get_path(1)
    cluster_create_exit_code_xml = "#{CommonLib.get_log_path(1)}/server_cluster_exit_code_#{CommonLib.get_unique_refid}.xml"
    connection.command_exec("#{libpath}", "#{cluster_create_exit_code_xml}", "\"#{add_server_to_cluster_commandline}\"")

    parser_obj = ResponseParser.new("_")
    parser_obj.parse_exitcode(cluster_create_exit_code_xml)
    response = parser_obj.return_response
    File.delete(cluster_create_exit_code_xml)

    if response["Success"] == "TRUE"
      Puppet.info("Successfully added the server %s to cluster object" % [server_name, cluster_server_name])
    else
      Puppet.info("Unable to add the server %s to the cluster %s." % [server_name, cluster_server_name])
      raise Puppet::Error, response["Error"]
    end
  end

  def destroy
    cluster_server_name = @resource[:cluster_server_name]
    server_name = @resource[:server_name]

    libpath = CommonLib.get_path(1)
    cluster_remove_exit_code_xml = "#{CommonLib.get_log_path(1)}/server_cluster_remove_exit_code_#{CommonLib.get_unique_refid}.xml"
    connection.command_exec("#{libpath}", "#{cluster_remove_exit_code_xml}", "\"#{remove_server_from_cluster_commandline}\"")

    parser_obj = ResponseParser.new("_")
    parser_obj.parse_exitcode(cluster_remove_exit_code_xml)
    response = parser_obj.return_response
    File.delete(cluster_remove_exit_code_xml)

    if response["Success"] == "TRUE"
      Puppet.info("Successfully removed the server %s from cluster object" % [server_name, cluster_server_name])
    else
      Puppet.info("Unable to remove the server %s from the cluster %s." % [server_name, cluster_server_name])
      raise Puppet::Error, response["Error"]
    end
  end

  # Assume cluster object and server object are already created.
  # Compellent API will raise error in case any of these is missing
  def exists?
    cluster_server_name = @resource[:cluster_server_name]
    server_name = @resource[:server_name]
    server_folder = @resource[:folder]

    @cluster_server_index = ""

    libpath = CommonLib.get_path(1)
    server_show_exit_code_xml = "#{CommonLib.get_log_path(1)}/serverShowExitCode_#{CommonLib.get_unique_refid}.xml"
    server_show_response_xml = "#{CommonLib.get_log_path(1)}/serverShowResponse_#{CommonLib.get_unique_refid}.xml"
    connection.command_exec("#{libpath}",
                            "#{server_show_exit_code_xml}",
                            "\"#{show_server_commandline(cluster_server_name)} -xml #{server_show_response_xml}\"")

    parser_obj = ResponseParser.new("_")

    if server_folder.empty?
      self.server_information = parser_obj.retrieve_empty_folder_server_properties(server_show_response_xml, cluster_server_name)
      @cluster_server_index = self.server_information["Index"].first unless self.server_information["Index"].nil?
    else
      parser_obj.parse_discovery(server_show_exit_code_xml, server_show_response_xml, 0)
      self.server_information = parser_obj.return_response
      @cluster_server_index = self.server_information["server_Index"]
    end

    # Cannot find cluster server object
    raise Puppet::Error, "Cluster Server %s do not exists on storage center" % [cluster_server_name] unless @cluster_server_index

    # get all server information
    connection.command_exec("#{libpath}","#{server_show_exit_code_xml}","\"#{show_server_commandline} -xml #{server_show_response_xml}\"")
    server_data = JSON.parse(JSON.pretty_generate(XmlSimple.xml_in(server_show_response_xml)))
    mapped_servers = server_data["server"].select {|server| server["ParentIndex"].first == @cluster_server_index  &&
        server["Name"].first == server_name &&
        (server["Folder"].first.is_a?(Hash) ? "" : server["Folder"].first).downcase == server_folder.downcase}

    File.delete(server_show_exit_code_xml, server_show_response_xml)

    server = server_data["server"].select {|server| server["Name"].first == @resource[:server_name] &&
        (server["Folder"].first.is_a?(Hash) ? "" : server["Folder"].first).downcase == server_folder.downcase}
    @server_index = server.first["Index"].first unless server.empty?

    raise Puppet::Error, "Server %s do not exists on storage center" % [server_name] unless @server_index

    return !mapped_servers.empty?
  end
end

