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

Run RandRW IOPS In Preliminaries
  [Tags]    preliminaries
  [Template]    Run fio in parallel
  # iotype  iodepth         bs      num_procs   sort_field  clients
  randrw        1           4k      1           iops        ${CEPH_CLIENTS}[0]
  randrw        8           4k      1           iops        ${CEPH_CLIENTS}[0]
  randrw        16          4k      1           iops        ${CEPH_CLIENTS}[0]
  randrw        32          4k      1           iops        ${CEPH_CLIENTS}[0]
  randrw        64          4k      1           iops        ${CEPH_CLIENTS}[0]
  randrw       128          4k      1           iops        ${CEPH_CLIENTS}[0]

Who is the top RandRW IOPS performer
  [Tags]         top
  ${iodepth}  ${bs} =   Get top performer
  ...   randrw    ${CEPH_CLIENTS}[0]  ${JSON_DIR}   iops
  Log   randrw-${iodepth}-${bs} wins!!!     console=True
  Set Suite Variable    ${iodepth}
  Set Suite Variable    ${bs}

Run RandRW IOPS In Finals
  [Tags]    finals
  [Template]    Run fio in parallel
  # iotype  iodepth          bs      num_procs  sort_field  clients
  randrw       ${iodepth}    ${bs}    1         iops        @{CEPH_CLIENTS}
  randrw       ${iodepth}    ${bs}    2         iops        @{CEPH_CLIENTS}
  randrw       ${iodepth}    ${bs}    3         iops        @{CEPH_CLIENTS}
  randrw       ${iodepth}    ${bs}    4         iops        @{CEPH_CLIENTS}
  randrw       ${iodepth}    ${bs}    5         iops        @{CEPH_CLIENTS}

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
