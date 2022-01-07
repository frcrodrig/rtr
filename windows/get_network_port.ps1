$LocalHost = [System.Net.Dns]::GetHostname()
$Content = @(
    Get-NetTcpConnection -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort, RemoteAddress,
        RemotePort, State
    Get-NetUDPEndpoint -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort
)
$Content = $Content | ForEach-Object {
    [PSCustomObject] @{
        Host          = $LocalHost
        Protocol      = if ($_.State) { 'TCP' } else { 'UDP' }
        LocalAddress  = $_.LocalAddress
        LocalPort     = $_.LocalPort
        RemoteAddress = $_.RemoteAddress
        RemotePort    = $_.RemotePort
        State         = $_.State
    }
}
if ($Content -and (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue)) {
    Send-ToHumio $Content
    ConvertTo-Json -InputObject ([PSCustomObject] @{
        Host    = $LocalHost
        Script  = 'get_network_port.ps1'
        Message = 'check_humio_for_result'
    }) -Compress
} elseif ($Content) {
    $Content | ForEach-Object {
        $_ | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_network_port_found'
}