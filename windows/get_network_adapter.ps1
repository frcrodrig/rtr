$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-NetAdapter -ErrorAction SilentlyContinue | Select-Object Name, InterfaceDescription,
MacAddress, Status | ForEach-Object {
    [PSCustomObject] @{
        Host                 = $LocalHost
        Name                 = $_.Name
        InterfaceDescription = $_.InterfaceDescription
        MacAddress           = $_.MacAddress
        Status               = $_.Status
    }
}
if ($Content -and (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue)) {
    Send-ToHumio $Content
    ConvertTo-Json -InputObject ([PSCustomObject] @{
        Host    = $LocalHost
        Script  = 'get_network_adapter.ps1'
        Message = 'check_humio_for_result'
    }) -Compress
} elseif ($Content) {
    $Content | ForEach-Object {
        $_ | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_network_adapter_found'
}