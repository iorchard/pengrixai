*** Keywords ***
Compute service is available
  get compute api versions  COMPUTE_SERVICE=${COMPUTE_SERVICE}

User creates server
  set suite variable    @{server_id}    @{EMPTY}
  ${hostno} =    Get Length  ${HOSTS}
  ${netno} =    Get Length  ${PRIVATE_NETWORKS}
  FOR   ${i}    IN RANGE    0   ${NUM_SERVERS}
    ${a} =      Evaluate    ${i}%${hostno}
    ${b} =      Evaluate    ${i}%${netno}
    ${no} =     Evaluate    f'{${i}:03}'
    Log     Create ${SERVER_NAME}-${no}     console=True
    &{RESP}=  create server
    ...     SERVER_NAME=${SERVER_NAME}-${no}  IMAGE_REF=${IMAGE_REF}
    ...     FLAVOR_REF=${FLAVOR_REF}    NETWORK_REF=${PRIVATE_NETWORKS}[${b}]
    ...     ZONE=${ZONE}    HOST=${HOSTS}[${a}]
    Append To List      ${server_id}    ${RESP.server_id}
  END
  ${rc} =   Run And Return Rc
  ...   echo ${server_id} |tr -d '[' |tr -d ']' | tr -d ' ' |tr ',' ' ' |tee ${DATA_DIR}/${DATA_FILE}
  Should Be Equal As Integers   ${rc}   0

User creates server with port and volume
  Set Suite Variable    @{server_id}    @{EMPTY}
  @{ports} =      Create List   @{EMPTY}
  Network service is available
  Volume service is available
  ${hostno} =    Get Length  ${HOSTS}
  ${netno} =    Get Length  ${PRIVATE_NETWORKS}
  FOR   ${i}    IN RANGE    0   ${NUM_SERVERS}
    ${a} =      Evaluate    ${i}%${hostno}
    ${b} =      Evaluate    ${i}%${netno}
    ${no} =     Evaluate    f'{${i}:03}'
    Log     Create ${SERVER_NAME}-port-${no}    console=True
    ${port} =     User creates port     ${PRIVATE_NETWORKS}[${b}]
    ...                                 ${SERVER_NAME}-port-${no}
    Log     Create ${SERVER_NAME}-volume-${no}    console=True
    ${vol} =     User creates volume    ${SERVER_NAME}-vol-${no}
    Volume has been created
    Volume is available
    Log     Create ${SERVER_NAME}-${no}     console=True
    &{RESP}=  create server with port and volume
    ...                 SERVER_NAME=${SERVER_NAME}-${no}
    ...                 FLAVOR_REF=${FLAVOR_REF}
    ...                 NETWORK_REF=${PRIVATE_NETWORKS}[${b}]
    ...                 PORT_REF=${port}
    ...                 VOLUME_REF=${vol}
    ...                 ZONE=${ZONE}
    ...                 HOST=${HOSTS}[${a}]
    Append To List      ${server_id}    ${RESP.server_id}
    Append To List      ${ports}      ${port}
  END
  ${rc} =   Run And Return Rc
  ...   echo ${server_id} |tr -d '[' |tr -d ']' | tr -d ' ' |tr ',' ' ' |tee ${DATA_DIR}/${DATA_FILE}
  Should Be Equal As Integers   ${rc}   0
  ${rc} =   Run And Return Rc
  ...   echo ${ports} |tr -d '[' |tr -d ']' | tr -d ' ' |tr ',' ' ' |tee ${DATA_DIR}/${PORT_FILE}
  Should Be Equal As Integers   ${rc}   0

Server has been created
  FOR   ${i}    IN RANGE    0   ${NUM_SERVERS}
    ${no} =     Evaluate    f'{${i}:03}'
    verify server name  SERVER_ID=${server_id}[${i}]
    ...                 SERVER_NAME=${SERVER_NAME}-${no}
  END

Server is active
  ${output} =   Get File    ${DATA_DIR}/${DATA_FILE}

  @{list} =     Split String     ${output}
  FOR   ${id}    IN     @{list}
    Wait Until Keyword Succeeds   1 hour     500ms
    ...                     check server status is active
    ...                         SERVER_ID=${id}
  END

All servers are active
  Wait Until Keyword Succeeds   1 hour      1s
  ...                           verify all servers are active
  ...                               SERVER_NAME=${SERVER_NAME}
  ...                               NUM_SERVERS=${NUM_SERVERS}

User stops server
  ${output} =   Get File    ${DATA_DIR}/${DATA_FILE}

  @{list} =     Split String     ${output}
  FOR   ${id}    IN     @{list}
    Log     stop server ${id}       console=True
    stop server     SERVER_ID=${id}
  END

Server is shutoff
  ${output} =   Get File    ${DATA_DIR}/${DATA_FILE}

  @{list} =     Split String     ${output}
  FOR   ${id}    IN     @{list}
    Wait Until Keyword Succeeds   1 hour     500ms
    ...                     check server status is shutoff
    ...                         SERVER_ID=${id}
  END

All servers are shutoff
  Wait Until Keyword Succeeds   1 hour      1s
  ...                           verify all servers are shutoff
  ...                               SERVER_NAME=${SERVER_NAME}
  ...                               NUM_SERVERS=${NUM_SERVERS}

User starts server
  ${output} =   Get File    ${DATA_DIR}/${DATA_FILE}

  @{list} =     Split String     ${output}
  FOR   ${id}    IN     @{list}
    Log     start server ${id}       console=True
    start server     SERVER_ID=${id}
  END

User deletes server
  ${output} =   Get File    ${DATA_DIR}/${DATA_FILE}

  @{list} =     Split String     ${output}
  FOR   ${id}   IN  @{list}
    Log     delete server ${id}       console=True
    delete server   SERVER_ID=${id}
  END

Server is not found
  ${output} =   Get File    ${DATA_DIR}/${DATA_FILE}
  
  @{list} =     Split String     ${output}
  FOR   ${id}    IN     @{list}
    Wait Until Keyword Succeeds   1 hour     500ms
    ...                     check server is not found   SERVER_ID=${id}
  END

All servers are gone
  Wait Until Keyword Succeeds   1 hour      1s
  ...                           verify all servers are gone
  ...                               SERVER_NAME=${SERVER_NAME}

Clean the ports
  ${status}     ${val} =    Run Keyword And Ignore Error
  ...                       File Should Exist   ${DATA_DIR}/${PORT_FILE}
  Run Keyword If    '${status}' == 'PASS'   Delete the ports

Delete the ports
  ${output} =   Get File    ${DATA_DIR}/${PORT_FILE}

  @{list} =     Split String     ${output}
  Network service is available
  FOR   ${id}    IN     @{list}
    Wait Until Keyword Succeeds   1 hour     500ms
    ...                     delete port   PORT_ID=${id}
    Log     deleted port ${id}       console=True
  END

