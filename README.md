## Overview

This repo contains simple Heat template and scripts to launch multiple vMX on OpenStack+Contrail.

Some of the template/script component are taken from official Juniper Heat Template [https://github.com/Juniper/vmx-heat-templates]
While the official template from Juniper provide a complete structure as well as a great detail of the explanation, their focus is to launch vMX that connected to real network.

This repo focuses on how to launch multiple vMX on OpenStack+Contrail that will be connected each other via multiple virtual network but isolated from the rest of the network. 

As an example, 2_nodes_vmx.yaml will launch a simple topology as below:
* number of vMX: 2
    * let's call it vmx101 and vmx102
    
* each vMX consist of 2 VMs, one for RE and one for FPC/PFE

* every virtual network created by this template will be set as L2 mode and configured to ignore the allocated IP. 
    * that's mean you can assign any IP to any ge-0/0/x interface, whether in access or trunk mode

* each VMX will have the following interfaces
    * RE and FPC fxp0 should be connected to public or any virtual network that accessible from outside openstack
        * the virtual network must be exist prior running the launching script
    * All vMX ge-0/0/0 and ge-0/0/1 will be connected to the same virtual network, let's call it net_dummy
        * this virtual network will be automatically created by the template
    * All vMX ge-0/0/0 and ge-0/0/1 will be connected to the same virtual network, let's call it net_dummy
        * this virtual network will be automatically created by the template
    * All vMX ge-0/0/2 will be connected to the existing virtual network
        * the purpose is, for lab simulation, sometime i need to connect vMX that launched from this template to the other vMX or even other VM inside OpenStack or even outside Openstack
        * the virtual network must be exist prior running the launching script
    * All vMX ge-0/0/3 will be connected to the existing virtual network
        * same purpose as ge-0/0/2. I just prepare 2 different network in case anyone need it. For my case, usually i use ge-0/0/2 for untagged traffic and ge-0/0/3 for tagged traffic
        * the virtual network must be exist prior running the launching script
    * EACH vmx ge-0/0/4 and ge-0/0/5 will have "hairpin" connection. 
        * Each VMX hairpin is isolated, so ge-0/0/4 from vmx01 will not connect to vmx02 ge-0/0/4
        * this virtual network will be automatically created by the template
        * I usually use this network to connect multiple logical system inside a vMX (alternatively you can use lt- interface)
    
    
If you notice, this script also depend on my other script [https://github.com/rendoaw/ocsc] to modify Contrail parameter thru REST API. 
This script is needed to change the virtual network properties as below:

```
{
    "forwarding_mode": "l2",
    "allow_transit": true,
    "mirror_destination": false,
    "rpf": "disable"
}
```

* note: 
    * forwarding_mode=l2 can be set from HEAT template or you can also set default forwarding mode = L2 for any future virtual network creation in Contrail page, but i found out that at least in Contrail 3.2.2, i also need to set "rpf = disable" to allow traffic from any arbitrary IP. 
    * this rpf setting seems not configurable from HEAT and there is no way to set the default rpf setting in the global config. The only way that i can find is thru REST API.


## Setup

* Please refer to official Juniper Heat Template [https://github.com/Juniper/vmx-heat-templates] for better understanding of vMX requirement.

* (Optionally) run setup.sh to prepare your environment
* Copy openstackrc-sample to openstackrc
* Adjust openstackrc based on your environment
* Adjust the environment file according to your environment


## Run

* syntax

    ```
    ./vmx_launch.sh -s <stackname> -t <HEAT template file> -e <environment file>
    ```

* example

    ```
    earth:vmx-openstack rendo$ ./vmx_launch.sh -s lab1 -t 2_nodes_vmx.yaml -e 2_nodes_vmx.env
    Creating stack lab1 ...
    +--------------------------------------+------------+--------------------+---------------------+--------------+
    | id                                   | stack_name | stack_status       | creation_time       | updated_time |
    +--------------------------------------+------------+--------------------+---------------------+--------------+
    | af1d791f-2e72-4765-a639-03fec6debe52 | rendo      | CREATE_COMPLETE    | 2017-05-21T17:46:18 | None         |
    | c36ec95c-c2de-4ff6-a577-8b300bfd95ae | lab1       | CREATE_IN_PROGRESS | 2017-05-21T20:36:13 | None         |
    +--------------------------------------+------------+--------------------+---------------------+--------------+


    wait until the stack creation is completed ...
    stack lab1 creation is not finished within 0 seconds, wait another 10 seconds...
    stack lab1 creation is not finished within 10 seconds, wait another 10 seconds...
    stack lab1 creation is not finished within 20 seconds, wait another 10 seconds...
    stack lab1 created in 30 seconds


    For Contrail: Set all internal virtual network to be L2 only ...
    For Contrail: Set all internal virtual network to be L2 only ...
    Updating lab1-net_dummy ...
    http://192.168.1.19:8082/virtual-network/bf291fb8-3bee-4ace-873d-1b87c2dcc698
    {
        "forwarding_mode": "l2",
        "allow_transit": true,
        "mirror_destination": false,
        "rpf": "disable"
    }
    Updating lab1-net_dummy_101 ...
    http://192.168.1.19:8082/virtual-network/f7194b86-1959-407e-952f-eb2d019bf1b8
    {
        "forwarding_mode": "l2",
        "allow_transit": true,
        "mirror_destination": false,
        "rpf": "disable"
    }
    Updating lab1-net_dummy_102 ...
    http://192.168.1.19:8082/virtual-network/5ae17f7c-a6c0-4d2f-bcee-841e622589e4
    {
        "forwarding_mode": "l2",
        "allow_transit": true,
        "mirror_destination": false,
        "rpf": "disable"
    }
    Updating lab1-vmx101_fab_net ...
    http://192.168.1.19:8082/virtual-network/bcba98d6-6a6f-437b-ba6a-e8315ce369f4
    {
        "forwarding_mode": "l2",
        "allow_transit": true,
        "mirror_destination": false,
        "rpf": "disable"
    }
    Updating lab1-vmx101_pfe_net ...
    http://192.168.1.19:8082/virtual-network/ff1d2f9e-ae8b-42a0-a8b3-f90d72abbfb0
    {
        "forwarding_mode": "l2",
        "allow_transit": true,
        "mirror_destination": false,
        "rpf": "disable"
    }
    Updating lab1-vmx102_fab_net ...
    http://192.168.1.19:8082/virtual-network/c17d8ca5-47a4-4896-98f4-f09957633230
    {
        "forwarding_mode": "l2",
        "allow_transit": true,
        "mirror_destination": false,
        "rpf": "disable"
    }
    Updating lab1-vmx102_pfe_net ...
    http://192.168.1.19:8082/virtual-network/133b8ab1-6bae-4d1f-92c4-d3666b45db0a
    {
        "forwarding_mode": "l2",
        "allow_transit": true,
        "mirror_destination": false,
        "rpf": "disable"
    }


    List of vMX IP:
    vmx101_fpc_port_0 : 100.64.1.11
    vmx101_re_port_0 : 100.64.1.14
    vmx102_fpc_port_0 : 100.64.1.12
    vmx102_re_port_0 : 100.64.1.13
    ```

* wait for few minutes
    * FPC will up pretty quickly
    * But, RE will take sometime to boot and apply the default config that pushed thru config-drive.

* try to ssh to each vmx

```
earth:vmx-openstack rendo$ ssh admin@100.64.1.14
Warning: Permanently added '100.64.1.14' (ECDSA) to the list of known hosts.
Password:
--- JUNOS 17.1R1.8 Kernel 64-bit  JNPR-10.3-20170209.344539_build
admin@vmx01> show chassis hardware
Hardware inventory:
Item             Version  Part number  Serial number     Description
Chassis                                VM5921FC5E1F      VMX
Midplane
Routing Engine 0                                         RE-VMX
CB 0                                                     VMX SCB
CB 1                                                     VMX SCB
FPC 0                                                    Virtual FPC
  CPU            Rev. 1.0 RIOT         123XYZ987
  MIC 0                                                  Virtual
    PIC 0                 BUILTIN      BUILTIN           Virtual

```

## Troubleshooting

* if stack creation is completed but RE image is not pingable. Check the booting status

    ```
    # nova console-log <instance name>

    example:
    # nova console-log lab1-vmx101_re
    ```

## default credentials

* user: admin
* password: juniper1


## Todo

* add more templates

