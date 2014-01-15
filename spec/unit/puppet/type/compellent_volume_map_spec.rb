#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'

describe Puppet::Type.type(:compellent_volume_map) do

	let :resource do
	described_class.new(
	:name  => 'Windows 2012',
    :ensure            => 'present',
    :boot              => true,
    :volumefolder 	   => 'TestFolder',
    :serverfolder      => 'TestServerFolder',
    :servername        => 'Test_Server',
    :lun               => '',
    :localport         => '',
    :force             => true,
    :singlepath        => true,
    :readonly          => true,
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
			it "should allow a valid volumefolder with ensure present" do
			described_class.new(:name => 'newVolMapOne', :volumefolder => 'TestFolder', :ensure => 'present')[:volumefolder].should == 'TestFolder'
			end
			it "should allow a valid volumefolder with ensure absent" do
				described_class.new(:name => 'newVolMapTwo',:volumefolder => 'TestFolder', :ensure => 'absent')[:volumefolder].should == 'TestFolder'
			end
		end
	end	
end