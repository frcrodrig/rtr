$Obj=gwmi Win32_Service -EA 0|?{$_.State -eq 'Running'}|select ProcessId,Name,PathName|%{
[PSCustomObject]@{ProcessId=$_.ProcessId;Name=$_.Name;PathName=$_.PathName}}
$Out=[PSCustomObject]@{Host=[System.Net.Dns]::GetHostname();Script='get_running_service.ps1';
Message='no_running_service'}
if(gcm shumio -EA 0){
if($Obj){shumio $Obj;$Out|%{$_.Message='check_humio';$_|ConvertTo-Json -Compress}
}else{$Out|%{shumio ($_|select Script,Message);Write-Error $_.Message}}
}elseif($Obj){
$Obj|%{$_.PSObject.Properties.Add((New-Object PSNoteProperty('Host',$Out.Host)));$_|ConvertTo-Json -Compress}
}else{Write-Error $Out.Message}