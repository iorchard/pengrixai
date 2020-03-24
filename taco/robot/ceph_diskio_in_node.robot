*** Settings ***
Suite Setup         Check if fio server is running  ${PERF_NODE}

Resource            ../resources/common_resources.robot
Resource            ../resources/monitor_keywords.robot
Resource            ../resources/ceph_resources.robot

Library             SSHLibrary

*** Test Cases ***
Disk IO In Node
  Given Pre Process
  When Run fio in Node
  Then Post Process     output/ceph-diskio-in-node

*** Keywords ***
Pre Process
  Preflight
  Clean dstat log   kanif_ceph.conf
  ${handle} =       Start kanif process     kanif_ceph.conf
  Set Suite Variable    ${handle}
  SSHLibrary.Open Connection       ${PERF_NODE}    timeout=5s
  Wait Until Keyword Succeeds        1 min    3 sec
  ...    SSHLibrary.Login With Public Key    ${UID}    ${SSHKEY}

Post Process
  [Arguments]   ${dstat_outputdir}
  SSHLibrary.Get File   ${PERF_NODE}.json   fio/${PERF_NODE}.json
  SSHLibrary.Close Connection
  Log       Sleep for 60 seconds     console=True
  Sleep     60s     Collecting resource usage
  Repeat Keyword    2 times     Kill kanif process  ${handle}
  Get dstat log     ${dstat_outputdir}    kanif_ceph.conf
