Puppet::Type.newtype(:compellent_server) do 
  @doc = "Manage Compellent Server creation and deletion."
  
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
  
  newparam(:operatingsystem) do
    desc "The Server operatingSystem. Valid format is 1-9(kmgt)."
  end
  
  newparam(:notes) do
    desc "The description for the server."
  end
  
  newparam(:serverfolder) do
    desc "The server folder."
  end
  
 newparam(:wwn) do
    desc "The WWN to map Server."
    validate do |value|
      unless value =~ /^\w+$/
        raise ArgumentError, "%s is not a valid WWN number." % value
      end
    end
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

