$CastPath = 'C:\cast.exe'
if ((Test-Path $CastPath) -eq $false) {
    throw "'cast.exe' not found. Use 'put' to deliver it to '$CastPath' before continuing."
}
$ScriptBlock = {
    $JsonPath = 'C:\cast.json'
    Start-Process $CastPath -ArgumentList 'scan C:\' -RedirectStandardOutput $JsonPath -PassThru | ForEach-Object {
        if (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue) {
            Send-ToHumio (@{ Started = $CastPath })
        }
        Wait-Process $_.Id
        if ((Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue) -and (Test-Path $JsonPath)) {
            (Get-Content $JsonPath).Normalize() | ForEach-Object {
                Send-ToHumio @($_)
                Remove-Item -Path $JsonPath
                $JsonStatus = if (Test-Path -Path $JsonPath) { 'Failed_To_Remove' } else { 'Removed' }
                Send-HumioEvent (@{ $JsonStatus = $JsonPath })
            }
        }
        if (Test-Path $CastPath) {
            Remove-Item -Path $CastPath
            if (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue) { 
                $CastStatus = if (Test-Path -Path $CastPath) { 'Failed_To_Remove' } else { 'Removed' }
                Send-HumioEvent (@{ $CastStatus = $CastPath })
            }
        }
    }
}
$ArgumentList = '-Command &{' + $ScriptBlock + '} -CastPath ' + $CastPath
Start-Process -FilePath powershell.exe -ArgumentList $ArgumentList -PassThru | ForEach-Object {
    [PSCustomObject] @{
        Host        = [System.Net.Dns]::GetHostname()
        Id          = $_.Id
        ProcessName = $_.ProcessName
        Message     = 'search_started'
    } | ConvertTo-Json -Compress
}