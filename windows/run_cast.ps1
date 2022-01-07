$ScriptBlock = {
    if (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue) { 
        Send-ToHumio (@{ ProcessInit = 'C:\cast.exe' })
    }
    Start-Process -FilePath C:\cast.exe -ArgumentList 'scan C:\' -RedirectStandardOutput 'C:\cast.json' -Wait
    if (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue) { 
        Send-ToHumio @((Get-Content 'C:\cast.json').Normalize() -split '\n' | ForEach-Object {
            $_ | ConvertFrom-Json
        })
        $JsonStatus = if (Test-Path -Path 'C:\cast.json') { 'FailedToRemove' } else { 'Removed' }
        Send-ToHumio (@{ $JsonStatus = 'C:\cast.json' })
    }
    if (Test-Path 'C:\cast.exe') {
        Remove-Item -Path 'C:\cast.exe'
    }
    if (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue) { 
        $ExeStatus = if (Test-Path -Path 'C:\cast.exe') { 'FailedToRemove' } else { 'Removed' }
        Send-ToHumio (@{ $ExeStatus = 'C:\cast.exe' })
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