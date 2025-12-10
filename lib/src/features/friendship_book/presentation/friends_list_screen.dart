import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../../friendship_book/data/friendship_book_repository.dart';
import '../../friendship_book/domain/friendship_book_model.dart';
import 'friendship_book_screen.dart';

class FriendsListScreen extends ConsumerWidget {
  const FriendsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsListProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),

          friendsAsync.when(
            // Ich habe hier auf eine ListView umgestellt für breitere Kacheln
            data: (friends) => _buildFriendsList(context, friends),
            loading: () => const Center(child: Padding(padding: EdgeInsets.only(top: 100), child: CircularProgressIndicator(color: AppColors.accent))),
            error: (err, _) => Text("Fehler: $err", style: const TextStyle(color: AppColors.alert)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Freunde.",
          style: GoogleFonts.playfairDisplay(color: AppColors.textLight, fontSize: 32, fontWeight: FontWeight.w600),
        ),
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.1))),
          child: const Center(child: Icon(LucideIcons.userPlus, color: AppColors.textDim, size: 20)),
        ),
      ],
    );
  }

  // Neue Listen-Ansicht (statt Grid)
  Widget _buildFriendsList(BuildContext context, List<FriendshipBookProfile> friends) {
    if (friends.isEmpty) {
      return Center(child: Text("Noch keine Freunde.", style: GoogleFonts.inter(color: AppColors.textDim)));
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: friends.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final friend = friends[index];
        return _buildFriendListTile(context, friend);
      },
    );
  }

  // Breite Kachel (Row Layout)
  Widget _buildFriendListTile(BuildContext context, FriendshipBookProfile friend) {
    final answeredCount = friend.entries.where((e) => e.hasAnswer).length;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FriendshipBookScreen(userId: friend.userId),
          ),
        );
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar Links
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.transparent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                border: Border.all(color: AppColors.accent.withOpacity(0.5), width: 1.5),
              ),
              child: Center(
                child: Text(
                  friend.avatarLetter,
                  style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textLight),
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Info Rechts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.displayName,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textLight, fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(LucideIcons.bookOpen, size: 14, color: AppColors.textDim),
                      const SizedBox(width: 6),
                      Text(
                        "$answeredCount Einträge",
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDim),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Pfeil Indikator
            Icon(LucideIcons.chevronRight, color: AppColors.textDim.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    );
  }
}