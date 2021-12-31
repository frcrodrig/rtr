
[PSCustomObject] @{
    Hostname         = [System.Net.Dns]::GetHostname()
    LastUsedUsername = (
        Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon').LastUsedUsername
} | ConvertTo-Json -Compress