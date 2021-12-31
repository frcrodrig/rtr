$LocalHost = [System.Net.Dns]::GetHostname()
$Content = foreach ($Username in (Get-WmiObject Win32_ComputerSystem -ErrorAction SilentlyContinue).UserName) {
    $UserSid = (Get-WmiObject Win32_UserAccount -ErrorAction SilentlyContinue | Where-Object {
        $_.Caption -eq $Username }).SID
    if ($UserSid) {
        [void] (New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS)
        Get-ChildItem -Path "HKU:\$UserSid\Network" | ForEach-Object {
            Split-Path -Path $_.Name -Leaf | ForEach-Object {
                [PSCustomObject] @{
                    Hostname   = $LocalHost
                    Sid        = $UserSid
                    Username   = $Username
                    Share      = $_
                    RemotePath = Get-ItemPropertyValue -Path $_ -Name RemotePath
                }
            }
        }
    }
}
if ($Content) {
    $Content | Where-Object { $_ } | ForEach-Object {
        $_ | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_remote_share_found'
}