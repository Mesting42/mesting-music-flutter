---
version: 1
slug: "es-experience-presentation-music-landing-page-dart"
primary_target: "lib/features/experience/presentation/music_landing_page.dart"
related_targets: ["lib/features/experience/presentation/beta_music_shell.dart","lib/features/experience/presentation/beta_bottom_bar.dart","lib/features/experience/presentation/floating_playback_pill.dart","lib/features/experience/presentation/music_library_page.dart","lib/features/experience/presentation/beta_now_playing_page.dart","lib/features/experience/presentation/apple_player_controls.dart","lib/features/experience/presentation/immersive_lyrics.dart","lib/features/music_platform/presentation/platform_recommendations_page.dart","lib/features/music_platform/presentation/platform_search_landing.dart","lib/features/playlists/presentation/playlist_editor_dialog.dart","lib/features/player/presentation/music_shell.dart","lib/shared/widgets/beta_edge_back.dart","lib/features/experience/presentation/player_pull_to_dismiss.dart","lib/features/experience/presentation/player_more_menu.dart","lib/features/search/presentation/apple_search_results.dart","lib/features/music_platform/presentation/apple_hot_search.dart","lib/features/music_platform/data/platform_quality_catalog.dart","lib/features/music_platform/platform_quality_providers.dart","lib/core/audio/media_volume_controller.dart","lib/core/audio/mesting_audio_handler.dart"]
---

# Mesting Beta.8 music surfaces

Mode: Operate, with cover art leading the listening experience. This record merges Beta.8 into the earlier Beta.5/Beta.6/Beta.7 surface. Preserve the established Apple Music authority and North Star; the Beta.8 section below takes precedence. The prior theme-owned Beta accent, round transport backgrounds, width-dependent mini queue action and followTheme selection descriptions are superseded below.

Approved visual authority: the user's Apple Music screenshots for home, discovery, glass navigation, lyrics, playlist editing and month/year Replay, plus the later pinned red-navigation, lyric/transport and two-action mini-player references. Keep Mesting naming and Chinese UI. These references establish composition and glyph direction; widget screenshots cannot promise exact native Apple GPU optics or performance.

The physical scene is one-handed Android use during commuting and quiet evening listening. Beta.7 unifies selected navigation icons/text and related choices using the sampled reference red, with a brighter dark-mode accent. Profile icons follow that accent and panels adapt pale red to dark red. Text remains a semantic neutral; the selected progress/character labels retain primary text contrast while explicit IP artwork keeps its own colors. Formal flavor theme, navigation, default vinyl and custom recommender behavior remain separate.

## Floating chrome and search

Beta uses the actual liquid_glass_widgets 1.15.0 official Apple Music example composition: GlassScaffold, GlassTabBar.searchable and GlassButton.custom, with package-owned press/drag springs and accessory morphing. Preserve Mesting routes, Chinese search and audio actions. Source snapshot: third_party/liquid_glass_widgets/.

Phone and wide Beta windows share one bottom navigation without an expanded rail or its 88dp spacer; adaptive content caps remain. The official bar owns safe area and keyboard lift. Search content extends behind glass, with internal bottom clearance and shell keyboard avoidance only for content. The old full-width opaque white search background strip is removed. A transparent Material supplies normal text defaults. Scrolling past 50dp compacts the accessory inline; tapping the current destination returns to the top.

The mini accessory shows cover/title/artist and exactly two bare icon controls: play/pause and next. Tapping opens the player; horizontal swipe changes track. A narrow layout can omit artist text but does not add a queue action. Use official premium/full chrome optics (blur 2, thickness 30, lightIntensity .2; play pill .18), separately from older MestingGlass settings and fallback claims.

## Player and lyrics

Default player is the square cover. All five styles—cover, classic, aurora, cassette, lyricStage—retain their upper visual identity/motion and share ApplePlayerControls below. Both cover and lyric modes show progress/time, bare white Cupertino previous/play-pause/next, Android system-media-volume rail, then comments / quality / current queue. Do not restore the older large white play circle or smaller filled transport circles.

Classic keeps its grey turntable, with local dark translucent fills behind top collapse/more actions, stronger lower veil, and opaque white artist text. These close the reviewed contrast finding without replacing the style identity. The lyric view uses small top artwork and song identity, a blurred-cover backdrop, left-aligned synchronized lines, bright active text, dim inactive text and fading edges. Current base type is 24dp with TextScaler and measured line heights; tapping a synchronized line seeks. Short windows scroll and retain all controls.

Seek and volume expose separate merged semantic nodes: 播放进度 with elapsed/total time, and 系统媒体音量 with a percentage. Native adjustable actions remain. MediaVolumeController and Android MediaVolumeBridge control STREAM_MUSIC, accept volume events and refresh when resumed; unsupported hosts leave the rail disabled. Unit/widget evidence covers names, values, actions and read/set/event/missing-host behavior; hardware keys and Android TalkBack remain unverified.

All styles retain one persisted quality preference; the earlier fixed standard/high/lossless/Hi-Res menu is superseded by the Beta.8 per-song resource chooser below. Existing audio-handler source refresh preserves position, playing/paused state, logical queue and mode, rejecting stale commands. Preferred and delivered tiers remain separate; unknown metadata, permitted trials and downgrades are disclosed.

## Discovery and search provenance

Discovery exposes upstream private FM, daily, home-discover and new-song modules in the approved Mesting composition. Contracts are pinned to md3Music a69503b84e8829f888684f67c163be03c589c014. FM stations are heart/explore/niche/radio (红心/探索/小众/电台), retaining station mode/pool, cur_mark, completion/playtime and like/dislike feedback with account isolation. Pull-to-refresh reloads platform modules. No Beta artist scoring or personal hot list is inserted.

FM/home-discover provenance belongs to an explicitly started recommendation queue, not a preview fetch. At ≤3 remaining upcoming items, continuation appends server-ordered results to the actual visible queue; no local-library/random fallback pool participates. Explicit non-recommendation playback ends provenance even for the same recording. Account/session and generation guards reject stale responses and feedback ownership stays with the originating stream.

Search uses actual /search/hot keyword boards, history and theme/scene/playlist/rank/album exploration. A hot keyword starts a real search; it is never rendered as a fabricated playable track. Both shell and standalone Beta search use the platform landing; legacy curated routes redirect Beta to discovery. Keep the currently connected capability scope: scene chips are display-only, and theme rows have no playback action; do not imply every upstream endpoint is a completed flow. The formal channel retains its prior recommendation/search implementation.

## Appearance and status feedback

Beta dress-up removes the brand picker, redundant Skin heading/description/classic card, DRESS UP eyebrow and followTheme choices. Keep light/dark/system appearance, custom image/video, player styles, explicit progress palettes/characters. Beta.8 removes the IP-decoration switch, superseding the Beta.6/Beta.7 retention description. Coral launcher/splash is fixed and old brand choices migrate. Residual followTheme aliases become classic in Beta.7; previously migrated explicit IP values remain. Full IP skins still retire to classic, background strength remains .58 and performance automatic. Formal theme behavior remains.

Lightweight feedback uses one replaceable top-safe-area translucent HUD with a short title and glyph, dark/light adaptation, motion and live-region semantics. Ordinary subtitles are omitted; actionable warning/error detail remains. This is a presentation of the existing operation's outcome, not a new business success state.

## Retained library and editing contracts

Home combines cover-led top picks, recent listening, discoveries and Replay. Library unifies favorites, playlists, recent listening and Replay for the active owner. Glass is reserved for floating chrome; content and account forms use stable theme surfaces.

Artwork parsing and read-only metadata recovery serve recommendation/search/playlist/player covers, coalesce requests, limit concurrency to 3 and cache 256 successes without permanently caching failures. Playlist editing remains a rounded sheet with templates/gallery, name, description, cancel and confirm. Normalize a selected image to 640px PNG; an owned cloud list uses the embedded upstream upload/update contract. Cloud failure retains drafts; no automatic mutation retry or cross-account write.

Replay uses real daily records for the active owner; missing historical months are never reconstructed. Preserve comments, real search pagination, account/library ownership and quality-state preservation from earlier Beta work. Track reordering and comment reaction writes remain separately deferred.

## Beta.8 current interactions and validation

MusicShell persists the originating tab while player/settings/search layouts
unmount the visible glass shell; BetaMusicShell receives navigationOwner. Explicit
roots update the owner; detail routes retain it. Home has a filled glyph.
BetaEdgeBack uses only left/right 20dp strips for secondary routes and embedded/
standalone search steps, retaining interior slider and shelf gestures.

AppleSearchResults owns one lazy CustomScrollView/SliverList with real paging,
server order, total/loaded counts, 52dp artwork, compact song identity, bare hearts
and more actions. AppleHotSearchBoards retains board selection, ranks and ten-word
pages, using two columns or three at 650dp available width. Keywords remain search
actions. A 480-row phone fixture instantiates ten artwork widgets; this is a
construction boundary observation, not FPS.

Only the top grey PlayerDismissHandle starts PlayerPullToDismiss. Its 112×36dp
interaction region supports tap/downward drag; all five styles in cover/lyrics
mode share smooth commit/rebound and reduced-motion completion. Cover, lyric
scrolling and rails do not compete for dismissal. PlayerMoreMenu anchors to the
top button with action icons, grouped separators and a current-style checkmark:
22dp rounding, maximum width 280dp, at least 16dp side clearance, wrapping and
internal scrolling for narrow/large-text layouts.

Favorites use bare heart glyphs with transparent 48×48dp targets, including
compact uses. Idle reads the local onSurfaceVariant, selected reads the
brightness-aware Beta accent; pointer feedback scales to .88 over 120ms.
Activation and real cloud outcomes retain their existing owner. The white
geometric tonearm has no black outline, contacts black outer grooves beyond the
cover label and retains playing/paused rotation. Replay year feedback and popup
both use clipped 20dp rounding.

Media volume retains a fine visual rail, 48dp high hit region and immediate local
drag feedback. Dart serializes native writes and keeps the latest pending value;
unchanged Dart state, duplicate native events and equal system volume steps are
suppressed. The same 100 rapid samples changed from 100 writes before to two
after, final value 1.0. This bounds channel traffic, not hardware smoothness.

Global Previous/Next separates explicit playback context from FM history/server
order. Previous then Next returns to the original recording without consuming
the next recommendation. MestingAudioHandler remains the sole audio owner;
recommendation provenance is unchanged.

PlatformQualityCatalog offers only current-song tiers supported by positive
resource hashes/explicit records; membership flags do not manufacture resources.
Unknown/failed metadata offers manual reload, with no automatic retry loop.
The 30dp light/dark translucent dialog follows song changes and binds choices to
a recording ID. Membership guidance appears only after attempted selection and
the platform result. Failure preserves the stream and saved preference; actual,
preferred, trial, downgrade and unknown delivery remain separate.

Comments search structured recording-specific IDs before generic audio aliases.
Bounded stale-ID metadata repair or device-registration retry applies to reads
only; explicit comment writes retain account guards and no automatic retry.
Featured playlists parse special_list/plist; rank songs parse songlist. Platform
account entry uses the actual coral Mesting application-icon asset.

Current Beta.8 disposition is SHIP WITH STATED VALIDATION LIMITS; R1/R2/R3 closed.
Evidence root is work/beta8: ui-verdict.jsonl has a combined 33 passed (14 UI plus
19 transport/gesture/API/volume checks), normal regression-shipped.jsonl has
602 passed / 47 conditional skips, and Beta targeted-shipped.jsonl has 110 passed
/ zero skips; all have zero failures and overlap, so never sum them. Analyzer:
No issues found. Release build, com.mesting.music.beta / 1.0.37-beta.8 / 8, same
test certificate, 16KiB alignment and byte-identical embedded ARM server
libraries versus Beta.7 are verified. Hashes/source archive belong to the final
manifest. Current screenshots are work/beta8/screenshots-verdict.

No Android device is attached. Captures use synthetic data, software rendering
and Windows QA CJK fonts. Hardware volume, TalkBack, predictive Back/physical
gesture arbitration, real IME, GPU/motion/frame-rate, cold/upgrade migration,
live CDN/quality/entitlement and account/comment writes remain unverified.
Boundary measurements do not establish FPS. General Android compatibility is
the scope; effects/animation/function are retained, with no model-specific tuning.

Current entry points: MusicShell / BetaMusicShell.navigationOwner; BetaEdgeBack;
PlayerPullToDismiss; AppleSearchResults; AppleHotSearchBoards; PlayerMoreMenu;
PlatformQualityCatalog/provider/resolver; MediaVolumeController/Bridge;
MestingAudioHandler; PlatformCatalog/comments/song identity. Full paths and
historical facts are retained in docs/MD3MUSIC_BETA.md.

## Historical Beta.7 evidence and retained validation boundaries

Historical Beta.7 disposition: SHIP WITH STATED VALIDATION LIMITS, with R1–R3 resolved in the supplied source/widget/capture scope. Final UI evidence is work/beta7/screenshots-verdict; R1/R2 closure also retains screenshots-approved evidence. ui-verdict.log has 8 passing tests. Search-chip/subtitle CJK QA font coverage is fixed in the final captures and is no longer an open product defect. Logs and fixtures overlap; do not add groups into a total. Exact deliverable files and hashes belong in the Beta.7 delivery manifest.

No Android device was connected. Hardware/system-volume synchronization, TalkBack speech/gestures, real IME transitions, GPU glass/motion, launcher/splash upgrade migration, live CDN playback/quality switching and live account/cloud operations remain unverified. Captures use synthetic local data, Windows QA fonts and Flutter software rendering.

Implementation entry points: the related_targets above; platform_recommendations.dart, platform_explore.dart, platform_recommendation_providers.dart for server provenance; beta_appearance.dart, app_theme.dart, theme_controller.dart, app_brand_style.dart and theme_gallery_page.dart for red/appearance migration; music_notice.dart for shared HUD. Use docs/MD3MUSIC_BETA.md for the integration handoff and historical supersession details.
