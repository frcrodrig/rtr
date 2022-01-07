$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-SmbShare -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject] @{
        Host        = $LocalHost
        Name        = $_.Name
        ScopeName   = $_.ScopeName
        Path        = $_.Path
        Description = $_.Description
    }
}
if ($Content -and (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue)) {
    Send-ToHumio $Content
    ConvertTo-Json -InputObject ([PSCustomObject] @{
        Host    = $LocalHost
        Script  = 'get_local_share.ps1'
        Message = 'check_humio_for_result'
    }) -Compress
} elseif ($Content) {
    $Content | ForEach-Object {
        $_ | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_local_share_found'
}