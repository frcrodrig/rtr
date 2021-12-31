[PSCustomObject] @{
    Hostname       = [System.Net.Dns]::GetHostname()
    LastBootUpTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
} | ConvertTo-Json -Compress