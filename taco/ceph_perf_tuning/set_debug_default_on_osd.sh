#!/bin/bash
# You have to run 'sudo ceph-conf -D |grep ^debug_ > debug_orig.txt' first
# to save the default debug settings.
# Then, you run set_debug_0_on_osd.sh and do perf test.
# Run this script to set back to the default debug settings.

debugs=(debug_lockdep debug_context debug_crush debug_buffer debug_timer debug_filer debug_objecter debug_rados debug_rbd debug_journaler debug_client debug_osd debug_optracker debug_objclass debug_filestore debug_journal debug_ms debug_monc debug_tp debug_auth debug_finisher debug_heartbeatmap debug_perfcounter debug_asok debug_throttle debug_mon debug_paxos debug_rgw)

for d in ${debugs[@]};do
  # get value of $d
  val=$(grep "$d " debug_orig.txt|awk '{print $3}')
  echo "sudo ceph tell osd.* config set $d $val"
  sudo ceph tell osd.* config set $d $val
done

