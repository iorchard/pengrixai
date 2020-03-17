*** Keywords ***
Check if fio servers are running
  FOR   ${s}   IN  @{FIO_SERVERS}
    Check if fio server is running  ${s}
  END

Check if fio server is running
  [Arguments]   ${server}
  Open Connection   ${server}   port=${FIO_SERVER_PORT}
  Read Until    closed
  Close Connection

Warmup fio
  Log   Warmup fio      console=True
  FOR   ${s}   IN  @{FIO_SERVERS}
    Run     fio --client=${s} fio/warmup.fio
  END

Run fio
  Log   Run fio     console=True
  FOR   ${s}   IN  @{FIO_SERVERS}
    Run fio with testcases    ${s}
  END

Run fio with testcases
  [Arguments]   ${server}
  Log   Run fio randread with different iodepth values.     console=True
  FOR   ${iodepth}  IN  1   8   16  32  64  128
    Run     sed -e 's/IODEPTH/${iodepth}/;s/IOTYPE/randread/;s/BS/4k/ fio/fio.tpl > fio/randread_${iodepth}_4k.fio
    Run     fio --output=fio/randread_${iodepth}_4k.json --output-format=json --client=${s} fio/randread_${iodepth}_4k.fio
  END

  Log   Run fio randwrite with different iodepth values.     console=True
  FOR   ${iodepth}  IN  1   8   16  32  64  128
    Run     sed -e 's/IODEPTH/${iodepth}/;s/IOTYPE/randread/;s/BS/4k/ fio/fio.tpl > fio/randread_${iodepth}_4k.fio
    Run     fio --output=fio/randread_${iodepth}_4k.json --output-format=json --client=${s} fio/randread_${iodepth}_4k.fio
  END
