foreach ($Result in (Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct)) {
    [PSCustomObject] @{
        Hostname     = [System.Net.Dns]::GetHostname()
        DisplayName  = $_.DisplayName
        ProductState = $_.ProductState
    } | ConvertTo-Json -Compress
}