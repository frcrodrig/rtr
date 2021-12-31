$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-SmbShare
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
    Write-Error 'no_share_found'
}