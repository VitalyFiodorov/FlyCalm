import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/shared_widgets.dart';

class CalmMeScreen extends ConsumerStatefulWidget {
  const CalmMeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CalmMeScreen> createState() => _CalmMeScreenState();
}

class _CalmMeScreenState extends ConsumerState<CalmMeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String _instructionText = "Breathe in…";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 10), // 4 in, 2 hold, 4 out rough cycle
    );

    _scaleAnimation = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween(begin: 0.5, end: 1.0).chain(CurveTween(curve: Curves.easeInOutSine)),
          weight: 40.0, // 4s inhale
        ),
        TweenSequenceItem<double>(
          tween: Tween(begin: 1.0, end: 1.0),
          weight: 10.0, // 1s hold
        ),
        TweenSequenceItem<double>(
          tween: Tween(begin: 1.0, end: 0.5).chain(CurveTween(curve: Curves.easeInOutSine)),
          weight: 50.0, // 5s exhale
        ),
      ],
    ).animate(_controller);

    _controller.addListener(() {
      final val = _controller.value;
      if (val < 0.4) {
        if (_instructionText != "Take a slow breath in…") {
          setState(() => _instructionText = "Take a slow breath in…");
          _triggerHaptic(HapticFeedback.lightImpact);
        }
      } else if (val < 0.5) {
        if (_instructionText != "Hold…") {
          setState(() => _instructionText = "Hold…");
          _triggerHaptic(HapticFeedback.selectionClick);
        }
      } else {
        if (_instructionText != "Gently breathe out…") {
          setState(() => _instructionText = "Gently breathe out…");
          _triggerHaptic(HapticFeedback.lightImpact);
        }
      }
    });

    _controller.repeat();
  }

  void _triggerHaptic(Future<void> Function() hapticFunc) {
    if (ref.read(settingsProvider).hapticsEnabled) {
      hapticFunc();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ScreenContainer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _instructionText,
                  key: ValueKey<String>(_instructionText),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28),
                ),
              ),
              const SizedBox(height: 80),
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.softBlue.withOpacity(0.2),
                        border: Border.all(color: AppTheme.softBlue.withOpacity(0.5), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.softBlue.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 10 * _scaleAnimation.value,
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
