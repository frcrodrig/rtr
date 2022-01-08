$Obj=gwmi -ClassName Win32_Processor -EA 0|%{[PSCustomObject]@{ProcessorId=$_.ProcessorId;Caption=$_.Caption;
    DeviceID=$_.DeviceID;Manufacturer=$_.Manufacturer;MaxClockSpeed=$_.MaxClockSpeed;Name=$_.Name;
    SocketDesignation=$_.SocketDesignation }}
$Out=[PSCustomObject]@{Host=[System.Net.Dns]::GetHostname();Script='get_processor.ps1';Message='no_processor'}
if(gcm shumio -EA 0){
    if($Obj){shumio $Obj;$Out|%{$_.Message='check_humio';$_|ConvertTo-Json -Compress}
    }else{$Out|%{shumio ($_|select Script, Message);Write-Error $_.Message}}
}elseif($Obj){
    $Obj|%{$_.PSObject.Properties.Add((New-Object PSNoteProperty('Host',$Out.Host)));$_|ConvertTo-Json -Compress}
}else{Write-Error $Out.Message}