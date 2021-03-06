$Obj=Get-SmbShare -EA 0|%{[PSCustomObject]@{Name=$_.Name;ScopeName=$_.ScopeName;Path=$_.Path;
Description=$_.Description}}
$Out=[PSCustomObject]@{Host=[System.Net.Dns]::GetHostname();Script='get_local_share.ps1';Message='no_local_share'}
if(gcm shumio -EA 0){
if($Obj){shumio $Obj;$Out|%{$_.Message='check_humio';$_|ConvertTo-Json -Compress}
}else{$Out|%{shumio ($_|select Script,Message);Write-Error $_.Message}}
}elseif($Obj){
$Obj|%{$_.PSObject.Properties.Add((New-Object PSNoteProperty('Host',$Out.Host)));$_|ConvertTo-Json -Compress}
}else{Write-Error $Out.Message}