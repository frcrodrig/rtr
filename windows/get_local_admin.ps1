$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-LocalGroupMember -Group Administrators -ErrorAction SilentlyContinue
if ($Content) {
    $Content | ForEach-Object {
        [PSCustomObject] @{
            Hostname        = $LocalHost
            ObjectClass     = $_.ObjectClass
            Name            = $_.Name
            PrincipalSource = $_.PrincipalSource
        } | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_administrator_found'
}