Puppet::Type.newtype(:compellent_map_volume) do 
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
    desc "The aggregate this volume should be created in." 
    desc "Should volume size auto-increment be enabled? Defaults to `:true`."
    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:volumefolder) do
    desc "The vlolume folder name, optional parameter."
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
    desc "The aggregate this volume should be created in." 
    desc "Should volume size auto-increment be enabled? Defaults to `:true`."
    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:readonly, :boolean => true) do
    desc "The aggregate this volume should be created in." 
    desc "Should volume size auto-increment be enabled? Defaults to `:true`."
    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:singlepath, :boolean => true) do
    desc "The aggregate this volume should be created in." 
    desc "Should volume size auto-increment be enabled? Defaults to `:true`."
    newvalues(:true, :false)
    defaultto :false
  end 
  
  newparam(:servername) do
    desc "The server name needs to be map with volume"
    validate do |value|
      unless value =~ /^[\w\s\-]+$/
         raise ArgumentError, "%s is not a valid initial server name." % value
      end
    end
  end

  newparam(:lun) do
    desc "The Lun name."
  end

  newparam(:localport) do
    desc "The localport."
  end
end

