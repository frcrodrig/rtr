$Obj=@(@(Get-NetTcpConnection -EA 0|select LocalAddress,LocalPort,RemoteAddress,RemotePort,State,OwningProcess)+
@(Get-NetUDPEndpoint -EA 0|select LocalAddress,LocalPort))
$Obj=$Obj|%{[PSCustomObject]@{Protocol=if($_.State){'TCP'}else{'UDP'};LocalAddress=$_.LocalAddress;
LocalPort=$_.LocalPort;RemoteAddress=$_.RemoteAddress;RemotePort=$_.RemotePort;State=$_.State;
OwningProcess=$_.OwningProcess}}
$Out=[PSCustomObject]@{Host=[System.Net.Dns]::GetHostname();Script='get_network_port.ps1';
Message='no_network_port'}
if(gcm shumio -EA 0){
if($Obj){shumio $Obj;$Out|%{$_.Message='check_humio';$_|ConvertTo-Json -Compress}
}else{$Out|%{shumio ($_|select Script,Message);Write-Error $_.Message}}
}elseif($Obj){
$Obj|%{$_.PSObject.Properties.Add((New-Object PSNoteProperty('Host',$Out.Host)));$_|ConvertTo-Json -Compress}
}else{Write-Error $Out.Message}