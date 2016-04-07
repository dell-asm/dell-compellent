require 'puppet/provider/compellent'
require 'puppet/files/ResponseParser'
require 'puppet/files/CommonLib'

Puppet::Type.type(:compellent_volume).provide(:compellent_volume, :parent => Puppet::Provider::Compellent) do
  @doc = 'Manage Compellent Volume creation, modification and deletion.'
  def createvolume_commandline
    command = "volume create -name '#{@resource[:name]}' -size '#{@resource[:size]}'"
    if @resource[:boot] == :true
      command = command + " -boot"
    end

    if @resource[:readcache] == :true
      command = command + " -readcache true"
    end

    if @resource[:writecache] == :true
      command = command + " -writecache true"
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
    command
  end

  def showvolume_commandline
    command = "volume show -name '#{@resource[:name]}'"
    folder_value = @resource[:volumefolder]
    if "#{folder_value}".size != 0
      command = command + " -folder '#{folder_value}'"
    end
    command
  end

  def get_deviceid
    Puppet.debug('Fetching information about the Volume')
    libpath = CommonLib.get_path(1)
    resourcename = @resource[:name]
    vol_show_cli = showvolume_commandline
    volshow_respxml = "#{CommonLib.get_log_path(1)}/volshowResp_#{CommonLib.get_unique_refid}.xml"
    volshow_exitcodexml = "#{CommonLib.get_log_path(1)}/volshowExitCode_#{CommonLib.get_unique_refid}.xml"
    connection.command_exec("#{libpath}","#{volshow_exitcodexml}","\"#{vol_show_cli} -xml #{volshow_respxml}\"")
    parser_obj=ResponseParser.new('_')
    folder_value = @resource[:volumefolder]
    if (folder_value != nil) && (folder_value.length > 0)
      parser_obj.parse_discovery(volshow_exitcodexml,volshow_respxml,0)
      hash= parser_obj.return_response
    else
      hash = parser_obj.retrieve_empty_folder_volume_properties(volshow_respxml,@resource[:name])
    end
    File.delete(volshow_respxml,volshow_exitcodexml)
    device_id = "#{hash['volume_DeviceID']}"
	Puppet.debug("Device Id for Volume #{resourcename} is #{device_id}")
    device_id
  end

  def create
    Puppet.debug("Inside Create Volume Method.")
    libpath = CommonLib.get_path(1)
    folder_value = @resource[:volumefolder]
    resourcename = @resource[:name]
    volume_cli = createvolume_commandline

    volfolder_exitcodexml = "#{CommonLib.get_log_path(1)}/volFolderCreateExitCode_#{CommonLib.get_unique_refid}.xml"

    if "#{folder_value}".size != 0
      Puppet.debug("Creating volume folder with name '#{folder_value}'")
      connection.command_exec("#{libpath}","#{volfolder_exitcodexml}","\"volumefolder create -name '#{folder_value}'\"")
      parser_obj=ResponseParser.new('_')
      parser_obj.parse_exitcode(volfolder_exitcodexml)
      hash= parser_obj.return_response
      File.delete(volfolder_exitcodexml)
      if "#{hash['Success']}".to_str() == 'TRUE'
        Puppet.info("Successfully created the volume folder '#{folder_value}'.")
      else
        existresult = "#{hash['Error']}".to_str()
        if existresult.include? 'already exists'
          Puppet.info("Volume folder '#{folder_value}' already exists.")
        else
          raise Puppet::Error, "#{hash['Error']}"
        end
      end
    end
    volcreate_exitcodexml = "#{CommonLib.get_log_path(1)}/volCreateExitCode_#{CommonLib.get_unique_refid}.xml"
    connection.command_exec("#{libpath}","#{volcreate_exitcodexml}","\"#{volume_cli}\"")

    parser_obj=ResponseParser.new('_')
    parser_obj.parse_exitcode(volcreate_exitcodexml)
    hash= parser_obj.return_response
    File.delete(volcreate_exitcodexml)
    if "#{hash['Success']}" == 'TRUE'
      Puppet.info("Successfully created the volume '#{resourcename}'.")
    else
      raise Puppet::Error, "#{hash['Error']}"
    end
  end

  def destroy
    Puppet.debug('Inside Destroy Volume method')
    libpath = CommonLib.get_path(1)
    resourcename = @resource[:name]
    device_id = get_deviceid
    if  "#{device_id}".size != 0
      Puppet.debug('Invoking destroy command')
      voldestroy_exitcodexml = "#{CommonLib.get_log_path(1)}/volDestroyExitCode_#{CommonLib.get_unique_refid}.xml"
      if @resource[:purge] == "yes"
        connection.command_exec("#{libpath}","#{voldestroy_exitcodexml}","\"volume delete -deviceid #{device_id} -purge\"")
      else
        connection.command_exec("#{libpath}","#{voldestroy_exitcodexml}","\"volume delete -deviceid #{device_id}\"")
      end
      parser_obj=ResponseParser.new('_')
      parser_obj.parse_exitcode(voldestroy_exitcodexml)
      hash= parser_obj.return_response
      File.delete(voldestroy_exitcodexml)
      if "#{hash['Success']}" == 'TRUE'
        Puppet.info("Successfully deleted the volume '#{resourcename}'.")
      else
        raise Puppet::Error, "#{hash['Error']}"
      end
    end
  end

  def exists?
    device_id = get_deviceid
    resourcename = @resource[:name]
    
    if  "#{device_id}" == ''
      Puppet.debug("Puppet::Volume '#{resourcename}' does not exist")
      false
    else
      Puppet.debug("Puppet::Volume '#{resourcename}' exist")
      true
    end
  end
end

