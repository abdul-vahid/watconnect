import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/main.dart';
import 'package:whatsapp/models/lead_model.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/function_lib.dart';
import 'package:whatsapp/view_models/lead_list_vm.dart';
import 'package:whatsapp/view_models/unread_count_vm.dart';
import 'package:whatsapp/view_models/user_list_vm.dart';
import 'package:whatsapp/views/view/login_view.dart';
import 'package:whatsapp/views/view/whatsapp_message_view.dart';
import '../widgets/bottomnavigatonbar.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  static FirebaseMessaging? _firebaseMessaging;
  void initState() {
    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging?.requestPermission();
    super.initState();
    // registerToken();
    startTimer();
    setupFirebase();
  }

  Future<void> setupFirebase() async {
    await Firebase.initializeApp();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {
      debug("::::: Data: ${payload.payload}  ${payload.payload.runtimeType}");
      var body = jsonDecode(payload.payload ?? "");
      print("body::: ${body}   ${body['lead_id']} ");
      String leadId = body['lead_id'] ?? "";
      if (leadId.isNotEmpty) {
        NavigationFunc(leadId, navigatorKey.currentContext!);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debug(" Foreground notification: ${message.notification?.title}");
      debug(" Data: ${message.data}  ${jsonEncode(message.data)}");

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        String? imageUrl = message.data['fileUrl'];
        String? leadId = message.data['lead_id'];
        BigPictureStyleInformation? bigPictureStyle;

        if (imageUrl != null && imageUrl.isNotEmpty) {
          try {
            final Directory tempDir = await getTemporaryDirectory();
            final String filePath = '${tempDir.path}/notif_img.jpg';
            final http.Response response = await http.get(Uri.parse(imageUrl));
            final File file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);

            bigPictureStyle = BigPictureStyleInformation(
              FilePathAndroidBitmap(filePath),
              contentTitle: notification.title,
              summaryText: notification.body,
            );
          } catch (e) {
            debug(" Error loading image: $e");
          }
        }

        await flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'channel_id',
              'channel_name',
              importance: Importance.max,
              priority: Priority.high,
              styleInformation: bigPictureStyle,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debug(" App opened from background: ${message.data}");
      String? leadId = message.data['lead_id'];
      if (leadId != null) {
        NavigationFunc(leadId, navigatorKey.currentContext!);
      }
    });

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null &&
        initialMessage.data['clicked'] == 'true' &&
        initialMessage.data['lead_id'] != null &&
        initialMessage.data['lead_id'].toString().isNotEmpty) {
      debug(
          " App launched from terminated state by tapping: ${initialMessage.data}");

      String leadId = initialMessage.data['lead_id'];

      WidgetsBinding.instance.addPostFrameCallback((_) {
        NavigationFunc(leadId, navigatorKey.currentContext!);
      });
    } else {
      debug("Skipping initial message - not tapped");
    }
  }

  void startTimer() async {
    const duration = Duration(seconds: 3);
    Timer(duration, _isLoggedIn);
  }

  void _isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(SharedPrefsConstants.userKey)) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const FooterNavbarPage()),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/images/whatsapp.png",
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 160,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white,
                    valueColor:
                        AlwaysStoppedAnimation(AppColor.navBarIconColor),
                    minHeight: 5,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> NavigationFunc(String leadId, BuildContext cntxt) async {
    debug("NavigationFunc called with leadId: $leadId");
    LeadModel? matchedModel;
    var leadlistvm = Provider.of<LeadListViewModel>(cntxt, listen: false);
    await leadlistvm.fetch();
    for (var viewModel in leadlistvm.viewModels) {
      debug("Found lead ID: ${viewModel.model.id}");
      if (viewModel.model.id.toString() == leadId) {
        matchedModel = viewModel.model;
        break;
      }
    }
    if (matchedModel == null) {
      debug("No matching lead found for ID: $leadId");
      return;
    }
    Navigator.push(
      cntxt,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          leadName: "${matchedModel?.firstname} ${matchedModel?.lastname}",
          wpnumber: matchedModel!.whatsapp_number!.contains("+")
              ? matchedModel.whatsapp_number ?? ""
              : "${matchedModel.countryCode}${matchedModel.whatsapp_number ?? ""}",
          id: matchedModel.id,
        ),
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    var number = prefs.getString('phoneNumber');
    if (number != null) {
      String whatsappNumber = matchedModel.whatsapp_number!.contains("+")
          ? matchedModel.whatsapp_number ?? ""
          : "${matchedModel.countryCode}${matchedModel.whatsapp_number ?? ""}";
      Map<String, String>? bodydata = {"whatsapp_number": whatsappNumber};

      var response = await Provider.of<UnreadCountVm>(cntxt, listen: false)
          .marksreadcountmsg(
        leadnumber: whatsappNumber,
        number: number,
        bodydata: bodydata,
      );
    }
  }

  static void registerToken() async {
    _firebaseMessaging?.getToken().then((token) {
      debug("registerToken value => $token");
      UserListViewModel().registerFCMToken(token!).then((value) {
        debug("FCM token registered to backend => $value");
      }, onError: (error, stackTrace) {
        debug("FCM token registration error => $error");
      });
    }).catchError((e) {
      debug("FCM getToken error => $e");
    });
  }
}
