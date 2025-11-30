import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../../friends/data/profile_repository.dart';
import '../../friends/domain/profile_model.dart';
import '../../../core/services/audio_player_service.dart';
import '../../feed/data/feed_providers.dart'; // Zugriff auf Feed-Daten
import '../../feed/domain/audio_update_model.dart'; // Audio Update Model

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In einer echten App kommt diese ID aus dem AuthProvider (Firebase Auth)
    const currentUserId = 'current_user_id';

    // Wir laden 1. das Profil und 2. alle Updates (die wir dann filtern)
    final profileAsync = ref.watch(userProfileProvider(currentUserId));
    final allUpdatesAsync = ref.watch(feedUpdatesProvider);

    // Audio Status beobachten
    final audioState = ref.watch(audioPlayerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 120),
      child: profileAsync.when(
        data: (profile) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            _buildUserInfo(profile),
            const SizedBox(height: 40),

            // EINKLAPPBARER STECKBRIEF
            _buildCollapsibleFriendbook(profile, ref, audioState),

            const SizedBox(height: 40),

            // MEINE UPDATES SECTION
            Text(
              "Meine Updates",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 16),

            allUpdatesAsync.when(
              data: (updates) {
                // FILTER: Nur Updates anzeigen, die mir gehören
                // Hinweis: Im Mock-Repo müssen wir sicherstellen, dass es Updates mit 'current_user_id' gibt,
                // sonst bleibt die Liste leer. Für Demo-Zwecke zeige ich hier ALLES an, wenn die ID nicht passt,
                // aber der Code für den Filter ist auskommentiert vorbereitet.

                /* ECHTER FILTER (Aktivieren sobald echte Daten da sind):
                final myUpdates = updates.where((u) => u.userId == currentUserId).toList();
                */

                // MOCK FILTER (Damit man was sieht, filtere ich nach 'u1' oder zeige alle)
                // In der Produktion wird das durch den echten Filter ersetzt.
                final myUpdates = updates;

                if (myUpdates.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "Du hast noch keine Updates aufgenommen.",
                      style: GoogleFonts.inter(color: AppColors.textDim, fontStyle: FontStyle.italic),
                    ),
                  );
                }

                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: myUpdates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildMyUpdateCard(myUpdates[index], ref, audioState),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
              error: (e, _) => Text("Fehler beim Laden der Updates", style: TextStyle(color: AppColors.alert)),
            ),

            const SizedBox(height: 40),
            _buildInviteBox(),
          ],
        ),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 100),
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
        error: (err, _) => Center(
          child: Text("Fehler: $err", style: TextStyle(color: AppColors.alert)),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Mein Buch.",
          style: GoogleFonts.playfairDisplay(color: AppColors.textLight, fontSize: 32, fontWeight: FontWeight.w600),
        ),
        Icon(LucideIcons.settings, color: AppColors.textDim, size: 24),
      ],
    );
  }

  Widget _buildUserInfo(FriendProfile profile) {
    return Row(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.bgSurface,
            border: Border.all(color: AppColors.accent, width: 2),
          ),
          child: Center(
            child: Text(
              profile.avatarLetter,
              style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textLight),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayName,
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textLight),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: profile.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(tag, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textDim)),
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Einklappbarer Bereich für das Freundebuch
  Widget _buildCollapsibleFriendbook(FriendProfile profile, WidgetRef ref, AudioState audioState) {
    return Theme(
      data: Theme.of(ref.context).copyWith(dividerColor: Colors.transparent),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: Colors.white.withOpacity(0.05), // Leichter Hintergrund für den Block
          child: ExpansionTile(
            title: Text(
              "Steckbrief",
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textLight.withOpacity(0.9)),
            ),
            trailing: Icon(LucideIcons.chevronDown, color: AppColors.textDim),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              // Bearbeiten Button
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    "Bearbeiten",
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent),
                  ),
                ),
              ),
              // Liste der Einträge
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: profile.entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildEntryCard(profile.entries[index], ref, audioState);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntryCard(ProfileEntry entry, WidgetRef ref, AudioState audioState) {
    final isPlayingThis = entry.hasAnswer && audioState.playingUrl == entry.audioUrl && audioState.isPlaying;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      opacity: 0.03,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  entry.question,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textLight.withOpacity(0.9)),
                ),
              ),
              if (!entry.hasAnswer) Icon(LucideIcons.plus, color: AppColors.textDim, size: 16),
            ],
          ),
          if (entry.hasAnswer) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () { if (entry.audioUrl != null) ref.read(audioPlayerProvider.notifier).toggle(entry.audioUrl!); },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: isPlayingThis ? Border.all(color: AppColors.accent.withOpacity(0.3)) : null,
                ),
                child: Row(
                  children: [
                    Icon(isPlayingThis ? LucideIcons.pause : LucideIcons.play, color: isPlayingThis ? AppColors.accent : AppColors.textLight, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(height: 2, color: Colors.white.withOpacity(0.1)),
                    ),
                    const SizedBox(width: 8),
                    Text(isPlayingThis ? "Playing..." : entry.formattedDuration, style: GoogleFonts.sourceCodePro(color: AppColors.textDim, fontSize: 10)),
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  // Karte für "Meine Updates" - Angepasst für eigene Inhalte
  Widget _buildMyUpdateCard(AudioUpdate update, WidgetRef ref, AudioState audioState) {
    final isPlayingThis = audioState.playingUrl == update.audioUrl && audioState.isPlaying;

    // Mapping von Wochentagen/Monaten wäre hier cool, aber für jetzt hardcoded
    final day = update.createdAt.day.toString();
    final month = "NOV"; // Platzhalter

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Datum-Box statt Avatar
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(day, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textLight)),
                Text(month, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textDim)),
              ],
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  update.promptTitle ?? "Life Update",
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textLight, fontSize: 15),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Zeigt an, mit wem geteilt wurde (im Mock noch nicht verfügbar, daher Platzhalter)
                Row(
                  children: [
                    Icon(LucideIcons.users, size: 12, color: AppColors.textDim),
                    const SizedBox(width: 4),
                    Text("Engste Freunde", style: GoogleFonts.inter(fontSize: 11, color: AppColors.textDim)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: () { ref.read(audioPlayerProvider.notifier).toggle(update.audioUrl); },
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPlayingThis ? AppColors.accent : Colors.white.withOpacity(0.05)
              ),
              child: Icon(
                  isPlayingThis ? LucideIcons.pause : LucideIcons.play,
                  color: isPlayingThis ? AppColors.bgDeep : AppColors.textLight,
                  size: 16
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteBox() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.2)), borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Text("Hol deine echten Freunde dazu.", style: GoogleFonts.inter(color: AppColors.textDim, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: AppColors.textLight, borderRadius: BorderRadius.circular(16)),
            child: Center(child: Text("Einladungs-Link teilen", style: GoogleFonts.inter(color: AppColors.bgDeep, fontWeight: FontWeight.bold))),
          ),
        ],
      ),
    );
  }
}