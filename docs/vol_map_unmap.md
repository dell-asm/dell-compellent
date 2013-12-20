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

     The create method maps the volume with a given server object. 

   
  2. Destroy

     The destroy method unmaps the volume from a given server object.  


# -------------------------------------------------------------------------
# Summary of parameters.
# -------------------------------------------------------------------------

    name: (Required)This parameter defines the name of the volume that is to be mapped/unmapped.

	ensure: (Required) This parameter is required to call the create or destroy method.
    Possible values: present/absent
    If the value of the ensure parameter is set to present, the module calls the create method.
    If the value of the ensure parameter is set to absent, the modules calls the destroy method.

    boot: If present, this parameter designates the mapped volume to be a boot volume. Possible values are "true/false".
 
    servername:(Required) This parameter defines the name of the server where the volume or volume view is to be mapped.  		    

    serverfolder: This parameter defines the folder in which the server object is available.
         
    lun:(Required) This parameter defines the logical unit number (LUN) for the mapped volume.
		        
    volumefolder: This parameter defines the folder in which the volume is present.
    
    localport: This parameter defines the world wide name (WWN) of the single local port to use for mapping when the
               singlepath option is used.
	     
    force: If this parameter is defined, it forces mapping even if the mapping already exists. The possible values are: true/false.
		       
    readonly: This parameter defines whether or not a map is read only. The possible values are: true/false.
 		
    singlepath:	 This parameter indicates that only a single local port can be used for mapping. If omitted, all local ports are used for mapping.
                 The possible values are: true/false.

    user:(Required) This parameter defines the storage admin user name.

    password:(Required) This parameter defines the storage admin password.

    host:(Required) This parameter defines the storage ipAddress/name.

# -------------------------------------------------------------------------
# Parameter signature 
# -------------------------------------------------------------------------

#Provide transport and Map properties

    define compellent::volume_map_unmap (
            $user, 
            $password,
            $host,
            $servername,
            $ensure        	    = 'absent',
            $boot			    = false,
            $lun          	    = '',
            $volumefolder 	    ,
            $serverfolder       = '',
            $localport    	    = '',
            $force		        = false, 
            $readonly		    = false, 
            $singlepath		    = false, 

            ) {
        compellent_map_volume { "${name}":
            ensure       	 	 => $ensure,
            boot		     	 => $boot,
            servername		     => $servername,   
            serverfolder         => $serverfolder,
            lun 		         => $lun,
            volumefolder         => $volumefolder,
            localport	         => $localport,
            force		         => $force,   
            readonly 		     => $readonly,
            singlepath	         => $singlepath,
            user			     => $user,
            password 		     => $password,
            host			     => $host,
        }
    }

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
   Refer to the examples in the manifest directory.
  The following files capture the details for the sample init.pp and the supported files:

    - init.pp_mapvol
    - volume_map_unmap.pp
   
   A user can create a init.pp file based on the above sample files and call the "puppet device" command , for example: 
   # puppet device

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------	
