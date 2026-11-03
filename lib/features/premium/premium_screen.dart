import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/shared_widgets.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});
  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsProvider).log('premium_screen_viewed');
  }

  @override
  Widget build(BuildContext context) {
    final premium = ref.watch(premiumProvider);
    final entitled = ref.watch(settingsProvider).premiumEntitled;
    final product = premium.product as ProductDetails?;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      extendBodyBehindAppBar: true,
      body: ScreenContainer(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 100, 24, 32),
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                color: AppTheme.lavender,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flight,
                  size: 54, color: AppTheme.primaryText),
            ),
            const SizedBox(height: 20),
            Text(
                entitled
                    ? 'FlyCalm Premium is ready'
                    : 'Feel more prepared for your next flight.',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            const AppCard(
                padding: EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('✓ Guided support from boarding to arrival'),
                      SizedBox(height: 10),
                      Text('✓ Step-by-step help during turbulence'),
                      SizedBox(height: 10),
                      Text('✓ Six guided steps for anxious moments'),
                      SizedBox(height: 10),
                      Text('✓ Lifetime access — one payment'),
                    ])),
            const SizedBox(height: 10),
            const Text(
              'Your Premium guides stay available in airplane mode.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 20),
            if (!entitled) ...[
              if (premium.loading)
                const _DisabledPremiumButton(text: 'Loading Premium...')
              else if (product == null || !premium.storeAvailable)
                const _DisabledPremiumButton(text: 'Premium unavailable')
              else
                PrimaryButton(
                  onPressed: () async {
                    await ref
                        .read(analyticsProvider)
                        .log('premium_cta_clicked');
                    final started =
                        await ref.read(premiumProvider.notifier).buy();
                    if (!mounted) return;
                    if (!started) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Premium is currently unavailable. Please try again later.')));
                    }
                  },
                  text: 'Unlock Lifetime — ${product.price}',
                ),
              const SizedBox(height: 8),
              const Text('One-time purchase. No subscription.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  )),
              if (!premium.loading &&
                  (product == null || !premium.storeAvailable)) ...[
                const SizedBox(height: 8),
                const Text(
                  'Premium is currently unavailable. Please try again later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                ),
              ],
              TextButton(
                  onPressed: () => ref.read(premiumProvider.notifier).restore(),
                  child: const Text('Restore purchase')),
            ] else
              const Text('Your lifetime access is saved for offline use.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _DisabledPremiumButton extends StatelessWidget {
  const _DisabledPremiumButton({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: false,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppTheme.textMuted.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppTheme.textMuted.withValues(alpha: 0.35),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
