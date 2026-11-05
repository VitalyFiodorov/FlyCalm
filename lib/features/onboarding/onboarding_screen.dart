import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../core/providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  int _currentPageIndex = 0;
  final int _totalScreens = 6;

  // Customizable CTA Button Text configurations for easy updates
  // (Can be changed to "Take a breath", "I'm ready", "Help me feel calmer", etc.)
  static const String _screen1Cta = "Continue";
  static const String _screen2Cta = "Continue";
  static const String _screen3Cta = "Continue";
  static const String _screen4Cta = "Continue";
  static const String _screen6Cta = "Start calming";

  // Local state for Screen 4 selection
  final List<String> _selectedTriggers = [];

  // Local state for Screen 5 selection
  bool _audioEnabled = true;
  bool _hapticsEnabled = true;
  String _calmingPreference =
      'guided'; // options: 'guided', 'voice', 'soundscape'

  // Airplane Window Animation Controller
  late AnimationController _windowController;
  late AnimationController _pulseController;
  late Animation<double> _windowProgress;
  late Animation<double> _windowPulse;

  @override
  void initState() {
    super.initState();
    // Parallax scrolling for airplane clouds
    _windowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    );
    _windowProgress =
        Tween<double>(begin: 0.0, end: 1.0).animate(_windowController);
    ref.read(analyticsProvider).log('onboarding_started');
    _windowPulse = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50.0),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50.0),
    ]).animate(
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 4),
      )..repeat(),
    );

    _windowController.repeat();

    // Initialize local values from settings provider after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider);
      setState(() {
        _audioEnabled = settings.audioEnabled;
        _hapticsEnabled = settings.hapticsEnabled;
        _selectedTriggers.clear();
        _selectedTriggers.addAll(settings.selectedAnxietyTriggers);
        _calmingPreference = settings.calmingModePreference;
      });
    });
  }

  @override
  void dispose() {
    _windowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerHaptic(Future<void> Function() hapticFunc) {
    if (_hapticsEnabled) {
      hapticFunc();
    }
  }

  void _goNext() {
    _triggerHaptic(HapticFeedback.mediumImpact);
    if (_currentPageIndex < _totalScreens - 1) {
      setState(() {
        _currentPageIndex++;
      });
    } else {
      // Save all parameters back to preferences and complete onboarding
      final settingsNotifier = ref.read(settingsProvider.notifier);
      settingsNotifier.updateAnxietyTriggers(_selectedTriggers);
      settingsNotifier.updateCalmingPreference(_calmingPreference);
      settingsNotifier.toggleAudio(_audioEnabled);
      settingsNotifier.toggleHaptics(_hapticsEnabled);
      settingsNotifier.completeOnboarding();
      ref.read(analyticsProvider).log('onboarding_completed', parameters: {
        'trigger_count': _selectedTriggers.length,
      });
      context.go('/home');
    }
  }

  void _goBack() {
    _triggerHaptic(HapticFeedback.lightImpact);
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cloudWhite,
      body: ScreenContainer(
        child: Column(
          children: [
            // Top Navigation & Progress Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  // Back Button (hidden on screen 1)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _currentPageIndex > 0 ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: _currentPageIndex == 0,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppTheme.textMuted, size: 20),
                        onPressed: _goBack,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "FlyCalm",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w300,
                              fontSize: 20,
                              letterSpacing: 2,
                              color: AppTheme.textLight.withValues(alpha: 0.8),
                            ),
                      ),
                    ),
                  ),
                  // Placeholder to balance back button width
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Progress Indicator (Thin glowing blue bar)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
              child: Stack(
                children: [
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.textMuted.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    width: MediaQuery.of(context).size.width *
                        ((_currentPageIndex + 1) / _totalScreens) *
                        0.84, // scaled to horizontal padded constraints
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.softBlue,
                      borderRadius: BorderRadius.circular(1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.softBlue.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Panel (Slow animated cross-fade transition)
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.05),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _buildScreenContent(_currentPageIndex),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenContent(int index) {
    switch (index) {
      case 0:
        return _buildScreen1();
      case 1:
        return _buildScreen2();
      case 2:
        return _buildScreen3();
      case 3:
        return _buildScreen4();
      case 4:
        return _buildScreen5();
      case 5:
        return _buildScreen6();
      default:
        return const SizedBox.shrink();
    }
  }

  // --- SCREEN 1: SAFE ENTRY ---
  Widget _buildScreen1() {
    return KeyedSubtree(
      key: const ValueKey<int>(1),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 32.0),
        child: Column(
          children: [
            Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  "Fear of Flying?",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        fontSize: 34,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "You’re not alone.",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(
                            0xFF93C5FD), // brighter, more readable sky-blue
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const Spacer(flex: 3), // rich vertical breathing room
            // Premium Parallax Airplane Window
            Center(
              child: AnimatedBuilder(
                animation: _windowController,
                builder: (context, child) {
                  return Container(
                    width: 210,
                    height: 290,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(105),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.softBlue.withValues(alpha: 0.12),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: AirplaneWindowCloudPainter(
                        progress: _windowProgress.value,
                        breathPulse: _windowPulse.value,
                      ),
                    ),
                  );
                },
              ),
            ),
            const Spacer(flex: 4), // rich vertical breathing room
            PrimaryButton(
              onPressed: _goNext,
              text: _screen1Cta,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // --- SCREEN 2: DEEP REASSURANCE ---
  Widget _buildScreen2() {
    return KeyedSubtree(
      key: const ValueKey<int>(2),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 32.0),
        child: Column(
          children: [
            Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  "Flying anxiety can feel overwhelming",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Text(
                  "Takeoff, turbulence, panic, claustrophobia — FlyCalm helps you feel more grounded during flights.",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(
                            0xFF94A3B8), // premium neutral-slate subtitle
                        fontSize: 15,
                        height: 1.55,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const Spacer(flex: 3),
            const Center(
              child: BreathingGlow(),
            ),
            const Spacer(flex: 4),
            PrimaryButton(
              onPressed: _goNext,
              text: _screen2Cta,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // --- SCREEN 3: COMPANION WALKTHROUGH ---
  Widget _buildScreen3() {
    return KeyedSubtree(
      key: const ValueKey<int>(3),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 32.0),
        child: Column(
          children: [
            Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  "Calm support when anxiety peaks",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Text(
                  "Free calming tools are always available. Premium adds three step-by-step sessions for the full flight, turbulence, and anxious moments.",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textMuted,
                        fontSize: 15,
                        height: 1.55,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const Spacer(flex: 3),
            const FloatingMockUi(),
            const Spacer(flex: 4),
            PrimaryButton(
              onPressed: _goNext,
              text: _screen3Cta,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // --- SCREEN 4: DEEP PERSONALIZATION (TRIGGERS) ---
  Widget _buildScreen4() {
    final triggersList = [
      {"label": "Before takeoff", "icon": Icons.schedule_rounded},
      {"label": "During takeoff", "icon": Icons.flight_takeoff_rounded},
      {"label": "Turbulence", "icon": Icons.waves_rounded},
      {"label": "Long flights", "icon": Icons.map_rounded},
      {"label": "Claustrophobia", "icon": Icons.zoom_in_map_rounded},
      {"label": "Panic attacks", "icon": Icons.favorite_rounded},
    ];

    return KeyedSubtree(
      key: const ValueKey<int>(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Text(
              "When do you feel most anxious?",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Select all that apply. We will tailor support recommendations for these scenarios.",
              style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.25,
                ),
                itemCount: triggersList.length,
                itemBuilder: (context, index) {
                  final trigger = triggersList[index];
                  final label = trigger["label"] as String;
                  final icon = trigger["icon"] as IconData;
                  final isSelected = _selectedTriggers.contains(label);

                  return GestureDetector(
                    onTap: () {
                      _triggerHaptic(HapticFeedback.selectionClick);
                      setState(() {
                        if (isSelected) {
                          _selectedTriggers.remove(label);
                        } else {
                          _selectedTriggers.add(label);
                        }
                      });
                      ref
                          .read(analyticsProvider)
                          .log('fear_trigger_selected', parameters: {
                        'trigger': label.toLowerCase().replaceAll(' ', '_'),
                        'selected': _selectedTriggers.contains(label),
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.softBlue.withValues(alpha: 0.08)
                            : AppTheme.cardBg.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isSelected ? AppTheme.softBlue : AppTheme.outline,
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: AppTheme.softBlue.withValues(alpha: 0.15),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            color: isSelected
                                ? AppTheme.softBlue
                                : AppTheme.textMuted,
                            size: 28,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppTheme.textLight
                                  : AppTheme.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24), // improved vertical spacing
            PrimaryButton(
              onPressed: _goNext,
              text: _screen4Cta,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // --- SCREEN 5: GROUNDING SETTINGS (PREFERENCES) ---
  Widget _buildScreen5() {
    final modeOptions = [
      {
        "id": "guided",
        "title": "Guided Deep Breathing",
        "subtitle": "Interactive breathing prompts and co-regulation tools",
        "icon": Icons.air_rounded
      },
      {
        "id": "voice",
        "title": "Gentle Voice Reassurance",
        "subtitle": "Soothing voice narrations explaining sights and sounds",
        "icon": Icons.record_voice_over_rounded
      },
      {
        "id": "soundscape",
        "title": "Soothing Soundscapes",
        "subtitle": "Calming background noise and meditative audio paths",
        "icon": Icons.spa_rounded
      },
    ];

    return KeyedSubtree(
      key: const ValueKey<int>(5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Let’s personalize your experience",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Device Customization Switches
              AppCard(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text("Calming Audio",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: const Text(
                          "Automatic ambient sounds during stress peaks",
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textMuted)),
                      activeThumbColor: AppTheme.softBlue,
                      value: _audioEnabled,
                      onChanged: (val) {
                        _triggerHaptic(HapticFeedback.selectionClick);
                        setState(() => _audioEnabled = val);
                      },
                    ),
                    const Divider(color: AppTheme.outline),
                    SwitchListTile(
                      title: const Text("Physical Haptic Pulse",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: const Text(
                          "Vibrate phone gently to guide breathing cycles",
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textMuted)),
                      activeThumbColor: AppTheme.softBlue,
                      value: _hapticsEnabled,
                      onChanged: (val) {
                        _triggerHaptic(HapticFeedback.selectionClick);
                        setState(() => _hapticsEnabled = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "PRIMARY CALMING METHOD",
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.softBlue,
                    letterSpacing: 1.5),
              ),
              const SizedBox(height: 10),

              // Radios for preferences
              ...modeOptions.map((opt) {
                final id = opt["id"] as String;
                final title = opt["title"] as String;
                final subtitle = opt["subtitle"] as String;
                final icon = opt["icon"] as IconData;
                final isSelected = _calmingPreference == id;

                return GestureDetector(
                  onTap: () {
                    _triggerHaptic(HapticFeedback.selectionClick);
                    setState(() => _calmingPreference = id);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.softBlue.withValues(alpha: 0.05)
                          : AppTheme.cardBg.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected ? AppTheme.softBlue : AppTheme.outline,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.softBlue.withValues(alpha: 0.2)
                                : AppTheme.lightBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon,
                              color: isSelected
                                  ? AppTheme.softBlue
                                  : AppTheme.textMuted,
                              size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: AppTheme.textLight),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: const TextStyle(
                                    fontSize: 11, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded,
                              color: AppTheme.softBlue, size: 20),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              PrimaryButton(
                onPressed: _goNext,
                text: "Continue",
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- SCREEN 6: CORE CO-REGULATION ---
  Widget _buildScreen6() {
    return KeyedSubtree(
      key: const ValueKey<int>(6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 32.0),
        child: Column(
          children: [
            Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  "You can feel calmer while flying",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Text(
                  "One breath. One moment at a time.",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textMuted,
                        fontSize: 15.5,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const Spacer(flex: 3),
            Center(
              child: BreathingCoRegulation(hapticsEnabled: _hapticsEnabled),
            ),
            const Spacer(flex: 4),
            PrimaryButton(
              onPressed: _goNext,
              text: _screen6Cta,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// CUSTOM PAINTER & ANIMATION ASSISTANT WIDGETS
// ==========================================

class AirplaneWindowCloudPainter extends CustomPainter {
  final double progress; // drift position [0.0, 1.0]
  final double breathPulse; // pulsing glow [0.0, 1.0]

  AirplaneWindowCloudPainter(
      {required this.progress, required this.breathPulse});

  @override
  void paint(Canvas canvas, Size size) {
    final RRect outerFrame = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.width * 0.48),
    );

    // Save canvas state before clipping, keeping outside background un-touched
    canvas.save();
    canvas.clipRRect(outerFrame);

    // 1. Soft daylight sky gradient.
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFDBEAFE),
          Color(0xFFC7E2FF),
          Color(0xFFF8FAFC),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // 2. Glowing atmospheric sunburst radial glow (Inside the window)
    final Paint glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF93C5FD)
              .withValues(alpha: 0.25 + (0.05 * breathPulse)),
          const Color(0xFF60A5FA).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.7),
          radius: size.width * 0.8));
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.7),
        size.width * 0.8, glowPaint);

    // 3. Soft light details inside the window.
    final Paint starPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75);
    canvas.drawCircle(
        Offset(size.width * 0.25, size.height * 0.15), 1.5, starPaint);
    canvas.drawCircle(
        Offset(size.width * 0.78, size.height * 0.22), 1.2, starPaint);
    canvas.drawCircle(
        Offset(size.width * 0.55, size.height * 0.08), 2.0, starPaint);

    // 4. Parallax Horizontal Cloud Layers
    // Layer 1: Distant pastel cloud layer.
    _drawCloudLayer(canvas, size, progress * 0.25,
        const Color(0xFFDDD6FE).withValues(alpha: 0.82), 0.55);

    // Layer 2: Mid-ground mint clouds.
    _drawCloudLayer(canvas, size, progress * 0.5,
        const Color(0xFFA7F3D0).withValues(alpha: 0.7), 0.65);

    // Layer 3: Foreground glowing puffy clouds (Fast speed, bright details, puffy white)
    _drawCloudLayer(
        canvas,
        size,
        progress * 0.8,
        const Color(0xFFE2E8F0).withValues(alpha: 0.9 + (0.05 * breathPulse)),
        0.75);

    // Restore canvas state to draw borders and sheen without clipping mask anomalies
    canvas.restore();

    // 5. Draw the physical airplane outer-wall frame
    // Draw thick inner bevel shadow to represent deep airplane window frame
    final Paint innerBevelPaint = Paint()
      ..color = const Color(0xFF64748B).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;
    canvas.drawRRect(outerFrame, innerBevelPaint);

    // Outer frame rim (thick grey airplane wall rim)
    final Paint frameRimPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawRRect(outerFrame, frameRimPaint);

    // High contrast bevel glow to give high-fidelity depth pop
    final Paint borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(outerFrame, borderPaint);

    // 6. Draw diagonal specular sheen reflection
    final Paint glassReflect = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.0),
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.save();
    canvas.clipRRect(outerFrame);
    final Path sheenPath = Path()
      ..moveTo(size.width * 0.35, 0)
      ..lineTo(size.width, size.height * 0.45)
      ..lineTo(size.width, size.height * 0.52)
      ..lineTo(size.width * 0.15, 0)
      ..close();
    canvas.drawPath(sheenPath, glassReflect);
    canvas.restore();
  }

  void _drawCloudLayer(Canvas canvas, Size size, double layerProgress,
      Color color, double verticalHeightPercent) {
    final Paint cloudPaint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal, 8); // cleaner cloud edges for premium vector feel

    final double screenOffset = layerProgress * size.width;

    // Draw duplicate blocks of clouds so they loop seamlessly
    for (int block = -2; block <= 2; block++) {
      final double cloudX = (block * size.width) + screenOffset;
      final double cloudY = size.height * verticalHeightPercent;

      // Draw cluster of overlapping circles to create an organic fluffy cloud shape
      canvas.drawCircle(Offset(cloudX, cloudY), size.width * 0.28, cloudPaint);
      canvas.drawCircle(
          Offset(cloudX - size.width * 0.18, cloudY + size.height * 0.02),
          size.width * 0.22,
          cloudPaint);
      canvas.drawCircle(
          Offset(cloudX + size.width * 0.2, cloudY + size.height * 0.01),
          size.width * 0.24,
          cloudPaint);
      canvas.drawCircle(
          Offset(cloudX - size.width * 0.35, cloudY + size.height * 0.04),
          size.width * 0.18,
          cloudPaint);
      canvas.drawCircle(
          Offset(cloudX + size.width * 0.38, cloudY + size.height * 0.03),
          size.width * 0.16,
          cloudPaint);
    }
  }

  @override
  bool shouldRepaint(covariant AirplaneWindowCloudPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.breathPulse != breathPulse;
  }
}

class BreathingGlow extends StatefulWidget {
  const BreathingGlow({super.key});

  @override
  State<BreathingGlow> createState() => _BreathingGlowState();
}

class _BreathingGlowState extends State<BreathingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    // 5-second slow rhythmic breath sequence for anxiety reduction
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.3)
              .chain(CurveTween(curve: Curves.easeInOutCubic)),
          weight: 50.0),
      TweenSequenceItem(
          tween: Tween(begin: 1.3, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOutCubic)),
          weight: 50.0),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.25, end: 0.65)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50.0),
      TweenSequenceItem(
          tween: Tween(begin: 0.65, end: 0.25)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50.0),
    ]).animate(_controller);

    _controller.repeat();
  }

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
        return SizedBox(
          width: 250,
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer atmospheric neon halo
              Container(
                width: 200 * _scaleAnimation.value,
                height: 200 * _scaleAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.softBlue
                          .withValues(alpha: _opacityAnimation.value * 0.45),
                      AppTheme.softBlue.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              // Middle glowing pulse ring
              Container(
                width: 140 * _scaleAnimation.value,
                height: 140 * _scaleAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.softBlue.withValues(alpha: 0.03),
                  border: Border.all(
                    color: AppTheme.softBlue
                        .withValues(alpha: _opacityAnimation.value * 0.3),
                    width: 1.5,
                  ),
                ),
              ),
              // Inner tactile co-regulating dot
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.softBlue.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppTheme.softBlue
                          .withValues(alpha: _opacityAnimation.value),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.softBlue
                            .withValues(alpha: _opacityAnimation.value * 0.25),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FloatingMockUi extends StatefulWidget {
  const FloatingMockUi({super.key});

  @override
  State<FloatingMockUi> createState() => _FloatingMockUiState();
}

class _FloatingMockUiState extends State<FloatingMockUi>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    // Smooth infinite sinusoidal float animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _floatAnim = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 12.0)
              .chain(CurveTween(curve: Curves.easeInOutSine)),
          weight: 50.0),
      TweenSequenceItem(
          tween: Tween(begin: 12.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeInOutSine)),
          weight: 50.0),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (context, child) {
        return SizedBox(
          height: 250,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // 1. Soothing Audio mini-card (lower-right, out of phase rotation)
              Positioned(
                bottom: 15 + (_floatAnim.value * 0.7),
                right: 20,
                child: Transform.rotate(
                  angle: 0.04,
                  child: _buildMockCard(
                    icon: Icons.music_note_rounded,
                    title: "Calming Audio",
                    subtitle: "Drift away to ambient clouds",
                    width: 175,
                  ),
                ),
              ),
              // 2. Guided Breathing mini-card (upper-left, opposing float phase)
              Positioned(
                top: 15 - (_floatAnim.value * 0.8),
                left: 20,
                child: Transform.rotate(
                  angle: -0.04,
                  child: _buildMockCard(
                    icon: Icons.air_rounded,
                    title: "Breathing",
                    subtitle: "Regulate your nervous system",
                    width: 175,
                  ),
                ),
              ),
              // 3. Turbulence Assist core card (center focal highlight)
              Positioned(
                top: 75 + (_floatAnim.value * 1.0),
                child: Transform.scale(
                  scale: 1.05,
                  child: _buildMockCard(
                    icon: Icons.waves_rounded,
                    title: "Turbulence Support",
                    subtitle: "Real-time explanation of sound & movement",
                    width: 220,
                    isMain: true,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMockCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double width,
    bool isMain = false,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMain
            ? AppTheme.deepBlue.withValues(alpha: 0.95)
            : AppTheme.cardBg.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isMain
              ? AppTheme.softBlue.withValues(alpha: 0.5)
              : AppTheme.outline,
          width: isMain ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.skyBlue.withValues(alpha: isMain ? 0.18 : 0.1),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: isMain
                  ? AppTheme.softBlue.withValues(alpha: 0.2)
                  : AppTheme.lightBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.softBlue, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textLight),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style:
                      const TextStyle(fontSize: 9.5, color: AppTheme.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BreathingCoRegulation extends StatefulWidget {
  final bool hapticsEnabled;
  const BreathingCoRegulation({super.key, required this.hapticsEnabled});

  @override
  State<BreathingCoRegulation> createState() => _BreathingCoRegulationState();
}

class _BreathingCoRegulationState extends State<BreathingCoRegulation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;
  String _guideText = "Breathe in…";
  Color _circleColor = AppTheme.softBlue;

  @override
  void initState() {
    super.initState();
    // 4s inhale, 2s hold, 4s exhale = 10s cycle
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.62, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOutCubic)),
          weight: 40.0), // inhale
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.0), weight: 20.0), // hold
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.62)
              .chain(CurveTween(curve: Curves.easeInOutCubic)),
          weight: 40.0), // exhale
    ]).animate(_controller);

    _glowAnim = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.15, end: 0.8)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 40.0),
      TweenSequenceItem(
          tween: Tween(begin: 0.8, end: 0.9)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 20.0),
      TweenSequenceItem(
          tween: Tween(begin: 0.9, end: 0.15)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 40.0),
    ]).animate(_controller);

    _controller.addListener(() {
      final value = _controller.value;
      if (value < 0.40) {
        if (_guideText != "Breathe in…") {
          setState(() {
            _guideText = "Breathe in…";
            _circleColor = AppTheme.softBlue;
          });
          _playHaptic(HapticFeedback.lightImpact);
        }
      } else if (value < 0.60) {
        if (_guideText != "Hold…") {
          setState(() {
            _guideText = "Hold…";
            _circleColor =
                const Color(0xFF38BDF8); // Slightly lighter glowing sky blue
          });
          _playHaptic(HapticFeedback.mediumImpact);
        }
      } else {
        if (_guideText != "Breathe out…") {
          setState(() {
            _guideText = "Breathe out…";
            _circleColor = AppTheme.softBlue.withValues(alpha: 0.8);
          });
          _playHaptic(HapticFeedback.lightImpact);
        }
      }
    });

    _controller.repeat();
  }

  void _playHaptic(Future<void> Function() hapticFunc) {
    if (widget.hapticsEnabled) {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 260,
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Atmospheric outer expanding glow
              Container(
                width: 250 * _scaleAnim.value,
                height: 250 * _scaleAnim.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _circleColor.withValues(alpha: _glowAnim.value * 0.45),
                      _circleColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              // Meditative pulse ring
              Container(
                width: 180 * _scaleAnim.value,
                height: 180 * _scaleAnim.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        _circleColor.withValues(alpha: _glowAnim.value * 0.25),
                    width: 1.0,
                  ),
                ),
              ),
              // Tangible core breathing visualizer circle
              Transform.scale(
                scale: _scaleAnim.value,
                child: Container(
                  width: 125,
                  height: 125,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _circleColor.withValues(alpha: 0.12),
                    border: Border.all(
                      color: _circleColor.withValues(
                          alpha: _glowAnim.value * 0.85 + 0.1),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _circleColor.withValues(
                            alpha: _glowAnim.value * 0.3),
                        blurRadius: 35,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim, child: child),
                      child: Text(
                        _guideText,
                        key: ValueKey<String>(_guideText),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
