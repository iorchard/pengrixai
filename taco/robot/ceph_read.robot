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

Run Read IOPS
  [Tags]    run
  [Template]    Run fio in parallel
  # iotype  iodepth       bs      num_procs  sort_field
#  read      16            4m      1          bw
#  read      16            4m      5          bw
#  read      16            4m     10          bw
#  read      16            4m     20          bw
  read      32            4m     30          bw
  read      32            4m     40          bw
  read      32            4m     50          bw
  read      32            4m     60          bw

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
