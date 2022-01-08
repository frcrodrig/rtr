$Def = @’
[DllImport("kernel32.dll", SetLastError = true)]
public static extern uint QueryDosDevice(
    string lpDeviceName,
    System.Text.StringBuilder lpTargetPath,
    uint ucchMax);
‘@
$StrBld=New-Object System.Text.StringBuilder(65535)
$K32=Add-Type -MemberDefinition $Def -Name Kernel32 -Namespace Win32 -PassThru
$Obj=Get-Volume -EA 0|select DriveLetter,FileSystemLabel,FileSystem,SizeRemaining|%{[PSCustomObject]@{
    DriveLetter=$_.DriveLetter;FileSystemLabel=$_.FileSystemLabel;FileSystem=$_.FileSystem;
    SizeRemaining=$_.SizeRemaining;NtPath=($K32::QueryDosDevice("$($_.DriveLetter):",$StrBld,255)).ToString()}}
$Out=[PSCustomObject]@{Host=[System.Net.Dns]::GetHostname();Script='get_volume.ps1';Message='no_volume'}
if(gcm shumio -EA 0){
    if($Obj){shumio $Obj;$Out|%{$_.Message='check_humio';$_|ConvertTo-Json -Compress}
    }else{$Out|%{shumio ($_|select Script, Message);Write-Error $_.Message}}
}elseif($Obj){
    $Obj|%{$_.PSObject.Properties.Add((New-Object PSNoteProperty('Host',$Out.Host)));$_|ConvertTo-Json -Compress}
}else{Write-Error $Out.Message}