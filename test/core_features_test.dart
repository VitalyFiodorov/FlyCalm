import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skyease/data/models/models.dart';
import 'package:skyease/data/services/analytics_service.dart';
import 'package:skyease/data/storage/storage_repository.dart';

void main() {
  test('next flight countdown and preparation stages are date based', () {
    final now = DateTime(2026, 8, 31, 23, 30);
    expect(NextFlight(date: DateTime(2026, 8, 31)).countdownLabel(now),
        'Your flight is today');
    expect(NextFlight(date: DateTime(2026, 9, 1)).countdownLabel(now),
        'Your flight is tomorrow');
    expect(NextFlight(date: DateTime(2026, 9, 3)).preparationStage(now),
        'Prepare your personal flight plan');
    expect(NextFlight(date: DateTime(2026, 9, 20)).preparationStage(now),
        'Understand what happens during a flight');
  });

  test('next flight and premium entitlement persist offline', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageRepository(prefs);
    final flight = NextFlight(
        date: DateTime(2026, 10, 1), origin: 'SOF', destination: 'LHR');
    await storage.saveNextFlight(flight);
    final settings = storage.getSettings().copyWith(premiumEntitled: true);
    await storage.saveSettings(settings);

    expect(storage.getNextFlight()?.origin, 'SOF');
    expect(storage.getSettings().premiumEntitled, isTrue);
  });

  test('analytics records returning opens without personal text', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final analytics = AnalyticsService(prefs);
    await analytics.trackAppOpen();
    await analytics.trackAppOpen();

    expect(analytics.pendingEvents, hasLength(2));
    expect(
        analytics.pendingEvents.last['parameters']['returning_user'], isTrue);
  });
}
