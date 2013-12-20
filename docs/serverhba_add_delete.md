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

     The create method adds HBA to a given server object. 

   
  2. Destroy

     The destroy method removes HBA from a given server object.  


# -------------------------------------------------------------------------
# Summary of parameters.
# -------------------------------------------------------------------------

    name: (Required) This parameter defines the name of the server object upon which the HBA is to be added/removed.

	ensure: (Required) This parameter is required to call the create or destroy method.
    Possible values: present/absent
    If the value of the ensure parameter is set to present, the module calls the create method.
    If the value of the ensure parameter is set to absent, the modules calls the destroy method.

    porttype:(Required) This parameter defines the transport type for all HBAs being added. This option is required if the
             manual flag is set. The possible values are:(FibreChannel/iSCSI).	
	    
    wwn:  This parameter defines the HBA world wide names (WWNs) for the server.
         	    
    manual: This parameter sets an optional flag to configure the requested HBAs before they are discovered. If the WWN matches
            a known server port, then this flag is ignored. If this flag is present, then 'porttype' must also be
            specified. The possible values are: true/false).         

    serverfolder: This parameter defines the folder name for the server object.        

    user:(Required) This parameter defines the storage admin user name.

    password:(Required) This parameter defines the storage admin password.

    host:(Required) This parameter defines the storage ipAddress/name.

# -------------------------------------------------------------------------
# Parameter signature 
# -------------------------------------------------------------------------

#Provide transport and HBA properties

    define compellent::hba_add_delete (
            $user, 
            $password,
            $host,
            $wwn,
            $ensure        	= 'present',
            $porttype	    = '',
            $serverfolder 	= '',
            $manual		    =  false,  

            ) {
        compellent_hba_add_delete { "${name}":
            ensure       	 	 => $ensure,
            porttype		     => $porttype,
            wwn	          	     => $wwn,
            manual		         => $manual,
            user			     => $user,
            password 		     => $password,
            serverfolder         => $serverfolder,
            host			     => $host,
        }
    }

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
   Refer to the examples in the manifest directory.
   The following files capture the details for the sample init.pp and the supported files:

    - sample_init.pp_hba
    - sample_hba_add_delete.pp
   
   A user can create an init.pp file based on the above sample files, and call the "puppet device" command , for example: 
   # puppet device

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------	
