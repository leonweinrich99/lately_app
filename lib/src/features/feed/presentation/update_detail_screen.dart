import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/services/audio_player_service.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/audio_update_model.dart';

class UpdateDetailScreen extends ConsumerWidget {
  final AudioUpdate update;

  const UpdateDetailScreen({super.key, required this.update});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerProvider);
    final isPlayingThis = audioState.playingUrl == update.audioUrl && audioState.isPlaying;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.0,
                colors: [AppColors.bgSurface, AppColors.bgDeep],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(LucideIcons.chevronDown, color: Colors.white, size: 28),
                      ),
                      Text(
                        "LIFE UPDATE",
                        style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.textDim,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const Spacer(),

                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
                    gradient: LinearGradient(
                        colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                        begin: Alignment.topLeft, end: Alignment.bottomRight
                    ),
                  ),
                  child: Center(
                    child: Text(
                      update.userDisplayName.isNotEmpty ? update.userDisplayName[0] : "?",
                      style: GoogleFonts.playfairDisplay(fontSize: 40, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  update.userDisplayName,
                  style: GoogleFonts.playfairDisplay(fontSize: 32, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  update.promptTitle ?? "Einfach so erzählt",
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDim),
                ),

                const SizedBox(height: 60),

                // Visualizer
                SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(30, (index) => _VisualizerBar(isActive: isPlayingThis)),
                  ),
                ),

                const Spacer(),

                // Play/Pause Button
                GestureDetector(
                  onTap: () {
                    ref.read(audioPlayerProvider.notifier).toggle(update.audioUrl);
                  },
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 30, offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      isPlayingThis ? LucideIcons.pause : LucideIcons.play,
                      color: AppColors.bgDeep, size: 32,
                    ),
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisualizerBar extends StatefulWidget {
  final bool isActive;
  const _VisualizerBar({required this.isActive});
  @override
  State<_VisualizerBar> createState() => _VisualizerBarState();
}

class _VisualizerBarState extends State<_VisualizerBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 200 + _rnd.nextInt(500)))..repeat(reverse: true);
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final height = widget.isActive ? 10.0 + (_controller.value * _rnd.nextInt(40)) : 4.0;
        return Container(
          width: 4, height: height, margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(color: widget.isActive ? AppColors.textLight : AppColors.textDim.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
        );
      },
    );
  }
}