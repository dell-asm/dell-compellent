require 'spec_helper'
require 'fixtures/unit/puppet/provider/compellent_volume_map/compellent_volume_map_fixture'

NOOPS_HASH = {:noop => false}

describe Puppet::Type.type(:compellent_volume_map).provider(:compellent_volume_map) do

  before(:each) do
    @fixture = Compellent_volume_map_fixture.new
    mock_transport=double('transport')
    @fixture.provider.transport = mock_transport
    Puppet.stub(:debug)

  end

  context "when compellent volume map provider is created " do

    it "should have parent 'Puppet::Provider::Compellent'" do
      @fixture.provider.should be_kind_of(Puppet::Provider::Compellent)
    end

    it "should have create method defined for compellent volume map" do
      @fixture.provider.class.instance_method(:create).should_not == nil

    end

    it "should have destroy method defined for compellent volume map" do
      @fixture.provider.class.instance_method(:destroy).should_not == nil
    end

    it "should have exists? method defined for compellent volume map" do
      @fixture.provider.class.instance_method(:exists?).should_not == nil

    end
  end
end