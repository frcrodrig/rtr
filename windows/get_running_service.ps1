$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-WmiObject Win32_Service -ErrorAction SilentlyContinue | Where-Object { $_.State -eq "Running" } |
Select-Object ProcessId, Name, PathName | ForEach-Object {
    [PSCustomObject] @{
        Host      = $LocalHost
        ProcessId = $_.ProcessId
        Name      = $_.Name
        PathName  = $_.PathName
    }
}
if ($Content -and (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue)) {
    Send-ToHumio $Content
    ConvertTo-Json -InputObject ([PSCustomObject] @{
        Host    = $LocalHost
        Script  = 'get_running_service.ps1'
        Message = 'check_humio_for_result'
    }) -Compress
} elseif ($Content) {
    $Content | ForEach-Object {
        $_ | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_service_found'
}
