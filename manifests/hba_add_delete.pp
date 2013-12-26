# == Define: compellent::hba
#
# Utility class for creation of a Server HBA.
#
# === Parameters:
#
# [*ensure*]
#   The resource state.
#
# [*wwn*]
#   The World Wide Number.
#
# [*porttype*]
#   The type of port.
#
# [*manual*]
#   Space reservation mode. Valid options are: none, file and volume.# 
#
# === Actions:
#
# === Requires:
#
# === Sample Usage:
#
# Make sure there is a server hba called `server_hba`.
#
#  compellent::hba { 'server_hba':
# 	user, 
#	password,
#	host,
#	ensure        	= 'present',
#	porttype	    = '1234',
#	wwn	          	= 'WWN',
#	manual			= false,
#     }
#

define compellent::hba_add_delete (
  $wwn,
  $ensure        	= 'present',
  $porttype	        = '',
  $serverfolder 	= '',
  $manual		    =  false,  
  
) {
  compellent_hba_add_delete { "${name}":
  ensure       	 	 => $ensure,
  porttype		     => $porttype,
  wwn	          	 => $wwn,
  manual		     => $manual,
  serverfolder       => $serverfolder,
  }
}
