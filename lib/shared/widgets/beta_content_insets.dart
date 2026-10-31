import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// A glass overlay reserves space inside the scroll content, rather than
/// adding an opaque empty box outside it. The page surface still paints behind
/// the glass while its last control can scroll fully above the accessory.
class BetaContentInsets extends InheritedWidget {
  const BetaContentInsets({
    required this.bottom,
    required super.child,
    super.key,
  });
  final double bottom;
  static double bottomOf(BuildContext context, [double minimum = 0]) =>
      math.max(
        minimum,
        context
                .dependOnInheritedWidgetOfExactType<BetaContentInsets>()
                ?.bottom ??
            0,
      );
  @override
  bool updateShouldNotify(BetaContentInsets oldWidget) =>
      bottom != oldWidget.bottom;
}
