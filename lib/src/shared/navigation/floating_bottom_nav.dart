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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30), // Rundung erhöht
          // Leichter Schatten für die ganze Leiste
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30), // Rundung erhöht
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: AppColors.bgSurface.withOpacity(0.85),
              // Innerer Rand für High-End Look
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                  borderRadius: BorderRadius.circular(30), // Rundung erhöht
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    // --- LINKE SEITE: NAVIGATION ---
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNavItem(LucideIcons.music, 0), // Text entfernt
                          _buildNavItem(LucideIcons.bookOpen, 1), // Text entfernt
                          _buildNavItem(LucideIcons.user, 2), // Text entfernt
                        ],
                      ),
                    ),

                    // --- TRENNLINIE (Optional) ---
                    Container(
                      width: 1,
                      height: 32,
                      color: Colors.white.withOpacity(0.1),
                      margin: const EdgeInsets.only(right: 8),
                    ),

                    // --- RECHTE SEITE: ACTION BUTTON ---
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: _buildCompactRecordButton(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: double.infinity,
        width: 60, // Feste Breite für Touch-Target
        child: Center( // Zentriert das Icon vertikal und horizontal
          child: Icon(
            icon,
            color: isActive ? AppColors.accent : AppColors.textDim.withOpacity(0.5),
            size: 28, // Icon etwas größer gemacht, da Text fehlt
          ),
        ),
      ),
    );
  }

  Widget _buildCompactRecordButton() {
    return GestureDetector(
      onTap: onRecordTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.alert, Color(0xFF7A2424)],
          ),
          borderRadius: BorderRadius.circular(22), // Passende Rundung für den Button
          boxShadow: [
            BoxShadow(
              color: AppColors.alert.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              blurRadius: 2,
              offset: const Offset(-1, -1),
              blurStyle: BlurStyle.inner,
            ),
          ],
        ),
        child: const Icon(LucideIcons.mic, color: Colors.white, size: 26),
      ),
    );
  }
}