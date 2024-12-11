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

  Future<void> startListening(Function(String) onResult) async {
    if (!_isListening) {
      _isListening = true;
      await _speechToText.listen(
        onResult: (SpeechRecognitionResult result) {
          _lastWords = result.recognizedWords;
          onResult(_lastWords);
        },
      );
    }
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
