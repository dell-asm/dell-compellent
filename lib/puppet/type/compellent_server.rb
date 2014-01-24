Puppet::Type.newtype(:compellent_server) do
  @doc = "Manage Compellent Server creation and deletion."

  apply_to_device

  ensurable

  newparam(:name) do
    desc "The server name. Valid characters are a-z, 1-9 & underscore."
    isnamevar
    validate do |value|
      unless value =~ /^[\w\s\-]+$/
        raise ArgumentError, "%s is not a valid initial server name." % value
      end
    end
  end

  newparam(:operatingsystem) do
    desc "The Server operatingSystem."
  end

  newparam(:notes) do
    desc "The description for the server."
  end

  newparam(:serverfolder) do
    desc "The server folder name."
    validate do |value|
      unless value =~ /^[\w\s\-]*$/
        raise ArgumentError, "%s is not a valid initial server folder name." % value
      end
    end
  end

  newparam(:wwn) do
    desc "The WWN to map Server."
  end

end

