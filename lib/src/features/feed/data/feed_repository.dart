import '../domain/audio_update_model.dart';

// 1. Die abstrakte Schnittstelle (Der Vertrag)
// Jedes Repository (egal ob Fake oder Echt) muss diese Methoden haben.
abstract class FeedRepository {
  Future<List<AudioUpdate>> getUpdatesForUser(String currentUserId);
  Future<void> likeUpdate(String updateId, String userId);
}

// 2. Die Mock-Implementierung (Für die Entwicklung JETZT)
// Damit können wir arbeiten, als hätten wir ein Backend, ohne eines zu haben.
class MockFeedRepository implements FeedRepository {
  @override
  Future<List<AudioUpdate>> getUpdatesForUser(String currentUserId) async {
    // Simuliert Netzwerk-Ladezeit für realistisches Feeling
    await Future.delayed(const Duration(seconds: 1));

    return [
      AudioUpdate(
        id: '1',
        userId: 'u1',
        userDisplayName: 'Lena',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', // Echte URL zum Testen
        durationSeconds: 134,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        promptTitle: "Gedanken zum Sonntag",
      ),
      AudioUpdate(
        id: '2',
        userId: 'u2',
        userDisplayName: 'Tom',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        durationSeconds: 45,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        promptTitle: "Kurzes Life-Update",
      ),
      AudioUpdate(
        id: '3',
        userId: 'u3',
        userDisplayName: 'Oma Renate',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        durationSeconds: 270,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  Future<void> likeUpdate(String updateId, String userId) async {
    print("User $userId liked update $updateId (Mock Backend Call)");
    await Future.delayed(const Duration(milliseconds: 300));
  }
}