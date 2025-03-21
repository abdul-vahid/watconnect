import 'package:flutter/material.dart';

class VideoCallScreen extends StatefulWidget {
  final String? leadName;
  final String? wpnumber;

  const VideoCallScreen({super.key, this.leadName, this.wpnumber});

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool isCalling =
      true; // Calling state (true means calling, false means ongoing call)
  bool isAnswered =
      false; // Call answered state (can be toggled as a simulation)
  bool isEnded = false; // Call ended state

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
        title: Text(
          'Video Call with ${widget.leadName}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: isEnded
            ? _callEndedUI() // UI for ended call
            : isCalling
                ? _callingUI() // UI for calling state
                : _ongoingCallUI(), // UI for the ongoing call after the user picks up
      ),
    );
  }

  // UI when the call is in the "Calling" state
  Widget _callingUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Placeholder for the video feed or camera preview
        Container(
          height: 150,
          width: 150,
          color: Colors.grey,
          child: const Icon(
            Icons.videocam,
            size: 100,
            color: Colors.white,
          ),
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
              isCalling = false; // Simulate call answering
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
              isEnded = true; // Simulate call ended
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('End Call'),
        ),
      ],
    );
  }

  // UI when the call is ongoing (call is answered)
  Widget _ongoingCallUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Placeholder for the video feed or camera preview
        Container(
          height: 150,
          width: 150,
          color: Colors.grey,
          child: const Icon(
            Icons.videocam,
            size: 100,
            color: Colors.white,
          ),
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
