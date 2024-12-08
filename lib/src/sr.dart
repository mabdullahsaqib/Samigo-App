import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

class SpeechRecognizer {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _lastWords = '';

  Future<void> initialize() async {
    await _speechToText.initialize(
      onError: errorListener,
      onStatus: statusListener,
    );
  }

  bool get isListening => _isListening;

  String get lastWords => _lastWords;

  Future<void> startListening() async {
    if (!_isListening) {
      _isListening = true;
      print('Listening...');
      await _speechToText.listen(
        onResult: _onSpeechResult,
      );
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    print('Result: ${result.recognizedWords}');
    _lastWords = result.recognizedWords;
  }

  Future<void> stopListening() async {
    if (_isListening) {
      _isListening = false;
      await _speechToText.stop();
    }
  }

  void errorListener(SpeechRecognitionError error) {
    print(
        "Received error status: $error, listening: ${_speechToText.isListening}");
  }

  void statusListener(String status) {
    print(
        "Received listener status: $status, listening: ${_speechToText.isListening}");
  }
}
