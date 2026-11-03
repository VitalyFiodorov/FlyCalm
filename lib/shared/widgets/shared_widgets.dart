import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';

class PrimaryButton extends ConsumerStatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const PrimaryButton({super.key, required this.onPressed, required this.text});

  @override
  ConsumerState<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends ConsumerState<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _pressController;
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.reverse(),
      onTapUp: (_) => _pressController.forward(),
      onTapCancel: () => _pressController.forward(),
      onTap: () {
        if (ref.read(settingsProvider).hapticsEnabled) {
          HapticFeedback.mediumImpact();
        }
        widget.onPressed();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.softBlue,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.softBlue.withValues(alpha: 0.24),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: const TextStyle(
                color: AppTheme.darkNavy,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends ConsumerWidget {
  final VoidCallback onPressed;
  final String text;

  const SecondaryButton(
      {super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () {
        if (ref.read(settingsProvider).hapticsEnabled) {
          HapticFeedback.lightImpact();
        }
        onPressed();
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.textLight,
        backgroundColor: Colors.white.withValues(alpha: 0.72),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        side: const BorderSide(color: AppTheme.softBlue, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      child: Center(child: Text(text)),
    );
  }
}

class ScreenContainer extends StatelessWidget {
  final Widget child;
  const ScreenContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.lightBlue, AppTheme.cloudWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -90,
            right: -70,
            child: _AtmosphereGlow(size: 250, color: AppTheme.lavender),
          ),
          const Positioned(
            bottom: -100,
            left: -80,
            child: _AtmosphereGlow(size: 280, color: AppTheme.mint),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class _AtmosphereGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _AtmosphereGlow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.32),
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const ProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.lightBlue,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: MediaQuery.of(context).size.width *
              progress, // Needs constrained width, best to use LayoutBuilder, but OK if parent is constrained
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.softBlue,
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [],
          ),
        ),
      ],
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.skyBlue.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
