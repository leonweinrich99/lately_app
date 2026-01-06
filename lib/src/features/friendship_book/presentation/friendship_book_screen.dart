import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/tactile_button.dart';
import '../../../core/services/audio_player_service.dart';
import '../../friendship_book/data/friendship_book_repository.dart';
import '../../friendship_book/domain/friendship_book_model.dart';
import '../../feed/domain/challenge_model.dart';
import '../../recorder/presentation/record_screen.dart';

class FriendshipBookScreen extends ConsumerWidget {
  final String userId;
  final bool isMe;

  const FriendshipBookScreen({
    super.key,
    required this.userId,
  }) : isMe = userId == 'current_user_id';

  // --- LOGIK: NEUE FRAGE HINZUFÜGEN ---
  void _showAddQuestionDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.white.withOpacity(0.1))),
        title: Text("Neue Frage", style: GoogleFonts.playfairDisplay(color: AppColors.textLight, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: textController,
          style: GoogleFonts.inter(color: AppColors.textLight),
          decoration: InputDecoration(
            hintText: "Was möchtest du fragen?",
            hintStyle: GoogleFonts.inter(color: AppColors.textDim),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textDim)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accent)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Abbrechen", style: GoogleFonts.inter(color: AppColors.textDim)),
          ),
          TextButton(
            onPressed: () async {
              if (textController.text.isNotEmpty) {
                // 1. Speichern im Repository
                await ref.read(friendshipBookRepositoryProvider).addQuestion(userId, textController.text);
                // 2. UI aktualisieren (Provider neu laden)
                ref.invalidate(friendshipBookProvider(userId));
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text("Hinzufügen", style: GoogleFonts.inter(color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wir laden BEIDE Profile: Das des Freundes und mein eigenes
    final friendBookAsync = ref.watch(friendshipBookProvider(userId));
    final myBookAsync = ref.watch(friendshipBookProvider('current_user_id'));

    final audioState = ref.watch(audioPlayerProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          // Globaler Hintergrund
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
                  children: [
                    // --- HEADER BEREICH ---
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
                      // Fallback falls man fälschlicherweise hier landet
                      Text("Mein Freundebuch", style: GoogleFonts.playfairDisplay(fontSize: 32, color: AppColors.textLight)),
                    ],

                    const SizedBox(height: 40),

                    // --- FRAGEN LISTE ---
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: friendProfile.entries.length + 1, // +1 für den "Hinzufügen"-Button
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        // Der Button ganz unten
                        if (index == friendProfile.entries.length) {
                          return _buildAddQuestionButton(context, ref);
                        }

                        final friendEntry = friendProfile.entries[index];

                        // Finde den passenden Eintrag in MEINEM Buch (über die Frage)
                        final myEntry = myProfile.entries.firstWhere(
                                (e) => e.question == friendEntry.question,
                            orElse: () => FriendshipBookEntry(id: friendEntry.id, question: friendEntry.question)
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
                loading: () => const SizedBox(),
                error: (e, _) => const SizedBox(),
              ),
              loading: () => const Center(
                  child: Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: CircularProgressIndicator(color: AppColors.accent)
                  )
              ),
              error: (err, _) => Center(child: Text("Fehler", style: TextStyle(color: AppColors.alert))),
            ),
          ),

          // Back Button (Nur wenn wir bei einem Freund sind)
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

  // --- WIDGETS ---

  // 1. Header mit Verbindungslinie
  Widget _buildConnectionHeader(FriendshipBookProfile friendProfile) {
    return SizedBox(
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Linie
          Container(
            width: 80, height: 2,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), AppColors.accent, Colors.white.withOpacity(0.1)])
            ),
          ),
          // Herz-Icon
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(color: AppColors.bgDeep, shape: BoxShape.circle, border: Border.all(color: AppColors.accent)),
            child: const Icon(LucideIcons.heart, size: 10, color: AppColors.accent),
          ),
          // Avatare Links & Rechts
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
          child: Center(
              child: Text(letter, style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textLight))
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textDim)),
      ],
    );
  }

  // 2. Die Karte mit der Frage und zwei Seiten
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
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      borderColor: Colors.white.withOpacity(0.05),
      child: Column(
        children: [
          // Die Frage oben
          Text(
            question,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
                fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textLight, height: 1.3
            ),
          ),

          const SizedBox(height: 24),

          // Split View
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // --- MEINE SEITE ---
              _buildSideAction(
                context,
                hasAnswer: myEntry.hasAnswer,
                audioUrl: myEntry.audioUrl,
                isMe: true, // Das bin ich
                label: "Meine Antwort",
                ref: ref,
                audioState: audioState,
                questionText: question,
              ),

              // Vertikale Linie
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),

              // --- FREUNDES SEITE ---
              _buildSideAction(
                context,
                hasAnswer: friendEntry.hasAnswer,
                audioUrl: friendEntry.audioUrl,
                isMe: false, // Das ist der Freund
                label: friendName,
                ref: ref,
                audioState: audioState,
                questionText: question,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Logik für die einzelnen Buttons (Play, Record, Warten)
  Widget _buildSideAction(
      BuildContext context, {
        required bool hasAnswer,
        String? audioUrl,
        required bool isMe,
        required String label,
        required WidgetRef ref,
        required AudioState audioState,
        required String questionText,
      }) {
    // FALL 1: Antwort existiert -> Abspielen
    if (hasAnswer) {
      final isPlaying = audioUrl != null && audioState.playingUrl == audioUrl && audioState.isPlaying;

      return Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () { if(audioUrl != null) ref.read(audioPlayerProvider.notifier).toggle(audioUrl); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPlaying ? AppColors.accent : Colors.white.withOpacity(0.05),
                    border: Border.all(color: isPlaying ? AppColors.accent : Colors.white.withOpacity(0.1)),
                    boxShadow: isPlaying ? [BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 15)] : [],
                  ),
                  child: Icon(
                      isPlaying ? LucideIcons.pause : LucideIcons.play,
                      color: isPlaying ? AppColors.bgDeep : AppColors.textLight,
                      size: 24
                  ),
                ),
              ),
              // Option zum Bearbeiten wenn es meine Antwort ist
              if (isMe)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      _openRecorder(context, questionText);
                    },
                    child: Icon(LucideIcons.rotateCcw, size: 16, color: AppColors.textDim.withOpacity(0.5)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: isPlaying ? AppColors.accent : AppColors.textDim, fontWeight: FontWeight.w600)),
        ],
      );
    }

    // FALL 2: Keine Antwort & ICH bin es -> Aufnehmen
    else if (isMe) {
      return GestureDetector(
        onTap: () {
          _openRecorder(context, questionText);
        },
        child: Column(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.alert,
                boxShadow: [BoxShadow(color: AppColors.alert.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Icon(LucideIcons.mic, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text("Aufnehmen", style: GoogleFonts.inter(fontSize: 10, color: AppColors.alert, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    // FALL 3: Keine Antwort & FREUND ist es -> Warten Symbol
    else {
      return Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
            ),
            child: Icon(LucideIcons.clock, color: AppColors.textDim.withOpacity(0.3), size: 24),
          ),
          const SizedBox(height: 8),
          Text("Noch offen", style: GoogleFonts.inter(fontSize: 10, color: AppColors.textDim.withOpacity(0.5))),
        ],
      );
    }
  }

  // Helper Methode zum Öffnen des Recorders
  void _openRecorder(BuildContext context, String questionText) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecordScreen(
          isDirectReply: true, // WICHTIG: Keine Gruppenauswahl
          challenge: Challenge(
              id: 'q_only',
              title: "Freundebuch",
              subtitle: "Deine Antwort",
              logo: "FB",
              questions: [questionText], // Die Frage übergeben
              bgColorHex: 0xFF1A403C,
              textColorHex: 0xFFE8F7F6
          ),
        ),
      ),
    );
  }

  // 4. Button zum Hinzufügen am Ende der Liste
  Widget _buildAddQuestionButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showAddQuestionDialog(context, ref),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 20),
        borderColor: Colors.white.withOpacity(0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.plusCircle, color: AppColors.textDim, size: 20),
            const SizedBox(width: 8),
            Text(
              "Eigene Frage hinzufügen",
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDim
              ),
            ),
          ],
        ),
      ),
    );
  }
}