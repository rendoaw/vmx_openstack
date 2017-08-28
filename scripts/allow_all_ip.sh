#!/bin/bash 

stack_name=$1

for i in `heat resource-list $stack_name | grep "::Port"  | awk '{print $4}'`; do
    echo $i
    neutron port-update ${i} --allowed-address-pairs type=dict list=true ip_address="0.0.0.0/0"
done

