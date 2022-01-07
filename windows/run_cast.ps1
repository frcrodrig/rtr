$ScriptBlock = {
    if (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue) {
        C:\cast.exe scan C:\ *>&1 | ForEach-Object {
            Send-ToHumio $_
        }
    } else {
        $Param = @{
            FilePath               = 'C:\cast.exe'
            ArgumentList           = 'scan C:\'
            RedirectStandardOutput = 'C:\cast.json'
        }
        Start-Process @Param
    }
    if (Test-Path 'C:\cast.exe') {
        Remove-Item -Path 'C:\cast.exe'
    }
    if (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue) { 
        $ExeStatus = if (Test-Path -Path 'C:\cast.exe') { 'Failed_To_Remove' } else { 'Removed' }
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