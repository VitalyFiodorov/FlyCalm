import 'dart:convert';

enum FlightPhase {
  takeoff,
  climb,
  cruising,
  descent,
  landing,
  completed,
}

class FlightSession {
  final String id;
  final String fromCity;
  final String toCity;
  final DateTime departureTime;
  final int durationMinutes;
  final DateTime createdAt;
  final bool isActive;

  FlightSession({
    required this.id,
    required this.fromCity,
    required this.toCity,
    required this.departureTime,
    required this.durationMinutes,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromCity': fromCity,
      'toCity': toCity,
      'departureTime': departureTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory FlightSession.fromMap(Map<String, dynamic> map) {
    return FlightSession(
      id: map['id'],
      fromCity: map['fromCity'],
      toCity: map['toCity'],
      departureTime: DateTime.parse(map['departureTime']),
      durationMinutes: map['durationMinutes'],
      createdAt: DateTime.parse(map['createdAt']),
      isActive: map['isActive'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());
  factory FlightSession.fromJson(String source) =>
      FlightSession.fromMap(json.decode(source));

  FlightSession copyWith({
    String? id,
    String? fromCity,
    String? toCity,
    DateTime? departureTime,
    int? durationMinutes,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return FlightSession(
      id: id ?? this.id,
      fromCity: fromCity ?? this.fromCity,
      toCity: toCity ?? this.toCity,
      departureTime: departureTime ?? this.departureTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class AppSettings {
  final bool audioEnabled;
  final bool hapticsEnabled;
  final bool onboardingCompleted;
  final List<String> selectedAnxietyTriggers;
  final String calmingModePreference;
  final bool premiumEntitled;

  AppSettings({
    this.audioEnabled = true,
    this.hapticsEnabled = true,
    this.onboardingCompleted = false,
    this.selectedAnxietyTriggers = const [],
    this.calmingModePreference = 'guided',
    this.premiumEntitled = false,
  });

  AppSettings copyWith({
    bool? audioEnabled,
    bool? hapticsEnabled,
    bool? onboardingCompleted,
    List<String>? selectedAnxietyTriggers,
    String? calmingModePreference,
    bool? premiumEntitled,
  }) {
    return AppSettings(
      audioEnabled: audioEnabled ?? this.audioEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      selectedAnxietyTriggers:
          selectedAnxietyTriggers ?? this.selectedAnxietyTriggers,
      calmingModePreference:
          calmingModePreference ?? this.calmingModePreference,
      premiumEntitled: premiumEntitled ?? this.premiumEntitled,
    );
  }
}

class NextFlight {
  const NextFlight({
    required this.date,
    this.departureTime,
    this.origin = '',
    this.destination = '',
  });

  final DateTime date;
  final String? departureTime;
  final String origin;
  final String destination;

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'departureTime': departureTime,
        'origin': origin,
        'destination': destination,
      };

  String toJson() => jsonEncode(toMap());

  factory NextFlight.fromJson(String source) {
    final map = Map<String, dynamic>.from(jsonDecode(source) as Map);
    return NextFlight(
      date: DateTime.parse(map['date'] as String),
      departureTime: map['departureTime'] as String?,
      origin: map['origin'] as String? ?? '',
      destination: map['destination'] as String? ?? '',
    );
  }

  int daysUntil(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final flightDay = DateTime(date.year, date.month, date.day);
    return flightDay.difference(today).inDays;
  }

  String countdownLabel(DateTime now) {
    final days = daysUntil(now);
    if (days < 0) return 'Flight date passed';
    if (days == 0) return 'Your flight is today';
    if (days == 1) return 'Your flight is tomorrow';
    return '$days days until your flight';
  }

  String preparationStage(DateTime now) {
    final days = daysUntil(now);
    if (days <= 0) return 'Your FlyCalm tools are ready';
    if (days == 1) return 'Get ready for tomorrow';
    if (days <= 3) return 'Prepare your personal flight plan';
    if (days <= 7) return 'Practice your calming technique';
    return 'Understand what happens during a flight';
  }
}

class TurbulenceMessage {
  final String id;
  final String category;
  final String text;

  const TurbulenceMessage({
    required this.id,
    required this.category,
    required this.text,
  });
}

class CalmAudioTrack {
  final String id;
  final String title;
  final String assetPath;
  final int durationSeconds;

  const CalmAudioTrack({
    required this.id,
    required this.title,
    required this.assetPath,
    required this.durationSeconds,
  });
}
