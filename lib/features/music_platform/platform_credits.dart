import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Keeps upstream authorship and the complete license available offline in the
/// APK. Corresponding server sources and build scripts live in third_party.
class PlatformCredits {
  PlatformCredits._();
  static bool _registered = false;

  static void register() {
    if (_registered) return;
    _registered = true;
    LicenseRegistry.addLicense(() async* {
      final license = await rootBundle.loadString(
        'third_party/md3music/LICENSE',
      );
      final notice = await rootBundle.loadString(
        'third_party/md3music/NOTICE.md',
      );
      yield LicenseEntryWithLineBreaks([
        'md3Music · zzyoxml and contributors',
      ], '$notice\n\n$license');
      final glassLicense = await rootBundle.loadString(
        'third_party/liquid_glass_widgets/LICENSE',
      );
      final glassNotice = await rootBundle.loadString(
        'third_party/liquid_glass_widgets/NOTICE.md',
      );
      yield LicenseEntryWithLineBreaks([
        'Liquid Glass Widgets Apple Music example · Sebastian Degenaar',
      ], '$glassNotice\n\n$glassLicense');
    });
  }
}
