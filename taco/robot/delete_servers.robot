*** Settings ***
Suite Setup         User gets auth token

Resource            ../resources/common_resources.robot
Resource            ../resources/openstack_settings.robot

Resource            ../resources/identity_keywords.robot
Resource            ../resources/compute_keywords.robot
Resource            ../resources/network_keywords.robot
Resource            ../resources/volume_keywords.robot
Resource            ../resources/monitor_keywords.robot

Library             GabbiLibrary  ${COMPUTE_SERVICE}
...                               ${GABBIT_PATH}

*** Test Cases ***
Pre Process
  [Setup]   Preflight
  Clean dstat log
  ${handle} =       Start kanif process
  Set Suite Variable    ${handle}

Delete Servers
  Given Compute Service is available
  When User deletes server
  Then All servers are gone

Post Process
  Clean the ports
  ${sleep} =    Convert To Integer  ${NUM_SERVERS}
  Log       ${sleep}s     console=True
  Sleep     ${sleep}s     Collecting resource usage
  [Teardown]    Stop Monitor    ${handle}

*** Keywords ***
Stop Monitor
  [Arguments]    ${handle}
  Repeat Keyword    2 times     Kill kanif process  ${handle}
  Get dstat log     output/delete-${NUM_SERVERS}-vms

