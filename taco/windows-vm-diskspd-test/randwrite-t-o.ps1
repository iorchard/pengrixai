$t_i = [ordered]@{ 1=240;2=120;3=80;4=60;5=48;6=40;8=30;10=24;12=20;15=16;16=15;20=12 }
$t_i.GetEnumerator() | ForEach-Object {
    $t = "-t"+$_.Key
    $o = "-o"+$_.Value
    "$t $o"
    $result = c:\Users\IBK\diskspd\diskspd.exe -r -w100 -d600 -W300 -b4K $t $o -h -Z1M -c10G -L c:\randwrite.dat
    foreach ($line in $result) { if ($line -like "total:*") { $total=$line; break } }
    foreach ($line in $result) { if ($line -like "avg.*") { $avg=$line; break } }

    $mbps = $total.Split("|")[2].Trim()
    $iops = $total.Split("|")[3].Trim()
    $latency = $total.Split("|")[4].Trim()
    $cpu = $avg.Split("|")[1].Trim()
    "Param $param, $iops iops, $mbps MB/s, $latency ms, $cpu CPU"
}
