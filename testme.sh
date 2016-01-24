#!/bin/bash

function check_demo {
  count=0
  while true; do
    heat stack-list | egrep -q "COMPLETE"
    if [ $? -eq 0 ]; then
       echo "Demo Started. Run the Verify option of this demo to see what was provisioned"
       break
    fi
    heat stack-list | egrep -q "FAILED"
    if [ $? -eq 0 ]; then
       echo "Demo Failed to Start. Use heat resource-list [STACK NAME]\" to troubleshoot"
       break
    fi
    if [[ "$count" == "20" ]]; then
      echo "Something is wrong with the Demo it took 60 seconds to run. That's too long."
      break
    fi
    sleep 3
    count=$((count + 1))
  done
}

for i in {1..1}
do
  heat stack-create \
-f new_tenant_with_single_subnet_part1.yaml \
-P "demo_project_name=demoproject${i};\
demo_project_user=demouser${i};\
demo_user_role=demorole${i}" \
demo$i-part1

echo ""
echo "* Waiting for the Openstack network to be provisioned"
check_demo
 
# store current auth settings
OLD_PS1=${PS1}
OLD_OS_USERNAME=${OS_USERNAME}
OLD_TENANT_NAME=${OS_TENANT_NAME}

echo "* Log in as the demouser${i} in order to create servers"
# use new ones to start the servers
export OS_USERNAME=demouser${i}
export OS_TENANT_NAME=demoproject${i}

heat stack-create \
-f new_tenant_with_single_subnet_part2.yaml \
-e params_new_tenant.yaml \
-P "demo_net_name=demonet${i};\
demo_net_gateway=10.100.${i}.1;\
demo_net_cidr=10.100.${i}.0/24;\
demo_net_pool_start=10.100.${i}.10;\
demo_net_pool_end=10.100.${i}.100;\
demo_key_name=demo_key_$i;\
demo_server1_name=server1_project${i};\
demo_server2_name=server2_project${i}" \
demo$i-part2

echo ""
echo "* Waiting for Servers to be deployed"
check_demo

#echo "* Return openstack auth settings back to the ${OLD_OS_USERNAME} user"
#return back to old settings
export OS_USERNAME=${OLD_OS_USERNAME}
export OS_TENANT_NAME=${OLD_TENANT_NAME}


done
