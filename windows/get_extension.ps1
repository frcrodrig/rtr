$LocalHost = [System.Net.Dns]::GetHostname()
$Browsers = @{
    Chrome = 'AppData\Local\Google\Chrome\User Data\Default\Extensions'
    Edge   = 'AppData\Local\Microsoft\Edge\User Data\Default\Extensions'
}
$Content = foreach ($Path in (Get-WmiObject win32_userprofile |
Where-Object localpath -notmatch 'Windows').localpath) {
    foreach ($Pair in $Browsers.GetEnumerator()) {
        $Target = Join-Path -Path $Path -ChildPath $Pair.Value
        if (Test-Path -Path $Target) {
            foreach ($Folder in (Get-ChildItem $Target | Where-Object { $_.Name -ne 'Temp' })) {
                foreach ($Result in (Get-ChildItem -Path $Folder.FullName)) {
                    $Manifest = Join-Path -Path $Result.FullName -ChildPath manifest.json
                    if (Test-Path -Path $Manifest) {
                        Get-Content $Manifest | ConvertFrom-Json | ForEach-Object {
                            [PSCustomObject] @{
                                Hostname  = $LocalHost
                                Username  = $Path | Split-Path -Leaf
                                Browser   = $Pair.Key
                                Extension = if ($_.Name -notlike '__MSG*') {
                                    $_.Name
                                } else {
                                    $Id = ($_.Name -replace '__MSG_','').Trim('_')
                                    @('_locales\en_US','_locales\en').foreach{
                                        $Messages = Join-Path -Path $Result.Fullname -ChildPath $_
                                        $Messages = Join-Path -Path $Messages -ChildPath messages.json
                                        if (Test-Path -Path $Messages) {
                                            $Content = Get-Content $Messages | ConvertFrom-Json
                                            (@('appName','extName','extensionName','app_name',
                                            'application_title',$Id).foreach{
                                                if ($Content.$_.message) {
                                                    $Content.$_.message
                                                }
                                            }) | Select-Object -First 1
                                        }
                                    }
                                }
                                Version   = $_.Version
                                Id        = $Folder.Name
                            }
                        }
                    }
                }
            }
        }
    }
}
if ($Content -and (Get-Command -Name Send-ToHumio -ErrorAction SilentlyContinue)) {
    Send-ToHumio $Content
    ConvertTo-Json -InputObject ([PSCustomObject] @{
        Host    = $LocalHost
        Script  = 'get_extension.ps1'
        Message = 'check_humio_for_result'
    }) -Compress
} elseif ($Content) {
    $Content | ForEach-Object {
        $_ | ConvertTo-Json -Compress
    }
} else {
    Write-Error 'no_extension_found'
}