define compellent::server_create_destroy (
  $user, 
  $password,
  $host,
  $wwn,
  $operatingsystem      = 'Windows 2012',
  $ensure        	= 'present',
  $serverfolder         = 'serverFolder',
  $notes 		= 'Test Server',
  
) {
  compellent_server { "${name}":
  ensure       	 	 => $ensure,
  operatingsystem	 => $operatingsystem,
  serverfolder         	 => $serverfolder,
  notes			 => $notes,   
  wwn			 => $wwn,
  user			 => $user,
  password 		 => $password,
  host			 => $host,
  }
}

