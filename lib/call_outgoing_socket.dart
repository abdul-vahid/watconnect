// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:whatsapp/main.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/view_models/call_view_model.dart';

// ignore: camel_case_types
class outgoingCall {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  IO.Socket? _socket;
  IO.Socket? _statusSocket;
  bool _isConnected = false;

  String callId = "";

  IO.Socket? get socket => _socket;

  Future<void> connect(String token, Map<String, dynamic> userData,
      String devId, String busNum) async {
    if (_isConnected && _socket?.connected == true) {
      debugPrint("🔁 outgoing Call socket already connected.");
      return;
    }
    print("devId:::::::  $devId         $busNum");
    userData.addAll({
      'deviceId': devId,
      'business_number': busNum,
    });

    log("outgoing call user data :: :   $userData");

    _socket = IO.io(
      'https://admin.watconnect.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/ibs/socket.io')
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket
      ?..onConnect((_) {
        _isConnected = true;
        //debugPrint('✅ Call socket connected for outgoing call');
        _socket?.emit("setup", userData);
      })
      ..onDisconnect((_) async {
        _isConnected = false;
        //debugPrint('❌ Call socket disconnected');
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

  void disconnectSocket() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
    print("🧹 outgoing WebSocket fully cleaned up");
  }

  bool _rendererDisposed = false;

  void disposeAll() async {
    try {
      print("🧹 Cleaning up resources...");

      if (_localStream != null) {
        for (var track in _localStream!.getTracks()) {
          await track.stop();
        }
        await _localStream?.dispose();
        _localStream = null;
      }

      // Close peer connection
      await _peerConnection?.close();
      _peerConnection = null;

      // Dispose remote renderer
      _remoteRenderer.srcObject = null;
      await _remoteRenderer.dispose();
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

  Future<bool> rejectApiCall(Map<String, dynamic>? callData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final context = navigatorKey.currentContext;
      if (context == null) {
        print("❌ No context found for rejectApiCall");
        return false;
      }

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

      DashBoardController drProvider =
          Provider.of(navigatorKey.currentContext!, listen: false);
      if (drProvider.fromSalesForce) {
        number = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";
      } else {
        number = prefs.getString('phoneNumber');
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
        navigatorKey.currentContext!,
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
        navigatorKey.currentContext!,
        listen: false,
      ).outgoingCallApi(payload);

      return true;
    } catch (e, stacktrace) {
      print("❌ Error in startCall: $e");
      print(stacktrace);
      return false;
    }
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
      'https://admin.watconnect.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/ibs/socket.io')
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
        // EasyLoading.showToast("Call Accepted");
      } else if (status == "RINGING") {
        // EasyLoading.showToast("Ringing...");
      } else if (status == "COMPLETED" || status == "TERMINATE") {
        // EasyLoading.showToast("Call Terminated");
        // rejectApiCall(data);
      }
    });
  }
}
