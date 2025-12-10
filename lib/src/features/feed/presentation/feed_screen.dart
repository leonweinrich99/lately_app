import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/services/audio_player_service.dart';
import '../../feed/data/feed_providers.dart';
import '../domain/audio_update_model.dart';
import '../domain/challenge_model.dart';
import 'update_detail_screen.dart';
import '../../recorder/presentation/record_screen.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatesAsync = ref.watch(feedUpdatesProvider);
    final challengesAsync = ref.watch(activeChallengesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          _buildSectionTitle("Für Dich"),
          const SizedBox(height: 16),

          challengesAsync.when(
            data: (challenges) => _buildChallengeList(context, challenges),
            loading: () => const SizedBox(height: 160, child: Center(child: CircularProgressIndicator(color: AppColors.accent))),
            error: (err, _) => SizedBox(height: 100, child: Text("Fehler: $err", style: const TextStyle(color: AppColors.textDim))),
          ),

          const SizedBox(height: 30),
          _buildSectionTitle("Neues aus dem Kreis", action: "Alle abspielen"),
          const SizedBox(height: 16),

          updatesAsync.when(
            data: (updates) {
              // FILTER: Zeige nur Updates von Freunden (alles außer mir selbst)
              // In einer echten App würde man die 'current_user_id' aus dem Auth-State holen.
              final friendUpdates = updates.where((u) => u.userId != 'current_user_id').toList();

              if (friendUpdates.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text("Alles ruhig im Kreis. Zeit für ein Update von dir?", style: TextStyle(color: AppColors.textDim.withOpacity(0.5))),
                );
              }

              return _buildUpdateList(friendUpdates, ref, context);
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.accent))),
            error: (err, stack) => Text("Fehler: $err", style: const TextStyle(color: AppColors.alert)),
          ),
        ],
      ),
    );
  }

  // ... (Restliche Widgets wie _buildHeader, _buildSectionTitle, _buildChallengeList, _buildUpdateList bleiben gleich)
  // Ich kopiere sie hier herein, damit die Datei vollständig ist.

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Guten Morgen", style: GoogleFonts.inter(color: AppColors.textDim, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text("Hallo, Tom.", style: GoogleFonts.playfairDisplay(color: AppColors.textLight, fontSize: 32, fontWeight: FontWeight.w500)),
          ],
        ),
        const GlassContainer(
          width: 44, height: 44, padding: EdgeInsets.zero, borderRadius: 14,
          child: Center(child: Icon(LucideIcons.users, color: AppColors.textDim, size: 20)),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {String? action}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.inter(color: AppColors.textLight.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.bold)),
        if (action != null) Text(action, style: GoogleFonts.inter(color: AppColors.textDim, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildChallengeList(BuildContext context, List<Challenge> challenges) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: challenges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final challenge = challenges[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      RecordScreen(challenge: challenge),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeOutQuart;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    return SlideTransition(position: animation.drive(tween), child: child);
                  },
                ),
              );
            },
            child: Container(
              width: 240,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(challenge.bgColorHex),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Stack(
                children: [
                  Positioned(
                      right: -20, top: -20,
                      child: Opacity(
                          opacity: 0.1,
                          child: Text(challenge.logo, style: GoogleFonts.playfairDisplay(fontSize: 80, fontWeight: FontWeight.w900, color: Color(challenge.textColorHex)))
                      )
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(challenge.title, style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w600, color: Color(challenge.textColorHex))),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Expanded(
                          child: Text(
                            challenge.subtitle,
                            style: GoogleFonts.inter(fontSize: 13, color: Color(challenge.textColorHex).withOpacity(0.7), height: 1.4),
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                          )
                      ),
                      const SizedBox(width: 8),
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Color(challenge.textColorHex).withOpacity(0.2))), child: Icon(LucideIcons.arrowRight, size: 16, color: Color(challenge.textColorHex))),
                    ])
                  ]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpdateList(List<AudioUpdate> updates, WidgetRef ref, BuildContext context) {
    final audioState = ref.watch(audioPlayerProvider);
    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: updates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final update = updates[index];
        final isPlayingThis = audioState.playingUrl == update.audioUrl && audioState.isPlaying;
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => UpdateDetailScreen(update: update)),
            );
          },
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(width: 48, height: 48, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.transparent], begin: Alignment.topLeft, end: Alignment.bottomRight), border: Border.all(color: Colors.white.withOpacity(0.1))), child: Text(update.userDisplayName.isNotEmpty ? update.userDisplayName[0] : "?", style: GoogleFonts.playfairDisplay(color: AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 20))),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Text(update.userDisplayName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textLight)), Text(isPlayingThis ? "Spielt..." : update.formattedDuration, style: GoogleFonts.inter(fontSize: 12, color: isPlayingThis ? AppColors.accent : AppColors.textDim, fontWeight: isPlayingThis ? FontWeight.bold : FontWeight.normal, fontFeatures: const [FontFeature.tabularFigures()]))]), const SizedBox(height: 4), Text(update.promptTitle ?? "Life Update", style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDim), maxLines: 1, overflow: TextOverflow.ellipsis)])),
                const SizedBox(width: 20),
                GestureDetector(onTap: () { ref.read(audioPlayerProvider.notifier).toggle(update.audioUrl); }, child: Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: isPlayingThis ? AppColors.accent : Colors.white.withOpacity(0.05)), child: Icon(isPlayingThis ? LucideIcons.pause : LucideIcons.play, color: isPlayingThis ? AppColors.bgDeep : AppColors.textLight, size: 16))),
              ],
            ),
          ),
        );
      },
    );
  }
}