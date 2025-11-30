import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/audio_update_model.dart';

// Wir nutzen jetzt einen Notifier, um Daten auch verändern zu können
class FeedRepository extends StateNotifier<List<AudioUpdate>> {
  FeedRepository() : super([]) {
    // Initiale Mock-Daten laden
    _loadMockData();
  }

  Future<void> _loadMockData() async {
    await Future.delayed(const Duration(seconds: 1));
    state = [
      AudioUpdate(
        id: '1', userId: 'u1', userDisplayName: 'Lena',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        durationSeconds: 134,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        promptTitle: "Gedanken zum Sonntag",
      ),
      AudioUpdate(
        id: '2', userId: 'u2', userDisplayName: 'Tom',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        durationSeconds: 45,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        promptTitle: "Kurzes Life-Update",
      ),
    ];
  }

  // Methode zum Hinzufügen eines neuen Updates
  void addUpdate(AudioUpdate update) {
    // Fügt das neue Update ganz oben in die Liste ein
    state = [update, ...state];
  }

  // Methode zum Abrufen (für den Provider)
  List<AudioUpdate> getUpdates() {
    return state;
  }
}