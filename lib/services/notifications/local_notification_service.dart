// import 'dart:developer';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import '../../utils/app_constants.dart';
// import '../../utils/app_utils.dart';
// import '../../utils/function_lib.dart';

// class LocalNotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   static void initialize() {
//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//             android: AndroidInitializationSettings("@mipmap/ic_launcher"),
//             iOS: DarwinInitializationSettings());

//     _notificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (details) {
//         log("onDidReceiveNotificationResponse     ${details}  ${details.data}   ");

//         BuildContext? context = AppUtils.currentContext;
//         if (context != null) {
//           // Navigator.push(
//           //   context,
//           //   MaterialPageRoute(
//           //       builder: (context) => MultiProvider(
//           //             providers: [
//           //               ChangeNotifierProvider(
//           //                   create: (_) => NotificationsListViewModel())
//           //             ],
//           //             child: const NotificationView(),
//           //           )),
//           // );
//           // AppUtils.launchTab(context,
//           //     selectedIndex: HomeTabsOptions.notifications.index);
//         } else {
//           debug("Current Context is null");
//         }
//       },
//     );
//   }

//   static void onDidReceiveLocalNotification(
//       int? id, String? title, String? body, String? payload) async {
//     BuildContext? context = AppUtils.currentContext;
//     // display a dialog with the notification details, tap ok to go to another page
//     showDialog(
//       context: context!,
//       builder: (BuildContext context) => CupertinoAlertDialog(
//         title: Text(title!),
//         content: Text(body!),
//         actions: [
//           CupertinoDialogAction(
//             isDefaultAction: true,
//             child: Text("ok"),
//             onPressed: () async {
//               Navigator.of(context, rootNavigator: true).pop();
//               // await Navigator.push(
//               //   context,
//               //   MaterialPageRoute(
//               //     builder: (context) => SecondScreen(payload),
//               //   ),
//               // );
//             },
//           )
//         ],
//       ),
//     );
//   }

//   static void displayNotification(RemoteMessage message) async {
//     try {
//       final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//       const NotificationDetails notificationDetails = NotificationDetails(
//         android: AndroidNotificationDetails(
//             AppConstants.channelId, AppConstants.channelName,
//             channelDescription: AppConstants.channelDescription,
//             playSound: true,
//             priority: Priority.high,
//             importance: Importance.max,
//             channelShowBadge: true,
//             visibility: NotificationVisibility.public),
//       );

//       await _notificationsPlugin.show(
//         id,
//         message.notification!.title,
//         message.notification!.body,
//         notificationDetails,
//         payload: message.data['id'],
//       );
//     } on Exception {}
//   }
// }

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../utils/app_utils.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(
          // onDidReceiveLocalNotification: onDidReceiveLocalNotification

          ),
    );

    _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint("Notification Clicked: ${details.payload}");
      },
    );
  }

  static void onDidReceiveLocalNotification(
      int? id, String? title, String? body, String? payload) async {
    BuildContext? context = AppUtils.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(title ?? ""),
          content: Text(body ?? ""),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  static Future<void> displayNotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      String? imageUrl;

      if (message.data.containsKey('urls')) {
        print(
            "url=jsonDecode(message.data['urls'])==>${jsonDecode(message.data['urls'])}");
        List<dynamic> urls = jsonDecode(message.data['urls']);
        if (urls.isNotEmpty) {
          imageUrl = urls[0];
        }
      }

      debugPrint("Extracted Image URL: $imageUrl");

      BigPictureStyleInformation? bigPictureStyle;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final String? filePath =
            await _downloadAndSaveFile(imageUrl, 'notif_img.jpg');

        if (filePath != null) {
          debugPrint("Image saved at: $filePath");
          bigPictureStyle = BigPictureStyleInformation(
            FilePathAndroidBitmap(filePath),
            largeIcon: FilePathAndroidBitmap(filePath),
            contentTitle: message.notification?.title ?? "",
            summaryText: message.notification?.body ?? "",
          );
        } else {
          debugPrint("Failed to download image");
        }
      }

      final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'i_digi_school',
          'iDigiSchool',
          channelDescription: 'iDigiSchool Notifications',
          playSound: true,
          priority: Priority.high,
          importance: Importance.max,
          channelShowBadge: true,
          visibility: NotificationVisibility.public,
          styleInformation: bigPictureStyle,
        ),
      );

      await _notificationsPlugin.show(
        id,
        message.notification?.title,
        message.notification?.body,
        notificationDetails,
        payload: message.data['id'],
      );

      debugPrint("Notification Title: ${message.notification?.title}");
      debugPrint("Notification Body: ${message.notification?.body}");
    } catch (e) {
      debugPrint("Error displaying notification: $e");
    }
  }

  static Future<String?> _downloadAndSaveFile(
      String url, String fileName) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/$fileName';
      final http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        debugPrint(
            "Failed to download file. Status Code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Error downloading file: $e");
      return null;
    }
  }
}
