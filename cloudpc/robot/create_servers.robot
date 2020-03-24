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
  Remove File   ${DATA_DIR}/${DATA_FILE}

Create and Start Servers
  Given Api service is available
  When User creates server
  Then Server has been created
       and Server is active

Post Process
  ${sleep} =    Convert To Integer  ${NUM_SERVERS}
  Log       ${sleep * 1}s     console=True
  Sleep     ${sleep * 1}s     Collecting resource usage
  [Teardown]    Stop Monitor    ${handle}

*** Keywords ***
Stop Monitor
  [Arguments]    ${handle}
  Repeat Keyword    2 times     Kill kanif process  ${handle}
  Get dstat log     output/create-n-start-${NUM_SERVERS}-vms
