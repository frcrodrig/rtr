$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-WmiObject -ClassName Win32_Baseboard | Select-Object Manufacturer, Product, Model, SerialNumber
if ($Content) {
    $Content | ForEach-Object {
        [PSCustomObject] @{
            Hostname     = $LocalHost
            Manufacturer = $_.Manufacturer
            Product      = $_.Product
            Model        = $_.Model
            SerialNumber = $_.SerialNumber
        } | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_baseboard_found'
}