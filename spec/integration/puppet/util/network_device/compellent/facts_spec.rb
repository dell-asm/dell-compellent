#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'
require 'puppet/util/network_device'
require 'puppet/util/network_device/compellent/device'
require 'puppet/util/network_device/transport_compellent'

describe Puppet::Util::NetworkDevice::Compellent::Facts do

  device_conf =  YAML.load_file(my_fixture('device_conf.yml'))
  let :transport do
    Puppet::Util::NetworkDevice::Transport_compellent.new()
  end

  let :facts do
    described_class.new(transport)
  end

  let :deviceobj do
    mock 'Compellent server'
  end

  before :each do
    Puppet::Util::Log.level = :debug
    Puppet::Util::Log.newdestination(:console)
    deviceobj = Puppet::Util::NetworkDevice::Compellent::Device.new(device_conf['url'])
    transobj = deviceobj.transport
    transport.host = transobj.host
    transport.user = transobj.user
    transport.password = transobj.password
  end

  describe "#retrieve" do
    it "should retrive facts and respective values from compellent" do
      puts "Facts retrive operation started."
      #facts.retrieve
      puts facts.retrieve
      puts "Facts retrive operation completed."
    end

    {
      #Add facts and values to validate with existing values
    }.each do |fact, expected_value|
      it "should return #{expected_value} for #{fact}" do
        facts.retrieve[fact].should == expected_value
      end
    end

  end
end
