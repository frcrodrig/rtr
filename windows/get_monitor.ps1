$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-WmiObject -Namespace root\wmi -Class WmiMonitorID -ErrorAction SilentlyContinue |
Select-Object ManufacturerName, UserFriendlyName, SerialNumberID | ForEach-Object {
    $_.PSObject.Properties | Where-Object { $_.Value -is [System.Array] } | ForEach-Object {
        $_.Value = ([System.Text.Encoding]::ASCII.GetString($_.Value -notmatch 0))
    }
    [PSCustomObject] @{
        Host             = $LocalHost
        ManufacturerName = $_.ManufacturerName
        UserFriendlyName = $_.UserFriendlyName
        SerialNumberID   = $_.SerialNumberID
    }
}
if ($Content -and (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue)) {
    Send-ToHumio $Content
    ConvertTo-Json -InputObject ([PSCustomObject] @{
        Host    = $LocalHost
        Script  = 'get_monitor.ps1'
        Message = 'check_humio_for_result'
    }) -Compress
} elseif ($Content) {
    $Content | ForEach-Object {
        $_ | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_monitor_found'
}