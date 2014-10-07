#
# == Define: compellent::removevol
#
# Utility for removing volumes and server object from compellent storage center.
#
# === Parameters:
#
# === Actions:
#
# === Requires:
#
# === Sample Usage:
#  compellent::removevol {'test_vol_1':
#      volumefolder => 'ASM',
#      servername => '78QR1V1',
#      operatingsystem => 'VMWare ESX 5.1',
#      serverfolder => 'ASM_FOL',
#  }
#
define compellent::removevol (
  $volumefolder = '',
  $purge = 'yes',
  $volume_notes = '',
  $server_notes = '',
  $replayprofile = 'Sample',
  $storageprofile = 'Low Priority',
  $servername = '',
  $operatingsystem = 'VMWare ESX 5.1',
  $serverfolder = '',
  $porttype = 'FibreChannel',
  $manual = false,
  $force = true,
  $readonly = false,
  $singlepath = false,
  $lun = '',
  $localport = '',
) {
  compellent_volume {"$name":
    ensure         => 'absent',
    volumefolder   => "$volumefolder",
    purge          => "$purge",
    notes          => "$volume_notes",
    replayprofile  => "$replayprofile",
    storageprofile => "$storageprofile",
  }
  if empty($servername) != true {
    compellent_server { "$servername":
      ensure          => 'absent',
      operatingsystem => "$operatingsystem",
      notes           => "$server_notes",
      serverfolder    => "$serverfolder",
      require         =>  Compellent_volume["$name"],
    }
  }
}
