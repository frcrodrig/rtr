Get-LocalGroupMember -Group Administrators | ForEach-Object {
    [PSCustomObject] @{
        Hostname        = [System.Net.Dns]::GetHostname()
        ObjectClass     = $_.ObjectClass
        Name            = $_.Name
        PrincipalSource = $_.PrincipalSource
    } | ConvertTo-Json -Compress
}