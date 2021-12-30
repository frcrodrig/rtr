foreach ($Task in (Get-ChildItem -Path "$($env:SYSTEMROOT)\System32\Tasks" -File -Recurse |
Select-Object Name, FullName)) {
    [xml] (Get-Content $Task.FullName) | ForEach-Object {
        [PSCustomObject] @{
            Task      = $Task.Name
            UserId    = $_.Task.Principals.Principal.UserId
            Author    = $_.Task.RegistrationInfo.Author
            Enabled   = $_.Task.Settings.Enabled
            Command   = $_.Task.Actions.Exec.Command
            Arguments = $_.Task.Actions.Exec.Arguments
        } | Out-String
    }
}