#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'

describe Puppet::Type.type(:compellent_volume) do

	let :resource do
	described_class.new(
	:name     => 'Windows 2012',
    :purge          => 'yes',
    :size           => '2g',
    :ensure         => 'absent',
    :boot           => false,
    :volumefolder   => 'TestFolder',
    :notes          => 'Test Space Notes',
    :replayprofile  => 'Sample',
    :storageprofile => 'Low Priority',
    )
	end

	it "should have name as its keyattribute" do
		described_class.key_attributes.should == [:name]
	end

	describe "when validating attributes" do
		[:volumefolder,:name].each do |param|
			it "should hava a #{param} parameter" do
				described_class.attrtype(param).should == :param
			end
		end
		[:ensure].each do |property|
			it "should have a #{property} property" do
			described_class.attrtype(property).should == :property
			end
		end
	end

	describe "when validating values" do
		describe "for name" do
			it "should allow a valid storageprofile with ensure present" do
			described_class.new(:name => 'newvolOne',:storageprofile => 'Low Priority', :ensure => 'present')[:storageprofile].should == 'Low Priority'
			end
			it "should allow a valid storageprofile with ensure absent" do
				described_class.new(:name => 'newvolTwo',:storageprofile => 'Low Priority', :ensure => 'absent')[:storageprofile].should == 'Low Priority'
			end
		end
	end	
end