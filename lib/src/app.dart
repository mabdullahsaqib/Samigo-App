import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

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

  final String apiUrl = 'https://samigo.vercel.app/command';

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
      } else {
        setState(() {
          _messages.add('Error : ${response.statusCode} - ${response.body}');
        });
      }
    } catch (e) {
      setState(() {
        _messages.add('Error : $e');
      });
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
