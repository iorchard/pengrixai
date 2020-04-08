*** Settings ***
Suite Setup         Verify ceph client
Suite Teardown      SSHLibrary.Close All Connections
Resource            ../resources/common_resources.robot
Resource            ../resources/monitor_keywords.robot
Resource            ../resources/ceph_resources.robot

Library             sum_fio_data.py
Library             analyze_n_graph.py

*** Test Cases ***
Pre Process
  [Tags]     pre
  [Setup]   Preflight
  Log   Preprocess
  Clean dstat log   kanif_ceph.conf
  ${handle} =       Start kanif process     kanif_ceph.conf
  Set Suite Variable    ${handle}

Run Randwrite IOPS
  [Tags]    run
  [Template]    Run fio in parallel
  # iotype  iodepth          bs      num_procs  sort_field
  randwrite     128            4k      1         iops
  randwrite     128            4k      2         iops
  randwrite     128            4k      3         iops
  randwrite     128            4k      4         iops
  randwrite     128            4k      5         iops
  randwrite     128            4k      6         iops
  randwrite     128            4k      7         iops
  randwrite     128            4k      8         iops
  randwrite     128            4k      9         iops

Post Process
  [Tags]     post
  Log       Sleep for 30 seconds     console=True
  Sleep     30s     Collecting resource usage
  [Teardown]    Stop Monitor    ${handle}

*** Keywords ***
Stop Monitor
  [Arguments]   ${handle}
  Repeat Keyword    2 times     Kill kanif process  ${handle}
  Get dstat log     ${OUTPUT_DIR}    kanif_ceph.conf
