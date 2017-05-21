#!/bin/bash

stack_name=$1
IFS=$'\n'

for i in `${HEAT} resource-list --nested-depth 10  ${stack_name} | grep "OS::Neutron::Port" | grep port_0`; do 
    port_name=`echo $i | awk '{print $2}'`
    port_uuid=`echo $i | awk '{print $4}'`
    ip=`${NEUTRON} port-show ${port_uuid} -f json | python -c 'import json,sys;obj=json.load(sys.stdin); fixed_ips=json.loads(obj["fixed_ips"]); print fixed_ips["ip_address"]'`
    echo "${port_name} : ${ip}"
done



