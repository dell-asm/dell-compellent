#! /usr/bin/env ruby

require 'spec_helper'
require 'puppet/util/network_device/transport_compellent'
require 'yaml'

describe Puppet::Util::NetworkDevice::Transport_compellent do
  
  before :each do
    @transport_class = described_class.new
	@transport_class.host = "192.168.1.100"
	@transport_class.user = "eqladmin"
	@transport_class.password = "eqladmin"
  end
 
  describe "#host" do
    it "returns the correct host" do
        @transport_class.host.should eql "192.168.1.100"
    end
  end
  
  describe "#user" do
	it "returns the correct user" do
		@transport_class.user.should eql "eqladmin"
	end
  end
  
  describe "#password" do
	it "returns the correct password" do
		@transport_class.password.should eql "eqladmin"
	end
  end
    
  it "attribute host value, should match with assigned value" do
	  expect{expect(@transport_class.host).to eq("192.168.1.100")}.not_to raise_error
  end
  
  it "attribute user value, should match with assigned value" do
	  expect{expect(@transport_class.user).to eq("eqladmin")}.not_to raise_error
  end
  
  it "attribute password value, should match with assigned value" do
	  expect{expect(@transport_class.password).to eq("eqladmin")}.not_to raise_error
  end
  
end
