# encoding: utf-8
Puppet::Type.newtype(:compellent_cluster_server) do
  @doc = "Manage Compellent Cluster Server Object creation and deletion."

  ensurable

  # Name of the cluster server that needs to be managed
  #
  # @param name [String]
  newparam(:name) do
    desc "The cluster server name. Valid characters are a-z, 1-9 & underscore."
    isnamevar
    validate do |value|
      unless value =~ /^[\p{Word}\s\-]+$/u
        raise ArgumentError, "%s is not a valid initial server name." % value
      end
    end
  end

  # Operating System name that needs to be associated with cluster server object
  #
  # @param operatingsystem [String] Example "VMware ESXi 5.1"
  newparam(:operatingsystem) do
    desc "The Server operatingSystem."
  end

  # Folder name where server cluster object can be arranged. This is an optional parameter
  #
  # @param folder [String]
  newparam(:folder) do
    desc "The culuster server folder name."
    validate do |value|
      unless value =~ /^[\p{Word}\s\-]*$/u
        raise ArgumentError, "%s is not a valid initial server folder name." % value
      end
    end
    defaultto("")
  end
end

