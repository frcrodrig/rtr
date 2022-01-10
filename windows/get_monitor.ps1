$Obj=gwmi -Namespace root\wmi -Class WmiMonitorID -EA 0|select ManufacturerName,UserFriendlyName,SerialNumberID|%{
$_.PSObject.Properties|?{$_.Value -is [System.Array]}|%{$_.Value=([System.Text.Encoding]::ASCII.GetString(
$_.Value -notmatch 0))};[PSCustomObject]@{ManufacturerName=$_.ManufacturerName;
UserFriendlyName=$_.UserFriendlyName;SerialNumberID = $_.SerialNumberID}}
$Out=[PSCustomObject]@{Host=[System.Net.Dns]::GetHostname();Script='get_monitor.ps1';Message='no_monitor'}
if(gcm shumio -EA 0){
if($Obj){shumio $Obj;$Out|%{$_.Message='check_humio';$_|ConvertTo-Json -Compress}
}else{$Out|%{shumio ($_|select Script,Message);Write-Error $_.Message}}
}elseif($Obj){
$Obj|%{$_.PSObject.Properties.Add((New-Object PSNoteProperty('Host',$Out.Host)));$_|ConvertTo-Json -Compress}
}else{Write-Error $Out.Message}