import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Privacy-conscious analytics boundary.
///
/// Events are persisted locally first so core flows never depend on a network.
/// A production analytics transport can upload [pendingEvents] when connectivity
/// is available. Parameters are deliberately restricted to non-free-text values.
class AnalyticsService {
  AnalyticsService(this._prefs);

  static const _eventsKey = 'analytics_pending_events_v1';
  static const _firstOpenKey = 'analytics_first_open_at';
  static const _lastOpenKey = 'analytics_last_open_at';
  static const _openCountKey = 'analytics_open_count';
  static const _completedExercisesKey = 'analytics_completed_exercises';

  final SharedPreferences _prefs;

  Future<void> trackAppOpen() async {
    final now = DateTime.now();
    final previousOpen = _prefs.getString(_lastOpenKey);
    final openCount = (_prefs.getInt(_openCountKey) ?? 0) + 1;
    await _prefs.setString(_firstOpenKey,
        _prefs.getString(_firstOpenKey) ?? now.toIso8601String());
    await _prefs.setString(_lastOpenKey, now.toIso8601String());
    await _prefs.setInt(_openCountKey, openCount);
    await log(
      'app_open',
      parameters: {
        'returning_user': previousOpen != null,
        'open_count': openCount,
      },
    );
  }

  Future<void> log(String name,
      {Map<String, Object?> parameters = const {}}) async {
    assert(RegExp(r'^[a-z][a-z0-9_]{1,39}$').hasMatch(name));
    final safeParameters = <String, Object?>{};
    for (final entry in parameters.entries) {
      final value = entry.value;
      if (value == null || value is bool || value is num || value is String) {
        safeParameters[entry.key] = value;
      }
    }
    final events = pendingEvents;
    events.add({
      'name': name,
      'occurred_at': DateTime.now().toUtc().toIso8601String(),
      'parameters': safeParameters,
    });
    // Bound storage while preserving enough history to diagnose the funnel.
    final bounded =
        events.length > 500 ? events.sublist(events.length - 500) : events;
    await _prefs.setStringList(_eventsKey, bounded.map(jsonEncode).toList());
    if (kDebugMode) debugPrint('FlyCalm analytics: $name $safeParameters');
  }

  List<Map<String, dynamic>> get pendingEvents =>
      _prefs
          .getStringList(_eventsKey)
          ?.map((event) => Map<String, dynamic>.from(jsonDecode(event) as Map))
          .toList() ??
      <Map<String, dynamic>>[];

  Future<void> markExerciseCompleted(String exercise) async {
    final completed = (_prefs.getInt(_completedExercisesKey) ?? 0) + 1;
    await _prefs.setInt(_completedExercisesKey, completed);
    await log('${exercise}_completed',
        parameters: {'completed_exercises': completed});
  }

  int get completedExercises => _prefs.getInt(_completedExercisesKey) ?? 0;
}
