#!/bin/bash

logs=(osd_min_pg_log_entries osd_max_pg_log_entries osd_pg_log_dups_tracked osd_pg_log_trim_min)

echo "sudo ceph tell osd.* config set osd_min_pg_log_entries 1500"
sudo ceph tell osd.* config set osd_min_pg_log_entries 1500

echo "sudo ceph tell osd.* config set osd_max_pg_log_entries 10000"
sudo ceph tell osd.* config set osd_max_pg_log_entries 10000

echo "sudo ceph tell osd.* config set osd_pg_log_dups_tracked 3000"
sudo ceph tell osd.* config set osd_pg_log_dups_tracked 3000

echo "sudo ceph tell osd.* config set osd_pg_log_trim_min 100"
sudo ceph tell osd.* config set osd_pg_log_trim_min 100
