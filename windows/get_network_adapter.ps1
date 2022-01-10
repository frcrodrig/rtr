$Obj=Get-NetAdapter -EA 0|%{$Ip=Get-NetIpAddress -InterfaceIndex $_.IfIndex|select IPAddress,AddressFamily;
[PSCustomObject]@{Name=$_.Name;IfIndex=$_.IfIndex;MacAddress=$_.MacAddress;LinkSpeed=$_.LinkSpeed;
Virtual=$_.Virtual;Status=$_.Status;MediaConnectionState=$_.MediaConnectionState;FullDuplex=$_.FullDuplex;
DriverName=$_.DriverName;DriverVersionString=$_.DriverVersionString;Ipv4Address=($Ip|?{$_.AddressFamily -eq
'IPv4'}).IPAddress;Ipv6Address=($Ip|?{$_.AddressFamily -eq 'IPv6'}).IPAddress}}
$Out=[PSCustomObject]@{Host=[System.Net.Dns]::GetHostname();Script='get_network_adapter.ps1';
Message='no_network_adapter'}
if(gcm shumio -EA 0){
if($Obj){shumio $Obj;$Out|%{$_.Message='check_humio';$_|ConvertTo-Json -Compress}
}else{$Out|%{shumio ($_|select Script,Message);Write-Error $_.Message}}
}elseif($Obj){
$Obj|%{$_.PSObject.Properties.Add((New-Object PSNoteProperty('Host',$Out.Host)));$_|ConvertTo-Json -Compress}
}else{Write-Error $Out.Message}