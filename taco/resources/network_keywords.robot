*** Keywords ***
# Added keywords for TACO
Network service is available
  connect to neutron api    NEUTRON_SERVICE=${NEUTRON_SERVICE}

User creates port
  [Arguments]   ${network}   ${name}
  &{RESP} =     create port     PROJECT_ID=${PROJECT_ID}
  ...                           NETWORK_REF=${network}
  ...                           PORT_NAME=${name}
  set suite variable    ${port_id}  ${RESP.port_id}
  Log   Created a port - ${port_id}     console=True
  [Return]      ${port_id}

Port has been created
  check port is created     PROJECT_ID=${PROJECT_ID}
  ...                       PORT_ID=${port_id}

Port is active
  Wait Until Keyword Succeeds   5 min   1s
  ...   check port is available    PROJECT_ID=${PROJECT_ID}
  ...                              PORT_ID=${port_id}

User deletes port
  delete port   PROJECT_ID=${PROJECT_ID}    PORT_ID=${port_id}

Port is not found
  check port is not found
  ...   PROJECT_ID=${PROJECT_ID}    PORT_ID=${port_id}
  Log   Deleted a port - ${port_id}     console=True


# Do not touch below!

Get server port id
  ${port_id}=  list active ports   url=${NEUTRON_SERVICE}
  ...                           SERVER_ID=${server_id}
  [Return]  ${port_id}

User creates floating ip for server
  &{RESP}=  list active ports   url=${NEUTRON_SERVICE}
  ...                           SERVER_ID=${server_id}
  &{RESP}=  create floating ip    url=${NEUTRON_SERVICE}
  ...                             EXTERNAL_NET_ID=${PUBLIC_NETWORK}
  ...                             PORT_ID=${RESP.port_id}
  [Return]  &{RESP}

User deletes floating ip
  [Arguments]   ${floating_ip_id}
  delete floating ip    url=${NEUTRON_SERVICE}
  ...                   FLOATING_IP_ID=${floating_ip_id}

Floating ip is accessible
  [Arguments]   ${floating_ip}
  wait until keyword succeeds   1 min   10 sec
  ...         verify floating ip in server addresses    SERVER_ID=${server_id}
  ...                                                   FLOATING_IP=${floating_ip}

