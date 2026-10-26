# md3Music integration Beta.7 handoff

## Beta.7 accepted implementation and delivery boundary

This section is the current built truth for **1.0.37-beta.7 / 7**, merged after
final finish review on 2026-10-25. The disposition is **SHIP WITH STATED
VALIDATION LIMITS**: R1–R3 are resolved in the reviewed source/widget/capture
scope. Earlier Beta.6/Beta.5/Beta.4 records below remain historical context;
where behavior differs, this section takes precedence. No commit or clean
working tree is implied. Preserve formal-channel decisions, existing account
ownership, comments, paged song search, cloud library and the one audio service.

The delivery target is
`C:/Users/Mest/Documents/Codex/2026-10-25/mesting-beta5-handoff-20261025/outputs/beta-1.0.37-beta.7`.
The final delivery manifest owns exact artifact bytes, SHA256, signing/package
inspection and archive contents. Do not reuse a rebuild's intermediate hash or
the historical Beta.6 APK identity below as the Beta.7 identity.

### Red appearance and simplified dress-up

`BetaAppearance` owns the user's sampled reference red and its dark adaptation.
All four selected destination icons/text and related selection chrome use it;
profile icons are red and profile panels are pale red/dark red. The red outer
selection fill/border/shadow for progress styles and characters does not recolor
explicit IP artwork. Primary text remains readable on selected choices. The
final local correction closes R3 and removes the `DRESS UP` eyebrow.

Beta removes the complete brand picker and redundant Skin title/description/
classic card, retaining light/dark/system, custom image/video, player styles,
independent progress palettes/characters and IP decoration. Launcher/splash
identity is fixed to `coral`, with old brand preferences migrated. Beta.7 hides
`followTheme` choices and migrates residual aliases to `classic`. Earlier
Beta.6 migration already converted some legacy full-IP choices into explicit IP
values; those explicit selections remain. Full IP skins stay retired, background
strength stays .58 and performance `automatic`. Formal flavor retains its
existing complete themes, brand controls, navigation and default vinyl.

### One control layout across all five players

`BetaNowPlayingPage` routes `cover`, `classic`, `aurora`, `cassette` and
`lyricStage` through one `ApplePlayerControls`. Keep each upper scene and motion,
then use the exact same lower order in both cover and lyrics modes:

1. Progress rail and elapsed/remaining time.
2. Bare white Cupertino previous / play-pause / next glyphs, without large circle
   backgrounds.
3. Real Android system-media-volume rail.
4. Song comments / quality / current queue.

Classic preserves the grey turntable with local dark translucent fills behind
collapse/more, a stronger lower veil and opaque white artist text. These close
R1; they do not replace the shared bare transport. Lyrics show small top artwork
and song identity, blurred-cover atmosphere, left-aligned synced lines, bright
active text, dim inactive text and fading edges. Their current base size is
**24dp** (down from 30dp) with TextScaler and measured line heights; synced lines
remain tap-to-seek. Short/large-text layouts scroll rather than remove controls.

Seek and volume use merged semantics with distinct Chinese labels and native
adjustable actions: `播放进度` announces elapsed/total duration and `系统媒体音量`
announces percentage. Every player style has focused semantic-node assertions.
`MediaVolumeController` probes MethodChannel support before subscribing to
EventChannel, avoiding missing-host errors in non-Android/widget environments.
The lifecycle-scoped Kotlin `MediaVolumeBridge` reads/writes `STREAM_MUSIC`,
observes system changes and refreshes on foreground return; missing hosts leave
a truthful disabled rail. Channel read/set/event/missing-host tests pass. This
closes R2 at widget/source level; hardware keys and TalkBack still need a device.

All five styles retain shared standard/high/lossless/Hi-Res preference and the
existing state-preserving source refresh. The player quality chooser is now a
dark translucent rounded popup. Preference is not a guarantee of delivered tier;
unknown metadata, trial and permitted downgrade remain explicit.

### Official chrome, mini player and status feedback

The official liquid_glass_widgets **1.15.0** `GlassScaffold`,
`GlassTabBar.searchable` and `GlassButton.custom` composition, optical settings,
press/drag springs and accessory morphing remain. Phone and wide windows share
one bottom bar. The mini accessory has exactly two bare icon actions—play/pause
and next—while keeping open-player and horizontal-swipe behavior. A wide layout
no longer adds a queue button; queue remains in the full player.

Search content extends behind the glass with internal bottom clearance. The
entire opaque white background strip is removed; the shell avoids the keyboard
for content and the official bar owns its own lift and safe area. Do not add the
inset twice. Stable content/forms and account routes remain opaque theme surfaces.

`showMusicNotice` now presents one replaceable translucent HUD below the top
safe area. It keeps a short title and glyph, light/dark adaptation, motion and
live-region semantics. Ordinary obsolete subtitles are omitted; warning/error
messages retain actionable detail. Replacing a HUD does not fabricate operation
success or introduce a second business-state system.

### Platform recommendation provenance and real search discovery

Beta ports recommendation contracts from upstream md3Music
**a69503b84e8829f888684f67c163be03c589c014** (`rust-local-force`), including
API parameters, parsing, server ordering, refresh, feedback and continuation.
The local artist-scoring recommender and personal hot list are removed from
Beta entry paths; the other distribution keeps its existing custom recommender.

The discovery surface has four modules: private FM, daily recommendations,
`/home/discover` and new songs. FM station choices are heart/explore/niche/radio
(红心/探索/小众/电台), retaining the matching mode/pool and `cur_mark` feedback
context; each garbage/dislike replacement batch registers its own cur_mark before playback. Playtime/completion, favorite/cancel-favorite and dislike reports apply
only to the active owned FM stream and current platform account. Platform
permissions remain authoritative; anonymous browsing does not create membership.

`PlatformRecommendationSession` owns provenance. Fetching a preview does not
start an FM session. An explicit FM/home-discover queue starts continuation;
when actual remaining upcoming items are **≤3**, fetched results append to the
real visible upcoming queue in strict server order, without library-pool or
random fallback. Explicit non-recommendation playback ends the stream even if
it selects the same recording. Account/session checks and generation guards
reject stale starts/refills/feedback; disposed account streams cannot repopulate
a replacement owner's queue. Pull-to-refresh reloads platform modules.

Both shell and standalone Beta search route to `PlatformSearchLanding` with
real `/search/hot` keyword boards, search history and exploration categories
(theme playlists, scenes, popular playlists, rankings and new albums). Hot words
trigger a real keyword search, never fake playable songs. Scene chips currently
present categories without a tap action and theme rows are display-only; do not
claim full feature migration from endpoint presence. Legacy curated routes
redirect Beta into discovery. Existing real song search preserves upstream
paging, recording IDs and server order as described in the Beta.4 section.

### Evidence and limits

Evidence root:
`C:/Users/Mest/Documents/Codex/2026-10-25/mesting-beta5-handoff-20261025/work`.
`beta7-finish-verdict.md` closes R1–R3. Current captures are in
`beta7/screenshots-verdict`; classic/semantics closure also retains the preceding
`beta7/screenshots-approved` evidence. The previously known search chip/subtitle
CJK tofu was a QA font-coverage issue; explicit fixture fonts repaired it and the
final captures clear it. It is not an outstanding product defect or a claim of
Android typography acceptance.

- `beta7/regression-shipped.jsonl`: **587 passed, 41 conditional skips,
  0 failures**, terminal `done.success=true`. This supersedes the earlier
  586/40 and 586/41 runs after the standalone Beta-search guard and per-batch FM feedback-context regression.
- `beta7/targeted-shipped.jsonl`: **81 passed**, terminal success.
- `beta7/ui-verdict.log`: **8 passed**, including five-style semantic assertions
  and standalone Beta search not reading the legacy recommendation scorer.
- `beta7/logic-approved.log`: **14 passed**, including ordered continuation,
  account-change stale response protection, quality-state preservation and
  media-volume channels.
- These groups **overlap**. Do not add them into a single test total. Tests and
  widget screenshots use synthetic fixtures; they are not live cloud writes.
- `beta7/analyze-shipped.log` reports **No issues found**. Release assembly in `beta7/build-shipped.log` has
  succeeded; the delivery manifest/validation
  record identifies the final rebuilt APK and exact signature/hash checks.
- The design detector was run once for Beta.7 and returned no findings (`[]`).
  Finish documentation did not rerun it or initiate a new UI defect hunt.

No Android device is connected. Hardware/system-volume synchronization,
TalkBack speech/gestures, real IME transitions, GPU glass/motion performance,
launcher/splash upgrade migration, live CDN playback/quality switching and live
account/cloud operations remain unverified. Captures use local synthetic data,
Windows QA fonts and Flutter software rendering; they cannot promise exact
native Apple GPU fidelity. These limits travel with the private Beta delivery.

### Beta.7 implementation entry points

All paths below are relative to the project root.

| Module | Responsibility |
| --- | --- |
| `lib/features/themes/beta_appearance.dart`, `app_theme.dart` | Red/dark accent and pale-red/dark-red semantic panels |
| `lib/features/themes/theme_controller.dart`, `app_brand_style.dart`, `theme_gallery_page.dart` | Beta-only appearance choices, followTheme/coral migration and explicit IP preservation |
| `lib/features/experience/presentation/beta_now_playing_page.dart`, `apple_player_controls.dart`, `immersive_lyrics.dart` | Five upper scenes, shared controls, readable classic and 24dp synced lyrics |
| `lib/core/audio/media_volume_controller.dart`, `android/app/src/main/kotlin/com/mesting/mesting_music/MediaVolumeBridge.kt`, `MainActivity.kt` | Lifecycle-scoped Android media-volume bridge |
| `lib/features/experience/presentation/beta_music_shell.dart`, `beta_bottom_bar.dart`, `floating_playback_pill.dart` | Official chrome, search clearance and two-action mini accessory |
| `lib/shared/widgets/music_notice.dart` | Single replaceable top status HUD |
| `lib/features/music_platform/data/platform_recommendations.dart`, `platform_recommendation_providers.dart` | Pinned platform API/order, FM provenance, feedback and account/generation guards |
| `lib/features/music_platform/data/platform_explore.dart`, `presentation/platform_recommendations_page.dart`, `presentation/platform_search_landing.dart` | Four discovery modules, actual hot-search boards and connected exploration |
| `lib/core/audio/mesting_audio_handler.dart` | Existing audio service, visible ordered continuation and state-preserving source refresh |
| `lib/features/search/presentation/music_search_page.dart`, `lib/app/router/app_router.dart` | Standalone Beta landing and legacy-route redirection boundaries |

Build with **Flutter 3.41.9 / Dart 3.11.5**. The script defaults to Beta.7 name/code
and ARMv7 + ARM64 while retaining the formal pubspec baseline, CloudBase auth,
Beta package identity and disabled update checks. It does not deploy a backend
or publish an update manifest. See the retained build command below.

## Historical Beta.6 cover, official chrome, quality and appearance handoff

The following section records the earlier Beta.6 build and review. Its artifact
bytes/hash and test counts identify Beta.6 only. Beta.7 behavior and final
artifact identity are governed by the current section and delivery manifest.

Beta.6 repairs missing artwork across recommendations, search, playlists and
players. `PlatformArtwork` selects valid HTTP/HTTPS URLs from upstream cover
fields, preserves permitted HTTP, normalizes protocol-relative URLs and size
placeholders, and skips bare filenames. `PlatformArtworkRepository` performs
read-only `/audio` metadata recovery for visible/older Kugou tracks, coalesces
requests for a hash, limits concurrency to 3, and retains 256 successful covers.
Temporary network failures are not permanently cached; artwork failure does not
fail audio or mutate cloud data.

Beta chrome now directly uses the official liquid_glass_widgets Apple Music
example's `GlassScaffold`, `GlassTabBar.searchable` and `GlassButton.custom`,
preserving Chinese Mesting navigation/search, swipe, queue and audio actions.
The dependency remains pinned to **1.15.0**; the MIT upstream example/source
snapshot lives in `third_party/liquid_glass_widgets/`. The package owns press,
drag, spring and accessory morphing. Phone and wide windows use one bottom bar;
Beta no longer adds the expanded rail or its 88dp spacer. The adaptive body
width constraints remain. The official bar handles safe areas and keyboard lift;
the shell clears only search content for the keyboard. A transparent Material
provides normal bar text defaults. These resolve the reviewed duplicate keyboard
lift, text-inheritance and duplicate wide-navigation findings.

Official chrome uses premium/full, blur 2, thickness 30, chromatic aberration
.01, saturation 1.2 and fresnel 0, with light intensity .2 for navigation and .18
for the playback pill. These are separate from the older `MestingGlass`
standard/blur 12/thickness 22 surface and its opaque high-contrast fallback;
do not apply that fallback claim to the official bar.

All five player appearances expose **标准 / 高品质 / 无损 / Hi-Res** through
`PlatformQualityButton` and the shared persisted preference. The existing audio
handler's `refreshCurrentSource` replaces the current stream while preserving
position, playing/paused state, logical queue and playback mode. Newer commands
invalidate stale switches; decoder failure attempts to restore the old stream.
`Track.playbackQuality` is optional and backward compatible. Preferred and
delivered quality are distinct: unknown server metadata stays unknown, permitted
downgrades and trials are disclosed, and account/resource availability remains
authoritative. No live CDN/decoder quality-switch acceptance is implied by mocks.

Beta removes the full Shin-chan, Hello Kitty and Kuromi themes while retaining
classic light/dark/system and independent progress styles/characters. Old full
themes migrate to `classic`; a saved `followTheme` progress style/character is
converted to the original character so its actual appearance is retained.
Background strength and performance controls are removed in Beta and fixed at
.58 and `automatic`; the IP-character-decoration switch remains. The formal
flavor retains its existing navigation and theme behavior.

Build with **Flutter 3.41.9 / Dart 3.11.5** using the command below. The build
script now defaults to **1.0.37-beta.6 / 6**; `pubspec.yaml` keeps its formal
baseline version. The final Beta.6 APK was built and inspected: package
`com.mesting.music.beta`, 88,954,358 bytes, SHA256
`B1462439D022F4947CBFD2608901C2DB3D484C49CC161DE309C20421C0670B03`.
APK Signature Scheme v2 verification and 16KiB ZIP alignment passed, and its
certificate matches Beta.5. Final `flutter analyze` reported no issues.

The normal full regression passed 576 tests with 38 conditional skips; the Beta
specialized group passed 67 and final UI group passed 6. Groups overlap and must
not be added together. Independent review disposition is **ship**, with the
three Beta.6 presentation findings resolved. Approved UI screenshots use
synthetic fixtures; occasional test-font coverage boundaries in search-chip
secondary text do not establish a physical-device defect. No Android device
was available, so real-device/GPU, live artwork CDN, live quality switching and
real cloud writes remain unverified. Sources remain an uncommitted working-tree
snapshot; Beta.6 packaging must not overwrite the earlier Beta.5 archive.

The following Beta.5 presentation/library and Beta.4 integration details remain
applicable except where superseded by this Beta.6 section. Track reordering is
still unimplemented; comment like/unlike writes remain deferred as accepted.

## Beta.5 presentation and library changes

The approved composition now uses cover-led Home and separate Discovery, an
owner-bound Library, four destinations plus independent search, a floating
playback capsule, and a square-cover player with large synchronized lyrics.
The existing black-vinyl and alternate player styles remain selectable.
The retained Mesting theme modes still own colors/backgrounds; Beta.6 theme
availability and migration are described above.
`liquid_glass_widgets` is pinned to 1.15.0; effects are confined to floating
chrome. The older `MestingGlass` surface has a high-contrast fallback; Beta.6
official chrome has the separate behavior described above. Content/forms use
opaque theme surfaces.

Build this snapshot with **Flutter 3.41.9 / Dart 3.11.5**. The independent SDK
used here is `D:\flutter\mesting-beta5\flutter`; the original formal checkout
and its SDK are unchanged. Run:

```powershell
.\tool\build_android_md3_beta_apk.ps1 -FlutterSdkRoot D:\flutter\mesting-beta5\flutter
```

The current script selects version `1.0.37-beta.7` / `7`, ARMv7 + ARM64. `pubspec.yaml`
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
| `features/music_platform/data/platform_artwork.dart` | Shared cover normalization and bounded read-only metadata recovery |
| `features/music_platform/domain/platform_audio_quality.dart` | Verified quality request codes and permitted fallback order |
| `features/music_platform/platform_quality_providers.dart` | Persisted quality preference and shared switching state |
| `features/music_platform/presentation/platform_quality_button.dart` | Common player quality selector, actual-tier and trial/downgrade disclosure |
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
| `core/audio/mesting_audio_handler.dart` | Existing playback queue, URL resolver callback and state-preserving current-source refresh |
| `features/experience/presentation/beta_music_shell.dart`, `beta_bottom_bar.dart`, `floating_playback_pill.dart` | Official glass scaffold/searchable tabs/accessory composition with existing Mesting actions |
| `features/themes/theme_controller.dart`, `theme_gallery_page.dart` | Beta appearance migration and settings; formal theme behavior retained |
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
private cloud playlist by default. Cover upload is connected through the common
editor as described above; track reordering remains unimplemented. Cloud data
cannot be restored from a source or APK backup.

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

The build script selects `beta`, version `1.0.37-beta.7` / `7`, ARMv7 + ARM64,
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
