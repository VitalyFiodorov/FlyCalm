import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../core/providers.dart';
import '../../data/services/flight_estimator.dart';
import '../../data/models/models.dart';

class FlightModeScreen extends ConsumerWidget {
  const FlightModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flightSession = ref.watch(flightSessionProvider);
    final estimatorStateAsync = ref.watch(flightEstimatorProvider);

    if (flightSession == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/home');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: ScreenContainer(
        child: estimatorStateAsync.when(
          data: (state) {
            if (state.currentPhase == FlightPhase.completed) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/arrival');
              });
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  Text(
                    "${flightSession.fromCity} → ${flightSession.toCity}",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: AppTheme.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  AppCard(
                    child: Column(
                      children: [
                        Text(
                          FlightEstimator.getPhaseTitle(state.currentPhase),
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          FlightEstimator.getPhaseSubtitle(state.currentPhase),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppTheme.textMuted),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        LayoutBuilder(builder: (context, constraints) {
                          return ProgressBar(progress: state.progressPercent);
                        }),
                        const SizedBox(height: 24),
                        Text(
                          FlightEstimator.formatRemainingTime(
                              state.remainingSeconds),
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(fontSize: 28),
                        ),
                        const SizedBox(height: 8),
                        const Text("Estimated time",
                            style: TextStyle(color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    onPressed: () => context.push('/calm'),
                    text: "Calm me",
                  ),
                  const SizedBox(height: 16),
                  SecondaryButton(
                    onPressed: () => context.push('/turbulence'),
                    text: "Turbulence mode",
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}
