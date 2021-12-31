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
$LocalHost = [System.Net.Dns]::GetHostname()
$Content = foreach ($Path in $InstallPaths) {
    if (Test-Path $Path) {
        Get-ItemProperty -Path "$Path\*" | Where-Object { $_.DisplayName -and $_.DisplayVersion -and
        $_.Publisher } | Select-Object DisplayName, DisplayVersion, Publisher
    }
}
if ($Content) {
    $Content | ForEach-Object {
        [PSCustomObject] @{
            Hostname       = $LocalHost
            DisplayName    = $_.DisplayName
            DisplayVersion = $_.DisplayVersion
            Publisher      = $_.Publisher
        } | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_application_found'
}