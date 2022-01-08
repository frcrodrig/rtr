$Obj=gwmi -ClassName Win32_Baseboard -EA 0|select Manufacturer,Product,Model,SerialNumber|%{
    [PSCustomObject]@{Manufacturer=$_.Manufacturer;Product=$_.Product;Model=$_.Model;SerialNumber=$_.SerialNumber}
}
$Out=[PSCustomObject]@{Host=[System.Net.Dns]::GetHostname();Script='get_baseboard.ps1';Message='no_baseboard'}
if(gcm shumio -EA 0){
    if($Obj){shumio $Obj;$Out|%{$_.Message='check_humio';$_|ConvertTo-Json -Compress}
   }else{$Out|%{shumio ($_|select Script,Message);Write-Error $_.Message}}
}elseif($Obj){
    $Obj|%{$_.PSObject.Properties.Add((New-Object PSNoteProperty('Host',$Out.Host)));$_|ConvertTo-Json -Compress}
}else{Write-Error $Out.Message}