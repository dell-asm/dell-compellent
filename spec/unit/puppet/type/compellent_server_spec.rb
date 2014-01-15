#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'

describe Puppet::Type.type(:compellent_server) do

	let :resource do
	described_class.new(
	:name     => 'Windows 2012',
    :operatingsystem => 'Windows 2012',
    :ensure          => 'present',
    :serverfolder    => '',
    :notes           => '',
    :wwn             => '21000024FF44486F',
    )
	end

	it "should have name as its keyattribute" do
		described_class.key_attributes.should == [:name]
	end

	describe "when validating attributes" do
		[:operatingsystem,:name].each do |param|
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
			it "should allow a valid operatingsystem with ensure present" do
			described_class.new(:name => 'newSerOne',:operatingsystem => 'Windows 2012', :ensure => 'present')[:operatingsystem].should == 'Windows 2012'
			end
			it "should allow a valid operatingsystem with ensure absent" do
				described_class.new(:name => 'newSerTwo',:operatingsystem => 'Windows 2012', :ensure => 'absent')[:operatingsystem].should == 'Windows 2012'
			end
		end
	end	
end