param(
    [string]$VersionName = '1.0.0',
    [int]$VersionCode = 1,
    [string]$AuthApiBaseUrl = 'http://106.54.124.197'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if ($VersionName -notmatch '^[0-9]+\.[0-9]+\.[0-9]+$') {
    throw 'VersionName must use x.y.z format.'
}
if ($VersionCode -lt 1) {
    throw 'VersionCode must be greater than zero.'
}

$appRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$jdkHome = 'C:\Program Files\Android\Android Studio\jbr'
$gradleHome = Join-Path $appRoot 'build\release-gradle-home-33'
if (-not (Test-Path -LiteralPath $jdkHome -PathType Container)) {
    throw "Android Studio JBR was not found: $jdkHome"
}
if (-not (Test-Path -LiteralPath $gradleHome -PathType Container)) {
    throw "Project Gradle cache was not found: $gradleHome"
}

Push-Location -LiteralPath $appRoot
try {
    $env:JAVA_HOME = $jdkHome
    $env:GRADLE_USER_HOME = $gradleHome
    & flutter build apk `
        --debug `
        --target-platform 'android-arm,android-arm64' `
        --build-name $VersionName `
        --build-number $VersionCode `
        "--dart-define=AUTH_API_BASE_URL=$AuthApiBaseUrl" `
        '--dart-define=ENABLE_APP_UPDATE_CHECKS=true' `
        '--dart-define=APP_UPDATE_PACKAGE_NAME=com.mesting.music.beta' `
        '--dart-define=APP_UPDATE_MANIFEST_URL=https://mesting-d5gm7tuhxacddccfb-1331507389.tcloudbaseapp.com/releases/android/beta/latest.json'
    if ($LASTEXITCODE -ne 0) {
        throw 'Beta APK build failed.'
    }

    $apkPath = Join-Path $appRoot 'build\app\outputs\flutter-apk\app-debug.apk'
    if (-not (Test-Path -LiteralPath $apkPath -PathType Leaf)) {
        throw "Beta APK was not found: $apkPath"
    }

    $archiveDirectory = Join-Path $appRoot 'build\beta_apk'
    [IO.Directory]::CreateDirectory($archiveDirectory) | Out-Null
    $archivePath = Join-Path $archiveDirectory "Mesting-Music-Beta-v$VersionName-build$VersionCode.apk"
    Copy-Item -LiteralPath $apkPath -Destination $archivePath -Force
    Write-Output "Built Beta APK: $archivePath"
} finally {
    Pop-Location
}
