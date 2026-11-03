enum SessionStepType {
  reassurance,
  information,
  breathing,
  grounding,
  audio,
  completion,
}

class SessionStep {
  const SessionStep({
    required this.title,
    required this.body,
    required this.type,
    this.points = const [],
    this.audioTitle,
    this.audioAssetPath,
  });

  final String title;
  final String body;
  final SessionStepType type;
  final List<String> points;
  final String? audioTitle;
  final String? audioAssetPath;
}

class GuidedSession {
  const GuidedSession({
    required this.id,
    required this.title,
    required this.headerTitle,
    required this.subtitle,
    required this.iconName,
    required this.steps,
  });

  final String id;
  final String title;
  final String headerTitle;
  final String subtitle;
  final String iconName;
  final List<SessionStep> steps;
}
