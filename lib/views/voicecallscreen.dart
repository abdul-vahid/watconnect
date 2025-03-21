import 'package:flutter/material.dart';

class VoiceCallScreen extends StatefulWidget {
  final String? leadName;
  final String? wpnumber;

  const VoiceCallScreen({super.key, this.leadName, this.wpnumber});

  @override
  _VoiceCallScreenState createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  bool isCalling = true;
  bool isAnswered = false;
  bool isEnded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Voice Call with ${widget.leadName}',
            style: const TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: isEnded
            ? _callEndedUI()
            : isCalling
                ? _callingUI()
                : _ongoingCallUI(),
      ),
    );
  }

  Widget _callingUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.phone,
          size: 100,
          color: Colors.green,
        ),
        const SizedBox(height: 20),
        Text(
          'Calling ${widget.leadName}...',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 20),
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            setState(() {
              isCalling = false;
              isAnswered = true;
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Answer'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            setState(() {
              isEnded = true;
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('End Call'),
        ),
      ],
    );
  }

  Widget _ongoingCallUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.phone,
          size: 100,
          color: Colors.green,
        ),
        const SizedBox(height: 20),
        Text(
          'In Call with ${widget.leadName}...',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            setState(() {
              isEnded = true; // Simulate call ended
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('End Call'),
        ),
      ],
    );
  }

  // UI when the call is ended
  Widget _callEndedUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.call_end,
          size: 100,
          color: Colors.red,
        ),
        const SizedBox(height: 20),
        const Text(
          'Call Ended',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('Back to Chat'),
        ),
      ],
    );
  }
}
