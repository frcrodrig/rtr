$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-WmiObject -Namespace root\wmi -Class WmiMonitorID -ErrorAction SilentlyContinue |
    Select-Object ManufacturerName, UserFriendlyName, SerialNumberID
if ($Content) {
    $Content | Where-Object { $_ } | ForEach-Object {
        $_.PSObject.Properties | Where-Object { $_.Value -is [System.Array] } | ForEach-Object {
            $_.Value = ([System.Text.Encoding]::ASCII.GetString($_.Value -notmatch 0))
        }
        [PSCustomObject] @{
            Hostname         = $LocalHost
            ManufacturerName = $_.ManufacturerName
            UserFriendlyName = $_.UserFriendlyName
            SerialNumberID   = $_.SerialNumberID
        } | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_monitor_found'
}