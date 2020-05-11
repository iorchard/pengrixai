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


Run Write BW In Preliminaries
  [Tags]    preliminaries
  [Template]    Run fio in parallel
  # iotype  iodepth      bs      num_procs   sort_field  clients
  write      1           4m      1           bw          ${CEPH_CLIENTS}[0]
  write      8           4m      1           bw          ${CEPH_CLIENTS}[0]
  write      16          4m      1           bw          ${CEPH_CLIENTS}[0]
  write      32          4m      1           bw          ${CEPH_CLIENTS}[0]
  write      64          4m      1           bw          ${CEPH_CLIENTS}[0]
  write     128          4m      1           bw          ${CEPH_CLIENTS}[0]

Who is the top Write BW performer
  [Tags]     top
  ${iodepth}  ${bs} =   Get top performer
  ...   write    ${CEPH_CLIENTS}[0]  ${JSON_DIR}   bw
  Log   write-${iodepth}-${bs} wins!!!     console=True
  Set Suite Variable    ${iodepth}
  Set Suite Variable    ${bs}

Run Write BW in Finals
  [Tags]    finals
  [Template]    Run fio in parallel
  # iotype  iodepth         bs      num_procs   sort_field    clients
  write     ${iodepth}      ${bs}   1          bw            @{CEPH_CLIENTS}
  write     ${iodepth}      ${bs}   2          bw            @{CEPH_CLIENTS}
  write     ${iodepth}      ${bs}   3          bw            @{CEPH_CLIENTS}
  write     ${iodepth}      ${bs}   4          bw            @{CEPH_CLIENTS}
  write     ${iodepth}      ${bs}   5          bw            @{CEPH_CLIENTS}

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
