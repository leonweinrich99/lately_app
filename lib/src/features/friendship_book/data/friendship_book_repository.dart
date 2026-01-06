import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/friendship_book_model.dart';

abstract class FriendshipBookRepository {
  Future<FriendshipBookProfile> getFriendshipBookForUser(String userId);
  Future<List<FriendshipBookProfile>> getFriends(String currentUserId);
  Future<void> addQuestion(String userId, String question);
  Future<void> addAnswer(String userId, String question, String audioUrl, int duration); // NEU
}

class MockFriendshipBookRepository implements FriendshipBookRepository {
  // --- 10 STANDARD FRAGEN ---
  static const List<String> _standardQuestions = [
    "Unser lustigster gemeinsamer Moment",
    "Das schätze ich an dir besonders",
    "Ein Song, der mich an dich erinnert",
    "Das müssen wir unbedingt mal wieder machen",
    "Dein größtes Talent",
    "Was bringt dich immer zum Lachen?",
    "Ein Ort, an den wir reisen müssen",
    "Dein Lieblingsessen",
    "Eine Eigenschaft, die ich gerne von dir hätte",
    "Wie haben wir uns kennengelernt?"
  ];

  final Map<String, FriendshipBookProfile> _profiles = {};

  MockFriendshipBookRepository() {
    _initMockData();
  }

  void _initMockData() {
    List<FriendshipBookEntry> createStandardEntries() {
      return _standardQuestions.asMap().entries.map((e) =>
          FriendshipBookEntry(
              id: 'std_${e.key}',
              question: e.value,
              audioUrl: null,
              durationSeconds: 0
          )
      ).toList();
    }

    var lenaEntries = createStandardEntries();
    lenaEntries[0] = FriendshipBookEntry(id: 'std_0', question: _standardQuestions[0], audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3', durationSeconds: 42);
    lenaEntries[1] = FriendshipBookEntry(id: 'std_1', question: _standardQuestions[1], audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3', durationSeconds: 25);

    _profiles['u1'] = FriendshipBookProfile(
        userId: 'u1', displayName: "Lena", avatarLetter: "L", tags: ["Seit 2015", "Schulfreundin"],
        entries: lenaEntries
    );

    var tomEntries = createStandardEntries();
    tomEntries[0] = FriendshipBookEntry(id: 'std_0', question: _standardQuestions[0], audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3', durationSeconds: 15);

    _profiles['u2'] = FriendshipBookProfile(
        userId: 'u2', displayName: "Tom", avatarLetter: "T", tags: ["Seit 2020", "Arbeitskollege"],
        entries: tomEntries
    );

    _profiles['current_user_id'] = FriendshipBookProfile(
        userId: 'current_user_id', displayName: "Ich", avatarLetter: "M", tags: [],
        entries: createStandardEntries()
    );
  }

  @override
  Future<FriendshipBookProfile> getFriendshipBookForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _profiles[userId] ?? _profiles.values.first;
  }

  @override
  Future<List<FriendshipBookProfile>> getFriends(String currentUserId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _profiles.values.where((p) => p.userId != 'current_user_id').toList();
  }

  @override
  Future<void> addQuestion(String userId, String question) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final profile = _profiles[userId];
    if (profile != null) {
      final newEntry = FriendshipBookEntry(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        question: question,
      );
      final newEntries = List<FriendshipBookEntry>.from(profile.entries)..add(newEntry);
      _profiles[userId] = FriendshipBookProfile(
        userId: profile.userId, displayName: profile.displayName, avatarLetter: profile.avatarLetter, tags: profile.tags, entries: newEntries,
      );
    }
  }

  // NEU: Antwort speichern
  @override
  Future<void> addAnswer(String userId, String question, String audioUrl, int duration) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final profile = _profiles[userId];
    if (profile != null) {
      // Wir suchen den Eintrag anhand der Frage und updaten ihn
      final newEntries = profile.entries.map((entry) {
        if (entry.question == question) {
          return FriendshipBookEntry(
            id: entry.id,
            question: entry.question,
            audioUrl: audioUrl,
            durationSeconds: duration,
          );
        }
        return entry;
      }).toList();

      _profiles[userId] = FriendshipBookProfile(
          userId: profile.userId,
          displayName: profile.displayName,
          avatarLetter: profile.avatarLetter,
          tags: profile.tags,
          entries: newEntries
      );
    }
  }
}

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