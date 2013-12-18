Puppet::Type.newtype(:compellent_map_volume) do 
  @doc = "Manage Map/Unamp Volume."
  
  apply_to_device
  
  ensurable
  
  newparam(:name) do
    desc "The volume name needs to be map with server. Valid characters are a-z, 1-9 & underscore."
    isnamevar
    validate do |value|
      unless value =~ /^\w+$/
        raise ArgumentError, "%s is not a valid volume name." % value
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
    desc "The volume folder name."
  end

  newparam(:serverfolder) do
    desc "The server folder name."
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
      unless value =~ /^\w+$/
        raise ArgumentError, "%s is not a valid volume name." % value
      end
    end
  end

  newparam(:lun) do
    desc "The space reservation mode."
  end

  newparam(:localport) do
    desc "The space reservation mode."
  end

  newparam(:user) do
    desc "The space reservation mode."
  end
  
  newparam(:password) do
    desc "The space reservation mode."
  end

  newparam(:host) do
    desc "The space reservation mode."
  end
  
end

