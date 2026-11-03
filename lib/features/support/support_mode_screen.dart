import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/shared_widgets.dart';

enum SupportMode { takeoff, panic, landing }

class SupportModeScreen extends ConsumerStatefulWidget {
  const SupportModeScreen({super.key, required this.mode});
  final SupportMode mode;

  @override
  ConsumerState<SupportModeScreen> createState() => _SupportModeScreenState();
}

class _SupportModeScreenState extends ConsumerState<SupportModeScreen> {
  Timer? _timer;
  int _seconds = 0;

  String get _event => widget.mode.name;

  @override
  void initState() {
    super.initState();
    ref.read(analyticsProvider).log('${_event}_mode_started');
    ref
        .read(analyticsProvider)
        .log('breathing_started', parameters: {'context': _event});
    _timer = Timer.periodic(const Duration(seconds: 1),
        (_) => mounted ? setState(() => _seconds++) : null);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  (String, String, List<String>) get _content => switch (widget.mode) {
        SupportMode.takeoff => (
            'Takeoff',
            'Let the seat support you. Keep your breath slow while the aircraft climbs.',
            [
              'Engine sound and acceleration usually increase.',
              'Pressure may hold you gently against the seat.',
              'The angle and engine sound change as the aircraft climbs.'
            ],
          ),
        SupportMode.panic => (
            "You're here. You're safe in this moment.",
            'Nothing needs to be solved all at once. Stay with one slow breath.',
            [
              'Name 5 things you can see.',
              'Notice 4 things you can feel.',
              'Listen for 3 sounds around you.'
            ],
          ),
        SupportMode.landing => (
            'Landing',
            'Feel your feet on the floor and let the exhale be a little longer.',
            [
              'Engine sound often changes during descent.',
              'You may hear the landing gear and flaps moving.',
              'A firm touch-down and braking sensations can be normal.'
            ],
          ),
      };

  Future<void> _finish() async {
    await ref.read(analyticsProvider).markExerciseCompleted('breathing');
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final content = _content;
    final phase = (_seconds % 10) < 4
        ? 'Breathe in slowly'
        : (_seconds % 10) < 5
            ? 'Pause gently'
            : 'Breathe out slowly';
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading:
              IconButton(icon: const Icon(Icons.close), onPressed: _finish)),
      extendBodyBehindAppBar: true,
      body: ScreenContainer(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 100, 24, 32),
          children: [
            Text(content.$1,
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 14),
            Text(content.$2,
                style: const TextStyle(color: AppTheme.textMuted, height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 36),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: .72, end: 1),
                duration: const Duration(seconds: 4),
                curve: Curves.easeInOut,
                onEnd: () => mounted ? setState(() {}) : null,
                builder: (_, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.softBlue.withValues(alpha: .18),
                        border:
                            Border.all(color: AppTheme.softBlue, width: 2))),
              ),
            ),
            const SizedBox(height: 24),
            Text(phase,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 36),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      widget.mode == SupportMode.panic
                          ? 'Ground yourself'
                          : 'What you may notice',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  for (final item in content.$3)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text('•  $item',
                            style: const TextStyle(
                                color: AppTheme.textMuted, height: 1.4))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(onPressed: _finish, text: 'I’m ready to continue'),
          ],
        ),
      ),
    );
  }
}
