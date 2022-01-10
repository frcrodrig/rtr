$Tbl=@{Chrome='AppData\Local\Google\Chrome\User Data\Default\Extensions';
Edge='AppData\Local\Microsoft\Edge\User Data\Default\Extensions'}
$Obj=foreach ($User in (gwmi win32_userprofile|? localpath -notmatch 'Windows').localpath) {
foreach ($Pair in $Tbl.GetEnumerator()){$Path=Join-Path -Path $User -ChildPath $Pair.Value;
if (Test-Path -Path $Path){
foreach ($Fold in (Get-ChildItem $Path|?{$_.Name -ne 'Temp'})) {
foreach ($Item in (Get-ChildItem -Path $Fold.FullName)) {
$Json=Join-Path -Path $Item.FullName -ChildPath manifest.json;if (Test-Path -Path $Json) {
Get-Content $Json|ConvertFrom-Json|%{[PSCustomObject]@{Username=($User|Split-Path -Leaf);
Browser=$Pair.Key;Extension=if($_.Name -notlike '__MSG*'){$_.Name}else{
$Id=($_.Name -replace '__MSG_','').Trim('_');@('_locales\en_US','_locales\en').foreach{
$Msg=Join-Path -Path (Join-Path -Path $Item.Fullname -ChildPath $_) -ChildPath messages.json
if(Test-Path -Path $Msg){$App=Get-Content $Msg|ConvertFrom-Json;(@('appName','extName','extensionName','app_name',
'application_title',$Id).foreach{if($App.$_.message){$App.$_.message}})|select -First 1}}};Version=$_.Version;
Id=$Fold.Name}}}}}}}}
$Out=[PSCustomObject]@{Host=[System.Net.Dns]::GetHostname();Script='get_extension.ps1';Message='no_extension'}
if(gcm shumio -EA 0){
if($Obj){shumio $Obj;$Out|%{$_.Message='check_humio';$_|ConvertTo-Json -Compress}
}else{$Out|%{shumio ($_|select Script,Message);Write-Error $_.Message}}
}elseif($Obj){
$Obj|%{$_.PSObject.Properties.Add((New-Object PSNoteProperty('Host',$Out.Host)));$_|ConvertTo-Json -Compress}
}else{Write-Error $Out.Message}