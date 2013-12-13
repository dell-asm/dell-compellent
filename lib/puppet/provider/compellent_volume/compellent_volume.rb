require 'puppet/provider/compellent'

Puppet::Type.type(:compellent_volume).provide(:compellent_volume, :parent => Puppet::Provider::Compellent) do
  @doc = "Manage Compellent Volume creation, modification and deletion."
  def create_volumecommandline
    command = "volume create -name '#{@resource[:name]}' -size '#{@resource[:size]}'"
    if #@{resource[:boot]} = "enable"
    command = command + " -boot"
    end
    if "#{@resource[:folder]}".size != 0
      command = command + " -folder '#{@resource[:folder]}'"
    end
    if "#{@resource[:notes]}".size != 0
      command = command + " -notes '#{@resource[:notes]}'"
    end
    if "#{@resource[:replayprofile]}".size != 0
      command = command + " -replayprofile '#{@resource[:replayprofile]}'"
    end
    if "#{@resource[:storageprofile]}".size != 0
      command = command + " -storageprofile '#{@resource[:storageprofile]}'"
    end
    return command
  end

  def create
    # TODO: Clone a VM from template.
    puts "Inside Create Method."
    volumeCLI = create_volumecommandline
    puts "Volume CLI"
    puts volumeCLI

    if "#{@resource[:folder]}".size != 0
      Puppet.debug("Creating volume folder with name '#{@resource[:folder]}'")
      volumeFolderCommand = "java -jar /etc/puppet/modules/compellent/lib/puppet/util/network_device/compellent/CompCU-6.3.jar -host #{@resource[:host]} -user #{@resource[:user]} -password #{@resource[:password]} -xmloutputfile /tmp/volfoldercreate_#{@resource[:name]}_exitcode.xml -c \"volumefolder create -name '#{@resource[:folder]}'\""
      Puppet.debug(volumeFolderCommand)
      system (volumeFolderCommand)
    end

    Puppet.debug("Creating volume with name '#{@resource[:name]}'")

    volumeCreateCommand = "java -jar /etc/puppet/modules/compellent/lib/puppet/util/network_device/compellent/CompCU-6.3.jar -host #{@resource[:host]} -user #{@resource[:user]} -password #{@resource[:password]} -xmloutputfile /tmp/volcreate_#{@resource[:name]}_exitcode.xml -c \"#{volumeCLI}\""
    Puppet.debug(volumeCreateCommand)

    response =  system (volumeCreateCommand)

  end

  def destroy
    Puppet.debug("Inside Destroy method")
    Puppet.debug("Destroying volume #{@resource[:name]}")
    volumeDestroyCommand = "java -jar /etc/puppet/modules/compellent/lib/puppet/util/network_device/compellent/CompCU-6.3.jar -host #{@resource[:host]} -user #{@resource[:user]} -password #{@resource[:password]} -xmloutputfile /tmp/voldeleteexitcode.xml -c \"volume delete -name #{@resource[:name]}\""
    system(volumeDestroyCommand)
  end

  def exists?
    Puppet.debug("Puppet::Provider::Compellenet_volume: checking existence of compellent volume #{@resource[:name]}")
    Puppet.debug(" resource[:ensure]  ==  #{@resource[:ensure]}")
    if("#{@resource[:ensure]}" == "absent")
      @property_hash[:ensure] = :present
    else
      @property_hash[:ensure] = :absent
    end
    Puppet.debug("Value = #{@property_hash[:ensure]}")
    @property_hash[:ensure] == :present
  end

end

