import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});

/// Narration + sound effects.
///
/// Narration prefers the recorded `audioUrl` uploaded from the admin panel
/// (best pronunciation quality); if a step has none, the device
/// text-to-speech engine reads the text in the world's locale
/// (en-US, bn-BD, hi-IN, ur-PK, ar-SA …).
class AudioService {
  final AudioPlayer _voice = AudioPlayer();
  final AudioPlayer _effects = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  Future<void> speak({String audioUrl = '', String text = '', String locale = 'en-US'}) async {
    await stop();
    if (audioUrl.isNotEmpty) {
      try {
        await _voice.play(UrlSource(audioUrl));
        return;
      } catch (e) {
        debugPrint('Audio playback failed, falling back to TTS: $e');
      }
    }
    if (text.trim().isEmpty) return;
    try {
      await _tts.setLanguage(locale.isEmpty ? 'en-US' : locale);
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(1.08);
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS failed: $e');
    }
  }

  /// Short effect (correct / wrong / complete) — URLs come from config/app.
  Future<void> effect(String url) async {
    if (url.isEmpty) return;
    try {
      await _effects.stop();
      await _effects.play(UrlSource(url), volume: 0.7);
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _voice.stop();
    } catch (_) {}
    try {
      await _tts.stop();
    } catch (_) {}
  }

  void dispose() {
    _voice.dispose();
    _effects.dispose();
    _tts.stop();
  }
}
