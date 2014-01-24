# == Define: compellent::server
#
# Utility class for creation of a Compellent Server#
#
define compellent::server (
  $wwn             = '',
  $operatingsystem = '',
  $ensure          = 'present',
  $serverfolder    = '',
  $notes           = '',) {
  compellent_server { "$name":
    ensure          => $ensure,
    operatingsystem => $operatingsystem,
    serverfolder    => $serverfolder,
    notes           => $notes,
    wwn             => $wwn,
  }
}

