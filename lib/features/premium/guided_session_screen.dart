import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/audio_service.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'guided_session.dart';

class GuidedSessionScreen extends ConsumerStatefulWidget {
  const GuidedSessionScreen({super.key, required this.session});

  final GuidedSession session;

  @override
  ConsumerState<GuidedSessionScreen> createState() =>
      _GuidedSessionScreenState();
}

class _GuidedSessionScreenState extends ConsumerState<GuidedSessionScreen> {
  int _stepIndex = 0;
  late final AudioService _audioService;

  String get _progressKey => 'premium_session_progress_${widget.session.id}';

  @override
  void initState() {
    super.initState();
    _audioService = ref.read(audioServiceProvider);
    final saved = ref.read(sharedPreferencesProvider).getInt(_progressKey) ?? 0;
    _stepIndex = saved.clamp(0, widget.session.steps.length - 1);
  }

  @override
  void dispose() {
    _audioService.stop();
    super.dispose();
  }

  Future<void> _setStep(int index) async {
    await _audioService.stop();
    if (!mounted) return;
    setState(() => _stepIndex = index);
    await ref.read(sharedPreferencesProvider).setInt(_progressKey, index);
  }

  Future<void> _restart() async {
    await ref.read(sharedPreferencesProvider).remove(_progressKey);
    await _setStep(0);
  }

  Future<void> _finish() async {
    await ref.read(sharedPreferencesProvider).remove(_progressKey);
    await _audioService.stop();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.session.steps[_stepIndex];
    final isLast = _stepIndex == widget.session.steps.length - 1;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Exit session',
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.session.headerTitle,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
        ),
        actions: [
          IconButton(
            tooltip: 'Restart session',
            icon: const Icon(Icons.refresh),
            onPressed: _restart,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: ScreenContainer(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 76, 24, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step ${_stepIndex + 1} of ${widget.session.steps.length}',
                        style: const TextStyle(color: AppTheme.textMuted),
                      ),
                      Text(
                        '${(((_stepIndex + 1) / widget.session.steps.length) * 100).round()}%',
                        style: const TextStyle(color: AppTheme.softBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: (_stepIndex + 1) / widget.session.steps.length,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                    backgroundColor: AppTheme.cardBg,
                    color: AppTheme.softBlue,
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: ListView(
                  key: ValueKey(_stepIndex),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                  children: [
                    _StepIcon(type: step.type),
                    const SizedBox(height: 20),
                    Text(
                      step.title,
                      style: Theme.of(context).textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      step.body,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 17,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (step.type == SessionStepType.breathing) ...[
                      const SizedBox(height: 28),
                      const _BreathingGuide(),
                    ],
                    if (step.points.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final point in step.points)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  '•  $point',
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    if (step.type == SessionStepType.audio &&
                        step.audioAssetPath != null) ...[
                      const SizedBox(height: 28),
                      _AudioControls(step: step),
                    ],
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  children: [
                    if (_stepIndex > 0) ...[
                      IconButton.outlined(
                        tooltip: 'Previous step',
                        onPressed: () => _setStep(_stepIndex - 1),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: PrimaryButton(
                        onPressed:
                            isLast ? _finish : () => _setStep(_stepIndex + 1),
                        text: isLast ? 'Finish session' : 'Continue',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.type});
  final SessionStepType type;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      SessionStepType.reassurance => Icons.favorite_outline,
      SessionStepType.information => Icons.lightbulb_outline,
      SessionStepType.breathing => Icons.air,
      SessionStepType.grounding => Icons.self_improvement,
      SessionStepType.audio => Icons.headphones,
      SessionStepType.completion => Icons.check_circle_outline,
    };
    final background = switch (type) {
      SessionStepType.grounding || SessionStepType.completion => AppTheme.mint,
      SessionStepType.reassurance => AppTheme.lavender,
      SessionStepType.information => AppTheme.softPurple,
      SessionStepType.breathing || SessionStepType.audio => AppTheme.lightBlue,
    };
    return Center(
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, size: 44, color: AppTheme.primaryText),
      ),
    );
  }
}

class _BreathingGuide extends StatefulWidget {
  const _BreathingGuide();

  @override
  State<_BreathingGuide> createState() => _BreathingGuideState();
}

class _BreathingGuideState extends State<_BreathingGuide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        final scale = value < .4
            ? .7 + (value / .4) * .3
            : value < .5
                ? 1.0
                : 1.0 - ((value - .5) / .5) * .3;
        final label = value < .4
            ? 'Breathe in slowly'
            : value < .5
                ? 'Pause gently'
                : 'Breathe out slowly';
        return Column(
          children: [
            Transform.scale(
              scale: scale,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.softBlue.withValues(alpha: .18),
                  border: Border.all(color: AppTheme.softBlue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(label, style: Theme.of(context).textTheme.titleLarge),
          ],
        );
      },
    );
  }
}

class _AudioControls extends ConsumerWidget {
  const _AudioControls({required this.step});
  final SessionStep step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(audioServiceProvider);
    return AppCard(
      child: Column(
        children: [
          const Icon(Icons.headphones, color: AppTheme.softBlue, size: 36),
          const SizedBox(height: 12),
          Text(
            step.audioTitle ?? 'Calming audio',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                tooltip: 'Play audio',
                onPressed: () => service.playAsset(step.audioAssetPath!),
                icon: const Icon(Icons.play_arrow),
              ),
              const SizedBox(width: 16),
              IconButton.outlined(
                tooltip: 'Pause audio',
                onPressed: service.pause,
                icon: const Icon(Icons.pause),
              ),
              const SizedBox(width: 16),
              IconButton.outlined(
                tooltip: 'Stop audio',
                onPressed: service.stop,
                icon: const Icon(Icons.stop),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
