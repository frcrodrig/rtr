$Last=(gp -Path ('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon') -EA 0).LastUsedUsername
$Active=gp 'HKCU:\Volatile Environment' -EA 0|select USERDOMAIN,LOGONSERVER,USERNAME,USERPROFILE
$Obj=if($Active){$Active|%{[PSCustomObject]@{LastUsedUsername=$Last;ActiveUserDomain=$_.USERDOMAIN;
ActiveUserLogonServer=$_.LOGONSERVER;ActiveUsername=$_.USERNAME;ActiveUserProfile=$_.USERPROFILE}}
}else{$None=[PSCustomObject]@{LastUsedUsername=$Last};@('ActiveUserDomain','ActiveUserLogonServer',
'ActiveUsername','ActiveUserProfile').foreach{$None.PSObject.Properties.Add((New-Object PSNoteProperty($_,
$null)))};$None}
$Out=[PSCustomObject]@{Host=[System.Net.Dns]::GetHostname();Script='get_current_user.ps1';Message='check_humio'}
if(gcm shumio -EA 0){shumio $Obj;$Out|%{$_|ConvertTo-Json -Compress}}else{
$Obj|%{$_.PSObject.Properties.Add((New-Object PSNoteProperty('Host',$Out.Host)));$_|ConvertTo-Json -Compress}}