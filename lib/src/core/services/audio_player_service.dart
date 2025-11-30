import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- State-Objekt ---
class AudioState {
  final String? playingUrl; // Welche URL läuft gerade?
  final bool isPlaying;     // Läuft es oder pausiert es?
  final Duration position;  // Wo sind wir?
  final Duration total;     // Wie lang ist es?

  AudioState({
    this.playingUrl,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.total = Duration.zero,
  });

  AudioState copyWith({
    String? playingUrl,
    bool? isPlaying,
    Duration? position,
    Duration? total,
  }) {
    return AudioState(
      playingUrl: playingUrl ?? this.playingUrl,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      total: total ?? this.total,
    );
  }
}

// --- Logic (Notifier) ---
class AudioPlayerNotifier extends StateNotifier<AudioState> {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayerNotifier() : super(AudioState()) {
    // Listener für Status
    _player.playerStateStream.listen((state) {
      if (mounted) {
        this.state = this.state.copyWith(
          isPlaying: state.playing,
          playingUrl: state.processingState == ProcessingState.completed ? null : this.state.playingUrl,
        );
      }
    });

    // Listener für Position
    _player.positionStream.listen((pos) {
      if (mounted) this.state = this.state.copyWith(position: pos);
    });

    // Listener für Dauer
    _player.durationStream.listen((dur) {
      if (mounted) this.state = this.state.copyWith(total: dur ?? Duration.zero);
    });
  }

  Future<void> play(String url) async {
    if (state.playingUrl == url) {
      _player.play();
    } else {
      state = state.copyWith(playingUrl: url);
      try {
        await _player.setUrl(url);
        _player.play();
      } catch (e) {
        print("Fehler beim Abspielen: $e");
        state = state.copyWith(playingUrl: null);
      }
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
    state = state.copyWith(playingUrl: null, isPlaying: false);
  }

  Future<void> toggle(String url) async {
    if (state.playingUrl == url && state.isPlaying) {
      await pause();
    } else {
      await play(url);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

// --- Provider ---
final audioPlayerProvider = StateNotifierProvider<AudioPlayerNotifier, AudioState>((ref) {
  return AudioPlayerNotifier();
});