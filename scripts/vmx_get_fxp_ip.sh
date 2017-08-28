#!/bin/bash

stack_name=$1
IFS=$'\n'

for i in `${HEAT} resource-list --nested-depth 10  ${stack_name} 2> /dev/null | grep "OS::Neutron::Port" | egrep "port_0|port_fxp"  | grep -v fpc_port_0`; do 
    port_name=`echo $i | awk '{print $2}'`
    port_uuid=`echo $i | awk '{print $4}'`
    ip=`${NEUTRON} port-show ${port_uuid} -f json 2> /dev/null 2> /dev/null | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["fixed_ips"][0]["ip_address"]'`
    echo "${port_name} : ${ip}"
done



