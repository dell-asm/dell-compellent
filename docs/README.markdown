# Compellent storage device module

**Table of Contents**

- [Compellent storage device module](#Compellent-network-device-module)
	- [Overview](#overview)
	- [Features](#features)
	- [Requirements](#requirements)
		- [Compellent JAVA SDK] (#CompCU-6.3.jar)
	- [Usage](#usage)
		- [Device Setup](#device-setup)
		- [Compellent operations](#Compellent-operations)

## Overview
The Compellent storage device module is designed to extend the support for managing Compellent Storage Controller configuration using Puppet and its Network Device functionality.

The Compellent storage device module has been written and tested against the Compellent JAVA SDK(CompCU-6.3.jar). The following Compellent models have been verified using this module:
- SC8000

However, this module may be compatible with other versions.

## Features
This module supports the following functionality:

 * Volume creation and deletion.
 * Server creation and deletion.
 * Addition and Removal of HBAs from volumes.
 * Mapping and unmapping of Volumes. 

## Requirements
As a Puppet agent cannot be directly installed on the Compellent storage controller, it can either be managed from the Puppet Master server,
or through an intermediate proxy system running a puppet agent. The requirements for the proxy system are as under:

 * Puppet 2.7.+
 * Compellent JAVA SDK

### Compellent JAVA SDK
The Compellent JAVA libraries (CompCU-6.3.jar) can be downloaded directly from the [Compellent](http://support.dell.com).
Please note: A Dell Compellent support account is required to be able to download the SDK.

After downloading the SDK, the following files need to be copied to the Puppet Master:
`CompCU-6.3.jar > [module dir]/compellent/lib/puppet/lib/`

## Usage

### Device Setup
To configure a Compellent storage device, the device *type* must be `compellent`.
The device can either be configured within */etc/puppet/device.conf*, or, preferably, create an individual config file for each device within a sub-folder.
This is preferred as it allows the user to run the puppet against individual devices, rather than all devices configured...

In order to run the puppet against a single device, you can use the following command:

    puppet device --deviceconfig /etc/puppet/device/[device].conf

Example configuration `/etc/puppet/device/compellent1.example.com.conf`:

    [compellent1.example.com]
      type compellent
      url https://root:secret@compellent1.example.com

### Compellent operations
This module can be used to create/destroy a volume, map/unmap the volume, create/destroy a server, add/remove an HBA.
For example: 

 compellent::volume_create_destroy { 'Volume Name':
        user              => 'Admin',
        password          => 'xyz',
        host              => '172.19.30.40',
        purge             => 'yes',
        size 		      => '2g',
        ensure        	  => 'absent',
        boot			  =>  false,  
        volumefolder      => 'Test',
        notes 			  => 'Test Space Notes',
        replayprofile 	  => 'Sample',
        storageprofile	  => 'Low Priority',
    }

This creates a Compellent volume called `Volume Name`, as per the values defined for various parameters in the above definition.
The volume occupies 2gb space.

You can also use any of the above operations individually, or create new defined types, as required. The details of each operation and parameters 
are mentioned in the following readme files, that are shipped with the module:

  - server_create_destroy.md
  - serverhba_add_delete.md
  - vol_create_destroy.md
  - vol_map_unmap.md
