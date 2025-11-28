// Ein robustes Model für einen Benutzer
class AppUser {
  final String uid;          // Eindeutige ID (vom Auth Provider)
  final String displayName;  // z.B. "Tom"
  final String? avatarUrl;   // URL zum Profilbild (nullable)
  final String? bioAudioUrl; // URL zur Vorstellung (Freundebuch)
  final List<String> friendIds; // Liste der Freunde (IDs)

  const AppUser({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    this.bioAudioUrl,
    this.friendIds = const [],
  });

  // Factory um Daten später aus Firebase (JSON/Map) zu laden
  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      uid: id,
      displayName: map['displayName'] ?? '',
      avatarUrl: map['avatarUrl'],
      bioAudioUrl: map['bioAudioUrl'],
      friendIds: List<String>.from(map['friendIds'] ?? []),
    );
  }

  // Um Daten ZU Firebase zu senden
  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bioAudioUrl': bioAudioUrl,
      'friendIds': friendIds,
    };
  }
}