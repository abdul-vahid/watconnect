import 'dart:async';
import 'package:flutter/material.dart';

class CallPopupDialog extends StatefulWidget {
  final String callerName;
  final Function()? onReject;
  final Function(String callDuration)? onDurationUpdate;
  final Future<bool> Function()? onAccept;

  const CallPopupDialog({
    super.key,
    required this.callerName,
    this.onReject,
    this.onDurationUpdate,
    this.onAccept,
  });

  @override
  State<CallPopupDialog> createState() => _CallPopupDialogState();
}

class _CallPopupDialogState extends State<CallPopupDialog> {
  bool callAccepted = false;
  Timer? _timer;
  int _durationSeconds = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  void startCallTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _durationSeconds++;
      });
    });
  }

  void stopCallTimer() {
    _timer?.cancel();
    widget.onDurationUpdate?.call(formatDuration(_durationSeconds));
  }

  void handleAccept() async {
    if (widget.onAccept != null) {
      bool success = await widget.onAccept!();
      if (success) {
        setState(() => callAccepted = true);
        startCallTimer();
      }
    }
  }

  void handleReject() {
    stopCallTimer();
    widget.onReject?.call();
    Navigator.of(context).pop(); // Close dialog
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(callAccepted ? "In Call With" : "Incoming Call"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.callerName, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          if (callAccepted)
            Text(
              "Call Duration: ${formatDuration(_durationSeconds)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
        ],
      ),
      actions: [
        if (!callAccepted)
          ElevatedButton.icon(
            icon: Icon(Icons.call_end),
            onPressed: handleReject,
            label: Text("Reject"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        if (!callAccepted)
          ElevatedButton.icon(
            icon: Icon(Icons.call),
            onPressed: handleAccept,
            label: Text("Accept"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        if (callAccepted)
          ElevatedButton(
            onPressed: handleReject,
            child: Text("End Call"),
          )
      ],
    );
  }
}
