$ScriptBlock = {
    Start-Process 'C:\cast.exe' -ArgumentList 'scan C:\' -RedirectStandardOutput 'C:\cast.json' -PassThru |
    ForEach-Object {
        if (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue) {
            Send-ToHumio (@{ Started = 'C:\cast.exe' })
        }
        Wait-Process $_.Id
        if ((Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue) -and (Test-Path 'C:\cast.json')) {
            (Get-Content 'C:\cast.json').Normalize() | ForEach-Object {
                Send-ToHumio @($_)
            }
            Remove-Item -Path 'C:\cast.json'
            $JsonStatus = if (Test-Path -Path 'C:\cast.json') { 'Failed_To_Remove' } else { 'Removed' }
            Send-HumioEvent (@{ $JsonStatus = 'C:\cast.json' })
        }
        if (Test-Path 'C:\cast.exe') {
            Remove-Item -Path 'C:\cast.exe'
            if (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue) { 
                $ExeStatus = if (Test-Path -Path 'C:\cast.exe') { 'Failed_To_Remove' } else { 'Removed' }
                Send-HumioEvent (@{ $ExeStatus = 'C:\cast.exe' })
            }
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