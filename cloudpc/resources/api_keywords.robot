*** Keywords ***
Api service is available
  get vm list   PROJECT_ID=${PROJECT_ID}

Get server id file
  ${rc}     ${output} =      Run And Return Rc and Output
  ...                           cat ${DATA_DIR}/${DATA_FILE}
  Should Be Equal As Integers   ${rc}    0
  [Return]  ${output}

User creates server
  ${hostno} =   Get Length  ${HOSTS}
  ${netno} =    Get Length  ${PRIVATE_NETWORKS}
  FOR   ${i}    IN RANGE    0   ${NUM_SERVERS}
    ${a} =      Evaluate    ${i}%${hostno}
    ${b} =      Evaluate    ${i}%${netno}
    ${no} =     Evaluate    f'{${i}:03}'
    Log   Create ${SERVER_NAME}-${no}   console=True
    create server
    ...                 SERVER_NAME=${SERVER_NAME}-${no}
    ...                 IMAGE_REF=${IMAGE_REF}
    ...                 FLAVOR_REF=${FLAVOR_REF}
    ...                 HOST=${HOSTS}[${a}]
    ...                 NETWORK_REF=${PRIVATE_NETWORKS}[${b}]
    ...                 ZONE=${ZONE}
    ...                 PROJECT_ID=${PROJECT_ID}
    ...                 VOL_TYPE=${VOL_TYPE}
  END
  # Get server ids after there are ${NUM_SERVERS} servers
  Wait Until Keyword Succeeds   1 hour  5s
  ...   verify number of servers
  ...   PROJECT_ID=${PROJECT_ID}    NUM_SERVERS=${NUM_SERVERS}
  &{RESP} =     collect server id   PROJECT_ID=${PROJECT_ID}
  ${rc} =   Run And Return Rc
  ...   echo ${RESP.server_id_list} |tr -d '[' |tr -d ']' | tr -d ' ' |tr ',' ' ' |tee ${DATA_DIR}/${DATA_FILE}
  Should Be Equal As Integers   ${rc}    0

Server has been created
  ${output} =   Get server id file
  
  @{list} =     Split String     ${output}
  FOR   ${i}    IN RANGE    0   ${NUM_SERVERS}
    ${no} =     Evaluate    f'{${i}:03}'
    verify server name  SERVER_ID=${list}[${no}]
    ...                 SERVER_NAME=${SERVER_NAME}-${no}
    ...                 PROJECT_ID=${PROJECT_ID}
  END

Server is active
  ${output} =   Get server id file
  
  @{list} =     Split String     ${output}
  FOR   ${id}    IN     @{list}
    Wait Until Keyword Succeeds   1 hour     500ms
    ...                     check server status is active
    ...                         SERVER_ID=${id}
    ...                         PROJECT_ID=${PROJECT_ID}
  END

User stops server
  ${output} =   Get server id file

  @{list} =     Split String     ${output}
  FOR   ${id}    IN     @{list}
    Log     stop ${id}   console=True
    stop server     SERVER_ID=${id}     PROJECT_ID=${PROJECT_ID}
  END

Server is shutoff
  ${output} =   Get server id file

  @{list} =     Split String     ${output}
  FOR   ${id}    IN     @{list}
    Wait Until Keyword Succeeds   1 hour     500ms
    ...                     check server status is shutoff
    ...                         SERVER_ID=${id}     PROJECT_ID=${PROJECT_ID}
  END

User starts server
  ${output} =   Get server id file

  @{list} =     Split String     ${output}
  FOR   ${id}    IN     @{list}
    Log     start ${id}       console=True
    start server     SERVER_ID=${id}    PROJECT_ID=${PROJECT_ID}
  END

User deletes server
  ${output} =   Get server id file

  @{list} =     Split String     ${output}
  FOR   ${id}   IN  @{list}
    Log     delete ${id}       console=True
    delete server   SERVER_ID=${id}     PROJECT_ID=${PROJECT_ID}
  END

Server is not found
  ${output} =   Get server id file
  
  @{list} =     Split String     ${output}
  FOR   ${id}    IN     @{list}
    Wait Until Keyword Succeeds   1 hour     1s
    ...                     check server is not found
    ...                         SERVER_ID=${id}
    ...                         PROJECT_ID=${PROJECT_ID}
  END
