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

  def create   
    Puppet.debug("Inside Add Server HBA Method.")
    add_hba_cli = add_serverhbacommandline
    resourcename = @resource[:name]
    libpath = get_path(2)	
    add_server_hba_command = "java -jar #{libpath} -host #{@resource[:host]} -user #{@resource[:user]} -password #{@resource[:password]} -xmloutputfile /tmp/addserverhba_#{resourcename}_exitcode.xml -c \"#{add_hba_cli}\""
    Puppet.debug(add_server_hba_command)
    response =  system (add_server_hba_command)

    parser_obj=ResponseParser.new('_')
    file_path = "/tmp/addserverhba_#{resourcename}_exitcode.xml"
    parser_obj.parse_exitcode(file_path)
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
    remove_server_hba_command = "java -jar #{libpath} -host #{@resource[:host]} -user #{@resource[:user]} -password #{@resource[:password]} -xmloutputfile /tmp/removeserverhba_#{resourcename}_exitcode.xml -c \"#{delete_hba_cli}\""
    Puppet.debug(remove_server_hba_command)    
    system(remove_server_hba_command)

    parser_obj=ResponseParser.new('_')
    file_path = "/tmp/removeserverhba_#{resourcename}_exitcode.xml"
    parser_obj.parse_exitcode(file_path)
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
    show_server_hba_command = "java -jar #{libpath} -host #{@resource[:host]} -user #{@resource[:user]} -password #{@resource[:password]} -xmloutputfile /tmp/showhserverhba_#{@resource[:name]}_exitcode.xml -c \"#{show_hba_cli} -xml /tmp/showhserverhba_#{@resource[:name]}_response.xml\""
    system(show_server_hba_command)    
    server_file_name_path = "/tmp/showhserverhba_#{@resource[:name]}_response.xml"
    parser_obj=ResponseParser.new('_')
    hash = parser_obj.retrieve_server_properties(server_file_name_path)
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

