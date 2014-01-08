# == Define: compellent::server
#
# Utility class for creation of a Compellent Server#
#
define compellent::server (
  $wwn             = '21000024FF44486F',
  $operatingsystem = 'Windows 2012',
  $ensure          = 'present',
  $serverfolder    = '',
  $notes           = 'Test Server',) {
  compellent_server { "$name":
    ensure          => $ensure,
    operatingsystem => $operatingsystem,
    serverfolder    => $serverfolder,
    notes           => $notes,
    wwn             => $wwn,
  }
}

