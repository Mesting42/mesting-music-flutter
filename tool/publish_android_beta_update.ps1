param(
    [Parameter(Mandatory = $true)]
    [string]$VersionName,
    [Parameter(Mandatory = $true)]
    [int]$VersionCode,
    [Parameter(Mandatory = $true)]
    [string]$InputApkPath,
    [Parameter(Mandatory = $true)]
    [string[]]$ReleaseNotes,
    [string]$Title = 'Mesting Music Beta update',
    [int]$MinimumVersionCode = 1,
    [switch]$Mandatory,
    [string]$EnvironmentId = 'mesting-d5gm7tuhxacddccfb',
    [string]$HostingDomain = 'mesting-d5gm7tuhxacddccfb-1331507389.tcloudbaseapp.com'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if ($VersionName -notmatch '^[0-9]+\.[0-9]+\.[0-9]+$') {
    throw 'VersionName must use x.y.z format.'
}
if ($VersionCode -lt 1) {
    throw 'VersionCode must be greater than zero.'
}
if ($MinimumVersionCode -lt 1 -or $MinimumVersionCode -gt $VersionCode) {
    throw 'MinimumVersionCode must be between 1 and VersionCode.'
}

$normalizedNotes = @(
    $ReleaseNotes |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ }
)
if ($normalizedNotes.Count -eq 0) {
    throw 'At least one non-empty release note is required.'
}

$appRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$apkPath = (Resolve-Path -LiteralPath $InputApkPath).Path
$apk = Get-Item -LiteralPath $apkPath
$sha256 = (Get-FileHash -LiteralPath $apk.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
$remoteDirectory = 'releases/android/beta'
$fileName = "mesting-music-beta-$VersionName-$VersionCode.apk"
$remoteApkPath = "$remoteDirectory/$fileName"
$apkUrl = "https://$HostingDomain/$remoteApkPath"
$manifestDirectory = Join-Path $appRoot 'build\app_update\beta'
[IO.Directory]::CreateDirectory($manifestDirectory) | Out-Null
$manifestPath = Join-Path $manifestDirectory 'latest.json'

$manifest = [ordered]@{
    packageName = 'com.mesting.music.beta'
    versionName = $VersionName
    versionCode = $VersionCode
    minimumVersionCode = $MinimumVersionCode
    mandatory = [bool]$Mandatory
    title = $Title
    releaseNotes = $normalizedNotes
    apkUrl = $apkUrl
    sha256 = $sha256
    sizeBytes = [long]$apk.Length
    publishedAt = [DateTimeOffset]::Now.ToString('o')
}
[IO.File]::WriteAllText(
    $manifestPath,
    ($manifest | ConvertTo-Json -Depth 5) + [Environment]::NewLine,
    [Text.UTF8Encoding]::new($false)
)

Push-Location -LiteralPath $appRoot
try {
    # The immutable APK and version manifest must arrive before latest.json.
    & tcb hosting deploy $apk.FullName $remoteApkPath -e $EnvironmentId --retry-count 3 --json
    if ($LASTEXITCODE -ne 0) { throw 'Beta APK upload failed.' }

    $versionManifestPath = "$remoteDirectory/manifests/$VersionCode.json"
    & tcb hosting deploy $manifestPath $versionManifestPath -e $EnvironmentId --retry-count 3 --json
    if ($LASTEXITCODE -ne 0) { throw 'Beta archived manifest upload failed.' }

    & tcb hosting deploy $manifestPath "$remoteDirectory/latest.json" -e $EnvironmentId --retry-count 3 --json
    if ($LASTEXITCODE -ne 0) { throw 'Beta latest.json publish failed.' }

    Write-Output "Published Mesting Music Beta $VersionName ($VersionCode)"
    Write-Output "APK: $apkUrl"
    Write-Output "Manifest: https://$HostingDomain/$remoteDirectory/latest.json"
    Write-Output "SHA-256: $sha256"
} finally {
    Pop-Location
}
