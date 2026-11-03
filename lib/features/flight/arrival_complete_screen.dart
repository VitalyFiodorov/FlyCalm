import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/shared_widgets.dart';

class ArrivalCompleteScreen extends ConsumerStatefulWidget {
  const ArrivalCompleteScreen({super.key});
  @override
  ConsumerState<ArrivalCompleteScreen> createState() =>
      _ArrivalCompleteScreenState();
}

class _ArrivalCompleteScreenState extends ConsumerState<ArrivalCompleteScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsProvider).log('flight_completed');
  }

  Future<void> _finish() async {
    await ref.read(flightSessionProvider.notifier).clearFlight();
    final analytics = ref.read(analyticsProvider);
    if (analytics.completedExercises >= 3) {
      final review = InAppReview.instance;
      if (await review.isAvailable()) await review.requestReview();
    }
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ScreenContainer(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 100, color: AppTheme.softBlue),
                  const SizedBox(height: 48),
                  Text('You did it ✈️',
                      style: Theme.of(context).textTheme.displayLarge,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Text('Another flight completed.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: AppTheme.textMuted),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 60),
                  PrimaryButton(onPressed: _finish, text: 'Back to my plan'),
                ]),
          ),
        ),
      );
}
