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
$Content = Get-Volume -ErrorAction SilentlyContinue | Select-Object DriveLetter, FileSystemLabel,
    FileSystem, SizeRemaining
if ($Content) {
    $Content | Where-Object { $_ } | ForEach-Object {
        $DevicePath = $Kernel32::QueryDosDevice("$($_.DriveLetter):",$StringBuilder,255)
        [PSCustomObject] @{
            Hostname        = $LocalHost
            DriveLetter     = $_.DriveLetter
            FileSystemLabel = $_.FileSystemLabel
            FileSystem      = $_.FileSystem
            SizeRemaining   = $_.SizeRemaining
            DevicePath      = $DevicePath
        } | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_volume_found'
}