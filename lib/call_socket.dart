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
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/view_models/call_view_model.dart';
import 'package:whatsapp/view_models/lead_controller.dart';
import 'package:whatsapp/view_models/message_list_vm.dart';

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
  String startTime = "";

  // Call Data Storage (for Salesforce API)
  Map<String, dynamic>? _currentCallData;
  String? _leadName;
  String? _wpNumber;
  String? _callId;
  RTCSessionDescription? _offer;

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

          // Verify the recorded file
          final audioFile = File(recordingPath);
          print('Audio file exists: ${audioFile.existsSync()}');
          print('File size: ${audioFile.lengthSync()} bytes');

          // Upload recording and call Salesforce API
          await _handleRecordingUploadAndSalesforce(recordingPath);

          print('✅ Incoming call recording saved: $recordingPath');

          // Show popup to listen to recording
          // _showRecordingPlaybackPopup(recordingPath);
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

  Future<void> _handleRecordingUploadAndSalesforce(String recordingPath) async {
    try {
      if (navigatorKey.currentContext == null) {
        print('❌ Context not available for Salesforce API call');
        return;
      }

      final audioFile = File(recordingPath);
      if (!audioFile.existsSync()) {
        print('❌ Recording file not found: $recordingPath');
        return;
      }

      // Step 1: Upload recording file to get file ID

      // Step 2: Check if Salesforce integration is enabled and call API
      final drProvider = Provider.of<DashBoardController>(
          navigatorKey.currentContext!,
          listen: false);

      if (drProvider.fromSalesForce) {
        final callsViewModel = Provider.of<CallsViewModel>(
            navigatorKey.currentContext!,
            listen: false);

        final dbResponse = await callsViewModel.uploadRecFiledb(audioFile);
        print("dbResponse:::: of file rec audio api ::: $dbResponse");

        final recFileId = jsonDecode(dbResponse)['records']?[0]?['title'];
        print("dbResponse:::: jsonDecode recFileId ::: $recFileId");

        if (recFileId == null) {
          print('❌ Failed to get recording file ID');
          return;
        }

        await _callSalesforceApi(recFileId);
      } else {
        final messageVM = Provider.of<MessageViewModel>(
            navigatorKey.currentContext!,
            listen: false);

        final callsViewModel = Provider.of<CallsViewModel>(
            navigatorKey.currentContext!,
            listen: false);
        final prefs = await SharedPreferences.getInstance();
        final dbResponse = await messageVM.uploadFiledb(audioFile, null, null);
        final fileId = jsonDecode(dbResponse)['records']?[0]?['id'];
        String businessNumber = prefs.getString('phoneNumber') ?? "";
        Map<String, dynamic> body = {
          "name": _leadName,
          "whatsapp_number": _wpNumber,
          "business_number": businessNumber,
          "event": "call_started",
          "status": "Outgoing",
          "call_id": _callId,
          "end_time": DateTime.now().toLocal().toIso8601String(),
          "sdp": _offer?.sdp ?? "", // Use the stored offer here
          "file_id": fileId
        };

        callsViewModel.outgoingCallApi(body);
        // ----------
        print('ℹ️ Salesforce integration not enabled, skipping API call');
      }
    } catch (e, st) {
      print('❌ Error in recording upload and Salesforce API: $e');
      _handleError('Recording upload and Salesforce API failed', e, st);
    }
  }

  Future<void> _callSalesforceApi(String recFileId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tentCode =
          prefs.getString(SharedPrefsConstants.sfNodeTennatCode) ?? "";
      final filePubUrl =
          "${AppConstants.baseImgUrl}public/$tentCode/attachment/$recFileId";

      final busNum =
          prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";

      print("dbResponse::::filePubUrl $filePubUrl");

      // Prepare the API body
      Map<String, dynamic> body = {
        "name": _leadName ?? "Unknown Lead",
        "whatsapp_number": _wpNumber ?? "Unknown Number",
        "business_number": busNum,
        "event": "call_started",
        "call_id": _callId ?? _currentCallId ?? "Unknown",
        "end_time": DateTime.now().toLocal().toIso8601String(),
        "status": "Incoming",
        "sdp": _offer?.sdp ?? "",
        "audio_url": filePubUrl
      };

      log("chatMessageController.createCallHistoryApi $body");

      // Call the Salesforce API
      final ChatMessageController chatMessageController =
          Provider.of<ChatMessageController>(navigatorKey.currentContext!,
              listen: false);

      await chatMessageController.createCallHistoryApi(body: body);

      print('✅ Salesforce call history API called successfully');
    } catch (e, st) {
      print('❌ Salesforce API call failed: $e');
      _handleError('Salesforce API call failed', e, st);
    }
  }

  // Store call data for Salesforce API
  void _storeCallDataForSalesforce({
    required Map<String, dynamic> callData,
    String? leadName,
    String? wpNumber,
    String? callId,
    RTCSessionDescription? offer,
  }) {
    _currentCallData = callData;
    _leadName = leadName;
    _wpNumber = wpNumber;
    _callId = callId;
    _offer = offer;

    print('📝 Stored call data for Salesforce API');
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
        ),
      );
    });
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

        LeadController leadCtrl =
            Provider.of(navigatorKey.currentContext!, listen: false);
        userData.addAll({
          'deviceId': devId,
          'business_number': busNum,
          'business_numbers': leadCtrl.allBusinessNumbers,
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

      // Reset dialog state
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
          "busNum call data: $busNum, selectedBusinessNumber: $selectedBusinessNumber");

      LeadController leadCtrl =
          Provider.of(navigatorKey.currentContext!, listen: false);

      if (!leadCtrl.allBusinessNumbers.contains(busNum)) {
        print('❌ Call not for current business number, ignoring');
        _closePopup();
        return;
      }

      if (event == "terminate") {
        print('📞 Call terminated event received');
        _closePopup();
        return;
      }

      print("_dialogShown before showing popup: $_dialogShown");

      if (dir != "BUSINESS_INITIATED" && !_dialogShown) {
        // Store call data for Salesforce API
        _storeCallDataForSalesforce(
          callData: data,
          leadName: data['data']['name']?.toString(),
          wpNumber: data['data']['whatsapp_number']?.toString(),
          callId: data['data']['call_id']?.toString(),
          offer: data['data']['sdp'] != null
              ? RTCSessionDescription(data['data']['sdp'], 'offer')
              : null,
        );

        print('📞 Showing call popup for incoming call');
        _showCallPopup(data);
        // REMOVED: _removeOverlay(); - This was causing the overlay to be removed immediately
      } else {
        print(
            'ℹ️ Call direction is BUSINESS_INITIATED or dialog already shown');
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
    // Remove existing overlay first
    _removeOverlay();

    // Get the correct context from navigatorKey
    final context = navigatorKey.currentContext;
    if (context == null) {
      print('❌ No context available for overlay');
      return;
    }

    _callOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 40, // Account for status bar
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.call, color: Colors.greenAccent, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Incoming Call",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${data['data']['name'] ?? 'Unknown'}",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
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

    try {
      Overlay.of(context).insert(_callOverlay!);
      print('✅ Overlay shown successfully');
    } catch (e) {
      print('❌ Failed to insert overlay: $e');
      _callOverlay = null;
    }
  }

  void _removeOverlay() {
    if (_callOverlay != null) {
      print('🗑️ Removing overlay');
      _callOverlay?.remove();
      _callOverlay = null;
    }
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
      LeadController leadCtrl =
          Provider.of(navigatorKey.currentContext!, listen: false);

      final prefs = await SharedPreferences.getInstance();
      String deviId = prefs.getString(SharedPrefsConstants.deviceId) ?? "";

      _socket?.emit("accept_call", {
        "call_id": callData['data']['call_id'],
        "business_number": callData['data']['business_number'],
        "deviceId": deviId,
        "business_numbers": leadCtrl.allBusinessNumbers ?? []
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
    // Stop any existing audio first
    await _audioPlayer.stop();

    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(
      UrlSource('https://admin.watconnect.com/user_images/ringtone.mp3'),
      volume: 1.0,
    );

    _duration = 0;
    _callAccepted = false;

    final context = navigatorKey.currentContext;
    if (context == null || _dialogShown) {
      print('❌ Cannot show dialog: context null or dialog already shown');
      return;
    }

    _dialogShown = true;

    // Show overlay first
    _showOverlay(data);

    showDialog(
      context: context,
      barrierDismissible: false, // Make it modal
      builder: (ctx) {
        _dialogContext = ctx;

        return StatefulBuilder(
          builder: (context, setState) {
            _popupSetState = setState;

            return PopScope(
              canPop: false, // Prevent back button from closing
              child: AlertDialog(
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
                    Text(
                      data['data']['whatsapp_number']?.toString() ??
                          'Unknown number',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    if (_callAccepted)
                      Text(
                        _formatDuration(_duration),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
                            print('✅ Accept button pressed');
                            await acceptApiCall(data);
                            setState(() => _callAccepted = true);
                            await _audioPlayer.stop();
                            _removeOverlay(); // Remove overlay when call is accepted
                          },
                        ),
                        _popupButton(
                          label: "Reject",
                          icon: Icons.call_end,
                          color: Colors.red,
                          onPressed: () async {
                            print('❌ Reject button pressed');
                            await rejectApiCall(data);
                            Navigator.of(_dialogContext!).pop();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      print('🔚 Dialog closed');
      _dialogContext = null;
      _dialogShown = false;
      _popupSetState = null;
      _removeOverlay(); // Ensure overlay is removed when dialog closes

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

  const RecordingPlaybackDialog({
    super.key,
    required this.filePath,
    required this.duration,
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
