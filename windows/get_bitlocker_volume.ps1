$Obj=Get-BitLockerVolume -EA 0|select -ExcludeProperty ComputerName
$Out=[PSCustomObject]@{Host=[System.Net.Dns]::GetHostname();Script='get_bitlocker_volume.ps1';
    Message='no_bitlocker_volume'}
if(gcm shumio -EA 0){
    if($Obj){shumio $Obj;$Out|%{$_.Message='check_humio';$_|ConvertTo-Json -Compress}
    }else{$Out|%{shumio ($_|select Script, Message);Write-Error $_.Message}}
}elseif($Obj){
    $Obj|%{$_.PSObject.Properties.Add((New-Object PSNoteProperty('Host',$Out.Host)));$_|ConvertTo-Json -Compress}
}else{Write-Error $Out.Message}