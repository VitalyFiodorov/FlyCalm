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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
                children: [
                  Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: AppTheme.lavender,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.flight,
                          size: 38, color: AppTheme.primaryText),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    entitled
                        ? 'FlyCalm Premium is ready'
                        : 'Guided support for every stage of your flight.',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 28,
                          height: 1.15,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  const AppCard(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('✓ Guided Flight Journey — boarding to arrival'),
                        SizedBox(height: 8),
                        Text('✓ Advanced Turbulence — step-by-step support'),
                        SizedBox(height: 8),
                        Text('✓ Structured Panic Support — six calming steps'),
                        SizedBox(height: 8),
                        Text('✓ All Premium guides available offline'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your Premium guides stay available in airplane mode.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              decoration: BoxDecoration(
                color: AppTheme.cloudWhite.withValues(alpha: 0.94),
                border: const Border(
                  top: BorderSide(color: AppTheme.outline),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryText.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: !entitled
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (premium.loading)
                          const _DisabledPremiumButton(
                              text: 'Loading Premium...')
                        else if (product == null || !premium.storeAvailable)
                          const _DisabledPremiumButton(
                              text: 'Premium unavailable')
                        else
                          PrimaryButton(
                            onPressed: () async {
                              await ref
                                  .read(analyticsProvider)
                                  .log('premium_cta_clicked');
                              final started = await ref
                                  .read(premiumProvider.notifier)
                                  .buy();
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
                        const SizedBox(height: 6),
                        const Text(
                          'One-time purchase. No subscription.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (!premium.loading &&
                            (product == null || !premium.storeAvailable)) ...[
                          const SizedBox(height: 6),
                          const Text(
                            'Premium is currently unavailable. Please try again later.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppTheme.textMuted, fontSize: 14),
                          ),
                        ],
                        TextButton(
                          onPressed: () =>
                              ref.read(premiumProvider.notifier).restore(),
                          child: const Text('Restore purchase'),
                        ),
                      ],
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Your lifetime access is saved for offline use.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ),
            ),
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
