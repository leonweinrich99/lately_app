import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TactileButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final double size;
  final bool isRecording; // Wenn true, pulsiert er vielleicht später

  const TactileButton({
    super.key,
    required this.onTap,
    this.icon = Icons.mic,
    this.size = 64,
    this.isRecording = false,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Der haptische Farbverlauf
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isRecording
                  ? [AppColors.alert, AppColors.alert] // Flach, wenn aktiv
                  : [AppColors.alert, const Color(0xFF7A2424)], // 3D Verlauf
            ),
            boxShadow: [
              // Äußerer Schatten (Drop Shadow)
              BoxShadow(
                color: AppColors.alert.withOpacity(widget.isRecording ? 0.6 : 0.4),
                blurRadius: widget.isRecording ? 30 : 20,
                offset: const Offset(0, 8),
                spreadRadius: widget.isRecording ? 5 : 0,
              ),
              // Inneres Highlight (Lichtkante oben links)
              if (!widget.isRecording)
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(-2, -2),
                  blurStyle: BlurStyle.inner,
                ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: widget.size * 0.5,
          ),
        ),
      ),
    );
  }
}