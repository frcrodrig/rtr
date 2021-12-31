$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-NetAdapter | Select-Object Name, InterfaceDescription, MacAddress, Status
if ($Content) {
    $Content | ForEach-Object {
        [PSCustomObject] @{
            Hostname             = $LocalHost
            Name                 = $_.Name
            InterfaceDescription = $_.InterfaceDescription
            MacAddress           = $_.MacAddress
            Status               = $_.Status
        } | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_adapter_found'
}