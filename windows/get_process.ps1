$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-Process -ErrorAction SilentlyContinue | Select-Object Name, Id, StartTime, WorkingSet, CPU,
    HandleCount, Path
if ($Content) {
    $Content | Where-Object { $_ } | ForEach-Object {
        [PSCustomObject] @{
            Hostname    = $LocalHost
            Id          = $_.Id
            Name        = $_.Name
            StartTime   = $_.StartTime
            WorkingSet  = $_.WorkingSet
            CPU         = $_.CPU
            HandleCount = $_.HandleCount
            Path        = $_.Path
        } | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_process_found'
}