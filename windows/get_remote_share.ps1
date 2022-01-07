$LocalHost = [System.Net.Dns]::GetHostname()
$Content = foreach ($UserSid in (Get-WmiObject Win32_UserProfile | Where-Object {
$_.SID -like 'S-1-5-21-*' }).SID) {
    Get-ItemProperty -Path "Registry::\HKEY_USERS\$UserSid\Network" -ErrorAction SilentlyContinue |
    ForEach-Object {
        Split-Path -Path $_.Name -Leaf | ForEach-Object {
            [PSCustomObject] @{
                Host       = $LocalHost
                Sid        = $UserSid
                Username   = $Username
                Share      = $_
                RemotePath = Get-ItemPropertyValue -Path $_ -Name RemotePath
            }
        }
    }
}
if ($Content -and (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue)) {
    Send-ToHumio $Content
    ConvertTo-Json -InputObject ([PSCustomObject] @{
        Host    = $LocalHost
        Script  = 'get_remote_share.ps1'
        Message = 'check_humio_for_result'
    }) -Compress
} elseif ($Content) {
    $Content | ForEach-Object {
        $_ | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_remote_share_found'
}