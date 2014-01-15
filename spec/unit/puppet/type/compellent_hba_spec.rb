#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'

describe Puppet::Type.type(:compellent_hba) do

	let :resource do
	described_class.new(
    :name         => 'DemoAlias',
    :ensure       => 'present',
	:porttype     => '1234',
	:manual       => 'true',
    :wwn          => 'WWN',
	:serverfolder => '',
    )
	end

	it "should have name as its keyattribute" do
		described_class.key_attributes.should == [:name]
	end

	describe "when validating attributes" do
		[:porttype,:name].each do |param|
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
			it "should allow a valid name with ensure present" do
			described_class.new(:name => 'newHbaOne', :ensure => 'present')[:name].should == 'newHbaOne'
			end
			it "should allow a valid name with ensure absent" do
				described_class.new(:name => 'newHbaTwo', :ensure => 'absent')[:name].should == 'newHbaTwo'
			end
		end
	end	
end