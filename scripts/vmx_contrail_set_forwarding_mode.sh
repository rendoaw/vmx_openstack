#!/bin/bash

. openstackrc 

stack_name=$1
echo "For Contrail: Set all internal virtual network to be L2 only ..."
for i in `${HEAT} resource-list --nested-depth 10  ${stack_name} | grep "OS::Neutron::Net" | awk '{print $2}'`; do
    echo "Updating ${stack_name}-${i} ..."
    ${OCSC} --contrail-set-mode l2 --contrail-vnet-name ${stack_name}-$i
done


