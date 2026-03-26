import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/models.dart';
import '../data/storage/storage_repository.dart';
import '../data/services/audio_service.dart';
import '../data/services/flight_estimator.dart';
import '../data/repositories/message_repository.dart';

// Storage Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialized in main');
});

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository(ref.watch(sharedPreferencesProvider));
});

// Settings Provider
class SettingsNotifier extends StateNotifier<AppSettings> {
  final StorageRepository _storage;

  SettingsNotifier(this._storage) : super(_storage.getSettings());

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingCompleted: true);
    await _storage.saveSettings(state);
  }

  Future<void> toggleAudio(bool enabled) async {
    state = state.copyWith(audioEnabled: enabled);
    await _storage.saveSettings(state);
  }

  Future<void> toggleHaptics(bool enabled) async {
    state = state.copyWith(hapticsEnabled: enabled);
    await _storage.saveSettings(state);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.watch(storageRepositoryProvider));
});

// Flight Session Provider
class FlightSessionNotifier extends StateNotifier<FlightSession?> {
  final StorageRepository _storage;

  FlightSessionNotifier(this._storage) : super(_storage.getActiveFlight());

  Future<void> setFlight(FlightSession flight) async {
    state = flight;
    await _storage.saveActiveFlight(flight);
  }

  Future<void> clearFlight() async {
    state = null;
    await _storage.clearActiveFlight();
  }
}

final flightSessionProvider = StateNotifierProvider<FlightSessionNotifier, FlightSession?>((ref) {
  return FlightSessionNotifier(ref.watch(storageRepositoryProvider));
});

// Flight Estimator Stream Provider
final flightEstimatorProvider = StreamProvider<FlightEstimatorState>((ref) {
  final session = ref.watch(flightSessionProvider);
  if (session == null) {
    return Stream.value(FlightEstimatorState(
      elapsedSeconds: 0,
      remainingSeconds: 0,
      progressPercent: 0,
      currentPhase: FlightPhase.takeoff,
    ));
  }

  return Stream.periodic(const Duration(seconds: 1), (_) {
    return FlightEstimator.estimate(
      session.departureTime,
      session.durationMinutes,
      DateTime.now(),
    );
  }).startWith(FlightEstimator.estimate(
    session.departureTime,
    session.durationMinutes,
    DateTime.now(),
  ));
});

extension StreamExt<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}

// Services
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository();
});
