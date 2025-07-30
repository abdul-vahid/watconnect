import 'package:flutter/material.dart';
import 'package:whatsapp/call_outgoing_socket.dart';
// import 'package:whatsapp/services/outgoingCall.dart'; // Adjust path

class CallScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> userData;
  final String wpNumber;
  final String leadName;

  const CallScreen({
    super.key,
    required this.token,
    required this.userData,
    required this.wpNumber,
    required this.leadName,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final outgoingCall callService = outgoingCall();
  String callStatus = 'Not Connected';
  bool isCalling = false;

  Future<void> _initiateCall() async {
    setState(() {
      isCalling = true;
      callStatus = 'Connecting...';
    });

    try {
      await callService.connect(widget.token, widget.userData);
      await callService.startCall(widget.wpNumber, widget.leadName);
      setState(() {
        callStatus = 'Calling...';
      });
    } catch (e) {
      setState(() {
        callStatus = 'Failed: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    callService.disconnectSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audio Call")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Call Status: $callStatus"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isCalling ? null : _initiateCall,
              child: const Text("Start Call"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                callService.disconnectSocket();
                setState(() {
                  callStatus = 'Call Ended';
                  isCalling = false;
                });
              },
              child: const Text("End Call"),
            ),
          ],
        ),
      ),
    );
  }
}
