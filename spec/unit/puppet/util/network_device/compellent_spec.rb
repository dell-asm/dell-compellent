#! /usr/bin/env ruby

require 'puppet'
require 'puppet/util/network_device'
require 'puppet/util/network_device/compellent'
require 'spec_helper'
require 'yaml'

describe "Module Test Of Puppet::Util::NetworkDevice::Compellent" do
  
  context "context1" do
  
    let(:dummy_class) do
      Class.new do
        include Puppet::Util::NetworkDevice::Compellent
        def self.name
          "DummyClass"
        end
      end
    end

    context "instances" do
      subject { dummy_class.new }
      it { subject.should be_an_instance_of(dummy_class) }
      it { should be_a(Puppet::Util::NetworkDevice::Compellent) }
    end

    context "classes" do
      subject { dummy_class }
      it { should be_an_instance_of(Class) }
      it { defined?(DummyClass).should be_nil }
      its (:name) { should eq("DummyClass") }
    end
	
  end

  context "context2" do
    it "should not be possible to access let methods from anohter context" do
      defined?(dummy_class).should be_nil
    end
  end

  it "should not be possible to access let methods from a child context" do
    defined?(dummy_class).should be_nil
  end
  
end