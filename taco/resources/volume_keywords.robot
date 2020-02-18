*** Keywords ***
Volume service is available
  connect to cinder api	    CINDER_SERVICE=${CINDER_SERVICE}

User creates volume
  [Arguments]   ${vol_name}=test-vol
  &{RESP} =     create volume   PROJECT_ID=${PROJECT_ID}
  ...                           IMAGE_REF=${IMAGE_REF}
  ...                           VOL_NAME=${vol_name}
  ...                           VOL_SIZE=${VOL_SIZE}
  ...                           VOL_TYPE=${VOL_TYPE}
  set suite variable    ${volume_id}    ${RESP.volume_id}
  Log   Created a volume - ${volume_id}     console=True
  [Return]  ${volume_id}

Volume has been created
  check volume is created   PROJECT_ID=${PROJECT_ID}
  ...                       VOLUME_ID=${volume_id}

Volume is available
  Wait Until Keyword Succeeds   5 min   200ms
  ...   check volume is available    PROJECT_ID=${PROJECT_ID}
  ...                                VOLUME_ID=${volume_id} 

User deletes volume
  delete volume     PROJECT_ID=${PROJECT_ID}    VOLUME_ID=${volume_id}

Volume is deleted
  check volume is not found
  ...   PROJECT_ID=${PROJECT_ID}    VOLUME_ID=${volume_id}
  Log   Deleted a volume - ${volume_id}     console=True

