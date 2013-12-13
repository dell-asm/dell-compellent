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
  
  newproperty(:options, :array_matching => :all) do 
    desc "The volume options hash."
    validate do |value|
      raise ArgumentError, "Puppet::Type::Compellent_volume: options property must be a hash." unless value.is_a? Hash
    end
    
    def insync?(is)
      # @should is an Array. see lib/puppet/type.rb insync?
      should = @should.first

      # Comparison of hashes
      return false unless is.class == Hash and should.class == Hash
      should.each do |k,v|
        return false unless is[k] == should[k]
      end
      true
    end
    
    def should_to_s(newvalue)
      # Newvalue is an array, but we're only interested in first record. 
      newvalue = newvalue.first
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end
  
  newproperty(:snapschedule, :array_matching=> :all) do 
    desc "The volume snapshot schedule, in a hash format. Valid keys are: 'minutes', 'hours', 'days', 'weeks', 'which-hours', 'which-minutes'. "
    validate do |value|
      raise ArgumentError, "Puppet::Type::Compellent_volume: snapschedule property must be a hash." unless value.is_a? Hash
    end
    
    def insync?(is)
      # @should is an Array. see lib/puppet/type.rb insync?
      should = @should.first

      # Comparison of hashes
      return false unless is.class == Hash and should.class == Hash
      should.each do |k,v|
        # Skip record if is is " " and should is "0"
        next if is[k] == " " and should[k] == "0"
        return false unless is[k] == should[k].to_s
      end
      true
    end
    
    def should_to_s(newvalue)
      # Newvalue is an array, but we're only interested in first record. 
      newvalue = newvalue.first
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end
  
end
