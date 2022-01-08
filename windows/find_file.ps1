[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 1)]
    [ValidateScript({ Test-Path $_ })]
    [string] $Path,

    [Parameter(Mandatory = $true, Position = 2)]
    [string] $Filter,

    [Parameter(Position = 3)]
    [string] $Include,

    [Parameter(Position = 4)]
    [string] $Exclude,

    [Parameter(Position = 5)]
    [System.Uri] $HumioUri,

    [Parameter(Position = 6)]
    [ValidatePattern('^\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$')]
    [string] $HumioToken
)
begin {
    $ScriptBlock = {
        param($Path, $Filter, $Include, $Exclude, $HumioUri, $HumioToken)
        function Send-HumioEvent ($Result, $HumioUri, $HumioToken) {
            $Fields = @{
                host   = [System.Net.Dns]::GetHostname()
                script = 'find_file.ps1'
            }
            $IdPath = 'HKLM:\SYSTEM\CrowdStrike\{9b03c1d9-3138-44ed-9fae-d9f4c034b88d}\'+
                '{16e0423f-7058-48c9-a204-725362b67639}\Default'
            if (Test-Path $IdPath) {
                $Fields.Add('cid',([System.BitConverter]::ToString((
                    (Get-ItemProperty $IdPath -Name CU).CU)).ToLower() -replace '-',''))
                $Fields.Add('aid',([System.BitConverter]::ToString((
                    (Get-ItemProperty $IdPath -Name AG).AG)).ToLower() -replace '-',''))
            }
            $Request = @{
                Uri             = $HumioUri
                Method          = 'post'
                Headers         = @{ authorization  = (@('bearer', $HumioToken) -join ' ') }
                Body            = @{ fields = $Fields; messages = $Result }
                UseBasicParsing = $true
            }
            $Request.Body = $Request.Body | ConvertTo-Json -Compress
            [void](Invoke-WebRequest @Request)
        }
        $Param = @{
            File        = $true
            Recurse     = $true
            ErrorAction = 'SilentlyContinue'
        }
        $PSBoundParameters.GetEnumerator().Where({ $_.Key -notmatch 'Humio' }).foreach{
            $Param[$_.Key] = $_.Value
        }
        Get-ChildItem @Param | Select-Object FullName, CreationTime, LastWriteTime, LastAccessTime |
        ForEach-Object {
            $Result = [PSCustomObject]@{
                FullName          = $_.FullName
                CreationTimeUtc   = $_.CreationTime.ToFileTimeUtc()
                LastWriteTimeUtc  = $_.LastWriteTime.ToFileTimeUtc()
                LastAccessTimeUtc = $_.LastAccessTime.ToFileTimeUtc()
                Sha256            = (Get-FileHash -Path $_.FullName -Algorithm Sha256).Hash.ToLower()
            }
            if ($HumioUri -and $HumioToken) {
                Send-HumioEvent $Result $HumioUri $HumioToken
            } else {
                $Result | Export-Csv -Path (Join-Path -Path $env:SystemDrive -ChildPath "find_file_$(
                    Get-Date -Format FileDate).csv") -NoTypeInformation -Append
            }
        }
    }
    $Arguments = ($PSBoundParameters.GetEnumerator().foreach{
        "-$($_.Key) '$($_.Value)'"
    }) -join ' '
}
process {
    Start-Process -FilePath powershell.exe -ArgumentList "-Command &{ $ScriptBlock } $Arguments" -PassThru |
    ForEach-Object {
        [PSCustomObject]@{
            Hostname = [System.Net.Dns]::GetHostname()
            Pid      = $_.Id
            Process  = $_.Name
            Message  = if ($HumioUri -and $HumioToken) {
                'check_humio'
            } else {
                Join-Path -Path $env:SystemDrive -ChildPath "find_file_$(Get-Date -Format FileDate).csv"
            }
        } | ConvertTo-Json -Compress
    }
}