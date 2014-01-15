require 'spec_helper'
require 'fixtures/unit/puppet/provider/compellent_volume/compellent_volume_fixture'

NOOPS_HASH = {:noop => false}

describe Puppet::Type.type(:compellent_volume).provider(:compellent_volume) do

  before(:each) do
    @fixture = Compellent_volume_fixture.new
    mock_transport=mock('transport')
    @fixture.provider.transport = mock_transport
    Puppet.stub(:debug)

  end

  context "when compellent volume provider is created " do

    it "should have parent 'Puppet::Provider::Compellent'" do
      @fixture.provider.should be_kind_of(Puppet::Provider::Compellent)
    end

    it "should have create method defined for compellent_volume" do
      @fixture.provider.class.instance_method(:create).should_not == nil

    end

    it "should have destroy method defined for compellent_volume" do
      @fixture.provider.class.instance_method(:destroy).should_not == nil
    end

    it "should have exists? method defined for compellent_volume" do
      @fixture.provider.class.instance_method(:exists?).should_not == nil

    end
  end
end