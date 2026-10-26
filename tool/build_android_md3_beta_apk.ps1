param(
    [string]$VersionName = '1.0.37-beta.8',
    [ValidateRange(1, 2147483647)][int]$VersionCode = 8,
    [ValidateSet('debug', 'release')][string]$Mode = 'release',
    [string]$TargetPlatform = 'android-arm,android-arm64',
    [string]$FlutterSdkRoot = $env:MESTING_BETA_FLUTTER_ROOT
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$appRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
Push-Location -LiteralPath $appRoot
try {
    # This is a process-local SDK selection. The existing formal build SDK and
    # the user's global PATH remain unchanged. Reproduction uses Flutter 3.41.9.
    $flutterCommand = if ($FlutterSdkRoot) {
        Join-Path $FlutterSdkRoot 'bin\flutter.bat'
    } else {
        (Get-Command flutter -ErrorAction Stop).Source
    }
    $sdk = & $flutterCommand --version --machine | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0) { throw 'Cannot read Flutter SDK version.' }
    if ([version]$sdk.frameworkVersion -lt [version]'3.41.0') {
        throw 'Beta requires Flutter >= 3.41.0. Use -FlutterSdkRoot with the independent Flutter 3.41.9 SDK.'
    }
    # No deployment, manifest write or formal build is performed by this tool.
    # Channel identity is also enforced from Flutter's generated appFlavor.
    & $flutterCommand build apk "--$Mode" --flavor beta `
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
