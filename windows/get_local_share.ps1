$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-SmbShare -ErrorAction SilentlyContinue
if ($Content) {
    $Content | ForEach-Object {
        [PSCustomObject] @{
            Hostname    = $LocalHost
            Name        = $_.Name
            ScopeName   = $_.ScopeName
            Path        = $_.Path
            Description = $_.Description
        } | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_local_share_found'
}