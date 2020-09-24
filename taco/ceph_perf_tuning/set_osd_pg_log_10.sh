#!/bin/bash

logs=(osd_min_pg_log_entries osd_max_pg_log_entries osd_pg_log_dups_tracked osd_pg_log_trim_min)

for l in ${logs[@]};do
  echo "sudo ceph tell osd.* config set $l 10"
  sudo ceph tell osd.* config set $l 10
done

