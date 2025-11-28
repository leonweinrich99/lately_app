import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/audio_update_model.dart';
import 'feed_repository.dart';

// Dieser Provider gibt uns Zugriff auf das Repository.
// Später tauschen wir hier einfach "MockFeedRepository" gegen "FirebaseFeedRepository".
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return MockFeedRepository();
});

// Dieser Provider lädt die Updates für den aktuellen User.
// UI Widgets hören auf diesen Provider.
final feedUpdatesProvider = FutureProvider<List<AudioUpdate>>((ref) async {
  final repository = ref.watch(feedRepositoryProvider);
  // Hardcoded User ID für Entwicklung
  return repository.getUpdatesForUser('current_user_id');
});