1..12 | ForEach-Object {
    $param = "-o$_"
    $result = c:\Users\IBK\diskspd\diskspd.exe -r -w80 -d600 -W300 -b4K -t8 $param -h -Z1M -c10G -L c:\diskspd.dat
    foreach ($line in $result) { if ($line -like "total:*") { $total=$line; break } }
    foreach ($line in $result) { if ($line -like "avg.*") { $avg=$line; break } }

    $mbps = $total.Split("|")[2].Trim()
    $iops = $total.Split("|")[3].Trim()
    $latency = $total.Split("|")[4].Trim()
    $cpu = $avg.Split("|")[1].Trim()
    "Param $param, $iops iops, $mbps MB/s, $latency ms, $cpu CPU"
}
