$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-LocalGroupMember -Group Administrators -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject] @{
        Host            = $LocalHost
        ObjectClass     = $_.ObjectClass
        Name            = $_.Name
        PrincipalSource = $_.PrincipalSource
    }
}
if ($Content -and (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue)) {
    Send-ToHumio $Content
    ConvertTo-Json -InputObject ([PSCustomObject] @{
        Host    = $LocalHost
        Script  = 'get_local_admin.ps1'
        Message = 'check_humio_for_result'
    }) -Compress
} elseif ($Content) {
    $Content | ForEach-Object {
        $_ | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_local_admin_found'
}