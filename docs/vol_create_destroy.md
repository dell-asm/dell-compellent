# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

The Compellent storage module uses the Compellent JAVA SDK (CompCU-6.3.jar) to interact with the compellent storage device.

# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------

	- Create
	- Destroy

# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------


  1. Create

     The create method creates the volume as per the parameters specified in the definition. 

   
  2. Destroy

     The destroy method deletes the volume from the storage device.  


# -------------------------------------------------------------------------
# Summary of parameters.
# -------------------------------------------------------------------------

    name: (Required) This parameter defines the name of the volume that needs to be created/destroyed.

	ensure: (Required) This parameter is required to call the create or destroy method.
    Possible values: present/absent
    If the value of the ensure parameter is set to present, the module calls the create method.
    If the value of the ensure parameter is set to absent, the modules calls the destroy method.

    size:(Required) This parameter specifies the volume size. Enter the number of 512-byte blocks or the total byte size. To specify
         a total byte size, use k for kilobytes, m for megabytes, g for gigabytes, or t for terabytes.

    boot: If present, this parameter designates the mapped volume to be a boot volume.

    folder: This parameter specifies the name of an existing volume folder where a volume is to be created. In case the folder does not exists , a new folder is created.

    notes: This parameter specifies the notes for the volume. By default, no notes are included.

    replayprofile: This parameter specifies the replay profiles for the volume.

    storageprofile: This parameter specifies a storage profile for the volume.

    purge: This parameter indicates that the volume should be purged. If the purge option is not specified, the volume is still visible using the volume show command and contains the status of the Recycled. Possible values for this parameter are "yes/no".
    Default value is "yes". 

# -------------------------------------------------------------------------
# Parameter signature 
# -------------------------------------------------------------------------

#Provide transport and volume properties

define compellent::volume_create_destroy (
        $size,
        $purge          = 'yes',
        $ensure        	= 'present',
        $boot		=  false,  
        $folder         = '',
        $notes 	     	= '',
        $replayprofile 	= 'Sample',
        $storageprofile	= 'Low Priority',

        ) {
    compellent_volume { "${name}":
        ensure       	 => $ensure,
        size     	 	 => $size,
        boot		     => $boot,  
        folder         	 => $folder,
        notes			 => $notes,   
        replayprofile	 => $replayprofile,
        storageprofile	 => $storageprofile,
        purge            => $purge,
    }
}

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
   Refer to the examples in the manifest directory.
   The following files capture the details for the sample init.pp and supported files:

    - sample_init.pp_volume
    - volume_create_destroy.pp
   
   A user can create an init.pp file based on the above sample files and call the "puppet device" command , for example: 
   # puppet device

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------	
