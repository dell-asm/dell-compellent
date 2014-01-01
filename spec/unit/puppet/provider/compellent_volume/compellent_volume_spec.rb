#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'
require 'puppet/provider/compellent'
require 'puppet/util/network_device/compellent/device'

describe Puppet::Type.type(:compellent_volume).provider(:compellent_volume) do

  device_conf =  YAML.load_file(my_fixture('device_conf.yml'))
  before :each do
    Facter.stubs(:value).with(:url).returns(device_conf['url'])
    described_class.stubs(:suitable?).returns true
    Puppet::Type.type(:compellent_volume).stubs(:defaultprovider).returns described_class
  end

  #Load Create Volume file
  create_volume_yml =  YAML.load_file(my_fixture('create_volume.yml'))
  
  create_node = create_volume_yml['CreateVolume1']
  let :create_volume do
    Puppet::Type.type(:compellent_volume).new(
		:name          		=> create_node['name'],
		:ensure        		=> create_node['ensure'],
		:purge			=> create_node['purge'],
		:size 		        => create_node['size'],
		:boot			=> create_node['boot'],
		:volumefolder		=> create_node['volumefolder'],
		:notes 		        => create_node['notes'],
		:replayprofile		=> create_node['replayprofile'],
		:storageprofile		=> create_node['storageprofile']
    )
  end 

  #Load Delete Volume file
  delete_volume_yml =  YAML.load_file(my_fixture('delete_volume.yml'))
  
  delete_node = delete_volume_yml['DeleteVolume1']  
  let :delete_volume do
    Puppet::Type.type(:compellent_volume).new(
		:name          		=> delete_node['name'],
		:ensure        		=> delete_node['ensure'],
		:purge			=> delete_node['purge'],
		:volumefolder		=> delete_node['volumefolder'],
		:notes 		        => delete_node['notes'],
		:replayprofile		=> delete_node['replayprofile'],
		:storageprofile		=> delete_node['storageprofile']
    )
  end 
  
  #Load the provider
  let :provider do
    described_class.new( )
  end
	
  describe "create a new volume" do
    it ":should be able to create a volume" do
	      create_volume.provider.should_not be_exists
          create_volume.provider.create
    end
  end

  describe "delete volume" do
    it ":should be able to delete volume" do
	  delete_volume.provider.should be_exists	  
          delete_volume.provider.destroy
    end
  end

end
