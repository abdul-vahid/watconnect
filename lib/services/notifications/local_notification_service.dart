import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_utils.dart';
import '../../utils/function_lib.dart';
// import '../../widgets/widget_utils.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static void initialize() {
    // initializationSettings  for Android
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings("@mipmap/ic_launcher"),
            iOS: DarwinInitializationSettings(
                // onDidReceiveLocalNotification: onDidReceiveLocalNotification
                ));

    _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debug("onDidReceiveNotificationResponse");
        BuildContext? context = AppUtils.currentContext;
        if (context != null) {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => MultiProvider(
          //             providers: [
          //               ChangeNotifierProvider(
          //                   create: (_) => NotificationsListViewModel())
          //             ],
          //             child: const NotificationView(),
          //           )),
          // );
          // AppUtils.launchTab(context,
          //     selectedIndex: HomeTabsOptions.notifications.index);
        } else {
          debug("Current Context is null");
        }
      },
    );
  }

  static void onDidReceiveLocalNotification(
      int? id, String? title, String? body, String? payload) async {
    BuildContext? context = AppUtils.currentContext;
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context!,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title!),
        content: Text(body!),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("ok"),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              // await Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => SecondScreen(payload),
              //   ),
              // );
            },
          )
        ],
      ),
    );
  }

  static void displayNotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
            AppConstants.channelId, AppConstants.channelName,
            channelDescription: AppConstants.channelDescription,
            playSound: true,
            priority: Priority.high,
            importance: Importance.max,
            channelShowBadge: true,
            visibility: NotificationVisibility.public),
      );

      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data['id'],
      );
    } on Exception {}
  }
}
