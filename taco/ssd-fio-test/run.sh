#!/bin/bash

# Check prerequisite - fio and jq

for f in *.fio
do
    # Get test case name
    json=${f/fio/json}
    sudo fio --output=${json} --output-format=json $f
    # Take a rest for 30 seconds
    sleep 30
done

./parse.sh > result.txt
