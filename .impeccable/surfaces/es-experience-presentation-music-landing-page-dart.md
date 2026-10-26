---
version: 1
slug: "es-experience-presentation-music-landing-page-dart"
primary_target: "lib/features/experience/presentation/music_landing_page.dart"
related_targets: ["lib/features/experience/presentation/beta_music_shell.dart","lib/features/experience/presentation/beta_bottom_bar.dart","lib/features/experience/presentation/floating_playback_pill.dart","lib/features/experience/presentation/music_library_page.dart","lib/features/experience/presentation/beta_now_playing_page.dart","lib/features/experience/presentation/apple_player_controls.dart","lib/features/experience/presentation/immersive_lyrics.dart","lib/features/music_platform/presentation/platform_recommendations_page.dart","lib/features/music_platform/presentation/platform_search_landing.dart","lib/features/playlists/presentation/playlist_editor_dialog.dart"]
---

# Mesting Beta.7 music surfaces

Mode: Operate, with cover art leading the listening experience. This record merges the approved Beta.7 implementation into the earlier Beta.5/Beta.6 surface. The prior theme-owned Beta accent, round transport backgrounds, width-dependent mini queue action and followTheme selection descriptions are superseded below.

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

All styles use one persisted standard/high/lossless/Hi-Res preference and a dark translucent rounded quality popup. Existing audio-handler source refresh preserves position, playing/paused state, logical queue and mode, rejecting stale commands. Preferred and delivered tiers remain separate; unknown metadata, permitted trials and downgrades are disclosed.

## Discovery and search provenance

Discovery exposes upstream private FM, daily, home-discover and new-song modules in the approved Mesting composition. Contracts are pinned to md3Music a69503b84e8829f888684f67c163be03c589c014. FM stations are heart/explore/niche/radio (红心/探索/小众/电台), retaining station mode/pool, cur_mark, completion/playtime and like/dislike feedback with account isolation. Pull-to-refresh reloads platform modules. No Beta artist scoring or personal hot list is inserted.

FM/home-discover provenance belongs to an explicitly started recommendation queue, not a preview fetch. At ≤3 remaining upcoming items, continuation appends server-ordered results to the actual visible queue; no local-library/random fallback pool participates. Explicit non-recommendation playback ends provenance even for the same recording. Account/session and generation guards reject stale responses and feedback ownership stays with the originating stream.

Search uses actual /search/hot keyword boards, history and theme/scene/playlist/rank/album exploration. A hot keyword starts a real search; it is never rendered as a fabricated playable track. Both shell and standalone Beta search use the platform landing; legacy curated routes redirect Beta to discovery. Keep the currently connected capability scope: scene chips are display-only, and theme rows have no playback action; do not imply every upstream endpoint is a completed flow. The formal channel retains its prior recommendation/search implementation.

## Appearance and status feedback

Beta dress-up removes the brand picker, redundant Skin heading/description/classic card, DRESS UP eyebrow and followTheme choices. Keep light/dark/system appearance, custom image/video, player styles, explicit progress palettes/characters and IP-decoration switch. Coral launcher/splash is fixed and old brand choices migrate. Residual followTheme aliases become classic in Beta.7; previously migrated explicit IP values remain. Full IP skins still retire to classic, background strength remains .58 and performance automatic. Formal theme behavior remains.

Lightweight feedback uses one replaceable top-safe-area translucent HUD with a short title and glyph, dark/light adaptation, motion and live-region semantics. Ordinary subtitles are omitted; actionable warning/error detail remains. This is a presentation of the existing operation's outcome, not a new business success state.

## Retained library and editing contracts

Home combines cover-led top picks, recent listening, discoveries and Replay. Library unifies favorites, playlists, recent listening and Replay for the active owner. Glass is reserved for floating chrome; content and account forms use stable theme surfaces.

Artwork parsing and read-only metadata recovery serve recommendation/search/playlist/player covers, coalesce requests, limit concurrency to 3 and cache 256 successes without permanently caching failures. Playlist editing remains a rounded sheet with templates/gallery, name, description, cancel and confirm. Normalize a selected image to 640px PNG; an owned cloud list uses the embedded upstream upload/update contract. Cloud failure retains drafts; no automatic mutation retry or cross-account write.

Replay uses real daily records for the active owner; missing historical months are never reconstructed. Preserve comments, real search pagination, account/library ownership and quality-state preservation from earlier Beta work. Track reordering and comment reaction writes remain separately deferred.

## Evidence and validation boundaries

Final disposition: SHIP WITH STATED VALIDATION LIMITS, with R1–R3 resolved in the supplied source/widget/capture scope. Final UI evidence is work/beta7/screenshots-verdict; R1/R2 closure also retains screenshots-approved evidence. ui-verdict.log has 8 passing tests. Search-chip/subtitle CJK QA font coverage is fixed in the final captures and is no longer an open product defect. Logs and fixtures overlap; do not add groups into a total. Exact deliverable files and hashes belong in the Beta.7 delivery manifest.

No Android device was connected. Hardware/system-volume synchronization, TalkBack speech/gestures, real IME transitions, GPU glass/motion, launcher/splash upgrade migration, live CDN playback/quality switching and live account/cloud operations remain unverified. Captures use synthetic local data, Windows QA fonts and Flutter software rendering.

Implementation entry points: the related_targets above; platform_recommendations.dart, platform_explore.dart, platform_recommendation_providers.dart for server provenance; beta_appearance.dart, app_theme.dart, theme_controller.dart, app_brand_style.dart and theme_gallery_page.dart for red/appearance migration; music_notice.dart for shared HUD. Use docs/MD3MUSIC_BETA.md for the integration handoff and historical supersession details.
