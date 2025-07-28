// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:async';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/main.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:whatsapp/view_models/call_view_model.dart';

class CallSocketService {
  // final StreamController<Map<String, dynamic>> _callEventController =
  //     StreamController<Map<String, dynamic>>.broadcast();

  // Stream<Map<String, dynamic>> get callEvents => _callEventController.stream;

  static final CallSocketService _instance = CallSocketService._internal();
  factory CallSocketService() => _instance;

  CallSocketService._internal();
  final AudioPlayer _audioPlayer = AudioPlayer();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  IO.Socket? callSocket;
  BuildContext? _dialogContext;
  Timer? _callTimer;
  int _duration = 0;
  bool _callAccepted = false;
  bool _dialogShown = false;
  OverlayEntry? _callOverlay;
  StateSetter? _popupSetState;

  final _callEventController = StreamController<dynamic>.broadcast();

  Stream<dynamic> get callEvents => _callEventController.stream;

  void connect(String token, Map<String, dynamic> userId) {
    try {
      print("📲 Setting up WhatsApp call socket ${callSocket == null}");
      disconnectSocket();

      callSocket = IO.io(
        'https://sandbox.watconnect.com',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setPath('/swp/socket.io')
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .build(),
      );

      callSocket!.connect();

      callSocket!.onConnect((_) {
        print('✅ Connected to call WebSocket');
        callSocket!.emit("setup", userId);
      });

      callSocket!.on("whatsapp_call_event", (data) {
        log('\x1B[95mFCM     data receving in calling socket::::::::::::::::::::::::::::::::::::::::::::::::::');
        print(
            "data received while calling:::::::::::  ${_dialogShown}  ${data}");

        final event = data['data']['event'];
        if (event != "terminate") {
          _callEventController.add(data['data']);
          if (!_dialogShown) {
            _showCallPopup(data);
          }
        } else {
          _closePopup();
        }
      });

      callSocket!.onDisconnect((_) => _closePopup());
      callSocket!.onError((_) => _closePopup());
    } catch (e) {
      print("catching errors in call socket    $e");
    }
  }

  void disconnectSocket() {
    if (callSocket != null) {
      callSocket!.disconnect();
      callSocket!.destroy();
      callSocket = null;
      print("WebSocket fully cleaned up");
    }
  }

  Future<void> _showCallPopup(Map<String, dynamic> data) async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(
      UrlSource('https://sandbox.watconnect.com/user_images/ringtone.mp3'),
      volume: 1.0,
    );

    _duration = 0;
    _callAccepted = false;
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
              backgroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone_in_talk_rounded,
                      size: 60, color: Colors.greenAccent),
                  const SizedBox(height: 16),
                  Text(
                    "${data['data']['name']} is calling...",
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  if (_callAccepted)
                    Text(
                      _formatDuration(_duration),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await acceptApiCall(data);
                          _popupSetState?.call(() async {
                            _callAccepted = true;
                            await _audioPlayer.stop();
                            await _audioPlayer.dispose();
                          });
                        },
                        icon: const Icon(Icons.call),
                        label: const Text("Accept"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await rejectApiCall(data);
                          Navigator.of(_dialogContext!).pop();
                        },
                        icon: const Icon(Icons.call_end),
                        label: const Text("Reject"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  )
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
      // _removeOverlay();
    });
  }

  void _closePopup() {
    if (_dialogContext != null) {
      Navigator.of(_dialogContext!).pop();
      _dialogContext = null;
    }
    _callTimer?.cancel();
    _callTimer = null;
    _removeOverlay();
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Future<void> acceptApiCall(Map<String, dynamic> callData) async {
    try {
      final Map<String, dynamic> configuration = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ]
      };

      _peerConnection = await createPeerConnection(configuration);

      _remoteStream = await createLocalMediaStream('remote');
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          _remoteRenderer.srcObject = _remoteStream;
        }
      };

      final offer = RTCSessionDescription(
        callData['data']['sdp'],
        'offer',
      );
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

      if (_callTimer != null) return;
      _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _duration++;
        _popupSetState?.call(() {});
      });
    } catch (e) {
      print("❌ Error on accept: $e");
      _peerConnection?.close();
      _peerConnection = null;
    }
  }

  Future<void> rejectApiCall(Map<String, dynamic> callData) async {
    try {
      final payload = {
        "call_id": callData['data']['call_id'],
        "business_number": callData['data']['business_number']
      };
      _callTimer?.cancel();
      _callTimer = null;

      await Provider.of<CallsViewModel>(navigatorKey.currentContext!,
              listen: false)
          .callRejectApi(payload);
    } catch (e) {
      print("❌ Error during reject: $e");
    } finally {
      await _audioPlayer.stop();
      await _audioPlayer.dispose();
      _cleanUpCallConnection();
    }
  }

  Future<void> _cleanUpCallConnection() async {
    _peerConnection?.close();
    _peerConnection = null;
    // await Helper.setMicrophoneMute(true); // Optional safety
    await Helper.setSpeakerphoneOn(false);
    _localStream?.dispose();
    _localStream = null;
    await _audioPlayer.stop();
    await _audioPlayer.dispose();

    _remoteStream?.dispose();
    _remoteStream = null;

    _remoteRenderer.srcObject = null;
  }

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
                    if (!_dialogShown) {
                      _showCallPopup(data);
                    }
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
}
