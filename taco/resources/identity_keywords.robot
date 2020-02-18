*** Keywords ***
User gets auth token
  &{RESP}=  get auth token  url=${KEYSTONE_SERVICE}
  ...                        USER_NAME=${USER_NAME}  DOMAIN_NAME=${DOMAIN_NAME}
  ...                        USER_PASSWORD=${USER_PASSWORD}
  ...                        PROJECT_NAME=${PROJECT_NAME}
  Set Environment Variable  SERVICE_TOKEN   ${RESP.auth_token}
