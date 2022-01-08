$Key='HKEY_LOCAL_MACHINE\SYSTEM\CrowdStrike\{9b03c1d9-3138-44ed-9fae-d9f4c034b88d}\'+
    '{16e0423f-7058-48c9-a204-725362b67639}\Default'
$Tag=(reg query $Key) -match 'GroupingTags'
$Val=if($Tag){(($Tag -split 'REG_SZ')[-1].Trim().Split(',')+$args.Split(',')|select -Unique) -join ','}else{$args}
[void](reg add $Key /v GroupingTags /d $Val /f)
$Obj="$((((reg query $Key) -match 'GroupingTags') -split 'REG_SZ')[-1].Trim())"
$Out=[PSCustomObject]@{Host=[System.Net.Dns]::GetHostname();Script='add_sensortag.ps1';Message='check_humio'}
if(gcm shumio -EA 0){shumio ([PSCustomObject]@{SensorTag=$Obj});$Out|%{$_|ConvertTo-Json -Compress}
}else{[PSCustomObject]@{Host=$Out.Host;SensorTag=$Obj}|ConvertTo-Json -Compress}