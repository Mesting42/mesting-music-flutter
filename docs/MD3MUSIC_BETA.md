# md3Music integration Beta.5 handoff

## Beta.5 presentation and library changes

The approved composition now uses cover-led Home and separate Discovery, an
owner-bound Library, four destinations plus independent search, a floating
playback capsule, and a square-cover player with large synchronized lyrics.
The existing black-vinyl and alternate player styles remain selectable.
The Mesting dress-up themes and light/dark modes still own colors/backgrounds.
`liquid_glass_widgets` is pinned to 1.15.0; effects are confined to floating
chrome, with a high-contrast fallback. Content/forms use opaque theme surfaces.

Build this snapshot with **Flutter 3.41.9 / Dart 3.11.5**. The independent SDK
used here is `D:\flutter\mesting-beta5\flutter`; the original formal checkout
and its SDK are unchanged. Run:

```powershell
.\tool\build_android_md3_beta_apk.ps1 -FlutterSdkRoot D:\flutter\mesting-beta5\flutter
```

This selects version `1.0.37-beta.5` / `5`, ARMv7 + ARM64. `pubspec.yaml`
retains the formal baseline version; the distribution script supplies the Beta
version. The source ZIP contains no signing private key or local SDK settings.

Presentation lives in `features/experience/presentation`; it consumes existing
catalog/library/audio contracts rather than owning another player or session.
`PlatformCatalog.newSongs` always uses the public new-song chart; `daily`
continues to choose personal recommendations only for a platform login.

`history/listening_replay.dart` aggregates real daily records by active owner
and calendar year/month. `playbackOwnerBindingProvider` binds the initial guest
as well as later accounts. Missing historical periods are never reconstructed
from lifetime totals. The Replay stream and library switch with the owner.

The common playlist editor accepts an `onSave` callback, retaining the draft on
failure. Gallery images and native Canvas templates are normalized to a 640px
PNG in application documents. For an owned Kugou playlist, the repository
uploads it using the embedded `/playlist/pic/upload` contract, reads `total_ver`,
then commits `custom/<FileName>` through `/playlist/update`, preserving privacy
and sort. Writes guard the original identity throughout and do not auto-retry.
After a partially successful creation, a manual retry reconciles the created
list rather than creating another. System favorite lists and subscribed lists
cannot be edited as owned lists. Mesting/local libraries keep their own save
contract. Mock upload success is not evidence of a live cloud-account write.

Relevant tests: `beta5_cloud_cover_test.dart`, `beta5_replay_test.dart`,
`beta5_ui_test.dart`, and `playlist_cover_editor_test.dart`, plus the retained
Beta account/search/comments/library suites. UI screenshots use synthetic local
fixtures. See DESIGN.md for the built design system and the packaged Chinese
validation record for exact run counts and remaining device checks.

The following Beta.4 integration details remain applicable unless superseded
above. Comment like/unlike writes remain deferred with user acceptance.

Beta.4 connects the upstream paged song-search flow directly, preserves recording
IDs through saved/playback tracks, adds full comment browsing controls, and
reuses Mesting collection/components throughout imported platform surfaces.
It retains guest playback resolution, account isolation, avatars and cloud
library support. It is not a complete migration of every md3Music feature.

## Source baseline and provenance

- Mesting baseline: `flutter-music-v1.0.37-build58`, commit
  `1b669e8239f1641f5f008e8d286940142e6daf35`.
- Integration branch: `integration/md3music-beta`.
- Upstream md3Music: `a69503b84e8829f888684f67c163be03c589c014`,
  branch `rust-local-force`.
- Flutter used for Beta.4: 3.38.6; Dart: 3.10.7; Java: 17-compatible
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
| `features/auth/beta_account_choice.dart` | Persistent mutually exclusive account selection; guest after logout |
| `features/music_platform/data/platform_catalog.dart` | Public discovery, daily recommendations and public playlists |
| `features/music_platform/data/platform_library_repository.dart` | Existing library contract backed by the current Kugou cloud identity |
| `features/music_platform/data/platform_playback_resolver.dart` | Bounded media lookup, device registration retry and permitted preview fallback |
| `features/music_platform/data/platform_comments_repository.dart` | Resource IDs, paging and explicit comment writes pinned to one Kugou identity |
| `features/music_platform/data/platform_song_identity.dart` | Recording ID aliases and bounded parsing of nested metadata; skips zero IDs |
| `features/music_platform/data/platform_search_repository.dart` | Upstream 30-row search pages, server order and result totals |
| `features/music_platform/platform_profile_provider.dart` | Profile/avatar refresh independent of credential restoration |
| `features/auth/account_capabilities.dart` | Shared menu, player and route capability boundaries |
| `features/music_platform/data/embedded_kugou_music_source.dart` | Adapts search, rankings and fresh playback URLs to Mesting tracks |
| `features/music_platform/presentation/platform_account_page.dart` | Phone and QR login, account choice and independent logout |
| `features/music_platform/presentation/platform_comments_page.dart` | Opaque comment/thread routes, compose, reply and delete-own actions |
| `features/music_platform/presentation/platform_design.dart` | Shared Mesting surfaces, fields, buttons, page frame and feedback |
| `features/music_platform/presentation/platform_comment_card.dart` | Comment author/date/content/count presentation without network writes |
| `core/audio/mesting_audio_handler.dart` | Existing playback queue with optional URL resolver callback |
| `features/lyrics/data/lyrics_repository.dart` | Injectable JSON transport with existing lyric fallbacks |
| `features/library/presentation/library_access.dart` | Beta local-library access without legacy cloud authentication |
| `android/app/src/beta` | Beta name, scoped cleartext network policy and native libraries only |

Keep platform credentials out of the Mesting account repository. Do not add a
second audio service. Do not call the server during global application startup:
network or native startup failures must leave the guest entry usable.

## Account and data rules

There are two credential formats and data owners, with one active login at a
time. Both choices appear while signed out. Once logged in, all account surfaces
show the selected identity; logout returns to guest mode and restores both
choices. Do not fabricate a Mesting user from a Kugou identity. Delayed CloudBase
restoration must not override a platform selection. On upgrade from Beta.1,
an existing platform credential wins if there is no saved selection. A saved
guest choice prevents old credentials from reactivating after logout.

Kugou mode hides Mesting messages, friends/user search, sharing/listen-together
and the Java/MySQL test app entry. A direct legacy route is blocked as well.
Mesting mode keeps its own features and hides Kugou comments. Guest mode uses
the local library. Player, list, lyrics-overlay and notification favorite actions
all use the active library repository; they must not require an unrelated login.
Profile, drawer and account management share the current account's avatar. Only
reading/display is implemented; an avatar failure must not invalidate login.

Account and comment routes explicitly use an opaque surface, because the shell
deliberately has a transparent scaffold background for themed artwork. A new
full-screen route must not inherit that transparency accidentally.

Beta guest favorites and playlists live in the Beta sandbox. They are not
silently migrated or synchronized to either cloud account. Mesting keeps its
original library owner. A Kugou login selects the cloud adapter: paginated lists,
favorites, track add/remove, playlist create/rename/delete and explicit refresh.
Every request checks its expected user and token before sending and after
receiving a response. Mutations are serialized and never retried automatically.
Read-only collected lists are displayed without write controls. Creation uses a
private cloud playlist by default. Cover upload and track reordering remain out
of scope. Cloud data cannot be restored from a source or APK backup.

All Beta music sources use the embedded concept-platform transport regardless
of login choice. Guests/Mesting users receive public new-song recommendations;
Kugou users request their daily recommendations. Missing platform permissions
remain missing: using this transport grants no membership entitlement.

Cloud song metadata uses `mesting-platform:` as an internal deferred-resolution
marker. The audio handler resolves each selected song before creating its audio
source, so loading a large favorite list does not request thousands of URLs.
The marker is never passed to the audio decoder as a media URL.

Guest playback first requests a normal URL, registers the device once if the
platform returns 20028, and retries that request once. If a non-VIP request has
no URL, it asks for the platform's `free_part=1` preview and labels it as a trial.
The entire lookup has a 40-second cancellation deadline. A VIP credential keeps
the full-quality endpoint priority and does not silently fall back to an
anonymous preview. If the platform supplies no permitted URL, show a precise
message rather than promising playback. Search metadata does not become locked
just because an early URL request failed. Beta Android policy permits HTTP only
for loopback and upstream media domains (`kugou.com` and
`stream.tencentmusic.com`, including subdomains), matching the inspected APK;
the default policy remains HTTPS-only.

Comments use a song's real `mixsongid` resolved through `/audio` and a playlist's
global collection ID. Reply/delete use the upstream comment children ID and root
thread ID, never a local track/playlist UUID. Writes use POST with the upstream
flat query contract. Send, reply and delete-own occur only after explicit user
actions and are never retried automatically. Identity is checked before and after
HTTP; stale pages stop showing another account's comment controls. The server's
permissions, moderation and security challenges remain authoritative.

## Beta.4 search and comment corrections

Beta search bypasses the legacy MusicSearchRepository's fuzzy reordering and
title/artist deduplication. It follows upstream KugouApiClient.search parameters:
`/search`, `keywords`, `type=song`, page starting at 1 and `pagesize=30`.
`total`/`total_count` are displayed separately from loaded rows. Appending removes
only repeated file IDs and preserves distinct recordings and server order. A
generation token, abort signal and account checks reject stale responses. Failed
appends retain the visible list and retry the same page. Repeated pages stop
loading instead of creating an infinite request loop. The main result list
supports near-bottom loading and an explicit load-more/retry action.

Track.platformSongId is an optional, backward-compatible JSON/media extra; no
database schema migration or local-data clearing is necessary. Search/catalog
metadata and refreshed playback responses populate it. Older hash-only rows
resolve /audio, then /song/url metadata if necessary. The resolver accepts
AlbumAudioID, MixSongID, Audioid/audio_id and structured list/base/audio_info
responses as the upstream model does. It does not guess an ID from the file hash
or choose another same-title recording. Comment entry opens a loading/retry route
immediately, so resolution failure no longer prevents entering the page.

Song hottest comments first resolve childrenid from /comment/music, then request
/comment/music/topliked. Playlist hot ordering and latest/earliest ordering are
applied to loaded rows, matching the limits of the upstream client. All/singer/
mine scope filters explicitly describe their loaded-data scope. Dates, singer
flags, like counts, reply counts and nested replies are displayed. The childrenid
is retained for ranking rows that omit it, so replies/deletion still use the real
pool. Sorting/paging responses are guarded against newer selections.

Comment like/unlike writes are **not implemented**. The pinned upstream and its
published API documentation provide counts/ranking but no verified reaction
write contract. The user explicitly accepted deferral if a real implementation
could not be established. The app shows platform counts without inventing a
local success toggle or posting to an unverified endpoint.

Favorites and playlist collections reuse FavoriteCollectionView and
MyPlaylistsCollectionView. The account/login, profile, discovery, playlist and
comment surfaces share Mesting tokens and themed controls. Opaque full-screen
routes use PlatformPageFrame; themed shell pages retain the shell background.
UI tests cover light/dark modes, a 320-pixel viewport and keyboard insets.

## Build and checks

Put Flutter on PATH and run from the extracted project root:

```powershell
flutter pub get
flutter analyze
flutter test
flutter test --flavor beta test/music_platform_test.dart test/beta_login_entry_test.dart test/beta_update_isolation_test.dart test/remote_lyrics_repository_test.dart test/platform_cloud_library_test.dart test/beta_account_exclusivity_test.dart test/platform_guest_playback_test.dart test/platform_comments_test.dart test/beta_player_library_actions_test.dart test/platform_search_paging_test.dart test/platform_beta4_ui_test.dart
.\tool\build_android_md3_beta_apk.ps1
```

The build script selects `beta`, version `1.0.37-beta.5` / `5`, ARMv7 + ARM64,
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

The user confirmed real Kugou login and logged-in playback work, and clarified
that the playback failure occurs in guest mode. Beta.4 still needs phone
acceptance of real search paging, comment IDs/read/write, guest full/preview
audio, avatar images and account transitions. Mock protocol/UI tests cannot certify a third-party
service's live behavior. No user's real cloud comments were posted or deleted
during development. Music disk, MV, recognition, membership check-in
and track reordering remain separate migration work. Cover upload is connected
in Beta.5 and still needs real-device/cloud acceptance. Endpoint availability in the
Rust source alone does not mean a feature is connected to Mesting's interface.

Before public distribution, reproduce native builds, establish a release signing
process, and resolve the upstream license/disclaimer wording recorded in NOTICE.
Keep all corresponding-source and attribution requirements with the derivative.
