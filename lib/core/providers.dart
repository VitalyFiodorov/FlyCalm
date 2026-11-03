import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/models.dart';
import '../data/storage/storage_repository.dart';
import '../data/services/audio_service.dart';
import '../data/services/flight_estimator.dart';
import '../data/repositories/message_repository.dart';
import '../data/services/analytics_service.dart';
import '../data/services/purchase_service.dart';

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

  Future<void> updateAnxietyTriggers(List<String> triggers) async {
    state = state.copyWith(selectedAnxietyTriggers: triggers);
    await _storage.saveSettings(state);
  }

  Future<void> updateCalmingPreference(String preference) async {
    state = state.copyWith(calmingModePreference: preference);
    await _storage.saveSettings(state);
  }

  Future<void> resetOnboarding() async {
    state = state.copyWith(
      onboardingCompleted: false,
      selectedAnxietyTriggers: const [],
      calmingModePreference: 'guided',
    );
    await _storage.saveSettings(state);
  }

  Future<void> grantPremium() async {
    state = state.copyWith(premiumEntitled: true);
    await _storage.saveSettings(state);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
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

final flightSessionProvider =
    StateNotifierProvider<FlightSessionNotifier, FlightSession?>((ref) {
  return FlightSessionNotifier(ref.watch(storageRepositoryProvider));
});

class NextFlightNotifier extends StateNotifier<NextFlight?> {
  NextFlightNotifier(this._storage) : super(_storage.getNextFlight());
  final StorageRepository _storage;

  Future<void> save(NextFlight flight) async {
    state = flight;
    await _storage.saveNextFlight(flight);
  }

  Future<void> clear() async {
    state = null;
    await _storage.clearNextFlight();
  }
}

final nextFlightProvider =
    StateNotifierProvider<NextFlightNotifier, NextFlight?>((ref) {
  return NextFlightNotifier(ref.watch(storageRepositoryProvider));
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

final analyticsProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref.watch(sharedPreferencesProvider));
});

class PremiumState {
  const PremiumState(
      {this.loading = true,
      this.storeAvailable = false,
      this.product,
      this.error});
  final bool loading;
  final bool storeAvailable;
  final dynamic product;
  final String? error;
}

class PremiumNotifier extends StateNotifier<PremiumState> {
  PremiumNotifier(this._ref) : super(const PremiumState()) {
    _service = PurchaseService(
      onEntitlementGranted: () =>
          _ref.read(settingsProvider.notifier).grantPremium(),
      onEvent: (name, parameters) =>
          _ref.read(analyticsProvider).log(name, parameters: parameters),
    );
    _initialize();
  }

  final Ref _ref;
  late final PurchaseService _service;

  Future<void> _initialize() async {
    await _service.initialize();
    state = PremiumState(
      loading: false,
      storeAvailable: _service.storeAvailable,
      product: _service.product,
      error: _service.errorMessage,
    );
  }

  Future<bool> buy() => _service.buy();
  Future<void> restore() => _service.restore();
  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

final premiumProvider = StateNotifierProvider<PremiumNotifier, PremiumState>(
    (ref) => PremiumNotifier(ref));
