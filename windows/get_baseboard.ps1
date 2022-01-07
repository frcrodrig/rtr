$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-WmiObject -ClassName Win32_Baseboard -ErrorAction SilentlyContinue | Select-Object Manufacturer,
Product, Model, SerialNumber | ForEach-Object {
    [PSCustomObject] @{
        Host         = $LocalHost
        Manufacturer = $_.Manufacturer
        Product      = $_.Product
        Model        = $_.Model
        SerialNumber = $_.SerialNumber
    }
}
if ($Content -and (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue)) {
    Send-ToHumio $Content
    ConvertTo-Json -InputObject ([PSCustomObject] @{
        Host    = $LocalHost
        Script  = 'get_baseboard.ps1'
        Message = 'check_humio_for_result'
    }) -Compress
} elseif ($Content) {
    $Content | ForEach-Object {
        $_ | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_baseboard_found'
}