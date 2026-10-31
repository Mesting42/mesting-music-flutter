# Beta.18 local handoff

This development change starts from branch `beta`, clean Beta.17 commit
`e8ac5bb23ff51787b3a881ad252b4fa9bed97677`. The Beta.17 tag remains unchanged;
Beta.18 is a local working-tree delivery, not a newly published GitHub release.

Read [the Beta.18 change and validation record](fixes-2026-10-26-beta18.md)
and the current `DESIGN.md` before extending these controls. The final success
HUD reference is 104 x 104dp at the upper center, and guide controls remain
usable throughout the success feedback. Earlier large-card/blocked-guide
previews are superseded.

## Build and signing

This delivery used Flutter 3.41.9, the pinned lockfile, Android Studio's
JBR 21.0.10 and NDK 28.2.13676358. Java/Kotlin source targets remain 17. The
formal package/version configuration remains separate; the Beta build tool
overrides the name and code to `1.0.37-beta.18` and `18`:

```powershell
.\tool\build_android_md3_beta_apk.ps1 -FlutterSdkRoot '<local Flutter 3.41.9 path>'
```

The build script uses the configured Android debug signing identity. That
identity is machine-local and is not guaranteed to match an installed Beta.
For this delivery, the compiled APK was re-signed into a delivery copy using
Android Build Tools `apksigner` and the privately transferred Beta.17 key.
The global debug keystore was left untouched. The signature was then verified,
and all compiled payload entries were compared with the original build.

Expected Beta.17/Beta.18 signing certificate SHA-256:
`8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333`.
Check the actual final APK certificate before any future delivery; a new debug
key will not support a direct upgrade. Transfer private keys separately and
never include them in Git or an archive.

The exact delivered APK metadata and its hash are recorded in
`release/Mesting-Music-v1.0.37-beta.18-verification.json` and the adjacent SHA-256
file. No package split, resource-loading change, native-service replacement or
dependency upgrade was made by this UI refinement.

## Validation and remaining boundary

- Final Beta regression: 275 passed; no skips/failures. Compact-HUD geometry and
  early Next are included in that final run.
- Static analysis: no issues. Software-rendered previews cover both themes,
  narrow layouts, enlarged text, loading and reveal states.
- Normal suite: 724 passed, 89 skipped, 3 failures. All three reproduce on the
  pristine Beta.17 baseline; details are in the change record and external logs.
- APK v2 signing, both ARM architectures, ZIP 16 KiB and ARM64 ELF segment
  alignment, native payload hashes and unchanged dependency lock were verified.
- No connected phone: actual upgrade/data retention, Android GPU effects,
  native routing, haptics and live account/network behavior still require device
  testing. No Git commit/push, release publication or installation was performed.
