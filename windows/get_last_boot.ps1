$Content = [PSCustomObject] @{
    Host           = [System.Net.Dns]::GetHostname()
    LastBootUpTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
}
if ($Content -and (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue)) {
    Send-ToHumio $Content
    ConvertTo-Json -InputObject ([PSCustomObject] @{
        Host    = $Content.Host
        Script  = 'get_last_boot.ps1'
        Message = 'check_humio_for_result'
    }) -Compress
} else {
    $Content | ConvertTo-Json -Compress
}