#!/bin/bash

debugs=(debug_lockdep debug_context debug_crush debug_buffer debug_timer debug_filer debug_objecter debug_rados debug_rbd debug_journaler debug_client debug_osd debug_optracker debug_objclass debug_filestore debug_journal debug_ms debug_monc debug_tp debug_auth debug_finisher debug_heartbeatmap debug_perfcounter debug_asok debug_throttle debug_mon debug_paxos debug_rgw)

for d in ${debugs[@]};do
  echo "sudo ceph tell osd.* config set $d 0/0"
  sudo ceph tell osd.* config set $d 0/0
done

