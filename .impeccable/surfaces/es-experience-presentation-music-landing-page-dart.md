---
version: 1
slug: "es-experience-presentation-music-landing-page-dart"
primary_target: "lib/features/experience/presentation/music_landing_page.dart"
related_targets: ["lib/features/experience/presentation/music_library_page.dart","lib/features/experience/presentation/cover_player_page.dart","lib/features/playlists/presentation/playlist_editor_dialog.dart"]
---

# Mesting Beta.5 music surfaces

Mode: Operate, with cover art leading the listening experience.

Approved visual authority: six Apple Music screenshots attached by the user; home, discovery, glass navigation, lyrics, playlist editor and month/year Replay. These are the accepted compositions. Keep Mesting naming and Chinese UI; do not import Apple claims, watermarks, services or unrelated features.

The physical scene is one-handed Android use during commuting and quiet evening listening. Keep the existing dress-up themes and system light/dark behavior. Restrained semantic neutrals plus the selected theme accent; album art supplies the broader color range. Chinese system text at 34px page title, 23px sections and 15–16px song rows, with accessible scaling.

Home combines top picks, recent listening, playlist discoveries and Replay. Discovery uses separate cover-led new music and grouped song recommendations. Library unifies favorites, playlists, recent listening and Replay for the active owner. Four destinations plus independent search and a floating playback capsule. Glass is reserved for floating chrome. Contents and account forms use opaque theme surfaces.

Default player is square cover plus transport, with switchable large synchronized lyrics over the blurred cover. Black vinyl and the existing alternate styles remain selectable. Short windows scroll; no transport action is removed.

Playlist editing is a rounded sheet with cover templates/gallery, name, description, cancel and confirm. Store a normalized 640px PNG, upload a selected cover through the embedded upstream endpoint, then update cloud metadata. Cloud failure retains drafts. Never retry a cloud mutation automatically or write across an account change.

Replay uses real daily listening records for the active owner; no reconstructed historical months. Tests use explicitly synthetic local fixtures and rendered Flutter widgets, not a physical Android device. Final delivery must identify device/cloud verification still needed.

Implementation targets: lib/features/experience/presentation, platform_design.dart, platform_profile.dart, platform_library_page.dart, playlist_editor_dialog.dart, music_navigation.dart and music_shell.dart. Preserve business capabilities, comments, search pagination and account isolation from Beta.4.
