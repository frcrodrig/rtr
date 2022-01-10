$Obj=('Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
'Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*').foreach{
gp -Path "Registry::\HKEY_LOCAL_MACHINE\$_" -EA 0|?{$_.DisplayName -and $_.DisplayVersion -and $_.Publisher}|
select DisplayName,DisplayVersion,Publisher;foreach ($Sid in (gwmi Win32_UserProfile|?{
$_.SID -like 'S-1-5-21-*'}).SID){gp -Path "Registry::\HKEY_USERS\$Sid\$_" -EA 0|?{$_.DisplayName -and
$_.DisplayVersion -and $_.Publisher}|select DisplayName,DisplayVersion,Publisher}}
$Out=[PSCustomObject]@{Host=[System.Net.Dns]::GetHostname();Script='get_application.ps1';Message='no_application'}
if(gcm shumio -EA 0){
if($Obj){shumio $Obj;$Out|%{$_.Message='check_humio';$_|ConvertTo-Json -Compress}
}else{$Out|%{shumio ($_|select Script,Message);Write-Error $_.Message}}
}elseif($Obj){
$Obj|%{$_.PSObject.Properties.Add((New-Object PSNoteProperty('Host',$Out.Host)));$_|ConvertTo-Json -Compress}
}else{Write-Error $Out.Message}