$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct -ErrorAction SilentlyContinue
if ($Content) {
    $Content | Where-Object { $_ } | ForEach-Object {
        [PSCustomObject] @{
            Hostname     = $LocalHost
            DisplayName  = $_.DisplayName
            ProductState = $_.ProductState
        } | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_avproduct_found'
}