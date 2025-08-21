// ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/call_outgoing_socket.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/view_models/call_view_model.dart';
import 'package:whatsapp/view_models/message_list_vm.dart';
import 'package:whatsapp/views/view/whatsapp_Call_guidelines.dart';

class CallScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> userData;
  final String wpNumber;
  final String leadName;
  final String? parentId;

  const CallScreen(
      {super.key,
      required this.token,
      required this.userData,
      required this.wpNumber,
      required this.leadName,
      this.parentId});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  // final outgoingCall callService = outgoingCall();
  String callStatus = 'Not Connected';
  bool isCalling = false;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  IO.Socket? _socket;
  IO.Socket? _statusSocket;
  bool _isConnected = false;
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  Timer? _callTimer;
  int _callDurationInSeconds = 0;
  bool _rendererDisposed = false;
  TextEditingController permiController = TextEditingController(
    text: "We would like to call you to help support on your query",
  );

  bool showPermissionBox = false;
  String callId = "";

  Future<void> _initiateCall() async {
    safeSetState(() {
      isCalling = true;
      callStatus = 'Connecting...';
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      String deviId =
          await prefs.getString(SharedPrefsConstants.deviceId) ?? "";
      String busNum = "";
      DashBoardController drProvider = Provider.of(context, listen: false);

      if (drProvider.fromSalesForce) {
        busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
      } else {
        busNum = prefs.getString('phoneNumber') ?? "";
      }

      await connect(widget.token, widget.userData, deviId, busNum);
      bool result = await startCall(widget.wpNumber, widget.leadName);

      safeSetState(() {
        callStatus = 'Calling...';
      });

      print("result of api call ::::  $result");
      if (result) {
      } else {
        safeSetState(() {
          isCalling = false;
          callStatus = 'Not Connected';
        });

        print("chaning the xall status:::::::$callStatus");
      }
    } catch (e) {
      safeSetState(() {
        callStatus = 'Failed: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    disconnectSocket();
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
                            rejectApiCall(null);
                            disconnectSocket();
                            safeSetState(() {
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
                      safeSetState(() {
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
                            safeSetState(() {
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
                            String number = "";

                            DashBoardController drProvider =
                                Provider.of(context, listen: false);

                            if (drProvider.fromSalesForce) {
                              number = prefs.getString(
                                      SharedPrefsConstants.sfBusinessNumber) ??
                                  "";
                            } else {
                              number = prefs.getString('phoneNumber') ?? "";
                            }

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
                              if (widget.parentId != null) {
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
                              } else {
                                setState(() {
                                  showPermissionBox = false;
                                });
                                EasyLoading.showToast("Permission Requested");
                              }
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
      if (!mounted) {
        timer.cancel();
        return;
      }
      safeSetState(() {
        _callDurationInSeconds++;
      });
    });
  }

  void disconnectSocket() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
    print("🧹 outgoing WebSocket fully cleaned up");
  }

  Future<void> connect(String token, Map<String, dynamic> userData,
      String devId, String busNum) async {
    if (_isConnected && _socket?.connected == true) {
      debugPrint("🔁 outgoing Call socket already connected.");
      return;
    }
    print("devId:::::::  ${devId}         ${busNum}");
    userData.addAll({
      'deviceId': devId,
      'business_number': busNum,
    });

    log("outgoing call user data :: :   $userData");

    _socket = IO.io(
      'https://sandbox.watconnect.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/swp/socket.io')
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket
      ?..onConnect((_) {
        _isConnected = true;
        debugPrint('✅ Call socket connected for outgoing call');
        _socket?.emit("setup", userData);
      })
      ..onDisconnect((_) async {
        _isConnected = false;
        debugPrint('❌ Call socket disconnected');
        await Future.delayed(const Duration(seconds: 2));
        connect(token, userData, devId, busNum);
      })
      ..onConnectError((err) {
        _isConnected = false;
        debugPrint('❌ Call socket connection error: $err');
      })
      ..onError((data) => debugPrint("⚠️ Socket error: $data"))
      ..onReconnect((_) => debugPrint("🔁 Reconnecting socket..."))
      ..onReconnectFailed((_) => debugPrint("❌ Reconnect failed"))
      ..connect();

    _setupListeners(token);
  }

  void _setupListeners(String tkn) {
    _socket?.on("whatsapp_call_event", (data) {
      log('\x1B[32m    outgoing   whatsapp_call_event::::::::::::::    $data');
      final event = data['data']['event'];
      final dir = data['data']['direction'];
      final sdp = data['data']['sdp'] ?? "";
      callId = data['data']['call_id'];

      print("event ::::::  $event    $dir");

      if (event == "terminate" && dir == "BUSINESS_INITIATED") {
        rejectApiCall(data);

        _callTimer?.cancel();
        rejectApiCall(null);
        disconnectSocket();

        safeSetState(() {
          callStatus = 'Call Ended';
          isCalling = false;
        });

        return;
      }

      if (event == "connect" && dir == "BUSINESS_INITIATED") {
        connectStausSocket(tkn);
        // _showOutgoingCallPopup(data);
        if (sdp.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 300), () {
            safeHandleSdp(sdp);
          });
        }
      }
    });
  }

  Future<bool> rejectApiCall(Map<String, dynamic>? callData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final drProvider =
          Provider.of<DashBoardController>(context, listen: false);

      final number = drProvider.fromSalesForce
          ? (prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "")
          : (prefs.getString('phoneNumber') ?? "");

      final payload = {
        "call_id": callData?['data']?['call_id'] ?? callId,
        "business_number": number,
      };

      final callsViewModel =
          Provider.of<CallsViewModel>(context, listen: false);
      final response = await callsViewModel.callRejectApi(payload);

      if (response == null) {
        print("❌ callRejectApi returned null");
        return false;
      }

      final decodedResponse = jsonDecode(response);
      print("✅ rejectApiCall response: $decodedResponse");

      return decodedResponse['success'] == true;
    } catch (e, st) {
      print("❌ Error during reject: $e\n$st");
      return false;
    } finally {
      disposeAll();
    }
  }

  void disposeAll() async {
    try {
      print("🧹 Cleaning up resources...");

      // Stop and dispose local stream

      _rendererDisposed = true;

      // Disconnect sockets
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      _statusSocket?.disconnect();
      _statusSocket?.dispose();
      _statusSocket = null;
      _isConnected = false;

      print("✅ All resources released successfully.");
    } catch (e) {
      print("❌ Error while disposing resources: $e");
    }
  }

  Future<bool> startCall(String wpnumber, String leadName) async {
    try {
      await _remoteRenderer.initialize();

      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
        },
        'video': false,
      });

      _peerConnection = await createPeerConnection({
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ],
      });

      _peerConnection?.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.SendRecv),
      );

      _localStream!.getAudioTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        print("📞 onTrack fired");

        if (event.streams.isNotEmpty && !_remoteRenderer.renderVideo) {
          try {
            _remoteRenderer.srcObject = event.streams[0];
          } catch (e) {
            print("⚠️ Could not set remote stream: $e");
          }
        }
      };

      _peerConnection!.getSenders().then((senders) {
        for (var sender in senders) {
          if (sender.track?.kind == 'video') {
            _peerConnection!.removeTrack(sender);
          }
        }
      });

      RTCSessionDescription offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
      });

      await _peerConnection!.setLocalDescription(offer);

      final prefs = await SharedPreferences.getInstance();
      String? number = "";

      DashBoardController drProvider = Provider.of(context, listen: false);
      if (drProvider.fromSalesForce) {
        number = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
      } else {
        number = prefs.getString('phoneNumber');
      }

      if (number == null) {
        print("⚠️ Business number not found.");
        return false;
      }

      Map<String, dynamic> acceptBody = {
        "payload": {
          "messaging_product": "whatsapp",
          "to": wpnumber,
          "action": "connect",
          "session": {"sdp_type": "offer", "sdp": offer.sdp}
        },
        "business_number": number
      };

      String callId = "";

      final value = await Provider.of<CallsViewModel>(
        context,
        listen: false,
      ).callAcceptApi(acceptBody);

      var apires = jsonDecode(value ?? "");
      print("apires['success'] ::::::::  ${apires['success']}");

      if (apires['success'] == false) {
        EasyLoading.showToast(apires['meta_response']['error']['message'])
            .then((onValue) {
          EasyLoading.showToast(
              apires['meta_response']['error']['error_user_msg']);
        });

        return false;
      }

      callId = apires['meta_response']['calls'][0]['id'];
      print("Call accepted with ID: $callId");

      Map<String, dynamic> payload = {
        "name": leadName,
        "whatsapp_number": wpnumber,
        "business_number": number,
        "status": "Outgoing",
        "event": "connect",
        "call_id": callId,
        "start_time":
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        "sdp": offer.sdp,
        "sdp_type": "connect",
        "direction": "BUSINESS_INITIATED"
      };

      await Provider.of<CallsViewModel>(
        context,
        listen: false,
      ).outgoingCallApi(payload);

      return true; // ✅ Success
    } catch (e, stacktrace) {
      print("❌ Error in startCall: $e");
      print(stacktrace);
      return false; // ❌ Failure
    }
  }

  Future<void> safeHandleSdp(String sdp) async {
    int retry = 0;
    while (_peerConnection == null && retry < 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      retry++;
    }

    if (_peerConnection != null) {
      await handleSdp(sdp);
    } else {
      log("❌ PeerConnection still null after waiting.");
    }
  }

  Future<void> handleSdp(String sdp) async {
    print("📞 handleSdp() called");

    if (_peerConnection == null) {
      log("❌ PeerConnection is null. Cannot handle SDP.");
      return;
    }

    try {
      RTCSessionDescription description = RTCSessionDescription(sdp, "answer");
      await _peerConnection!.setRemoteDescription(description);

      log("✅ Remote SDP answer set successfully.");
    } catch (e) {
      log("❌ Error in handleSDP: $e");
    }
  }

  void connectStausSocket(String token) {
    _statusSocket = IO.io(
      'https://sandbox.watconnect.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/swp/socket.io')
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );

    _statusSocket
      ?..onConnect((_) {
        debugPrint('✅ Call status socket connected');
      })
      ..onDisconnect((_) async {
        debugPrint('❌ Call status socket disconnected');
        await Future.delayed(const Duration(seconds: 2));
      })
      ..onConnectError((err) {
        debugPrint('❌ Call status socket connection error: $err');
      })
      ..onError((data) => debugPrint("⚠️ Status socket error: $data"))
      ..onReconnect((_) => debugPrint("🔁 Reconnecting status socket..."))
      ..onReconnectFailed((_) => debugPrint("❌ Status reconnect failed"))
      ..connect();

    _setupStatusListeners();
  }

  void _setupStatusListeners() {
    _statusSocket?.on("whatsapp_statuses", (data) {
      final status = data["data"]["status"];
      log('\x1B[32m  outgoing Call Status Update:     $status          $data  ');

      if (status == "ACCEPTED") {
        // Start timer only when call is accepted
        _startCallTimer();

        safeSetState(() {
          callStatus = "In Call";
          isCalling = true;
        });
      } else if (status == "RINGING") {
        safeSetState(() {
          callStatus = "Ringing...";
        });
      } else if (status == "COMPLETED" || status == "TERMINATE") {
        // Stop timer when call ends
        _callTimer?.cancel();

        safeSetState(() {
          callStatus = "Call Ended";
          isCalling = false;
          _callDurationInSeconds = 0;
        });
      }
    });
  }

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }
}

String _formatDuration(int seconds) {
  final Duration duration = Duration(seconds: seconds);
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final String minutes = twoDigits(duration.inMinutes.remainder(60));
  final String secs = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$secs";
}
