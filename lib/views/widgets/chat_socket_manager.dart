import 'dart:developer';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../utils/app_utils.dart';
import '../../../view_models/unread_count_vm.dart';
import 'package:flutter/material.dart';
import '../../../main.dart';

class SocketManager {
  IO.Socket? _socket;

  Future<void> connectSocket(BuildContext context, String? wpNumber) async {
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');
    String token = await AppUtils.getToken() ?? "";
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

    try {
      _socket = IO.io(
        'https://admin.watconnect.com',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setPath('/ibs/socket.io')
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .build(),
      );

      _socket!.connect();

      _socket!.onConnect((_) {
        log('Connected to WebSocket');
        _socket!.emit("setup", decodedToken);
      });

      _socket!.on("connected", (_) {
        log("WebSocket setup complete");
      });

      _socket!.on("receivedwhatsappmessage", (data) async {
        log("New WhatsApp message received: $data");
        if (wpNumber != null) {
          Map<String, String> bodydata = {"whatsapp_number": wpNumber};
          await Provider.of<UnreadCountVm>(navigatorKey.currentContext!,
                  listen: false)
              .marksreadcountmsg(
            leadnumber: wpNumber,
            number: number,
            bodydata: bodydata,
          );
        }
      });

      _socket!.onDisconnect((_) => log("WebSocket Disconnected"));
      _socket!.onError((error) => log("WebSocket Error: $error"));
    } catch (error) {
      log("Error connecting to WebSocket: $error");
    }
  }

  void disconnectSocket() {
    _socket?.disconnect();
    log("Socket disconnected");
  }

  void dispose() {
    _socket?.dispose();
  }
}
