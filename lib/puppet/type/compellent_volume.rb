Puppet::Type.newtype(:compellent_volume) do
  @doc = "Manage Compellent Volume creation, modification and deletion."

  apply_to_device

  ensurable

  newparam(:name) do
    desc "The volume name. Valid characters are a-z, 1-9 & underscore."
    isnamevar
    validate do |value|
      unless value =~ /^[\w\s\-]+$/
        raise ArgumentError, "%s is not a valid initial volume name." % value
      end
    end
  end

  newparam(:size) do
    desc "The initial volume size. Valid format is 1-9(kmgt)."
    validate do |value|
      unless value =~ /^\d+([kmgt]$|(KB|MB|GB|TB)$)/
       	raise ArgumentError, "%s is not a valid initial volume size." % value
      end
    end
    
    munge do |value|
      if value =~ /^\d+(KB)$/
        value.sub!(/(KB)/,'k')
      elsif value =~ /^\d+(MB)$/
        value.sub!(/(MB)/,'m')
      elsif value =~ /^\d+(GB)$/
        value.sub!(/(GB)/,'g')
      elsif value =~ /^\d+(TB)$/
        value.sub!(/(TB)/,'t')
      end
    end
  
  end

  newparam(:boot, :boolean => true) do
    desc "The parameter specifies the boot option for volume."
    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:volumefolder) do
    desc "The volume folder name. Valid characters are a-z, 1-9 & underscore."
    validate do |value|
      unless value =~ /^[\w\s\-]*$/
        raise ArgumentError, "%s is not a valid initial volume folder name." % value
      end
    end
  end
  newparam(:purge) do
    desc "Force option for create volume."
  end

  newparam(:notes) do
    desc "The language code this volume should use."
  end

  newparam(:replayprofile) do
    desc "The space reservation mode."
  end

  newparam(:storageprofile) do
    desc "The space reservation mode."
  end

end
