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
#      wwn1 => '21000024FF43A69A',
#      wwn2 => '21000024FF43A69B',
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
	$servername,
	$operatingsystem = 'VMWare ESX 5.1',
	$serverfolder = '',
	$wwn1,
	$wwn2,
	$porttype = 'FiberChannel',
	$manual = false,
	$force = true,
	$readonly = false,
	$singlepath = false,
	$lun = '',
	$localport = '',
) {
	compellent_volume {
		"$name":
			size => "$size",
			boot => "$boot",
			volumefolder => "$volumefolder",
			purge => "$purge",
			notes => "$volume_notes",
			replayprofile => "$replayprofile",
			storageprofile => "$storageprofile",
			ensure => 'present',
	}

	compellent_server {
		"$servername":
			operatingsystem => "$operatingsystem",
			notes => "$server_notes",
			serverfolder => "$serverfolder",
			wwn => "$wwn1",
			ensure => 'present',
	}

	compellent_hba {
		"$servername":
			wwn => "$wwn2",
			serverfolder => "$serverfolder",
			porttype => "$porttype",
			manual => "$manual",
			ensure => 'present',
	}

	compellent_volume_map {
		"$name":
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
	}

	Compellent_server["$servername"]
		-> Compellent_hba["$servername"]
		-> Compellent_volume["$name"]
		-> Compellent_volume_map["$name"]
}
