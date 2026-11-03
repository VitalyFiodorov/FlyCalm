import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../core/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final flightSession = ref.watch(flightSessionProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ScreenContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              AppCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text("Audio Enabled"),
                      subtitle: const Text("Play calming audio tracks",
                          style: TextStyle(color: AppTheme.textMuted)),
                      activeThumbColor: AppTheme.softBlue,
                      value: settings.audioEnabled,
                      onChanged: (val) =>
                          ref.read(settingsProvider.notifier).toggleAudio(val),
                    ),
                    const Divider(color: AppTheme.outline),
                    SwitchListTile(
                      title: const Text("Haptics Enabled"),
                      subtitle: const Text("Gentle vibrations for breathing",
                          style: TextStyle(color: AppTheme.textMuted)),
                      activeThumbColor: AppTheme.softBlue,
                      value: settings.hapticsEnabled,
                      onChanged: (val) => ref
                          .read(settingsProvider.notifier)
                          .toggleHaptics(val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text("Personalization",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Calming Mode"),
                      subtitle: Text(
                        settings.calmingModePreference == 'guided'
                            ? "Guided Deep Breathing"
                            : settings.calmingModePreference == 'voice'
                                ? "Gentle Voice Reassurance"
                                : "Soothing Soundscapes",
                        style: const TextStyle(color: AppTheme.textMuted),
                      ),
                      leading: const Icon(Icons.spa, color: AppTheme.softBlue),
                    ),
                    const Divider(color: AppTheme.outline),
                    const SizedBox(height: 8),
                    const Text("Anxiety Triggers",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    if (settings.selectedAnxietyTriggers.isEmpty)
                      const Text("No triggers selected yet",
                          style: TextStyle(
                              color: AppTheme.textMuted, fontSize: 14))
                    else
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children:
                            settings.selectedAnxietyTriggers.map((trigger) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.softBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color:
                                      AppTheme.softBlue.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              trigger,
                              style: const TextStyle(
                                  fontSize: 12, color: AppTheme.textLight),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 16),
                    const Divider(color: AppTheme.outline),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () {
                          ref.read(settingsProvider.notifier).resetOnboarding();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Onboarding preferences reset')),
                          );
                          context.go('/onboarding');
                        },
                        icon:
                            const Icon(Icons.refresh, color: AppTheme.softBlue),
                        label: const Text("Reset Onboarding Flow",
                            style: TextStyle(
                                color: AppTheme.softBlue,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (flightSession != null) ...[
                Text("Current Flight",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                            "${flightSession.fromCity} ➔ ${flightSession.toCity}"),
                        subtitle: const Text("Active flight in progress",
                            style: TextStyle(color: AppTheme.textMuted)),
                        leading:
                            const Icon(Icons.flight, color: AppTheme.softBlue),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            ref
                                .read(flightSessionProvider.notifier)
                                .clearFlight();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Flight cleared')));
                            context.go('/home');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text("Cancel Flight"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 48),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("About FlyCalm",
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    const Text(
                        "FlyCalm is your companion for a calm and serene flight. It works offline to help you understand your flight progress and find peace during turbulence.",
                        style:
                            TextStyle(color: AppTheme.textMuted, height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
