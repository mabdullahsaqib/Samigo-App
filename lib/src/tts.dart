import 'package:flutter_tts/flutter_tts.dart';

class TTS {
  final FlutterTts _flutterTts = FlutterTts();

  TTS() {
    _initializeTTS();
  }

  void _initializeTTS() {
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
