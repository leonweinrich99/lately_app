import 'dart:ui';
import '../domain/challenge_model.dart';

abstract class ChallengeRepository {
  Future<List<Challenge>> getActiveChallenges();
  Future<Challenge?> getChallengeById(String id);
}

class MockChallengeRepository implements ChallengeRepository {
  // Unsere "Datenbank" im Speicher
  final List<Challenge> _mockChallenges = [
    const Challenge(
      id: 'd10',
      title: 'Daily 10',
      subtitle: 'Die 10 Fragen des Tages',
      logo: 'D10',
      bgColorHex: 0xFFE0E8E7,
      textColorHex: 0xFF0F2926,
      questions: [
        "Wofür bist du heute dankbar?",
        "Was war dein Highlight?",
        "Was hat dich genervt?",
        "Wen hast du vermisst?",
        "Was hast du gegessen?",
        "Dein Song des Tages?",
        "Ein Wort für heute?",
        "Was möchtest du morgen tun?",
        "Wer hat dich zum Lachen gebracht?",
        "Energie-Level (1-10)?"
      ],
    ),
    const Challenge(
      id: 'mood',
      title: 'Gefühls-Check',
      subtitle: 'Wie geht es dir wirklich?',
      logo: 'Mood',
      bgColorHex: 0xFFDBC6BE,
      textColorHex: 0xFF2D1B1B,
      questions: [
        "Wie fühlst du dich gerade?",
        "Was brauchst du heute noch?",
        "Was lässt du los?"
      ],
    ),
  ];

  @override
  Future<List<Challenge>> getActiveChallenges() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simuliere Netzwerk
    return _mockChallenges;
  }

  @override
  Future<Challenge?> getChallengeById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockChallenges.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}