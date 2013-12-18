Puppet::Type.newtype(:compellent_volume) do 
  @doc = "Manage Compellent Volume creation, modification and deletion."
  
  apply_to_device
  
  ensurable
  
  newparam(:name) do
    desc "The volume name. Valid characters are a-z, 1-9 & underscore."
    isnamevar
    validate do |value|
      unless value =~ /^\w+$/
        raise ArgumentError, "%s is not a valid volume name." % value
      end
    end
  end
  
  newparam(:size) do
    desc "The initial volume size. Valid format is 1-9(kmgt)."
    defaultto "1g"
    validate do |value|
      unless value =~ /^\d+[kmgt]$/
         raise ArgumentError, "%s is not a valid initial volume size." % value
      end
    end
  end
  
  newparam(:boot, :boolean => true) do
    desc "The aggregate this volume should be created in." 
    desc "Should volume size auto-increment be enabled? Defaults to `:true`."
    newvalues(:true, :false)
    defaultto :true
  end
  
  newparam(:folder) do
    desc "The folder this volume should be created in." 
   
    validate do |value|
      unless value =~ /^\w+$/
        raise ArgumentError, "%s is not a valid folder name." % value
      end
    end
  end
  
  newparam(:notes) do
    desc "The language code this volume should use."
    validate do |value|
      unless value =~ /^\w+$/
        raise ArgumentError, "%s is not a valid folder name." % value
      end
    end
  end
  
  newparam(:replayprofile) do
    desc "The space reservation mode."
     validate do |value|
      unless value =~ /^\w+$/
        raise ArgumentError, "%s is not a valid folder name." % value
      end
    end
  end
  
newparam(:storageprofile) do
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
