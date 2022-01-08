$Obj=foreach($UserSid in (gwmi Win32_UserProfile|?{$_.SID -like 'S-1-5-21-*'}).SID){
    gp -Path "Registry::\HKEY_USERS\$UserSid\Network" -EA 0|%{Split-Path -Path $_.Name -Leaf|%{
    [PSCustomObject]@{Sid=$UserSid;Username=$Username;Share=$_;RemotePath=gpv -Path $_ -Name RemotePath}}}}
$Out=[PSCustomObject]@{Host=[System.Net.Dns]::GetHostname();Script='get_remote_share.ps1';
    Message='no_remote_share'}
if(gcm shumio -EA 0){
    if($Obj){shumio $Obj;$Out|%{$_.Message='check_humio';$_|ConvertTo-Json -Compress}
    }else{$Out|%{shumio ($_|select Script, Message);Write-Error $_.Message}}
}elseif($Obj){
    $Obj|%{$_.PSObject.Properties.Add((New-Object PSNoteProperty('Host',$Out.Host)));$_|ConvertTo-Json -Compress}
}else{Write-Error $Out.Message}