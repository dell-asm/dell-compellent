require 'puppet/provider/compellent'
require 'puppet/lib/ResponseParser'

Puppet::Type.type(:compellent_hba_add_delete).provide(:compellent_hba_add_delete, :parent => Puppet::Provider::Compellent) do
  @doc = "Manage Compellent Server HBA creation, modification and deletion."
  
  def add_serverhbacommandline
    command = "server addhba -name '#{@resource[:name]}' -WWN '#{@resource[:wwn]}'"

   porttype_value = @resource[:porttype]

   hba_manual = @resource[:manual]
   if hba_manual == :true
	if "#{porttype_value}".size != 0
		command = command + " -manual -porttype '#{porttype_value}'"
	   	Puppet.debug(command)
	end
    end
    return command

  end
  
  def remove_serverhbacommandline  
    command = "server removehba -name '#{@resource[:name]}' -WWN '#{@resource[:wwn]}'"	
    return command

  end
  
  def show_serverhbacommandline  
    command = "server show -name '#{@resource[:name]}'"
    #if "#{@resource[:folder]}".size != 0
    #  command = command + " -folder '#{@resource[:folder]}'"
    #end
    return command
  end
  
  def get_logpath(num)
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

  def create   
    Puppet.debug("Inside Add Server HBA Method.")
    add_hba_cli = add_serverhbacommandline
    resourcename = @resource[:name]
    libpath = get_path(2)	
    add_server_hba_exitcodexml = "#{get_logpath(2)}/addserverhbaExitCode_#{get_unique_refid}.xml"
    add_server_hba_command = "java -jar #{libpath} -host #{@resource[:host]} -user #{@resource[:user]} -password #{@resource[:password]} -xmloutputfile #{add_server_hba_exitcodexml} -c \"#{add_hba_cli}\""
    Puppet.debug(add_server_hba_command)
    response =  system (add_server_hba_command)

    parser_obj=ResponseParser.new('_')
    parser_obj.parse_exitcode(add_server_hba_exitcodexml)
    hash= parser_obj.return_response
    if "#{hash['Success']}".to_str() == "TRUE"
      Puppet.debug("Server HBA added successfully..")
      else
      Puppet.debug("Failed to add HBA in Server..")
      raise Puppet::Error, "#{hash['Error']}"
    end
    
  end

  def destroy
    Puppet.debug("Inside Remove Server HBA Method.")
    delete_hba_cli = remove_serverhbacommandline
    resourcename = @resource[:name]	
    libpath = get_path(2)
    remove_server_hba_exitcodexml = "#{get_logpath(2)}/removeserverhbaExitCode_#{get_unique_refid}.xml"
    remove_server_hba_command = "java -jar #{libpath} -host #{@resource[:host]} -user #{@resource[:user]} -password #{@resource[:password]} -xmloutputfile #{remove_server_hba_exitcodexml} -c \"#{delete_hba_cli}\""
    Puppet.debug(remove_server_hba_command)    
    system(remove_server_hba_command)

    parser_obj=ResponseParser.new('_')
    parser_obj.parse_exitcode(remove_server_hba_exitcodexml)
    hash= parser_obj.return_response
    if "#{hash['Success']}".to_str() == "TRUE"
      Puppet.debug("Server HBA removed successfully..")
      else
      Puppet.debug("Failed to remove HBA from Server..")
      raise Puppet::Error, "#{hash['Error']}"
    end


	
  end

  def exists?
    Puppet.debug("Puppet::Provider::in checking for existence for resource  #{@resource[:name]}.")
    Puppet.debug("ensure = #{@resource[:ensure]}")
    libpath = get_path(2)
    show_hba_cli = show_serverhbacommandline
	server_hba_show_exitcode_xml = "#{get_logpath(2)}/serverHbaShowExitCode_#{get_unique_refid}.xml"
	server_hba_show_response_xml = "#{get_logpath(2)}/serverHbaShowResponse_#{get_unique_refid}.xml"
	
    show_server_hba_command = "java -jar #{libpath} -host #{@resource[:host]} -user #{@resource[:user]} -password #{@resource[:password]} -xmloutputfile #{server_hba_show_exitcode_xml} -c \"#{show_hba_cli} -xml #{server_hba_show_response_xml}\""
    system(show_server_hba_command)    
    parser_obj=ResponseParser.new('_')
    hash = parser_obj.retrieve_server_properties(server_hba_show_response_xml)
    wwn_list = "#{hash['WWN_List']}"
    Puppet.debug("WWN list - #{wwn_list}")

    if  wwn_list.include? @resource[:wwn]
      Puppet.debug("Puppet::WWN exist")
      true
   else
      Puppet.debug("Puppet::WWN does not exist")  
      false
    end
	end

end

