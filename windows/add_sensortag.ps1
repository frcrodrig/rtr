[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 1)]
    [ValidateScript({ Test-Path $_ })]
    [array] $Tags,

    [Parameter(Position = 2)]
    [System.Uri] $HumioUri,

    [Parameter(Position = 3)]
    [ValidatePattern('^\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$')]
    [string] $HumioToken
)
begin {
    $ScriptBlock = {
        param($Tags, $HumioUri, $HumioToken)
        function Send-HumioEvent ($Result, $HumioUri, $HumioToken) {
            $Fields = @{
                host   = [System.Net.Dns]::GetHostname()
                script = 'add_sensortag.ps1'
            }
            $IdPath = 'HKLM:\SYSTEM\CrowdStrike\{9b03c1d9-3138-44ed-9fae-d9f4c034b88d}\' +
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
            $Request.Body = ConvertTo-Json -InputObject $Request.Body -Compress
            [void] (Invoke-WebRequest @Request)
        }
        $Key = 'HKEY_LOCAL_MACHINE\SYSTEM\CrowdStrike\{9b03c1d9-3138-44ed-9fae-d9f4c034b88d}\' +
            '{16e0423f-7058-48c9-a204-725362b67639}\Default'
        $Current = (reg query $Key) -match 'GroupingTags'
        $Value = if ($Current) {
            (($Current -split 'REG_SZ')[-1].Trim().Split(',') + $Tags.Split(',') | Select-Object -Unique) -join ','
        } else {
            $Tags
        }
        [void] (reg add $Key /v GroupingTags /d $Value /f)
        Send-HumioEvent ([PSCustomObject] @{
            Hostname   = [System.Net.Dns]::GetHostname()
            SensorTag  = "$((((reg query $Key) -match 'GroupingTags') -split 'REG_SZ')[-1].Trim())"
        } | ConvertTo-Json -Compress) $HumioUri $HumioToken
    }
    $Arguments = ($PSBoundParameters.GetEnumerator().foreach{
        "-$($_.Key) '$($_.Value)'"
    }) -join ' '
}
process {
    if ($HumioUri -and $HumioToken) {
        Start-Process -FilePath powershell.exe -ArgumentList "-Command &{ $ScriptBlock } $Arguments" -PassThru |
        ForEach-Object {
            [PSCustomObject] @{
                Hostname = [System.Net.Dns]::GetHostname()
                Pid      = $_.Id
                Process  = $_.Name
                Message  = 'check_humio_for_event'
            } | ConvertTo-Json -Compress
        }
    } else {
        $Key = 'HKEY_LOCAL_MACHINE\SYSTEM\CrowdStrike\{9b03c1d9-3138-44ed-9fae-d9f4c034b88d}\' +
            '{16e0423f-7058-48c9-a204-725362b67639}\Default'
        $Current = (reg query $Key) -match 'GroupingTags'
        $Value = if ($Current) {
            (($Current -split 'REG_SZ')[-1].Trim().Split(',') + $Tags.Split(',') | Select-Object -Unique) -join ','
        } else {
            $Tags
        }
        [void] (reg add $Key /v GroupingTags /d $Value /f)
        [PSCustomObject] @{
            Hostname   = [System.Net.Dns]::GetHostname()
            SensorTag  = "$((((reg query $Key) -match 'GroupingTags') -split 'REG_SZ')[-1].Trim())"
        } | ConvertTo-Json -Compress
    }
}