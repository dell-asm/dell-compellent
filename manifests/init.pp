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

class compellent{
 compellent::vqe { 'Test1':
  user              => 'test',
  password          => 'P@ssw0rd',
  host              => '172.17.10.45',
  size 				=> '2g',
  ensure        	=> 'absent',
  boot				=>  false,  
  folder            => 'folder2',
  notes 			=> 'Test1',
  replayprofile 	=> 'Sample',
  storageprofile	=> 'Low Priority',
    }
}

