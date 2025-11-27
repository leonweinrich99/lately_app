import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';

class FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onRecordTap;

  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onRecordTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32), // Schwebt 32px über dem Boden
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.bgSurface.withOpacity(0.85),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(LucideIcons.music, "Feed", 0),
                _buildNavItem(LucideIcons.bookOpen, "Freunde", 1),

                // Der mittlere Platzhalter für den schwebenden Record-Button
                const SizedBox(width: 48),

                _buildNavItem(LucideIcons.user, "Ich", 2),
                // Kleiner Platzhalter für Symmetrie (optional, hier nicht nötig da spaceEvenly)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque, // Klickbereich vergrößern
      child: SizedBox(
        width: 60,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.accent : AppColors.textDim.withOpacity(0.5),
              size: 24,
            ),
            if (isActive)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.textLight,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Separates Widget für den Record Button, damit er im Stack darüber liegen kann
class FloatingRecordButton extends StatelessWidget {
  final VoidCallback onTap;

  const FloatingRecordButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.alert, Color(0xFF7A2424)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.alert.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(-2, -2),
              blurStyle: BlurStyle.inner,
            ),
          ],
          border: Border.all(color: AppColors.bgDeep, width: 4), // Rand zur Trennung
        ),
        child: const Icon(LucideIcons.mic, color: Colors.white, size: 28),
      ),
    );
  }
}