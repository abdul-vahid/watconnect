// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:developer';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class outgoingCall {
  IO.Socket? socket;
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;

  bool _sdpHandled = false;

  Future<void> connect(String token, Map<String, dynamic> userData) async {
    socket = IO.io(
      'https://socket.callingdomain.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setQuery({'token': token})
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      log('Socket connected');
    });

    socket!.on('message', (data) async {
      final event = data['event'];
      final dir = data['dir'];
      final sdp = data['sdp'];
      final candidate = data['candidate'];

      log('Message received: $event $dir');

      if (event == "connect" && dir == "BUSINESS_INITIATED") {
        if (sdp != null && !_sdpHandled) {
          _sdpHandled = true;
          await Future.delayed(const Duration(milliseconds: 500));
          safeHandleSdp(sdp);
        }
      }

      if (event == "ICE_CANDIDATE" && candidate != null) {
        peerConnection?.addCandidate(RTCIceCandidate(
          candidate['candidate'],
          candidate['sdpMid'],
          candidate['sdpMLineIndex'],
        ));
      }
    });

    socket!.onDisconnect((_) {
      log('Socket disconnected');
    });
  }

  Future<void> startCall(String wpNumber, String leadName) async {
    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });

    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    };

    peerConnection = await createPeerConnection(config);

    localStream!.getTracks().forEach((track) {
      peerConnection!.addTrack(track, localStream!);
    });

    peerConnection!.onIceCandidate = (candidate) {
      socket?.emit('message', {
        'event': 'ICE_CANDIDATE',
        'candidate': {
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        }
      });
    };

    peerConnection!.onTrack = (event) {
      if (event.track.kind == 'audio') {
        remoteStream = event.streams.first;
        // ✅ No need to assign it to a renderer, WebRTC plays remote audio automatically
      }
    };

    final offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);

    socket?.emit('message', {
      'event': 'connect',
      'dir': 'BUSINESS_INITIATED',
      'number': wpNumber,
      'lead_name': leadName,
      'sdp': offer.toMap()
    });

    log('Offer sent: ${offer.sdp}');
  }

  void safeHandleSdp(Map<String, dynamic> sdpData) async {
    final remoteDesc = RTCSessionDescription(sdpData['sdp'], sdpData['type']);
    await peerConnection?.setRemoteDescription(remoteDesc);
    log('Remote SDP set');
  }

  void disconnectSocket() {
    socket?.disconnect();
    socket?.dispose();
    peerConnection?.close();
    localStream?.dispose();
    remoteStream?.dispose();
    _sdpHandled = false;
    log("Call disconnected");
  }
}
