import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Samigo extends StatelessWidget {
  const Samigo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
