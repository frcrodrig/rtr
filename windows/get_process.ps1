$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-Process -ErrorAction SilentlyContinue | Select-Object Name, Id, StartTime, WorkingSet, CPU,
HandleCount, Path | ForEach-Object {
    [PSCustomObject] @{
        Host        = $LocalHost
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
    Send-ToHumio $Content
    ConvertTo-Json -InputObject ([PSCustomObject] @{
        Host    = $LocalHost
        Script  = 'get_process.ps1'
        Message = 'check_humio_for_result'
    }) -Compress
} elseif ($Content) {
    $Content | ForEach-Object {
        $_ | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_process_found'
}