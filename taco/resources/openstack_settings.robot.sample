*** Variables ***

#### TACO OpenStack General settings ####
#${BASE_URL}             http://keystone.openstack.svc.cluster.local:8080
${COMPUTE_SERVICE}      http://nova.openstack.svc.cluster.local:8080/v2.1
${KEYSTONE_SERVICE}     http://keystone.openstack.svc.cluster.local:8080/v3
${NEUTRON_SERVICE}      http://neutron.openstack.svc.cluster.local:8080
${CINDER_SERVICE}      http://cinder.openstack.svc.cluster.local:8080/v3

${USER_NAME}            admin
${USER_PASSWORD}        <admin-password>
${DOMAIN_NAME}          default
${PROJECT_NAME}         admin

#### Settings for common test cases ####
# windows10_pro_64bit_r01
${IMAGE_REF}        0c324442-e612-4709-a3b0-82ca9e45c5d4

#### Settings for Cinder volume test cases ####
# admin project id
${PROJECT_ID}		04fc98f991574532bc9f6e241d3111a3
# volume size in GiB
${VOL_SIZE}			50
# volume type: rbd1 or nfs1
${VOL_TYPE}			rbd1

#### Settings for Nova test cases ####
${SERVER_NAME}      taco-server

# tiny_spec 2C/4G/50G
${FLAVOR_REF}       db82b528-a86f-41a3-96d0-6a130aa787c0

# public-net
${PUBLIC_NETWORK}   ba3ca2e2-1445-42ad-be54-aceba67ebb81

# jijisa-network. jijisa-subnet is 10.5.0.0/16
${PRIVATE_NETWORK}  bc86860c-1064-4b0e-9e4d-bdcb19f758fc

${ZONE}             nova
@{HOSTS}            <host1>   <host2>   <host3>
