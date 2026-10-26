# md3Music integration Beta.10 handoff

## Beta.10 current implementation and verified release boundary

Current source/build-script target: **Mesting Music / com.mesting.music.beta / 1.0.37-beta.10 / 10**. The script selects the Beta flavor while `pubspec.yaml` retains the formal baseline version. This pass preserves the valuable dirty Beta.5–9 working tree, the fixed platform API/server, account ownership and the single MestingAudioHandler. It does not reset/clean the checkout or change branch, worktree or historical outputs. Shared improvements apply at explicit Beta call sites; they do not establish a formal-channel redesign.

The user confirmed the full written Beta.10 plan after it was saved as `Beta10-完整修改方案-待确认.md`; its filename reflects the earlier draft state. Visual authority is the inherited Mesting/Apple Music world, the supplied welcome/guide reference layouts, the user's coral original vector music-note/record duo choice and that confirmed plan. There is **no independently generated/approved ImageGen comp, approval sidecar or random FORM seed**. The welcome source has a truthful THESIS / OWN-WORLD / STORY / FIRST VIEWPORT / FORM contract rather than a fabricated prior approval record. `PRODUCT.md`, `DESIGN.md`, `.impeccable/design.json` and the music/auth surface briefs describe the implemented Beta.10 state; historical versions below retain their own evidence.

The initial independent review was `work/beta10/review-first.md`, disposition **fix**, R1–R8. After the fix batch and final recapture, `review-final.md` concludes **ship**, with **R1–R8 all resolved** and no partial/unresolved material finding in that bounded review. Final regression/analyze and release verification have completed as recorded below. Beta.9 evidence remains historical and is not substituted for the verified Beta.10 runs. Source archive identity belongs to the external delivery manifest generated after documentation freeze, so no self-referential archive hash is embedded here.

### Entry, interactive login, success and eight-page guide

- BetaEntryCoordinator owns entry above the router and blocks underlying input/focus/semantics while active, so a newly published account cannot unmount its success/guide sequence. BetaEntryFlow separates explicit login events from credential restoration/token refresh and deduplicates success/guide events from QR polling. Every new interactive login, including after logout, follows **login → central success card → eight-page guide → app**. A restored session does not re-run that sequence.
- First entry without a completed-entry flag or restored session shows the welcome page. Phone and WeChat are the primary real platform entries; other methods retain Kugou/QQ QR and Mesting login/register. Agreement/privacy remain accessible. **Guest enters the app directly**. Guide Skip/Finish persist entry completion, and Settings → 使用指南 replays the guide without pretending another login occurred.
- The original vector music-note and record companions have articulated limbs, expression, headphone/record details, light motion, blinking and a local tap greeting. Drawing is isolated from authentication/network/audio. External outlines adapt to dark backgrounds; facial/internal lines keep their own contrast. These are user-selected authored vectors, not image-generated or third-party character assets.
- Guide pages teach the actual connected product: discovery/search/new music; player/lyrics; gray-handle dismissal and comments/quality/queue/menu; account-appropriate recommendations/favorites; single-song vs Play All, manual priority, continuation and actual history; light/dark/system and backgrounds/progress; five player styles; start/replay. The non-platform-account wording does not promise Kugou cloud/FM. No desktop lyrics, Zen or AI feature is claimed.
- Five separately recognizable, selectable dynamic previews use one local repaint clock and **the real playerVisualStyleProvider**. They show cover, turntable, aurora disc, particle scene and spectrum stage vocabulary corresponding to the existing style IDs. Choosing a card saves the same preference as Dress Up and player More. Theme choices likewise use the existing theme controller. Guide scenes are local, reversible demonstrations; they do not start playback or send cloud writes. Inactive retained pages are TickerMode-gated; reduced-motion behavior is component-specific rather than a claim that all timers stop.

### Shared premium glass, waiting and result feedback

BetaGlassButton / BetaGlassField / BetaGlassBackButton reuse `betaMusicPillGlass(context)` with **premium, useOwnLayer and independent RepaintBoundary**. Scope includes welcome/other-login controls, platform phone/code fields and actions, Mesting's six account fields/two primary actions, the specified exit and license/thanks actions, and circular app Back controls. Stable content/list backgrounds and the formal branch retain their contracts. Glass surfaces must remain independent siblings; nested glass can suppress a child's refraction.

The button default is 52dp high with 18dp horizontal padding, 15dp/700 text and capsule geometry; individual call sites deliberately vary size. Back is 48×48dp. GlassField is 24dp rounded with 20/17dp input padding plus an outer 3dp horizontal inset; existing field focus, validation and keyboard semantics remain. Loading uses the shared segmented Cupertino spinner in the operation's own area, including list/QR/code/login/logout states, with duplicate submission disabled.

BetaSignOutDialog owns the pending/failed confirmation state: duplicate requests are ignored, actions and Back are disabled while busy, failure preserves the session and gives a retryable inline error, and only real sign-out success returns to welcome/reset routing. The central login card enters, draws the shared green ring/check mark, exits, then advances to guide; comments reuse the success mark only for actual successful results. Existing replaceable top HUD and actionable errors remain. Software/HTML previews cannot verify Android premium optics.

### Transition continuity, menu dimensions and exact icons

- Search and ordinary route motion cover the old content with the current theme's **opaque colorScheme.surface**, rather than the app's transparent scaffold background. The source remains mounted for scroll/navigation state; completed search hides its old paint. The player still reveals its actual mounted underlay/capsule during dismissal rather than inserting a blank color screen.
- PlayerContentTransition provides paired fade/slide/scale entry and exit (default 360ms in, 280ms out). Cover/lyrics, identity and visual-style changes remain local, preserving transport/audio ownership. Real `userCommandStream` skipNext/skipPrevious supplies motion direction; cover/lyrics and enum-ordered style selection also set direction. Interruptions retain the existing bounded switcher behavior and component reduced-motion branch.
- BetaAnchoredMenu measures each trigger's actual RenderBox at open time and uses that exact width for the 22dp rounded menu. Its 90×44dp trigger minimum is not treated as a fixed menu width; the checkmark and Expanded label are laid out inside the measured width at normal and enlarged text.
- PlayerCommentGlyph is a shared authored **circular quotation bubble** used in the player and matching guide scene; quality uses the middle-speaker Cupertino glyph. Comments retain two one-row menus, reply/delete/account guards and independent premium input / blue 48dp Send siblings, with native keyboard visibility controlling 2/4 maximum lines.
- Tapping the current destination icon while the bar is contracted expands it while preserving that page/scroll. Existing mounted-shell ownership, 32dp edge/system Back, automatic paging, pure-heart feedback, real queue/history and fixed recommendation provenance remain.

### Same-ID media updates and truthful delivered quality

`currentMediaRevisionProvider` increments for each actual media-item publication because audio_service's MediaItem equality is ID-based. `currentTrackProvider` observes that revision, allowing a same-recording source/quality update to refresh its visible metadata without subscribing to playback-position ticks.

Strict tier switching retains the existing per-tier encoding hash, actual source replacement, saved-preference agreement and failure rollback. The resolver normalizes a supplied positive bitrate in kbps/bps; a measured lossy bitrate up to 400000 bps takes precedence over a possibly requested-label `quality` field, with >220000 bps considered high and lower lossy bitrate standard. Other cases use explicit platform quality metadata; strict unknown/mismatch is rejected. This prevents a 320kbps delivery stamped as a 128kbps request from becoming false success. The same audio owner retains position, pause/playing state, queue and mode; later commands/account generation still prevent stale replacement. Fixture verification does not certify real CDN or membership behavior.

### Beta.10 evidence and remaining validation

Evidence root: `C:/Users/Mest/Documents/Codex/2026-10-25/mesting-beta7-handoff-20261025/work/beta10`.

| Evidence | Scope/status at documentation handoff |
| --- | --- |
| targeted-first.log | 27 passing first-pass targeted tests; not final regression |
| entry-captures-first.log | 7 passing entry/capture tests; overlaps other groups |
| R1–R7 fix batch targeted feedback tests | Earlier 16 passing checks including measured menus, logout waiting/failure and reverse direction; overlaps final groups |
| design-detector.json | Root ran once, result `[]`; Dart coverage is bounded and this is not visual approval |
| captures-first, entry-contact.png, guide-contact.png | Historical first-pass software fixtures with recorded defects; final captures and R1–R8 scoring supersede them |
| review-first.md / review-final.md | Initial **fix** → bounded final **ship**, R1–R8 all **resolved**, remaining product-defect findings clear |
| normal-tests-clean.jsonl | **635 passed / 54 conditional skips / 0 failures** |
| beta-tests-clean.jsonl | **150 passed / 0 skipped / 0 failed** |
| ui-final-clean.log | Final software UI/interaction group: **34 passed / 0 failed** |
| motion-export.log | **4 passed**; reused software fixtures export welcome-light/dark-motion.gif and styles-light/dark-motion.gif, **36 frames each / 80ms per frame**; not Android FPS evidence |
| analyze-clean.log | **No issues found** |
| build-release.log / release-verification/artifact-verification.json | Release built; **Mesting Music / com.mesting.music.beta / 1.0.37-beta.10 / 10** verified; same Beta test certificate; **16KiB ZIP alignment passed**; armeabi-v7a and arm64-v8a server libraries **byte-identical to Beta.9** |
| Beta.10 APK | **89,227,526 bytes**; SHA256 **BEA94A3411EA23E9970AA32AE57EA772937D2ACE4337721E18B00A88A537776A** |
| Beta.10 source ZIP / exact bytes / SHA256 | Owned by external **outputs/beta-1.0.37-beta.10/delivery-manifest.json**, generated after final documentation readback/freeze; this document does not claim that archive was already created or embed its own archive hash |

The groups overlap and must not be summed; the four motion-export checks are additional software fixture evidence and not a new aggregate total. Captures and GIFs use synthetic fixtures, Flutter software rendering and Windows QA CJK fonts. No Android device is attached. Native Android GPU glass/motion/FPS, hardware volume/TalkBack, physical/predictive Back, real IME, cold/upgrade startup, every real login/QR/token/exit path, live CDN quality/permissions and real account/comment/cloud writes remain unverified. General Android compatibility is the scope; no device-specific tuning or reduction of effects/functions is claimed. Preserve Beta.7, Beta.8 and Beta.9 outputs. No installation, publication, commit/push or real user cloud mutation is implied.

The generic notice check icon is gated to Beta; pre-existing formal-channel notice expectations are retained and the final normal regression above passes. This does not change the previously documented channel boundary or establish a global formal-channel redesign.

### Beta.10 implementation entry points

| Entry | Responsibility |
| --- | --- |
| lib/features/auth/beta_entry_flow.dart; presentation/beta_entry_coordinator.dart | Explicit-login stages, restore distinction, deduplication and above-router entry ownership |
| lib/features/auth/presentation/beta_welcome_page.dart; mesting_music_companions.dart | Truthful direction contract, real account/guest/legal entry and original articulated duo |
| lib/features/auth/presentation/beta_onboarding_page.dart; beta_player_style_previews.dart | Eight real-feature pages, skip/replay, interactive demonstrations and shared persistent preferences |
| lib/features/auth/presentation/beta_sign_out_dialog.dart; auth_page.dart; lib/features/settings/presentation/settings_page.dart | Beta account fields/actions, operation waiting/failure, confirmed sign-out and guide replay |
| lib/shared/widgets/beta_glass_controls.dart; beta_anchored_menu.dart; beta_success_feedback.dart; player_comment_glyph.dart | Independent premium controls, measured menus, shared spinner/mark and circular quotation bubble |
| lib/features/experience/presentation/beta_music_shell.dart; beta_now_playing_page.dart; player_content_transition.dart; lib/app/router/app_router.dart | Opaque transition coverage, paired local motion, real direction intent and retained playback/chrome |
| lib/core/audio/playback_providers.dart; lib/features/music_platform/data/platform_playback_resolver.dart | Same-ID media revision and delivered-bitrate truth |

## Historical Beta.9 implementation and delivery boundary

This historical source record targets **Mesting Music / com.mesting.music.beta / 1.0.37-beta.9 / 9**. Its counts, disposition and artifact hashes apply only to Beta.9. It preserves the user's established Apple Music visual direction and North Star, **“封面主导的私人听歌空间”**; no replacement visual concept is introduced. The source is the valuable dirty integration/md3music-beta working tree spanning Beta.5–9. Do not reset or clean it. Formal-channel contracts, account ownership, pinned platform API/server and the single MestingAudioHandler remain.

The following behavior is evidenced by current source and the verified final runs below. Bounded independent disposition is **ship**, with **R1–R5 resolved**. Final regression, analyzer and release package/signature/alignment/native-library verification have completed; source archive bytes/hash remain for the final manifest. Beta.8/Beta.7 results below describe their own historical builds and do not establish a Beta.9 pass.

Delivery target:
C:/Users/Mest/Documents/Codex/2026-10-25/mesting-beta7-handoff-20261025/outputs/beta-1.0.37-beta.9.
The final delivery manifest owns exact artifact bytes, hashes and source-archive identity. Preserve Beta.7 and Beta.8 outputs. No commit, push, installation, real cloud mutation or publication is implied.

### Persistent navigation, system Back and compact chrome

- MusicShell keeps the originating bottom tab and route scroll state. BetaMusicShell remains mounted behind full player/settings and changes only chrome opacity/reveal, preventing a fresh glass accessory entrance on return.
- Both left/right **32dp** fallback strips support inward secondary/search return. Actual Router/system Back reaches embedded search through BackButtonListener before the nested navigator: **results → search landing → originating page**. Standalone search owns the equivalent callback. Interior shelves, lyric scrolling and sliders retain their gestures; Home stays a filled glyph.
- The actual premium/full liquid_glass_widgets 1.15.0 glass remains. Accessory morph uses scroll hysteresis: enter compact above **88dp**, expand at **24dp**. Repeating the current root tab can scroll to top. A small playerChromeReveal ValueNotifier connects handle drag to the still-mounted bottom chrome.
- FloatingPlaybackPill selects only the playing boolean from playback state, rather than rebuilding for every position event. Play/Pause calls the shared live toggle so a quick later tap can cancel Pause's fade; the same engine state owns mini/full controls. The pill still has only play/pause and next, cover/title/artist, open-player tap and horizontal track swipe.

### Deliberate playback, manual queue priority and ordinary continuation

beta_playback_actions.dart centralizes Beta UI selection and error reporting across editorial/library/public/cloud/search/local playlist/history/FM call sites. A single song tap only plays that song; surrounding page contents are never an implicit queue. **Play All** explicitly imports the selected collection.

When existing manual upcoming items require a decision, Keep/Replace/Cancel retains explicit user intent. Play All + Keep plays the chosen collection then appends the old manual tail without duplicate IDs. Single-song Keep retains manual upcoming items while discarding old generated recommendations. Manual upcoming items have priority before automatically generated items, which QueuePage identifies separately.

The existing MestingAudioHandler enables continueAfterExplicitQueue for Beta. When manual items end, completion or Next can request ordinary platform continuation. It preserves actual logical playback history even when the native source index is always zero: Previous returns to a recording that actually played, and no prior history restarts the current recording. It does not invent a previous song from unopened page context. Delayed Next/refill work is generation guarded, coalesced, and reports failures; a later Pause/Stop/Seek invalidates pending advance so discovery cannot restart playback after the user's later command.

PlatformRecommendationSession owns ordinary continuation separately from explicit FM/home-discover sessions. Explicit FM single-song adoption does not import a page batch. FM feedback provenance, server ordering, cur_mark and account/generation checks remain; ordinary continuation does not impersonate an FM stream. No local-library/random recommendation pool is introduced. The embedded native service and pinned API are unchanged.

### Strict per-resource quality and actual engine source

PlatformQualityCatalog retains **tier → encoding hash**, including separate standard/high/lossless/Hi-Res resources. The chooser hides unsupported tiers but retains supported locked tiers; permissions are explained only after an actual attempt and platform response. Unknown/failed metadata remains manually retryable without a loop.

A strict switch fetches resource metadata and requests the target encoding's hash. In particular, switching lossless down to high/standard does not reuse the current FLAC hash and mislabel its returned stream. The highest-quality VIP URL path cannot override an explicitly lower requested tier; the standard endpoint is available for the exact request. Delivered quality is validated before replacing the engine source. Synchronous audio ownership prevents stale preference/notice updates. Selection check, toast/footer and the actual engine source agree before the saved preference changes.

Position, playing/paused state, logical queue and playback mode survive a valid source refresh. Failure preserves the current working stream and previous saved preference. Trial, fallback/downgrade, preferred and actual tiers retain truthful separate disclosure; platform membership permissions are not manufactured by the UI.

### Neutral light surfaces, compact titles and automatic song paging

The visible Beta name is **Mesting Music**, including the Android app label. Classic light panels change from pale pink to neutral white/gray: BetaAppearance.panel(light) is **#F2F2F7**, with white base surfaces and neutral container layers. Reference red navigation/selection accent, existing dark appearance and cover-based player atmosphere remain. Existing appearance migrations and retained features are unchanged by this palette correction.

PlatformPageFrame uses a **21dp / 700 / 1.2** single-line detail title with -.5 letter spacing. OverflowMarquee resolves inherited font/spacing and TextScaler for both measure/render, clips only real overflow and translates a stable child without per-frame relayout. Reduced motion leaves it static. Main landing titles retain their established hierarchy.

AutomaticSongPaging prefetches from fresh ScrollMetrics when extentAfter ≤480dp and fills an initially short viewport. Hidden TickerMode pages do not schedule loading; newly enabled content does not reuse stale short-list metrics. Lazy rows/slivers cover search, explore, recommendation, favorite, cloud and public playlist song lists. Server order, account generations and existing repository paging remain. Normal state has no manual load-more button; failure preserves visible content and offers retry. Search summary is **共 N 首** only. Hot boards keep board/rank/ten-word-page behavior.

### Pure hearts, Replay and handle-only dismissal

FavoriteToggleButton retains a transparent **48×48dp** target and pure outlined/filled hearts, local neutral idle color and brightness-adapted red selected color. Pointer feedback is .88/120ms. A successful state change triggers a local, interruptible **420ms** fill/outline plus scale pulse: like reaches 1.24, unlike .8, then settles. Reduced motion reaches the final state; failed cloud writes cannot trigger a fake success celebration. Owner and keyboard activation remain.

Replay year uses Cupertino opacity feedback and the shared light/neutral PlayerMoreMenu popover, avoiding a rectangular press overlay. The actual owner-bound daily/year/month statistics are unchanged and missing months are never fabricated.

Five player styles and cover/lyrics state keep their original upper scenes/effects and shared lower controls. Only the top gray **112×36dp** handle starts down-pull/tap dismissal; cover/lyrics/rails do not compete. Commit/rebound and reduced-motion completion reveal the mounted capsule smoothly. Existing white geometric outer-groove tonearm, contrast correction, Android media volume/semantics, and grouped more menu remain.

### Compact comment controls and real blue 3D Liquid Glass Send

Sort (最热/最新/最早) and scope (全部/歌手/我的) are two dropdowns on one row. They preserve all existing sort/scope choices, selected values, loaded-data/global-hot explanation and reply/delete behavior. Dates, like counts and sort notes use the local textSecondary token for readable light/dark and narrow large-text presentation.

PlatformCommentComposer uses **two independent sibling glass surfaces**: a premium GlassContainer input and a premium **48×48dp blue GlassButton.custom** Send, each useOwnLayer=true inside its own RepaintBoundary. The button uses actual liquid_glass_widgets rendering rather than a raster imitation; nesting it inside the input's glass would suppress its refraction and is prohibited by this renderer contract. Its upward white arrow becomes a real sending indicator while the explicit operation is busy. Blue is local to Send; red remains the global accent.

The input is 24dp rounded, 16dp/1.4 text, maximum 1000 characters. **KeyboardVisibilityBuilder** observes the current native View.viewInsets via metrics changes even under a resized Scaffold, avoiding already-consumed body MediaQuery. The input allows **2 lines with keyboard / 4 without**. The floating row is compact and bottom aligned; input and Send do not collapse into one nested glass surface.

Recording-specific IDs, bounded read-only stale-ID/device recovery, real reply/thread/delete IDs and account guards remain. Send/reply/delete require explicit user actions and are never automatically retried. Comment reactions and playlist track reordering remain deferred. Source/raster/software appearance is not a substitute for native Android GPU material acceptance.

### Beta.9 evidence, current status and remaining acceptance

Evidence root:
C:/Users/Mest/Documents/Codex/2026-10-25/mesting-beta7-handoff-20261025/work/beta9.

| Evidence | Recorded scope / current status |
| --- | --- |
| Current implementation source | Behavior and exact values described above; no test result inferred from code |
| pill-benchmark.json | Same 100 position events: Beta.8 glass control 99 rebuilds, Beta.9 0; source restored after comparison |
| beta9-finish-verdict.md | Bounded independent **ship** disposition; R1–R5 resolved after recapture/source/behavior review |
| Final normal regression | **619 passed / 52 conditional skips / 0 failed** |
| Final Beta targeted group | **132 passed / 0 skipped / 0 failed** |
| ui-final.jsonl / commands-final.jsonl | Software UI **23 passed**, command/interaction **21 passed**, both 0 failed / 0 skipped; all groups overlap |
| Final analyze | **No issues found** |
| Release APK / signature / package / alignment / ARM libraries | **88,964,062 bytes**, com.mesting.music.beta / Mesting Music / 1.0.37-beta.9 / 9; same Beta certificate, 16KiB ZIP alignment passed, both ARM service binaries byte-identical to Beta.7 |
| APK SHA256 | **F37AE0B53A2BD57D9EB40A340B1665CB2B5109F2CC4C7C9C1DA4623585B892E4** |
| Source ZIP / manifest / SHA256 | Actual working-tree snapshot; per-file verification, exact byte count and SHA256 are owned by the delivery artifact manifest |

The pill benchmark is Flutter debug rebuild work, **not FPS, frame time, native GPU optics or device smoothness**. Screenshots use synthetic local data, Flutter software rendering and Windows QA Chinese fonts. No Android device is attached. Hardware media volume, TalkBack speech/gestures, predictive/physical Back arbitration, real IME behavior, native GPU glass/motion/frame rate, cold/upgrade migration, live CDN playback/quality/entitlement and real account/comment/cloud writes remain unverified. General Android compatibility is the scope; no device-model-specific optimization is claimed.

### Beta.9 implementation entry points

All paths are relative to the project root.

| Entry | Responsibility |
| --- | --- |
| lib/features/player/presentation/music_shell.dart; lib/features/experience/presentation/beta_music_shell.dart | Persistent mounted shell, source tab/scroll, native Back dispatch and 88/24dp scroll hysteresis |
| lib/shared/widgets/beta_edge_back.dart; lib/features/search/presentation/music_search_page.dart | 32dp two-edge and standalone search return |
| lib/features/player/presentation/beta_playback_actions.dart; lib/core/audio/mesting_audio_handler.dart | Explicit single/Play All and queue choice; logical history, manual priority, generation-guarded continuation |
| lib/features/music_platform/platform_recommendation_providers.dart; lib/features/queue/presentation/queue_page.dart | Ordinary/FM session provenance and visible generated queue items |
| lib/features/music_platform/data/platform_quality_catalog.dart; platform_playback_resolver.dart; lib/features/music_platform/platform_quality_providers.dart; lib/features/music_platform/presentation/platform_quality_button.dart | Encoding hash catalog, exact source request/validation and truthful persisted selection |
| lib/shared/widgets/overflow_marquee.dart; lib/features/music_platform/presentation/platform_design.dart | Inherited-font single-line 21dp detail titles |
| lib/shared/widgets/automatic_song_paging.dart; lib/features/search/presentation/apple_search_results.dart | Fresh-metrics lazy automatic paging and total-only search count |
| lib/features/library/presentation/favorite_toggle_button.dart; lib/features/experience/presentation/listening_replay_page.dart; player_more_menu.dart | Local 420ms pure-heart state, opacity year feedback and shared rounded menu |
| lib/features/experience/presentation/floating_playback_pill.dart; player_chrome_reveal.dart; player_pull_to_dismiss.dart | Playing-boolean mini control, shared toggle and handle-only reveal/dismiss |
| lib/features/music_platform/presentation/platform_comments_page.dart; platform_comment_composer.dart; lib/shared/widgets/keyboard_visibility_builder.dart | One-row dropdowns, real sibling glass composer and native keyboard 2/4-line adaptation |
| lib/features/themes/beta_appearance.dart; app_theme.dart; android/app/src/beta/res/values/strings.xml | Neutral classic light and visible Mesting Music identity |

The Beta.9 build used **Flutter 3.41.9 / Dart 3.11.5** and script target **1.0.37-beta.9 / 9**, ARMv7 + ARM64, while pubspec kept the formal baseline version. The current script target is Beta.10 above. Use `flutter test --flavor beta` for Beta suites; do not replace actual appFlavor with a FLUTTER_APP_FLAVOR dart-define. A build invocation does not publish an update manifest, deploy a backend or authorize installation.

## Historical Beta.8 accepted implementation and delivery boundary

This is the historical implementation record for **1.0.37-beta.8 / 8**, reviewed on
2026-10-25. Its 20dp edges, shell unmounting, loaded-count wording and playback-context behavior are superseded by Beta.9 above; its passing results apply only to Beta.8. Disposition: **SHIP WITH STATED VALIDATION LIMITS**; R1/R2/R3 closed.
The established Apple Music authority and North Star continue. Preserve formal
channel contracts, account ownership, recommendation provenance and the single
MestingAudioHandler. General Android compatibility is in scope; effects,
animation and functions remain, with no device-model-specific optimization.

Delivery target:
C:/Users/Mest/Documents/Codex/2026-10-25/mesting-beta7-handoff-20261025/outputs/beta-1.0.37-beta.8.
The final manifest owns exact artifact bytes/hashes and source-archive identity.
Beta.6/Beta.7 hashes/counts below identify historical builds only. No clean
checkout, commit, push, installation, cloud mutation or publication is implied.

### Navigation, search and compact interactions

- MusicShell persists the originating tab and passes navigationOwner to
  BetaMusicShell. Detail routes retain it; explicit roots update it. Player/
  settings can unmount visible glass chrome without losing the owner. R1
  regression covers Profile and Library through Favorites, Settings and Player.
- BetaEdgeBack handles inward drags in both 20dp edge strips on secondary routes
  and embedded/standalone search steps, leaving interior shelves/sliders alone.
  Home uses a filled glyph.
- AppleSearchResults uses one lazy CustomScrollView/SliverList, retaining genuine
  server paging/order, total versus loaded counts, compact identity, 52dp covers,
  bare hearts and more actions. AppleHotSearchBoards retains real board selection,
  ranks and ten-word pages, two columns or three at 650dp available width.
  Keywords remain search actions.
- Replay year press feedback/menu share explicit clipped 20dp rounding.
- PlayerMoreMenu anchors to the top button, with icons, grouped separators and
  the current-style checkmark. Its 22dp rounded popover caps at 280dp width,
  keeps at least 16dp horizontal clearance, wraps text and scrolls as needed.

### One audio owner, gestures and truthful controls

Five styles (cover/classic/aurora/cassette/lyricStage), in cover/lyrics state,
retain their effects and common controls. Only the top grey PlayerDismissHandle
starts PlayerPullToDismiss: the 112×36dp region supports tap/downward drag,
smooth dismissal commit/rebound and reduced-motion completion. Covers, lyric
scrolling and sliders do not start dismissal.

Global Previous/Next distinguishes explicit list context from FM history/server
order. Previous resolves history/context before forward Up Next; returnToUpcoming
restores the original recording. B → A → B and first A → wrapped C → A are
reversible. Cold FM Previous restarts the current song without consuming the next
recommendation. This resolves R2 through the existing audio owner and retains
recommendation continuation.

System media volume retains a fine rail and **48dp high** responsive region,
with immediate local drag feedback. MediaVolumeController permits one native
write in flight and keeps only the latest pending value; duplicate Dart state,
native events and identical STREAM_MUSIC steps are suppressed. Foreground
refresh, lifecycle disposal, support probing and unsupported-host disabling
continue.

FavoriteToggleButton is bare wherever reused, with a transparent **48×48dp**
target; compact changes glyph size only. Idle color is actual local
onSurfaceVariant; selected uses the brightness-aware Beta accent. Immediate
pointer feedback scales to .88 over 120ms. Existing keyboard activation,
ownership and real write result remain. R3 is closed. Classic preserves its
contrast correction and white geometric tonearm without black outline, the
cartridge on black outer grooves beyond the label, and playing/paused rotation.

### Per-song quality and platform identity

PlatformQualityCatalog parses positive resource hashes/explicit tiers and shows
only confirmed per-song choices. A standard-only song shows standard only;
membership flags do not create resources. Unknown/failed metadata has manual
reload and no automatic retry loop. The 30dp light/dark translucent dialog follows
song changes and binds selections to recording IDs. Membership guidance appears
only after an attempted selection and platform response. Preferred/delivered
tiers, trial, downgrade and unknown delivery remain distinct. Existing source
refresh retains position, playback state, queue/mode; failure preserves the old
stream and saved preference.

PlatformSongIdentity searches structured recording-specific aliases before
generic Audioid/audio_id. Comment reads allow bounded stale-ID metadata repair
or a single device-registration recovery retry. Send/reply/delete retain
explicit actions, real thread IDs, account guards and no automatic write retry.
Reaction writes remain deferred. PlatformCatalog accepts special_list/plist
for featured playlists and songlist for rank songs. Platform account entry uses
the actual coral Mesting application-icon asset.

Beta.8 removes the IP-decoration switch while retaining explicit progress
palettes/characters, superseding historical Beta.6/Beta.7 switch descriptions.
Theme retirement, followTheme/coral migration, .58 background strength and
automatic performance behavior continue. No data-schema migration or local
data clearing is introduced.

### Beta.8 evidence and limits

Evidence root:
C:/Users/Mest/Documents/Codex/2026-10-25/mesting-beta7-handoff-20261025/work/beta8.

| Evidence | Confirmed scope |
| --- | --- |
| beta8-finish-verdict.md | SHIP WITH STATED VALIDATION LIMITS; R1/R2/R3 closed |
| ui-verdict.jsonl | Combined **33 passed / 0 failed**: **14 UI** plus **19 transport/gesture/API/volume** checks |
| regression-shipped.jsonl | Normal **602 passed / 47 conditional skips / 0 failed**, terminal success |
| targeted-shipped.jsonl | Beta targeted **110 passed / 0 skipped / 0 failed**, terminal success |
| analyze-shipped.log | No issues found |
| build-shipped.log; work/release-verification/artifact-verification.json | Release successful; com.mesting.music.beta / 1.0.37-beta.8 / 8; same test certificate, 16KiB ZIP alignment, both ARM server binaries byte-identical to Beta.7 |
| volume-before.log / ui-verdict.jsonl | Same 100 rapid samples: 100 native writes before, 2 after, final 1.0 |
| ui-verdict.jsonl search fixture | 480 loaded songs / 10 artwork widgets instantiated at a phone viewport |
| screenshots-verdict | Software captures with synthetic local data and QA CJK fonts |
| design-detection.json | Empty findings array; only that detector's scope |

Groups overlap: **never add them into a total**. Write/coalescing and lazy-widget
measurements establish bounded work, not FPS, frame time or Android hardware
smoothness. The finish verdict preceded the subsequently completed owner
regression/analyzer/build; this table records those later confirmed results.

adb devices is empty. Hardware volume, TalkBack speech/gestures, Android
predictive Back/physical gesture arbitration, real IME, GPU glass/motion/frame
rate, cold/upgrade migration, live CDN playback/quality/entitlement and live
account/comment/cloud writes remain unverified. No installation or live cloud
write occurred. Exact hashes and archive checks belong in the final manifest.

### Beta.8 implementation entry points

All paths are relative to the project root.

| Entry | Responsibility |
| --- | --- |
| lib/features/player/presentation/music_shell.dart; lib/features/experience/presentation/beta_music_shell.dart | Persistent tab owner and visible glass shell |
| lib/shared/widgets/beta_edge_back.dart | Two-edge secondary/search-step return |
| lib/features/search/presentation/apple_search_results.dart; lib/features/music_platform/presentation/apple_hot_search.dart | Lazy results / compact ranked keywords |
| lib/features/experience/presentation/player_pull_to_dismiss.dart; player_more_menu.dart | Handle-only commit/rebound / anchored popover |
| lib/features/experience/presentation/apple_player_controls.dart; lib/core/audio/media_volume_controller.dart; android/app/src/main/kotlin/com/mesting/mesting_music/MediaVolumeBridge.kt | Responsive rail / serialized native writes and suppression |
| lib/core/audio/mesting_audio_handler.dart | Single audio owner / explicit context, FM history and reversible Previous |
| lib/features/library/presentation/favorite_toggle_button.dart; lib/features/player/presentation/player_visual_stages.dart | Bare hearts / outer-groove geometric tonearm |
| lib/features/music_platform/data/platform_quality_catalog.dart; lib/features/music_platform/platform_quality_providers.dart; lib/features/music_platform/data/platform_playback_resolver.dart; lib/features/music_platform/presentation/platform_quality_button.dart | Resource catalog / preference / permitted source / chooser |
| lib/features/music_platform/data/platform_catalog.dart; lib/features/music_platform/data/platform_comments_repository.dart; lib/features/music_platform/data/platform_song_identity.dart | Parsing envelopes / bounded comment identity reads |
| lib/features/experience/presentation/listening_replay_page.dart; lib/features/music_platform/presentation/platform_account_page.dart; lib/features/themes/theme_gallery_page.dart | Rounded year / exact icon / Beta appearance scope |

Build with Flutter 3.41.9 / Dart 3.11.5. The script defaults to 1.0.37-beta.8 / 8,
ARMv7 + ARM64, retaining formal pubspec version and the existing private Beta
identity/update isolation. The build command below remains applicable; it does
not publish an update manifest or deploy a backend.

## Historical Beta.7 accepted implementation and delivery boundary

This section records the historical built truth for **1.0.37-beta.7 / 7**, merged after
final finish review on 2026-10-25. The disposition is **SHIP WITH STATED
VALIDATION LIMITS**: R1–R3 are resolved in the reviewed source/widget/capture
scope. Earlier Beta.6/Beta.5/Beta.4 records below remain historical context;
where behavior differs, the current Beta.10 section and retained Beta.9 baseline above take precedence. No commit or clean
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

Build with **Flutter 3.41.9 / Dart 3.11.5**. At the Beta.7 build, the script defaulted to Beta.7 name/code
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
script at the Beta.6 handoff defaulted to **1.0.37-beta.6 / 6**; `pubspec.yaml` keeps its formal
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

## Historical Beta.5 presentation and library changes

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

The current Beta.10 script selects version `1.0.37-beta.10` / `10`, ARMv7 + ARM64; this historical section does not imply a new Beta.5 build. `pubspec.yaml`
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
| `features/music_platform/presentation/platform_comments_page.dart`, `platform_comment_composer.dart` | Opaque comment/thread routes, one-row dropdowns and independent floating glass input/send with explicit reply/delete/write actions |
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

## Historical Beta.4 search and comment corrections

Beta search bypasses the legacy MusicSearchRepository's fuzzy reordering and
title/artist deduplication. It follows upstream KugouApiClient.search parameters:
`/search`, `keywords`, `type=song`, page starting at 1 and `pagesize=30`.
`total`/`total_count` are displayed separately from loaded rows. Appending removes
only repeated file IDs and preserves distinct recordings and server order. A
generation token, abort signal and account checks reject stale responses. Failed
appends retain the visible list and retry the same page. Repeated pages stop
loading instead of creating an infinite request loop. That Beta.4 result list supported near-bottom loading and an explicit load-more/retry action. Beta.9 replaces normal load-more actions with automatic paging and retains error retry only.

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

The build script selects `beta`, version `1.0.37-beta.10` / `10`, ARMv7 + ARM64,
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
