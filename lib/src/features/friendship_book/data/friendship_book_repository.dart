import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/friendship_book_model.dart';

abstract class FriendshipBookRepository {
  Future<FriendshipBookProfile> getFriendshipBookForUser(String userId);
  Future<List<FriendshipBookProfile>> getFriends(String currentUserId);
}

class MockFriendshipBookRepository implements FriendshipBookRepository {
  // Mock-Daten für Freundschaftsbücher
  final Map<String, FriendshipBookProfile> _profiles = {
    'u1': const FriendshipBookProfile(
        userId: 'u1',
        displayName: "Lena",
        avatarLetter: "L",
        tags: ["Seit 2015", "Schulfreundin"], // Tags zeigen jetzt Beziehungs-Status
        entries: [
          FriendshipBookEntry(
              id: '1',
              question: "Unser lustigster gemeinsamer Moment",
              audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
              durationSeconds: 42
          ),
          FriendshipBookEntry(
              id: '2',
              question: "Das schätze ich an dir besonders",
              audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
              durationSeconds: 25
          ),
          FriendshipBookEntry(
              id: '3',
              question: "Ein Song, der mich an dich erinnert",
              audioUrl: null,
              durationSeconds: 0
          ),
          FriendshipBookEntry(
              id: '4',
              question: "Das müssen wir unbedingt mal wieder machen",
              audioUrl: null,
              durationSeconds: 0
          ),
        ]
    ),
    'u2': const FriendshipBookProfile(
        userId: 'u2',
        displayName: "Tom",
        avatarLetter: "T",
        tags: ["Seit 2020", "Arbeitskollege"],
        entries: [
          FriendshipBookEntry(
              id: '1',
              question: "Unser lustigster gemeinsamer Moment",
              audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
              durationSeconds: 15
          ),
          FriendshipBookEntry(
              id: '2',
              question: "Das schätze ich an dir besonders",
              audioUrl: null,
              durationSeconds: 0
          ),
        ]
    ),
    // Mein eigenes Profil
    'current_user_id': const FriendshipBookProfile(
        userId: 'current_user_id',
        displayName: "Ich",
        avatarLetter: "M",
        tags: [],
        entries: []
    ),
  };

  @override
  Future<FriendshipBookProfile> getFriendshipBookForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Wenn die ID nicht existiert, geben wir ein leeres Profil oder den ersten Eintrag zurück (Fallback)
    return _profiles[userId] ?? _profiles.values.first;
  }

  @override
  Future<List<FriendshipBookProfile>> getFriends(String currentUserId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Gib alle Profile zurück, außer das eigene
    return _profiles.values.where((p) => p.userId != 'current_user_id').toList();
  }
}

// --- PROVIDER ---
final friendshipBookRepositoryProvider = Provider<FriendshipBookRepository>((ref) {
  return MockFriendshipBookRepository();
});

final friendshipBookProvider = FutureProvider.family<FriendshipBookProfile, String>((ref, userId) async {
  final repository = ref.watch(friendshipBookRepositoryProvider);
  return repository.getFriendshipBookForUser(userId);
});

final friendsListProvider = FutureProvider<List<FriendshipBookProfile>>((ref) async {
  final repository = ref.watch(friendshipBookRepositoryProvider);
  return repository.getFriends('current_user_id');
});