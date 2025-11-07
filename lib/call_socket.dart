// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:whatsapp/main.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/utils/app_constants.dart';
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
  String? devId;
  Map<String, dynamic>? user;
  String? busNum;

  // WebRTC & Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _isRendererInitialized = false;

  // Audio Recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  int _recordingDuration = 0;
  Timer? _recordingTimer;
  String? _recordingFilePath;
  String? _currentCallId;

  // UI
  BuildContext? _dialogContext;
  OverlayEntry? _callOverlay;
  StateSetter? _popupSetState;
  bool _dialogShown = false;

  // Timers
  Timer? _callTimer;
  Timer? _outcallTimer;
  int _duration = 0;
  bool _callAccepted = false;

  // Events
  final _callEventController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get callEvents => _callEventController.stream;

  // Public methods
  IO.Socket? get socket => _socket;

  void dispose() {
    _statusSocket?.disconnect();
    _statusSocket = null;
    _isStatusConnected = false;

    _cleanUpCallConnection();

    if (!_callEventController.isClosed) _callEventController.close();
    _audioPlayer.dispose();

    // Dispose recording resources
    _stopRecording();
    _audioRecorder.dispose();
  }

  // ===================== AUDIO RECORDING METHODS =====================

  Future<void> _initializeAudioRecorder() async {
    try {
      final permission = await Permission.microphone.request();
      if (!permission.isGranted) {
        print('⚠️ Microphone permission not granted');
      }
    } catch (e) {
      print('❌ Error initializing audio recorder: $e');
    }
  }

  Future<void> _startRecording(String callId) async {
    try {
      if (_isRecording) return;

      final hasPermission = await Permission.microphone.isGranted;
      if (!hasPermission) {
        final status = await Permission.microphone.request();
        if (!status.isGranted) {
          throw Exception('Microphone permission denied');
        }
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _recordingFilePath =
          '${directory.path}/incoming_call_${callId}_$timestamp.m4a';

      print('🎙️ Starting recording for incoming call: $callId');
      print('📁 Recording path: $_recordingFilePath');

      // Configure recording settings
      final config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 2,
      );

      await _audioRecorder.start(config, path: _recordingFilePath!);

      _isRecording = true;
      _recordingDuration = 0;
      _currentCallId = callId;

      // Start recording duration timer
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration++;
        _popupSetState?.call(() {});
      });

      print('✅ Recording started successfully for incoming call');
      _trackCallEvent('incoming_call_recording_started', {'call_id': callId});
    } catch (e, st) {
      print('❌ Failed to start recording for incoming call: $e');
      _handleError('Failed to start recording', e, st);
    }
  }

  Future<void> _stopRecording() async {
    try {
      print('🛑 Stopping recording for incoming call...');

      _recordingTimer?.cancel();
      _recordingTimer = null;

      if (_isRecording) {
        final recordingPath = await _audioRecorder.stop();

        _isRecording = false;

        if (recordingPath != null && recordingPath.isNotEmpty) {
          _recordingFilePath = recordingPath;

          // Upload recording to server
          await _uploadRecordingToServer(recordingPath);

          print('✅ Incoming call recording saved: $recordingPath');

          // Show popup to listen to recording
          _showRecordingPlaybackPopup(recordingPath);
        }

        _trackCallEvent('incoming_call_recording_stopped', {
          'duration': _recordingDuration,
          'file_path': _recordingFilePath,
          'call_id': _currentCallId
        });
      }
    } catch (e, st) {
      print('❌ Failed to stop recording for incoming call: $e');
      _handleError('Failed to stop recording', e, st);
    }
  }

  void _showRecordingPlaybackPopup(String filePath) {
    if (navigatorKey.currentContext == null) return;

    // Use a small delay to ensure the call popup is closed first
    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: true,
        builder: (context) => RecordingPlaybackDialog(
          filePath: filePath,
          duration: _recordingDuration,
          callId: _currentCallId ?? 'Unknown',
        ),
      );
    });
  }

  Future<void> _uploadRecordingToServer(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        print('❌ Recording file not found: $filePath');
        return;
      }

      final fileSize = await file.length();
      print(
          '📤 Uploading incoming call recording: $filePath (${fileSize ~/ 1024} KB)');

      // Convert to base64 for upload
      final bytes = await file.readAsBytes();
      final base64Audio = base64Encode(bytes);

      // Upload to server
      await _saveCallRecordingToServer(base64Audio, filePath);

      // Note: We don't delete the file immediately as user might want to play it
      print('✅ Incoming call recording uploaded to server');
    } catch (e, st) {
      print('❌ Recording upload failed: $e');
      // Don't rethrow - we don't want to break the call flow if upload fails
    }
  }

  Future<void> _saveCallRecordingToServer(
      String base64Audio, String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final drProvider = Provider.of<DashBoardController>(
          navigatorKey.currentContext!,
          listen: false);

      String businessNumber = "";
      if (drProvider.fromSalesForce) {
        businessNumber =
            prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
      } else {
        businessNumber = prefs.getString('phoneNumber') ?? "";
      }

      final Map<String, dynamic> recordingData = {
        "fileName":
            "IncomingCallRecording_${_currentCallId}_${DateTime.now().millisecondsSinceEpoch}.m4a",
        "base64Data": base64Audio,
        "callHistoryId": _currentCallId,
        "businessNumber": businessNumber,
        "whatsappNumber": "", // You might want to get this from call data
        "duration": _recordingDuration,
        "timestamp": DateTime.now().toIso8601String(),
        "fileSize": base64Audio.length,
        "direction": "incoming",
      };

      // Call your API to save the recording
      final callsViewModel = Provider.of<CallsViewModel>(
          navigatorKey.currentContext!,
          listen: false);
      // await callsViewModel.saveCallRecording(recordingData);

      _trackCallEvent('incoming_call_recording_uploaded', {
        'call_id': _currentCallId,
        'duration': _recordingDuration,
        'file_size': base64Audio.length
      });

      print('✅ Incoming call recording saved to server');
    } catch (e, st) {
      print('❌ Failed to save incoming call recording to server: $e');
    }
  }

  void _handleError(String message, dynamic error, [StackTrace? stackTrace]) {
    log('❌ $message: $error', stackTrace: stackTrace);
  }

  void _trackCallEvent(String event, [Map<String, dynamic>? properties]) {
    final analytics = {
      'event': event,
      'call_id': _currentCallId,
      'duration': _recordingDuration,
      'timestamp': DateTime.now().toIso8601String(),
      'business_number': busNum,
      ...?properties,
    };

    print('📊 Incoming Call Analytics: $analytics');
  }

  // ===================== SOCKET HANDLING =====================

  Future<void> connect(
      String token, dynamic userData, String devId, String busNum) async {
    this.token = token;
    user = userData;
    this.devId = devId;
    this.busNum = busNum;

    // Initialize audio recorder
    await _initializeAudioRecorder();

    print("its trying to connect to socket:::::::::::::::  🔁 Call socket ");
    if (_isConnected && _socket?.connected == true) {
      debugPrint("🔁 Call socket already connected.");
      _setupListeners();
      return;
    }

    _socket = _createSocket(token);
    _socket!
      ..onConnect((_) {
        _isConnected = true;
        debugPrint('✅ Call socket connected');

        // Add file details
        userData.addAll({
          'deviceId': devId,
          'business_number': busNum,
        });

        log("before we connect socket userdata::::   $userData   devi id :::  $devId busNum:::  $busNum ");

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
        connect(token!, user, devId!, busNum!);
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
      'https://admin.watconnect.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/ibs/socket.io')
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );
  }

  // ===================== LISTENERS =====================

  void _setupListeners() {
    var callData;
    _socket?.on("whatsapp_call_event", (data) async {
      log('\x1B[32m   incoming call data whatsapp_call_event   $data    ');
      _dialogShown = false;
      callData = data;
      final event = data['data']['event'];
      final dir = data['data']['direction'];

      busNum = data['data']['business_number'] ?? "";

      final prefs = await SharedPreferences.getInstance();
      DashBoardController drProvider =
          Provider.of(navigatorKey.currentContext!, listen: false);
      String selectedBusinessNumber = "";
      if (drProvider.fromSalesForce) {
        selectedBusinessNumber =
            prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
      } else {
        selectedBusinessNumber = prefs.getString('phoneNumber') ?? "";
      }

      print(
          "busNum call datat   :::   $busNum      selectedBusinessNumber     $selectedBusinessNumber");
      if (busNum != selectedBusinessNumber) {
        _closePopup();
        return;
      }

      if (event == "terminate") {
        _closePopup();
        return;
      }
      print("_dialogShown:::::::   be4 shoing popup        $_dialogShown");
      if (dir != "BUSINESS_INITIATED" && !_dialogShown) {
        _showCallPopup(data);
        _removeOverlay();
      }
    });

    void callAcceptedElsewhereHandler(dynamic payload) async {
      final prefs = await SharedPreferences.getInstance();
      final myDeviceId = prefs.getString(SharedPrefsConstants.deviceId) ?? "";

      log('\x1B[32m      payload of CALL_ACCEPT elsewhere::::: $payload');
      log('\x1B[32m    payload callData:: call_accepted_elsewhere ::: $callData');

      if (payload["call_id"] == callData['data']['call_id'] &&
          payload["business_number"] == callData['data']['business_number'] &&
          payload["accepted_by"] != myDeviceId) {
        _closePopup();

        _socket?.off("call_accepted_elsewhere", callAcceptedElsewhereHandler);
      } else {
        _socket?.off("call_accepted_elsewhere", callAcceptedElsewhereHandler);
      }
    }

    _socket?.on("call_accepted_elsewhere", callAcceptedElsewhereHandler);
  }

  void _setupStatusListeners() {
    _statusSocket?.on("whatsapp_statuses", (data) {
      log('\x1B[32m    incoming call whatsapp_statuses $data      ');
      final status = data["data"]["status"];
      log("📥 Call Status: $status");
      if (status == "COMPLETED" || status == "TERMINATE") {
        _closePopup();
        // Stop recording when call is completed
        _stopRecording();
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

    // Stop recording when popup is closed
    await _stopRecording();

    _cleanUpCallConnection();
    _removeOverlay();
  }

  // ===================== CALL HANDLING =====================

  Future<void> acceptApiCall(Map<String, dynamic> callData) async {
    log("call data receving just before accept api call     $callData");
    try {
      _currentCallId = callData['data']['call_id'];

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
          // _remoteRenderer.srcObject = _remoteStream;
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

      final prefs = await SharedPreferences.getInstance();
      String deviId = prefs.getString(SharedPrefsConstants.deviceId) ?? "";

      _socket?.emit("accept_call", {
        "call_id": callData['data']['call_id'],
        "business_number": callData['data']['business_number'],
        "deviceId": deviId
      });

      // Start recording when call is accepted
      if (_currentCallId != null && _currentCallId!.isNotEmpty) {
        await _startRecording(_currentCallId!);
      }

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

      // Stop recording if call is rejected
      await _stopRecording();

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
    // Stop recording
    await _stopRecording();

    // Stop local tracks
    _localStream?.getTracks().forEach((track) => track.stop());
    await _localStream?.dispose();

    // Stop remote tracks
    _remoteStream?.getTracks().forEach((track) => track.stop());
    await _remoteStream?.dispose();

    // Stop sender tracks
    final senders = await _peerConnection?.getSenders();
    senders?.forEach((s) => s.track?.stop());

    // Stop receiver tracks
    final receivers = await _peerConnection?.getReceivers();
    receivers?.forEach((r) => r.track?.stop());

    // Close peer connection
    await _peerConnection?.close();
    _peerConnection = null;

    _currentCallId = null;
  }

  // ===================== POPUP =====================

  Future<void> _showCallPopup(Map<String, dynamic> data) async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(
      UrlSource('https://admin.watconnect.com/user_images/ringtone.mp3'),
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
                  if (_isRecording) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fiber_manual_record,
                            color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Recording • ${_formatDuration(_recordingDuration)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
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

      // Stop recording when dialog is closed
      if (_isRecording) {
        _stopRecording();
      }
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

// Recording Playback Dialog Widget
class RecordingPlaybackDialog extends StatefulWidget {
  final String filePath;
  final int duration;
  final String callId;

  const RecordingPlaybackDialog({
    super.key,
    required this.filePath,
    required this.duration,
    required this.callId,
  });

  @override
  State<RecordingPlaybackDialog> createState() =>
      _RecordingPlaybackDialogState();
}

class _RecordingPlaybackDialogState extends State<RecordingPlaybackDialog> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _setupListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeAudio() async {
    try {
      setState(() {
        _isLoading = true;
      });

      _audioPlayer.onDurationChanged.listen((Duration d) {
        if (mounted) {
          setState(() {
            _totalDuration = d;
          });
        }
      });

      // Set up position update listener
      _audioPlayer.onPositionChanged.listen((Duration position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });

      // Set up player completion listener
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _playerState = PlayerState.stopped;
            _position = _totalDuration;
          });
        }
      });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error initializing audio: $e');
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load recording');
    }
  }

  void _setupListeners() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
    });
  }

  Future<void> _playPauseRecording() async {
    try {
      if (_playerState == PlayerState.playing) {
        await _audioPlayer.pause();
      } else {
        if (_playerState == PlayerState.stopped) {
          await _audioPlayer.play(DeviceFileSource(widget.filePath));
        } else {
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      print('❌ Error playing/pausing recording: $e');
      _showError('Failed to play recording');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioPlayer.stop();
      setState(() {
        _position = Duration.zero;
      });
    } catch (e) {
      print('❌ Error stopping recording: $e');
    }
  }

  void _seekRecording(double value) {
    final newPosition = Duration(milliseconds: (value * 1000).round());
    _audioPlayer.seek(newPosition);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String minutes = twoDigits(duration.inMinutes.remainder(60));
    final String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.audiotrack, color: Colors.blue),
          SizedBox(width: 8),
          Text(
            'Call Recording',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Call ID: ${widget.callId}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Duration: ${_formatDuration(Duration(seconds: widget.duration))}',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const CircularProgressIndicator()
          else ...[
            Slider(
              value: _position.inMilliseconds
                  .toDouble()
                  .clamp(0, _totalDuration.inMilliseconds.toDouble()),
              min: 0,
              max: _totalDuration.inMilliseconds.toDouble(),
              onChanged: (value) {
                final newPosition = Duration(milliseconds: value.round());
                _audioPlayer.seek(newPosition);
              },
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_position),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  _formatDuration(_totalDuration),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.stop, size: 30),
                  color: Colors.red,
                  onPressed: _stopRecording,
                ),
                IconButton(
                  icon: Icon(
                    _playerState == PlayerState.playing
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 50,
                  ),
                  color: Colors.blue,
                  onPressed: _playPauseRecording,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 30),
                  color: Colors.grey,
                  onPressed: () {
                    // Delete the recording file
                    try {
                      final file = File(widget.filePath);
                      if (file.existsSync()) {
                        file.deleteSync();
                      }
                      Navigator.of(context).pop();
                    } catch (e) {
                      _showError('Failed to delete recording');
                    }
                  },
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _stopRecording();
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
