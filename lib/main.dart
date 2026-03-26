import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/providers.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/flight/add_flight_screen.dart';
import 'features/flight/flight_mode_screen.dart';
import 'features/turbulence/turbulence_screen.dart';
import 'features/calm/calm_me_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/flight/arrival_complete_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const SkyEaseApp(),
    ),
  );
}

class SkyEaseApp extends ConsumerWidget {
  const SkyEaseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    // We start at the splash screen to allow a calm fade-in
    final goRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/add_flight',
          builder: (context, state) => const AddFlightScreen(),
        ),
        GoRoute(
          path: '/flight_mode',
          builder: (context, state) => const FlightModeScreen(),
        ),
        GoRoute(
          path: '/turbulence',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const TurbulenceScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: '/calm',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const CalmMeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/arrival',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const ArrivalCompleteScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'FlyCalm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: goRouter,
    );
  }
}
