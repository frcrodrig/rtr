$LocalHost = [System.Net.Dns]::GetHostname()
$Winlogon = Get-ItemProperty -Path (
    'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon') -ErrorAction SilentlyContinue
$ActiveUser = Get-ItemProperty 'HKCU:\Volatile Environment' -ErrorAction SilentlyContinue |
Select-Object USERDOMAIN, LOGONSERVER, USERNAME, USERPROFILE | ForEach-Object {
    [PSCustomObject] @{
        Hostname              = $LocalHost
        LastUsedUsername      = $Winlogon.LastUsedUsername
        ActiveUserDomain      = $_.USERDOMAIN
        ActiveUserLogonServer = $_.LOGONSERVER
        ActiveUsername        = $_.USERNAME
        ActiveUserProfile     = $_.USERPROFILE
    }
}
$Content = if ($ActiveUser) {
    $ActiveUser
} else {
    [PSCustomObject] @{
        Hostname              = $LocalHost
        LastUsedUsername      = $Winlogon.LastUsedUsername
        ActiveUserDomain      = $null
        ActiveUserLogonServer = $null
        ActiveUsername        = $null
        ActiveUserProfile     = $null
    }
}
if ($Content -and (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue)) {
    Send-ToHumio $Content
    ConvertTo-Json -InputObject ([PSCustomObject] @{
        Host    = $LocalHost
        Script  = 'get_current_user.ps1'
        Message = 'check_humio_for_result'
    }) -Compress
} else {
    $Content | ForEach-Object {
        $_ | ConvertTo-Json -Compress
    }
}