$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-WmiObject -ClassName Win32_Baseboard -ErrorAction SilentlyContinue | Select-Object Manufacturer,
    Product, Model, SerialNumber
if ($Content) {
    $Content | Where-Object { $_ } | ForEach-Object {
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