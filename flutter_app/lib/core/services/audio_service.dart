import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages UI sound effects (menu navigation clicks).
/// Initialised once and exposed as a Riverpod provider.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();
  bool _soundEnabled = true;

  bool get soundEnabled => _soundEnabled;

  /// Call once at app start to pre-load the click sound.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    // Pre-cache the sound
    await _player.setSourceAsset('sounds/menu_click.mp3');
  }

  /// Plays a subtle click for bottom-nav or menu switches.
  Future<void> playMenuClick() async {
    if (!_soundEnabled) return;
    try {
      await _player.stop();
      await _player.setVolume(0.4);
      await _player.play(AssetSource('sounds/menu_click.mp3'));
    } catch (_) {
      // Silently ignore audio errors in demo
    }
  }

  /// Toggle sound on/off and persist.
  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _soundEnabled);
  }

  void dispose() {
    _player.dispose();
  }
}

// ── Riverpod Providers ────────────────────────────────────────────────────

/// Provides the [AudioService] singleton.
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService.instance;
  ref.onDispose(service.dispose);
  return service;
});

/// Reactive bool for whether sound is enabled (used by the toggle UI).
final soundEnabledProvider = StateProvider<bool>((ref) => true);
