import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/distribution_channel.dart';
import '../../auth/presentation/auth_gate.dart';
import '../../auth/beta_account_choice.dart';
import '../../auth/auth_providers.dart';
import '../../music_platform/music_platform_providers.dart';

/// Beta guests can own device-only collections. This permission applies only
/// to library operations; social, profile and CloudBase actions stay protected.
Future<bool> ensureLibraryAccess(
  BuildContext context,
  WidgetRef ref, {
  required String reason,
  required String redirect,
}) async {
  if (DistributionChannel.isBeta) {
    try {
      // Never write guest data while an existing platform login is restoring.
      await ref.read(platformAccountProvider.future);
      if (ref.read(betaAccountChoiceProvider) == BetaAccountChoice.mesting) {
        await ref.read(authControllerProvider.future);
      }
      return true;
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('当前账号曲库尚未就绪，请重试')));
      }
      return false;
    }
  }
  return ensureAuthenticated(context, ref, reason: reason, redirect: redirect);
}
