#! /usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:compellent_hba_add_delete) do

  #Load Parameter file
  parameter_yml =  YAML.load_file(my_fixture('compellent_hba.yml'))
  parameter_node = parameter_yml['CompellentHBAParameters']
  
  let :resource do
    described_class.new(
      :name          		=> parameter_node['name'],
	  :ensure        		=> parameter_node['ensure'],
	  :serverfolder			=> parameter_node['serverfolder'],
	  :wwn					=> parameter_node['wwn'],
	  :porttype 			=> parameter_node['porttype'],
	  :manual				=> parameter_node['manual']	 
    )
  end

  
  it "should have name as its keyattribute" do
    described_class.key_attributes.should == [:name]
  end

  
  describe "when validating attributes" do
    [:name,:wwn].each do |param|
      it "should hava a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end
  end

  
  describe "when validating values" do
  
    describe "for name" do
      it "should allow a valid HBA name" do
        resource.name.should eq( 'Test_Server')
      end      
    end

    describe "for ensure" do
      it "should allow present" do
        described_class.new(:name => resource.name, :ensure => 'present')[:ensure].should == :present
      end
	  
	  it "should allow present" do
        expect { described_class.new(:name => resource.name, :ensure => 'invalid') }.to raise_error Puppet::Error, /Invalid value/
      end
    
    end
	
	 describe "for wwn" do
      it "should allow a valid WWN" do
	   described_class.new(:name => resource.name,:wwn => '21000024FF46613F')[:wwn].should == '21000024FF46613F'
      end    
    end
	
	 describe "for server folder" do
      it "should allow a valid server folder" do
         described_class.new(:name => resource.name,:serverfolder => '')[:serverfolder].should == ''
      end    
    end
	
	 describe "for port type" do
      it "should allow a valid port type" do
         described_class.new(:name => resource.name,:porttype => 'FiberChannel')[:porttype].should == 'FiberChannel'
      end    
    end
	
	describe "for manual" do
      it "should allow a valid port type" do
      described_class.new(:name => resource.name,:manual => true)[:manual].should == :true
      end    
    end
	
  end	
end