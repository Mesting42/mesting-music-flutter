import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Local animation signal: dragging the player never rebuilds the routed page
/// or all of its glass surfaces. Only the persistent chrome listens to it.
final playerChromeRevealProvider = Provider<ValueNotifier<double>>((ref) {
  final reveal = ValueNotifier(0.0);
  ref.onDispose(reveal.dispose);
  return reveal;
});
