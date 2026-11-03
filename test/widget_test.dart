import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skyease/main.dart';
import 'package:skyease/core/providers.dart';

void main() {
  testWidgets('FlyCalm App builds successfully', (WidgetTester tester) async {
    // Mock SharedPreferences with completed onboarding
    SharedPreferences.setMockInitialValues({
      'app_onboarding_completed': true,
    });
    final sharedPrefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        ],
        child: const SkyEaseApp(),
      ),
    );

    // Verify that the title "FlyCalm" is displayed (in SplashScreen)
    expect(find.text('FlyCalm'), findsOneWidget);

    // Settle the 3-second routing delay timer to navigate to HomeScreen
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify we successfully routed to the HomeScreen
    expect(find.text('Your flight'), findsOneWidget);
  });
}
