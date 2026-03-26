import '../models/models.dart';

class FlightEstimatorState {
  final int elapsedSeconds;
  final int remainingSeconds;
  final double progressPercent;
  final FlightPhase currentPhase;

  FlightEstimatorState({
    required this.elapsedSeconds,
    required this.remainingSeconds,
    required this.progressPercent,
    required this.currentPhase,
  });
}

class FlightEstimator {
  static FlightEstimatorState estimate(DateTime departureTime, int durationMinutes, DateTime now) {
    final int totalSeconds = durationMinutes * 60;
    final int elapsedSeconds = now.difference(departureTime).inSeconds;

    if (elapsedSeconds < 0) {
      return FlightEstimatorState(
        elapsedSeconds: 0,
        remainingSeconds: totalSeconds,
        progressPercent: 0.0,
        currentPhase: FlightPhase.takeoff, // Pre-flight can be combined with takeoff
      );
    }

    final int clampedElapsedSeconds = elapsedSeconds > totalSeconds ? totalSeconds : elapsedSeconds;
    final int remainingSeconds = totalSeconds - clampedElapsedSeconds;
    final double percent = clampedElapsedSeconds / totalSeconds;

    FlightPhase phase;
    if (percent < 0.05) {
      phase = FlightPhase.takeoff;
    } else if (percent < 0.15) {
      phase = FlightPhase.climb;
    } else if (percent < 0.80) {
      phase = FlightPhase.cruising;
    } else if (percent < 0.95) {
      phase = FlightPhase.descent;
    } else if (percent < 1.0) {
      phase = FlightPhase.landing;
    } else {
      phase = FlightPhase.completed;
    }

    return FlightEstimatorState(
      elapsedSeconds: clampedElapsedSeconds,
      remainingSeconds: remainingSeconds,
      progressPercent: percent,
      currentPhase: phase,
    );
  }

  static String formatRemainingTime(int seconds) {
    if (seconds <= 0) return "Arrived";
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    
    if (h > 0) {
      return "${h}h ${m}m ${s}s remaining";
    }
    return "${m}m ${s}s remaining";
  }

  static String getPhaseTitle(FlightPhase phase) {
    switch (phase) {
      case FlightPhase.takeoff:
        return "The aircraft is taking off";
      case FlightPhase.climb:
        return "The aircraft is climbing";
      case FlightPhase.cruising:
        return "You’re now at cruising altitude";
      case FlightPhase.descent:
        return "The aircraft is preparing to land";
      case FlightPhase.landing:
        return "The aircraft is landing soon";
      case FlightPhase.completed:
        return "You’ve arrived";
    }
  }

  static String getPhaseSubtitle(FlightPhase phase) {
    switch (phase) {
      case FlightPhase.takeoff:
        return "This is a normal and controlled phase.";
      case FlightPhase.climb:
        return "You may notice changes in engine sound or movement.";
      case FlightPhase.cruising:
        return "This is the smoothest part of the flight.";
      case FlightPhase.descent:
        return "You’re getting closer to your destination.";
      case FlightPhase.landing:
        return "This is a routine part of the flight.";
      case FlightPhase.completed:
        return "Your flight has ended.";
    }
  }
}
