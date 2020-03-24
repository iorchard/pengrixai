*** Settings ***
Library             SSHLibrary

*** Variables ***
# ceph disk io test variables
${PERF_VM}              perf-target
${PERF_NODE}            control-001
${FIO_SERVER_SSHPORT}      22
${UID}                  clex
${SSHKEY}               /home/jijisa/.ssh/id_rsa

*** Keywords ***
Check if fio server is running
  [Arguments]   ${server}
  SSHLibrary.Open Connection    ${server}   port=${FIO_SERVER_SSHPORT}
  ...                           timeout=3s
  SSHLibrary.Login With Public Key     ${UID}  ${SSHKEY}
  ${rc} =   SSHLibrary.Execute Command   fio --version     return_stdout=False
  ...           return_rc=True
  Should Be Equal As Integers   ${rc}   0
  SSHLibrary.Close Connection

Run fio in VM
  Log   Run fio for ${PERF_VM}    console=True
  SSHLibrary.Put File  fio/vm.fio    ./  mode=0600
  SSHLibrary.Execute Command   sudo fio --output=${PERF_VM}.json --output-format=json vm.fio

Run fio in Node
  Log   Run fio for ${PERF_NODE}    console=True
  SSHLibrary.Put File  fio/node.fio    ./  mode=0600
  SSHLibrary.Execute Command   sudo fio --output=${PERF_NODE}.json --output-format=json node.fio

