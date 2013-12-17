Puppet::Type.newtype(:compellent_hba_add_delete) do 
  @doc = "Manage Server HBA creation, modification and deletion."
  
  apply_to_device
  
  ensurable
  
  newparam(:name) do
    desc "The server name. Valid characters are a-z, 1-9 & underscore."
    isnamevar
    validate do |value|
      unless value =~ /^\w+$/
        raise ArgumentError, "%s is not a valid server name." % value
      end
    end
  end
  
  newparam(:wwn) do
    desc "The WWN. Valid characters are a-z, 1-9 & underscore or can be a blank value."   
    validate do |value|
      unless value =~ /^\w+$/
        raise ArgumentError, "%s is not a valid server name." % value
      end
    end
  end
  
  newparam(:porttype) do
    desc "The porttype is iSCSI or FiberChannel. Valid characters are a-z."   
  end
  
  newparam(:manual, :boolean => true) do
    desc "This option uses when the HBA has not been discovered by Compellent"
    desc "For mannual true, have to specific the portType for HBA; Defaults to 'false'"     
    newvalues(:true, :false)
    defaultto :false
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
