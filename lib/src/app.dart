import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'auth.dart'; // Updated AuthService for Bearer Token flow
import 'sos.dart'; // SOS feature
import 'sr.dart'; // SpeechRecognizer functionality
import 'tts.dart'; // TTS functionality

class Samigo extends StatelessWidget {
  const Samigo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Samigo',
      home: SamigoHome(),
    );
  }
}

class SamigoHome extends StatelessWidget {
  const SamigoHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Bot(),
      ),
    );
  }
}

class Bot extends StatefulWidget {
  const Bot({super.key});

  @override
  BotState createState() => BotState();
}

class BotState extends State<Bot> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _messages = <String>[];
  bool _isLoading = false;
  bool _toSpeech = false; // TTS toggle
  bool _speechEnabled = false; // Speech recognition toggle

  final String apiUrl = 'https://samigo.vercel.app/command';
  final AuthService _authService = AuthService();

  late TTS tts;
  late SpeechRecognizer speechRecognizer;
  String? bearerToken; // To store the dynamically generated Bearer Token

  @override
  void initState() {
    super.initState();
    tts = TTS();
    speechRecognizer = SpeechRecognizer();

    speechRecognizer.initialize().then((_) {
      setState(() {
        _speechEnabled = true;
        print('Speech recognition initialized: $_speechEnabled');
      });
    });
  }

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _messages.add('You: $message');
      _isLoading = true;
    });

    try {
      final headers = {
        if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      };

      final Response response = await post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode({'command': message}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String data = responseData['response'] ?? 'No response';

        setState(() {
          _messages.add('Samigo: $data');
        });

        if (responseData['status'] == 'auth_required') {
          await _authenticateAndSetBearerToken();
          return;
        }

        if (_toSpeech) {
          tts.speak(data);
        }
      } else {
        _handleError(response.statusCode, response.body);
      }
    } catch (e) {
      _handleError(null, e.toString());
    } finally {
      _resetInputState();
    }
  }

  Future<void> _authenticateAndSetBearerToken() async {
    try {
      setState(() {
        _messages.add('Authenticating with Google...');
      });

      final token = await _authService.authenticateAndGetToken();

      if (token == null) {
        setState(() {
          _messages.add('Authentication canceled by user.');
        });
        return;
      }

      setState(() {
        bearerToken = token; // Save the Bearer Token for future requests
        _messages.add('Authentication successful! Bearer Token set.');
      });
    } catch (e) {
      _handleError(null, e.toString());
    }
  }

  void _handleError(int? statusCode, String errorMessage) {
    final String message = statusCode != null
        ? 'Error $statusCode: $errorMessage'
        : 'Error: $errorMessage';

    setState(() {
      _messages.add(message);
    });

    if (_toSpeech) {
      tts.speak('An error occurred while processing your request.');
    }
  }

  void _resetInputState() {
    _textController.clear();
    _scrollToBottom();
    setState(() {
      _isLoading = false;
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onSpeechResult(String result) {
    setState(() {
      _textController.text = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('Samigo'),
          actions: [
            IconButton(
              icon: Icon(_toSpeech ? Icons.volume_up : Icons.volume_off),
              onPressed: () {
                setState(() {
                  _toSpeech = !_toSpeech;
                });
              },
            ),
            if (_speechEnabled)
              IconButton(
                icon: Icon(
                  speechRecognizer.isListening ? Icons.mic : Icons.mic_off,
                ),
                onPressed: () {
                  if (speechRecognizer.isListening) {
                    speechRecognizer.stopListening();
                    _sendMessage(_textController.text);
                  } else {
                    speechRecognizer.startListening(_onSpeechResult);
                  }
                  setState(() {});
                },
              ),
            IconButton(
              icon: const Icon(Icons.warning),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SOSPage()),
                );
              },
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final isUserMessage = index % 2 == 0;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                alignment: isUserMessage
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isUserMessage
                        ? Colors.blueAccent.withOpacity(0.8)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _messages[index],
                    style: TextStyle(
                      color: isUserMessage ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: "Enter your command...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _sendMessage(_textController.text),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
