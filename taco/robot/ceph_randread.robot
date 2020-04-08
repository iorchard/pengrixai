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

Run Randread IOPS
  [Tags]    run
  [Template]    Run fio in parallel
  # iotype  iodepth          bs      num_procs  sort_field
  randread     32            4k      20         iops
  randread     32            4k      30         iops
  randread     32            4k      40         iops
  randread     32            4k      50         iops
  randread     32            4k      60         iops

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
