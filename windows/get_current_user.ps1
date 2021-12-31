$ActiveUser = Get-ItemProperty 'HKCU:\Volatile Environment' -ErrorAction SilentlyContinue
[PSCustomObject] @{
    Hostname              = [System.Net.Dns]::GetHostname()
    ActiveUserDomain      = if ($ActiveUser) { $ActiveUser.USERDOMAIN }
    ActiveUserLogonServer = if ($ActiveUser) { $ActiveUser.LOGONSERVER }
    ActiveUsername        = if ($ActiveUser) { $ActiveUser.USERNAME }
    ActiveUserProfile     = if ($ActiveUser) { $ActiveUser.USERPROFILE }
    LastUsedUsername      = (Get-ItemProperty -Path (
        'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon')).LastUsedUsername
} | ConvertTo-Json -Compress