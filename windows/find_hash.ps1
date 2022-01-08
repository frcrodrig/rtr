[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position = 1)]
    [ValidateScript({ Test-Path $_ })]
    [string] $Path,

    [Parameter(Mandatory=$true, Position = 2)]
    [ValidatePattern('^\w{64}$')]
    [string] $Hash,

    [Parameter(Position = 5)]
    [System.Uri] $HumioUri,

    [Parameter(Position = 6)]
    [ValidatePattern('^\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$')]
    [string] $HumioToken
)
begin {
    $ScriptBlock = {
        param($Path, $Hash, $HumioUri, $HumioToken)
        function Send-HumioEvent ($Result, $HumioUri, $HumioToken) {
            $Fields = @{
                host   = [System.Net.Dns]::GetHostname()
                script = 'find_hash.ps1'
            }
            $IdPath = 'HKLM:\SYSTEM\CrowdStrike\{9b03c1d9-3138-44ed-9fae-d9f4c034b88d}\'+
                '{16e0423f-7058-48c9-a204-725362b67639}\Default'
            if (Test-Path $IdPath) {
                $Fields.Add('cid',([System.BitConverter]::ToString((
                    (gp $IdPath -Name CU).CU)).ToLower() -replace '-',''))
                $Fields.Add('aid',([System.BitConverter]::ToString((
                    (gp $IdPath -Name AG).AG)).ToLower() -replace '-',''))
            }
            $Request = @{
                Uri             = $HumioUri
                Method          = 'post'
                Headers         = @{ authorization  = (@('bearer', $HumioToken) -join ' ') }
                Body            = @{ fields = $Fields; messages = $Result }
                UseBasicParsing = $true
            }
            $Request.Body = ConvertTo-Json -InputObject $Request.Body -Compress
            [void](Invoke-WebRequest @Request)
        }
        $Param = @{
            Path        = $Path
            File        = $true
            Recurse     = $true
            ErrorAction = 'SilentlyContinue'
        }
        Get-ChildItem @Param | % {
            Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName | ? Hash -eq $Hash.ToUpper() |
            select Hash, Path | % {
                if ($HumioUri -and $HumioToken) {
                    Send-HumioEvent $_ $HumioUri $HumioToken
                }else{
                    $_ | Export-Csv -Path (Join-Path -Path $env:SystemDrive -ChildPath "find_hash_$(
                        Get-Date -Format FileDate).csv") -NoTypeInformation -Append
                }
            }
        }
    }
    $Arguments = ($PSBoundParameters.GetEnumerator().foreach{
        "-$($_.Key) '$($_.Value)'"
    }) -join ' '
}
process {
    Start-Process -FilePath powershell.exe -ArgumentList "-Command &{ $ScriptBlock } $Arguments" -PassThru |
    % {
        [PSCustomObject]@{
            Hostname = [System.Net.Dns]::GetHostname()
            Pid      = $_.Id
            Process  = $_.Name
            Message  =if($HumioUri -and $HumioToken) {
                'check_humio_for_events'
            }else{
                Join-Path -Path $env:SystemDrive -ChildPath "find_hash_$(Get-Date -Format FileDate).csv"
            }
        }|ConvertTo-Json -Compress
    }
}