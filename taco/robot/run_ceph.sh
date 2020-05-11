#!/bin/bash

# Write
robot -d output/stage/1replica/ceph-write/preliminaries -i preliminaries ceph_write.robot
cp output/stage/1replica/ceph-write/preliminaries/*.json output/stage/1replica/ceph-write/
robot -d output/stage/1replica/ceph-write -i top -i finals ceph_write.robot

# Read
robot -d output/stage/1replica/ceph-read/preliminaries -i preliminaries ceph_read.robot
cp output/stage/1replica/ceph-read/preliminaries/*.json output/stage/1replica/ceph-read/
robot -d output/stage/1replica/ceph-read -i top -i finals ceph_read.robot

## Random Write
robot -d output/stage/1replica/ceph-randwrite/preliminaries -i preliminaries ceph_randwrite.robot
cp output/stage/1replica/ceph-randwrite/preliminaries/*.json output/stage/1replica/ceph-randwrite/
robot -d output/stage/1replica/ceph-randwrite -i top -i finals ceph_randwrite.robot

## Random Read
robot -d output/stage/1replica/ceph-randread/preliminaries -i preliminaries ceph_randread.robot
cp output/stage/1replica/ceph-randread/preliminaries/*.json output/stage/1replica/ceph-randread/
robot -d output/stage/1replica/ceph-randread -i top -i finals ceph_randread.robot

## Random RW
robot -d output/stage/1replica/ceph-randrw/preliminaries -i preliminaries ceph_randrw.robot
cp output/stage/1replica/ceph-randrw/preliminaries/*.json output/stage/1replica/ceph-randrw/
robot -d output/stage/1replica/ceph-randrw -i top -i finals ceph_randrw.robot

