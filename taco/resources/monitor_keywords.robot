*** Keywords ***
Clean dstat log
  [Arguments]   ${conf}=kanif.conf
  Run Process   kash -f ${conf} -l clex -F -- "rm -f dstat.log"
  ...   shell=True  cwd=../monitor

Start kanif process
  [Arguments]   ${conf}=kanif.conf
  ${handle} =   Start Process
  ...   kash -f ${conf} -l clex -F -- "dstat -tlcmdrn --output dstat.log 10"  shell=True
  ...   cwd=../monitor

  ${pid} =  Get Process Id    ${handle}
  Log   kash pid is ${pid} from ${handle}      console=True
  [Return]  ${handle}

Kill kanif process
  [Arguments]   ${handle}
  Log   variable handle = ${handle}   console=True
  Send Signal To Process    SIGINT  ${handle}   group=True

Get dstat log
  [Arguments]   ${outdir}=output/test   ${conf}=kanif.conf
  Run Process   kaget -f ${conf} -l clex -F dstat.log ${outdir}
  ...           shell=True  cwd=../monitor

