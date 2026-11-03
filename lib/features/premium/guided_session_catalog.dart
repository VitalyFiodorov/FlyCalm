import 'guided_session.dart';

class GuidedSessionCatalog {
  static const flightJourney = GuidedSession(
    id: 'guided_flight_journey',
    title: 'Guided Flight Journey',
    headerTitle: 'Flight Journey',
    subtitle: 'Calm guidance from boarding to arrival',
    iconName: 'flight',
    steps: [
      SessionStep(
        title: 'Before boarding',
        body: 'There is nothing to rush. Get settled one small step at a time.',
        type: SessionStepType.reassurance,
        points: [
          'Keep your calming tools within reach.',
          'Let your shoulders soften.',
          'Notice one familiar thing around you.'
        ],
      ),
      SessionStep(
        title: 'Taxi',
        body:
            'Slow movement, pauses and changing engine sounds are expected while the aircraft taxis.',
        type: SessionStepType.information,
        points: [
          'Feel the seat supporting you.',
          'Keep both feet grounded.',
          'Let the crew guide the pace.'
        ],
      ),
      SessionStep(
        title: 'Takeoff',
        body:
            'Breathe with the acceleration instead of fighting the sensation.',
        type: SessionStepType.breathing,
        points: [
          'Engine sound usually becomes louder.',
          'Pressure against the seat is expected.',
          'The sensation changes as the aircraft climbs.'
        ],
      ),
      SessionStep(
        title: 'Initial climb',
        body:
            'Bring your attention back to the cabin and the support beneath you.',
        type: SessionStepType.grounding,
        points: [
          'Name 3 things you can see.',
          'Notice 2 points of contact with the seat.',
          'Listen for 1 steady cabin sound.'
        ],
      ),
      SessionStep(
        title: 'Cruise',
        body:
            'You can let this part of the journey become smaller in your attention.',
        type: SessionStepType.reassurance,
        points: [
          'Unclench your jaw.',
          'Take a sip of water if you can.',
          'Return to a slow exhale whenever you need it.'
        ],
      ),
      SessionStep(
        title: 'Preparing for descent',
        body:
            'Changes in engine sound and cabin movement can be part of the descent.',
        type: SessionStepType.information,
        points: [
          'Pressure sensations may change.',
          'The crew will prepare the cabin.',
          'You can stay with one calm breath at a time.'
        ],
      ),
      SessionStep(
        title: 'Landing',
        body:
            'Let the exhale be longer while the aircraft approaches the runway.',
        type: SessionStepType.breathing,
        points: [
          'Flaps and landing gear can create new sounds.',
          'Touchdown may feel firm.',
          'Braking and turning sensations are expected.'
        ],
      ),
      SessionStep(
        title: 'You arrived',
        body:
            'The journey is complete. Take a moment to notice what you managed.',
        type: SessionStepType.completion,
      ),
    ],
  );

  static const advancedTurbulence = GuidedSession(
    id: 'advanced_turbulence_session',
    title: 'Advanced Turbulence Session',
    headerTitle: 'Turbulence',
    subtitle: 'A structured sequence for bumpy air',
    iconName: 'air',
    steps: [
      SessionStep(
        title: 'Stay with this moment',
        body:
            'The movement is uncomfortable. You do not need to solve the whole flight right now.',
        type: SessionStepType.reassurance,
      ),
      SessionStep(
        title: 'What you may feel',
        body:
            'Changing air currents can create bumps, small drops and vibration.',
        type: SessionStepType.information,
        points: [
          'Your body may react before your thoughts settle.',
          'Cabin sounds can change with the movement.',
          'The crew handles turbulence as a routine part of flying.'
        ],
      ),
      SessionStep(
        title: 'Slow the breath',
        body:
            'Take a gentle breath in, then give yourself a longer breath out.',
        type: SessionStepType.breathing,
      ),
      SessionStep(
        title: 'Ground in the cabin',
        body:
            'Move your attention from the motion to what is steady around you.',
        type: SessionStepType.grounding,
        points: [
          'Press your feet lightly into the floor.',
          'Notice the seat beneath your legs and back.',
          'Name 3 colours you can see.'
        ],
      ),
      SessionStep(
        title: 'Let the moment pass',
        body:
            'You can feel unsettled and still move through this moment one breath at a time.',
        type: SessionStepType.reassurance,
      ),
      SessionStep(
        title: 'Optional calming audio',
        body:
            'Use the existing turbulence guidance if listening feels helpful right now.',
        type: SessionStepType.audio,
        audioTitle: 'In-Flight Turbulence',
        audioAssetPath: 'audio/Calm Reassuring In-Flight Turbulence.mp3',
      ),
      SessionStep(
        title: 'Session complete',
        body: 'Return whenever you want another guided pass through the steps.',
        type: SessionStepType.completion,
      ),
    ],
  );

  static const structuredPanic = GuidedSession(
    id: 'structured_panic_session',
    title: 'Structured Panic Session',
    headerTitle: 'Panic Support',
    subtitle: 'Step-by-step support when anxiety rises',
    iconName: 'favorite',
    steps: [
      SessionStep(
        title: "You're here",
        body: 'Stay with this screen. Nothing needs to be fixed all at once.',
        type: SessionStepType.reassurance,
      ),
      SessionStep(
        title: 'One slow breath',
        body:
            'Follow the circle. Keep the breath gentle rather than deep or forced.',
        type: SessionStepType.breathing,
      ),
      SessionStep(
        title: 'Reconnect with the cabin',
        body: 'Use your senses to bring attention back to the present moment.',
        type: SessionStepType.grounding,
        points: [
          'Name 5 things you can see.',
          'Notice 4 things you can feel.',
          'Listen for 3 sounds around you.'
        ],
      ),
      SessionStep(
        title: 'Redirect your attention',
        body:
            'Anxiety can make every sensation feel urgent. Choose one neutral detail and describe it silently.',
        type: SessionStepType.information,
        points: [
          'A colour or shape nearby',
          'The texture of the seat',
          'A steady sound in the cabin'
        ],
      ),
      SessionStep(
        title: 'Stabilize',
        body:
            'Let your shoulders drop. Keep the next exhale slow and unhurried.',
        type: SessionStepType.breathing,
      ),
      SessionStep(
        title: 'Recovery',
        body:
            'You moved through the session. Stay seated for a moment and continue gently.',
        type: SessionStepType.completion,
      ),
    ],
  );

  static const all = [flightJourney, advancedTurbulence, structuredPanic];
}
