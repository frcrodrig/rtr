$LocalHost = [System.Net.Dns]::GetHostname()
$Content = @(
    Get-NetTcpConnection -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort, RemoteAddress,
        RemotePort, State
    Get-NetUDPEndpoint -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort
)
if ($Content) {
    $Content | ForEach-Object {
        [PSCustomObject] @{
            Hostname      = $LocalHost
            Protocol      = if ($_.State) { 'TCP' } else { 'UDP' }
            LocalAddress  = $_.LocalAddress
            LocalPort     = $_.LocalPort
            RemoteAddress = $_.RemoteAddress
            RemotePort    = $_.RemotePort
            State         = $_.State
        } | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_port_found'
}