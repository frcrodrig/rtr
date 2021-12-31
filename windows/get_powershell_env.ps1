$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-Item -Path env:
if ($Content) {
    $Item = [PSCustomObject] @{ Hostname = $LocalHost }
    $Content.GetEnumerator().foreach{
        $Item.PSObject.Properties.Add((New-Object PSNoteProperty($_.Name, $_.Value)))
    }
    $Item | ConvertTo-Json -Compress
} else {
    Write-Error 'no_item_found'
}