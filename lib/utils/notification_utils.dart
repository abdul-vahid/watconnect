import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/views/view/home_view.dart';
import 'package:whatsapp/views/view/lead_list_view.dart';

import '../services/notifications/local_notification_service.dart';
import 'app_utils.dart';
import 'function_lib.dart';

class NotificationUtil {
  static FirebaseMessaging? _firebaseMessaging;
  static BuildContext? context;
  static bool isInitialized = false;
  void initialize(context) {
    if (isInitialized) {
      return;
    }

    NotificationUtil.context = context;
    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging?.requestPermission();

    // it is used for grant permission using app setting
    // NotificationSettings setting =_firebaseMessaging?.requestPermission() as NotificationSettings;
    // if (setting.authorizationStatus == AuthorizationStatus.authorized) {
    //   debug(" user grant permisstion");
    // }else if(setting.authorizationStatus == AuthorizationStatus.provisional){
    //   debug(" user grant provisional");
    // }else{
    //   AppSettings.openNotificationSetting();
    // }

    // 1. This method call when app in terminated state and you get a notification
    // when you click on notification app open from terminated state and you can get notification data in this method
    _firebaseMessaging?.getInitialMessage().then(
      (RemoteMessage? remoteMessage) {
        debug("display notifcation app getInitialMessage");
        //onMessageReceived(remoteMessage);
        if (remoteMessage != null && remoteMessage.notification != null) {
          AppUtils.viewPush(context, LeadListView());
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
          // AppUtils.launchTab(AppUtils.currentContext!,
          //     selectedIndex: HomeTabsOptions.notifications.index);
        }
      },
    );

    // 2. This method only call when App in forground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage? remoteMessage) {
        debug("display notifcation app opened foregroud");
        onMessageReceived(remoteMessage);
      },
    );

    // 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage? remoteMessage) {
        debug("display notifcation app background");
        // AppUtils.viewPush(context, FirstView());
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
        // AppUtils.launchTab(AppUtils.currentContext!,
        //     selectedIndex: HomeTabsOptions.notifications.index);
        onMessageReceived(remoteMessage!);
      },
    );

    registerToken();
    if (!isInitialized) {
      isInitialized = true;
    }
  }

  static Future<void> onMessageReceived(RemoteMessage? remoteMessage) {
    if (remoteMessage != null) {
      LocalNotificationService.displayNotification(remoteMessage);
    }

    return Future.value();
  }

  static void registerToken() async {
    _firebaseMessaging!.getToken().then((token) {
      //TokenService tokenService = TokenService();
      debug("registerToken $token");
      // UserListViewModel().registerFCMToken(token!).then((value) {}, onError: (error, stackTrace) {});
    }).catchError((e) {
      debug("Error = $e");
    });
  }
}
