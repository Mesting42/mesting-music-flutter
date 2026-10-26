# md3Music integration Beta handoff

This is the first Android Beta milestone. It keeps Mesting's existing interface
and audio handler and adapts the upstream local music API. It is not yet a
complete migration of every md3Music feature.

## Source baseline and provenance

- Mesting baseline: `flutter-music-v1.0.37-build58`, commit
  `1b669e8239f1641f5f008e8d286940142e6daf35`.
- Integration branch: `integration/md3music-beta`.
- Upstream md3Music: `a69503b84e8829f888684f67c163be03c589c014`,
  branch `rust-local-force`.
- Flutter used for this build: 3.38.6; Dart: 3.10.7; Java: 17-compatible
  Android Studio JBR; Android NDK: 28.2.13676358.
- `third_party/md3music` contains the original license, disclaimer and Rust
  server source. The three native libraries are upstream prebuilt artifacts;
  they have not been reproduced from source in this environment.
- The source ZIP is a working-tree snapshot, including tracked and untracked
  source files. It contains no `.git` directory. The separate Git bundle holds
  the history before integration. No integration commit is implied by the ZIP.

## Module boundaries

| Module | Responsibility |
| --- | --- |
| `core/platform/distribution_channel.dart` | Authoritative Flutter flavor, package identity and update channel |
| `features/music_platform/data/embedded_music_server.dart` | Lazy Android C ABI startup on a background isolate and loopback readiness |
| `features/music_platform/data/music_platform_api.dart` | Loopback HTTP, independent session headers, timeouts and safe errors |
| `features/music_platform/data/platform_session_store.dart` | Dedicated secure-storage key for the music platform |
| `features/music_platform/music_platform_providers.dart` | Account state and serialized credential writes/logout |
| `features/music_platform/data/embedded_kugou_music_source.dart` | Adapts search, rankings and fresh playback URLs to Mesting tracks |
| `features/music_platform/presentation/platform_account_page.dart` | Phone and QR login, account choice and independent logout |
| `core/audio/mesting_audio_handler.dart` | Existing playback queue with optional URL resolver callback |
| `features/lyrics/data/lyrics_repository.dart` | Injectable JSON transport with existing lyric fallbacks |
| `features/library/presentation/library_access.dart` | Beta local-library access without legacy cloud authentication |
| `android/app/src/beta` | Beta name, loopback network policy and native libraries only |

Keep platform credentials out of the Mesting account repository. Do not add a
second audio service. Do not call the server during global application startup:
network or native startup failures must leave the guest entry usable.

## Account and data rules

There are two independent accounts: the existing Mesting/CloudBase account and
the music platform account. Signing in or out of either must not create, replace
or clear the other. A music platform login does not restore deleted CloudBase
data. Platform account mutation is serialized so a delayed secure-storage write
cannot resurrect a login after logout.

Beta guest favorites and playlists live in the Beta application sandbox. They
are not silently migrated or synchronized to either cloud account. Platform
cloud playlists and music disk integration are not implemented in this milestone.

## Build and checks

Put Flutter on PATH and run from the extracted project root:

```powershell
flutter pub get
flutter analyze
flutter test
flutter test --flavor beta test/music_platform_test.dart test/beta_login_entry_test.dart test/beta_update_isolation_test.dart test/remote_lyrics_repository_test.dart
.\tool\build_android_md3_beta_apk.ps1
```

The build script selects `beta`, version `1.0.37-beta.1` / `1`, ARMv7 + ARM64,
CloudBase authentication retained, and automatic update checks disabled. It does
not publish an update manifest or deploy a backend. The package is
`com.mesting.music.beta`, separate from formal and Java/MySQL packages.

Android local files and signing keys are intentionally excluded from the source
archive. Flutter/Android tooling must regenerate local configuration. The archive
includes the public Gradle wrapper launchers and JAR used by this build even
though the baseline ignores those generated files. A fresh build needs working
network access for dependencies. The private test APK currently uses this computer's
debug certificate. A different certificate cannot update the installed Beta in
place; preserve the signing key separately before distributing later Beta builds.

`integration_test/md3_beta_smoke_test.dart` is supplied for a connected Android
device. It checks actual native startup, first entry, anonymous search and
playback. It is **not included in the passing unit/widget test count** and has
not run successfully here. The local emulator crashes in its graphics runtime
before a device becomes available. Genuine platform login also requires manual
device validation and is not mocked into a success claim.

## Remaining migration work

Verify the packaged native libraries, real login, media playback and local
library persistence on a phone first. Then migrate platform cloud playlists and
their write operations, music disk, MV, comments and other upstream functions
in separately testable steps. Endpoint availability in the Rust source alone
does not mean a feature is connected to Mesting's user interface.

Before public distribution, reproduce native builds, establish a release signing
process, and resolve the upstream license/disclaimer wording recorded in NOTICE.
Keep all corresponding-source and attribution requirements with the derivative.
