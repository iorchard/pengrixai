#!/bin/bash

header="%-12s\t%-15s\t%-10s\t%-16s"
for j in *.json
do
    echo "***$j***"
    # read or write
    if [[ $j == *"-read-"* ]]
    then 
        k="read"
    else
        k="write"
    fi
    echo $k
    printf "$header\n" "Name" "$k BW(KB/s)" "$k IOPS" "mean latency(ns)"
    # use jq's variable interpolation and passing bash variable to jp filter.
    jq -r --arg K "$k" '.jobs[] | "\(.jobname)\t\(.[$K].bw)\t\t\(.[$K].iops)\t\(.[$K].lat_ns.mean)"' $j
    echo
done
