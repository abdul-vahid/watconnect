// ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
// import 'dart:log';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:whatsapp/call_socket.dart';
// import 'package:whatsapp/main.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/view_models/call_view_model.dart';
import 'package:whatsapp/view_models/lead_controller.dart';
import 'package:whatsapp/view_models/message_list_vm.dart';
import 'package:whatsapp/views/view/whatsapp_Call_guidelines.dart';

enum CallState {
  notConnected,
  connecting,
  calling,
  ringing,
  inCall,
  ended,
  failed
}

class CallScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> userData;
  final String wpNumber;
  final String leadName;
  final String? parentId;

  const CallScreen({
    super.key,
    required this.token,
    required this.userData,
    required this.wpNumber,
    required this.leadName,
    this.parentId,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  // State variables
  CallState _callState = CallState.notConnected;
  String _callStatus = 'Not Connected';
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  IO.Socket? _socket;
  IO.Socket? _statusSocket;
  bool _isSocketConnected = false;
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _isRemoteRendererInitialized = false;

  // Add this variable to store the offer
  RTCSessionDescription? _offer;
  String? startTime = "";

  Timer? _callTimer;
  int _callDurationInSeconds = 0;
  String _callId = "";

  // Audio Recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  int _recordingDuration = 0;
  Timer? _recordingTimer;
  String? _recordingFilePath;

  // Permission request state
  final TextEditingController _permissionController = TextEditingController(
    text: "We would like to call you to help support on your query",
  );
  bool _showPermissionBox = false;

  // Add these variables for better status tracking
  bool _isCallConnected = false;
  DateTime? _callStartTime;
  Timer? _connectionCheckTimer;

  @override
  void initState() {
    super.initState();
    _initializeRenderer();
    shouldHide();
    _initializeAudioRecorder();
  }

  bool shouldHideLeadNumber = false;
  Future<void> shouldHide() async {
    final prefs = await SharedPreferences.getInstance();
    shouldHideLeadNumber =
        prefs.getBool(SharedPrefsConstants.shouldHideNumber) ?? false;
    setState(() {});
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _disposeAllResources();
    super.dispose();
  }

  Future<void> _initializeRenderer() async {
    try {
      await _remoteRenderer.initialize();
      safeSetState(() {
        _isRemoteRendererInitialized = true;
      });
    } catch (e, st) {
      _handleError('Failed to initialize renderer', e, st);
    }
  }

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

  void _disposeAllResources() async {
    try {
      print('🔄 Disposing all resources...');

      _callTimer?.cancel();
      _callTimer = null;

      _recordingTimer?.cancel();
      _recordingTimer = null;

      _connectionCheckTimer?.cancel();
      _connectionCheckTimer = null;

      if (_isRecording) {
        await _stopRecording();
      }

      await _audioRecorder.dispose();

      // Dispose WebRTC resources
      await _disposeWebRTCResources();

      _statusSocket?.disconnect();
      _statusSocket?.dispose();
      _statusSocket = null;

      // Reset all state variables
      _callDurationInSeconds = 0;
      _callId = "";
      _offer = null;
      _recordingDuration = 0;
      _recordingFilePath = null;
      _isCallConnected = false;
      _callStartTime = null;

      print('✅ All resources disposed');
    } catch (e) {
      print("❌ Error while disposing resources: $e");
    }
  }

  Future<void> _disposeWebRTCResources() async {
    try {
      print('🔄 Disposing WebRTC resources...');

      if (_peerConnection != null) {
        await _peerConnection!.close();
        _peerConnection = null;
      }

      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) => track.stop());
        _localStream = null;
      }

      // Don't dispose the remote renderer completely, just reset it
      if (_isRemoteRendererInitialized) {
        _remoteRenderer.srcObject = null;
      }

      print('✅ WebRTC resources disposed');
    } catch (e) {
      print('❌ Error disposing WebRTC resources: $e');
    }
  }

  void _resetCallScreen() {
    if (!mounted) return;

    setState(() {
      _callState = CallState.notConnected;
      _callStatus = 'Not Connected';
      _callDurationInSeconds = 0;
      _callId = "";
      _isRecording = false;
      _recordingDuration = 0;
      _recordingFilePath = null;
      _showPermissionBox = false;
      _isCallConnected = false;
      _callStartTime = null;
    });

    print('🔄 Call screen reset for new call');
  }

  void _updateCallState(CallState newState, [String? statusMessage]) {
    if (!mounted) return;

    setState(() {
      _callState = newState;
      if (statusMessage != null) {
        _callStatus = statusMessage;
      }
    });

    print('📞 Call State Updated: $newState - $statusMessage');
  }

  void _handleError(String message, dynamic error, [StackTrace? stackTrace]) {
    log('❌ $message: $error', stackTrace: stackTrace);
    _updateCallState(CallState.failed, 'Error: something went wrong');
    EasyLoading.showError('Operation failed');
  }

  // Audio Recording Methods
  Future<void> _startRecording() async {
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
      _recordingFilePath = '${directory.path}/call_${_callId}_$timestamp.m4a';

      print('🎙️ Starting recording for call: $_callId');
      print('📁 Recording path: $_recordingFilePath');

      // Configure recording settings
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 2,
      );

      await _audioRecorder.start(config, path: _recordingFilePath!);

      safeSetState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });

      // Start recording duration timer
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || !_isRecording) {
          timer.cancel();
          return;
        }
        safeSetState(() {
          _recordingDuration++;
        });
      });

      print('✅ Recording started successfully');
      _trackCallEvent('recording_started');
    } catch (e, st) {
      _handleError('Failed to start recording', e, st);
    }
  }

  Future<void> _stopRecording() async {
    try {
      print('🛑 Stopping recording...');

      _recordingTimer?.cancel();
      _recordingTimer = null;

      final recordingPath = await _audioRecorder.stop();

      safeSetState(() {
        _isRecording = false;
      });

      if (recordingPath != null && recordingPath.isNotEmpty) {
        _recordingFilePath = recordingPath;

        final audioFile = File(recordingPath);
        print('Audio file exists: ${audioFile.existsSync()}');
        print('File size: ${audioFile.lengthSync()} bytes');

        final callsViewModel =
            Provider.of<CallsViewModel>(context, listen: false);

        //
        final drProvider =
            Provider.of<DashBoardController>(context, listen: false);
        final prefs = await SharedPreferences.getInstance();
        if (drProvider.fromSalesForce) {
          final dbResponse = await callsViewModel.uploadRecFiledb(audioFile);
          print("dbResponse::::  of file rec audio api :::   $dbResponse");

          final recFileId = jsonDecode(dbResponse)['records']?[0]?['title'];
          print("dbResponse:::: jsonDecode recFileIdi :::   $recFileId");

          final tentCode =
              prefs.getString(SharedPrefsConstants.sfNodeTennatCode) ?? "";
          var filePubUrl =
              "${AppConstants.baseImgUrl}public/$tentCode/attachment/$recFileId";

          print("dbResponse::::filePubUrl   $filePubUrl");
          String busNum =
              prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";

          Map<String, dynamic> body = {
            "name": widget.leadName,
            "whatsapp_number": widget.wpNumber,
            "business_number": busNum,
            "event": "call_started",
            "status": "Outgoing",
            "call_id": _callId,
            "end_time": DateTime.now().toLocal().toIso8601String(),
            "sdp": _offer?.sdp ?? "", // Use the stored offer here
            "audio_url": filePubUrl
          };

          log("chatMessageController.createCallHistoryApi $body");

          /// add audio rec key here

          ChatMessageController chatMessageController =
              Provider.of(context, listen: false);
          chatMessageController.createCallHistoryApi(body: body);
        } else {
          final messageVM =
              Provider.of<MessageViewModel>(context, listen: false);

          final dbResponse =
              await messageVM.uploadFiledb(audioFile, null, null);
          final fileId = jsonDecode(dbResponse)['records']?[0]?['id'];

          String businessNumber = prefs.getString('phoneNumber') ?? "";
          Map<String, dynamic> body = {
            "name": widget.leadName,
            "whatsapp_number": widget.wpNumber,
            "business_number": businessNumber,
            "event": "call_started",
            "status": "Outgoing",
            "call_id": _callId,
            "end_time": DateTime.now().toLocal().toIso8601String(),
            "sdp": _offer?.sdp ?? "", // Use the stored offer here
            "file_id": fileId
          };

          callsViewModel.outgoingCallApi(body);
        }

        // Show a button to play the recording
        // _showPlayRecordingOption(recordingPath);
      }

      _trackCallEvent('recording_stopped',
          {'duration': _recordingDuration, 'file_path': _recordingFilePath});
    } catch (e, st) {
      _handleError('Failed to stop recording', e, st);
    }
  }

  Future<void> _initiateCall() async {
    // If we're in ended state, reset first
    if (_callState == CallState.ended || _callState == CallState.failed) {
      _resetCallScreen();
      // Add a small delay to ensure state is reset
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (_callState == CallState.calling || _callState == CallState.inCall) {
      return;
    }

    _updateCallState(CallState.connecting, 'Connecting...');

    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = prefs.getString(SharedPrefsConstants.deviceId) ?? "";
      String businessNumber = "";

      final drProvider =
          Provider.of<DashBoardController>(context, listen: false);
      if (drProvider.fromSalesForce) {
        businessNumber =
            prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
      } else {
        businessNumber = prefs.getString('phoneNumber') ?? "";
      }

      // Reuse existing socket connection or create new one
      if (_socket == null || !_isSocketConnected) {
        await _connectToSocket(
            widget.token, widget.userData, deviceId, businessNumber);
      }

      final bool result = await _startCall(widget.wpNumber, widget.leadName);

      if (result) {
        _updateCallState(CallState.calling, 'Calling...');

        // Start connection check timer to detect when call is actually connected
        _startConnectionCheckTimer();
      } else {
        _updateCallState(CallState.failed, 'Call failed to initiate');
      }
    } catch (e, st) {
      _handleError('Call initiation failed', e, st);
    }
  }

  void _startConnectionCheckTimer() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Check if we have a peer connection and it's connected
      if (_peerConnection != null && _isCallConnected) {
        timer.cancel();
        _updateCallState(CallState.inCall, 'Call Connected');
        _startCallTimer();
        if (_callId.isNotEmpty && !_isRecording) {
          _startRecording();
        }
        print('✅ Call connection confirmed via WebRTC');
      }

      // If we're still in calling state after 10 seconds, assume call failed
      if (_callState == CallState.calling && _callDurationInSeconds > 10) {
        timer.cancel();
        _updateCallState(CallState.failed, 'Call failed to connect');
        EasyLoading.showError('Call failed to connect');
      }
    });
  }

  Future<void> _connectToSocket(String token, Map<String, dynamic> userData,
      String deviceId, String businessNumber) async {
    if (_isSocketConnected && _socket?.connected == true) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');
    LeadController leadCtrl = Provider.of(context, listen: false);
    userData.addAll({
      'deviceId': deviceId,
      'business_number': businessNumber,
    });

    _socket = IO.io(
      'https://admin.watconnect.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/ibs/socket.io')
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .setTimeout(10000)
          .build(),
    );

    _socket!
      ..onConnect((_) {
        _isSocketConnected = true;
        _socket?.emit("setup", userData);
        print('✅ Socket connected and ready for calls');
      })
      ..onDisconnect((_) {
        _isSocketConnected = false;
        print('❌ Socket disconnected');
      })
      ..onConnectError((err) {
        _isSocketConnected = false;
        _handleError('Socket connection error', err);
      })
      ..on('whatsapp_call_event', _handleCallEvent)
      ..connect();
  }

  void _handleCallEvent(dynamic data) {
    final event = data['data']['event'];
    final direction = data['data']['direction'];
    final sdp = data['data']['sdp'] ?? "";
    _callId = data['data']['call_id'];

    print('📞 Call Event: $event, Direction: $direction, Call ID: $_callId');

    if (event == "terminate" && direction == "BUSINESS_INITIATED") {
      _endCall(data);
      return;
    }

    if (event == "connect" && direction == "BUSINESS_INITIATED") {
      _connectStatusSocket(widget.token);
      if (sdp.isNotEmpty) {
        // Update status immediately when we get SDP
        _updateCallState(CallState.ringing, 'Ringing...');
        Future.delayed(const Duration(milliseconds: 300), () {
          _handleSdp(sdp);
        });
      }
    }
  }

  Future<bool> _startCall(String wpNumber, String leadName) async {
    try {
      if (!_isRemoteRendererInitialized) {
        await _initializeRenderer();
      }

      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
        'video': false,
      });

      _peerConnection = await _createPeerConnection();

      _localStream!.getAudioTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        print('🎵 WebRTC Track Received - Call is connected!');
        if (event.streams.isNotEmpty && !_remoteRenderer.renderVideo) {
          _remoteRenderer.srcObject = event.streams[0];
          // Mark call as connected when we receive remote track
          _isCallConnected = true;
        }
      };

      // Add connection state listener for immediate feedback
      _peerConnection!.onConnectionState = (state) {
        print('🔗 WebRTC Connection State: $state');
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          _isCallConnected = true;
          print('✅ WebRTC Connection Established');
        } else if (state ==
            RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
          _updateCallState(CallState.failed, 'Connection failed');
        }
      };

      // Add ice connection state listener
      _peerConnection!.onIceConnectionState = (state) {
        print('🧊 ICE Connection State: $state');
        if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
          _isCallConnected = true;
          print('✅ ICE Connection Established');
        }
      };

      // Store the offer in the class variable
      _offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
      });

      await _peerConnection!.setLocalDescription(_offer!);

      final prefs = await SharedPreferences.getInstance();
      String businessNumber = "";

      final drProvider =
          Provider.of<DashBoardController>(context, listen: false);
      if (drProvider.fromSalesForce) {
        businessNumber =
            prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
      } else {
        businessNumber = prefs.getString('phoneNumber') ?? "";
      }

      final Map<String, dynamic> acceptBody = {
        "payload": {
          "messaging_product": "whatsapp",
          "to": wpNumber,
          "action": "connect",
          "session": {
            "sdp_type": "offer",
            "sdp": _offer!.sdp
          } // Use _offer here
        },
        "business_number": businessNumber
      };

      final callsViewModel =
          Provider.of<CallsViewModel>(context, listen: false);
      final response = await callsViewModel.callAcceptApi(acceptBody);

      if (response == null) {
        _handleError('Call failed', 'No response from server');
        return false;
      }

      final apiResponse = jsonDecode(response);

      if (apiResponse['success'] == false) {
        final errorMessage = apiResponse['meta_response']['error']['message'];
        final userErrorMessage =
            apiResponse['meta_response']['error']['error_user_msg'];

        EasyLoading.showToast(errorMessage);
        EasyLoading.showToast(userErrorMessage);
        return false;
      }

      _callId = apiResponse['meta_response']['calls'][0]['id'];

      final Map<String, dynamic> payload = {
        "name": leadName,
        "whatsapp_number": wpNumber,
        "business_number": businessNumber,
        "status": "Outgoing",
        "event": "connect",
        "call_id": _callId,
        "start_time":
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        "sdp": _offer!.sdp, // Use _offer here
        "sdp_type": "connect",
        "direction": "BUSINESS_INITIATED"
      };

      await callsViewModel.outgoingCallApi(payload);

      _trackCallEvent('call_initiated');

      return true;
    } catch (e, st) {
      _handleError('Call start failed', e, st);
      return false;
    }
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ],
      'sdpSemantics': 'unified-plan',
      'iceTransportPolicy': 'all'
    };

    final peerConnection = await createPeerConnection(configuration);

    return peerConnection;
  }

  Future<void> _handleSdp(String sdp) async {
    if (_peerConnection == null) return;

    try {
      print('📝 Setting remote SDP description');
      final RTCSessionDescription description =
          RTCSessionDescription(sdp, "answer");
      await _peerConnection!.setRemoteDescription(description);
      print('✅ Remote SDP description set successfully');
    } catch (e, st) {
      _handleError('SDP handling failed', e, st);
    }
  }

  void _connectStatusSocket(String token) {
    _statusSocket = IO.io(
      'https://admin.watconnect.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/ibs/socket.io')
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .setTimeout(10000)
          .build(),
    );

    _statusSocket!
      ..onConnect((_) => print('✅ Status socket connected'))
      ..on('whatsapp_statuses', _handleStatusUpdate)
      ..connect();
  }

  Future<void> _handleStatusUpdate(dynamic data) async {
    final status = data["data"]["status"];
    _trackCallEvent('status_update', {'status': status});
    print("🔔 Socket status update: $status");

    switch (status) {
      case "ACCEPTED":
        // Don't wait for socket status - use WebRTC connection state instead
        print('📞 Call accepted by recipient');
        break;
      case "RINGING":
        _updateCallState(CallState.ringing, "Ringing...");
        break;
      case "COMPLETED":
      case "TERMINATE":
        _endCall(data);
        break;
      case "FAILED":
        _updateCallState(CallState.failed, "Call failed");
        break;
    }
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    _callDurationInSeconds = 0;
    _callStartTime = DateTime.now();

    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _callState != CallState.inCall) {
        timer.cancel();
        return;
      }
      setState(() {
        _callDurationInSeconds++;
      });
    });
  }

  Future<void> _endCall([Map<String, dynamic>? callData]) async {
    try {
      print('🛑 Ending call and resetting state...');

      // Cancel timers first
      _callTimer?.cancel();
      _callTimer = null;
      _connectionCheckTimer?.cancel();
      _connectionCheckTimer = null;

      // Stop recording if active
      if (_isRecording) {
        await _stopRecording();
      }

      // Update UI state immediately
      _updateCallState(CallState.ended, 'Call Ended');

      // Track the event
      _trackCallEvent('call_ended', {'duration': _callDurationInSeconds});

      // Make API call to reject/end the call
      await _rejectCallApi(callData);

      // Reset call-specific variables
      _callDurationInSeconds = 0;
      _callId = "";
      _offer = null;
      _isCallConnected = false;
      _callStartTime = null;

      // Dispose of WebRTC resources but keep socket connection
      await _disposeWebRTCResources();

      print('✅ Call ended successfully, ready for new call');

      // Show a message that user can make another call
      // EasyLoading.showSuccess('Call ended. You can make another call.');
    } catch (e, st) {
      _handleError('Error ending call', e, st);
    }
  }

  Future<void> _rejectCallApi(Map<String, dynamic>? callData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final drProvider =
          Provider.of<DashBoardController>(context, listen: false);

      final businessNumber = drProvider.fromSalesForce
          ? (prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "")
          : (prefs.getString('phoneNumber') ?? "");

      final payload = {
        "call_id": callData?['data']?['call_id'] ?? _callId,
        "business_number": businessNumber,
      };

      final callsViewModel =
          Provider.of<CallsViewModel>(context, listen: false);
      await callsViewModel.callRejectApi(payload);
    } catch (e, st) {
      _handleError('Call rejection failed', e, st);
    }
  }

  void _trackCallEvent(String event, [Map<String, dynamic>? properties]) {
    final analytics = {
      'event': event,
      'call_id': _callId,
      'duration': _callDurationInSeconds,
      'timestamp': DateTime.now().toIso8601String(),
      'business_number': widget.userData['business_number'],
      'wp_number': widget.wpNumber,
      ...?properties,
    };

    print('📊 Call Analytics: $analytics');
  }

  Future<void> _sendPermissionRequest() async {
    try {
      final messageViewModel =
          Provider.of<MessageViewModel>(context, listen: false);
      final prefs = await SharedPreferences.getInstance();

      String businessNumber = "";
      DashBoardController drProvider = Provider.of(context, listen: false);

      if (drProvider.fromSalesForce) {
        businessNumber =
            prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
      } else {
        businessNumber = prefs.getString('phoneNumber') ?? "";
      }

      final Map<String, dynamic> body = {
        "messaging_product": "whatsapp",
        "recipient_type": "individual",
        "to": widget.wpNumber,
        "type": "interactive",
        "interactive": {
          "type": "call_permission_request",
          "action": {"name": "call_permission_request"},
          "body": {"text": _permissionController.text.trim()}
        }
      };

      final response = await messageViewModel.sendMessage(
          number: businessNumber, addmsModel: body);

      if (widget.parentId != null) {
        String msgId = response['messages'][0]['id'];

        Map<String, dynamic> historyMap = {
          "parent_id": widget.parentId,
          "name": widget.leadName,
          "message": _permissionController.text.trim(),
          "whatsapp_number": widget.wpNumber,
          "status": "Outgoing",
          "recordtypename": "lead",
          "is_read": true,
          "message_id": msgId,
          "business_number": businessNumber
        };

        await messageViewModel.sendmsgmobile(msgmobilbody: historyMap);
      }

      setState(() => _showPermissionBox = false);
      EasyLoading.showToast("Permission Requested");
      _trackCallEvent('permission_request_sent');
    } catch (e, st) {
      _handleError('Permission request failed', e, st);
    }
  }

  void safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final isCallInProgress = _callState == CallState.calling ||
        _callState == CallState.ringing ||
        _callState == CallState.inCall;

    final isCallFailed = _callState == CallState.failed;
    final isCallEnded = _callState == CallState.ended;

    return WillPopScope(
      onWillPop: () async => !isCallInProgress,
      child: Scaffold(
        backgroundColor: AppColor.pageBgGrey,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              if (!isCallInProgress) Navigator.pop(context);
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
                            Icon(
                              isCallEnded ? Icons.call_end : Icons.call,
                              size: 60,
                              color: isCallEnded ? Colors.grey : Colors.green,
                            ),
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
                              shouldHideLeadNumber
                                  ? "*******${widget.wpNumber.substring(widget.wpNumber.length - 5)}"
                                  : widget.wpNumber,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _callStatus,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: isCallFailed ? Colors.red : Colors.black,
                              ),
                            ),
                            if (isCallInProgress) ...[
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
                            if (_isRecording) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.fiber_manual_record,
                                      color: Colors.red, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Recording • ${_formatDuration(_recordingDuration)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (isCallEnded) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Call Duration: ${_formatDuration(_callDurationInSeconds)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
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
                      if (isCallEnded || isCallFailed)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _initiateCall,
                          icon: const Icon(Icons.call, color: Colors.white),
                          label: const Text("New Call",
                              style: TextStyle(color: Colors.white)),
                        )
                      else if (!isCallInProgress)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _initiateCall,
                          icon: const Icon(Icons.call, color: Colors.white),
                          label: const Text("Start Call",
                              style: TextStyle(color: Colors.white)),
                        ),
                      if (isCallInProgress)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _endCall,
                          icon: const Icon(Icons.call_end, color: Colors.white),
                          label: const Text("End Call",
                              style: TextStyle(color: Colors.white)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (!isCallInProgress)
                    ElevatedButton(
                      onPressed: () {
                        setState(
                            () => _showPermissionBox = !_showPermissionBox);
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
                  if (_showPermissionBox) _buildPermissionRequestUI(),
                  const SizedBox(height: 46),
                  const WhatsAppCallGuidelines(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionRequestUI() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Text("Message")],
        ),
        TextField(
          controller: _permissionController,
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
              onPressed: () => setState(() => _showPermissionBox = false),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.navBarIconColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _sendPermissionRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.navBarIconColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Send", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
}

String _formatDuration(int seconds) {
  final Duration duration = Duration(seconds: seconds);
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final String minutes = twoDigits(duration.inMinutes.remainder(60));
  final String secs = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$secs";
}

// Add this dialog widget for recording playback
class RecordingPlaybackDialog extends StatelessWidget {
  final String filePath;
  final int duration;

  const RecordingPlaybackDialog({
    super.key,
    required this.filePath,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Call Recording'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Duration: ${_formatDuration(duration)}'),
          Text('File: ${filePath.split('/').last}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            // Implement playback functionality here
            Navigator.of(context).pop();
          },
          child: const Text('Play Recording'),
        ),
      ],
    );
  }
}
