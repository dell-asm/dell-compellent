# Class: compellent
#
# This module manages compellent
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]

class compellent {
  compellent::hba { 'Test_Server':
    ensure       => 'absent',
    serverfolder => '',
    porttype     => 'FibreChannel',
    wwn          => '21000024FF4ABF6C',
    manual       => true,
  }
}

