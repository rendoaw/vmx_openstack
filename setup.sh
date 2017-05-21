#!/bin/bash

# based on https://github.com/Juniper/vmx-heat-templates

${NOVA} quota-class-update --cores 100 default 
${NOVA} quota-class-update --ram 102400 default 
${NOVA} quota-class-update --instances 100 default

${NOVA} flavor-create --is-public true re-flv auto 2048 40 2
${NOVA} flavor-key  re-flv set  aggregate_instance_extra_specs:global-grouppinned=true
${NOVA} flavor-key  re-flv set hw:cpu_policy=dedicated
${NOVA} aggregate-create global-group
${NOVA} aggregate-set-metadata global-group global-grouppinned=true
${NOVA} aggregate-add-host  global-group compute01
${NOVA} flavor-create --is-public true pfe-flv-lite auto 4096 40 4
${NOVA} flavor-key  pfe-flv-lite set  aggregate_instance_extra_specs:global-grouppinned=true
${NOVA} flavor-key  pfe-flv-lite set hw:cpu_policy=dedicated
${NOVA} flavor-key  pfe-flv-lite set hw:mem_page_size=2048

cp openstackrc-sample openstackrc

git clone https://github.com/rendoaw/ocsc.git


