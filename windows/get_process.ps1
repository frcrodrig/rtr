$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-Process -ErrorAction SilentlyContinue | Select-Object Name, Id, StartTime, WorkingSet, CPU,
HandleCount, Path | ForEach-Object {
    [PSCustomObject] @{
        Hostname    = $LocalHost
        Id          = $_.Id
        Name        = $_.Name
        StartTime   = $_.StartTime
        WorkingSet  = $_.WorkingSet
        CPU         = $_.CPU
        HandleCount = $_.HandleCount
        Path        = $_.Path
    }
}
if ($Content -and (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue)) {
    SendTo-Humio $Content
    ConvertTo-Json -InputObject ([PSCustomObject] @{
        host   = $LocalHost
        script = 'get_process.ps1'
        message = 'check_humio_for_result'
    }) -Compress
} elseif ($Content) {
    @($Content).foreach{
        ConvertTo-Json -InputObject $_ -Compress
    }
} else {
    Write-Error 'no_process_found'
}