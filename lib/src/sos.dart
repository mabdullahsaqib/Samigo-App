import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SOSPage extends StatefulWidget {
  const SOSPage({super.key});

  @override
  SOSPageState createState() => SOSPageState();
}

class SOSPageState extends State<SOSPage> {
  final TextEditingController _numberController = TextEditingController();
  String? _emergencyNumber;

  @override
  void initState() {
    super.initState();
    _loadEmergencyNumber();
  }

  Future<void> _loadEmergencyNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _emergencyNumber = prefs.getString('emergency_number') ?? '';
      _numberController.text = _emergencyNumber!;
    });
  }

  Future<void> _saveEmergencyNumber(String number) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('emergency_number', number);
    setState(() {
      _emergencyNumber = number;
    });
  }

  Future<void> _callEmergencyNumber() async {
    if (_emergencyNumber == null || _emergencyNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set an emergency number first!')),
      );
      return;
    }

    final Uri callUri = Uri(scheme: 'tel', path: _emergencyNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to call $_emergencyNumber')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Feature'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Emergency Number',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _saveEmergencyNumber(value);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _callEmergencyNumber,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: const Text('Call Emergency Number'),
            ),
          ],
        ),
      ),
    );
  }
}
