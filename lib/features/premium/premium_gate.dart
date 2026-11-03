import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'premium_screen.dart';

/// Central access boundary for content included in FlyCalm Premium.
///
/// The locally persisted entitlement is intentionally the only check so an
/// existing purchase continues to work without connectivity.
class PremiumGate extends ConsumerWidget {
  const PremiumGate({
    super.key,
    required this.child,
    this.lockedBuilder,
  });

  final Widget child;
  final WidgetBuilder? lockedBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitled = ref.watch(settingsProvider).premiumEntitled;
    if (entitled) return child;
    return lockedBuilder?.call(context) ?? const PremiumScreen();
  }
}
