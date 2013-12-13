# == Define: compellent::vqe
#
# Utility class for creation of a NetApp Volume, Qtree and NFS export.
#
# === Parameters:
#
# [*ensure*]
#   The resource state.
#
# [*size*]
#   The volume size to create/set.
#
# [*aggr*]
#   The aggregate to contain the volume.
#
# [*spaceres*]
#   Space reservation mode. Valid options are: none, file and volume.
#
# [*snapresv*]
#   The amount of space to reserve for snapshots, in percent.
#
# [*autoincrement*]
#   Should the volume auto-increment? True/False.
#
# [*options*]
#   Hash of options to set on volume. Keyshould match option name.
#
# [*snapschedule*]
#   Hash of snapschedule to set on volume.
#
# [*persistent*]
#   Should the export be persistent? True/False.
#
# === Actions:
#
# === Requires:
#
# === Sample Usage:
#
# Make sure there is a volume called `v_test_volume`, a qtree
# called `q_test_volume` and there is an NFS Export. The initial
# size will be 1 TeraByte.
#
#     compellent::vqe { 'test_volume':
#       size           => "1t",
#       aggr           => "aggr1",
#       spaceres       => "file",
#       snapresv       => 20,
#       autoincrement  => false,
#       persistent     => false
#     }
#
#
define compellent::vqe (
  $user, 
  $password,
  $host,
  $size,
  $ensure        	= 'absent',
  $boot			= false,  
  $folder               = 'folder',
  $notes 		= 'Test',
  $replayprofile 	= 'Sample',
  $storageprofile	= 'Low Priority',
  
) {
  compellent_volume { "v_${name}":
  ensure       	 	 => $ensure,
  size     	 	 => $size,
  boot		     	 => $boot,  
  folder         	 => $folder,
  notes				 => $notes,   
  replayprofile		 => $replayprofile,
  storageprofile	 => $storageprofile,
  user				 => $user,
  password 			 => $password,
  host				 => $host,
  }
}
