import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../core/providers.dart';

class ArrivalCompleteScreen extends ConsumerWidget {
  const ArrivalCompleteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ScreenContainer(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 100,
                color: AppTheme.softBlue,
              ),
              const SizedBox(height: 48),
              Text(
                "You’ve arrived",
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Your flight has ended. We hope FlyCalm helped make your journey more comfortable.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              PrimaryButton(
                onPressed: () {
                  ref.read(flightSessionProvider.notifier).clearFlight();
                  context.go('/home');
                },
                text: "Start a new flight",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
