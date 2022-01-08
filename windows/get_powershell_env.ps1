$Obj=Get-Item -Path env: -EA 0
$Out=[PSCustomObject]@{Host=[System.Net.Dns]::GetHostname();Script='get_powershell_env.ps1';
    Message='no_powershell_env'}
if(gcm shumio -EA 0){
    if($Obj){shumio $Obj;$Out|%{$_.Message='check_humio';$_|ConvertTo-Json -Compress}
    }else{$Out|%{shumio ($_|select Script, Message);Write-Error $_.Message}}
}elseif($Obj){
    $Obj|%{$_.PSObject.Properties.Add((New-Object PSNoteProperty('Host',$Out.Host)));$_|ConvertTo-Json -Compress}
}else{Write-Error $Out.Message}