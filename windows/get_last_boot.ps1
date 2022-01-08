$Obj=(Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime.ToFileTimeUtc()
$Out=[PSCustomObject]@{Host=[System.Net.Dns]::GetHostname();Script='get_last_boot.ps1';Message='check_humio'}
if(gcm shumio -EA 0){shumio ([PSCustomObject]@{LastBootUpTime=$Obj});$Out|%{$_|ConvertTo-Json -Compress}
}else{[PSCustomObject]@{Host=$Out.Host;LastBootUpTime=$Obj}|ConvertTo-Json -Compress}