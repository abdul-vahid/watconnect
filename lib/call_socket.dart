// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:async';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
// ignore: library_prefixes
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

  // User/Auth
  String? token;
  Map<String, dynamic>? user;
  String? busNum;

  // WebRTC & Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _isRendererInitialized = false;

  // UI
  BuildContext? _dialogContext;
  OverlayEntry? _callOverlay;
  StateSetter? _popupSetState;
  bool _dialogShown = false;

  // Timers
  Timer? _callTimer;
  Timer? _outcallTimer;
  int _duration = 0;
  // int _callDuration = 0;
  bool _callAccepted = false;

  // Events
  final _callEventController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get callEvents => _callEventController.stream;

  // Public methods
  IO.Socket? get socket => _socket;

  void dispose() {
    if (!_callEventController.isClosed) _callEventController.close();
    _audioPlayer.dispose();
  }

  // ===================== SOCKET HANDLING =====================

  Future<void> connect(String token, dynamic userData) async {
    this.token = token;
    user = userData;

    if (_isConnected && _socket?.connected == true) {
      debugPrint("🔁 Call socket already connected.");
      return;
    }

    _socket = _createSocket(token);
    _socket!
      ..onConnect((_) {
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
    debugPrint("🧹 WebSocket cleaned up");
  }

  void connectStatusSocket() {
    if (_isStatusConnected && _statusSocket?.connected == true) {
      debugPrint("🔁 Call status socket already connected.");
      return;
    }

    _statusSocket = _createSocket(token!);
    _statusSocket!
      ..onConnect((_) {
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
        debugPrint('❌ Call status socket error: $err');
      })
      ..onError((data) => debugPrint("⚠️ Status socket error: $data"))
      ..onReconnect((_) => debugPrint("🔁 Reconnecting status socket..."))
      ..onReconnectFailed((_) => debugPrint("❌ Status reconnect failed"))
      ..connect();

    _setupStatusListeners();
  }

  IO.Socket _createSocket(String token) {
    return IO.io(
      'https://sandbox.watconnect.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/swp/socket.io')
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );
  }

  // ===================== LISTENERS =====================

  void _setupListeners() {
    _socket?.on("whatsapp_call_event", (data) {
      log('\x1B[32m   incoming call data whatsapp_call_event   $data    ');
      _dialogShown = false;
      final event = data['data']['event'];
      final dir = data['data']['direction'];

      busNum = data['data']['business_number'] ?? "";

      if (event == "terminate") {
        _closePopup();
        return;
      }

      if (dir != "BUSINESS_INITIATED" && !_dialogShown) {
        _showCallPopup(data);
      }
    });
  }

  void _setupStatusListeners() {
    _statusSocket?.on("whatsapp_statuses", (data) {
      log('\x1B[32m    incoming call whatsapp_statuses $data      ');
      final status = data["data"]["status"];
      log("📥 Call Status: $status");

      if (status == "COMPLETED" || status == "TERMINATE") {
        _closePopup();
      }
    });
  }

  // ===================== UI HANDLING =====================

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

    Overlay.of(navigatorKey.currentContext!).insert(_callOverlay!);
  }

  void _removeOverlay() {
    _callOverlay?.remove();
    _callOverlay = null;
  }

  void _closePopup() async {
    if (_dialogContext != null && Navigator.canPop(_dialogContext!)) {
      Navigator.of(_dialogContext!).pop();
    }

    try {
      await _audioPlayer.stop();
    } catch (_) {}

    _statusSocket?.disconnect();
    _statusSocket = null;
    _isStatusConnected = false;

    _dialogContext = null;
    _dialogShown = false;
    _popupSetState = null;

    _callTimer?.cancel();
    _outcallTimer?.cancel();
    _callTimer = null;
    _outcallTimer = null;
    // _callDuration = 0;

    _cleanUpCallConnection();
    _removeOverlay();
  }

  // ===================== CALL HANDLING =====================

  Future<void> acceptApiCall(Map<String, dynamic> callData) async {
    try {
      _peerConnection = await createPeerConnection({
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'}
        ]
      });

      if (!_isRendererInitialized) {
        await _remoteRenderer.initialize();
        _isRendererInitialized = true;
      }

      _remoteStream = await createLocalMediaStream('remote');

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty && _isRendererInitialized) {
          _remoteStream = event.streams[0];
          _remoteRenderer.srcObject = _remoteStream;
        }
      };

      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(callData['data']['sdp'], 'offer'),
      );

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
          "session": {"sdp_type": "answer", "sdp": modifiedSdp}
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
      print("❌ Accept failed: $e");
      await _peerConnection?.close();
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
      await Provider.of<CallsViewModel>(navigatorKey.currentContext!,
              listen: false)
          .callRejectApi(payload);
    } catch (e) {
      print("❌ Reject failed: $e");
    } finally {
      await _audioPlayer.stop();
      _cleanUpCallConnection();
    }
  }

  Future<void> _cleanUpCallConnection() async {
    log("🧹 Cleaning call connection...");

    try {
      await _peerConnection?.close();
      _peerConnection = null;

      _localStream?.getTracks().forEach((track) => track.stop());
      _localStream = null;

      if (_isRendererInitialized) {
        _remoteRenderer.srcObject = null;
        await _remoteRenderer.dispose();
        _isRendererInitialized = false;
        //  _isRendererDisposed = false;
        log("✅ Renderer disposed");
      }
    } catch (e, s) {
      log("❌ Cleanup error: $e\n$s");
    }
  }

  // ===================== POPUP =====================

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

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}
