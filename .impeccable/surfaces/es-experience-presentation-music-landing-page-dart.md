---
version: 1
slug: "es-experience-presentation-music-landing-page-dart"
primary_target: "lib/features/experience/presentation/music_landing_page.dart"
related_targets: ["lib/features/experience/presentation/music_library_page.dart","lib/features/experience/presentation/cover_player_page.dart","lib/features/playlists/presentation/playlist_editor_dialog.dart"]
---

# Mesting Beta.6 music surfaces

Mode: Operate, with cover art leading the listening experience.

Approved visual authority: six Apple Music screenshots attached by the user; home, discovery, glass navigation, lyrics, playlist editor and month/year Replay. These are the accepted compositions. Keep Mesting naming and Chinese UI; do not import Apple claims, watermarks, services or unrelated features.

Beta.6 floating chrome uses the actual liquid_glass_widgets official Apple Music example composition: GlassScaffold, GlassTabBar.searchable and GlassButton.custom, with package-owned press/drag springs and accessory morphing. Runtime stays pinned to 1.15.0; the source snapshot is in third_party/liquid_glass_widgets/. Preserve Mesting routes, Chinese search, queue and audio contracts.

The physical scene is one-handed Android use during commuting and quiet evening listening. Beta.6 keeps classic light/dark/system modes and independently selected progress styles/characters, while retiring the full Shin-chan, Hello Kitty and Kuromi themes. Old themes migrate to classic; old followTheme progress choices become explicit original-character choices. Background strength is .58 and performance automatic; retain the IP-decoration switch. Formal flavor theme behavior is unchanged. Restrained semantic neutrals plus the selected theme accent; album art supplies the broader color range. Chinese system text at 34px page title, 23px sections and 15–16px song rows, with accessible scaling.

Home combines top picks, recent listening, playlist discoveries and Replay. Discovery uses separate cover-led new music and grouped song recommendations. Library unifies favorites, playlists, recent listening and Replay for the active owner. Four destinations plus independent search and a floating playback capsule. Glass is reserved for floating chrome. Contents and account forms use opaque theme surfaces.

Phone and wide Beta windows share one bottom navigation; remove the previous expanded rail and its 88dp spacer, while retaining the adaptive content caps. The official bar owns safe area and keyboard lift; only search results receive shell keyboard clearance. A transparent Material supplies normal bar text defaults. Scrolling past 50dp compacts the accessory inline, and tapping the current destination returns to the top. Use official premium/full chrome optics (blur 2, thickness 30, lightIntensity .2; play pill .18), separately from the older MestingGlass standard surface settings.

Default player is square cover plus transport, with switchable large synchronized lyrics over the blurred cover. Black vinyl and the existing alternate styles remain selectable. Short windows scroll; no transport action is removed.

All five player appearances expose standard/high/lossless/Hi-Res quality through one persisted preference and the existing audio handler. Replacing the current source preserves position, playing/paused state, logical queue and mode, and rejects stale commands. Show the delivered tier separately from the preference; unknown responses remain unknown, and permitted trials/downgrades are disclosed. Platform artwork parsing and read-only metadata recovery serve recommendation/search/playlist/player covers, coalesce requests, limit concurrency to 3 and cache 256 successes without permanently caching failures.

Playlist editing is a rounded sheet with cover templates/gallery, name, description, cancel and confirm. Store a normalized 640px PNG, upload a selected cover through the embedded upstream endpoint, then update cloud metadata. Cloud failure retains drafts. Never retry a cloud mutation automatically or write across an account change.

Replay uses real daily listening records for the active owner; no reconstructed historical months. Tests use explicitly synthetic local fixtures and rendered Flutter widgets, not a physical Android device. Final delivery must identify device/cloud verification still needed.

Implementation targets: lib/features/experience/presentation (including beta_music_shell.dart and beta_bottom_bar.dart), platform_design.dart, platform_profile.dart, platform_library_page.dart, playlist_editor_dialog.dart, platform_artwork.dart, platform_audio_quality.dart, platform_quality_providers.dart, music_navigation.dart and music_shell.dart. Preserve business capabilities, comments, search pagination and account isolation from Beta.4. Beta.6 independent review is ship; keyboard lift, bar text inheritance and duplicate wide navigation findings are resolved. The approved UI evidence is synthetic and does not certify a physical device, GPU, CDN, live quality switch or cloud writes.
