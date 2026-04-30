import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:whatsapp/main.dart';
import 'package:whatsapp/react_side/chat/controller/chat_controller.dart';
import 'package:whatsapp/react_side/chat/page/whatsapp_chat_page.dart';
import 'package:whatsapp/react_side/lead/controller/lead_list_controller.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/screens/sf_notification_screen.dart';
import 'package:whatsapp/utils/app_constants.dart';

class NotificationService {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();


  static Future<void> init() async {
    await _requestPermission();
    await _initLocalNotifications();
    _configureFCMListeners();
  }

  static Future<void> _requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ================= HANDLE KILLED STATE =================

  static Future<void> handleInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message == null) return;

    print("App opened from killed state");

    final payloadData = Map<String, dynamic>.from(message.data);

    payloadData['title'] =
        message.notification?.title ?? message.data['title'];

    await _handleNavigation(payloadData, shouldwait: true);
  }

  // ================= LOCAL NOTIFICATIONS =================

  static Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(android: android, iOS: ios);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  // ================= FCM LISTENERS =================

  static void _configureFCMListeners() {
    FirebaseMessaging.onMessage.listen(_showNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final payloadData = Map<String, dynamic>.from(message.data);

      payloadData['title'] =
          message.notification?.title ?? message.data['title'];

      _handleNavigation(payloadData);
    });
  }

  // ================= SHOW NOTIFICATION =================

  static Future<void> _showNotification(RemoteMessage message) async {
    final ctx = navigatorKey.currentContext;

    final prefs = await SharedPreferences.getInstance();
    String sfLoginType =
        prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";

    if (sfLoginType.isNotEmpty && ctx != null) {
      ChatMessageController cmProvider = Provider.of(ctx, listen: false);
      DashBoardController dbController = Provider.of(ctx, listen: false);

      final usrNumber =
          dbController.selectedContactInfo?.whatsappNumber ?? "";

      Future.delayed(const Duration(milliseconds: 1), () async {
        await cmProvider.messageHistoryApiCall(
          userNumber: usrNumber,
          isFirstTime: false,
        );
      });
    }

    String? filePath;

    final imageUrl =
        message.data['fileUrl'] ?? message.notification?.android?.imageUrl;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        filePath = await _downloadAndSaveFile(
          imageUrl,
          'notif_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      } catch (_) {}
    }

    final androidDetails = AndroidNotificationDetails(
      'spark',
      'Spark',
      channelDescription: 'Spark',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      largeIcon: filePath != null ? FilePathAndroidBitmap(filePath) : null,
      styleInformation: filePath != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(filePath),
              contentTitle: message.notification?.title ?? "",
              summaryText: message.notification?.body ?? "",
            )
          : null,
    );

    final iosDetails = DarwinNotificationDetails(
      attachments:
          filePath != null ? [DarwinNotificationAttachment(filePath)] : null,
    );

    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    
    final payloadData = Map<String, dynamic>.from(message.data);
    payloadData['title'] =
        message.notification?.title ?? message.data['title'];

    await _localNotifications.show(
      message.hashCode,
      payloadData['title'],
      message.notification?.body ?? message.data['body'],
      details,
      payload: jsonEncode(payloadData),
    );
  }



  static void _onNotificationTap(NotificationResponse response) async {
    if (response.payload == null || response.payload!.isEmpty) return;

    final map = safeStringToMap(response.payload!);
    await _handleNavigation(map);
  }


  static Future<void> _handleNavigation(
    Map<String, dynamic> data, {
    bool shouldwait = false,
  }) async {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;

    final finJson = cleanMap(data);

    final prefs = await SharedPreferences.getInstance();
    String sfLoginType =
        prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";

    if (sfLoginType.isNotEmpty) {
      DashBoardController db = Provider.of(ctx, listen: false);
      await db.sfNotificationHistoryApiCall();

      bool isOnChat = prefs.getBool("isOnSFChatPage") ?? false;

      if (!isOnChat) {
        if (shouldwait) {
          Future.delayed(const Duration(milliseconds: 3500), () {
            Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => SfNotificationScreen(
                  leadId: finJson['full_number'],
                ),
              ),
            );
          });
        } else {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => SfNotificationScreen(
                leadId: finJson['full_number'],
              ),
            ),
          );
        }
      }
    } else {
      if (shouldwait) {
        Future.delayed(const Duration(milliseconds: 3500), () async {
          final ctrl = ctx.read<ChatController>();
          final leadCtrl = ctx.read<LeadListController>();

          await ctrl.setSelectedLeadNumber("+${finJson['full_number']}");
          await leadCtrl.getLeadDetail(finJson['lead_id']);

          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => WhatsappChatPage(
                name: finJson['title'] ?? finJson['lead_name'],
                number: "+${finJson['full_number']}",
                leadId: finJson['lead_id'],
              ),
            ),
          );
        });
      } else {
        final ctrl = ctx.read<ChatController>();
        final leadCtrl = ctx.read<LeadListController>();

        await ctrl.setSelectedLeadNumber("+${finJson['full_number']}");
        await leadCtrl.getLeadDetail(finJson['lead_id']);

        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => WhatsappChatPage(
              name: finJson['title'] ?? finJson['lead_name'],
              number: "+${finJson['full_number']}",
              leadId: finJson['lead_id'],
            ),
          ),
        );
      }
    }
  }



  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }



  static Future<String?> _downloadAndSaveFile(
      String url, String fileName) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';

      final response = await http.get(Uri.parse(url));
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return filePath;
    } catch (_) {
      return null;
    }
  }


  static Map<String, dynamic> cleanMap(Map raw) {
    final Map<String, dynamic> result = {};

    raw.forEach((key, value) {
      final newKey = key.toString().replaceAll('"', '');

      if (value is String) {
        result[newKey] = value.replaceAll('"', '');
      } else if (value is Map) {
        result[newKey] = cleanMap(value);
      } else if (value is List) {
        result[newKey] = value.map((e) {
          if (e is Map) return cleanMap(e);
          if (e is String) return e.replaceAll('"', '');
          return e;
        }).toList();
      } else {
        result[newKey] = value;
      }
    });

    return result;
  }

  static Map<String, dynamic> safeStringToMap(String input) {
    try {
      final decoded = jsonDecode(input);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return {};
  }
}