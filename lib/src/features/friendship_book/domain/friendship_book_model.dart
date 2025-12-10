// Umbenannt von ProfileEntry zu FriendshipBookEntry
class FriendshipBookEntry {
  final String id;
  final String question; // z.B. "Mein aktueller Ohrwurm"
  final String? audioUrl; // URL zur Aufnahme (null = nicht beantwortet)
  final int durationSeconds; // Dauer der Aufnahme

  const FriendshipBookEntry({
    required this.id,
    required this.question,
    this.audioUrl,
    this.durationSeconds = 0,
  });

  bool get hasAnswer => audioUrl != null;

  String get formattedDuration {
    if (!hasAnswer) return "";
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

// Umbenannt von FriendProfile zu FriendshipBookProfile
// Repräsentiert eine SEITE in einem Freundebuch
class FriendshipBookProfile {
  final String userId;
  final String displayName;
  final String avatarLetter; // z.B. "M"
  final List<String> tags; // z.B. ["Musikliebhaber", "Kaffeefan"]
  final List<FriendshipBookEntry> entries;

  const FriendshipBookProfile({
    required this.userId,
    required this.displayName,
    required this.avatarLetter,
    this.tags = const [],
    this.entries = const [],
  });
}