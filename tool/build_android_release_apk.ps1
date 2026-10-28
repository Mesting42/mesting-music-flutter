param(
    [ValidatePattern('^\d+\.\d+\.\d+$')][string]$VersionName = '1.0.9',
    [ValidateRange(30, 2147483647)][int]$VersionCode = 30,
    [string]$FlutterSdkRoot = $env:MESTING_BETA_FLUTTER_ROOT
)
$ErrorActionPreference = 'Stop'
# The notes travel inside the APK for older clients to inspect via bounded
# Range reads. Refuse a future release whose text still names an older build.
$musicNotesPath = Join-Path $PSScriptRoot '../assets/data/release-notes.json'
$musicReleaseNotes = Get-Content -LiteralPath $musicNotesPath -Raw | ConvertFrom-Json
if ($musicReleaseNotes.version -ne $VersionName -or $musicReleaseNotes.versionCode -ne $VersionCode -or @($musicReleaseNotes.releaseNotes).Count -eq 0) {
    throw 'Update assets/data/release-notes.json to match this public version and Android code before building.'
}
# Public release entry. Keep the established internal identity so this APK
# replaces 1.0.1 instead of installing another app with a separate data store.
& (Join-Path $PSScriptRoot 'build_android_md3_beta_apk.ps1') `
    -VersionName $VersionName -VersionCode $VersionCode -Mode release `
    -FlutterSdkRoot $FlutterSdkRoot
