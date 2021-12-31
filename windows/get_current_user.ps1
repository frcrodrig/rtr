$LocalHost = [System.Net.Dns]::GetHostname()
$Winlogon = Get-ItemProperty -Path (
    'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon') -ErrorAction SilentlyContinue
$Content = Get-ItemProperty 'HKCU:\Volatile Environment' -ErrorAction SilentlyContinue |
    Select-Object USERDOMAIN, LOGONSERVER, USERNAME, USERPROFILE
if ($Content) {
    $Content | ForEach-Object {
        [PSCustomObject] @{
            Hostname              = $LocalHost
            LastUsedUsername      = $Winlogon.LastUsedUsername
            ActiveUserDomain      = $_.USERDOMAIN
            ActiveUserLogonServer = $_.LOGONSERVER
            ActiveUsername        = $_.USERNAME
            ActiveUserProfile     = $_.USERPROFILE
        } | ConvertTo-Json -Compress
    }
} else {
    [PSCustomObject] @{
        Hostname              = $LocalHost
        LastUsedUsername      = $Winlogon.LastUsedUsername
        ActiveUserDomain      = $null
        ActiveUserLogonServer = $null
        ActiveUsername        = $null
        ActiveUserProfile     = $null
    } | ConvertTo-Json -Compress
}