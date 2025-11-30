import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/tactile_button.dart';
import '../../../core/widgets/glass_container.dart';
import '../../feed/domain/challenge_model.dart';
import '../../groups/domain/user_group_model.dart';
import '../../groups/data/group_repository.dart';
// NEU: Importieren für das Speichern
import '../../feed/data/feed_providers.dart';
import '../../feed/domain/audio_update_model.dart';

class RecordScreen extends ConsumerStatefulWidget {
  final Challenge? challenge;

  const RecordScreen({
    super.key,
    this.challenge,
  });

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  // ... (Variablen bleiben gleich)
  bool isRecording = false;
  bool isReviewing = false;
  int seconds = 0;
  Timer? _timer;
  final TextEditingController _titleController = TextEditingController();
  final Set<String> selectedGroupIds = {'besties'};
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.challenge != null) {
      _titleController.text = "Re: ${widget.challenge!.title}";
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _titleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ... (toggleRecording, _discardRecording bleiben gleich)
  void toggleRecording() {
    if (isRecording) {
      _timer?.cancel();
      setState(() {
        isRecording = false;
        isReviewing = true;
        if (widget.challenge != null) {
          _titleController.text = "${widget.challenge!.title} - Frage ${_currentQuestionIndex + 1}";
        }
      });
    } else {
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
    setState(() {
      isReviewing = false;
      seconds = 0;
      if (widget.challenge == null) {
        _titleController.clear();
      }
    });
  }

  void _toggleGroup(String groupId) {
    setState(() {
      if (selectedGroupIds.contains(groupId)) {
        selectedGroupIds.remove(groupId);
      } else {
        selectedGroupIds.add(groupId);
      }
    });
  }

  // --- HIER PASSIERT DAS UPDATE ---
  void _sendUpdate() {
    if (selectedGroupIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bitte wähle mindestens eine Gruppe aus!"), backgroundColor: AppColors.alert),
      );
      return;
    }

    // 1. Das neue Update Objekt erstellen
    final newUpdate = AudioUpdate(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Einzigartige ID generieren
      userId: 'current_user_id', // Wichtig: Damit es im Profil erscheint!
      userDisplayName: 'Ich', // Oder echter Name
      audioUrl: 'dummy_url_recorded', // Platzhalter, da noch keine echte Datei
      durationSeconds: seconds > 0 ? seconds : 5, // Falls Test zu kurz war
      createdAt: DateTime.now(),
      promptTitle: _titleController.text.isNotEmpty ? _titleController.text : "Neues Update",
      visibilityUserIds: selectedGroupIds.toList(),
    );

    // 2. An den Provider senden
    ref.read(feedRepositoryProvider.notifier).addUpdate(newUpdate);

    // 3. UI schließen
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Update gesendet! 🚀"), backgroundColor: AppColors.accent),
    );
  }

  String get formattedTime {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // ... (Build Methode bleibt identisch wie im letzten Canvas)
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      resizeToAvoidBottomInset: false,
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
                        onPressed: isReviewing ? _discardRecording : () => Navigator.pop(context),
                        icon: Icon(isReviewing ? LucideIcons.trash2 : LucideIcons.x, color: Colors.white, size: 28),
                        style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1)),
                      ),
                      Text(
                        isReviewing
                            ? "SENDEN AN..."
                            : (isRecording ? "AUFNAHME LÄUFT" : (widget.challenge?.title.toUpperCase() ?? "NEUES UPDATE")),
                        style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.textDim,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const Spacer(),

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

  Widget _buildRecordingUI() {
    return Column(
      key: const ValueKey("recording"),
      children: [
        if (widget.challenge != null) ...[
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.challenge!.questions.length,
              onPageChanged: (index) {
                setState(() => _currentQuestionIndex = index);
              },
              itemBuilder: (context, index) {
                final isActive = index == _currentQuestionIndex;
                final question = widget.challenge!.questions[index];

                return AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: isActive ? 1.0 : 0.9,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isActive ? 1.0 : 0.5,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F7F6),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "FRAGE ${index + 1}/${widget.challenge!.questions.length}",
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.bgDeep.withOpacity(0.4)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            question,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.bgDeep),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
        ],

        Text(
          formattedTime,
          style: GoogleFonts.sourceCodePro(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: isRecording ? AppColors.alert : AppColors.textLight,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(30, (index) => _VisualizerBar(isActive: isRecording)),
          ),
        ),
        const SizedBox(height: 40),
        TactileButton(
          size: 84,
          isRecording: isRecording,
          icon: isRecording ? LucideIcons.square : LucideIcons.mic,
          onTap: toggleRecording,
        ),
        const SizedBox(height: 16),
        Text(
          isRecording ? "Tippen zum Beenden" : "Tippen für Aufnahme",
          style: GoogleFonts.inter(color: AppColors.textDim.withOpacity(0.5), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildReviewUI() {
    final groupsAsync = ref.watch(userGroupsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        key: const ValueKey("review"),
        children: [
          TextField(
            controller: _titleController,
            style: GoogleFonts.playfairDisplay(fontSize: 24, color: AppColors.textLight),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "Worum geht's?",
              hintStyle: GoogleFonts.playfairDisplay(color: AppColors.textDim.withOpacity(0.5)),
              border: InputBorder.none,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.1))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(LucideIcons.playCircle, color: AppColors.accent, size: 24), const SizedBox(width: 12), Text(formattedTime, style: GoogleFonts.sourceCodePro(color: AppColors.textLight, fontWeight: FontWeight.bold)), const SizedBox(width: 12), SizedBox(width: 60, height: 20, child: Row(children: List.generate(10, (i) => Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 1), color: AppColors.textDim.withOpacity(0.5), height: 10 + Random().nextDouble() * 10)))))],),
          ),

          const SizedBox(height: 40),

          Align(alignment: Alignment.centerLeft, child: Text("TEILEN MIT", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.textDim))),
          const SizedBox(height: 12),

          groupsAsync.when(
            data: (groups) => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: groups.map((group) => _buildGroupChip(group)).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
            error: (err, _) => Text("Konnte Gruppen nicht laden", style: TextStyle(color: AppColors.alert)),
          ),

          const SizedBox(height: 40),

          GestureDetector(
            onTap: _sendUpdate,
            child: Container(
              width: double.infinity, height: 64,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.accent, Color(0xFF4FA8A3)]), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(LucideIcons.send, color: AppColors.bgDeep), const SizedBox(width: 12), Text("Update senden", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.bgDeep))]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupChip(UserGroup group) {
    final isSelected = selectedGroupIds.contains(group.id);
    final groupColor = Color(group.colorHex);

    return GestureDetector(
      onTap: () => _toggleGroup(group.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? groupColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: isSelected ? groupColor : AppColors.textDim.withOpacity(0.3),
              width: 1.5
          ),
        ),
        child: Text(
          group.name,
          style: GoogleFonts.inter(
            color: isSelected ? groupColor : AppColors.textDim,
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
  void initState() { super.initState(); _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 200 + _rnd.nextInt(500)))..repeat(reverse: true); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _controller, builder: (context, child) {
      final height = widget.isActive ? 10.0 + (_controller.value * _rnd.nextInt(40)) : 4.0;
      return Container(width: 4, height: height, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: widget.isActive ? AppColors.textLight : AppColors.textDim.withOpacity(0.2), borderRadius: BorderRadius.circular(2)));
    },
    );
  }
}