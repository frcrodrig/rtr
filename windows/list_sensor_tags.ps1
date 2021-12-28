$Tags = (reg query ("HKEY_LOCAL_MACHINE\SYSTEM\CrowdStrike\{9b03c1d9-3138-44ed-9fae-d9f4c034b88d}\" +
    "{16e0423f-7058-48c9-a204-725362b67639}\Default")) -match "GroupingTags"
if ($Tags) {
    Write-Output "$(($Tags -split "REG_SZ")[-1].Trim())"
}