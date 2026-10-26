import 'package:flutter/material.dart';
import '../../../shared/widgets/beta_edge_back.dart';
import '../../../shared/widgets/overflow_marquee.dart';
import '../../../shared/widgets/mesting_loading_indicator.dart';
import '../../../shared/widgets/beta_glass_controls.dart';
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
    const shape = StadiumBorder();
    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerLow,
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
            backgroundColor: theme.colorScheme.surfaceContainerLow,
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
          backgroundColor: theme.colorScheme.surfaceContainerLow,
          selectedColor: theme.brightness == Brightness.dark
              ? theme.colorScheme.primary.withValues(alpha: .16)
              : theme.colorScheme.onSurface.withValues(alpha: .1),
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
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
    ),
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
    child: BetaEdgeBack(
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
                    BetaGlassBackButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OverflowMarquee(
                            title,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: context.musicThemeTokens.textPrimary,
                              letterSpacing: -.5,
                            ),
                          ),
                          if (subtitle.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.musicThemeTokens.textSecondary,
                                ),
                              ),
                            ),
                        ],
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
