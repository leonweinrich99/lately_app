import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/audio_update_model.dart';
import '../domain/challenge_model.dart';
import 'feed_repository.dart';
import 'challenge_repository.dart'; // Falls du das Challenge Repo hier hast

// --- FEED REPOSITORY PROVIDER ---
// Jetzt ein StateNotifierProvider, damit wir auf Änderungen hören und Methoden aufrufen können
final feedRepositoryProvider = StateNotifierProvider<FeedRepository, List<AudioUpdate>>((ref) {
  return FeedRepository();
});

// Dieser Provider liefert einfach den aktuellen Zustand (die Liste)
final feedUpdatesProvider = Provider<AsyncValue<List<AudioUpdate>>>((ref) {
  final updates = ref.watch(feedRepositoryProvider);
  // Wir wrappen es in AsyncData, damit das UI nicht umgebaut werden muss
  return AsyncData(updates);
});

// --- CHALLENGE REPOSITORY (Bleibt gleich) ---
final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return MockChallengeRepository();
});

final activeChallengesProvider = FutureProvider<List<Challenge>>((ref) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getActiveChallenges();
});

final challengeByIdProvider = FutureProvider.family<Challenge?, String>((ref, id) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getChallengeById(id);
});