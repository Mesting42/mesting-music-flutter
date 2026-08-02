import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/liquid_glass_sheet.dart';
import '../../themes/music_theme_tokens.dart';
import '../auth_providers.dart';

Future<bool> ensureAuthenticated(
  BuildContext context,
  WidgetRef ref, {
  required String reason,
  String redirect = '/music',
}) async {
  var session = ref.read(authControllerProvider).value;
  if (ref.read(authControllerProvider).isLoading) {
    try {
      session = await ref.read(authControllerProvider.future);
    } on Object {
      session = null;
    }
  }
  if (session != null) return true;
  if (!context.mounted) return false;

  final accepted = await showLiquidGlassBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) => _AuthRequiredSheet(reason: reason),
  );
  if (accepted != true || !context.mounted) return false;

  final uri = Uri(
    path: '/auth',
    queryParameters: {'mode': 'register', 'redirect': redirect},
  );
  return await context.push<bool>(uri.toString()) == true;
}

class _AuthRequiredSheet extends StatelessWidget {
  const _AuthRequiredSheet({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final tokens = context.musicThemeTokens;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: tokens.glassStrong,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: tokens.border),
          boxShadow: [
            BoxShadow(
              color: tokens.shadow,
              blurRadius: 35,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D2D8),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5268D7), Color(0xFF3F9FB0)],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x555268D7),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 31,
              ),
            ),
            const SizedBox(height: 17),
            const Text(
              '登录后继续',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 7),
            Text(
              reason,
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.55,
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 21),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF465CC7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '去登录 / 注册',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('暂时不用'),
            ),
          ],
        ),
      ),
    );
  }
}
