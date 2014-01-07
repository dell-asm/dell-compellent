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

     The create method creates the server object as per the parameters specified in the definition. 

   
  2. Destroy

     The destroy method deletes the server object from the storage device.  


# -------------------------------------------------------------------------
# Summary of parameters.
# -------------------------------------------------------------------------

    name: (Required) This parameter defines the server name that is to be created/destroyed.

	ensure: (Required) This parameter is required to call the create or destroy method.
    Possible values: present/absent
    If the value of the ensure parameter is set to present, the module calls the create method.
    If the value of the ensure parameter is set to absent, the modules calls the destroy method.
    
    operatingsystem:(Required) This parameter defines the name of the operating system hosted on the server.	     
    
    serverfolder: This parameter defines the folder for the server.     
    
    notes: 	This parameter defines the optional user notes associated with the server.		    
    
    wwn:(Required) This parameter defines a globally unique world wide name for the requested HBA
			        

# -------------------------------------------------------------------------
# Parameter signature 
# -------------------------------------------------------------------------

#Provide transport and volume properties

    define compellent::server_create_destroy (
            $wwn,
            $operatingsystem      = 'Windows 2012',
            $ensure        	      = 'present',
            $serverfolder         = '',
            $notes 		          = '',

            ) {
    compellent_server { "${name}":
        ensure       	 	 => $ensure,
        operatingsystem	     => $operatingsystem,
        serverfolder         => $serverfolder,
        notes			     => $notes,   
        wwn			         => $wwn,
       
    }
}

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
   Refer to the examples in the manifest directory.
   The following files capture the details of the sample init.pp and the supported files:

    - sample_init.pp_server
    - server_create_destroy.pp
   
   A user can create an init.pp file based on the above sample files, and call the "puppet device" command , for example: 
   # puppet device

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------	
