import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/distribution_channel.dart';
import '../../auth/presentation/auth_gate.dart';

/// Beta guests can own device-only collections. This permission applies only
/// to library operations; social, profile and CloudBase actions stay protected.
Future<bool> ensureLibraryAccess(
  BuildContext context,
  WidgetRef ref, {
  required String reason,
  required String redirect,
}) {
  if (DistributionChannel.isBeta) return Future.value(true);
  return ensureAuthenticated(context, ref, reason: reason, redirect: redirect);
}
