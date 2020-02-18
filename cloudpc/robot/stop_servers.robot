*** Settings ***
Suite Setup         Preflight
Resource            ../resources/common_resources.robot
Resource            ../resources/cloudpc_settings.robot

Resource            ../resources/api_keywords.robot
Resource            ../resources/monitor_keywords.robot

Library             GabbiLibrary  ${API_SERVICE}
...                               ${GABBIT_PATH}

*** Test Cases ***
Pre Process
  Clean dstat log
  ${handle} =       Start kanif process
  Set Suite Variable    ${handle}

Stop Servers
  Given Api service is available
  When User stops server
  Then Server is shutoff

Post Process
  ${sleep} =    Convert To Integer  ${NUM_SERVERS}
  Log       ${sleep * 1}s     console=True
  Sleep     ${sleep * 1}s     Collecting resource usage
  [Teardown]    Stop Monitor    ${handle}

*** Keywords ***
Stop Monitor
  [Arguments]    ${handle}
  Repeat Keyword    2 times     Kill kanif process  ${handle}
  Get dstat log     output/stop-${NUM_SERVERS}-vms
