*** Settings ***
Suite Setup         Verify ceph client
Suite Teardown      SSHLibrary.Close All Connections
Resource            ../resources/common_resources.robot
Resource            ../resources/monitor_keywords.robot
Resource            ../resources/ceph_resources.robot

Library             sum_fio_data.py
Library             top_performer.py
Library             analyze_n_graph.py

*** Test Cases ***
Pre Process
  [Tags]     pre
  [Setup]   Preflight
  Log   Preprocess
  Clean dstat log   kanif_ceph.conf
  Clean fio files   kanif_ceph.conf
  ${handle} =       Start kanif process     kanif_ceph.conf
  Set Suite Variable    ${handle}

Run Randwrite IOPS In Preliminaries
  [Tags]    preliminaries
  [Template]    Run fio in parallel
  # iotype  iodepth         bs      num_procs   sort_field  clients
  randwrite      1           4k      1           iops        ${CEPH_CLIENTS}[0]
  randwrite      8           4k      1           iops        ${CEPH_CLIENTS}[0]
  randwrite      16          4k      1           iops        ${CEPH_CLIENTS}[0]
  randwrite      32          4k      1           iops        ${CEPH_CLIENTS}[0]
  randwrite      64          4k      1           iops        ${CEPH_CLIENTS}[0]
  randwrite     128          4k      1           iops        ${CEPH_CLIENTS}[0]

Who is the top Randwrite IOPS performer
  [Tags]         top
  ${iodepth}  ${bs} =   Get top performer
  ...   randwrite    ${CEPH_CLIENTS}[0]  ${JSON_DIR}   iops
  Log   randwrite-${iodepth}-${bs} wins!!!     console=True
  Set Suite Variable    ${iodepth}
  Set Suite Variable    ${bs}

Run Randwrite IOPS In Finals
  [Tags]    finals
  [Template]    Run fio in parallel
  # iotype  iodepth          bs      num_procs  sort_field  clients
  randwrite    ${iodepth}    ${bs}    1         iops        @{CEPH_CLIENTS}
  randwrite    ${iodepth}    ${bs}    2         iops        @{CEPH_CLIENTS}
  randwrite    ${iodepth}    ${bs}    3         iops        @{CEPH_CLIENTS}
  randwrite    ${iodepth}    ${bs}    4         iops        @{CEPH_CLIENTS}
  randwrite    ${iodepth}    ${bs}    5         iops        @{CEPH_CLIENTS}

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
