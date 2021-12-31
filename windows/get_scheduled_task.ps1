$LocalHost = [System.Net.Dns]::GetHostname()
$Content = Get-ChildItem -Path "$($env:SYSTEMROOT)\System32\Tasks" -File -Recurse -ErrorAction SilentlyContinue |
    Select-Object Name, FullName
if ($Content) {
    foreach ($Task in $Content) {
        foreach ($Xml in ([xml] (Get-Content $Task.FullName))) {
            [PSCustomObject] @{
                Hostname  = $LocalHost
                Name      = $Task.Name
                UserId    = $Xml.Task.Principals.Principal.UserId
                Author    = $Xml.Task.RegistrationInfo.Author
                Enabled   = $Xml.Task.Settings.Enabled
                Command   = $Xml.Task.Actions.Exec.Command
                Arguments = $Xml.Task.Actions.Exec.Arguments
            } | ConvertTo-Json -Compress
        }
    }
} else {
    Write-Error 'no_scheduled_task_found'
}