#Dell Compellent

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with compellent module](#setup)
    * [Compellent JAVA SDK](#compellent_java_sdk) 
    * [Device Setup](#device_setup)
5. [Limitations - OS compatibility, etc.](#limitations)

##Overview

The Compellent module manages the volumes and servers objects.

##Module Description

The compellent module is capable of creating/destroying volumes , creating/destroying server objects , adding/removing initiators to server objects and mapping/unmapping volumes with server objects.

##Setup

###Compellent JAVA SDK

As Puppet agent cannot be directly installed on the Compellent storage controller, it can either be managed from the Puppet Master server, or through an intermediate proxy system running a puppet agent. The requirements for the proxy system are as under:

 * Puppet 2.7.+
 * Compellent JAVA SDK

The Compellent JAVA libraries (CompCU-6.3.jar) can be downloaded directly from the Dell support site. (http://support.dell.com).

Note: A Dell Compellent support account is required to be able to download the SDK.

After downloading the SDK, the following files need to be copied to the Puppet Master: 

`CompCU-6.3.jar > [module dir]/compellent/lib/puppet/files/`


### Device Setup

To configure a Compellent storage device, the device *type* must be `compellent`.
The device can either be configured within */etc/puppet/device.conf*, or, preferably, create an individual config file for each device within a sub-folder.
This is preferred, as it allows the user to run the puppet against individual devices, rather than all devices configured...

In order to run the puppet against a single device, you can use the following command:

    puppet device --deviceconfig /etc/puppet/device/[device].conf

Example configuration `/etc/puppet/device/compellent1.example.com.conf`:

    [compellent1.example.com]
      type compellent
      url https://root:secret@compellent1.example.com



## Volume

###Description

The Volume type/provider supports the functionality to create and destroy the volumes on a Compellent storage.

####Summary of Properties

1. _name_: (Required) This parameter defines the name of the volume that is to be created/destroyed.

2. _size_: (Required) This parameter specifies the volume size. Enter the number of 512-byte blocks or the total byte size. To specify a total byte size, use k for kilobytes, m for megabytes, g for gigabytes, or t for terabytes.

3. _boot_: If present, this parameter designates the mapped volume to be a boot volume.

4. _folder_: This parameter specifies the name of an existing volume folder where a volume is to be created. In case the folder does not exists , a new folder is created.

5. _notes_: This parameter specifies the notes for the volume. By default, no notes are included.

6. _replayprofile_: This parameter specifies the replay profiles for the volume.

7. _storageprofile_: This parameter specifies a storage profile for the volume.

8. _purge_: This parameter indicates that the volume should be purged. If the purge option is not specified, the volume is still visible using the volume show command and contains the status of the Recycleded. The possible values for this parameter are "yes/no". The default value is "yes". 


####Usage

The compellent storage volume module can be used by calling the Volume resource type from the init.pp, as shown in the example below:

      compellent::volume { 'FCDemoVolume':
                purge          => 'yes',
                size           => '20g',
                ensure         => 'present',
                boot           => false,
                volumefolder   => '',
                notes          => 'This is a FC Demo Volume',
                replayprofile  => 'Sample',
                storageprofile => 'Low Priority',
        }


## Server

###Description

The Server type/provider supports the functionality to create and destroy the server object on a Compellent storage.

####Summary of Properties

1. _name_: (Required) This parameter defines the server name that is to be created/destroyed.

2. _operatingsystem_: (Required) This parameter defines the name of the operating system hosted on the server.	     
    
3. _serverfolder_: This parameter defines the folder for the server.     
    
4. _notes_: This parameter defines the optional user notes associated with the server.		    
    
5. _wwn_: (Required) This parameter defines a globally unique world wide name for the requested HBA.


####Usage

The compellent storage server module can be used by calling the server resource type from init.pp, as 
shown in the example below:

     compellent::server { 'HK4V5Y1':
                operatingsystem => 'VMWare ESX 5.1',
                ensure          => 'present',
                serverfolder    => '',
                notes           => '',
                wwn             => '21000024FF4ABE2E',
        }



## volume_map

###Description

The volume_map type/provider supports the functionality to map a volume to a server object on a compellent storage.

####Summary of Properties

1. _name_: (Required)This parameter defines the name of the volume that is to be mapped/unmapped.

2. _boot_: If present, this parameter designates the mapped volume to be a boot volume. The possible values are "true/false".
 
3. _servername_: (Required) This parameter defines the name of the server where the volume or volume view is to be mapped.  		    

4. _serverfolder_: This parameter defines the folder in which the server object is available.
         
5. _lun_: (Required) This parameter defines the logical unit number (LUN) for the mapped volume.
		        
6. _volumefolder_: This parameter defines the folder in which the volume is present.
    
7. _localport_: This parameter defines the world wide name (WWN) of the single local port to use for mapping, when the singlepath option is used.
	     
8. _force_: If this parameter is defined, it forces mapping, even if the mapping already exists. The possible values are: true/false.
		       
9. _readonly_: This parameter defines whether or not a map is read only. The possible values are: true/false.
 		
10. _singlepath_: This parameter indicates that only a single local port can be used for mapping. If omitted, all local ports are used for mapping. The possible values are: true/false.


####Usage

The compellent storage volume map module can be used by calling the volume_map resource type from init.pp, as shown in the example below:

    compellent::volume_map { 'FCDemoVolume':
                ensure       => 'present',
                boot         => true,
                volumefolder => '',
                serverfolder => '',
                servername   => 'HK4V5Y1',
                lun          => '',
                localport    => '',
                force        => true,
                singlepath   => true,
                readonly     => true,
      }


## hba

###Description

The hba type/provider supports the functionality to add/remove an hba from a server object on a Compellent storage.

####Summary of Properties


1. _name_: (Required) This parameter defines the name of the server object upon which the HBA is to be added/removed.

2. _porttype_: (Required) This parameter defines the transport type for all HBAs being added. This option is required if the manual flag is set. The possible values are:(FibreChannel/iSCSI).	
	    
3. _wwn_: (Required)This parameter defines the HBA world wide names (WWNs) for the server.
         	    
4. _manual_: This parameter sets an optional flag to configure the requested HBAs before the HBAs are discovered. If the WWN matches a known server port, then this flag is ignored. If this flag is present, then 'porttype' must also be specified. The possible values are: true/false).         

5. _serverfolder_: This parameter defines the folder name for the server object.        


####Usage

The compellent storage hba module can be used by calling the hba resource type from init.pp, as shown in the example below:

     compellent::hba { 'HK4V5Y1':
                ensure       => 'present',
                serverfolder => '',
                porttype     => 'FiberChannel',
                wwn          => '21000024FF4ABE2F',
                manual       => true,
        }



##Limitations

This module has been tested on:

* centos 6

Testing on other platforms cannot be guaranteed.


