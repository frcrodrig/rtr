$LocalHost = [System.Net.Dns]::GetHostname()
$Content = ('Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
'Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*').foreach{
    Get-ItemProperty -Path "Registry::\HKEY_LOCAL_MACHINE\$_" -ErrorAction SilentlyContinue | Where-Object {
        $_.DisplayName -and $_.DisplayVersion -and $_.Publisher } | Select-Object DisplayName, DisplayVersion,
        Publisher
    foreach ($UserSid in (Get-WmiObject Win32_UserProfile | Where-Object { $_.SID -like 'S-1-5-21-*' }).SID) {
        Get-ItemProperty -Path "Registry::\HKEY_USERS\$UserSid\$_" -ErrorAction SilentlyContinue | Where-Object {
            $_.DisplayName -and $_.DisplayVersion -and $_.Publisher } | Select-Object DisplayName, DisplayVersion,
            Publisher
    }
}
if ($Content) {
    $Content | Where-Object { $_ } | ForEach-Object {
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
