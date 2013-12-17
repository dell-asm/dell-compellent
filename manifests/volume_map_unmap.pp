# == Define: compellent::volume_map_unmap
#
# Utility class for Compellent map/unmap volume.
#

define compellent::volume_map_unmap (
  $user, 
  $password,
  $host,
  $servername,
  $ensure        	= 'absent',
  $boot			= false,
  $lun          	= '',
  $folder 	        = '',
  $localport    	= '',
  $force		= false, 
  $readonly		= false, 
  $singlepath		= false, 
  
) {
  compellent_map_volume { "${name}":
  ensure       	 	 => $ensure,
  boot		     	 => $boot,
  servername		 => $servername,   
  lun 		         => $lun,
  folder                 => $folder,
  localport	         => $localport,
  force		         => $force,   
  readonly 		 => $readonly,
  singlepath	         => $singlepath,
  user			 => $user,
  password 		 => $password,
  host			 => $host,
  }
}
