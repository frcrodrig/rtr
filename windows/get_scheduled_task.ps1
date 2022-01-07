$LocalHost = [System.Net.Dns]::GetHostname()
$Content = foreach ($Task in (Get-ChildItem -Path "$($env:SYSTEMROOT)\System32\Tasks" -File -Recurse -ErrorAction '
SilentlyContinue' | Select-Object Name, FullName)) {
    foreach ($Xml in ([xml] (Get-Content $Task.FullName))) {
        [PSCustomObject] @{
            Host      = $LocalHost
            Name      = $Task.Name
            UserId    = $Xml.Task.Principals.Principal.UserId
            Author    = $Xml.Task.RegistrationInfo.Author
            Enabled   = $Xml.Task.Settings.Enabled
            Command   = $Xml.Task.Actions.Exec.Command
            Arguments = $Xml.Task.Actions.Exec.Arguments
        }
    }
}
if ($Content -and (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue)) {
    Send-ToHumio $Content
    ConvertTo-Json -InputObject ([PSCustomObject] @{
        Host    = $LocalHost
        Script  = 'get_scheduled_task.ps1'
        Message = 'check_humio_for_result'
    }) -Compress
} elseif ($Content) {
    $Content | ForEach-Object {
        $_ | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_scheduled_task_found'
}