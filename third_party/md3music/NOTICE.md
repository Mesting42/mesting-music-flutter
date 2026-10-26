# md3Music provenance

- Upstream: https://github.com/zzyoxml/md3Music
- Pinned commit: a69503b84e8829f888684f67c163be03c589c014 (rust-local-force)
- Upstream author: zzyoxml and contributors; original notices are preserved.
- License: GNU Affero General Public License, version 3; see LICENSE.
- `rust/` contains the corresponding upstream server sources, Cargo.lock,
  vendored tiny_http sources, tests and build scripts without local edits.
- `android/app/src/beta/jniLibs/*/libkugou_server.so` are the upstream binaries
  copied from this commit (arm64-v8a, armeabi-v7a, x86_64). They have not yet
  been reproduced from source on this machine. No binary is placed in main.
- Mesting's `lib/features/music_platform/` is an integration adapter for the
  upstream C ABI and API contracts. It preserves Mesting's UI, Riverpod state,
  database and audio handler rather than importing upstream UI dependencies.
- The integrated derivative is distributed under AGPL-3.0; original third-party
  dependency licenses and copyright notices remain applicable.
- UPSTREAM_DISCLAIMER.md is kept verbatim for review. Its GPLv3/noncommercial
  wording differs from LICENSE and must be resolved before public release.

Do not distribute credentials or signing keystores with source archives.
