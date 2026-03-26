import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../core/providers.dart';
import '../../data/models/models.dart';

class TurbulenceScreen extends ConsumerStatefulWidget {
  const TurbulenceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TurbulenceScreen> createState() => _TurbulenceScreenState();
}

class _TurbulenceScreenState extends ConsumerState<TurbulenceScreen> {
  late TurbulenceMessage _currentMessage;
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    // Use post-frame to access ref properly if needed, but we can access ref here
    final repo = ref.read(messageRepositoryProvider);
    _currentMessage = repo.getStartingMessage();
  }

  void _nextMessage() {
    setState(() {
      _tapCount++;
      final repo = ref.read(messageRepositoryProvider);
      _currentMessage = repo.getRandomMessage(excludeId: _currentMessage.id);
    });
  }

  Widget _buildAudioTile(BuildContext context, String title, String path) {
    final audioService = ref.read(audioServiceProvider);
    return ListTile(
      leading: const Icon(Icons.audiotrack, color: AppTheme.softBlue),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.play_circle_fill, color: AppTheme.softBlue),
            onPressed: () => audioService.playAsset(path),
          ),
          IconButton(
            icon: const Icon(Icons.pause_circle_filled, color: Colors.orangeAccent),
            onPressed: () => audioService.pause(),
          ),
        ],
      ),
      onTap: () => audioService.playAsset(path),
    );
  }

  void _showAudioModal(BuildContext context) {
    final audioService = ref.read(audioServiceProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Select Calming Audio", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildAudioTile(context, "Meditative Deep Breathing", "audio/Meditative Deep Breathing.mp3"),
                _buildAudioTile(context, "Calm Reassuring In-Flight Turbulence", "audio/Calm Reassuring In-Flight Turbulence.mp3"),
                _buildAudioTile(context, "Calm Reassuring In-Flight Anxiety Support", "audio/Calm Reassuring In-Flight Anxiety Support.mp3"),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    audioService.stop();
                  },
                  child: const Text("Stop Audio", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                )
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      audioService.stop();
    });
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
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF020617), // Deeper, calmer almost black background
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Text(
                    _currentMessage.text,
                    key: ValueKey<String>(_currentMessage.id),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                if (_tapCount > 1 && ref.watch(settingsProvider).audioEnabled) ...[
                  SecondaryButton(
                    onPressed: () => _showAudioModal(context),
                    text: "Play calming audio",
                  ),
                  const SizedBox(height: 16),
                ],
                PrimaryButton(
                  onPressed: _nextMessage,
                  text: "Tell me more",
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "I feel better",
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
