#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'
require 'puppet/provider/compellent'
require 'puppet/util/network_device/compellent/device'

describe Puppet::Type.type(:compellent_hba).provider(:compellent_hba) do

  device_conf_yml =  YAML.load_file(my_fixture('device_conf.yml'))
  url_node = device_conf_yml['DeviceURL']
  before :each do
    Facter.stubs(:value).with(:url).returns(url_node['url'])
    described_class.stubs(:suitable?).returns true
    Puppet::Type.type(:compellent_hba).stubs(:defaultprovider).returns described_class
  end

  #Load Add HBA file
  add_hba_yml =  YAML.load_file(my_fixture('add_hba.yml'))
  
  create_node = add_hba_yml['AddHBA1']
  let :add_hba do
    Puppet::Type.type(:compellent_hba).new(
		:name          		=> create_node['name'],
		:ensure        		=> create_node['ensure'],
		:wwn				=> create_node['wwn'],
		:serverfolder 		=> create_node['serverfolder'],
		:porttype			=> create_node['porttype'],
		:manual				=> create_node['manual']
    )
  end 

  #Load Remove HBA file
  remove_hba_yml =  YAML.load_file(my_fixture('remove_hba.yml'))
  
  remove_node = remove_hba_yml['RemoveHBA1']  
  let :remove_hba do
    Puppet::Type.type(:compellent_hba).new(
		:name          		=> remove_node['name'],
		:wwn				=> remove_node['wwn'],
		:ensure        		=> remove_node['ensure']
    )
  end 
  
  #Load the provider
  let :provider do
    described_class.new( )
  end

  describe "when exists?" do
  it ":should return true if hba is present" do
      #add_hba.provider.set(:ensure => :present)
     add_hba.provider.should be_exists
    end	
	end
	
  describe "when not exists?" do
  it ":should return true if hba is not present" do
     # remove_hba.provider.set(:ensure => :absent)
      remove_hba.provider.should_not be_exists
    end
	end

  describe "create a new hba" do
    it ":should be able to create a hba" do
	  add_hba.provider.should_not be_exists
      add_hba.provider.create
    end
  end

  describe "remove the hba" do
    it ":should be able to remove the hba" do
	  remove_hba.provider.should be_exists	  
      remove_hba.provider.destroy
    end
  end

end


