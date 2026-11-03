import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageRepository {
  final SharedPreferences _prefs;

  StorageRepository(this._prefs);

  static const String _keyAudioEnabled = 'app_audio_enabled';
  static const String _keyHapticsEnabled = 'app_haptics_enabled';
  static const String _keyOnboardingCompleted = 'app_onboarding_completed';
  static const String _keySelectedAnxietyTriggers =
      'app_selected_anxiety_triggers';
  static const String _keyCalmingModePreference = 'app_calming_mode_preference';
  static const String _keyActiveFlight = 'app_active_flight';
  static const String _keyNextFlight = 'app_next_flight';
  static const String _keyPremiumEntitled = 'app_premium_entitled';

  AppSettings getSettings() {
    return AppSettings(
      audioEnabled: _prefs.getBool(_keyAudioEnabled) ?? true,
      hapticsEnabled: _prefs.getBool(_keyHapticsEnabled) ?? true,
      onboardingCompleted: _prefs.getBool(_keyOnboardingCompleted) ?? false,
      selectedAnxietyTriggers:
          _prefs.getStringList(_keySelectedAnxietyTriggers) ?? const [],
      calmingModePreference:
          _prefs.getString(_keyCalmingModePreference) ?? 'guided',
      premiumEntitled: _prefs.getBool(_keyPremiumEntitled) ?? false,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setBool(_keyAudioEnabled, settings.audioEnabled);
    await _prefs.setBool(_keyHapticsEnabled, settings.hapticsEnabled);
    await _prefs.setBool(_keyOnboardingCompleted, settings.onboardingCompleted);
    await _prefs.setStringList(
        _keySelectedAnxietyTriggers, settings.selectedAnxietyTriggers);
    await _prefs.setString(
        _keyCalmingModePreference, settings.calmingModePreference);
    await _prefs.setBool(_keyPremiumEntitled, settings.premiumEntitled);
  }

  FlightSession? getActiveFlight() {
    final flightJson = _prefs.getString(_keyActiveFlight);
    if (flightJson != null) {
      try {
        return FlightSession.fromJson(flightJson);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> saveActiveFlight(FlightSession flight) async {
    await _prefs.setString(_keyActiveFlight, flight.toJson());
  }

  Future<void> clearActiveFlight() async {
    await _prefs.remove(_keyActiveFlight);
  }

  NextFlight? getNextFlight() {
    final source = _prefs.getString(_keyNextFlight);
    if (source == null) return null;
    try {
      return NextFlight.fromJson(source);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveNextFlight(NextFlight flight) =>
      _prefs.setString(_keyNextFlight, flight.toJson());

  Future<void> clearNextFlight() => _prefs.remove(_keyNextFlight);
}
