$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-Tpm -ErrorAction SilentlyContinue | ForEach-Object {
    $_.PSObject.Properties.Add((New-Object PSNoteProperty('Host', $LocalHost)))
    $_
}
if ($Content -and (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue)) {
    Send-ToHumio $Content
    ConvertTo-Json -InputObject ([PSCustomObject] @{
        Host    = $LocalHost
        Script  = 'get_tpm.ps1'
        Message = 'check_humio_for_result'
    }) -Compress
} elseif ($Content) {
    $Content | ForEach-Object {
        $_ | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_tpm_found'
}