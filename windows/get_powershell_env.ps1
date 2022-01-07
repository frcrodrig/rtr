$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-Item -Path env: -ErrorAction SilentlyContinue | ForEach-Object {
    $_.PSObject.Properties.Add((New-Object PSNoteProperty('Host', $LocalHost)))
}
if ($Content -and (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue)) {
    Send-ToHumio $Content
    ConvertTo-Json -InputObject ([PSCustomObject] @{
        Host    = $LocalHost
        Script  = 'get_bitlocker_volume.ps1'
        Message = 'check_humio_for_result'
    }) -Compress
} elseif ($Content) {
    $Content | ForEach-Object {
        $_ | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_powershell_env_found'
}