import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/services/audio_player_service.dart';
import '../../friendship_book/data/friendship_book_repository.dart';
import '../../friendship_book/domain/friendship_book_model.dart';
import '../../feed/domain/challenge_model.dart'; // Für den Recorder-Kontext
import '../../recorder/presentation/record_screen.dart';

class FriendshipBookScreen extends ConsumerWidget {
  final String userId;
  final bool isMe;

  const FriendshipBookScreen({
    super.key,
    required this.userId,
  }) : isMe = userId == 'current_user_id';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Wir laden das Profil des FREUNDES
    final friendBookAsync = ref.watch(friendshipBookProvider(userId));
    // 2. Wir laden MEIN Profil (um meine Antworten zu sehen)
    final myBookAsync = ref.watch(friendshipBookProvider('current_user_id'));

    final audioState = ref.watch(audioPlayerProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          // Hintergrund
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.0,
                colors: [AppColors.bgSurface, AppColors.bgDeep],
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 120),
            child: friendBookAsync.when(
              data: (friendProfile) => myBookAsync.when(
                data: (myProfile) => Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- HEADER: "UNSER FREUNDEBUCH" ---
                    if (!isMe) ...[
                      _buildConnectionHeader(friendProfile),
                      const SizedBox(height: 30),
                      Text(
                        "Unser Freundebuch",
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Eure gemeinsamen Erinnerungen",
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textDim
                        ),
                      ),
                    ] else ...[
                      // Fallback, falls ich mein eigenes Buch ansehe (sollte eigentlich über ProfileScreen laufen)
                      Text("Mein Freundebuch", style: GoogleFonts.playfairDisplay(fontSize: 32, color: AppColors.textLight)),
                    ],

                    const SizedBox(height: 40),

                    // --- DIE FRAGEN (DU vs. ICH) ---
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: friendProfile.entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final friendEntry = friendProfile.entries[index];
                        // Finde den passenden Eintrag in meinem Buch (basierend auf ID oder Index)
                        // Da Mock-Daten evtl. unterschiedliche IDs haben, nehmen wir hier sicherheitshalber den Index oder suchen nach ID
                        final myEntry = myProfile.entries.firstWhere(
                                (e) => e.id == friendEntry.id,
                            orElse: () => FriendshipBookEntry(id: 'temp', question: friendEntry.question) // Leerer Dummy
                        );

                        return _buildSharedEntryCard(
                            context,
                            question: friendEntry.question,
                            friendEntry: friendEntry,
                            myEntry: myEntry,
                            friendName: friendProfile.displayName,
                            ref: ref,
                            audioState: audioState
                        );
                      },
                    ),
                  ],
                ),
                loading: () => const SizedBox(), // Warten auf MyProfile
                error: (e, _) => const SizedBox(),
              ),
              loading: () => const Center(child: Padding(padding: EdgeInsets.only(top: 100), child: CircularProgressIndicator(color: AppColors.accent))),
              error: (err, _) => Center(child: Text("Fehler", style: TextStyle(color: AppColors.alert))),
            ),
          ),

          // Back Button
          if (!isMe)
            Positioned(
              top: 50, left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: GlassContainer(
                  width: 40, height: 40, borderRadius: 12, padding: EdgeInsets.zero,
                  child: const Center(child: Icon(LucideIcons.chevronLeft, color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- HEADER MIT VERBINDUNG ---
  Widget _buildConnectionHeader(FriendshipBookProfile friendProfile) {
    return SizedBox(
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Verbindung
          Container(
            width: 80, height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), AppColors.accent, Colors.white.withOpacity(0.1)]),
            ),
          ),
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(color: AppColors.bgDeep, shape: BoxShape.circle, border: Border.all(color: AppColors.accent)),
            child: const Icon(LucideIcons.heart, size: 10, color: AppColors.accent),
          ),
          // Avatare
          Positioned(left: 0, child: _buildSmallAvatar("I", "Ich")),
          Positioned(right: 0, child: _buildSmallAvatar(friendProfile.avatarLetter, friendProfile.displayName)),
        ],
      ),
    );
  }

  Widget _buildSmallAvatar(String letter, String label) {
    return Column(
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: AppColors.bgSurface, shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
          ),
          child: Center(child: Text(letter, style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textLight))),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textDim)),
      ],
    );
  }

  // --- DIE FRAGE-KARTE (DUAL VIEW) ---
  Widget _buildSharedEntryCard(
      BuildContext context, {
        required String question,
        required FriendshipBookEntry friendEntry,
        required FriendshipBookEntry myEntry,
        required String friendName,
        required WidgetRef ref,
        required AudioState audioState,
      }) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      // Subtiler Rahmen für Hochwertigkeit
      borderColor: Colors.white.withOpacity(0.05),
      child: Column(
        children: [
          // 1. Die Frage
          Text(
            question,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
                height: 1.3
            ),
          ),

          const SizedBox(height: 24),

          // 2. Die zwei Seiten (Split View)
          Row(
            children: [
              // --- MEINE SEITE ---
              Expanded(
                child: _buildPlayerOrRecorder(
                  context,
                  entry: myEntry,
                  isMe: true,
                  name: "Ich",
                  ref: ref,
                  audioState: audioState,
                ),
              ),

              // Trennlinie
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 12)),

              // --- FREUNDES SEITE ---
              Expanded(
                child: _buildPlayerOrRecorder(
                  context,
                  entry: friendEntry,
                  isMe: false,
                  name: friendName,
                  ref: ref,
                  audioState: audioState,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerOrRecorder(
      BuildContext context, {
        required FriendshipBookEntry entry,
        required bool isMe,
        required String name,
        required WidgetRef ref,
        required AudioState audioState,
      }) {
    // Wenn eine Antwort da ist -> Play Button
    if (entry.hasAnswer) {
      final isPlaying = audioState.playingUrl == entry.audioUrl && audioState.isPlaying;

      return GestureDetector(
        onTap: () { if(entry.audioUrl != null) ref.read(audioPlayerProvider.notifier).toggle(entry.audioUrl!); },
        child: Column(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPlaying ? AppColors.accent : Colors.white.withOpacity(0.05),
                border: Border.all(color: isPlaying ? AppColors.accent : Colors.white.withOpacity(0.1)),
              ),
              child: Icon(
                  isPlaying ? LucideIcons.pause : LucideIcons.play,
                  color: isPlaying ? AppColors.bgDeep : AppColors.textLight,
                  size: 20
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Von $name",
              style: GoogleFonts.inter(fontSize: 10, color: AppColors.textDim),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    // Wenn KEINE Antwort da ist
    else {
      // Wenn ich es bin -> Aufnahme Button
      if (isMe) {
        return GestureDetector(
          onTap: () {
            // Öffne Recorder für diese spezifische Frage
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RecordScreen(
                  // Wir erstellen on-the-fly eine "Mini-Challenge" für diese Frage
                  challenge: Challenge(
                    id: 'single_q_${entry.id}',
                    title: "Freundebuch",
                    subtitle: "Deine Antwort",
                    logo: "FB",
                    questions: [entry.question],
                    bgColorHex: 0xFF1A403C,
                    textColorHex: 0xFFE8F7F6,
                  ),
                ),
              ),
            );
          },
          child: Column(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgDeep, // Dunkel
                  border: Border.all(color: AppColors.textDim.withOpacity(0.3), style: BorderStyle.solid),
                ),
                child: const Icon(LucideIcons.mic, color: AppColors.accent, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                "Antworten",
                style: GoogleFonts.inter(fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }

      // Wenn es der Freund ist -> "Wartet..." Anzeige
      else {
        return Column(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Icon(LucideIcons.clock, color: AppColors.textDim.withOpacity(0.3), size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              "Noch offen",
              style: GoogleFonts.inter(fontSize: 10, color: AppColors.textDim.withOpacity(0.5)),
            ),
          ],
        );
      }
    }
  }
}