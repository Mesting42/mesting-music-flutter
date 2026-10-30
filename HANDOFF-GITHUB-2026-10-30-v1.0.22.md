# GitHub archive handoff — 2026-10-30

1.0.19/code40 through 1.0.22/code43 now have independent frozen commits, version tags and GitHub Releases. Each release contains 11 original delivery/verification attachments; GitHub SHA-256 and sizes match local originals. Each tagged source was reconstructed from that version’s frozen source ZIP. Existing APK and ZIP files were not changed.

1.0.22 remains a **candidate prerelease**: no physical-device acceptance, native crash root cause or permanent fix is claimed. The user reported native crashes after installing 1.0.21; archival publication is not a stability endorsement. Read the version handoffs and validation limitations before further work.

The remote beta maintenance branch includes all four frozen versions and this archive handoff. The existing local beta HEAD, primary index and pre-existing dirty worktree were deliberately retained. Do not pull/reset over local changes. A fresh clone of remote beta verified every file listed in the 1.0.22 source snapshot. The snapshot describes the frozen product, before these additional archive documents.

No music backend publication, phone/ADB access, or real-account operation was performed. Private signing credentials and private device evidence were excluded. Existing public upstream SDK fixtures and licenses remain intact.

Evidence: [archive verification](docs/version-archive/GITHUB-ARCHIVE-2026-10-30-v119-v122-verification.json).

- [v1.0.19](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.19): `31768de066e710774dc2b5ad441617d7248353ae`
- [v1.0.20](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.20): `93cc026020d7244f35fe371f211f8c7e671f030f`
- [v1.0.21](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.21): `e9f6eb162182fa5478b8e795e1fc129a7604cb44`
- [v1.0.22](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.22): `dbfb37d1c00487dfc91afa8ef505e728aef61c31` — candidate prerelease
