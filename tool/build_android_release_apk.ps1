param(
    [ValidatePattern('^\d+\.\d+\.\d+$')][string]$VersionName = '1.0.2',
    [ValidateRange(23, 2147483647)][int]$VersionCode = 23,
    [string]$FlutterSdkRoot = $env:MESTING_BETA_FLUTTER_ROOT
)
$ErrorActionPreference = 'Stop'
# Public release entry. Keep the established internal identity so this APK
# replaces 1.0.1 instead of installing another app with a separate data store.
& (Join-Path $PSScriptRoot 'build_android_md3_beta_apk.ps1') `
    -VersionName $VersionName -VersionCode $VersionCode -Mode release `
    -FlutterSdkRoot $FlutterSdkRoot
