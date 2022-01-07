$LocalHost = [System.Net.Dns]::GetHostname()
$Definition = @’
[DllImport("kernel32.dll", SetLastError = true)]
public static extern uint QueryDosDevice(
    string lpDeviceName,
    System.Text.StringBuilder lpTargetPath,
    uint ucchMax);
‘@
$StringBuilder = New-Object System.Text.StringBuilder(65536)
$Kernel32 = Add-Type -MemberDefinition $Definition -Name Kernel32 -Namespace Win32 -PassThru
$Content = Get-Volume -ErrorAction SilentlyContinue | Select-Object DriveLetter, FileSystemLabel, FileSystem,
SizeRemaining | ForEach-Object {
    $DevicePath = $Kernel32::QueryDosDevice("$($_.DriveLetter):",$StringBuilder,255)
    [PSCustomObject] @{
        Host            = $LocalHost
        DriveLetter     = $_.DriveLetter
        FileSystemLabel = $_.FileSystemLabel
        FileSystem      = $_.FileSystem
        SizeRemaining   = $_.SizeRemaining
        DevicePath      = $DevicePath
    }
}
if ($Content -and (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue)) {
    Send-ToHumio $Content
    ConvertTo-Json -InputObject ([PSCustomObject] @{
        Host    = $LocalHost
        Script  = 'get_volume.ps1'
        Message = 'check_humio_for_result'
    }) -Compress
} else {
    $Content | ForEach-Object {
        $_ | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_volume_found'
}