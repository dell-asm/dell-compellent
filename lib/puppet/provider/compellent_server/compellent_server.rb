require 'puppet/provider/compellent'
require 'puppet/lib/ResponseParser'
require 'puppet/lib/CommonLib'

Puppet::Type.type(:compellent_server).provide(:compellent_server, :parent => Puppet::Provider::Compellent) do
  @doc = "Manage Compellent Server creation and deletion."
 attr_accessor :hash_map
  @hash_map
  def create_servercommandline
    command = "server create -name '#{@resource[:name]}' -WWN '#{@resource[:wwn]}'"
	
	server_serverfolder = @resource[:serverfolder]
	server_serverfolder = server_serverfolder.strip
    if server_serverfolder.length > 0
      command = command + " -folder '#{server_serverfolder}'"
    end
	
	server_notes = @resource[:notes]
	server_notes = server_notes.strip
    if server_notes.length > 0
      command = command + " -notes '#{server_notes}'"
    end
	
	server_operatingsystem = @resource[:operatingsystem] 
	server_operatingsystem = server_operatingsystem.strip
    if server_operatingsystem.length > 0
	command = command + " -os '#{server_operatingsystem}'"
    end
    return command
  end

  def showserver_commandline
    command = "server show -name '#{@resource[:name]}'"
    server_serverfolder = @resource[:serverfolder]
    server_serverfolder = server_serverfolder.strip
    if server_serverfolder.length > 0 
      command = command + " -folder '#{@resource[:serverfolder]}'"
    end
    return command
  end
  
  def create
    puts "Inside Create Method."
    server_name = @resource[:name]
    Puppet.debug("Resource name #{server_name}")
    folder_value = @resource[:serverfolder]	
    servercli = create_servercommandline
   libpath = CommonLib.get_path(1)
    puts "Server CLI"
    puts servercli
    
    Puppet.debug("Creating server with name '#{server_name}'")
	if "#{folder_value}".size != 0
		Puppet.debug("Creating server folder with name '#{folder_value}'")
		server_folder_exitcodexml = "#{CommonLib.get_log_path(1)}/serverFolderCreateExitCode_#{CommonLib.get_unique_refid}.xml"
		server_folder_command = "java -jar #{libpath} -host #{transport.host} -user #{transport.user} -password #{transport.password} -xmloutputfile #{server_folder_exitcodexml} -c \"serverfolder create -name '#{folder_value}'\""
		Puppet.debug(server_folder_command)
        system (server_folder_command)
		parser_obj=ResponseParser.new('_')
        parser_obj.parse_exitcode(server_folder_exitcodexml)
        hash= parser_obj.return_response
		if "#{hash['Success']}".to_str() == "TRUE"
			Puppet.info("Successfully created the server folder '#{folder_value}'.")
        else
			b = "#{hash['Error']}".to_str()
			if b.include? "already exists"
				Puppet.info("Server folder '#{folder_value}' already exists")
			else
				raise Puppet::Error, "#{hash['Error']}"
			end
		end
	end
	
    servercreate_exitcodexml = "#{CommonLib.get_log_path(1)}/serverCreateExitCode_#{CommonLib.get_unique_refid}.xml"
	
    servercreatecommand = "java -jar -jar #{libpath} -host #{transport.host} -user #{transport.user} -password #{transport.password} -xmloutputfile #{servercreate_exitcodexml} -c \"#{servercli}\""
    Puppet.debug(servercreatecommand)
    response =  system (servercreatecommand)

    parser_obj=ResponseParser.new('_')
    parser_obj.parse_exitcode(servercreate_exitcodexml)
    hash= parser_obj.return_response
    if "#{hash['Success']}".to_str() == "TRUE"
      Puppet.info("Successfully created the server '#{server_name}'")
      else
      Puppet.info("Unable to create the server '#{server_name}'.")
      raise Puppet::Error, "#{hash['Error']}"
    end

  end

  def destroy
    server_name = @resource[:name]
    Puppet.debug("Inside Destroy method")
    Puppet.debug("Destroying server #{server_name}")

    libpath = CommonLib.get_path(1)
    serverdestroy_exitcodexml = "#{CommonLib.get_log_path(1)}/serverDestroyExitCode_#{CommonLib.get_unique_refid}.xml"
    server_folder = @resource[:serverfolder]
    if server_folder.length > 0
	server_index = self.hash_map['server_Index']
    else 
	server_index = self.hash_map['Index'][0]	
    end
    Puppet.debug("server_index : #{server_index}")
    serverdestroycommand = "java -jar -jar #{libpath} -host #{transport.host} -user #{transport.user} -password #{transport.password} -xmloutputfile #{serverdestroy_exitcodexml} -c \"server delete -index #{server_index}\""
    system(serverdestroycommand)

    parser_obj=ResponseParser.new('_')
    parser_obj.parse_exitcode(serverdestroy_exitcodexml)
    hash= parser_obj.return_response
    if "#{hash['Success']}".to_str() == "TRUE"
      Puppet.info("Successfully deleted the server '#{server_name}'.")
      else
      Puppet.info("Unable to delete the server '#{server_name}'.")
      raise Puppet::Error, "#{hash['Error']}"
    end

  end

  def exists?
    Puppet.debug("Puppet::Provider::Compellenet_server: checking existance of compellent server #{@resource[:name]}")
    Puppet.debug(" resource[:ensure]  ==  #{@resource[:ensure]}")
	libpath = CommonLib.get_path(1)
	servershowcli = showserver_commandline
	servershow_exitcodexml = "#{CommonLib.get_log_path(1)}/serverShowExitCode_#{CommonLib.get_unique_refid}.xml"
	servershow_responsexml = "#{CommonLib.get_log_path(1)}/serverShowResponse_#{CommonLib.get_unique_refid}.xml"
	servershow_command = "java -jar #{libpath} -host #{transport.host} -user #{transport.user} -password #{transport.password} -xmloutputfile #{servershow_exitcodexml} -c \"#{servershowcli} -xml #{servershow_responsexml}\""
    system(servershow_command)
    
    parser_obj=ResponseParser.new('_')
    folder_value = @resource[:serverfolder] 
    server_index = ""
    if folder_value.length  > 0
		parser_obj.parse_discovery(servershow_exitcodexml,servershow_responsexml,0)
	        self.hash_map = parser_obj.return_response
	        Puppet.debug("folder is not null, hash_map : #{self.hash_map}")
		server_index = self.hash_map['server_Index']
    else
		self.hash_map = parser_obj.retrieve_empty_folder_server_properties(servershow_responsexml,@resource[:name])
		Puppet.debug("folder is null, hash_map : #{self.hash_map}")
		if self.hash_map['Index'] != nil
		        server_index = self.hash_map['Index'][0]
		end
    end    

		
    Puppet.debug("Value = #{@property_hash[:ensure]}")
    if  "#{server_index}" == ""
		Puppet.info("Server does not exist")
		false
    else
      #Server exist, can delete!
      #@property_hash[:ensure] = :absent
      Puppet.info("Puppet::Server exist")
      true
    end
	
  end

end



