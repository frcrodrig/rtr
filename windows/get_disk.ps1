function Get-DrivePath ([string] $String) {
    $Definition = @’
[DllImport("kernel32.dll", SetLastError = true)]
public static extern uint QueryDosDevice(
    string lpDeviceName,
    System.Text.StringBuilder lpTargetPath,
    uint ucchMax);
‘@
    $StringBuilder = New-Object System.Text.StringBuilder(65536)
    $Kernel32 = Add-Type -MemberDefinition $Definition -Name Kernel32 -Namespace Win32 -PassThru
    foreach ($Volume in (Get-WmiObject Win32_Volume | Where-Object { $_.DriveLetter })) {
        $Value = $Kernel32::QueryDosDevice($String,$StringBuilder,65536)
        if ($Value) {
            $StringBuilder.ToString()
        }
    }
}
$Result = Get-Volume | Select-Object DriveLetter, FileSystemLabel, FileSystem, SizeRemaining
$Result | ForEach-Object {
    $_.PSObject.Properties.Add((New-Object PSNoteProperty('Hostname',([System.Net.Dns]::GetHostname()))))
    $_.PSObject.Properties.Add((New-Object PSNoteProperty('Path',(Get-DrivePath $_.DriveLetter))))
    $_ | Select-Object Hostname, DriveLetter, FileSystemLabel, FileSystem, SizeRemaining, Path
}