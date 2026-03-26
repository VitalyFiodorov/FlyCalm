import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../core/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flightSession = ref.watch(flightSessionProvider);

    return Scaffold(
      body: ScreenContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("FlyCalm", style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.settings, color: AppTheme.textMuted),
                    onPressed: () => context.push('/settings'),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Text(
                flightSession == null ? "Your flight" : "Ready to fly",
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 16),
              Text(
                flightSession == null ? "Add your flight to begin" : "${flightSession.fromCity} to ${flightSession.toCity}",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 48),
              if (flightSession == null)
                PrimaryButton(
                  onPressed: () => context.push('/add_flight'),
                  text: "Add flight",
                )
              else
                Column(
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Active Flight", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.softBlue)),
                              const Icon(Icons.flight_takeoff, color: AppTheme.softBlue),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text("${flightSession.fromCity} ➔ ${flightSession.toCity}", style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(
                            "Departs: ${flightSession.departureTime.hour}:${flightSession.departureTime.minute.toString().padLeft(2, '0')}",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      onPressed: () => context.push('/flight_mode'),
                      text: "Resume flight",
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
