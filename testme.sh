#!/bin/bash

for i in {1..1}
do
  heat stack-create \
-f new_tenant_with_single_subnet.yaml \
-e params_new_tenant.yaml \
-P "demo_project_name=project${i};\
demo_project_user=demouser${i};\
demo_user_role=demorole${i};\
demo_net_name=demonet${i};\
demo_net_gateway=10.100.${i}.1;\
demo_net_cidr=10.100.${i}.0/24;\
demo_net_pool_start=10.100.${i}.10;\
demo_net_pool_end=10.100.${i}.100;\
demo_key_name=demo_key_$i;\
demo_server1_name=server1_project${i};\
demo_server2_name=server2_project${i}" \
demo_$i
done
