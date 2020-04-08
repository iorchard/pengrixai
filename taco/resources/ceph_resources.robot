*** Settings ***
Library             SSHLibrary

*** Variables ***
# ceph disk io test variables
@{CEPH_CLIENTS}         compute-006     compute-007     compute-008
...                     compute-009     compute-010
${CEPH_CLIENT_TYPE}     node
${CEPH_CLIENT_SSHPORT}   22
${UID}                  clex
${SSHKEY}               /home/jijisa/.ssh/id_rsa
${JSON_DIR}             ${OUTPUT DIR}
${LATENCY_TARGET}       500ms
${LATENCY_WINDOW}       5s
${LATENCY_PERCENTILE}   100.0
${IMAGE_PREFIX}         image

*** Keywords ***
Verify ceph client
  FOR   ${client}    IN  @{CEPH_CLIENTS}
    SSHLibrary.Open Connection    ${client}   port=${CEPH_CLIENT_SSHPORT}
    ...                           timeout=3s    alias=ssh-${client}
    SSHLibrary.Login With Public Key     ${UID}  ${SSHKEY}
    ${rc} =   Set Variable    0
    ${rc} =   Run Keyword If    "${CEPH_CLIENT_TYPE}" == 'node'
    ...       SSHLibrary.Execute Command   ceph --version   return_stdout=False
    ...           return_rc=True
    Run Keyword If    $rc is not None   Should Be Equal As Integers   ${rc}  0
    ${rc} =   SSHLibrary.Execute Command   fio --version   return_stdout=False
    ...           return_rc=True
    Should Be Equal As Integers   ${rc}   0
  END

  ${rc} =   Run And Return Rc   ls -ld ${JSON_DIR}
  Run Keyword If    ${rc} != 0      Create Directory    ${JSON_DIR}

Create fio file
  [Arguments]   ${iotype}   ${iodepth}     ${bs}   ${num_procs}     ${client}
  ...           ${start}    ${end}
  FOR   ${i}    IN RANGE    ${start}      ${end}
    ${no} =      Evaluate    f'{${i}:03}'
    ${rc} =   Run And Return Rc   sed -e 's/NO/${no}/;s/IOTYPE/${iotype}/g;s/IODEPTH/${iodepth}/g;s/BS/${bs}/g;s/NUM_PROCS/${num_procs}/g' fio/node.tpl >> fio/${iotype}_${iodepth}_${bs}_${num_procs}_${client}.fio
    Should Be Equal As Integers     ${rc}   0
  
    # Put fio file on ceph client
    SSHLibrary.Switch Connection   ssh-${client}
    SSHLibrary.Put File
    ...   fio/${iotype}_${iodepth}_${bs}_${num_procs}_${client}.fio
    ...   ./
    ...   mode=0600
  END

Run fio in parallel
  [Arguments]   ${iotype}   ${iodepth}     ${bs}  ${num_procs}  ${sort_field}
  Log   Run fio in parallel ${iotype}_${iodepth}_${bs}_${num_procs}
  ...   console=True

  ${start} =    Set Variable    0
  ${end} =      Set Variable    ${num_procs}
  FOR   ${client}    IN     @{CEPH_CLIENTS}
    # Create fio file
    ${rc} =     Run And Return Rc   cat fio/global.tpl > fio/${iotype}_${iodepth}_${bs}_${num_procs}_${client}.fio
    Should Be Equal As Integers     ${rc}   0
    Create fio file     ${iotype}   ${iodepth}      ${bs}   ${num_procs}
    ...                 ${client}   ${start}        ${end}

    # Run drop caches if VM test
    ${rc} =   Run Keyword If    "${CEPH_CLIENT_TYPE}" == 'vm'
    ...   SSHLibrary.Execute Command
    ...   echo 3 |sudo tee /proc/sys/vm/drop_caches
    ...   return_stdout=False     return_rc=True
    Run Keyword If   $rc is not None   Should Be Equal As Integers   ${rc}   0
  
    ${start} =      Evaluate    ${start}+${num_procs}
    ${end} =        Evaluate    ${end}+${num_procs}
  END

  # Run fio on ceph clients
  ${start} =    Set Variable    0
  ${end} =      Set Variable    ${num_procs}
  FOR   ${client}    IN     @{CEPH_CLIENTS}
    Log     
    ...   Run fio ${iotype}_${iodepth}_${bs}_${num_procs}_${client}
    ...   console=True

    SSHLibrary.Switch Connection   ssh-${client}
    SSHLibrary.Start Command
    ...     fio --output=${iotype}_${iodepth}_${bs}_${num_procs}_${client}.json --output-format=json ${iotype}_${iodepth}_${bs}_${num_procs}_${client}.fio
    ...     sudo=True
  END

  # Sleep for 3 minutes.
  Sleep     3m

  # Get output json file on ceph clients
  FOR   ${client}    IN     @{CEPH_CLIENTS}
    SSHLibrary.Switch Connection   ssh-${client}
    SSHLibrary.Get File
    ...   ${iotype}_${iodepth}_${bs}_${num_procs}_${client}.json
    ...   ${JSON_DIR}/
  END
 
  # Create ${iotype}_${iodepth}_${bs}_${num_procs}.txt
  ${sum_iops}   ${sum_bw}   ${avg_lat}  ${max_lat}  ${min_lat} =
  ...   Sum fio data    ${iotype}   ${iodepth}  ${bs}   ${num_procs}
  ...   ${JSON_DIR}     ${sort_field}
  Log   SUM: iops=${sum_iops}, bw=${sum_bw} kB/s    console=True
  Log   Average Latency (us): ${avg_lat}            console=True
  Log   Max Latency (us): ${max_lat}                console=True
  Log   Min Latency (us): ${min_lat}                console=True

