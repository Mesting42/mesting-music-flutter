# Mesting Music Brand Design QA

## Evidence

- Source visual truth: `assets/branding/mesting-brand-selected-concept.png`
- Rendered light implementation: `assets/branding/mesting-brand-light-implementation.png`
- Rendered light/dark overview: `assets/branding/mesting-brand-implementation-preview.png`
- Full-view comparison: `assets/branding/mesting-design-qa-full.png`
- Focused icon comparison: `assets/branding/mesting-design-qa-icon.png`
- Focused splash comparison: `assets/branding/mesting-design-qa-splash.png`
- First comparison history: `assets/branding/mesting-design-qa-iteration-1.png`
- Source pixels: 1536 x 1024
- Implementation pixels: 1536 x 1024
- Comparison viewport: normalized 1536 x 1024 brand board at 1:1 density
- State: rounded-square launcher preview and light launch screen; the separate
  overview also verifies the dark launch-screen inversion.

The implementation is an Android-native icon and splash asset set rather than a
browser prototype. The rendered comparison uses the exact PNG resources and
solid color tokens consumed by the Android project.

## Findings

- No actionable P0, P1, or P2 mismatch remains.
- Fonts and typography: the `Mesting Music` wordmark is extracted from the
  selected visual target, preserves spelling and capitalization, and retains
  the selected rounded display weight. Its optical height is slightly cleaner
  after removal of the concept render's glow; this is an intentional production
  normalization.
- Spacing and layout rhythm: icon safe-zone padding, corner radius, mark scale,
  splash optical center, mark-to-wordmark spacing, and lockup width now match
  the normalized source comparison.
- Colors and visual tokens: the source render's soft gradient was intentionally
  replaced with solid `#D95046` coral and `#FFF8EC` cream to satisfy the selected
  production direction and Android adaptive/monochrome requirements. Dark
  launch mode uses `#17131B` with the same cream lockup.
- Image quality and asset fidelity: the visible mark and wordmark are extracted
  from the selected generated concept, not recreated as inline SVG, font glyph,
  Material icon, or placeholder. Edges are antialiased, transparent padding is
  clean, and focused comparisons show no chroma fringe.
- Copy and content: the only launch copy is exactly `Mesting Music`, matching
  the selected concept.

## Comparison History

1. First comparison found two P2 issues: the icon mark was oversized relative
   to the adaptive safe zone, and the launch mark was too small relative to the
   wordmark. Evidence is preserved in
   `assets/branding/mesting-design-qa-iteration-1.png`.
2. The generator was changed to extract the exact mark and lockup directly from
   the selected concept, normalize the icon mark to 61% of the canvas, and scale
   the splash lockup to the source's measured bounds.
3. The post-fix full and focused comparisons show matching silhouette, scale,
   spacing, wordmark content, and optical alignment. The remaining difference
   is the intentional removal of gradients and glow.

## Open Questions

- None blocking. OEM launcher masks and user-selected Android 13 themed-icon
  colors are platform-controlled, so their exact colors vary by device.

## Implementation Checklist

- Adaptive icon foreground and coral background configured for API 26+.
- Android 13 monochrome layer configured for API 33+.
- Legacy launcher PNGs generated for mdpi through xxxhdpi.
- Light and dark launch backgrounds configured for pre-Android 12 and API 31+.
- Brand asset generator retained under `tool/generate_brand_assets.py`.
- Android resource compilation and Flutter regression checks required before
  final handoff.

## Follow-up Polish

- P3: capture an OEM-specific themed-icon screenshot if a particular launcher
  family must be tuned beyond Android's standard adaptive safe zone.

final result: passed

---

# Search Loading and Result Spacing Design QA

## Evidence

- Source visual truth: the user-provided NetEase search loading screenshot and
  the Mesting search result screenshot from this task.
- Final loading render:
  `assets/design-qa/search-loading-final.png`
- Final result-spacing render:
  `assets/design-qa/search-results-spacing-final.png`
- Comparison viewport: 570 x 1250 at 1:1 density.

The rendered evidence uses the production `MusicSearchPage` widgets. The
software-rendered test environment does not include the app's Chinese font, so
glyphs appear as fallback boxes in the evidence image; widget geometry, colors,
animation surface, and spacing are production values.

## Findings

- The previous 280-pixel glass loading card, rotating ring, music-note icon, and
  three lines of copy were removed.
- Loading now uses four narrow, rounded equalizer bars with staggered wave
  phases and the single label `正在加载...`, matching the compact reference
  hierarchy while inheriting the active light, dark, or IP-theme accent.
- The equalizer is isolated in a repaint boundary and its controller is disposed
  with the widget.
- The nested result list previously inherited `MediaQuery` top padding. It now
  uses `EdgeInsets.zero`, eliminating the large blank band above the first
  result.
- A widget geometry regression test limits the title-to-first-artwork gap to
  less than 36 logical pixels.

## Verification

- Dart formatting: passed.
- `dart analyze`: passed with no issues.
- `flutter test test/music_search_ui_test.dart`: passed, including loading
  hierarchy, absence of stock progress indicators, list padding, and first-row
  spacing.
- No emulator was available during this pass; native Flutter software-rendered
  screenshots were used for focused visual QA.
- No APK was produced.

final result: passed

---

# Now Playing Turntable Design QA

## Evidence

- Paused source: `assets/design-qa/turntable-source-paused.png`
- Playing source: `assets/design-qa/turntable-source-playing.png`
- First emulator implementation:
  `assets/design-qa/turntable-comparison-iteration-1.png`
- State-specific emulator comparisons:
  `assets/design-qa/turntable-comparison-paused-iteration-2.png` and
  `assets/design-qa/turntable-comparison-playing-iteration-2.png`
- Final native Flutter render:
  `assets/design-qa/turntable-final-state-render.png`
- Final normalized comparison:
  `assets/design-qa/turntable-final-comparison.png`
- Comparison viewport: each state is normalized to 1080 x 2400.

The final render uses the same `VinylDiscSurface`, layout geometry, source cover,
transparent tonearm asset, and fixed-pivot rotations consumed by the production
player. The left state is paused and the right state is playing.

## Findings

- No actionable P0, P1, or P2 mismatch remains in the requested record and
  tonearm region.
- The record is centered at the measured source position, uses a 60% circular
  cover crop, a 2.5% outer rim, and 48 fine concentric grooves.
- The first tonearm asset had an oversized round pivot and a short cartridge.
  It was replaced with a transparent production asset extracted from the
  user-provided playing-state reference.
- Both states share one fixed pivot. The playing state uses 0 degrees and the
  paused state uses -22.5 degrees, animated over 520 ms.
- The normalized final comparison aligns the pivot, elbow, connector, and
  cartridge endpoints in both states. Remaining edge differences are limited
  to screenshot compression and antialiasing.
- The tonearm remains outside the rotating record subtree, so playback rotates
  only the vinyl and never the arm.

## Comparison History

1. Iteration 1 established the large record, 60% cover crop, grooves, and the
   first generated tonearm.
2. Iteration 2 corrected the record vertical position, outer rim, and fixed
   pivot motion, then measured paused and playing states separately.
3. Final iteration replaced the generated tonearm with the provided source
   silhouette, reduced the pivot head, extended the cartridge, and calibrated
   the paused rotation from the normalized endpoints.

## Verification

- Dart formatting: passed.
- `dart analyze`: passed with no issues.
- `flutter test test/vinyl_disc_test.dart`: passed, including animation gating,
  artwork geometry, tonearm rotation, responsive layout proportions, and asset
  bundle coverage.
- API 35 emulator screenshots were captured for the first two iterations.
  During the final pass the emulator host process became unstable after audio
  initialization, so the final pixel comparison uses Flutter's native
  software renderer with the exact production widgets and assets.
- No release APK was produced.

final result: passed
