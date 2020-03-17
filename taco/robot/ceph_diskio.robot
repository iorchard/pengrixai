*** Settings ***
Suite Setup         Check if fio servers are running

Resource            ../resources/common_resources.robot
Resource            ../resources/ceph_keywords.robot

*** Test Cases ***
Pre Process
  [Setup]   Preflight
  Clean dstat log
  ${handle} =       Start kanif process     kanif_ceph.conf
  Set Suite Variable    ${handle}

Run Disk IO
  Given Warmup fio
  When Run fio

Post Process
  Clean the ports
  ${sleep} =    Convert To Integer  ${NUM_SERVERS}
  Log       ${sleep * 1}s     console=True
  Sleep     ${sleep * 1}s     Collecting resource usage
  [Teardown]    Stop Monitor    ${handle}

*** Keywords ***
Stop Monitor
  [Arguments]    ${handle}
  Repeat Keyword    2 times     Kill kanif process  ${handle}
  Get dstat log     output/delete-${NUM_SERVERS}-vms
