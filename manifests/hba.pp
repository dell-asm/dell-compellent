# == Define: compellent::hba
#
# Utility class for creation of a Server HBA.
#


define compellent::hba (
  $wwn, 
  $ensure = 'present', 
  $porttype = '', 
  $serverfolder = '', 
  $manual = false,) {
  compellent_hba { "$name":
    ensure       => $ensure,
    porttype     => $porttype,
    wwn          => $wwn,
    manual       => $manual,
    serverfolder => $serverfolder,
  }
}
