import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/main.dart';
import 'package:whatsapp/models/lead_model.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/screens/sf_message_chat_screen.dart';
import 'package:whatsapp/salesforce/screens/sf_notification_screen.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/view_models/lead_list_vm.dart';
import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';

class NotificationService {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  // ================= INIT =================

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

  static Future<void> handleInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();

    if (message == null) return;

    print(" App opened from killed state via notification");
    print("Initial message data => ${message.data}");

    await _handleNavigation(message.data, shouldwait: true);
  }

  // ================= LOCAL NOTIFICATIONS =================

  static Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  // ================= FCM LISTENERS =================

  static void _configureFCMListeners() {
    FirebaseMessaging.onMessage.listen(_showNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNavigation(message.data);
    });
  }

  // ================= SHOW NOTIFICATION =================

  static Future<void> _showNotification(RemoteMessage message) async {
    print("message.  message.data>>>>>>>.  ${message}. ${message.data}");

    final ctx = navigatorKey.currentContext;

    final prefs = await SharedPreferences.getInstance();
    String sfLoginType =
        prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";
    if (sfLoginType.isNotEmpty) {
      ChatMessageController cmProvider = Provider.of(ctx!, listen: false);
      DashBoardController dbController = Provider.of(ctx!, listen: false);

      final usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
      Future.delayed(const Duration(milliseconds: 1), () async {
        await cmProvider.messageHistoryApiCall(
          userNumber: usrNumber,
          isFirstTime: false,
        );
      });
    }

    BigPictureStyleInformation? bigPictureStyle;
    String? filePath;

    final imageUrl =
        message.data['fileUrl'] ?? message.notification?.android?.imageUrl;

    // Try to download image for notification
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        filePath = await _downloadAndSaveFile(
            imageUrl, 'notif_img_${DateTime.now().millisecondsSinceEpoch}.jpg');
      } catch (e) {
        print("Failed to download image: $e");
      }
    }

    // For Android - use big picture style if image downloaded
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
              hideExpandedLargeIcon: false,
            )
          : null,
    );

    // For iOS - set attachment if available
    final iosDetails = DarwinNotificationDetails(
      attachments:
          filePath != null ? [DarwinNotificationAttachment(filePath)] : null,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? message.data['title'],
      message.notification?.body ?? message.data['body'],
      details,
      payload: jsonEncode(message.data),
    );
  }

  // ================= TAP HANDLING =================

  static void _onNotificationTap(NotificationResponse response) async {
    if (response.payload == null || response.payload!.isEmpty) return;

    try {
      final map = safeStringToMap(response.payload!);

      print("notification is tapped with data>>> $map");

      await _handleNavigation(map);
    } catch (e) {
      print("Payload parse error: $e");
    }
  }

  static Map<String, dynamic> safeStringToMap(String? input) {
    if (input == null || input.trim().isEmpty) {
      return {};
    }

    final value = input.trim();

    // 1️⃣ Try proper JSON
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}

    // 2️⃣ Try loose object format: {key: value}
    if (value.startsWith('{') && value.endsWith('}')) {
      final content = value.substring(1, value.length - 1);

      final Map<String, dynamic> result = {};

      for (final pair in content.split(',')) {
        if (!pair.contains(':')) continue;

        final parts = pair.split(':');
        final key = parts.first.trim();
        final rawValue = parts.sublist(1).join(':').trim();

        // Handle list values
        if (rawValue.contains(',')) {
          result[key] = rawValue.split(',').map((e) => e.trim()).toList();
        } else {
          result[key] = rawValue;
        }
      }
      return result;
    }

    // 3️⃣ Try key=value,key2=value2
    if (value.contains('=') && value.contains(',')) {
      final Map<String, dynamic> result = {};

      for (final pair in value.split(',')) {
        if (!pair.contains('=')) continue;
        final kv = pair.split('=');
        result[kv[0].trim()] = kv[1].trim();
      }
      return result;
    }

    // 4️⃣ Fallback — store raw string
    return {
      'raw': value,
    };
  }

  static Future<void> _handleNavigation(Map<String, dynamic> data,
      {bool shouldwait = false}) async {
    print("data before clean.  $data");
    final ctx = navigatorKey.currentContext;
    final finJson = cleanMap(data);
    final prefs = await SharedPreferences.getInstance();
    String sfLoginType =
        prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";
    print("_handleNavigation:::::::${finJson}   ${sfLoginType}");
    if (sfLoginType.isNotEmpty) {
      DashBoardController dasbController = Provider.of(ctx!, listen: false);
      await dasbController.sfNotificationHistoryApiCall();
         final prefs = await SharedPreferences.getInstance();
            bool isOnChat=  prefs.getBool("isOnSFChatPage")??false;

            if(isOnChat){

                // Navigator.push(
                //   ctx,
                //   MaterialPageRoute(
                //       builder: (context) => SfMessageChatScreen(
                //             pinnedLeadsList: [],
                //           )));

            }else{

  if (shouldwait) {
        Future.delayed(const Duration(milliseconds: 3500), () {
          Navigator.push(
            ctx!,
            MaterialPageRoute(
              builder: (_) =>
                  SfNotificationScreen(leadId: finJson['full_number']),
            ),
          );
        });
      } else {
        Navigator.push(
          ctx!,
          MaterialPageRoute(
            builder: (_) =>
                SfNotificationScreen(leadId: finJson['full_number']),
          ),
        );
      }

            }


    

      // navigate to customer screen
    } else {
      final leadlistvm = Provider.of<LeadListViewModel>(ctx!, listen: false);
      await leadlistvm.fetch();
      LeadModel? matchedModel;
      final List<LeadModel> pinnedLeads = [];

      // Find pinned leads and matching lead
      for (var viewModel in leadlistvm.viewModels) {
        final leadmodel = viewModel.model;

        if (leadmodel?.records != null) {
          for (var record in leadmodel!.records!) {
            print("record.id::::::::  ${record.id}");
            if (record.pinned == true) {
              pinnedLeads.add(record);
            }
            if (record.id.toString() == finJson['lead_id']) {
              matchedModel = record;
            }
          }
        }
      }

      final wpNumber = matchedModel?.whatsappNumber ?? "";
      final formattedWpNumber = wpNumber.contains("+")
          ? wpNumber
          : "${matchedModel?.countryCode}$wpNumber";

      if (shouldwait) {
        Future.delayed(const Duration(milliseconds: 3500), () {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => WhatsappChatScreen(
                pinnedLeads: pinnedLeads,
                leadName:
                    "${matchedModel?.firstname ?? ""} ${matchedModel?.lastname ?? ""}",
                wpnumber: formattedWpNumber,
                id: matchedModel?.id,
                model: matchedModel,
              ),
            ),
          );
        });
      } else {
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => WhatsappChatScreen(
              pinnedLeads: pinnedLeads,
              leadName:
                  "${matchedModel?.firstname ?? ""} ${matchedModel?.lastname ?? ""}",
              wpnumber: formattedWpNumber,
              id: matchedModel?.id,
              model: matchedModel,
            ),
          ),
        );
      }
    }
  }

  // ================= TOKEN =================

  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // ================= IMAGE DOWNLOAD =================

  static Future<String?> _downloadAndSaveFile(
    String url,
    String fileName,
  ) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';

      final response = await http.get(Uri.parse(url));
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return filePath;
    } catch (e) {
      return null;
    }
  }

  static Map<String, dynamic> cleanMap(Map raw) {
    final Map<String, dynamic> result = {};

    raw.forEach((key, value) {
      // Clean key
      final newKey = key.toString().replaceAll('"', '');

      // Clean value
      if (value is String) {
        // remove extra quotes if present
        final newValue = value.replaceAll('"', '');
        result[newKey] = newValue;
      } else if (value is Map) {
        // handle nested maps
        result[newKey] = cleanMap(value);
      } else if (value is List) {
        // handle list of maps/strings
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
}
