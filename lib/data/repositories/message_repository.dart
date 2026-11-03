import 'dart:math';
import '../models/models.dart';

class MessageRepository {
  static const List<TurbulenceMessage> _allMessages = [
    // Rational
    TurbulenceMessage(
        id: 'r1',
        category: 'rational',
        text:
            "Turbulence is like bumps on a road — uncomfortable, but expected."),
    TurbulenceMessage(
        id: 'r2',
        category: 'rational',
        text: "Aircraft are built to handle much stronger forces than this."),
    TurbulenceMessage(
        id: 'r3',
        category: 'rational',
        text:
            "Air currents naturally change during flight. This is a normal part of flying."),
    TurbulenceMessage(
        id: 'r4',
        category: 'rational',
        text:
            "The aircraft is safely riding the waves of air, perfectly balanced."),
    // Expert
    TurbulenceMessage(
        id: 'e1',
        category: 'expert',
        text: "Pilots go through turbulence regularly. It’s part of flying."),
    TurbulenceMessage(
        id: 'e2',
        category: 'expert',
        text:
            "The crew is trained for this and knows how to handle it calmly."),
    TurbulenceMessage(
        id: 'e3',
        category: 'expert',
        text: "This is a routine part of many flights."),
    TurbulenceMessage(
        id: 'e4',
        category: 'expert',
        text:
            "Flight instruments continuously ensure the plane's safe orientation."),
    // Body
    TurbulenceMessage(
        id: 'b1',
        category: 'body',
        text: "Try to take a slow breath in… and a longer breath out."),
    TurbulenceMessage(
        id: 'b2', category: 'body', text: "Relax your shoulders if you can."),
    TurbulenceMessage(
        id: 'b3',
        category: 'body',
        text: "Let your body soften with each breath."),
    TurbulenceMessage(
        id: 'b4',
        category: 'body',
        text: "Notice where you are holding tension, and gently release it."),
    // Normalization
    TurbulenceMessage(
        id: 'n1',
        category: 'normalization',
        text: "Many people feel this way during turbulence."),
    TurbulenceMessage(
        id: 'n2',
        category: 'normalization',
        text: "You’re not alone in this moment."),
    TurbulenceMessage(
        id: 'n3', category: 'normalization', text: "This feeling will pass."),
    TurbulenceMessage(
        id: 'n4',
        category: 'normalization',
        text: "It's natural to feel uncomfortable, but you are still safe."),
    // Time
    TurbulenceMessage(
        id: 't1',
        category: 'time',
        text: "This usually lasts only a short time."),
    TurbulenceMessage(
        id: 't2', category: 'time', text: "The flight continues normally."),
    TurbulenceMessage(id: 't3', category: 'time', text: "This will pass."),
    TurbulenceMessage(
        id: 't4',
        category: 'time',
        text: "Minutes pass, and the air will smooth out soon."),
  ];

  TurbulenceMessage getRandomMessage({String? excludeId}) {
    final rand = Random();
    final validMessages = _allMessages.where((m) => m.id != excludeId).toList();
    if (validMessages.isEmpty) return _allMessages.first;
    return validMessages[rand.nextInt(validMessages.length)];
  }

  TurbulenceMessage getStartingMessage() {
    return const TurbulenceMessage(
      id: 'start',
      category: 'intro',
      text: "The aircraft is experiencing turbulence. This is normal and safe.",
    );
  }
}
