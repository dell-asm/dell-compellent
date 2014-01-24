#
# == Define: compellent::createvol
#
# Utility for creating volumes in compellent storage center.
#
# === Parameters:
#
# === Actions:
#
# === Requires:
#
# === Sample Usage:
#  compellent::createvol {'test_vol_1':
#      size => '200g',
#      volumefolder => 'ASM',
#      servername => '78QR1V1',
#      operatingsystem => 'VMWare ESX 5.1',
#      serverfolder => 'ASM_FOL',
#      wwn => '21000024FF43A69A, 21000024FF43A69B',
#  }
#
define compellent::createvol (
  $size = '100g',
  $boot = 'false',
  $volumefolder = '',
  $purge = 'yes',
  $volume_notes = '',
  $server_notes = '',
  $replayprofile = 'Sample',
  $storageprofile = 'Low Priority',
  $servername = '',
  $operatingsystem = 'VMWare ESX 5.1',
  $serverfolder = '',
  $wwn = '',
  $porttype = 'FibreChannel',
  $manual = false,
  $force = true,
  $readonly = false,
  $singlepath = false,
  $lun = '',
  $localport = '',
) {
  compellent_volume {"$name":
    size => "$size",
    boot => "$boot",
    volumefolder => "$volumefolder",
    purge => "$purge",
    notes => "$volume_notes",
    replayprofile => "$replayprofile",
    storageprofile => "$storageprofile",
    ensure => 'present',
  }

  if empty($servername) != true {
    if empty($wwn) != true {
      $temp_wwn_array = strip(split($wwn, ','))
      $wwn_array = unique($temp_wwn_array)
      $wwn1 = $wwn_array[0]
      $wwn2 = inline_template("<%= @wwn_array.drop(1).join(',') %>")

      compellent_server { "$servername":
        operatingsystem => "$operatingsystem",
        notes => "$server_notes",
        serverfolder => "$serverfolder",
        wwn => "$wwn1",
        ensure => 'present',
        require =>  Compellent_volume["$name"],
      }

      if empty($wwn2) != true {
        compellent_hba { "$servername":
          wwn => "$wwn2",
          serverfolder => "$serverfolder",
          porttype => "$porttype",
          manual => "$manual",
          ensure => 'present',
          require =>  Compellent_server["$servername"],
        }
      }

      compellent_volume_map { "$name":
        boot => "$boot",
        volumefolder => "$volumefolder",
        serverfolder => "$serverfolder",
        force => "$force",
        readonly => "$readonly",
        singlepath => "$singlepath",
        servername => "$servername",
        lun => "$lun",
        localport => "$localport",
        ensure => 'present',
        require =>  Compellent_server["$servername"],
      }
    }
  }
}
