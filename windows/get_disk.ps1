
$Definition = @’
[DllImport("kernel32.dll", SetLastError = true)]
public static extern uint QueryDosDevice(
    string lpDeviceName,
    System.Text.StringBuilder lpTargetPath,
    uint ucchMax);
‘@
$StringBuilder = New-Object System.Text.StringBuilder(65536)
$Kernel32 = Add-Type -MemberDefinition $Definition -Name Kernel32 -Namespace Win32 -PassThru
Get-Volume | Select-Object DriveLetter, FileSystemLabel, FileSystem, SizeRemaining | ForEach-Object {
    $Path = $Kernel32::QueryDosDevice("$($_.DriveLetter):",$StringBuilder,255)
    [PSCustomObject] @{
        Hostname        = [System.Net.Dns]::GetHostname()
        DriveLetter     = $_.DriveLetter
        FileSystemLabel = $_.FileSystemLabel
        FileSystem      = $_.FileSystem
        SizeRemaining   = $_.SizeRemaining
        Path            = if ($Path) {
            $Path
        } else {
            $null
        }
    } | ConvertTo-Json -Compress
}