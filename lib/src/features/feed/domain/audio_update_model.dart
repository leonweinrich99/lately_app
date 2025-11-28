import 'package:flutter/foundation.dart';

class AudioUpdate {
  final String id;
  final String userId;        // Wer hat es aufgenommen?
  final String userDisplayName; // Caching des Namens (spart Reads)
  final String audioUrl;      // Wo liegt die Datei im Storage?
  final int durationSeconds;  // Länge für die Anzeige
  final DateTime createdAt;   // Wann aufgenommen?
  final String? promptId;     // War es eine Antwort auf "Daily 10"?
  final String? promptTitle;  // z.B. "Wofür bist du dankbar?"
  final List<String> visibilityUserIds; // Wer darf das hören? (Granulare Privatsphäre)
  final List<String> likedByUserIds;    // Wer hat ein Herz gegeben?

  const AudioUpdate({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    required this.audioUrl,
    required this.durationSeconds,
    required this.createdAt,
    this.promptId,
    this.promptTitle,
    this.visibilityUserIds = const [],
    this.likedByUserIds = const [],
  });

  // Hilfsmethode für formatierten Zeitstring (z.B. "2:14")
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  factory AudioUpdate.fromMap(Map<String, dynamic> map, String id) {
    return AudioUpdate(
      id: id,
      userId: map['userId'] ?? '',
      userDisplayName: map['userDisplayName'] ?? 'Unbekannt',
      audioUrl: map['audioUrl'] ?? '',
      durationSeconds: map['durationSeconds'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      promptId: map['promptId'],
      promptTitle: map['promptTitle'],
      visibilityUserIds: List<String>.from(map['visibilityUserIds'] ?? []),
      likedByUserIds: List<String>.from(map['likedByUserIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userDisplayName': userDisplayName,
      'audioUrl': audioUrl,
      'durationSeconds': durationSeconds,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'promptId': promptId,
      'promptTitle': promptTitle,
      'visibilityUserIds': visibilityUserIds,
      'likedByUserIds': likedByUserIds,
    };
  }
}