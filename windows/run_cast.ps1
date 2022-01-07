$ScriptBlock = {
    if (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue) {
        Send-ToHumio (@{ Started = 'C:\cast.exe' })
    }
    $Scan = C:\cast.exe scan C:\ *>&1
    if ($Scan -and (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue)) {
        Send-ToHumio @($Scan)
    } elseif ($Scan) {
        $Scan >> C:\cast.json
    }
    if (Test-Path 'C:\cast.exe') {
        Remove-Item -Path 'C:\cast.exe'
        if (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue) { 
            $ExeStatus = if (Test-Path -Path 'C:\cast.exe') { 'Failed_To_Remove' } else { 'Removed' }
            Send-HumioEvent (@{ $ExeStatus = 'C:\cast.exe' })
        }
    }
}
if ((Test-Path 'C:\cast.exe') -eq $false) {
    throw "'cast.exe' not found. Use 'put' to deliver it to 'C:\' before continuing."
}
Start-Process -FilePath powershell.exe -ArgumentList "-Command &{$ScriptBlock}" -PassThru |
ForEach-Object {
    [PSCustomObject] @{
        Host        = [System.Net.Dns]::GetHostname()
        Id          = $_.Id
        ProcessName = $_.ProcessName
        Message     = 'search_started'
    } | ConvertTo-Json -Compress
}