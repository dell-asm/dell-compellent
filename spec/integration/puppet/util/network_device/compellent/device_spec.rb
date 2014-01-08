#! /usr/bin/env ruby

require 'spec_helper'
require 'puppet/util/network_device/compellent/device'
require 'puppet/util/network_device/compellent/facts'
require 'puppet/util/network_device/transport_compellent'
require 'yaml'
require 'uri'

describe Puppet::Util::NetworkDevice::Compellent::Device do

  device_conf =  YAML.load_file(my_fixture('device_conf.yml'))
  describe "when connecting to a new device" do

    it "should reject a single hostname" do
      deviceobj = mock 'compellent server'
      response = described_class.new('pfiler.example.com')
	  expect{expect(response).to eq(response.match("Error"))}.not_to raise_error
    end

    it "should reject a missing username" do
      deviceobj = mock 'compellent server'
      deviceobj = described_class.new('https://pfiler.example.com')
	  expect{expect(response).to eq(response.match("Error"))}.not_to raise_error
    end

    it "should reject a missing password" do
      deviceobj = mock 'compellent server'
      deviceobj = described_class.new('https://root@pfiler.example.com')
	  expect{expect(response).to eq(response.match("Error"))}.not_to raise_error
    end

    it "should not accept plain http connections" do
      deviceobj = mock 'compellent server'
      deviceobj = described_class.new('http://root@pfiler.example.com')
	  expect{expect(response).to eq(response.match("Error"))}.not_to raise_error
    end
	
    it "should not connect to the device compellent - device not accessible" do
      response = mock 'compellent server'
      Puppet::Util::Log.level = :debug
      Puppet::Util::Log.newdestination(:console)
      puts "Compellent device discovery started"
      puts "************************************************************************************************"
      puts "************************************************************************************************"
      response =  described_class.new(device_conf['url'])
      #puts response
      expect{expect(response).to eq(response.match("Error"))}.not_to raise_error
      puts "************************************************************************************************"
      puts "************************************************************************************************"
      puts "Compellent device discovery process ended."

    end
	
	context "#parse" do
    
      it "should parse url" do
        parseobj = mock 'compellent parse object'
        Puppet::Util::Log.level = :debug
        Puppet::Util::Log.newdestination(:console)
        puts "parse url started"
        puts "************************************************************************************************"
        puts "************************************************************************************************"
       deviceobj =  described_class.new(device_conf['url'])
        transobj = deviceobj.transport
        puts transobj.host
        puts transobj.user
        puts transobj.password
        puts "************************************************************************************************"
        puts "************************************************************************************************"
        puts "parse url ended"

     end
    end

    context "#facts" do
    
      it "should connect to the device compellent and retrive facts" do
        factsobj = mock 'compellent facts object'
        Puppet::Util::Log.level = :debug
        Puppet::Util::Log.newdestination(:console)
        puts "start facts"
        puts "************************************************************************************************"
        puts "************************************************************************************************"
        deviceobj =  described_class.new(device_conf['url'])
        transportobj = deviceobj.transport
        puts transportobj.host
        puts transportobj.user
        puts transportobj.password

        factsobj = Puppet::Util::NetworkDevice::Compellent::Facts.new(transportobj)
        #retriveobj = factsobj.facts
        puts factsobj.retrieve
        puts "************************************************************************************************"
        puts "************************************************************************************************"
        puts "facts ended"

     end
    end

  end
end
