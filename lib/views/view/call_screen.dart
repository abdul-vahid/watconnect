// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/call_outgoing_socket.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/view_models/message_list_vm.dart';
import 'package:whatsapp/views/view/whatsapp_Call_guidelines.dart';

class CallScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> userData;
  final String wpNumber;
  final String leadName;
  final String parentId;

  const CallScreen(
      {super.key,
      required this.token,
      required this.userData,
      required this.wpNumber,
      required this.leadName,
      required this.parentId});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final outgoingCall callService = outgoingCall();
  String callStatus = 'Not Connected';
  bool isCalling = false;

  Timer? _callTimer;
  int _callDurationInSeconds = 0;

  TextEditingController permiController = TextEditingController(
    text: "We would like to call you to help support on your query",
  );

  bool showPermissionBox = false;

  Future<void> _initiateCall() async {
    setState(() {
      isCalling = true;
      callStatus = 'Connecting...';
    });

    try {
      await callService.connect(widget.token, widget.userData);
      bool result =
          await callService.startCall(widget.wpNumber, widget.leadName);
      setState(() {
        callStatus = 'Calling...';
      });
      print("result of api call ::::  $result");
      if (result) {
        _startCallTimer();
      } else {
        setState(() {
          isCalling = false;
          callStatus = 'Not Connected';
        });

        print("chaning the xall status:::::::$callStatus");
      }
    } catch (e) {
      setState(() {
        callStatus = 'Failed: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    callService.disconnectSocket();
    _callTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCallFailed = callStatus.toLowerCase().contains('failed');

    return WillPopScope(
      onWillPop: () async {
        if (isCalling ||
            callStatus == 'Connecting...' ||
            callStatus == 'Calling...') {
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColor.pageBgGrey,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              if (!(isCalling ||
                  callStatus == 'Connecting...' ||
                  callStatus == 'Calling...')) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text(
            "Audio Call",
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: AppColor.navBarIconColor,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 38.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 20),
                        width: double.infinity,
                        child: Column(
                          children: [
                            const Icon(Icons.call,
                                size: 60, color: Colors.green),
                            const SizedBox(height: 12),
                            Text(
                              widget.leadName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.wpNumber,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              callStatus,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: isCallFailed ? Colors.red : Colors.black,
                              ),
                            ),
                            if (isCalling) ...[
                              const SizedBox(height: 8),
                              Text(
                                _formatDuration(_callDurationInSeconds),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isCalling ? null : _initiateCall,
                        icon: const Icon(Icons.call, color: Colors.white),
                        label: const Text("Start Call",
                            style: TextStyle(color: Colors.white)),
                      ),
                      if (isCalling || callStatus == 'Calling...')
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            _callTimer?.cancel();
                            callService.rejectApiCall(null);
                            callService.disconnectSocket();
                            setState(() {
                              callStatus = 'Call Ended';
                              isCalling = false;
                            });
                          },
                          icon: const Icon(Icons.call_end, color: Colors.white),
                          label: const Text("End Call",
                              style: TextStyle(color: Colors.white)),
                        ),
                    ],
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showPermissionBox = !showPermissionBox;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF010C1F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.more_horiz_outlined, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Request Permission",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  /// Permission Box
                  if (showPermissionBox) ...[
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Message"),
                      ],
                    ),
                    TextField(
                      controller: permiController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showPermissionBox = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.navBarIconColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Cancel",
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            MessageViewModel ms = MessageViewModel(context);
                            final prefs = await SharedPreferences.getInstance();
                            String? number = prefs.getString('phoneNumber');

                            Map<String, dynamic> body = {
                              "messaging_product": "whatsapp",
                              "recipient_type": "individual",
                              "to": widget.wpNumber,
                              "type": "interactive",
                              "interactive": {
                                "type": "call_permission_request",
                                "action": {"name": "call_permission_request"},
                                "body": {"text": permiController.text.trim()}
                              }
                            };

                            await ms
                                .sendMessage(number: number, addmsModel: body)
                                .then((onValue) async {
                              print("valu:::::::  $onValue");
                              String msgId = onValue['messages'][0]['id'];

                              Map<String, dynamic> historyMap = {
                                "parent_id": widget.parentId,
                                "name": widget.leadName,
                                "message": permiController.text.trim(),
                                "whatsapp_number": widget.wpNumber,
                                "status": "Outgoing",
                                "recordtypename": "lead",
                                "is_read": true,
                                "message_id": msgId,
                                "business_number": number
                              };

                              await ms
                                  .sendmsgmobile(msgmobilbody: historyMap)
                                  .then((onValue) {
                                setState(() {
                                  showPermissionBox = false;
                                });
                                EasyLoading.showToast("Permission Requested");
                              });
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.navBarIconColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Send",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 46),

                  const WhatsAppCallGuidelines()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDurationInSeconds++;
      });
    });
  }
}

String _formatDuration(int seconds) {
  final Duration duration = Duration(seconds: seconds);
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final String minutes = twoDigits(duration.inMinutes.remainder(60));
  final String secs = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$secs";
}
