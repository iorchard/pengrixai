*** Keywords ***
Clean dstat log
  Run Process   kash -f kanif.conf -l clex -- "rm -f dstat.log"
  ...   shell=True  cwd=../monitor

Start kanif process
  ${handle} =   Start Process
  ...   kash -f kanif.conf -l clex -- "dstat -tlcmdn -o dstat.log"  shell=True
  ...   cwd=../monitor

  ${pid} =  Get Process Id    ${handle}
  Log   kash pid is ${pid} from ${handle}      console=True
  [Return]  ${handle}

Kill kanif process
  [Arguments]   ${handle}
  Log   variable handle = ${handle}   console=True
  Send Signal To Process    SIGINT  ${handle}   group=True

Get dstat log
  [Arguments]   ${outdir}=output/test
  Run Process   kaget -f kanif.conf -l clex dstat.log ${outdir}
  ...           shell=True  cwd=../monitor

