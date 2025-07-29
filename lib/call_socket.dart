// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:whatsapp/main.dart';
import 'package:whatsapp/view_models/call_view_model.dart';

class CallSocketService {
  static final CallSocketService _instance = CallSocketService._internal();
  factory CallSocketService() => _instance;
  CallSocketService._internal();

  // Socket
  IO.Socket? _socket;
  IO.Socket? _statusSocket;
  bool _isConnected = false;
  bool _isStatusConnected = false;

  // Auth & user
  String? token;
  Map<String, dynamic>? user;
  String? busNum;

  // WebRTC & Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  // UI
  BuildContext? _dialogContext;
  OverlayEntry? _callOverlay;
  StateSetter? _popupSetState;
  bool _dialogShown = false;

  // Timers
  Timer? _callTimer;
  Timer? _outcallTimer;
  int _duration = 0;
  int _callDuration = 0;
  bool _callAccepted = false;

  // Event Stream
  final _callEventController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get callEvents => _callEventController.stream;

  void dispose() => _callEventController.close();
  IO.Socket? get socket => _socket;

  // ===================== SOCKET CONNECTION =====================

  Future<void> connect(String token, dynamic userData) async {
    this.token = token;
    user = userData;

    if (_isConnected && _socket?.connected == true) {
      debugPrint("🔁 Call socket already connected.");
      return;
    }

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
        debugPrint('✅ Call socket connected');
        _socket?.emit("setup", userData);
      })
      ..onDisconnect((_) async {
        _isConnected = false;
        debugPrint('❌ Call socket disconnected');
        await Future.delayed(const Duration(seconds: 2));
        connect(token, userData);
      })
      ..onConnectError((err) {
        _isConnected = false;
        debugPrint('❌ Call socket connection error: $err');
      })
      ..onError((data) => debugPrint("⚠️ Socket error: $data"))
      ..onReconnect((_) => debugPrint("🔁 Reconnecting socket..."))
      ..onReconnectFailed((_) => debugPrint("❌ Reconnect failed"))
      ..connect();

    _setupListeners();
  }

  void disconnectSocket() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
    print("🧹 WebSocket fully cleaned up");
  }

  void connectStausSocket() {
    if (_isStatusConnected && _statusSocket?.connected == true) {
      debugPrint("🔁 Call status socket already connected.");
      return;
    }

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
        _isStatusConnected = true;
        debugPrint('✅ Call status socket connected');
        _statusSocket?.emit("setup", user);
      })
      ..onDisconnect((_) async {
        _isStatusConnected = false;
        debugPrint('❌ Call status socket disconnected');
        await Future.delayed(const Duration(seconds: 2));
        connect(token!, user);
      })
      ..onConnectError((err) {
        _isStatusConnected = false;
        debugPrint('❌ Call status socket connection error: $err');
      })
      ..onError((data) => debugPrint("⚠️ Status socket error: $data"))
      ..onReconnect((_) => debugPrint("🔁 Reconnecting status socket..."))
      ..onReconnectFailed((_) => debugPrint("❌ Status reconnect failed"))
      ..connect();

    _setupStatusListeners();
  }

  // ===================== LISTENERS =====================

  void _setupStatusListeners() {
    _statusSocket?.on("whatsapp_statuses", (data) {
      final status = data["data"]["status"];
      log("📥 Call Status Update: $status");

      if (status == "ACCEPTED") {
        _closePopup();
        _dialogShown = false;
        _showActiveCallPopup(navigatorKey.currentContext!, data);
      } else if (status == "COMPLETED" || status == "TERMINATE") {
        _closePopup();
      }
    });
  }

  void _setupListeners() {
    _socket?.on("whatsapp_call_event", (data) {
      log("whatsapp_call_event::::::::::::::    ${data}");
      final event = data['data']['event'];
      final dir = data['data']['direction'];
      final sdp = data['data']['sdp'] ?? "";

      busNum = data['data']['business_number'] ?? "";

      if (event == "terminate") {
        _closePopup();
        return;
      }

      if (event == "connect" && dir == "BUSINESS_INITIATED") {
        connectStausSocket();
        _showOutgoingCallPopup(data);
        if (sdp.isNotEmpty) handleSdp(sdp);
        return;
      }

      if (dir != "BUSINESS_INITIATED" && !_dialogShown) {
        _showCallPopup(data);
        return;
      }

      if (dir == "BUSINESS_INITIATED") {
        connectStausSocket();
        _showOutgoingCallPopup(data);
      }
    });
  }

  // ===================== UI METHODS =====================

  void _showOverlay(Map<String, dynamic> data) {
    if (_callOverlay != null) return;

    _callOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: 40,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.call, color: Colors.greenAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${data['data']['name']} is calling...",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    _removeOverlay();
                    if (!_dialogShown) _showCallPopup(data);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(navigatorKey.currentContext!)?.insert(_callOverlay!);
  }

  void _removeOverlay() {
    _callOverlay?.remove();
    _callOverlay = null;
  }

  void _closePopup() {
    if (_dialogContext != null) Navigator.of(_dialogContext!).pop();

    _dialogContext = null;
    _dialogShown = false;
    _popupSetState = null;

    _callTimer?.cancel();
    _callTimer = null;

    _outcallTimer?.cancel();
    _outcallTimer = null;

    _callDuration = 0;
    _removeOverlay();
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  // ===================== CALL HANDLING =====================

  Future<void> acceptApiCall(Map<String, dynamic> callData) async {
    try {
      final config = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'}
        ]
      };

      _peerConnection = await createPeerConnection(config);

      _remoteStream = await createLocalMediaStream('remote');
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          _remoteRenderer.srcObject = _remoteStream;
        }
      };

      final offer = RTCSessionDescription(callData['data']['sdp'], 'offer');
      await _peerConnection!.setRemoteDescription(offer);

      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': false,
      });

      for (var track in _localStream!.getTracks()) {
        _peerConnection!.addTrack(track, _localStream!);
      }

      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      final modifiedSdp =
          answer.sdp!.replaceAll("a=setup:actpass", "a=setup:active");

      final payload = {
        "payload": {
          "messaging_product": "whatsapp",
          "call_id": callData['data']['call_id'],
          "action": "accept",
          "session": {
            "sdp_type": "answer",
            "sdp": modifiedSdp,
          }
        },
        "business_number": callData['data']['business_number']
      };

      await Provider.of<CallsViewModel>(navigatorKey.currentContext!,
              listen: false)
          .callAcceptApi(payload);

      _callTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        _duration++;
        _popupSetState?.call(() {});
      });
    } catch (e) {
      print("❌ Error on accept: $e");
      _peerConnection?.close();
      _peerConnection = null;
    }
  }

  Future<void> rejectApiCall(Map<String, dynamic> callData,
      {bool isFromRing = false}) async {
    try {
      final payload = {
        "call_id":
            isFromRing ? callData['data']['id'] : callData['data']['call_id'],
        "business_number": busNum
      };

      _callTimer?.cancel();
      _callTimer = null;

      await Provider.of<CallsViewModel>(navigatorKey.currentContext!,
              listen: false)
          .callRejectApi(payload);
    } catch (e) {
      print("❌ Error during reject: $e");
    } finally {
      _cleanUpCallConnection();
    }
  }

  Future<void> _cleanUpCallConnection() async {
    _peerConnection?.close();
    _peerConnection = null;

    await Helper.setSpeakerphoneOn(false);
    await _audioPlayer.stop();

    _localStream?.dispose();
    _remoteStream?.dispose();
    _remoteRenderer.srcObject = null;

    if (_remoteRenderer.textureId != null) {
      await _remoteRenderer.dispose();
    }
  }

  Future<void> handleSdp(String sdp) async {
    try {
      if (_peerConnection == null) {
        log("PeerConnection is null. Cannot handle SDP.");
        return;
      }

      RTCSessionDescription description = RTCSessionDescription(sdp, "answer");
      await _peerConnection!.setRemoteDescription(description);
      log("✅ Remote SDP answer set successfully.");
    } catch (e) {
      log("❌ Error in handleSDP: $e");
    }
  }

  // ===================== POPUP UI METHODS OMITTED =====================
  // (Leave `_showCallPopup`, `_showOutgoingCallPopup`, `_showActiveCallPopup` as-is unless you want those cleaned up separately)
  Future<void> _showOutgoingCallPopup(Map<String, dynamic> data) async {
    if (navigatorKey.currentContext == null || _dialogShown) return;
    _dialogShown = true;

    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (ctx) {
        _dialogContext = ctx;
        return AlertDialog(
          backgroundColor: Colors.black87,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.ring_volume_rounded,
                  size: 60, color: Colors.greenAccent),
              const SizedBox(height: 16),
              Text(
                "${data['data']['name']}",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text("Ringing...", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.call_end),
                label: const Text("Reject"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await rejectApiCall(data, isFromRing: true);
                  Navigator.of(_dialogContext!).pop();
                },
              ),
            ],
          ),
        );
      },
    ).then((_) {
      _dialogContext = null;
      _dialogShown = false;
    });
  }

  void _showActiveCallPopup(BuildContext context, Map<String, dynamic> data) {
    _callDuration = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        _dialogContext = ctx;

        // Start call timer
        _outcallTimer?.cancel();
        _outcallTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          _callDuration++;
          _popupSetState?.call(() {});
        });

        return StatefulBuilder(
          builder: (context, setState) {
            _popupSetState = setState;
            final durationText = _formatDuration(_callDuration);

            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.call, size: 60, color: Colors.greenAccent),
                  const SizedBox(height: 12),
                  Text(
                    data['data']['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Call Duration: $durationText",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  _popupButton(
                    label: "End Call",
                    icon: Icons.call_end,
                    color: Colors.red,
                    onPressed: () async {
                      _outcallTimer?.cancel();
                      Navigator.of(_dialogContext!).pop();
                      await rejectApiCall(data, isFromRing: true);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showCallPopup(Map<String, dynamic> data) async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(
      UrlSource('https://sandbox.watconnect.com/user_images/ringtone.mp3'),
      volume: 1.0,
    );

    _duration = 0;
    _callAccepted = false;

    if (navigatorKey.currentContext == null || _dialogShown) return;
    _dialogShown = true;

    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: true,
      builder: (ctx) {
        _dialogContext = ctx;

        // Show overlay after dialog is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showOverlay(data);
        });

        return StatefulBuilder(
          builder: (context, setState) {
            _popupSetState = setState;

            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone_in_talk_rounded,
                      size: 60, color: Colors.greenAccent),
                  const SizedBox(height: 12),
                  Text(
                    "${data['data']['name']} is calling...",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (_callAccepted)
                    Text(
                      _formatDuration(_duration),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _popupButton(
                        label: "Accept",
                        icon: Icons.call,
                        color: Colors.green,
                        onPressed: () async {
                          await acceptApiCall(data);
                          setState(() => _callAccepted = true);
                          await _audioPlayer.stop();
                        },
                      ),
                      _popupButton(
                        label: "Reject",
                        icon: Icons.call_end,
                        color: Colors.red,
                        onPressed: () async {
                          await rejectApiCall(data);
                          Navigator.of(_dialogContext!).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      _dialogContext = null;
      _dialogShown = false;
      _popupSetState = null;
    });
  }

  Widget _popupButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 14),
      ),
      onPressed: onPressed,
    );
  }
}
