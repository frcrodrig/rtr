$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-WmiObject -ClassName Win32_Processor -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject] @{
        Host              = $LocalHost
        Id                = $_.ProcessorId
        Caption           = $_.Caption
        DeviceID          = $_.DeviceID
        Manufacturer      = $_.Manufacturer
        MaxClockSpeed     = $_.MaxClockSpeed
        Name              = $_.Name
        SocketDesignation = $_.SocketDesignation
    }
}
if ($Content -and (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue)) {
    Send-ToHumio $Content
    ConvertTo-Json -InputObject ([PSCustomObject] @{
        Host    = $LocalHost
        Script  = 'get_processor.ps1'
        Message = 'check_humio_for_result'
    }) -Compress
} elseif ($Content) {
    $Content | ForEach-Object {
        $_ | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_processor_found'
}