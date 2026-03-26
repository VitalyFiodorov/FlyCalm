import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';

class PrimaryButton extends ConsumerWidget {
  final VoidCallback onPressed;
  final String text;

  const PrimaryButton({Key? key, required this.onPressed, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        if (ref.read(settingsProvider).hapticsEnabled) {
          HapticFeedback.lightImpact();
        }
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.softBlue,
        foregroundColor: AppTheme.darkNavy,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        elevation: 0,
      ),
      child: Center(child: Text(text)),
    );
  }
}

class SecondaryButton extends ConsumerWidget {
  final VoidCallback onPressed;
  final String text;

  const SecondaryButton({Key? key, required this.onPressed, required this.text}) : super(key: key);

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
  const ScreenContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.darkNavy, AppTheme.deepBlue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const ProgressBar({Key? key, required this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.textMuted.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: MediaQuery.of(context).size.width * progress, // Needs constrained width, best to use LayoutBuilder, but OK if parent is constrained
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.softBlue,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: AppTheme.softBlue.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 1,
              )
            ],
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
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
