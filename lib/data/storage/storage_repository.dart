import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageRepository {
  final SharedPreferences _prefs;

  StorageRepository(this._prefs);

  static const String _keyAudioEnabled = 'app_audio_enabled';
  static const String _keyHapticsEnabled = 'app_haptics_enabled';
  static const String _keyOnboardingCompleted = 'app_onboarding_completed';
  static const String _keyActiveFlight = 'app_active_flight';

  AppSettings getSettings() {
    return AppSettings(
      audioEnabled: _prefs.getBool(_keyAudioEnabled) ?? true,
      hapticsEnabled: _prefs.getBool(_keyHapticsEnabled) ?? true,
      onboardingCompleted: _prefs.getBool(_keyOnboardingCompleted) ?? false,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setBool(_keyAudioEnabled, settings.audioEnabled);
    await _prefs.setBool(_keyHapticsEnabled, settings.hapticsEnabled);
    await _prefs.setBool(_keyOnboardingCompleted, settings.onboardingCompleted);
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
}
