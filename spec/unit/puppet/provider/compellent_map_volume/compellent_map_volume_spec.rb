#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'


describe Puppet::Type.type(:compellent_map_volume).provider(:compellent_map_volume) do

  device_conf =  YAML.load_file(my_fixture('device_conf.yml'))
  before :each do
    Facter.stubs(:value).with(:url).returns(device_conf['url'])
    described_class.stubs(:suitable?).returns true
    Puppet::Type.type(:compellent_map_volume).stubs(:defaultprovider).returns described_class
  end

  map_volume_yml =  YAML.load_file(my_fixture('map_volume.yml'))
  map_node1      =  map_volume_yml['MapVolume1']  

  let :map_volume do
    Puppet::Type.type(:compellent_map_volume).new(
		:name          	=> map_node1['name'],
		:ensure        	=> map_node1['ensure'],
		:boot		=> map_node1['boot'],
		:servername 	=> map_node1['servername'],
		:serverfolder	=> map_node1['serverfolder'],
		:lun		=> map_node1['lun'],
		:volumefolder	=> map_node1['volumefolder'],
		:localport	=> map_node1['localport'],
		:force		=> map_node1['force'],
		:readonly	=> map_node1['readonly'],
		:singlepath	=> map_node1['singlepath']
    )
  end

  
  unmap_volume_yml =  YAML.load_file(my_fixture('unmap_volume.yml'))
  unmap_node1 = unmap_volume_yml['UnmapVolume1']
  
  let :unmap_volume do
    Puppet::Type.type(:compellent_map_volume).new(
		:name          		=> unmap_node1['name'],
		:ensure        		=> unmap_node1['ensure'],
    )
  end

 
  let :provider do
    described_class.new( )
  end
  
  describe "when asking exists?" do
    it "should return false if volume is not mapped" do
      map_volume.provider.should_not be_exists
    end
  end

  describe "when mapping a volume" do
    it "should be able to map a volume" do
      map_volume.provider.create
    end
  end

  describe "when un-mapping a volume" do
    it "should be able to un-map a volume" do
      map_volume.provider.destroy
    end
  end

end
