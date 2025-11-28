import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NoiseBackground extends StatelessWidget {
  final Widget child;

  const NoiseBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Der solide Farb-Hintergrund
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.3),
              radius: 1.2,
              colors: [AppColors.bgSurface, AppColors.bgDeep],
            ),
          ),
        ),

        // 2. Das Noise-Bild (Optional)
        // Sobald du ein Bild hast: Lege es in pubspec.yaml an und entkommentiere dies:
        /*
        Opacity(
          opacity: 0.05, // Ganz subtil
          child: Image.asset(
            'assets/images/noise.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            repeat: ImageRepeat.repeat,
          ),
        ),
        */

        // 3. Der eigentliche Inhalt der App
        child,
      ],
    );
  }
}