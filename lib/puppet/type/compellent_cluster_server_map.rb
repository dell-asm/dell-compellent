# encoding: utf-8
Puppet::Type.newtype(:compellent_cluster_server_map) do
  @doc = "Manage maining unmapping of server object to cluster"

  ensurable

  # Name of the resource hash.
  #
  # In case multiple volume mapping needs to be performed within same manifest file, then unique resource hash name must be provided
  # @param name [String]
  newparam(:name) do
    desc "Resource name used for creating the manifest."
    isnamevar
  end

  # Cluster Server name to which server object needs to be associated
  #
  # @param cluster_server_name [String]
  newparam(:cluster_server_name) do
    desc "The cluster server name. Valid characters are a-z, 1-9 & underscore."
    validate do |value|
      unless value =~ /^[\p{Word}\s\-]+$/u
        raise ArgumentError, "%s is not a valid initial volume name." % value
      end
    end
  end

  # Server object name that needs to be assocciated with cluster server object
  #
  # @param server_name [String]
  newparam(:server_name) do
    desc "The WWN. Valid characters are a-z, 1-9 & underscore or can be a blank value."
    validate do |value|
      unless value =~ /^[\p{Word}\s\-]+$/u
        raise ArgumentError, "%s is not a valid initial volume name." % value
      end
    end
  end

  # Folder name under which cluster server object and server object are already created
  #
  # @param folder [String]
  newparam(:folder) do
    desc "The server folder name, optional parameter"
    validate do |value|
      unless value =~ /^[\p{Word}\s\-]*$/u
        raise ArgumentError, "%s is not a valid initial server folder name." % value
      end
    end
  end
end
