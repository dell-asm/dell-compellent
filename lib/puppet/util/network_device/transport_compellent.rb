# Class - initialize variable used for device connection

require 'net/https'
require 'puppet/util/network_device'
class Puppet::Util::NetworkDevice::Transport_compellent
      attr_accessor :host, :user, :password
      def initialize
      end
end
