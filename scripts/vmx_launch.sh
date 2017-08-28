#!/bin/bash

while [[ $# > 0 ]]; do
    key="$1"
    case $key in
        -t)
        template_file="$2"
        shift # past argument
        ;;
        -e)
        env_file="$2"
        shift # past argument
        ;;
        -s)
        stack_name="$2"
        shift # past argument
        ;;
        *)
                # unknown option
        ;;
    esac
    shift # past argument or value
done



if [ "X$env_file" == "X" ]; then
	echo "usage: $0 -s <stack_name> -t <template file> -e <env file>"
    exit 1
fi


echo
echo " Remove existing stack with the same name (if any)"
echo

#delete old stack if any
if [[ "${yes}" -ne 1 ]]; then
    ${HEAT} stack-list | grep -w "${stack_name}"  > /dev/null
    ret=$?
    if [ $ret = 0 ];then
        echo "WARNING: found existing stack name: $stack_name"
        read -p "Delete existing stack and continue (Y/N)? " ans
        if [ "$ans" != "Y" ] && [ "$ans" != "y" ]; then
            echo
            echo "Aborted"
            echo
            exit 0
        fi
    fi
fi

${HEAT} stack-delete --yes $stack_name >/dev/null 2> /dev/null
counter=0
sleep $counter
while [ true ]; do
    ${HEAT} stack-list | grep -w "{$stack_name}"  > /dev/null
    ret=$?
    if [ $ret = 0 ];then
        echo "stack delete is not finished within $counter seconds, wait another 10 seconds..."
        counter=`expr $counter + 10`
        sleep 10;
    else
        sleep 30
        break;
    fi
    if [ $counter -gt 300 ];then
        startup_status=0
        echo "ERROR: old stack is not deleted within 300 seconds, exit"
        echo
    exit 1
    fi
done



echo
echo "Creating stack ${stack_name} ..."
${HEAT} stack-create -f $template_file -e $env_file $stack_name

echo
echo
echo "wait until the stack creation is completed ..."
counter=0
sleep $counter
while [ true ]; do
    ${HEAT} stack-show ${stack_name} | grep CREATE_COMPLETE > /dev/null
    ret=$?
    if [ $ret -gt 0 ];then
        ${HEAT} stack-show ${stack_name} | grep -i FAILED > /dev/null
        ret=$?
        if [ $ret -eq 0 ];then
            echo "stack ${stack_name} creation is failed."
            exit 13
        fi
        echo "stack ${stack_name} creation is not finished within $counter seconds, wait another 10 seconds..."
        counter=`expr $counter + 10`
        sleep 10;
    else
        echo "stack ${stack_name} created in $counter seconds"
        break;
    fi
    if [ $counter -gt 300 ];then
        startup_status=0
        echo "ERROR: stack ${stack_name} is not created within 300 seconds, exit"
        echo
        exit 12
    fi
done


echo
echo
echo "For Contrail: Set all internal virtual network to be L2 only ..."
./vmx_contrail_set_forwarding_mode.sh ${stack_name}

echo
echo
echo "List of vMX IP:"
./vmx_get_fxp_ip.sh ${stack_name}




