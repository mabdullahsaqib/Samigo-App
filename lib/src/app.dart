import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'tts.dart';
import 'sr.dart';

class Samigo extends StatelessWidget {
  const Samigo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Samigo',
      home: Scaffold(
        body: Center(
          child: Bot(),
        ),
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
  bool _toSpeech = false; // For TTS toggle
  bool _speechEnabled = false; // For speech recognition toggle

  final String apiUrl = 'https://samigo.vercel.app/command';

  late TTS tts;
  late SpeechRecognizer speechRecognizer;

  @override
  void initState() {
    super.initState();
    tts = TTS();
    speechRecognizer = SpeechRecognizer();
    speechRecognizer.initialize().then((_) {
      setState(() {
        _speechEnabled = true;
        print('Speech enabled: $_speechEnabled');
      });
    });
  }

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) {
      return;
    }

    setState(() {
      _messages.add('You: $message');
      _isLoading = true;
    });

    try {
      final Response response = await post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'command': message,
        }),
      );

      if (response.statusCode == 200) {
        final String data = response.body;
        setState(() {
          _messages.add('Samigo: $data');
        });
        if (_toSpeech) {
          tts.speak(data);
        }
      } else {
        setState(() {
          _messages.add('Error : ${response.statusCode} - ${response.body}');
        });
        if (_toSpeech) {
          tts.speak('There was an error processing your request.');
        }
      }
    } catch (e) {
      setState(() {
        _messages.add('Error : $e');
      });
      if (_toSpeech) {
        tts.speak('There was an error processing your request.');
      }
    } finally {
      _textController.clear();
      _scrollToBottom();
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
                    speechRecognizer.isListening ? Icons.mic : Icons.mic_off),
                onPressed: () {
                  if (speechRecognizer.isListening) {
                    speechRecognizer.stopListening();
                  } else {
                    speechRecognizer.startListening();
                    _textController.text = speechRecognizer.lastWords;
                  }
                  setState(() {});
                },
              ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                alignment: (index % 2 == 0)
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (index % 2 == 0)
                        ? Colors.blueAccent.withOpacity(0.8)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _messages[index],
                    style: TextStyle(
                      color: (index % 2 == 0) ? Colors.white : Colors.black,
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
