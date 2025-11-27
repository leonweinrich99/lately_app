import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.blur = 20,
    this.opacity = 0.07, // Standard-Transparenz
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // 1. Der Blur-Effekt
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(
                decoration: BoxDecoration(
                  // 2. Der zarte Gradient für Tiefe
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(opacity + 0.05), // Helleres Highlight oben links
                      Colors.white.withOpacity(opacity),        // Basis
                    ],
                  ),
                  borderRadius: BorderRadius.circular(borderRadius),
                  // 3. Der feine Rand (Glass Kante)
                  border: Border.all(
                    color: borderColor ?? Colors.white.withOpacity(0.08),
                    width: 1,
                  ),
                ),
                padding: padding,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}