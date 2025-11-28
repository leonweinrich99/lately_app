import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../data/feed_providers.dart';
import '../domain/audio_update_model.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wir "beobachten" den Provider.
    // Riverpod kümmert sich um Loading/Error/Data States.
    final updatesAsync = ref.watch(feedUpdatesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          _buildSectionTitle("erzähl' doch mal ..."),
          const SizedBox(height: 16),
          _buildChallengeList(),
          const SizedBox(height: 30),
          _buildSectionTitle("was gibt's neues", action: "Alle abspielen"),
          const SizedBox(height: 16),

          // Hier reagieren wir auf den Daten-Status
          updatesAsync.when(
            data: (updates) => _buildUpdateList(updates),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            ),
            error: (err, stack) => Center(
              child: Text("Fehler beim Laden: $err", style: TextStyle(color: AppColors.alert)),
            ),
          ),
        ],
      ),
    );
  }

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
        GlassContainer(
          width: 44, height: 44, padding: EdgeInsets.zero, borderRadius: 14,
          child: const Center(child: Icon(LucideIcons.users, color: AppColors.textDim, size: 20)),
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

  // Die Challenges sind aktuell noch statisch (könnte man später auch ins Repository packen)
  Widget _buildChallengeList() {
    final challenges = [
      {"title": "Daily 10", "subtitle": "Die 10 Fragen des Tages", "bg": const Color(0xFFE0E8E7), "text": const Color(0xFF0F2926), "logo": "D10"},
      {"title": "Gefühls-Check", "subtitle": "Wie geht es dir wirklich?", "bg": const Color(0xFFDBC6BE), "text": const Color(0xFF2D1B1B), "logo": "Mood"},
    ];

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: challenges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = challenges[index];
          return Container(
            width: 240,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: item['bg'] as Color, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]),
            child: Stack(
              children: [
                Positioned(right: -20, top: -20, child: Opacity(opacity: 0.1, child: Text(item['logo'] as String, style: GoogleFonts.playfairDisplay(fontSize: 80, fontWeight: FontWeight.w900, color: item['text'] as Color)))),
                Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(item['title'] as String, style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w600, color: item['text'] as Color)),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Text(item['subtitle'] as String, style: GoogleFonts.inter(fontSize: 13, color: (item['text'] as Color).withOpacity(0.7), height: 1.4))),
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: (item['text'] as Color).withOpacity(0.2))), child: Icon(LucideIcons.arrowRight, size: 16, color: item['text'] as Color)),
                  ])
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  // Nimmt jetzt echte AudioUpdate Objekte entgegen!
  Widget _buildUpdateList(List<AudioUpdate> updates) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: updates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final update = updates[index];
        return GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48, height: 48, alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.transparent], begin: Alignment.topLeft, end: Alignment.bottomRight), border: Border.all(color: Colors.white.withOpacity(0.1))),
                child: Text(update.userDisplayName[0], style: GoogleFonts.playfairDisplay(color: AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(update.userDisplayName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textLight)),
                        Text(update.formattedDuration, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDim, fontFeatures: const [FontFeature.tabularFigures()])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(update.promptTitle ?? "Life Update", style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDim), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)), child: const Icon(LucideIcons.play, color: AppColors.textLight, size: 16)),
            ],
          ),
        );
      },
    );
  }
}