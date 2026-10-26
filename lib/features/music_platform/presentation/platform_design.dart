import 'package:flutter/material.dart';
import '../../../shared/widgets/liquid_glass_sheet.dart';
import '../../../shared/widgets/mesting_loading_indicator.dart';
import '../../player/presentation/music_hub_top_bar.dart';
import '../../themes/music_theme_tokens.dart';

/// Shared visual adapter for all imported platform surfaces. Business widgets
/// keep their own repositories; the adapter only reuses Mesting theme tokens.
class PlatformStyle extends StatelessWidget {
  const PlatformStyle({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.musicThemeTokens;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    );
    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          filled: true,
          fillColor: tokens.glass,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: tokens.borderStrong),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: tokens.borderStrong),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, 48),
            shape: shape,
            textStyle: theme.textTheme.labelLarge?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, 48),
            shape: shape,
            side: BorderSide(color: tokens.borderStrong),
            backgroundColor: tokens.glass,
            foregroundColor: tokens.textPrimary,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            minimumSize: const Size(44, 44),
            shape: shape,
            textStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        chipTheme: theme.chipTheme.copyWith(
          backgroundColor: tokens.glass,
          selectedColor: theme.colorScheme.primary.withValues(alpha: .16),
          side: BorderSide.none,
          shape: const StadiumBorder(),
          labelStyle: theme.textTheme.labelLarge?.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        popupMenuTheme: theme.popupMenuTheme.copyWith(
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        dialogTheme: theme.dialogTheme.copyWith(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      child: child,
    );
  }
}

class PlatformPanel extends StatelessWidget {
  const PlatformPanel({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    super.key,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => LiquidGlassSurface(
    borderRadius: BorderRadius.circular(26),
    child: Padding(padding: padding, child: child),
  );
}

class PlatformPageFrame extends StatelessWidget {
  const PlatformPageFrame({
    required this.title,
    required this.child,
    this.subtitle = '',
    this.actions = const [],
    this.pageKey,
    super.key,
  });
  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget> actions;
  final Key? pageKey;
  @override
  Widget build(BuildContext context) => PlatformStyle(
    child: Scaffold(
      key: pageKey,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: MusicHubTopBar(
                      title: title,
                      subtitle: subtitle,
                      showBack: true,
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  ...actions,
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    ),
  );
}

class PlatformSectionTitle extends StatelessWidget {
  const PlatformSectionTitle(this.title, {this.subtitle, super.key});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: context.musicThemeTokens.textPrimary,
            letterSpacing: -.4,
          ),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              subtitle!,
              style: TextStyle(
                color: context.musicThemeTokens.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
      ],
    ),
  );
}

class PlatformFeedbackState extends StatelessWidget {
  const PlatformFeedbackState({
    this.loading = false,
    this.message = '',
    this.retry,
    super.key,
  });
  final bool loading;
  final String message;
  final VoidCallback? retry;
  @override
  Widget build(BuildContext context) => PlatformPanel(
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading)
            const MestingLoadingIndicator(semanticLabel: '正在加载音乐内容')
          else ...[
            Icon(
              Icons.music_note_rounded,
              color: context.musicThemeTokens.textMuted,
              size: 30,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (retry != null)
              TextButton.icon(
                onPressed: retry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('重新加载'),
              ),
          ],
        ],
      ),
    ),
  );
}
