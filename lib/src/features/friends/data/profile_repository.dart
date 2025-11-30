import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/profile_model.dart';

abstract class ProfileRepository {
  Future<FriendProfile> getProfile(String userId);
}

class MockProfileRepository implements ProfileRepository {
  @override
  Future<FriendProfile> getProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simuliere Netzwerk

    return FriendProfile(
      userId: userId,
      displayName: "Max Mustermann",
      avatarLetter: "M",
      tags: ["🎵 Musikliebhaber", "☕ Kaffeefan"],
      entries: [
        ProfileEntry(
            id: '1',
            question: "Mein aktueller Ohrwurm",
            audioUrl: 'dummy_url_1',
            durationSeconds: 15
        ),
        ProfileEntry(
            id: '2',
            question: "Das bringt mich zum Lachen",
            audioUrl: 'dummy_url_2',
            durationSeconds: 32
        ),
        ProfileEntry(
            id: '3',
            question: "Mein Ziel für dieses Jahr",
            audioUrl: null, // Nicht beantwortet
            durationSeconds: 0
        ),
      ],
    );
  }
}

// --- PROVIDER ---
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return MockProfileRepository();
});

// Liefert das Profil des aktuellen Users (oder eines Freundes, wenn ID übergeben wird)
final userProfileProvider = FutureProvider.family<FriendProfile, String>((ref, userId) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getProfile(userId);
});