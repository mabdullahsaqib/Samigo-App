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
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _messages.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(_messages[index]),
              );
            },
          ),
        ),
        if (_isLoading)
          const CircularProgressIndicator()
        else
          TextField(
            controller: _textController,
            focusNode: _focusNode,
            decoration: const InputDecoration(
              hintText: 'Type a message...',
            ),
            onSubmitted: (String message) {
              _sendMessage(message);
            },
          ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {
            _sendMessage(_textController.text);
          },
        ),
      ],
    );
  }
}
