Puppet::Type.newtype(:compellent_map_volume) do 
  @doc = "Manage Map/Unamp Volume."
  
  apply_to_device
  
  ensurable
  
  newparam(:name) do
    desc "The volume name needs to be map with server. Valid characters are a-z, 1-9 & underscore."
    isnamevar
  end
  
  
  newparam(:boot, :boolean => true) do
    desc "The aggregate this volume should be created in." 
    desc "Should volume size auto-increment be enabled? Defaults to `:true`."
    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:volumefolder) do
    desc "The vlolume folder name, optional parameter."
  end

  newparam(:serverfolder) do
    desc "The server folder name, optional parameter."
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
  end

  newparam(:lun) do
    desc "The Lun name."
  end

  newparam(:localport) do
    desc "The localport."
  end

  newparam(:user) do
    desc "User for compellent."
  end
  
  newparam(:password) do
    desc "Password for compellent."
  end

  newparam(:host) do
    desc "IP-address for compellent."
  end
  
end

