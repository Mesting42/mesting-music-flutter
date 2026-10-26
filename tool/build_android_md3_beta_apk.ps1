param(
    [string]$VersionName = '1.0.37-beta.2',
    [ValidateRange(1, 2147483647)][int]$VersionCode = 2,
    [ValidateSet('debug', 'release')][string]$Mode = 'release',
    [string]$TargetPlatform = 'android-arm,android-arm64'
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$appRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
Push-Location -LiteralPath $appRoot
try {
    # No deployment, manifest write or formal build is performed by this tool.
    # Channel identity is also enforced from Flutter's generated appFlavor.
    & flutter build apk "--$Mode" --flavor beta `
        "--target-platform=$TargetPlatform" `
        "--build-name=$VersionName" "--build-number=$VersionCode" `
        '--dart-define=USE_CLOUDBASE_AUTH=true' `
        '--dart-define=ENABLE_APP_UPDATE_CHECKS=false' `
        '--dart-define=APP_UPDATE_PACKAGE_NAME=com.mesting.music.beta'
    if ($LASTEXITCODE -ne 0) { throw 'Beta APK build failed.' }
    $source = Join-Path $appRoot "build\app\outputs\flutter-apk\app-beta-$Mode.apk"
    if (!(Test-Path -LiteralPath $source -PathType Leaf)) { throw "Missing APK: $source" }
    Write-Output "Beta APK: $source"
    Get-FileHash -Algorithm SHA256 -LiteralPath $source | Format-List
} finally {
    Pop-Location
}
