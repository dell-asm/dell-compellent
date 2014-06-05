#
# == Define: compellent::unmapvolume
#
# Utility for creating volumes in compellent storage center.
#

define compellent::unmapvolume (
  $volumefolder = '',
  $servername = '',
  $serverfolder = '',
  $force = true
) {
    compellent_volume_map { "$name":
      ensure       => 'absent',
      volumefolder => "$volumefolder",
      serverfolder => "$serverfolder",
      force        => "$force",
      servername   => "$servername",
    }
}
