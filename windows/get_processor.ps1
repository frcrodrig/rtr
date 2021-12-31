$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-WmiObject -ClassName Win32_Processor -ErrorAction SilentlyContinue
if ($Content) {
    $Content | Where-Object { $_ } | ForEach-Object {
        [PSCustomObject] @{
            Hostname          = $LocalHost
            Id                = $_.ProcessorId
            Caption           = $_.Caption
            DeviceID          = $_.DeviceID
            Manufacturer      = $_.Manufacturer
            MaxClockSpeed     = $_.MaxClockSpeed
            Name              = $_.Name
            SocketDesignation = $_.SocketDesignation
        } | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_processor_found'
}