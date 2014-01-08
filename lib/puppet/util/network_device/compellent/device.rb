# Class - Making connection with device

require 'puppet/util/network_device'
require 'puppet/util/network_device/compellent/facts'
require 'puppet/util/network_device/transport_compellent'
require 'uri'
require 'net/https'
require 'puppet/files/ResponseParser'
require 'puppet/files/CommonLib'

class Puppet::Util::NetworkDevice::Compellent::Device

  attr_accessor :url, :transport
  def initialize(url, option = {})
    Puppet.debug("Device login started")
    @url = URI.parse(url)
    redacted_url = @url.dup
    redacted_url.password = "****" if redacted_url.password
    Puppet.debug("Puppet::Device::Compellent: connecting to Compellent device #{redacted_url}")
    raise ArgumentError, "Invalid scheme #{@url.scheme}. Must be https" unless @url.scheme == 'https'
    raise ArgumentError, "no user specified" unless @url.user
    raise ArgumentError, "no password specified" unless @url.password
    Puppet.debug("Host IP is #{@url.host}  #{@url.scheme}")
    @transport = Puppet::Util::NetworkDevice::Transport_compellent.new
    @transport.host = @url.host
    @transport.user = URI.decode(@url.user)
    @transport.password = URI.decode(@url.password)
    Puppet.debug("host is #{@transport.host}")

    login_respxml = "#{CommonLib.get_log_path(1)}/loginResp_#{CommonLib.get_unique_refid}.xml"
    response = @transport.exec("system show -xml #{login_respxml}")
    hash = response[:xml_output_hash]
    response_output = response[:xml_output_file]
    File.delete(login_respxml,response_output)
    if "#{hash['Success']}".to_str() == "TRUE"
      Puppet.debug("Login successful..")
    else
      raise Puppet::Error, "#{hash['Error']}"
    end
  end

  def facts
    Puppet.debug("In facts call")
    @facts ||= Puppet::Util::NetworkDevice::Compellent::Facts.new(@transport)
    facts = @facts.retrieve

    facts
  end
end
