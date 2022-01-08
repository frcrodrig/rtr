$Obj=Get-Process -EA 0|select Name,Id,StartTime,WorkingSet,CPU,HandleCount,Path|%{
    [PSCustomObject]@{Id=$_.Id;Name=$_.Name;StartTime=$_.StartTime.ToFileTimeUtc();WorkingSet=$_.WorkingSet;
    CPU=$_.CPU;HandleCount=$_.HandleCount;Path=$_.Path}}
$Out=[PSCustomObject]@{Host=[System.Net.Dns]::GetHostname();Script='get_process.ps1';Message='no_process'}
if(gcm shumio -EA 0){
    if($Obj){shumio $Obj;$Out|%{$_.Message='check_humio';$_|ConvertTo-Json -Compress}
    }else{$Out|%{shumio ($_|select Script, Message);Write-Error $_.Message}}
}elseif($Obj){
    $Obj|%{$_.PSObject.Properties.Add((New-Object PSNoteProperty('Host',$Out.Host)));$_|ConvertTo-Json -Compress}
}else{Write-Error $Out.Message}