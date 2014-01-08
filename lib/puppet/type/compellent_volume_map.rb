Puppet::Type.newtype(:compellent_volume_map) do 
  @doc = "Manage Map/Unamp Volume."
  
  apply_to_device
  
  ensurable
  
  newparam(:name) do
    desc "The volume name needs to be map with server. Valid characters are a-z, 1-9 & underscore."
    isnamevar
    validate do |value|
      unless value =~ /^[\w\s\-]+$/
         raise ArgumentError, "%s is not a valid initial volume name." % value
      end
    end 
  end
    
  newparam(:boot, :boolean => true) do
    desc "The parameter spcifies the boot option." 
    desc "Defaults to `:false`."
    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:volumefolder) do
    desc "The volume folder name, optional parameter."
    validate do |value|
      unless value =~ /^[\w\s\-]*$/
         raise ArgumentError, "%s is not a valid initial volume folder name." % value
      end
    end
  end

  newparam(:serverfolder) do
    desc "The server folder name, optional parameter."
    validate do |value|
      unless value =~ /^[\w\s\-]*$/
         raise ArgumentError, "%s is not a valid initial server folder name." % value
      end
    end
  end
  
  newparam(:force, :boolean => true) do
    desc "The parameter forces mapping." 
    desc "Defaults to `:false`."
    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:readonly, :boolean => true) do
    desc "The parameter to map volume with server in readonly mode." 
    desc "Defaults to `:false`."
    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:singlepath, :boolean => true) do
    desc "The parameter to map the volume with server for only single port." 
    desc "Defaults to `:false`."
    newvalues(:true, :false)
    defaultto :false
  end 
  
  newparam(:servername) do
    desc "The parameter specifies the server to which to map the volume."
    validate do |value|
      unless value =~ /^[\w\s\-]+$/
         raise ArgumentError, "%s is not a valid initial server name." % value
      end
    end
  end

  newparam(:lun) do
    desc "The paramter for specifies the LUN for mapped volume."
  end

  newparam(:localport) do
    desc "The parameter specifies the WWN of single local port when -singlepath option is used."
  end
end

