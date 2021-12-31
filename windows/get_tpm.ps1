$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-Tpm
if ($Content) {
    $Item = [PSCustomObject] @{ Hostname = $LocalHost }
    $Content.PSObject.Properties.Where({ $_.MemberType -eq 'Property' }) | ForEach-Object {
        $Item.PSObject.Properties.Add((New-Object PSNoteProperty($_.Name, $_.Value)))
    }
    $Item | ConvertTo-Json -Compress
} else {
    Write-Error 'no_tpm_found'
}