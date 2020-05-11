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


Run Read BW In Preliminaries
  [Tags]    preliminaries
  [Template]    Run fio in parallel
  # iotype  iodepth      bs      num_procs   sort_field  clients
  read      1            4m      1           iops        ${CEPH_CLIENTS}[0]
  read      8            4m      1           iops        ${CEPH_CLIENTS}[0]
  read      16           4m      1           iops        ${CEPH_CLIENTS}[0]
  read      32           4m      1           iops        ${CEPH_CLIENTS}[0]
  read      64           4m      1           iops        ${CEPH_CLIENTS}[0]
  read     128           4m      1           iops        ${CEPH_CLIENTS}[0]

Who is the top Read BW performer
  [Tags]         top
  ${iodepth}  ${bs} =   Get top performer
  ...   read    ${CEPH_CLIENTS}[0]  ${JSON_DIR}   bw
  Log   read-${iodepth}-${bs} wins!!!     console=True
  Set Suite Variable    ${iodepth}
  Set Suite Variable    ${bs}

Run Read BW in Finals
  [Tags]    finals
  [Template]    Run fio in parallel
  # iotype  iodepth        bs      num_procs  sort_field    clients
  read      ${iodepth}     ${bs}    1         bw            @{CEPH_CLIENTS}
  read      ${iodepth}     ${bs}    2         bw            @{CEPH_CLIENTS}
  read      ${iodepth}     ${bs}    3         bw            @{CEPH_CLIENTS}
  read      ${iodepth}     ${bs}    4         bw            @{CEPH_CLIENTS}
  read      ${iodepth}     ${bs}    5         bw            @{CEPH_CLIENTS}

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
