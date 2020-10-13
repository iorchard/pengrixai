2..7 | ForEach-Object {
    $i = "$_"
    Write-Output "$i outer loop"
    1..$i | ForEach-Object {
        $j = "$_"
        Write-Output "$j inner loop"
        $datafile = "c:\randwrite-$j.dat"
        $jobname = "job-$i-$j"
        Write-Output "datafile: $datafile, jobname: $jobname"
        $sb = {  
            c:\Users\IBK\diskspd\diskspd.exe -r -w0 -d300 -W100 -b4K -t8 -o10 -h -Z1M -c10G -L $args[0]
        }
        $job = Start-Job -Name $jobname -ScriptBlock $sb -ArgumentList $datafile
    }
    Get-Job | Wait-Job
    Start-Sleep -s 10
}

Get-Job
2..7 | ForEach-Object {
    $i = "$_"
    Write-Output "$i outer loop"
    1..$i | ForEach-Object {
        $j = "$_"
        Write-Output "$j inner loop"
        $jobname = "job-$i-$j"
        $resultfile = "result-$i-$j.txt"
        Receive-Job -Name $jobname | Out-File $resultfile
    }
}

Get-Job | Remove-Job

2..7 | ForEach-Object {
    $i = "$_"
    "$i Clients"
    1..$i | ForEach-Object {
        $j = "$_"
        $resultfile = "result-$i-$j.txt"
        $result = Get-Content $resultfile
        foreach ($line in $result) { if ($line -like "total:*") { $total=$line; break } }
        foreach ($line in $result) { if ($line -like "avg.*") { $avg=$line; break } }

        $mbps = $total.Split("|")[2].Trim()
        $iops = $total.Split("|")[3].Trim()
        $latency = $total.Split("|")[4].Trim()
        $cpu = $avg.Split("|")[1].Trim()
        "Param $param, $iops iops, $mbps MB/s, $latency ms, $cpu CPU"
    }
}