require 'puppet/provider/compellent'
require 'puppet/lib/ResponseParser'
require 'puppet/lib/CommonLib'

Puppet::Type.type(:compellent_hba_add_delete).provide(:compellent_hba_add_delete, :parent => Puppet::Provider::Compellent) do
  @doc = "Manage Compellent Server HBA creation, modification and deletion."

  attr_accessor :hash_map, :valid_wwn
  @hash_map
  @valid_wwn
  def add_serverhbacommandline
    #command = "server addhba -name '#{@resource[:name]}' -WWN '#{@resource[:wwn]}'"
    Puppet.debug("In method add hba in server, hash_map: #{self.hash_map}")
    folder_value = @resource[:serverfolder]
    Puppet.debug(folder_value)
    if folder_value.length > 0
      server_index = self.hash_map['Index']
      command = "server addhba -index '#{server_index}' -WWN '#{self.valid_wwn}'"
    else
      server_index = self.hash_map['Index'][0]
      command = "server addhba -index '#{server_index}' -WWN '#{self.valid_wwn}'"
    end

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
    Puppet.debug("In method remove hba, hash_map : #{self.hash_map}")
    folder_value = @resource[:serverfolder]
    if folder_value.length > 0
      server_index = self.hash_map['Index']
    else
      server_index = self.hash_map['Index'][0]
    end
    command = "server removehba -index '#{server_index}' -WWN '#{self.valid_wwn}'"
    return command

  end

  def show_serverhbacommandline
    command = "server show -name '#{@resource[:name]}'"
    if "#{@resource[:serverfolder]}".size != 0
      command = command + " -folder '#{@resource[:serverfolder]}'"
    end
    return command
  end

  def create
    Puppet.debug("Inside Add Server HBA Method.")
    add_hba_cli = add_serverhbacommandline
    resourcename = @resource[:name]
    libpath =CommonLib.get_path(1)
    add_server_hba_exitcodexml = "#{CommonLib.get_log_path(1)}/addserverhbaExitCode_#{CommonLib.get_unique_refid}.xml"
    transport.command_exec("#{libpath}","#{add_server_hba_exitcodexml}","\"#{add_hba_cli}\"")
    parser_obj=ResponseParser.new('_')
    parser_obj.parse_exitcode(add_server_hba_exitcodexml)
    hash= parser_obj.return_response
    File.delete(add_server_hba_exitcodexml)
    if "#{hash['Success']}".to_str() == "TRUE"
      Puppet.info("Successfully added HBA to the server '#{resourcename}'.")
    else
      Puppet.info("Unable to add the HBA in the server '#{resourcename}'.")
      raise Puppet::Error, "#{hash['Error']}"
    end
  end

  def destroy
    Puppet.debug("Inside Remove Server HBA Method.")
    delete_hba_cli = remove_serverhbacommandline
    resourcename = @resource[:name]
    libpath = CommonLib.get_path(1)
    remove_server_hba_exitcodexml = "#{CommonLib.get_log_path(1)}/removeserverhbaExitCode_#{CommonLib.get_unique_refid}.xml"
    transport.command_exec("#{libpath}","#{remove_server_hba_exitcodexml}","\"#{delete_hba_cli}\"")
    parser_obj=ResponseParser.new('_')
    parser_obj.parse_exitcode(remove_server_hba_exitcodexml)
    hash= parser_obj.return_response
    File.delete(remove_server_hba_exitcodexml)
    if "#{hash['Success']}".to_str() == "TRUE"
      Puppet.info("Successfully deleted the HBA from the server '#{resourcename}'.")
    else
      Puppet.info("Unable to remove the HBA from the server '#{resourcename}'.")
      raise Puppet::Error, "#{hash['Error']}"
    end
  end

  def find_wwn_list(wwn_list)
    Puppet.debug("in method find_wwn_list, wwn_list : #{wwn_list}")
    if ("#{wwn_list}".size != 0 )
      str = (@resource[:wwn]).split(",")
      Puppet.debug(str)
      self.valid_wwn = ""
      if("#{@resource[:ensure]}" == "absent")
        for item in str
          if (wwn_list.include? item)
            if self.valid_wwn.length  > 0
              self.valid_wwn = self.valid_wwn + ",#{item}"
            else
              self.valid_wwn = item
            end
          end
        end
      else
        for item in str
          if !(wwn_list.include? item)
            if self.valid_wwn.length  > 0
              self.valid_wwn =  self.valid_wwn + ",#{item}"
            else
              self.valid_wwn = item
            end
          end
        end
      end
    else
      if("#{@resource[:ensure]}" == "absent")
        self.valid_wwn = ""
      else
        self.valid_wwn = @resource[:wwn]
      end
    end
  end

  def exists?
    resourcename = @resource[:name]
    Puppet.debug("Puppet::Provider::in checking for existence for resource  #{resourcename}.")
    Puppet.debug("ensure = #{@resource[:ensure]}")
    libpath = CommonLib.get_path(1)
    show_hba_cli = show_serverhbacommandline
    server_hba_show_exitcode_xml = "#{CommonLib.get_log_path(1)}/serverHbaShowExitCode_#{CommonLib.get_unique_refid}.xml"
    server_hba_show_response_xml = "#{CommonLib.get_log_path(1)}/serverHbaShowResponse_#{CommonLib.get_unique_refid}.xml"
    transport.command_exec("#{libpath}","#{server_hba_show_exitcode_xml}","\"#{show_hba_cli} -xml #{server_hba_show_response_xml}\"")
    parser_obj=ResponseParser.new('_')
    folder_value = @resource[:serverfolder]
    if folder_value.length  > 0
        self.hash_map = parser_obj.retrieve_server_properties(server_hba_show_response_xml)
        Puppet.debug("self.hash_map ::::::::::::::::::::: #{self.hash_map}")
        wwn_list = self.hash_map['WWN_List']
      Puppet.debug("folder is not null : #{self.hash_map}")
    else
      self.hash_map = parser_obj.retrieve_empty_folder_server_properties(server_hba_show_response_xml,resourcename)
      Puppet.debug("folder is null : #{self.hash_map}")
      wwn_list = self.hash_map['WWN_List']
    end
    Puppet.debug("WWN list - #{wwn_list}")
    find_wwn_list(wwn_list)
    Puppet.debug(@resource[:wwn])
    Puppet.debug("valid_wwn after soring the valid wwn : #{self.valid_wwn}")
    File.delete(server_hba_show_exitcode_xml,server_hba_show_response_xml)
    if (self.valid_wwn.length > 0)
      if("#{@resource[:ensure]}" == "absent")
        true
      else
        false
      end
    else
      if("#{@resource[:ensure]}" == "absent")
        false
      else
        true
      end
    end
  end
end

