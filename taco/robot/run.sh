#!/bin/bash

for n in 100 150 200
do
    echo $n
    # create-n-start
    robot -d output/bmt/create-n-start-${n}-vms -v NUM_SERVERS:${n} create_servers_with_port_volume.robot
    sleep 60
    
    # stop
    robot -d output/bmt/stop-${n}-vms -v NUM_SERVERS:${n} stop_servers.robot
    sleep 60
    
    # start
    robot -d output/bmt/start-${n}-vms -v NUM_SERVERS:${n} start_servers.robot
    sleep 60
    
    # delete
    robot -d output/bmt/delete-${n}-vms -v NUM_SERVERS:${n} delete_servers.robot
    sleep 60
done
