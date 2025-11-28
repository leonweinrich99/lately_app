import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/tactile_button.dart';
import '../../../core/widgets/glass_container.dart'; // Importieren für schöne Kacheln

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  // Zustände: idle -> recording -> reviewing
  bool isRecording = false;
  bool isReviewing = false;

  int seconds = 0;
  Timer? _timer;

  // Eingaben
  final TextEditingController _titleController = TextEditingController();
  List<String> selectedCircles = ['Engste Freunde']; // Standard-Auswahl

  @override
  void dispose() {
    _timer?.cancel();
    _titleController.dispose();
    super.dispose();
  }

  void toggleRecording() {
    if (isRecording) {
      // STOP -> Gehe zu Review
      _timer?.cancel();
      setState(() {
        isRecording = false;
        isReviewing = true;
      });
    } else {
      // START -> Starte Timer
      setState(() {
        isRecording = true;
        seconds = 0;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => seconds++);
      });
    }
  }

  void _discardRecording() {
    // Zurücksetzen
    setState(() {
      isReviewing = false;
      seconds = 0;
      _titleController.clear();
    });
  }

  void _sendUpdate() {
    // Hier würde die Logik zum Senden an das Backend kommen
    // mit _titleController.text und selectedCircles
    Navigator.pop(context); // Schließt den Screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Update gesendet! 🚀"), backgroundColor: AppColors.accent),
    );
  }

  void _toggleCircle(String circle) {
    setState(() {
      if (selectedCircles.contains(circle)) {
        selectedCircles.remove(circle);
      } else {
        selectedCircles.add(circle);
      }
    });
  }

  String get formattedTime {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      // Resize To Avoid Bottom Inset verhindert, dass die Tastatur das Layout kaputt macht
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Hintergrund
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
                // --- TOP BAR ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: isReviewing ? _discardRecording : () => Navigator.pop(context),
                        icon: Icon(isReviewing ? LucideIcons.trash2 : LucideIcons.x, color: Colors.white, size: 28),
                        style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1)),
                      ),
                      Text(
                        isReviewing ? "SENDEN AN..." : (isRecording ? "AUFNAHME LÄUFT" : "NEUES UPDATE"),
                        style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.textDim,
                        ),
                      ),
                      const SizedBox(width: 48), // Spacer
                    ],
                  ),
                ),

                const Spacer(),

                // --- HAUPTBEREICH (Wechselt zwischen Record & Review) ---
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isReviewing ? _buildReviewUI() : _buildRecordingUI(),
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI: AUFNAHME ---
  Widget _buildRecordingUI() {
    return Column(
      key: const ValueKey("recording"),
      children: [
        Text(
          formattedTime,
          style: GoogleFonts.sourceCodePro(
            fontSize: 80, fontWeight: FontWeight.bold,
            color: isRecording ? AppColors.alert : AppColors.textLight,
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(30, (index) => _VisualizerBar(isActive: isRecording)),
          ),
        ),
        const SizedBox(height: 80),
        TactileButton(
          size: 96,
          isRecording: isRecording,
          icon: isRecording ? LucideIcons.square : LucideIcons.mic,
          onTap: toggleRecording,
        ),
        const SizedBox(height: 24),
        Text(
          isRecording ? "Tippen zum Beenden" : "Tippen für Aufnahme",
          style: GoogleFonts.inter(color: AppColors.textDim.withOpacity(0.5), fontSize: 14),
        ),
      ],
    );
  }

  // --- UI: REVIEW & SENDEN ---
  Widget _buildReviewUI() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        key: const ValueKey("review"),
        children: [
          // 1. Titel Eingabe
          TextField(
            controller: _titleController,
            style: GoogleFonts.playfairDisplay(fontSize: 28, color: AppColors.textLight),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "Worum geht's?",
              hintStyle: GoogleFonts.playfairDisplay(color: AppColors.textDim.withOpacity(0.5)),
              border: InputBorder.none,
            ),
          ),

          const SizedBox(height: 20),

          // 2. Kleiner Player
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.playCircle, color: AppColors.accent, size: 24),
                const SizedBox(width: 12),
                Text(formattedTime, style: GoogleFonts.sourceCodePro(color: AppColors.textLight, fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                // Fake Waveform klein
                SizedBox(
                  width: 60, height: 20,
                  child: Row(children: List.generate(10, (i) => Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 1), color: AppColors.textDim.withOpacity(0.5), height: 10 + Random().nextDouble() * 10)))),
                )
              ],
            ),
          ),

          const SizedBox(height: 40),

          // 3. Empfänger Auswahl
          Align(
            alignment: Alignment.centerLeft,
            child: Text("TEILEN MIT", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.textDim)),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildCircleChip("Engste Freunde"),
              _buildCircleChip("Familie"),
              _buildCircleChip("Alle Bekannten"),
            ],
          ),

          const SizedBox(height: 40),

          // 4. Senden Button
          GestureDetector(
            onTap: _sendUpdate,
            child: Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.accent, Color(0xFF4FA8A3)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.send, color: AppColors.bgDeep),
                  const SizedBox(width: 12),
                  Text("Update senden", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.bgDeep)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleChip(String label) {
    final isSelected = selectedCircles.contains(label);
    return GestureDetector(
      onTap: () => _toggleCircle(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.textDim.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? AppColors.accent : AppColors.textDim,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
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
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200 + _rnd.nextInt(500)),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final height = widget.isActive
            ? 10.0 + (_controller.value * _rnd.nextInt(40))
            : 4.0;
        return Container(
          width: 4,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: widget.isActive ? AppColors.textLight : AppColors.textDim.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}