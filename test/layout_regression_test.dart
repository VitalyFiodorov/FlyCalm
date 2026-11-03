import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skyease/core/providers.dart';
import 'package:skyease/features/home/home_screen.dart';
import 'package:skyease/features/premium/guided_session_catalog.dart';
import 'package:skyease/features/premium/guided_session_screen.dart';
import 'package:skyease/features/turbulence/turbulence_screen.dart';
import 'package:skyease/data/storage/storage_repository.dart';

void main() {
  Future<SharedPreferences> preferences() async {
    SharedPreferences.setMockInitialValues({
      'app_onboarding_completed': true,
    });
    return SharedPreferences.getInstance();
  }

  Widget testApp(SharedPreferences prefs, Widget screen) {
    final storage = StorageRepository(prefs);
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        settingsProvider.overrideWith(
          (ref) => SettingsNotifier(storage),
        ),
        nextFlightProvider.overrideWith(
          (ref) => NextFlightNotifier(storage),
        ),
      ],
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.3),
          ),
          child: child!,
        ),
        home: screen,
      ),
    );
  }

  testWidgets('home mode cards do not overflow with large text',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testApp(await preferences(), const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('audio sheet scrolls instead of overflowing', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester
        .pumpWidget(testApp(await preferences(), const TurbulenceScreen()));
    await tester.ensureVisible(find.text('Tell me more'));
    await tester.tap(find.text('Tell me more'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Tell me more'));
    await tester.tap(find.text('Tell me more'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Play calming audio'));
    await tester.tap(find.text('Play calming audio'));
    await tester.pumpAndSettle();

    expect(find.text('Select Calming Audio'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('every Premium guided step scrolls without clipping',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final prefs = await preferences();
    for (final session in GuidedSessionCatalog.all) {
      for (var index = 0; index < session.steps.length; index++) {
        await prefs.setInt('premium_session_progress_${session.id}', index);
        await tester.pumpWidget(
          testApp(
            prefs,
            GuidedSessionScreen(
              key: ValueKey('${session.id}_$index'),
              session: session,
            ),
          ),
        );
        await tester.pump();

        expect(find.text(session.headerTitle), findsOneWidget);
        expect(find.text(session.steps[index].title), findsOneWidget);
        expect(find.byType(ListView), findsOneWidget);
        expect(tester.takeException(), isNull,
            reason: '${session.title}, step ${index + 1}');

        await tester.drag(find.byType(ListView), const Offset(0, -800));
        await tester.pump();
        expect(tester.takeException(), isNull,
            reason: '${session.title}, scrolled step ${index + 1}');
      }
    }

    expect(GuidedSessionCatalog.flightJourney.headerTitle, 'Flight Journey');
    expect(GuidedSessionCatalog.advancedTurbulence.headerTitle, 'Turbulence');
    expect(GuidedSessionCatalog.structuredPanic.headerTitle, 'Panic Support');
  });
}
