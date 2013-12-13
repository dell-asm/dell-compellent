require 'puppet/util/network_device'
require 'puppet/util/network_device/compellent/facts'
require 'puppet/util/network_device/transport_compellent'
require 'uri'
require 'net/https'

class Puppet::Util::NetworkDevice::Compellent::Device

  attr_accessor :url, :transport

  def initialize(url, option = {})
    Puppet.debug("Device login started")
    @url = URI.parse(url)
    redacted_url = @url.dup
    redacted_url.password = "****" if redacted_url.password

    Puppet.debug("Puppet::Device::Netapp: connecting to Netapp device #{redacted_url}")

    raise ArgumentError, "Invalid scheme #{@url.scheme}. Must be https" unless @url.scheme == 'https'
    raise ArgumentError, "no user specified" unless @url.user
    raise ArgumentError, "no password specified" unless @url.password
    Puppet.debug("Host IP is #{@url.host}  #{@url.scheme}")
    @transport = Puppet::Util::NetworkDevice::Transport_compellent.new
    @transport.host = @url.host
    @transport.user = @url.user
    @transport.password = @url.password
    Puppet.debug("host is #{@transport.host}")
    response = system("java -jar /etc/puppet/modules/compellent/lib/puppet/util/network_device/compellent/CompCU-6.3.jar -host  #{@url.host} -user #{@url.user} -password P@ssw0rd -xmloutputfile /tmp/#{@url.host}_loginExitCode.xml -c \"system show -xml /tmp/#{@url.host}_loginResponse.xml\" ")
    Puppet.debug("the end")
  end
		
  def facts
    Puppet.debug("In facts")
    @facts ||= Puppet::Util::NetworkDevice::Compellent::Facts.new(@transport)
    facts = @facts.retrieve
    
    facts
  end
end
