$InstallPaths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)
$CurrentUser = Get-WmiObject win32_computersystem | Select-Object -ExpandProperty UserName
if ($CurrentUser) {
    $UserSid = (Get-WmiObject -class win32_useraccount | Where-Object { $_.Caption -eq $CurrentUser }).SID
    $InstallPaths += if ($UserSid) {
        [void] (New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS)
        if (Test-Path -Path HKU:\) {
            "HKU:\$UserSid\Software\Microsoft\Windows\CurrentVersion\Uninstall"
            "HKU:\$UserSid\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
        }
    }
}
foreach ($Path in $InstallPaths) {
    if (Test-Path $Path) {
        Get-ItemProperty -Path "$Path\*" -Recurse | Where-Object { $_.DisplayName -and $_.Publisher -and
        $_.DisplayVersion } | Select-Object DisplayName, DisplayVersion, Publisher | Format-List
    }
}