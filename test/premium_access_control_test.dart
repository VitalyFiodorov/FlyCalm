import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skyease/core/providers.dart';
import 'package:skyease/data/models/models.dart';
import 'package:skyease/data/storage/storage_repository.dart';
import 'package:skyease/features/home/home_screen.dart';
import 'package:skyease/features/premium/guided_session_catalog.dart';
import 'package:skyease/features/premium/premium_gate.dart';
import 'package:skyease/features/support/support_mode_screen.dart';
import 'package:skyease/main.dart';

class TestSettingsNotifier extends SettingsNotifier {
  // A super parameter cannot name SettingsNotifier's private field-formal.
  // ignore: use_super_parameters
  TestSettingsNotifier(StorageRepository storage, {required bool premium})
      : super(storage) {
    state = AppSettings(
      onboardingCompleted: true,
      premiumEntitled: premium,
    );
  }
}

void main() {
  Future<Widget> app({
    required bool premium,
    required Widget child,
  }) async {
    SharedPreferences.setMockInitialValues({
      'app_onboarding_completed': true,
      'app_premium_entitled': premium,
    });
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageRepository(prefs);
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        settingsProvider.overrideWith(
          (ref) => TestSettingsNotifier(storage, premium: premium),
        ),
        nextFlightProvider.overrideWith((ref) => NextFlightNotifier(storage)),
      ],
      child: child,
    );
  }

  Future<Widget> routedApp({
    required bool premium,
    required String initialLocation,
  }) {
    return app(
      premium: premium,
      child: MaterialApp.router(
        routerConfig: createAppRouter(initialLocation: initialLocation),
      ),
    );
  }

  testWidgets('PremiumGate blocks Free and opens content for Premium',
      (tester) async {
    Widget gated() => PremiumGate(
          lockedBuilder: (_) => const Text('Existing Premium paywall'),
          child: const Text('Premium content'),
        );

    await tester.pumpWidget(await app(
      premium: false,
      child: MaterialApp(home: gated()),
    ));
    expect(find.text('Existing Premium paywall'), findsOneWidget);
    expect(find.text('Premium content'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(await app(
      premium: true,
      child: MaterialApp(home: gated()),
    ));
    expect(find.text('Premium content'), findsOneWidget);
    expect(find.text('Existing Premium paywall'), findsNothing);
  });

  testWidgets('Free home preserves tools and locks only guided journeys',
      (tester) async {
    await tester.pumpWidget(await app(
      premium: false,
      child: const MaterialApp(home: HomeScreen()),
    ));

    expect(find.text('Add next flight'), findsOneWidget);
    expect(find.text('Takeoff'), findsOneWidget);
    expect(find.text('Turbulence'), findsOneWidget);
    expect(find.text('Breathing'), findsOneWidget);
    expect(find.text('Landing'), findsOneWidget);
    expect(find.textContaining('Premium ·'), findsNothing);

    for (final key in const [
      'guided_flight_journey_card',
      'advanced_turbulence_card',
      'structured_panic_card',
    ]) {
      final card = find.byKey(Key(key));
      await tester.scrollUntilVisible(
        card,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.descendant(of: card, matching: find.byIcon(Icons.lock_outline)),
        findsOneWidget,
      );
    }
  });

  testWidgets('Free Panic retains the complete existing grounding sequence',
      (tester) async {
    await tester.pumpWidget(await app(
      premium: false,
      child: const MaterialApp(
        home: SupportModeScreen(mode: SupportMode.panic),
      ),
    ));
    await tester.scrollUntilVisible(
      find.textContaining('Listen for 3 sounds'),
      300,
    );

    expect(find.textContaining('Name 5 things'), findsOneWidget);
    expect(find.textContaining('Notice 4 things'), findsOneWidget);
    expect(find.textContaining('Listen for 3 sounds'), findsOneWidget);
    expect(find.textContaining('Unlock'), findsNothing);
  });

  testWidgets('existing direct routes remain available to Free users',
      (tester) async {
    const routes = <String, String>{
      '/takeoff': 'Takeoff',
      '/landing': 'Landing',
      '/panic': "You're here. You're safe in this moment.",
    };

    for (final route in routes.entries) {
      await tester.pumpWidget(
        await routedApp(premium: false, initialLocation: route.key),
      );
      await tester.pump();
      expect(find.text(route.value), findsWidgets, reason: route.key);
      expect(
          find.text('Feel more prepared for your next flight.'), findsNothing,
          reason: route.key);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('Premium deep routes open each new guided experience',
      (tester) async {
    const routes = <String, String>{
      '/premium/guided-flight': 'Before boarding',
      '/premium/advanced-turbulence': 'Stay with this moment',
      '/premium/structured-panic': "You're here",
    };

    for (final route in routes.entries) {
      await tester.pumpWidget(
        await routedApp(premium: true, initialLocation: route.key),
      );
      await tester.pump();
      expect(find.text(route.value), findsOneWidget, reason: route.key);
      expect(find.textContaining('Step 1 of'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  test('guided session catalogue contains only the three additive products',
      () {
    expect(GuidedSessionCatalog.all, hasLength(3));
    expect(GuidedSessionCatalog.flightJourney.steps, hasLength(8));
    expect(GuidedSessionCatalog.advancedTurbulence.steps, hasLength(7));
    expect(GuidedSessionCatalog.structuredPanic.steps, hasLength(6));
    expect(
      GuidedSessionCatalog.advancedTurbulence.steps
          .where((step) => step.audioAssetPath != null)
          .single
          .audioAssetPath,
      'audio/Calm Reassuring In-Flight Turbulence.mp3',
    );
  });
}
