import 'package:flutter/material.dart';

/// Paint the page surface inside the scrollable's overscroll composition pass.
/// A Scaffold behind that pass is not available to a glass backdrop sampler.
/// Keeping the backing surface here preserves both premium optics and stretch.
class BetaGlassScrollBody extends StatelessWidget {
  const BetaGlassScrollBody({
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(24, 30, 24, 32),
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, viewport) => ListView(
      padding: EdgeInsets.zero,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: viewport.maxHeight),
          child: ColoredBox(
            key: const ValueKey('glass-scroll-backing-surface'),
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
