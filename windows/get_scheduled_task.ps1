$Obj=foreach($Task in (gci -Path "$($env:SYSTEMROOT)\System32\Tasks" -File -Recurse -EA 0|select Name,FullName)){
foreach($Xml in ([xml] (Get-Content $Task.FullName))){[PSCustomObject]@{Name=$Task.Name;
UserId=$Xml.Task.Principals.Principal.UserId;Author=$Xml.Task.RegistrationInfo.Author;
Enabled=$Xml.Task.Settings.Enabled;Command=$Xml.Task.Actions.Exec.Command;
Arguments=$Xml.Task.Actions.Exec.Arguments}}}
$Out=[PSCustomObject]@{Host=[System.Net.Dns]::GetHostname();Script='get_scheduled_task.ps1';
Message='no_scheduled_task'}
if(gcm shumio -EA 0){
if($Obj){shumio $Obj;$Out|%{$_.Message='check_humio';$_|ConvertTo-Json -Compress}
}else{$Out|%{shumio ($_|select Script,Message);Write-Error $_.Message}}
}elseif($Obj){
$Obj|%{$_.PSObject.Properties.Add((New-Object PSNoteProperty('Host',$Out.Host)));$_|ConvertTo-Json -Compress}
}else{Write-Error $Out.Message}