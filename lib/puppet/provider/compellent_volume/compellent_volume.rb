require 'puppet/provider/compellent'
require 'puppet/lib/ResponseParser'
require 'puppet/lib/CommonLib'

Puppet::Type.type(:compellent_volume).provide(:compellent_volume, :parent => Puppet::Provider::Compellent) do
  @doc = "Manage Compellent Volume creation, modification and deletion."
  def createvolume_commandline
    command = "volume create -name '#{@resource[:name]}' -size '#{@resource[:size]}'"
    if #@{resource[:boot]} = "enable"
    command = command + " -boot"
    end

    folder_value = @resource[:volumefolder]
    if "#{folder_value}".size != 0
      command = command + " -folder '#{folder_value}'"
    end

    notes_value = @resource[:notes]
    if "#{notes_value}".size != 0
      command = command + " -notes '#{notes_value}'"
    end

    replayprofile_value = @resource[:replayprofile]
    if "#{replayprofile_value}".size != 0
      command = command + " -replayprofile '#{replayprofile_value}'"
    end

    storageprofile_value = @resource[:storageprofile]
    if "#{storageprofile_value}".size != 0
      command = command + " -storageprofile '#{storageprofile_value}'"
    end
    return command
  end

  def showvolume_commandline
    command = "volume show -name '#{@resource[:name]}'"
    folder_value = @resource[:volumefolder]
    if "#{folder_value}".size != 0
      command = command + " -folder '#{folder_value}'"
    end
    return command
  end


  def get_deviceid
    Puppet.debug("Fetching information about the Volume")
    libpath = CommonLib.get_path(1)
    resourcename = @resource[:name]
    vol_show_cli = showvolume_commandline
    volshow_respxml = "#{CommonLib.get_log_path(1)}/volshowResp_#{CommonLib.get_unique_refid}.xml"
    volshow_exitcodexml = "#{CommonLib.get_log_path(1)}/volshowExitCode_#{CommonLib.get_unique_refid}.xml"
    volume_show_command = "java -jar #{libpath} -host #{transport.host} -user #{transport.user} -password #{transport.password} -xmloutputfile #{volshow_exitcodexml} -c \"#{vol_show_cli} -xml #{volshow_respxml}\""
    Puppet.debug(volume_show_command)
    system(volume_show_command)
    Puppet.debug("in method get_deviceid, after exectuing show volume command")
    parser_obj=ResponseParser.new('_')
    folder_value = @resource[:volumefolder]
    if ((folder_value != nil) && (folder_value.length > 0))
		parser_obj.parse_discovery(volshow_exitcodexml,volshow_respxml,0)
		hash= parser_obj.return_response 
    else
		hash = parser_obj.retrieve_empty_folder_volume_properties(volshow_respxml,@resource[:name])
    end
    device_id = "#{hash['volume_DeviceID']}"
    return device_id
  end



  def create

    Puppet.debug("Inside Create Method.")
    libpath = CommonLib.get_path(1)
    folder_value = @resource[:volumefolder]
    resourcename = @resource[:name]
    volume_cli = createvolume_commandline

    volfolder_exitcodexml = "#{CommonLib.get_log_path(1)}/volFolderCreateExitCode_#{CommonLib.get_unique_refid}.xml"

    if "#{folder_value}".size != 0
		Puppet.debug("Creating volume folder with name '#{folder_value}'")
		volume_folder_command = "java -jar #{libpath} -host #{transport.host} -user #{transport.user} -password #{transport.password} -xmloutputfile #{volfolder_exitcodexml} -c \"volumefolder create -name '#{folder_value}'\""
		Puppet.debug(volume_folder_command)
		system (volume_folder_command)
		parser_obj=ResponseParser.new('_')
		parser_obj.parse_exitcode(volfolder_exitcodexml)
		hash= parser_obj.return_response
		if "#{hash['Success']}".to_str() == "TRUE"
			Puppet.info("Successfully created the volume folder '#{folder_value}'.")
        else
			existresult = "#{hash['Error']}".to_str()
			if existresult.include? "already exists"
				Puppet.info("Volume folder '#{folder_value}' already exists.")
			else
				raise Puppet::Error, "#{hash['Error']}"
			end
		end
    end

    volcreate_exitcodexml = "#{CommonLib.get_log_path(1)}/volCreateExitCode_#{CommonLib.get_unique_refid}.xml"

    volume_create_command = "java -jar #{libpath} -host #{transport.host} -user #{transport.user} -password #{transport.password} -xmloutputfile #{volcreate_exitcodexml} -c \"#{volume_cli}\""
    Puppet.debug(volume_create_command)
    response =  system (volume_create_command)

    parser_obj=ResponseParser.new('_')
    parser_obj.parse_exitcode(volcreate_exitcodexml)
    hash= parser_obj.return_response
    if "#{hash['Success']}".to_str() == "TRUE"
		Puppet.info("Successfully created the volume '#{resourcename}'.")
    else
		raise Puppet::Error, "#{hash['Error']}"
    end
  end

  def destroy
    Puppet.debug("Inside Destroy method")
    libpath = CommonLib.get_path(1)
    resourcename = @resource[:name]
    device_id = get_deviceid
    voldestroy_exitcodexml = "#{CommonLib.get_log_path(1)}/volDestroyExitCode_#{CommonLib.get_unique_refid}.xml"
    if  "#{device_id}".size != 0
		Puppet.debug("Invoking destroy command")
		if (@resource[:purge] == "yes")
			volume_destroy_command = "java -jar #{libpath} -host #{transport.host} -user #{transport.user} -password #{transport.password} -xmloutputfile #{voldestroy_exitcodexml} -c \"volume delete -deviceid #{device_id} -purge\""
		else
			volume_destroy_command = "java -jar #{libpath} -host #{transport.host} -user #{transport.user} -password #{transport.password} -xmloutputfile #{voldestroy_exitcodexml} -c \"volume delete -deviceid #{device_id}\""
		end
		Puppet.debug(volume_destroy_command)
		system(volume_destroy_command)
    end
  end

  def exists?
    device_id = get_deviceid
	resourcename = @resource[:name]
    Puppet.debug("Device Id for Volume - #{device_id}")

    if  "#{device_id}" == ""
		Puppet.debug("Puppet::Volume '#{resourcename}' does not exist")
		false
	else
		Puppet.debug("Puppet::Volume '#{resourcename}' exist")
		true
    end
  end
end

