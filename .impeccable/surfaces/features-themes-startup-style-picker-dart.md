---
version: 1
slug: "features-themes-startup-style-picker-dart"
primary_target: "lib/features/themes/startup_style_picker.dart"
related_targets: ["lib/features/themes/startup_style.dart","lib/app/startup_video_surface.dart","lib/main.dart","lib/features/themes/theme_gallery_page.dart","lib/features/experience/presentation/beta_music_shell.dart","lib/features/experience/presentation/beta_search_back_history.dart","lib/features/experience/presentation/player_dismiss_motion.dart","lib/features/experience/presentation/player_pull_to_dismiss.dart","lib/app/router/app_router.dart","lib/shared/widgets/beta_glass_action.dart","lib/features/experience/presentation/beta_bottom_bar.dart","lib/features/playlists/presentation/playlist_editor_dialog.dart","lib/features/queue/presentation/queue_track_duration.dart","lib/features/music_platform/data/platform_track_duration_repository.dart"]
---

# Mesting Music Beta.12 startup and optical continuity

Mode: Operate within the existing Mesting/Apple Music world. The user's confirmed
Beta.12 plan owns scope. The supplied two short films are the actual startup
artifacts, not visual references to redraw. First film is default; second film
and the coral/white classic lockup remain selectable in 装扮 → 启动页. Static
posters, a selected mark and explicit preview make the choice visible without
autoplay while browsing. System Chinese type, existing Beta red, neutral settings
surfaces and the existing premium glass language remain visual authority.

The films retain their original soundtrack and proportions. Bundled compatible
copies do not replace or modify the user's originals. One bootstrap-owned gate
per cold process waits for both dependencies and the film before mounting the
business app and account/music restoration. Background pauses an unfinished
film; resume continues it and never replays a completed one. Bounded initialize
or stall failure falls back to the classic lockup; dependency retry does not
replay the film. Explicit preview owns a separate controller and disposes it on
close. Startup choice is independent of launcher icon aliases, theme, background
video and player visual style; a selection mark changes only after persistence.

Optical continuity is a functional requirement: collapsed and expanded bottom
controls retain full material during scrolling. Validate plain/content backdrop,
light/dark, settled/morph states and phone/wide layouts together. Remove only the
dark uniform synthetic perimeter; keep directional glints, meniscus, refraction,
press feedback and paired animations. Application adaptive quality is disabled;
the local MIT 1.15.0 fork suppresses only dark constant/minimum perimeter terms
in the fallback shader, while the premium path remains. Blue actions share clear
body alpha tint over scrolling light content; new/edit playlist saving uses the
same optics, and close is neutral glass. Material owns optics/feedback while the
page owns saving, validation and Back guards. Android GPU behavior is distinct
from host software captures; light compact glass on plain/content backgrounds
and every native render branch still require device evidence.

Embedded search has real local back history for results → landing → origin, with
all five categories and existing search session boundaries. The grey player
handle drives its route's own animation, completes only the remaining exit and
rebounds on cancellation. Queue rows show positive recording duration or --:--,
hydrate visible unknown rows with coalesced read-only metadata (two concurrent),
and discard stale account responses. No unrelated feature redesign is included.

Current evidence: work/beta12/captures-final/existing and ui-final.log (47 passed,
overlapping groups), production-router and startup lifecycle tests, final
test-summary.json/analyze-approved.log, media-verification.json and the verified
release packet. The paired normal-blue captures remain saturated in the software
renderer. The genuine embedded-host search and three /audio metadata responses
prove only matching read-only identities and duration units. No Android device
was attached: native GPU/FPS, system edge Back, media focus/volume, actual decoder
lifecycle and TalkBack remain unverified. Source archive identity is owned by the
external manifest after documentation freeze.

No ImageGen comp, new typography/world, random FORM seed or QUALITY BAR card was
created for this refinement. The plan's historical 待确认 filename does not undo
the user's subsequent explicit confirmation recorded in implementation-status.md.
Historical Beta.11 test/release results remain historical, not Beta.12 evidence.
