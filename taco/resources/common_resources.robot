*** Settings ***
Library             OperatingSystem
Library             Collections
Library             String
Library             Process
Library             Telnet

*** Variables ***
# path relative robot file where gabbi test files are located
${GABBIT_PATH}          ../gabbits
${NUM_SERVERS}          10
${DATA_DIR}             ./data
${DATA_FILE}            server_id.txt
${PORT_FILE}            port_id.txt
${MON_OUTPUT_DIR}       ../monitor/output

*** Keywords ***
Preflight
  ${rc} =   Run And Return Rc   ls -ld ${DATA_DIR}
  Run Keyword If    ${rc} != 0      Create Directory    ${DATA_DIR}

  ${rc} =   Run And Return Rc   ls -ld ${MON_OUTPUT_DIR}
  Run Keyword If    ${rc} != 0      Create Directory    ${MON_OUTPUT_DIR}
