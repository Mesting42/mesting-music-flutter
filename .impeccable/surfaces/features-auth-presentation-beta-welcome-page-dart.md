---
version: 1
slug: "features-auth-presentation-beta-welcome-page-dart"
primary_target: "lib/features/auth/presentation/beta_welcome_page.dart"
related_targets: ["lib/features/auth/beta_entry_flow.dart","lib/features/auth/presentation/beta_entry_coordinator.dart","lib/features/auth/presentation/beta_onboarding_page.dart","lib/features/auth/presentation/beta_player_style_previews.dart","lib/features/auth/presentation/mesting_music_companions.dart","lib/features/auth/presentation/beta_sign_out_dialog.dart","lib/features/auth/presentation/auth_page.dart","lib/features/settings/presentation/settings_page.dart","lib/shared/widgets/beta_glass_controls.dart","lib/shared/widgets/beta_success_feedback.dart"]
---

# Mesting Music Beta.10 welcome and guide

Mode: Operate. Audience: first-time Android listeners and returning listeners making a new explicit login. Job: choose a real account or guest, understand the connected controls, and enter the existing music experience. A restored credential/token refresh is not a new interactive login. The new surface extends the inherited Mesting world; it does not replace the formal-channel identity.

## Direction and provenance

The supplied welcome/guide layouts, the user's coral original vector note-and-record duo selection and the subsequently confirmed full Beta.10 written plan are the actual authority. No independently approved ImageGen comp, approval sidecar or random FORM seed exists. The truthful source contract names this user-specified native reference composition; historical “待确认” in the saved plan filename does not revoke its later confirmation.

Memorable moment: two articulated musical companions greet each other and respond to a tap. The welcome first viewport puts duo and brand above generous space, then phone/WeChat actions, guest/other methods and agreement/privacy below. Warm light/dark entrance backgrounds support readable silhouettes; this composition is not a global page template. Welcome is centered within 500dp; guide within 600dp, with safe areas and scrollable content at short/large-text sizes.

## Tasks, content and constraints

Phone and WeChat open genuine platform flows; other methods retain Kugou/QQ QR and Mesting login/register. Guest proceeds directly to music. Every fresh interactive login runs one success card, its exit, then eight guide pages. The coordinator sits above routing so credential publication cannot remove that presentation. Skip/Finish saves completion; Settings can replay. Successful logout returns to welcome, while pending logout deduplicates/disables and failure keeps the session with an actionable error.

Guide content describes actual discovery/search, player/lyrics, gray handle and comments/quality/queue/More, account-appropriate recommendations/favorites, deliberate queue/continuation/history, appearance/background/progress, five player styles and start/replay. It does not claim unimplemented desktop lyrics/Zen/AI. The five individually selectable dynamic mini-stages use one local repaint clock and the same persistent player style as Dress Up/More; appearance modes use the existing theme preference. Local scene taps demonstrate reversible state without playback/cloud writes or a new audio owner. Adjacent pages pause through TickerMode. Previous/Next/swipe retain directional page motion, Skip remains available and system Back moves to the prior guide page or finishes from the first.

Specified welcome/account/code/logout/Back controls share independent premium glass; each field/button owns its own layer. Reading backgrounds remain stable. The original duo, shared success mark and segmented spinner are authored/reused components, not bitmap substitutes for live glass. Formal calls keep their established presentation.

## Evidence and unresolved acceptance

This is source-grounded documentation of the verified Beta.10 implementation. Initial `review-first.md` was **fix**; after final recapture, `review-final.md` is **ship**, R1–R8 resolved. `captures-first`/entry-contact/guide-contact remain defect-bearing historical images. Final normal regression is **635 passed / 54 conditional skips / 0 failures**, Beta targeted **150 passed / 0 skipped / 0 failed**, software UI **34 passed / 0 failed**, and analyze **No issues found**. These and earlier 27/7/16 groups overlap and must not be summed. Release identity/signature/16KiB/ARM comparison are verified for Mesting Music / com.mesting.music.beta / 1.0.37-beta.10 / 10. Motion export's additional 4 checks produce welcome/style light/dark GIFs of 36 frames at 80ms per frame; these demonstrate software fixtures, not native FPS. Exact APK identity/hash and run evidence are in docs/MD3MUSIC_BETA.md; source archive bytes/hash are owned by the external `outputs/beta-1.0.37-beta.10/delivery-manifest.json` generated after final documentation freeze. Native GPU optics/FPS, real IME/TalkBack/hardware Back/volume, cold/upgrade entry, all live login/QR/refresh/logout paths and cloud/CDN permissions remain unverified; no Android device is attached.
