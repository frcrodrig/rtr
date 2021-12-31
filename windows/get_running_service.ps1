$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-WmiObject Win32_Service -ErrorAction SilentlyContinue | Where-Object { $_.State -eq "Running" } |
    Select-Object ProcessId, Name, PathName
if ($Content) {
    $Content | Where-Object { $_ } | ForEach-Object {
        [PSCustomObject] @{
            Hostname    = $LocalHost
            ProcessId   = $_.ProcessId
            Name        = $_.Name
            PathName    = $_.PathName
        } | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_service_found'
}
