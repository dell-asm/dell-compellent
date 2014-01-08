Puppet::Type.newtype(:compellent_hba) do 
  @doc = "Manage Server HBA creation, modification and deletion."
  
  apply_to_device
  
  ensurable
  
  newparam(:name) do
    desc "The server name. Valid characters are a-z, 1-9 & underscore."
    isnamevar
	validate do |value|
      unless value =~ /^[\w\s\-]+$/
         raise ArgumentError, "%s is not a valid initial volume name." % value
      end
    end 
  end
  
  newparam(:wwn) do
    desc "The WWN. Valid characters are a-z, 1-9 & underscore or can be a blank value."   
    validate do |value|
      unless value =~ /^[\w,]*$/
        raise ArgumentError, "%s is not a valid wwn number." % value
      end
    end
  end
   newparam(:serverfolder) do
    desc "The server folder name, optional parameter"
    validate do |value|
      unless value =~ /^[\w\s\-]*$/
         raise ArgumentError, "%s is not a valid initial server folder name." % value
      end
    end
  end
  
  newparam(:porttype) do
    desc "The porttype. Valid values are iSCSI or FiberChannel."   
  end
  
  newparam(:manual, :boolean => true) do
    desc "This option uses when the HBA has not been discovered by Compellent"
    desc "For mannual true, have to specific the portType for HBA; Defaults to 'false'"     
    newvalues(:true, :false)
    defaultto :false
  end 
     
end
