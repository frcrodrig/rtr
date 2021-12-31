$LocalHost = [System.Net.Dns]::GetHostname()
$Winlogon = Get-ItemProperty -Path (
    'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon') -ErrorAction SilentlyContinue
$ActiveUser = Get-ItemProperty 'HKCU:\Volatile Environment' -ErrorAction SilentlyContinue |
    Select-Object USERDOMAIN, LOGONSERVER, USERNAME, USERPROFILE
if ($ActiveUser) {
    $ActiveUser | ForEach-Object {
        [PSCustomObject] @{
            Hostname              = $LocalHost
            LastUsedUsername      = $Winlogon.LastUsedUsername
            ActiveUserDomain      = $_.USERDOMAIN
            ActiveUserLogonServer = $_.LOGONSERVER
            ActiveUsername        = $_.USERNAME
            ActiveUserProfile     = $_.USERPROFILE
        }
    }
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