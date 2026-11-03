import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/shared_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextFlight = ref.watch(nextFlightProvider);
    final premium = ref.watch(settingsProvider).premiumEntitled;
    return Scaffold(
      body: ScreenContainer(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('FlyCalm', style: Theme.of(context).textTheme.titleLarge),
              Row(children: [
                if (!premium)
                  IconButton(
                      icon: const Icon(Icons.workspace_premium,
                          color: AppTheme.softBlue),
                      onPressed: () => context.push('/premium')),
                IconButton(
                    icon: const Icon(Icons.settings, color: AppTheme.textMuted),
                    onPressed: () => context.push('/settings')),
              ]),
            ]),
            const SizedBox(height: 28),
            Text(nextFlight?.countdownLabel(DateTime.now()) ?? 'Your flight',
                style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 10),
            Text(
                nextFlight?.preparationStage(DateTime.now()) ??
                    'Add your next flight to get a simple preparation plan.',
                style: const TextStyle(color: AppTheme.textMuted, height: 1.4)),
            const SizedBox(height: 20),
            SecondaryButton(
                onPressed: () => context.push('/next_flight'),
                text: nextFlight == null
                    ? 'Add next flight'
                    : 'Edit next flight'),
            const SizedBox(height: 32),
            _PanicButton(onPressed: () => context.push('/panic')),
            const SizedBox(height: 32),
            Text('What do you need right now?',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              // Leave enough vertical room for two-line labels at larger
              // Android accessibility font sizes.
              childAspectRatio: MediaQuery.textScalerOf(context).scale(1) > 1.15
                  ? 0.82
                  : 0.95,
              children: [
                _ModeCard(
                    icon: Icons.flight_takeoff,
                    title: 'Takeoff',
                    subtitle: 'Breathe through the climb',
                    onTap: () => context.push('/takeoff')),
                _ModeCard(
                    icon: Icons.air,
                    title: 'Turbulence',
                    subtitle: 'Ground and understand',
                    onTap: () async {
                      await ref
                          .read(analyticsProvider)
                          .log('turbulence_mode_started');
                      if (context.mounted) context.push('/turbulence');
                    }),
                _ModeCard(
                    icon: Icons.self_improvement,
                    title: 'Breathing',
                    subtitle: 'Slow the moment down',
                    onTap: () async {
                      await ref.read(analyticsProvider).log('breathing_started',
                          parameters: {'context': 'home'});
                      if (context.mounted) context.push('/calm');
                    }),
                _ModeCard(
                    icon: Icons.flight_land,
                    title: 'Landing',
                    subtitle: 'Prepare for sensations',
                    onTap: () => context.push('/landing')),
              ],
            ),
            if (nextFlight != null) ...[
              const SizedBox(height: 28),
              PrimaryButton(
                  onPressed: () async {
                    await ref
                        .read(analyticsProvider)
                        .log('flight_preparation_opened', parameters: {
                      'days_until_flight': nextFlight.daysUntil(DateTime.now())
                    });
                    if (context.mounted) context.push('/takeoff');
                  },
                  text: 'Open my preparation plan'),
            ],
            const SizedBox(height: 32),
            Text('Guided journeys',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Step-by-step Premium support for specific moments in flight.',
              style: TextStyle(color: AppTheme.textMuted, height: 1.4),
            ),
            const SizedBox(height: 16),
            _PremiumJourneyCard(
              key: const Key('guided_flight_journey_card'),
              icon: Icons.flight,
              title: 'Guided Flight Journey',
              subtitle: 'From boarding to arrival',
              locked: !premium,
              onTap: () => context.push('/premium/guided-flight'),
            ),
            const SizedBox(height: 12),
            _PremiumJourneyCard(
              key: const Key('advanced_turbulence_card'),
              icon: Icons.air,
              title: 'Advanced Turbulence Session',
              subtitle: 'Structured support for bumpy air',
              locked: !premium,
              onTap: () => context.push('/premium/advanced-turbulence'),
            ),
            const SizedBox(height: 12),
            _PremiumJourneyCard(
              key: const Key('structured_panic_card'),
              icon: Icons.favorite_outline,
              title: 'Structured Panic Session',
              subtitle: 'Six guided steps when anxiety rises',
              locked: !premium,
              onTap: () => context.push('/premium/structured-panic'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanicButton extends StatelessWidget {
  const _PanicButton({required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Open panic support',
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.lavender, AppTheme.softPurple],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.softPurple),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.softPurple.withValues(alpha: .24),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]),
            child: const Row(children: [
              Icon(Icons.favorite, color: AppTheme.primaryText, size: 40),
              SizedBox(width: 18),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('PANIC? TAP HERE',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 19)),
                    SizedBox(height: 5),
                    Text('Start breathing immediately',
                        style: TextStyle(color: AppTheme.secondaryText))
                  ])),
              Icon(Icons.arrow_forward, color: AppTheme.primaryText),
            ]),
          ),
        ),
      );
}

class _ModeCard extends StatelessWidget {
  const _ModeCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppTheme.softBlue, size: 30),
                const SizedBox(height: 12),
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 5),
                Text(subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
              ]),
        ),
      );
}

class _PremiumJourneyCard extends StatelessWidget {
  const _PremiumJourneyCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.locked,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AppCard(
          child: Row(
            children: [
              Icon(icon, color: AppTheme.softBlue, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                locked ? Icons.lock_outline : Icons.arrow_forward,
                color: locked ? AppTheme.textMuted : AppTheme.softBlue,
                size: 21,
              ),
            ],
          ),
        ),
      );
}
