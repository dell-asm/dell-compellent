#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'
require 'puppet/provider/compellent'
require 'puppet/util/network_device/compellent/device'

describe Puppet::Type.type(:compellent_server).provider(:compellent_server) do

  device_conf_yml =  YAML.load_file(my_fixture('device_conf.yml'))
  url_node = device_conf_yml['DeviceURL']
  before :each do
    Facter.stubs(:value).with(:url).returns(url_node['url'])
    described_class.stubs(:suitable?).returns true
    Puppet::Type.type(:compellent_server).stubs(:defaultprovider).returns described_class
  end

  #Load create server file
  create_server_yml =  YAML.load_file(my_fixture('create_server.yml'))

  create_node = create_server_yml['CreateServer1']
  let :create_server do
    Puppet::Type.type(:compellent_server).new(
                :name                   => create_node['name'],
                :ensure                 => create_node['ensure'],
                :wwn                    => create_node['wwn'],
                :serverfolder           => create_node['serverfolder'],
                :notes                  => create_node['notes'],
                :operatingsystem        => create_node['operatingsystem'],
    )
  end

  #Load destroy server
  destroy_server_yml = YAML.load_file(my_fixture('destroy_server.yml'))

  remove_node = destroy_server_yml['DestroyServer1']
  let :destroy_server do
    Puppet::Type.type(:compellent_server).new(
                :name                   => remove_node['name'],
                :serverfolder           => remove_node['serverfolder'],
                :ensure                 => remove_node['ensure']
    )
  end
  
  #Load the provider
  let :provider do
    described_class.new( )
  end

  describe "create server" do
    it ":should be able to create server" do
      create_server.provider.should_not be_exists
      create_server.provider.create
    end
  end

  describe "destroy server" do
    it ":should be able to destroy a server" do
      destroy_server.provider.should be_exists
      destroy_server.provider.destroy
    end
  end
end
