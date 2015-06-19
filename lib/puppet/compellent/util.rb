module Puppet
  module Compellent
    module Util
      def self.get_transport
        require 'asm/device_management'
        begin
          ASM::DeviceManagement.parse_device_config(Puppet[:certname])
        rescue
          raise Puppet::Error, "Error parsing device config for: #{Puppet[:certname]}"
        end
      end
    end
  end
end