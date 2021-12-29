$Browsers = @{
    Chrome = 'AppData\Local\Google\Chrome\User Data\Default\Extensions'
    Edge   = 'AppData\Local\Microsoft\Edge\User Data\Default\Extensions'
}
foreach ($UserPath in (Get-WmiObject win32_userprofile | Where-Object {
$_.localpath -notmatch 'Windows' }).localpath) {
    foreach ($Pair in $Browsers.GetEnumerator()) {
        $TargetPath = Join-Path -Path $UserPath -ChildPath $Pair.Value
        if (Test-Path -Path $TargetPath) {
            foreach ($ExtFolder in (Get-Childitem $TargetPath | Where-Object { $_.Name -ne 'Temp' })) {
                foreach ($Version in (Get-Childitem -Path $ExtFolder.FullName)) {
                    $ManifestPath = Join-Path -Path $Version.FullName -ChildPath manifest.json
                    if (Test-Path -Path $ManifestPath) {
                        $Manifest = Get-Content $ManifestPath | ConvertFrom-Json
                        [PSCustomObject] @{
                            Username      = $UserPath | Split-Path -Leaf
                            Extension     = $Extension
                            Version       = $Manifest.version
                            Folder        = $Folder.name
                            ExtensionName = if ($Manifest.name -like '__MSG*') {
                                $AppId = ($Manifest.name -replace '__MSG_','').Trim('_')
                                @('_locales\en_US','_locales\en').foreach{
                                    $Messages = Join-Path -Path $Version.Fullname -ChildPath $_
                                    $Messages = Join-Path -Path $Messages -ChildPath messages.json
                                    if (Test-Path -Path $Messages) {
                                        $AppManifest = Get-Content $Messages | ConvertFrom-Json
                                        $ExtName = @('appName','extName','extensionName','app_name',
                                        'application_title',$AppId).foreach{
                                            if ($AppManifest.$_.message) {
                                                $AppManifest.$_.message
                                            }
                                        }
                                        $ExtName | Select-Object -First 1
                                    }
                                }
                            } else {
                                $Manifest.name
                            }
                        }
                    }
                }
            }
        }
    }
}