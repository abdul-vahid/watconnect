// // // // // // // import 'dart:async';
// // // // // // // import 'dart:core';

// // // // // // // import 'package:app_links/app_links.dart';
// // // // // // // import 'package:firebase_core/firebase_core.dart';
// // // // // // // import 'package:firebase_messaging/firebase_messaging.dart';
// // // // // // // import 'package:flutter/material.dart';
// // // // // // // import 'package:flutter/services.dart';
// // // // // // // import 'package:flutter_easyloading/flutter_easyloading.dart';
// // // // // // // import 'package:google_fonts/google_fonts.dart';
// // // // // // // import 'package:provider/provider.dart';
// // // // // // // import 'package:timezone/data/latest.dart' as tz;

// // // // // // // // Controllers & VMs
// // // // // // // import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
// // // // // // // import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
// // // // // // // import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
// // // // // // // import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
// // // // // // // import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
// // // // // // // import 'package:whatsapp/salesforce/controller/template_controller.dart';

// // // // // // // import 'package:whatsapp/services/notifications/notification_service.dart';
// // // // // // // import 'package:whatsapp/utils/app_color.dart';
// // // // // // // import 'package:whatsapp/utils/function_lib.dart';

// // // // // // // import 'package:whatsapp/view_models/approved_template_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/auto_response_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/call_view_model.dart';
// // // // // // // import 'package:whatsapp/view_models/campaign_chart_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/campaign_count_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/campaign_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/chart_list_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/get_user_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/groups_view_model.dart';
// // // // // // // import 'package:whatsapp/view_models/lead_controller.dart';
// // // // // // // import 'package:whatsapp/view_models/lead_count_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/lead_list_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/message_controller.dart';
// // // // // // // import 'package:whatsapp/view_models/message_history_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/message_list_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/tags_list_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/templete_list_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/unread_count_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/user_data_list_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/wallet_controller.dart';
// // // // // // // import 'package:whatsapp/view_models/whatsapp_setting_vm.dart';

// // // // // // // import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
// // // // // // // import 'package:whatsapp/views/view/splash_view.dart';

// // // // // // // import 'firebase_options.dart';

// // // // // // // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// // // // // // // final RouteObserver<ModalRoute<void>> routeObserver =
// // // // // // //     RouteObserver<ModalRoute<void>>();

// // // // // // // @pragma('vm:entry-point')
// // // // // // // Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// // // // // // //   await Firebase.initializeApp();
// // // // // // // }

// // // // // // // void main() async {
// // // // // // //   tz.initializeTimeZones();

// // // // // // //   WidgetsFlutterBinding.ensureInitialized();
// // // // // // //   await Firebase.initializeApp(
// // // // // // //     options: DefaultFirebaseOptions.currentPlatform,
// // // // // // //   );

// // // // // // //   FirebaseMessaging.onBackgroundMessage(
// // // // // // //     firebaseMessagingBackgroundHandler,
// // // // // // //   );

// // // // // // //   await NotificationService.init();

// // // // // // //   runApp(const MyApp());
// // // // // // //   await NotificationService.handleInitialMessage();
// // // // // // // }

// // // // // // // class MyApp extends StatefulWidget {
// // // // // // //   const MyApp({super.key});

// // // // // // //   @override
// // // // // // //   State<MyApp> createState() => _MyAppState();
// // // // // // // }

// // // // // // // class _MyAppState extends State<MyApp> {
// // // // // // //   late final AppLinks _appLinks;
// // // // // // //   StreamSubscription<Uri>? _linkSubscription;

// // // // // // //   @override
// // // // // // //   void initState() {
// // // // // // //     super.initState();
// // // // // // //     debug("🚀 AppLinks initialized");

// // // // // // //     _appLinks = AppLinks();
// // // // // // //     _handleInitialUri();
// // // // // // //     _listenToUriStream();
// // // // // // //   }

// // // // // // //   Future<void> _handleInitialUri() async {
// // // // // // //     try {
// // // // // // //       final Uri? initialUri = await _appLinks.getInitialLink();
// // // // // // //       debug("📌 Initial URI => $initialUri");

// // // // // // //       if (initialUri != null) {
// // // // // // //         _handleDeepLink(initialUri);
// // // // // // //       }
// // // // // // //     } catch (e) {
// // // // // // //       debug("❌ Initial URI error: $e");
// // // // // // //     }
// // // // // // //   }

// // // // // // //   /// 🔹 Runtime links
// // // // // // //   void _listenToUriStream() {
// // // // // // //     _linkSubscription = _appLinks.uriLinkStream.listen(
// // // // // // //       (Uri uri) {
// // // // // // //         debug("🔗 Stream URI => $uri");
// // // // // // //         _handleDeepLink(uri);
// // // // // // //       },
// // // // // // //       onError: (err) {
// // // // // // //         debug("❌ URI Stream error: $err");
// // // // // // //       },
// // // // // // //     );
// // // // // // //   }

// // // // // // //   /// 🔹 Deep link navigation
// // // // // // //   void _handleDeepLink(Uri uri) {
// // // // // // //     debug("➡️ Handling DeepLink: $uri");

// // // // // // //     if (uri.pathSegments.contains('chat')) {
// // // // // // //       final params = uri.queryParameters;

// // // // // // //       final leadName = params['name'] ?? 'WatConnect';
// // // // // // //       final wpnumber = params['number'] ?? '';
// // // // // // //       final id = params['id'];

// // // // // // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // //         final context = navigatorKey.currentContext;
// // // // // // //         if (context != null) {
// // // // // // //           Navigator.push(
// // // // // // //             context,
// // // // // // //             MaterialPageRoute(
// // // // // // //               builder: (_) => WhatsappChatScreen(
// // // // // // //                 leadName: leadName,
// // // // // // //                 wpnumber: wpnumber,
// // // // // // //                 id: id,
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //           );
// // // // // // //         }
// // // // // // //       });
// // // // // // //     }
// // // // // // //   }

// // // // // // //   @override
// // // // // // //   void dispose() {
// // // // // // //     _linkSubscription?.cancel();
// // // // // // //     super.dispose();
// // // // // // //   }

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     SystemChrome.setSystemUIOverlayStyle(
// // // // // // //       const SystemUiOverlayStyle(
// // // // // // //         statusBarColor: Colors.transparent,
// // // // // // //         statusBarIconBrightness: Brightness.dark,
// // // // // // //         statusBarBrightness: Brightness.light,
// // // // // // //       ),
// // // // // // //     );

// // // // // // //     SystemChrome.setPreferredOrientations([
// // // // // // //       DeviceOrientation.portraitUp,
// // // // // // //       DeviceOrientation.portraitDown,
// // // // // // //     ]);

// // // // // // //     return MultiProvider(
// // // // // // //       providers: [
// // // // // // //         ChangeNotifierProvider(create: (_) => ApprovedTemplateViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => UnreadCountVm(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => GroupsViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => MessageViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => CampaignChartViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => LeadListViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => TagsListViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => CampaignViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => MeesageHistoryViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => LeadCountViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => TempleteListViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => AutoResponseViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => WhatsappSettingViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => CampaignCountViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => ChartListViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => GetUserViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => UserDataListViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => MessageController()),
// // // // // // //         ChangeNotifierProvider(create: (_) => DashBoardController()),
// // // // // // //         ChangeNotifierProvider(create: (_) => TemplateController()),
// // // // // // //         ChangeNotifierProvider(create: (_) => BusinessNumberController()),
// // // // // // //         ChangeNotifierProvider(create: (_) => CallsViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => ChatMessageController()),
// // // // // // //         ChangeNotifierProvider(create: (_) => SfcampaignController()),
// // // // // // //         ChangeNotifierProvider(create: (_) => WalletController()),
// // // // // // //         ChangeNotifierProvider(create: (_) => LeadController()),
// // // // // // //         ChangeNotifierProvider(create: (_) => SfFileUploadController()),
// // // // // // //       ],
// // // // // // //       child: MaterialApp(
// // // // // // //         debugShowCheckedModeBanner: false,
// // // // // // //         navigatorKey: navigatorKey,
// // // // // // //         navigatorObservers: [routeObserver],
// // // // // // //         title: 'WatConnect',
// // // // // // //         theme: ThemeData(
// // // // // // //           textTheme: GoogleFonts.kohSantepheapTextTheme(),
// // // // // // //           primaryColor: AppColor.navBarIconColor,
// // // // // // //           appBarTheme: const AppBarTheme(
// // // // // // //             backgroundColor: AppColor.navBarIconColor,
// // // // // // //           ),
// // // // // // //         ),
// // // // // // //         builder: EasyLoading.init(),
// // // // // // //         home: const SplashView(),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // // }

// // // // // // // import 'dart:async';
// // // // // // // import 'dart:core';

// // // // // // // import 'package:app_links/app_links.dart';
// // // // // // // import 'package:firebase_core/firebase_core.dart';
// // // // // // // import 'package:firebase_messaging/firebase_messaging.dart';
// // // // // // // import 'package:flutter/material.dart';
// // // // // // // import 'package:flutter/services.dart';
// // // // // // // import 'package:flutter_easyloading/flutter_easyloading.dart';
// // // // // // // import 'package:google_fonts/google_fonts.dart';
// // // // // // // import 'package:provider/provider.dart';
// // // // // // // import 'package:timezone/data/latest.dart' as tz;

// // // // // // // // Controllers & VMs
// // // // // // // import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
// // // // // // // import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
// // // // // // // import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
// // // // // // // import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
// // // // // // // import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
// // // // // // // import 'package:whatsapp/salesforce/controller/template_controller.dart';

// // // // // // // import 'package:whatsapp/services/notifications/notification_service.dart';
// // // // // // // import 'package:whatsapp/utils/app_color.dart';
// // // // // // // import 'package:whatsapp/utils/function_lib.dart';

// // // // // // // import 'package:whatsapp/view_models/approved_template_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/auto_response_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/call_view_model.dart';
// // // // // // // import 'package:whatsapp/view_models/campaign_chart_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/campaign_count_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/campaign_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/chart_list_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/get_user_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/groups_view_model.dart';
// // // // // // // import 'package:whatsapp/view_models/lead_controller.dart';
// // // // // // // import 'package:whatsapp/view_models/lead_count_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/lead_list_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/message_controller.dart';
// // // // // // // import 'package:whatsapp/view_models/message_history_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/message_list_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/tags_list_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/templete_list_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/unread_count_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/user_data_list_vm.dart';
// // // // // // // import 'package:whatsapp/view_models/wallet_controller.dart';
// // // // // // // import 'package:whatsapp/view_models/whatsapp_setting_vm.dart';

// // // // // // // import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
// // // // // // // import 'package:whatsapp/views/view/splash_view.dart';

// // // // // // // import 'firebase_options.dart';

// // // // // // // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// // // // // // // final RouteObserver<ModalRoute<void>> routeObserver =
// // // // // // //     RouteObserver<ModalRoute<void>>();

// // // // // // // /// store deep link safely until app ready
// // // // // // // Uri? pendingDeepLink;

// // // // // // // @pragma('vm:entry-point')
// // // // // // // Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// // // // // // //   await Firebase.initializeApp();
// // // // // // // }

// // // // // // // void main() async {
// // // // // // //   tz.initializeTimeZones();

// // // // // // //   WidgetsFlutterBinding.ensureInitialized();
// // // // // // //   await Firebase.initializeApp(
// // // // // // //     options: DefaultFirebaseOptions.currentPlatform,
// // // // // // //   );

// // // // // // //   FirebaseMessaging.onBackgroundMessage(
// // // // // // //     firebaseMessagingBackgroundHandler,
// // // // // // //   );

// // // // // // //   await NotificationService.init();

// // // // // // //   runApp(const MyApp());
// // // // // // //   await NotificationService.handleInitialMessage();
// // // // // // // }

// // // // // // // class MyApp extends StatefulWidget {
// // // // // // //   const MyApp({super.key});

// // // // // // //   @override
// // // // // // //   State<MyApp> createState() => _MyAppState();
// // // // // // // }

// // // // // // // class _MyAppState extends State<MyApp> {
// // // // // // //   late final AppLinks _appLinks;
// // // // // // //   StreamSubscription<Uri>? _linkSubscription;

// // // // // // //   @override
// // // // // // //   void initState() {
// // // // // // //     super.initState();
// // // // // // //     debug("🚀 AppLinks initialized");

// // // // // // //     _appLinks = AppLinks();
// // // // // // //     _handleInitialUri();
// // // // // // //     _listenToUriStream();
// // // // // // //   }

// // // // // // //   /// 🔹 App killed state
// // // // // // //   Future<void> _handleInitialUri() async {
// // // // // // //     try {
// // // // // // //       final Uri? initialUri = await _appLinks.getInitialLink();
// // // // // // //       debug("📌 Initial URI => $initialUri");

// // // // // // //       if (initialUri != null) {
// // // // // // //         pendingDeepLink = initialUri;
// // // // // // //       }
// // // // // // //     } catch (e) {
// // // // // // //       debug("❌ Initial URI error: $e");
// // // // // // //     }
// // // // // // //   }

// // // // // // //   /// 🔹 Background / foreground
// // // // // // //   void _listenToUriStream() {
// // // // // // //     _linkSubscription = _appLinks.uriLinkStream.listen(
// // // // // // //       (Uri uri) {
// // // // // // //         debug("🔗 Stream URI => $uri");
// // // // // // //         pendingDeepLink = uri;
// // // // // // //         _processDeepLink();
// // // // // // //       },
// // // // // // //       onError: (err) {
// // // // // // //         debug("❌ URI Stream error: $err");
// // // // // // //       },
// // // // // // //     );
// // // // // // //   }

// // // // // // //   /// 🔹 Process deep link after providers ready
// // // // // // //   void _processDeepLink() {
// // // // // // //     if (pendingDeepLink == null) return;

// // // // // // //     final uri = pendingDeepLink!;
// // // // // // //     debug("➡️ Processing DeepLink: $uri");

// // // // // // //     if (!uri.pathSegments.contains('chat')) return;

// // // // // // //     final params = uri.queryParameters;
// // // // // // //     final leadName = params['name'] ?? 'WatConnect';
// // // // // // //     final wpnumber = params['number'] ?? '';
// // // // // // //     final id = params['id'];

// // // // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // //       final context = navigatorKey.currentContext;
// // // // // // //       if (context == null) return;

// // // // // // //       /// ensure providers exist
// // // // // // //       Provider.of<MessageController>(context, listen: false);
// // // // // // //       Provider.of<MessageViewModel>(context, listen: false);

// // // // // // //       Navigator.push(
// // // // // // //         context,
// // // // // // //         MaterialPageRoute(
// // // // // // //           builder: (_) => WhatsappChatScreen(
// // // // // // //             leadName: leadName,
// // // // // // //             wpnumber: wpnumber,
// // // // // // //             id: id,
// // // // // // //           ),
// // // // // // //         ),
// // // // // // //       );

// // // // // // //       pendingDeepLink = null;
// // // // // // //     });
// // // // // // //   }

// // // // // // //   @override
// // // // // // //   void dispose() {
// // // // // // //     _linkSubscription?.cancel();
// // // // // // //     super.dispose();
// // // // // // //   }

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     /// call deep link after UI built
// // // // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // //       _processDeepLink();
// // // // // // //     });

// // // // // // //     SystemChrome.setSystemUIOverlayStyle(
// // // // // // //       const SystemUiOverlayStyle(
// // // // // // //         statusBarColor: Colors.transparent,
// // // // // // //         statusBarIconBrightness: Brightness.dark,
// // // // // // //         statusBarBrightness: Brightness.light,
// // // // // // //       ),
// // // // // // //     );

// // // // // // //     SystemChrome.setPreferredOrientations([
// // // // // // //       DeviceOrientation.portraitUp,
// // // // // // //       DeviceOrientation.portraitDown,
// // // // // // //     ]);

// // // // // // //     return MultiProvider(
// // // // // // //       providers: [
// // // // // // //         ChangeNotifierProvider(
// // // // // // //             create: (_) => ApprovedTemplateViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => UnreadCountVm(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => GroupsViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => MessageViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => CampaignChartViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => LeadListViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => TagsListViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => CampaignViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => MeesageHistoryViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => LeadCountViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => TempleteListViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => AutoResponseViewModel(context)),
// // // // // // //         ChangeNotifierProvider(
// // // // // // //             create: (_) => WhatsappSettingViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => CampaignCountViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => ChartListViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => GetUserViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => UserDataListViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => MessageController()),
// // // // // // //         ChangeNotifierProvider(create: (_) => DashBoardController()),
// // // // // // //         ChangeNotifierProvider(create: (_) => TemplateController()),
// // // // // // //         ChangeNotifierProvider(create: (_) => BusinessNumberController()),
// // // // // // //         ChangeNotifierProvider(create: (_) => CallsViewModel(context)),
// // // // // // //         ChangeNotifierProvider(create: (_) => ChatMessageController()),
// // // // // // //         ChangeNotifierProvider(create: (_) => SfcampaignController()),
// // // // // // //         ChangeNotifierProvider(create: (_) => WalletController()),
// // // // // // //         ChangeNotifierProvider(create: (_) => LeadController()),
// // // // // // //         ChangeNotifierProvider(create: (_) => SfFileUploadController()),
// // // // // // //       ],
// // // // // // //       child: MaterialApp(
// // // // // // //         debugShowCheckedModeBanner: false,
// // // // // // //         navigatorKey: navigatorKey,
// // // // // // //         navigatorObservers: [routeObserver],
// // // // // // //         title: 'WatConnect',
// // // // // // //         theme: ThemeData(
// // // // // // //           textTheme: GoogleFonts.kohSantepheapTextTheme(),
// // // // // // //           primaryColor: AppColor.navBarIconColor,
// // // // // // //           appBarTheme: const AppBarTheme(
// // // // // // //             backgroundColor: AppColor.navBarIconColor,
// // // // // // //           ),
// // // // // // //         ),
// // // // // // //         builder: EasyLoading.init(),
// // // // // // //         home: const SplashView(),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }

// // // // // // import 'dart:async';
// // // // // // import 'dart:core';

// // // // // // import 'package:app_links/app_links.dart';
// // // // // // import 'package:firebase_core/firebase_core.dart';
// // // // // // import 'package:firebase_messaging/firebase_messaging.dart';
// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:flutter/services.dart';
// // // // // // import 'package:flutter_easyloading/flutter_easyloading.dart';
// // // // // // import 'package:google_fonts/google_fonts.dart';
// // // // // // import 'package:provider/provider.dart';
// // // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // // // import 'package:timezone/data/latest.dart' as tz;
// // // // // // import 'package:shared_preferences/shared_preferences.dart';

// // // // // // // Controllers & VMs
// // // // // // import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
// // // // // // import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
// // // // // // import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
// // // // // // import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
// // // // // // import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
// // // // // // import 'package:whatsapp/salesforce/controller/template_controller.dart';

// // // // // // import 'package:whatsapp/services/notifications/notification_service.dart';
// // // // // // import 'package:whatsapp/utils/app_color.dart';
// // // // // // import 'package:whatsapp/utils/function_lib.dart';

// // // // // // import 'package:whatsapp/view_models/approved_template_vm.dart';
// // // // // // import 'package:whatsapp/view_models/auto_response_vm.dart';
// // // // // // import 'package:whatsapp/view_models/call_view_model.dart';
// // // // // // import 'package:whatsapp/view_models/campaign_chart_vm.dart';
// // // // // // import 'package:whatsapp/view_models/campaign_count_vm.dart';
// // // // // // import 'package:whatsapp/view_models/campaign_vm.dart';
// // // // // // import 'package:whatsapp/view_models/chart_list_vm.dart';
// // // // // // import 'package:whatsapp/view_models/get_user_vm.dart';
// // // // // // import 'package:whatsapp/view_models/groups_view_model.dart';
// // // // // // import 'package:whatsapp/view_models/lead_controller.dart';
// // // // // // import 'package:whatsapp/view_models/lead_count_vm.dart';
// // // // // // import 'package:whatsapp/view_models/lead_list_vm.dart';
// // // // // // import 'package:whatsapp/view_models/message_controller.dart';
// // // // // // import 'package:whatsapp/view_models/message_history_vm.dart';
// // // // // // import 'package:whatsapp/view_models/message_list_vm.dart';
// // // // // // import 'package:whatsapp/view_models/tags_list_vm.dart';
// // // // // // import 'package:whatsapp/view_models/templete_list_vm.dart';
// // // // // // import 'package:whatsapp/view_models/unread_count_vm.dart';
// // // // // // import 'package:whatsapp/view_models/user_data_list_vm.dart';
// // // // // // import 'package:whatsapp/view_models/wallet_controller.dart';
// // // // // // import 'package:whatsapp/view_models/whatsapp_setting_vm.dart';

// // // // // // import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
// // // // // // import 'package:whatsapp/views/view/splash_view.dart';

// // // // // // import 'firebase_options.dart';
// // // // // // import 'utils/app_constants.dart';

// // // // // // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// // // // // // final RouteObserver<ModalRoute<void>> routeObserver =
// // // // // //     RouteObserver<ModalRoute<void>>();

// // // // // // /// store deep link safely until app ready
// // // // // // Uri? pendingDeepLink;

// // // // // // @pragma('vm:entry-point')
// // // // // // Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// // // // // //   await Firebase.initializeApp();
// // // // // // }

// // // // // // void main() async {
// // // // // //   tz.initializeTimeZones();

// // // // // //   WidgetsFlutterBinding.ensureInitialized();
// // // // // //   await Firebase.initializeApp(
// // // // // //     options: DefaultFirebaseOptions.currentPlatform,
// // // // // //   );

// // // // // //   FirebaseMessaging.onBackgroundMessage(
// // // // // //     firebaseMessagingBackgroundHandler,
// // // // // //   );

// // // // // //   await NotificationService.init();

// // // // // //   // Initialize SharedPreferences
// // // // // //   final prefs = await SharedPreferences.getInstance();

// // // // // //   // Check for pending deep link from notification
// // // // // //   WidgetsBinding.instance.addPostFrameCallback((_) async {
// // // // // //     await _handlePendingDeepLinkFromNotification(prefs);
// // // // // //   });

// // // // // //   runApp(const MyApp());
// // // // // //   await NotificationService.handleInitialMessage();
// // // // // // }

// // // // // // Future<void> _handlePendingDeepLinkFromNotification(SharedPreferences prefs) async {
// // // // // //   try {

// // // // // //     final notificationData = prefs.getString('pending_notification_data');
// // // // // //     if (notificationData != null && notificationData.isNotEmpty) {
// // // // // //       debug("📱 Processing pending notification data: $notificationData");

// // // // // //       final phoneNumber = _extractPhoneNumberFromNotification(notificationData);
// // // // // //       final leadName = _extractLeadNameFromNotification(notificationData);

// // // // // //       if (phoneNumber.isNotEmpty) {

// // // // // //         final deepLinkUri = Uri.parse('https://admin.watconnect.com//chat?number=$phoneNumber&name=$leadName');
// // // // // //         debug("deepLinkUri: $deepLinkUri");
// // // // // //         pendingDeepLink = deepLinkUri;

// // // // // //         await prefs.remove('pending_notification_data');
// // // // // //       }
// // // // // //     }
// // // // // //   } catch (e) {
// // // // // //     debug("❌ Error processing pending notification: $e");
// // // // // //   }
// // // // // // }

// // // // // // String _extractPhoneNumberFromNotification(String data) {
// // // // // //   // Implement your logic to extract phone number from notification data
// // // // // //   // This depends on how your notification payload is structured
// // // // // //   try {
// // // // // //     // Example: if data contains phone number directly
// // // // // //     if (data.contains('phone') || data.contains('number')) {
// // // // // //       final regex = RegExp(r'(\+?\d[\d\s\-\(\)]{8,}\d)');
// // // // // //       final match = regex.firstMatch(data);
// // // // // //       return match?.group(0) ?? '';
// // // // // //     }
// // // // // //     return '';
// // // // // //   } catch (e) {
// // // // // //     return '';
// // // // // //   }
// // // // // // }

// // // // // // String _extractLeadNameFromNotification(String data) {
// // // // // //   // Implement your logic to extract lead name from notification data
// // // // // //   // This depends on how your notification payload is structured
// // // // // //   try {
// // // // // //     if (data.contains('name') || data.contains('lead')) {
// // // // // //       final regex = RegExp(r'"name"\s*:\s*"([^"]+)"');
// // // // // //       final match = regex.firstMatch(data);
// // // // // //       return match?.group(1) ?? 'WatConnect';
// // // // // //     }
// // // // // //     return 'WatConnect';
// // // // // //   } catch (e) {
// // // // // //     return 'WatConnect';
// // // // // //   }
// // // // // // }

// // // // // // class MyApp extends StatefulWidget {
// // // // // //   const MyApp({super.key});

// // // // // //   @override
// // // // // //   State<MyApp> createState() => _MyAppState();
// // // // // // }

// // // // // // class _MyAppState extends State<MyApp> {
// // // // // //   late final AppLinks _appLinks;
// // // // // //   StreamSubscription<Uri>? _linkSubscription;
// // // // // //   bool _isAppInitialized = false;
// // // // // //   bool _areProvidersReady = false;

// // // // // //   @override
// // // // // //   void initState() {
// // // // // //     super.initState();
// // // // // //     debug("🚀 AppLinks initialized");

// // // // // //     _appLinks = AppLinks();
// // // // // //     _handleInitialUri();
// // // // // //     _listenToUriStream();

// // // // // //     // Set app as initialized after a short delay
// // // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // //       setState(() {
// // // // // //         _isAppInitialized = true;
// // // // // //       });
// // // // // //       _checkAndProcessDeepLink();
// // // // // //     });
// // // // // //   }

// // // // // //   /// 🔹 App killed state
// // // // // //   Future<void> _handleInitialUri() async {
// // // // // //     try {
// // // // // //       final Uri? initialUri = await _appLinks.getInitialLink();
// // // // // //       debug("📌 Initial URI => $initialUri");

// // // // // //       if (initialUri != null) {
// // // // // //         pendingDeepLink = initialUri;
// // // // // //         _checkAndProcessDeepLink();
// // // // // //       }
// // // // // //     } catch (e) {
// // // // // //       debug("❌ Initial URI error: $e");
// // // // // //     }
// // // // // //   }

// // // // // //   /// 🔹 Background / foreground
// // // // // //   void _listenToUriStream() {
// // // // // //     _linkSubscription = _appLinks.uriLinkStream.listen(
// // // // // //       (Uri uri) {
// // // // // //         debug("🔗 Stream URI => $uri");
// // // // // //         pendingDeepLink = uri;
// // // // // //         _checkAndProcessDeepLink();
// // // // // //       },
// // // // // //       onError: (err) {
// // // // // //         debug("❌ URI Stream error: $err");
// // // // // //       },
// // // // // //     );
// // // // // //   }

// // // // // //   void _checkAndProcessDeepLink() {
// // // // // //     if (pendingDeepLink == null || !_isAppInitialized || !_areProvidersReady) {
// // // // // //       return;
// // // // // //     }

// // // // // //     _processDeepLink();
// // // // // //   }

// // // // // //   void _processDeepLink() async {
// // // // // //     if (pendingDeepLink == null) return;

// // // // // //     final uri = pendingDeepLink!;
// // // // // //     debug("➡️ Processing DeepLink: $uri");

// // // // // //     if (!uri.pathSegments.contains('chat')) return;

// // // // // //     final params = uri.queryParameters;
// // // // // //     String leadName = params['name'] ?? 'WatConnect';
// // // // // //     String wpnumber = params['number'] ?? '';
// // // // // //     final id = params['id'];

// // // // // //     if (wpnumber.isEmpty) {
// // // // // //       wpnumber = await _extractPhoneNumberFromToken();
// // // // // //     }

// // // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // //       final context = navigatorKey.currentContext;
// // // // // //       if (context == null) {
// // // // // //         debug("❌ Context is null, cannot navigate");
// // // // // //         return;
// // // // // //       }

// // // // // //       Navigator.push(
// // // // // //         context,
// // // // // //         MaterialPageRoute(
// // // // // //           builder: (_) => WhatsappChatScreen(
// // // // // //             leadName: leadName,
// // // // // //             wpnumber: wpnumber,
// // // // // //             id: id,
// // // // // //           ),
// // // // // //         ),
// // // // // //       );

// // // // // //       pendingDeepLink = null;
// // // // // //     });
// // // // // //   }

// // // // // //   Future<String> _extractPhoneNumberFromToken() async {
// // // // // //     try {
// // // // // //       final prefs = await SharedPreferences.getInstance();

// // // // // //       String phoneNumber = prefs.getString('user_phone') ??
// // // // // //                           prefs.getString('phone_number') ??
// // // // // //                           prefs.getString('wp_number') ??
// // // // // //                           '';

// // // // // //       if (phoneNumber.isEmpty) {
// // // // // //         final userData = prefs.getString(SharedPrefsConstants.accessTokenKey);
// // // // // //         if (userData != null && userData.isNotEmpty) {

// // // // // //           phoneNumber = _extractPhoneFromUserData(userData);
// // // // // //         }
// // // // // //       }

// // // // // //       if (phoneNumber.isEmpty) {
// // // // // //         final fcmToken = await FirebaseMessaging.instance.getToken();
// // // // // //         debug("📱 FCM Token: $fcmToken");

// // // // // //       }

// // // // // //       debug("📱 Extracted phone number from token: $phoneNumber");
// // // // // //       return phoneNumber;
// // // // // //     } catch (e) {
// // // // // //       debug("❌ Error extracting phone number from token: $e");
// // // // // //       return '';
// // // // // //     }
// // // // // //   }

// // // // // //   /// 🔹 Extract phone number from user data string
// // // // // //   String _extractPhoneFromUserData(String userData) {
// // // // // //     try {
// // // // // //       // Assuming userData is JSON string
// // // // // //       // You might need to parse it properly based on your actual structure
// // // // // //       if (userData.contains('phone') || userData.contains('mobile')) {
// // // // // //         final regex = RegExp(r'"phone":\s*"([^"]+)"');
// // // // // //         final match = regex.firstMatch(userData);
// // // // // //         return match?.group(1) ?? '';
// // // // // //       }
// // // // // //       return '';
// // // // // //     } catch (e) {
// // // // // //       return '';
// // // // // //     }
// // // // // //   }

// // // // // //   /// 🔹 Callback when providers are ready
// // // // // //   void _onProvidersReady() {
// // // // // //     if (!_areProvidersReady) {
// // // // // //       setState(() {
// // // // // //         _areProvidersReady = true;
// // // // // //       });
// // // // // //       _checkAndProcessDeepLink();
// // // // // //     }
// // // // // //   }

// // // // // //   @override
// // // // // //   void dispose() {
// // // // // //     _linkSubscription?.cancel();
// // // // // //     super.dispose();
// // // // // //   }

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     // Call providers ready callback after UI is built
// // // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // //       _onProvidersReady();
// // // // // //     });

// // // // // //     SystemChrome.setSystemUIOverlayStyle(
// // // // // //       const SystemUiOverlayStyle(
// // // // // //         statusBarColor: Colors.transparent,
// // // // // //         statusBarIconBrightness: Brightness.dark,
// // // // // //         statusBarBrightness: Brightness.light,
// // // // // //       ),
// // // // // //     );

// // // // // //     SystemChrome.setPreferredOrientations([
// // // // // //       DeviceOrientation.portraitUp,
// // // // // //       DeviceOrientation.portraitDown,
// // // // // //     ]);

// // // // // //     return MultiProvider(
// // // // // //       providers: [
// // // // // //         ChangeNotifierProvider(
// // // // // //             create: (_) => ApprovedTemplateViewModel(context)),
// // // // // //         ChangeNotifierProvider(create: (_) => UnreadCountVm(context)),
// // // // // //         ChangeNotifierProvider(create: (_) => GroupsViewModel(context)),
// // // // // //         ChangeNotifierProvider(create: (_) => MessageViewModel(context)),
// // // // // //         ChangeNotifierProvider(create: (_) => CampaignChartViewModel(context)),
// // // // // //         ChangeNotifierProvider(create: (_) => LeadListViewModel(context)),
// // // // // //         ChangeNotifierProvider(create: (_) => TagsListViewModel(context)),
// // // // // //         ChangeNotifierProvider(create: (_) => CampaignViewModel(context)),
// // // // // //         ChangeNotifierProvider(create: (_) => MeesageHistoryViewModel(context)),
// // // // // //         ChangeNotifierProvider(create: (_) => LeadCountViewModel(context)),
// // // // // //         ChangeNotifierProvider(create: (_) => TempleteListViewModel(context)),
// // // // // //         ChangeNotifierProvider(create: (_) => AutoResponseViewModel(context)),
// // // // // //         ChangeNotifierProvider(
// // // // // //             create: (_) => WhatsappSettingViewModel(context)),
// // // // // //         ChangeNotifierProvider(create: (_) => CampaignCountViewModel(context)),
// // // // // //         ChangeNotifierProvider(create: (_) => ChartListViewModel(context)),
// // // // // //         ChangeNotifierProvider(create: (_) => GetUserViewModel(context)),
// // // // // //         ChangeNotifierProvider(create: (_) => UserDataListViewModel(context)),
// // // // // //         ChangeNotifierProvider(create: (_) => MessageController()),
// // // // // //         ChangeNotifierProvider(create: (_) => DashBoardController()),
// // // // // //         ChangeNotifierProvider(create: (_) => TemplateController()),
// // // // // //         ChangeNotifierProvider(create: (_) => BusinessNumberController()),
// // // // // //         ChangeNotifierProvider(create: (_) => CallsViewModel(context)),
// // // // // //         ChangeNotifierProvider(create: (_) => ChatMessageController()),
// // // // // //         ChangeNotifierProvider(create: (_) => SfcampaignController()),
// // // // // //         ChangeNotifierProvider(create: (_) => WalletController()),
// // // // // //         ChangeNotifierProvider(create: (_) => LeadController()),
// // // // // //         ChangeNotifierProvider(create: (_) => SfFileUploadController()),
// // // // // //       ],
// // // // // //       child: MaterialApp(
// // // // // //         debugShowCheckedModeBanner: false,
// // // // // //         navigatorKey: navigatorKey,
// // // // // //         navigatorObservers: [routeObserver],
// // // // // //         title: 'WatConnect',
// // // // // //         theme: ThemeData(
// // // // // //           textTheme: GoogleFonts.kohSantepheapTextTheme(),
// // // // // //           primaryColor: AppColor.navBarIconColor,
// // // // // //           appBarTheme: const AppBarTheme(
// // // // // //             backgroundColor: AppColor.navBarIconColor,
// // // // // //           ),
// // // // // //         ),
// // // // // //         builder: EasyLoading.init(),
// // // // // //         home: const SplashView(),
// // // // // //         // Handle route for deep linking
// // // // // //         onGenerateRoute: (settings) {
// // // // // //           // This can be used for more advanced routing if needed
// // // // // //           return null;
// // // // // //         },
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }
// // // // // import 'dart:async';
// // // // // import 'dart:core';

// // // // // import 'package:app_links/app_links.dart';
// // // // // import 'package:firebase_core/firebase_core.dart';
// // // // // import 'package:firebase_messaging/firebase_messaging.dart';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:flutter/services.dart';
// // // // // import 'package:flutter_easyloading/flutter_easyloading.dart';
// // // // // import 'package:google_fonts/google_fonts.dart';
// // // // // import 'package:provider/provider.dart';
// // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // // import 'package:timezone/data/latest.dart' as tz;
// // // // // import 'package:whatsapp/utils/app_constants.dart';

// // // // // // Controllers & VMs
// // // // // import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
// // // // // import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
// // // // // import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
// // // // // import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
// // // // // import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
// // // // // import 'package:whatsapp/salesforce/controller/template_controller.dart';

// // // // // import 'package:whatsapp/services/notifications/notification_service.dart';
// // // // // import 'package:whatsapp/utils/app_color.dart';
// // // // // import 'package:whatsapp/utils/function_lib.dart';

// // // // // import 'package:whatsapp/view_models/approved_template_vm.dart';
// // // // // import 'package:whatsapp/view_models/auto_response_vm.dart';
// // // // // import 'package:whatsapp/view_models/call_view_model.dart';
// // // // // import 'package:whatsapp/view_models/campaign_chart_vm.dart';
// // // // // import 'package:whatsapp/view_models/campaign_count_vm.dart';
// // // // // import 'package:whatsapp/view_models/campaign_vm.dart';
// // // // // import 'package:whatsapp/view_models/chart_list_vm.dart';
// // // // // import 'package:whatsapp/view_models/get_user_vm.dart';
// // // // // import 'package:whatsapp/view_models/groups_view_model.dart';
// // // // // import 'package:whatsapp/view_models/lead_controller.dart';
// // // // // import 'package:whatsapp/view_models/lead_count_vm.dart';
// // // // // import 'package:whatsapp/view_models/lead_list_vm.dart';
// // // // // import 'package:whatsapp/view_models/message_controller.dart';
// // // // // import 'package:whatsapp/view_models/message_history_vm.dart';
// // // // // import 'package:whatsapp/view_models/message_list_vm.dart';
// // // // // import 'package:whatsapp/view_models/tags_list_vm.dart';
// // // // // import 'package:whatsapp/view_models/templete_list_vm.dart';
// // // // // import 'package:whatsapp/view_models/unread_count_vm.dart';
// // // // // import 'package:whatsapp/view_models/user_data_list_vm.dart';
// // // // // import 'package:whatsapp/view_models/wallet_controller.dart';
// // // // // import 'package:whatsapp/view_models/whatsapp_setting_vm.dart';

// // // // // import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
// // // // // import 'package:whatsapp/views/view/splash_view.dart';

// // // // // import 'firebase_options.dart';

// // // // // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// // // // // final RouteObserver<ModalRoute<void>> routeObserver =
// // // // //     RouteObserver<ModalRoute<void>>();

// // // // // /// store deep link safely until app ready
// // // // // Uri? pendingDeepLink;

// // // // // @pragma('vm:entry-point')
// // // // // Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// // // // //   await Firebase.initializeApp();
// // // // // }

// // // // // void main() async {
// // // // //   WidgetsFlutterBinding.ensureInitialized();

// // // // //   try {
// // // // //     tz.initializeTimeZones();

// // // // //     await Firebase.initializeApp(
// // // // //       options: DefaultFirebaseOptions.currentPlatform,
// // // // //     );

// // // // //     FirebaseMessaging.onBackgroundMessage(
// // // // //       firebaseMessagingBackgroundHandler,
// // // // //     );

// // // // //     await NotificationService.init();

// // // // //     runApp(const MyApp());
// // // // //     await NotificationService.handleInitialMessage();
// // // // //   } catch (e) {
// // // // //     debug("❌ Error in main(): $e");
// // // // //     // You might want to show an error screen here
// // // // //     runApp(
// // // // //       MaterialApp(
// // // // //         home: Scaffold(
// // // // //           body: Center(
// // // // //             child: Text('App initialization failed: $e'),
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // class MyApp extends StatefulWidget {
// // // // //   const MyApp({super.key});

// // // // //   @override
// // // // //   State<MyApp> createState() => _MyAppState();
// // // // // }

// // // // // class _MyAppState extends State<MyApp> {
// // // // //   late final AppLinks _appLinks;
// // // // //   StreamSubscription<Uri>? _linkSubscription;
// // // // //   bool _isAppInitialized = false;
// // // // //   bool _areProvidersReady = false;

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();

// // // // //     try {
// // // // //       debug("🚀 AppLinks initialized");
// // // // //       _appLinks = AppLinks();
// // // // //       _handleInitialUri();
// // // // //       _listenToUriStream();

// // // // //       // Set app as initialized after a short delay
// // // // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // //         if (mounted) {
// // // // //           setState(() {
// // // // //             _isAppInitialized = true;
// // // // //           });
// // // // //           _checkAndProcessDeepLink();
// // // // //         }
// // // // //       });
// // // // //     } catch (e) {
// // // // //       debug("❌ Error in MyApp initState: $e");
// // // // //     }
// // // // //   }

// // // // //   /// 🔹 App killed state
// // // // //   Future<void> _handleInitialUri() async {
// // // // //     try {
// // // // //       final Uri? initialUri = await _appLinks.getInitialLink();
// // // // //       debug("📌 Initial URI => $initialUri");

// // // // //       if (initialUri != null) {
// // // // //         pendingDeepLink = initialUri;
// // // // //         _checkAndProcessDeepLink();
// // // // //       }
// // // // //     } catch (e) {
// // // // //       debug("❌ Initial URI error: $e");
// // // // //     }
// // // // //   }

// // // // //   /// 🔹 Background / foreground
// // // // //   void _listenToUriStream() {
// // // // //     _linkSubscription = _appLinks.uriLinkStream.listen(
// // // // //       (Uri uri) {
// // // // //         debug("🔗 Stream URI => $uri");
// // // // //         pendingDeepLink = uri;
// // // // //         _checkAndProcessDeepLink();
// // // // //       },
// // // // //       onError: (err) {
// // // // //         debug("❌ URI Stream error: $err");
// // // // //       },
// // // // //     );
// // // // //   }

// // // // //   /// 🔹 Check conditions and process deep link
// // // // //   void _checkAndProcessDeepLink() {
// // // // //     try {
// // // // //       if (pendingDeepLink == null ||
// // // // //           !_isAppInitialized ||
// // // // //           !_areProvidersReady) {
// // // // //         debug("⏳ Skipping deep link - conditions not met");
// // // // //         return;
// // // // //       }

// // // // //       _processDeepLink();
// // // // //     } catch (e) {
// // // // //       debug("❌ Error in checkAndProcessDeepLink: $e");
// // // // //     }
// // // // //   }

// // // // //   /// 🔹 Extract phone numbers from URL path and query parameters
// // // // //   Map<String, String> _extractPhoneNumbersFromUri(Uri uri) {
// // // // //     final Map<String, String> phoneNumbers = {
// // // // //       'leadPhone': '',
// // // // //       'whatsappSettingNumber': ''
// // // // //     };

// // // // //     try {
// // // // //       debug("🔍 Extracting phone numbers from URI: $uri");

// // // // //       // Extract lead phone from path (e.g., /message/history/+917740989118)
// // // // //       final pathSegments = uri.pathSegments;
// // // // //       for (var segment in pathSegments) {
// // // // //         if (segment.startsWith('+') && segment.length > 10) {
// // // // //           phoneNumbers['leadPhone'] = segment;
// // // // //           debug("📱 Found lead phone in path: ${phoneNumbers['leadPhone']}");
// // // // //           break;
// // // // //         }
// // // // //       }

// // // // //       // Extract whatsapp_setting_number from query parameters
// // // // //       final queryParams = uri.queryParameters;
// // // // //       if (queryParams.containsKey('whatsapp_setting_number')) {
// // // // //         phoneNumbers['whatsappSettingNumber'] =
// // // // //             queryParams['whatsapp_setting_number']!;
// // // // //         debug(
// // // // //             "📱 Found whatsapp setting number: ${phoneNumbers['whatsappSettingNumber']}");
// // // // //       }

// // // // //       // If not found in query, try to extract from full URL
// // // // //       if (phoneNumbers['whatsappSettingNumber']!.isEmpty) {
// // // // //         final urlString = uri.toString();
// // // // //         final regex = RegExp(r'whatsapp_setting_number=(\+?\d+)');
// // // // //         final match = regex.firstMatch(urlString);
// // // // //         if (match != null && match.group(1) != null) {
// // // // //           phoneNumbers['whatsappSettingNumber'] = match.group(1)!;
// // // // //           debug(
// // // // //               "📱 Extracted whatsapp setting number from URL: ${phoneNumbers['whatsappSettingNumber']}");
// // // // //         }
// // // // //       }

// // // // //       return phoneNumbers;
// // // // //     } catch (e) {
// // // // //       debug("❌ Error extracting phone numbers: $e");
// // // // //       return phoneNumbers;
// // // // //     }
// // // // //   }

// // // // //   /// 🔹 Process deep link after providers ready
// // // // //   void _processDeepLink() async {
// // // // //     try {
// // // // //       if (pendingDeepLink == null) {
// // // // //         debug("⚠️ No pending deep link to process");
// // // // //         return;
// // // // //       }

// // // // //       final uri = pendingDeepLink!;
// // // // //       debug("➡️ Processing DeepLink: $uri");

// // // // //       // Check if this is your API URL pattern
// // // // //       final isMessageHistoryUrl =
// // // // //           uri.toString().contains('/api/whatsapp/message/history/');

// // // // //       if (isMessageHistoryUrl) {
// // // // //         // Extract phone numbers from URL
// // // // //         final phoneNumbers = _extractPhoneNumbersFromUri(uri);
// // // // //         final leadPhone = phoneNumbers['leadPhone'] ?? '';
// // // // //         final whatsappSettingNumber =
// // // // //             phoneNumbers['whatsappSettingNumber'] ?? '';

// // // // //         if (leadPhone.isEmpty) {
// // // // //           debug("❌ Lead phone number not found in URL");
// // // // //           return;
// // // // //         }

// // // // //         // Get additional data from tokens if needed
// // // // //         final userData = await _getUserDataFromTokens();
// // // // //         final leadName = userData['leadName'] ?? 'WatConnect User';

// // // // //         // Navigate to chat screen
// // // // //         WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // //           try {
// // // // //             final context = navigatorKey.currentContext;
// // // // //             if (context == null) {
// // // // //               debug("❌ Context is null, cannot navigate");
// // // // //               // Try again after delay
// // // // //               Future.delayed(const Duration(milliseconds: 500), () {
// // // // //                 _processDeepLink();
// // // // //               });
// // // // //               return;
// // // // //             }

// // // // //             // Check if we're already on chat screen
// // // // //             final currentRoute = ModalRoute.of(context);
// // // // //             if (currentRoute?.settings.name?.contains('chat') == true) {
// // // // //               debug("⚠️ Already on chat screen, skipping navigation");
// // // // //               pendingDeepLink = null;
// // // // //               return;
// // // // //             }

// // // // //             debug("🚀 Navigating to chat screen with:");
// // // // //             debug("   Lead Phone: $leadPhone");
// // // // //             debug("   WhatsApp Setting Number: $whatsappSettingNumber");
// // // // //             debug("   Lead Name: $leadName");

// // // // //             Navigator.push(
// // // // //               context,
// // // // //               MaterialPageRoute(
// // // // //                 builder: (_) => WhatsappChatScreen(
// // // // //                   leadName: leadName,
// // // // //                   wpnumber: leadPhone, // Use lead phone as wpnumber
// // // // //                   id: whatsappSettingNumber, // Use whatsapp setting number as id
// // // // //                 ),
// // // // //               ),
// // // // //             );

// // // // //             pendingDeepLink = null;
// // // // //           } catch (e) {
// // // // //             debug("❌ Navigation error: $e");
// // // // //           }
// // // // //         });
// // // // //       } else {
// // // // //         // Handle other deep link patterns
// // // // //         final params = uri.queryParameters;
// // // // //         String leadName = params['name'] ?? 'WatConnect User';
// // // // //         String wpnumber = params['number'] ?? '';
// // // // //         final id = params['id'];

// // // // //         // If phone number is empty, try to extract from token
// // // // //         if (wpnumber.isEmpty) {
// // // // //           wpnumber = await _extractPhoneNumberFromToken();
// // // // //         }

// // // // //         if (wpnumber.isNotEmpty) {
// // // // //           WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // //             try {
// // // // //               final context = navigatorKey.currentContext;
// // // // //               if (context == null) {
// // // // //                 debug("❌ Context is null, cannot navigate");
// // // // //                 Future.delayed(const Duration(milliseconds: 500), () {
// // // // //                   _processDeepLink();
// // // // //                 });
// // // // //                 return;
// // // // //               }

// // // // //               Navigator.push(
// // // // //                 context,
// // // // //                 MaterialPageRoute(
// // // // //                   builder: (_) => WhatsappChatScreen(
// // // // //                     leadName: leadName,
// // // // //                     wpnumber: wpnumber,
// // // // //                     id: id ?? '',
// // // // //                   ),
// // // // //                 ),
// // // // //               );

// // // // //               pendingDeepLink = null;
// // // // //             } catch (e) {
// // // // //               debug("❌ Navigation error: $e");
// // // // //             }
// // // // //           });
// // // // //         }
// // // // //       }
// // // // //     } catch (e) {
// // // // //       debug("❌ Error processing deep link: $e");
// // // // //     }
// // // // //   }

// // // // //   /// 🔹 Get user data from stored tokens
// // // // //   Future<Map<String, String>> _getUserDataFromTokens() async {
// // // // //     final Map<String, String> userData = {
// // // // //       'leadName': 'WatConnect User',
// // // // //       'phone': ''
// // // // //     };

// // // // //     try {
// // // // //       final prefs = await SharedPreferences.getInstance();

// // // // //       // Get access token
// // // // //       final accessToken = prefs.getString(SharedPrefsConstants.accessTokenKey);
// // // // //       final sfAccessToken = prefs.getString(SharedPrefsConstants.sfAccessToken);
// // // // //       final userKey = prefs.getString(SharedPrefsConstants.userKey);

// // // // //       debug("🔑 Tokens found:");
// // // // //       debug("   Access Token: ${accessToken?.substring(0, 20)}...");
// // // // //       debug("   SF Access Token: ${sfAccessToken?.substring(0, 20)}...");
// // // // //       debug("   User Key: ${userKey?.substring(0, 20)}...");

// // // // //       // Extract lead name from user data if available
// // // // //       if (userKey != null && userKey.isNotEmpty) {
// // // // //         try {
// // // // //           // Parse user data to extract name
// // // // //           if (userKey.contains('"name"')) {
// // // // //             final regex = RegExp(r'"name":\s*"([^"]+)"');
// // // // //             final match = regex.firstMatch(userKey);
// // // // //             if (match != null && match.group(1) != null) {
// // // // //               userData['leadName'] = match.group(1)!;
// // // // //             }
// // // // //           } else if (userKey.contains('"firstName"')) {
// // // // //             final regex = RegExp(r'"firstName":\s*"([^"]+)"');
// // // // //             final match = regex.firstMatch(userKey);
// // // // //             if (match != null && match.group(1) != null) {
// // // // //               userData['leadName'] = match.group(1)!;
// // // // //             }
// // // // //           }
// // // // //         } catch (e) {
// // // // //           debug("❌ Error parsing user data: $e");
// // // // //         }
// // // // //       }

// // // // //       // Extract phone number if needed
// // // // //       userData['phone'] = await _extractPhoneNumberFromToken();

// // // // //       return userData;
// // // // //     } catch (e) {
// // // // //       debug("❌ Error getting user data from tokens: $e");
// // // // //       return userData;
// // // // //     }
// // // // //   }

// // // // //   /// 🔹 Extract phone number from stored token
// // // // //   Future<String> _extractPhoneNumberFromToken() async {
// // // // //     try {
// // // // //       final prefs = await SharedPreferences.getInstance();

// // // // //       // Try to get phone number from various possible storage locations
// // // // //       String phoneNumber = prefs.getString('user_phone') ??
// // // // //           prefs.getString('phone_number') ??
// // // // //           prefs.getString('wp_number') ??
// // // // //           prefs.getString('lead_phone') ??
// // // // //           '';

// // // // //       // If not found in prefs, try to extract from user data
// // // // //       if (phoneNumber.isEmpty) {
// // // // //         final userData = prefs.getString(SharedPrefsConstants.userKey);
// // // // //         if (userData != null && userData.isNotEmpty) {
// // // // //           phoneNumber = _extractPhoneFromUserData(userData);
// // // // //         }
// // // // //       }

// // // // //       // If still empty, try access token
// // // // //       if (phoneNumber.isEmpty) {
// // // // //         final accessToken =
// // // // //             prefs.getString(SharedPrefsConstants.accessTokenKey);
// // // // //         debug(
// // // // //             "Access Token for phone extraction: ${accessToken?.substring(0, 20)}...");
// // // // //         if (accessToken != null && accessToken.isNotEmpty) {
// // // // //           phoneNumber = _extractPhoneFromAccessToken(accessToken);
// // // // //           debug("Extracted phone from access token: $phoneNumber");
// // // // //         }
// // // // //       }

// // // // //       debug(
// // // // //           "📱 Extracted phone number from token: ${phoneNumber.isNotEmpty ? phoneNumber : 'Not found'}");
// // // // //       return phoneNumber;
// // // // //     } catch (e) {
// // // // //       debug("❌ Error extracting phone number from token: $e");
// // // // //       return '';
// // // // //     }
// // // // //   }

// // // // //   /// 🔹 Extract phone number from user data string
// // // // //   String _extractPhoneFromUserData(String userData) {
// // // // //     try {
// // // // //       // Try different patterns for phone number
// // // // //       final patterns = [
// // // // //         r'"phone":\s*"([^"]+)"',
// // // // //         r'"mobile":\s*"([^"]+)"',
// // // // //         r'"phoneNumber":\s*"([^"]+)"',
// // // // //         r'"contact":\s*"([^"]+)"',
// // // // //         r'"whatsapp":\s*"([^"]+)"',
// // // // //       ];

// // // // //       for (var pattern in patterns) {
// // // // //         final regex = RegExp(pattern);
// // // // //         final match = regex.firstMatch(userData);
// // // // //         if (match != null &&
// // // // //             match.group(1) != null &&
// // // // //             match.group(1)!.isNotEmpty) {
// // // // //           return match.group(1)!;
// // // // //         }
// // // // //       }
// // // // //       return '';
// // // // //     } catch (e) {
// // // // //       debug("❌ Error extracting phone from user data: $e");
// // // // //       return '';
// // // // //     }
// // // // //   }

// // // // //   String _extractPhoneFromAccessToken(String accessToken) {
// // // // //     try {
// // // // //       debug(" Extracting phone from access token payload $accessToken");
// // // // //       if (accessToken.contains('.')) {
// // // // //         final parts = accessToken.split('.');
// // // // //         if (parts.length >= 2) {
// // // // //           final payload = parts[1];
// // // // //           debug("🔍 Extracting phone from access token payload$payload");
// // // // //           if (payload.contains('phone') || payload.contains('mobile')) {
// // // // //             final regex = RegExp(r'phone[^:]*:\s*"([^"]+)"');
// // // // //             final match = regex.firstMatch(payload);
// // // // //             if (match != null && match.group(1) != null) {
// // // // //               return match.group(1)!;
// // // // //             }
// // // // //           }
// // // // //         }
// // // // //       }
// // // // //       return '';
// // // // //     } catch (e) {
// // // // //       debug("❌ Error extracting phone from access token: $e");
// // // // //       return '';
// // // // //     }
// // // // //   }

// // // // //   void _onProvidersReady() {
// // // // //     try {
// // // // //       if (!_areProvidersReady && mounted) {
// // // // //         setState(() {
// // // // //           _areProvidersReady = true;
// // // // //         });
// // // // //         _checkAndProcessDeepLink();
// // // // //       }
// // // // //     } catch (e) {
// // // // //       debug("❌ Error in onProvidersReady: $e");
// // // // //     }
// // // // //   }

// // // // //   @override
// // // // //   void dispose() {
// // // // //     _linkSubscription?.cancel();
// // // // //     super.dispose();
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {

// // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // //       _onProvidersReady();
// // // // //     });

// // // // //     SystemChrome.setSystemUIOverlayStyle(
// // // // //       const SystemUiOverlayStyle(
// // // // //         statusBarColor: Colors.transparent,
// // // // //         statusBarIconBrightness: Brightness.dark,
// // // // //         statusBarBrightness: Brightness.light,
// // // // //       ),
// // // // //     );

// // // // //     SystemChrome.setPreferredOrientations([
// // // // //       DeviceOrientation.portraitUp,
// // // // //       DeviceOrientation.portraitDown,
// // // // //     ]);

// // // // //     return MultiProvider(
// // // // //       providers: [
// // // // //         ChangeNotifierProvider(
// // // // //             create: (_) => ApprovedTemplateViewModel(context)),
// // // // //         ChangeNotifierProvider(create: (_) => UnreadCountVm(context)),
// // // // //         ChangeNotifierProvider(create: (_) => GroupsViewModel(context)),
// // // // //         ChangeNotifierProvider(create: (_) => MessageViewModel(context)),
// // // // //         ChangeNotifierProvider(create: (_) => CampaignChartViewModel(context)),
// // // // //         ChangeNotifierProvider(create: (_) => LeadListViewModel(context)),
// // // // //         ChangeNotifierProvider(create: (_) => TagsListViewModel(context)),
// // // // //         ChangeNotifierProvider(create: (_) => CampaignViewModel(context)),
// // // // //         ChangeNotifierProvider(create: (_) => MeesageHistoryViewModel(context)),
// // // // //         ChangeNotifierProvider(create: (_) => LeadCountViewModel(context)),
// // // // //         ChangeNotifierProvider(create: (_) => TempleteListViewModel(context)),
// // // // //         ChangeNotifierProvider(create: (_) => AutoResponseViewModel(context)),
// // // // //         ChangeNotifierProvider(
// // // // //             create: (_) => WhatsappSettingViewModel(context)),
// // // // //         ChangeNotifierProvider(create: (_) => CampaignCountViewModel(context)),
// // // // //         ChangeNotifierProvider(create: (_) => ChartListViewModel(context)),
// // // // //         ChangeNotifierProvider(create: (_) => GetUserViewModel(context)),
// // // // //         ChangeNotifierProvider(create: (_) => UserDataListViewModel(context)),
// // // // //         ChangeNotifierProvider(create: (_) => MessageController()),
// // // // //         ChangeNotifierProvider(create: (_) => DashBoardController()),
// // // // //         ChangeNotifierProvider(create: (_) => TemplateController()),
// // // // //         ChangeNotifierProvider(create: (_) => BusinessNumberController()),
// // // // //         ChangeNotifierProvider(create: (_) => CallsViewModel(context)),
// // // // //         ChangeNotifierProvider(create: (_) => ChatMessageController()),
// // // // //         ChangeNotifierProvider(create: (_) => SfcampaignController()),
// // // // //         ChangeNotifierProvider(create: (_) => WalletController()),
// // // // //         ChangeNotifierProvider(create: (_) => LeadController()),
// // // // //         ChangeNotifierProvider(create: (_) => SfFileUploadController()),
// // // // //       ],
// // // // //       child: Builder(
// // // // //         builder: (context) {
// // // // //           // Ensure providers are initialized
// // // // //           WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // //             _onProvidersReady();
// // // // //           });

// // // // //           return MaterialApp(
// // // // //             debugShowCheckedModeBanner: false,
// // // // //             navigatorKey: navigatorKey,
// // // // //             navigatorObservers: [routeObserver],
// // // // //             title: 'WatConnect',
// // // // //             theme: ThemeData(
// // // // //               textTheme: GoogleFonts.kohSantepheapTextTheme(),
// // // // //               primaryColor: AppColor.navBarIconColor,
// // // // //               appBarTheme: const AppBarTheme(
// // // // //                 backgroundColor: AppColor.navBarIconColor,
// // // // //               ),
// // // // //             ),
// // // // //             builder: EasyLoading.init(),
// // // // //             home: const SplashView(),
// // // // //           );
// // // // //         },
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }
// // // import 'dart:convert';
// // // import 'dart:async';
// // // import 'dart:core';

// // // import 'package:app_links/app_links.dart';
// // // import 'package:firebase_core/firebase_core.dart';
// // // import 'package:firebase_messaging/firebase_messaging.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:flutter_easyloading/flutter_easyloading.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:provider/provider.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import 'package:timezone/data/latest.dart' as tz;
// // // import 'package:whatsapp/utils/app_constants.dart';

// // // // Controllers & VMs
// // // import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
// // // import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
// // // import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
// // // import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
// // // import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
// // // import 'package:whatsapp/salesforce/controller/template_controller.dart';

// // // import 'package:whatsapp/services/notifications/notification_service.dart';
// // // import 'package:whatsapp/utils/app_color.dart';
// // // import 'package:whatsapp/utils/function_lib.dart';

// // // import 'package:whatsapp/view_models/approved_template_vm.dart';
// // // import 'package:whatsapp/view_models/auto_response_vm.dart';
// // // import 'package:whatsapp/view_models/call_view_model.dart';
// // // import 'package:whatsapp/view_models/campaign_chart_vm.dart';
// // // import 'package:whatsapp/view_models/campaign_count_vm.dart';
// // // import 'package:whatsapp/view_models/campaign_vm.dart';
// // // import 'package:whatsapp/view_models/chart_list_vm.dart';
// // // import 'package:whatsapp/view_models/get_user_vm.dart';
// // // import 'package:whatsapp/view_models/groups_view_model.dart';
// // // import 'package:whatsapp/view_models/lead_controller.dart';
// // // import 'package:whatsapp/view_models/lead_count_vm.dart';
// // // import 'package:whatsapp/view_models/lead_list_vm.dart';
// // // import 'package:whatsapp/view_models/message_controller.dart';
// // // import 'package:whatsapp/view_models/message_history_vm.dart';
// // // import 'package:whatsapp/view_models/message_list_vm.dart';
// // // import 'package:whatsapp/view_models/tags_list_vm.dart';
// // // import 'package:whatsapp/view_models/templete_list_vm.dart';
// // // import 'package:whatsapp/view_models/unread_count_vm.dart';
// // // import 'package:whatsapp/view_models/user_data_list_vm.dart';
// // // import 'package:whatsapp/view_models/wallet_controller.dart';
// // // import 'package:whatsapp/view_models/whatsapp_setting_vm.dart';

// // // import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
// // // import 'package:whatsapp/views/view/splash_view.dart';

// // // import 'firebase_options.dart';

// // // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// // // final RouteObserver<ModalRoute<void>> routeObserver =
// // //     RouteObserver<ModalRoute<void>>();

// // // /// store deep link safely until app ready
// // // Uri? pendingDeepLink;

// // // @pragma('vm:entry-point')
// // // Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// // //   await Firebase.initializeApp();
// // // }

// // // void main() async {
// // //   WidgetsFlutterBinding.ensureInitialized();

// // //   try {
// // //     tz.initializeTimeZones();

// // //     await Firebase.initializeApp(
// // //       options: DefaultFirebaseOptions.currentPlatform,
// // //     );

// // //     FirebaseMessaging.onBackgroundMessage(
// // //       firebaseMessagingBackgroundHandler,
// // //     );

// // //     await NotificationService.init();

// // //     runApp(const MyApp());
// // //     await NotificationService.handleInitialMessage();
// // //   } catch (e) {
// // //     debug("❌ Error in main(): $e");
// // //     // You might want to show an error screen here
// // //     runApp(
// // //       MaterialApp(
// // //         home: Scaffold(
// // //           body: Center(
// // //             child: Text('App initialization failed: $e'),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // // class MyApp extends StatefulWidget {
// // //   const MyApp({super.key});

// // //   @override
// // //   State<MyApp> createState() => _MyAppState();
// // // }

// // // class _MyAppState extends State<MyApp> {
// // //   late final AppLinks _appLinks;
// // //   StreamSubscription<Uri>? _linkSubscription;
// // //   bool _isAppInitialized = false;
// // //   bool _areProvidersReady = false;

// // //   @override
// // //   void initState() {
// // //     super.initState();

// // //     try {
// // //       debug("🚀 AppLinks initialized");
// // //       _appLinks = AppLinks();
// // //       _handleInitialUri();
// // //       _listenToUriStream();

// // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // //         if (mounted) {
// // //           setState(() {
// // //             _isAppInitialized = true;
// // //           });
// // //           _checkAndProcessDeepLink();
// // //         }
// // //       });
// // //     } catch (e) {
// // //       debug("❌ Error in MyApp initState: $e");
// // //     }
// // //   }

// // //   Future<void> _handleInitialUri() async {
// // //     try {
// // //       final Uri? initialUri = await _appLinks.getInitialLink();
// // //       debug("📌 Initial URI => $initialUri");

// // //       if (initialUri != null) {
// // //         pendingDeepLink = initialUri;
// // //         _checkAndProcessDeepLink();
// // //       }
// // //     } catch (e) {
// // //       debug("❌ Initial URI error: $e");
// // //     }
// // //   }

// // //   void _listenToUriStream() {
// // //     _linkSubscription = _appLinks.uriLinkStream.listen(
// // //       (Uri uri) {
// // //         debug("🔗 Stream URI => $uri");
// // //         pendingDeepLink = uri;
// // //         _checkAndProcessDeepLink();
// // //       },
// // //       onError: (err) {
// // //         debug("❌ URI Stream error: $err");
// // //       },
// // //     );
// // //   }

// // //   /// 🔹 Check conditions and process deep link
// // //   void _checkAndProcessDeepLink() {
// // //     try {
// // //       if (pendingDeepLink == null ||
// // //           !_isAppInitialized ||
// // //           !_areProvidersReady) {
// // //         debug("⏳ Skipping deep link - conditions not met");
// // //         return;
// // //       }

// // //       _processDeepLink();
// // //     } catch (e) {
// // //       debug("❌ Error in checkAndProcessDeepLink: $e");
// // //     }
// // //   }

// // //   /// 🔹 Extract phone numbers from URL path and query parameters
// // //   Map<String, String> _extractPhoneNumbersFromUri(Uri uri) {
// // //     final Map<String, String> phoneNumbers = {
// // //       'leadPhone': '',
// // //       'whatsappSettingNumber': ''
// // //     };

// // //     try {
// // //       debug("🔍 Extracting phone numbers from URI: $uri");

// // //       // Extract lead phone from path (e.g., /message/history/+917740989118)
// // //       final pathSegments = uri.pathSegments;
// // //       for (var segment in pathSegments) {
// // //         if (segment.startsWith('+') && segment.length > 10) {
// // //           phoneNumbers['leadPhone'] = segment;
// // //           debug("📱 Found lead phone in path: ${phoneNumbers['leadPhone']}");
// // //           break;
// // //         }
// // //       }

// // //       // Extract whatsapp_setting_number from query parameters
// // //       final queryParams = uri.queryParameters;
// // //       if (queryParams.containsKey('whatsapp_setting_number')) {
// // //         phoneNumbers['whatsappSettingNumber'] =
// // //             queryParams['whatsapp_setting_number']!;
// // //         debug(
// // //             "📱 Found whatsapp setting number: ${phoneNumbers['whatsappSettingNumber']}");
// // //       }

// // //       // If not found in query, try to extract from full URL
// // //       if (phoneNumbers['whatsappSettingNumber']!.isEmpty) {
// // //         final urlString = uri.toString();
// // //         final regex = RegExp(r'whatsapp_setting_number=(\+?\d+)');
// // //         final match = regex.firstMatch(urlString);
// // //         if (match != null && match.group(1) != null) {
// // //           phoneNumbers['whatsappSettingNumber'] = match.group(1)!;
// // //           debug(
// // //               "📱 Extracted whatsapp setting number from URL: ${phoneNumbers['whatsappSettingNumber']}");
// // //         }
// // //       }

// // //       return phoneNumbers;
// // //     } catch (e) {
// // //       debug("❌ Error extracting phone numbers: $e");
// // //       return phoneNumbers;
// // //     }
// // //   }

// // //   /// 🔹 Process deep link after providers ready
// // // //   void _processDeepLink() async {
// // // //     try {
// // // //       if (pendingDeepLink == null) {
// // // //         debug("⚠️ No pending deep link to process");
// // // //         return;
// // // //       }

// // // //       final uri = pendingDeepLink!;
// // // //       debug("➡️ Processing DeepLink: $uri");

// // // //       // Check if this is your API URL pattern
// // // //       final isMessageHistoryUrl =
// // // //           uri.toString().contains('/api/whatsapp/message/history/');
// // // // debug("isMessageHistoryUrlisMessageHistoryUrl$isMessageHistoryUrl");
// // // //       if (isMessageHistoryUrl) {
// // // //         // Extract phone numbers from URL
// // // //         final phoneNumbers = _extractPhoneNumbersFromUri(uri);
// // // //         debug("phoneNumbersphoneNumbersphoneNumbers$phoneNumbers");
// // // //         String leadPhone = phoneNumbers['leadPhone'] ?? '';
// // // //         final whatsappSettingNumber =
// // // //             phoneNumbers['whatsappSettingNumber'] ?? '';

// // // //         // Get user data from stored tokens
// // // //         final userData = await _getUserDataFromTokens();
// // // //         debug("userDatauserDatauserData$userData");
// // // //         final leadName = userData['leadName'] ?? 'WatConnect User';

// // // //         // Get user's whatsapp number from token
// // // //         final userWhatsappNumber = userData['whatsappNumber'] ?? '';

// // // //         // If lead phone is empty but we have user's whatsapp number, use that
// // // //         if (leadPhone.isEmpty && userWhatsappNumber.isNotEmpty) {
// // // //           leadPhone = userWhatsappNumber;
// // // //           debug("📱 Using user's whatsapp number as lead phone: $leadPhone");
// // // //         }

// // // //         if (leadPhone.isEmpty) {
// // // //           debug("❌ Lead phone number not found in URL or tokens");
// // // //           return;
// // // //         }

// // // //         // Navigate to chat screen
// // // //         WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //           try {
// // // //             final context = navigatorKey.currentContext;
// // // //             if (context == null) {
// // // //               debug("❌ Context is null, cannot navigate");
// // // //               // Try again after delay
// // // //               Future.delayed(const Duration(milliseconds: 500), () {
// // // //                 _processDeepLink();
// // // //               });
// // // //               return;
// // // //             }

// // // //             // Check if we're already on chat screen
// // // //             final currentRoute = ModalRoute.of(context);
// // // //             if (currentRoute?.settings.name?.contains('chat') == true) {
// // // //               debug("⚠️ Already on chat screen, skipping navigation");
// // // //               pendingDeepLink = null;
// // // //               return;
// // // //             }

// // // //             debug("🚀 Navigating to chat screen with:");
// // // //             debug("   Lead Phone: $leadPhone");
// // // //             debug("   WhatsApp Setting Number: $whatsappSettingNumber");
// // // //             debug("   Lead Name: $leadName");
// // // //             debug("   User WhatsApp Number: $userWhatsappNumber");

// // // //             Navigator.push(
// // // //               context,
// // // //               MaterialPageRoute(
// // // //                 builder: (_) => WhatsappChatScreen(
// // // //                   leadName: leadName,
// // // //                   wpnumber: leadPhone, // Use lead phone as wpnumber
// // // //                   id: whatsappSettingNumber, // Use whatsapp setting number as id
// // // //                 ),
// // // //               ),
// // // //             );

// // // //             pendingDeepLink = null;
// // // //           } catch (e) {
// // // //             debug("❌ Navigation error: $e");
// // // //           }
// // // //         });
// // // //       } else {
// // // //         // Handle other deep link patterns
// // // //         final params = uri.queryParameters;
// // // //         String leadName = params['name'] ?? 'WatConnect User';
// // // //         String wpnumber = params['number'] ?? '';
// // // //         final id = params['id'];

// // // //         // If phone number is empty, try to extract from token
// // // //         if (wpnumber.isEmpty) {
// // // //           final userData = await _getUserDataFromTokens();
// // // //           wpnumber = userData['whatsappNumber'] ?? '';
// // // //         }

// // // //         if (wpnumber.isNotEmpty) {
// // // //           WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //             try {
// // // //               final context = navigatorKey.currentContext;
// // // //               if (context == null) {
// // // //                 debug("❌ Context is null, cannot navigate");
// // // //                 Future.delayed(const Duration(milliseconds: 500), () {
// // // //                   _processDeepLink();
// // // //                 });
// // // //                 return;
// // // //               }

// // // //               Navigator.push(
// // // //                 context,
// // // //                 MaterialPageRoute(
// // // //                   builder: (_) => WhatsappChatScreen(
// // // //                     leadName: leadName,
// // // //                     wpnumber: wpnumber,
// // // //                     id: id ?? '',
// // // //                   ),
// // // //                 ),
// // // //               );

// // // //               pendingDeepLink = null;
// // // //             } catch (e) {
// // // //               debug("❌ Navigation error: $e");
// // // //             }
// // // //           });
// // // //         }
// // // //       }
// // // //     } catch (e) {
// // // //       debug("❌ Error processing deep link: $e");
// // // //     }
// // // //   }
// // //   void _processDeepLink() async {
// // //     try {
// // //       if (pendingDeepLink == null) {
// // //         debug("⚠️ No pending deep link to process");
// // //         return;
// // //       }

// // //       final uri = pendingDeepLink!;
// // //       final uriString = uri.toString();
// // //       debug("➡️ Processing DeepLink: $uriString");

// // //       // DIRECT NAVIGATION WITHOUT CHECKS
// // //       final String leadPhone = "+917740989118";
// // //       final String whatsappSettingNumber = "918306524244";

// // //       debug("🚀 NAVIGATING WITH STATIC VALUES:");
// // //       debug("   Lead Phone: $leadPhone");
// // //       debug("   WhatsApp Setting Number: $whatsappSettingNumber");

// // //       // Get user data
// // //       final userData = await _getUserDataFromTokens();
// // //       final String leadName = userData['leadName'] ?? 'WatConnect User';

// // //       debug("👤 User Name: $leadName");

// // //       // Navigate immediately - no conditions
// // //       _navigateToChatScreen(leadName, leadPhone, whatsappSettingNumber);
// // //     } catch (e) {
// // //       debug("❌ Error in _processDeepLink: $e");
// // //     }
// // //   }

// // //   /// Navigate to chat screen
// // //   void _navigateToChatScreen(
// // //       String leadName, String leadPhone, String whatsappSettingNumber) {
// // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // //       try {
// // //         final context = navigatorKey.currentContext;
// // //         if (context == null) {
// // //           debug("❌ Context is null, retrying in 500ms...");
// // //           // Retry after delay
// // //           Future.delayed(const Duration(milliseconds: 500), () {
// // //             _navigateToChatScreen(leadName, leadPhone, whatsappSettingNumber);
// // //           });
// // //           return;
// // //         }

// // //         // Check if already on chat screen
// // //         final currentRoute = ModalRoute.of(context);
// // //         if (currentRoute?.settings.name?.contains('chat') == true) {
// // //           debug("⚠️ Already on chat screen");
// // //           pendingDeepLink = null;
// // //           return;
// // //         }

// // //         debug("✅ Navigating to WhatsappChatScreen");

// // //         Navigator.push(
// // //           context,
// // //           MaterialPageRoute(
// // //             builder: (_) => WhatsappChatScreen(
// // //               leadName: leadName,
// // //               wpnumber: leadPhone,
// // //               id: whatsappSettingNumber,
// // //             ),
// // //           ),
// // //         );

// // //         pendingDeepLink = null;
// // //         debug("🎉 Navigation successful!");
// // //       } catch (e) {
// // //         debug("❌ Navigation error: $e");
// // //       }
// // //     });
// // //   }

// // //   /// Get user data from stored tokens
// // //   Future<Map<String, String>> _getUserDataFromTokens() async {
// // //     final Map<String, String> userData = {
// // //       'leadName': 'WatConnect User',
// // //       'whatsappNumber': ''
// // //     };

// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();
// // //       final userKey = prefs.getString(SharedPrefsConstants.userKey);

// // //       if (userKey != null && userKey.isNotEmpty) {
// // //         try {
// // //           // Parse the JSON
// // //           final Map<String, dynamic> jsonData = json.decode(userKey);

// // //           // Check if it has authToken
// // //           if (jsonData['authToken'] != null) {
// // //             final String authToken = jsonData['authToken'].toString();
// // //             debug("✅ Found authToken");

// // //             // Decode JWT
// // //             final Map<String, dynamic>? decodedToken =
// // //                 _decodeJWTToken(authToken);
// // //             if (decodedToken != null) {
// // //               userData['leadName'] = decodedToken['username']?.toString() ??
// // //                   decodedToken['email']?.toString().split('@').first ??
// // //                   'WatConnect User';

// // //               // Extract whatsapp number
// // //               if (decodedToken['whatsapp_number'] != null) {
// // //                 String number = decodedToken['whatsapp_number'].toString();
// // //                 String countryCode =
// // //                     decodedToken['country_code']?.toString() ?? '+91';

// // //                 if (!number.startsWith('+')) {
// // //                   number = '$countryCode$number';
// // //                 }
// // //                 userData['whatsappNumber'] = number;
// // //               }
// // //             }
// // //           } else if (jsonData['username'] != null) {
// // //             // Direct data (not JWT)
// // //             userData['leadName'] = jsonData['username'].toString();
// // //           }
// // //         } catch (e) {
// // //           debug("⚠️ JSON parse failed: $e");
// // //           // String extraction fallback
// // //           if (userKey.contains('username')) {
// // //             final regex = RegExp(r'"username":\s*"([^"]+)"');
// // //             final match = regex.firstMatch(userKey);
// // //             if (match != null && match.group(1) != null) {
// // //               userData['leadName'] = match.group(1)!;
// // //             }
// // //           }
// // //         }
// // //       }

// // //       debug("👤 User Data: ${userData['leadName']}");
// // //       return userData;
// // //     } catch (e) {
// // //       debug("❌ Error getting user data: $e");
// // //       return userData;
// // //     }
// // //   }

// // //   /// Decode JWT token
// // //   Map<String, dynamic>? _decodeJWTToken(String token) {
// // //     try {
// // //       final parts = token.split('.');
// // //       if (parts.length != 3) {
// // //         debug("❌ Invalid JWT format");
// // //         return null;
// // //       }

// // //       String payload = parts[1];
// // //       while (payload.length % 4 != 0) {
// // //         payload += '=';
// // //       }

// // //       final decoded = utf8.decode(base64Url.decode(payload));
// // //       return json.decode(decoded);
// // //     } catch (e) {
// // //       debug("❌ JWT decode failed: $e");
// // //       return null;
// // //     }
// // //   }
// // //   // Future<Map<String, String>> _getUserDataFromTokens() async {
// // //   //   final Map<String, String> userData = {
// // //   //     'leadName': 'WatConnect User',
// // //   //     'whatsappNumber': '',
// // //   //     'phone': ''
// // //   //   };

// // //   //   try {
// // //   //     final prefs = await SharedPreferences.getInstance();

// // //   //     // Get access token
// // //   //     final accessToken = prefs.getString(SharedPrefsConstants.accessTokenKey);
// // //   //     final sfAccessToken = prefs.getString(SharedPrefsConstants.sfAccessToken);
// // //   //     final userKey = prefs.getString(SharedPrefsConstants.userKey);

// // //   //     debug("🔑 Tokens found:");
// // //   //     debug("   Access Token: ${accessToken?.substring(0, min(20, accessToken?.length ?? 0))}...");
// // //   //     debug("   SF Access Token: ${sfAccessToken?.substring(0, min(20, sfAccessToken?.length ?? 0))}...");
// // //   //     debug("   User Key: ${userKey?.substring(0, min(20, userKey?.length ?? 0))}...");

// // //   //     // Extract user data from userKey (which contains your JSON)
// // //   //     if (userKey != null && userKey.isNotEmpty) {
// // //   //       try {
// // //   //         debug("🔍 Parsing user JSON data");

// // //   //         // Parse the JSON
// // //   //         final Map<String, dynamic> userJson = json.decode(userKey);

// // //   //         // Extract username
// // //   //         if (userJson['username'] != null) {
// // //   //           userData['leadName'] = userJson['username'].toString();
// // //   //           debug("👤 Found username: ${userData['leadName']}");
// // //   //         } else if (userJson['email'] != null) {
// // //   //           userData['leadName'] = userJson['email'].toString().split('@').first;
// // //   //         }

// // //   //         // Extract whatsapp_number - THIS IS THE KEY FIELD
// // //   //         if (userJson['whatsapp_number'] != null) {
// // //   //           String whatsappNumber = userJson['whatsapp_number'].toString();
// // //   //           String countryCode = userJson['country_code']?.toString() ?? '+91';

// // //   //           // Add country code if not already present
// // //   //           if (!whatsappNumber.startsWith('+')) {
// // //   //             whatsappNumber = '$countryCode$whatsappNumber';
// // //   //           }

// // //   //           userData['whatsappNumber'] = whatsappNumber;
// // //   //           debug("📱 Found whatsapp_number: ${userData['whatsappNumber']}");
// // //   //         }

// // //   //         // Also extract phone for backward compatibility
// // //   //         if (userJson['phone'] != null) {
// // //   //           userData['phone'] = userJson['phone'].toString();
// // //   //         } else if (userJson['mobile'] != null) {
// // //   //           userData['phone'] = userJson['mobile'].toString();
// // //   //         }

// // //   //       } catch (e) {
// // //   //         debug("❌ Error parsing user JSON: $e");

// // //   //         // Fallback: try to extract from string if JSON parsing fails
// // //   //         if (userKey.contains('whatsapp_number')) {
// // //   //           final regex = RegExp(r'"whatsapp_number":\s*"([^"]+)"');
// // //   //           final match = regex.firstMatch(userKey);
// // //   //           if (match != null && match.group(1) != null) {
// // //   //             userData['whatsappNumber'] = '+91${match.group(1)!}';
// // //   //             debug("📱 Extracted whatsapp_number from string: ${userData['whatsappNumber']}");
// // //   //           }
// // //   //         }

// // //   //         if (userKey.contains('username')) {
// // //   //           final regex = RegExp(r'"username":\s*"([^"]+)"');
// // //   //           final match = regex.firstMatch(userKey);
// // //   //           if (match != null && match.group(1) != null) {
// // //   //             userData['leadName'] = match.group(1)!;
// // //   //           }
// // //   //         }
// // //   //       }
// // //   //     }

// // //   //     // If whatsapp number still empty, try other sources
// // //   //     if (userData['whatsappNumber']!.isEmpty) {
// // //   //       userData['whatsappNumber'] = await _extractPhoneNumberFromToken();
// // //   //     }

// // //   //     return userData;
// // //   //   } catch (e) {
// // //   //     debug("❌ Error getting user data from tokens: $e");
// // //   //     return userData;
// // //   //   }
// // //   // }

// // //   int min(int a, int b) => a < b ? a : b;

// // //   /// 🔹 Extract phone number from stored token
// // //   Future<String> _extractPhoneNumberFromToken() async {
// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();

// // //       // Try to get phone number from various possible storage locations
// // //       String phoneNumber = prefs.getString('user_phone') ??
// // //           prefs.getString('phone_number') ??
// // //           prefs.getString('wp_number') ??
// // //           prefs.getString('lead_phone') ??
// // //           prefs.getString('whatsapp_number') ?? // Add this key
// // //           '';

// // //       // If not found in prefs, try to extract from user data
// // //       if (phoneNumber.isEmpty) {
// // //         final userData = prefs.getString(SharedPrefsConstants.userKey);
// // //         if (userData != null && userData.isNotEmpty) {
// // //           phoneNumber = _extractWhatsappNumberFromUserData(userData);
// // //         }
// // //       }

// // //       debug(
// // //           "📱 Extracted phone number from token: ${phoneNumber.isNotEmpty ? phoneNumber : 'Not found'}");
// // //       return phoneNumber;
// // //     } catch (e) {
// // //       debug("❌ Error extracting phone number from token: $e");
// // //       return '';
// // //     }
// // //   }

// // //   /// 🔹 Extract whatsapp number from user data string
// // //   String _extractWhatsappNumberFromUserData(String userData) {
// // //     try {
// // //       debug("🔍 Searching for whatsapp_number in user data");

// // //       // First try to parse as JSON
// // //       try {
// // //         // Decode the JSON string
// // //         final Map<String, dynamic> jsonData = json.decode(userData);
// // //         debug("✅ Parsed JSON: $jsonData");

// // //         // Check if whatsapp_number exists
// // //         if (jsonData['whatsapp_number'] != null) {
// // //           String number = jsonData['whatsapp_number'].toString();
// // //           debug("Original number: $number");

// // //           // Use country_code from JSON if present, else default to +91
// // //           String countryCode = jsonData['country_code']?.toString() ?? '+91';

// // //           // Prepend country code if number doesn't already start with '+'
// // //           if (!number.startsWith('+')) {
// // //             number = '$countryCode$number';
// // //           }

// // //           debug("Final WhatsApp number: $number");
// // //           return number;
// // //         } else {
// // //           debug("⚠️ whatsapp_number not found in JSON");
// // //         }
// // //       } catch (e) {
// // //         debug("⚠️ Failed to parse JSON, trying string extraction. Error: $e");
// // //       }

// // //       // Try different patterns for whatsapp number
// // //       final patterns = [
// // //         r'"whatsapp_number":\s*"([^"]+)"', // Primary pattern
// // //         r'"whatsappNumber":\s*"([^"]+)"',
// // //         r'"phone":\s*"([^"]+)"',
// // //         r'"mobile":\s*"([^"]+)"',
// // //         r'"phoneNumber":\s*"([^"]+)"',
// // //         r'"contact":\s*"([^"]+)"',
// // //         r'"whatsapp":\s*"([^"]+)"',
// // //       ];

// // //       for (var pattern in patterns) {
// // //         final regex = RegExp(pattern);
// // //         final match = regex.firstMatch(userData);
// // //         if (match != null &&
// // //             match.group(1) != null &&
// // //             match.group(1)!.isNotEmpty) {
// // //           String number = match.group(1)!;
// // //           debug("✅ Found number with pattern $pattern: $number");

// // //           // Add country code if it's a whatsapp_number and doesn't have +
// // //           if (pattern.contains('whatsapp') && !number.startsWith('+')) {
// // //             number = '+91$number';
// // //           }
// // //           return number;
// // //         }
// // //       }

// // //       debug("❌ No phone number found in user data");
// // //       return '';
// // //     } catch (e) {
// // //       debug("❌ Error extracting whatsapp number from user data: $e");
// // //       return '';
// // //     }
// // //   }

// // //   /// 🔹 Extract phone number from access token
// // //   String _extractPhoneFromAccessToken(String accessToken) {
// // //     try {
// // //       debug("🔍 Extracting phone from access token");

// // //       // First check if it's JWT
// // //       if (accessToken.contains('.')) {
// // //         final parts = accessToken.split('.');
// // //         if (parts.length >= 2) {
// // //           try {
// // //             // Decode base64 payload
// // //             String payload = parts[1];
// // //             // Add padding if needed
// // //             while (payload.length % 4 != 0) {
// // //               payload += '=';
// // //             }

// // //             // Decode from base64
// // //             final decodedPayload = utf8.decode(base64Url.decode(payload));
// // //             debug("📄 Decoded JWT payload: $decodedPayload");

// // //             // Parse as JSON
// // //             final payloadJson = json.decode(decodedPayload);

// // //             // Look for phone/whatsapp number in payload
// // //             if (payloadJson['whatsapp_number'] != null) {
// // //               return payloadJson['whatsapp_number'].toString();
// // //             }
// // //             if (payloadJson['phone'] != null) {
// // //               return payloadJson['phone'].toString();
// // //             }
// // //             if (payloadJson['mobile'] != null) {
// // //               return payloadJson['mobile'].toString();
// // //             }
// // //           } catch (e) {
// // //             debug("⚠️ Could not decode JWT payload: $e");
// // //           }
// // //         }
// // //       }

// // //       // Fallback: simple string search
// // //       if (accessToken.contains('whatsapp_number')) {
// // //         final regex = RegExp(r'whatsapp_number[^:]*:\s*"([^"]+)"');
// // //         final match = regex.firstMatch(accessToken);
// // //         if (match != null && match.group(1) != null) {
// // //           return match.group(1)!;
// // //         }
// // //       }

// // //       return '';
// // //     } catch (e) {
// // //       debug("❌ Error extracting phone from access token: $e");
// // //       return '';
// // //     }
// // //   }

// // //   /// 🔹 Callback when providers are ready
// // //   void _onProvidersReady() {
// // //     try {
// // //       if (!_areProvidersReady && mounted) {
// // //         setState(() {
// // //           _areProvidersReady = true;
// // //         });
// // //         _checkAndProcessDeepLink();
// // //       }
// // //     } catch (e) {
// // //       debug("❌ Error in onProvidersReady: $e");
// // //     }
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _linkSubscription?.cancel();
// // //     super.dispose();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     // Call providers ready callback after UI is built
// // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // //       _onProvidersReady();
// // //     });

// // //     SystemChrome.setSystemUIOverlayStyle(
// // //       const SystemUiOverlayStyle(
// // //         statusBarColor: Colors.transparent,
// // //         statusBarIconBrightness: Brightness.dark,
// // //         statusBarBrightness: Brightness.light,
// // //       ),
// // //     );

// // //     SystemChrome.setPreferredOrientations([
// // //       DeviceOrientation.portraitUp,
// // //       DeviceOrientation.portraitDown,
// // //     ]);

// // //     return MultiProvider(
// // //       providers: [
// // //         ChangeNotifierProvider(
// // //             create: (_) => ApprovedTemplateViewModel(context)),
// // //         ChangeNotifierProvider(create: (_) => UnreadCountVm(context)),
// // //         ChangeNotifierProvider(create: (_) => GroupsViewModel(context)),
// // //         ChangeNotifierProvider(create: (_) => MessageViewModel(context)),
// // //         ChangeNotifierProvider(create: (_) => CampaignChartViewModel(context)),
// // //         ChangeNotifierProvider(create: (_) => LeadListViewModel(context)),
// // //         ChangeNotifierProvider(create: (_) => TagsListViewModel(context)),
// // //         ChangeNotifierProvider(create: (_) => CampaignViewModel(context)),
// // //         ChangeNotifierProvider(create: (_) => MeesageHistoryViewModel(context)),
// // //         ChangeNotifierProvider(create: (_) => LeadCountViewModel(context)),
// // //         ChangeNotifierProvider(create: (_) => TempleteListViewModel(context)),
// // //         ChangeNotifierProvider(create: (_) => AutoResponseViewModel(context)),
// // //         ChangeNotifierProvider(
// // //             create: (_) => WhatsappSettingViewModel(context)),
// // //         ChangeNotifierProvider(create: (_) => CampaignCountViewModel(context)),
// // //         ChangeNotifierProvider(create: (_) => ChartListViewModel(context)),
// // //         ChangeNotifierProvider(create: (_) => GetUserViewModel(context)),
// // //         ChangeNotifierProvider(create: (_) => UserDataListViewModel(context)),
// // //         ChangeNotifierProvider(create: (_) => MessageController()),
// // //         ChangeNotifierProvider(create: (_) => DashBoardController()),
// // //         ChangeNotifierProvider(create: (_) => TemplateController()),
// // //         ChangeNotifierProvider(create: (_) => BusinessNumberController()),
// // //         ChangeNotifierProvider(create: (_) => CallsViewModel(context)),
// // //         ChangeNotifierProvider(create: (_) => ChatMessageController()),
// // //         ChangeNotifierProvider(create: (_) => SfcampaignController()),
// // //         ChangeNotifierProvider(create: (_) => WalletController()),
// // //         ChangeNotifierProvider(create: (_) => LeadController()),
// // //         ChangeNotifierProvider(create: (_) => SfFileUploadController()),
// // //       ],
// // //       child: Builder(
// // //         builder: (context) {
// // //           // Ensure providers are initialized
// // //           WidgetsBinding.instance.addPostFrameCallback((_) {
// // //             _onProvidersReady();
// // //           });

// // //           return MaterialApp(
// // //             debugShowCheckedModeBanner: false,
// // //             navigatorKey: navigatorKey,
// // //             navigatorObservers: [routeObserver],
// // //             title: 'WatConnect',
// // //             theme: ThemeData(
// // //               textTheme: GoogleFonts.kohSantepheapTextTheme(),
// // //               primaryColor: AppColor.navBarIconColor,
// // //               appBarTheme: const AppBarTheme(
// // //                 backgroundColor: AppColor.navBarIconColor,
// // //               ),
// // //             ),
// // //             builder: EasyLoading.init(),
// // //             home: const SplashView(),
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }
// // // }

// // // // import 'dart:convert';
// // // // import 'dart:async';
// // // // import 'dart:core';

// // // // import 'package:app_links/app_links.dart';
// // // // import 'package:firebase_core/firebase_core.dart';
// // // // import 'package:firebase_messaging/firebase_messaging.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:flutter_easyloading/flutter_easyloading.dart';
// // // // import 'package:google_fonts/google_fonts.dart';
// // // // import 'package:provider/provider.dart';
// // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // import 'package:timezone/data/latest.dart' as tz;
// // // // import 'package:whatsapp/utils/app_constants.dart';

// // // // // Controllers & VMs
// // // // import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
// // // // import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
// // // // import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
// // // // import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
// // // // import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
// // // // import 'package:whatsapp/salesforce/controller/template_controller.dart';

// // // // import 'package:whatsapp/services/notifications/notification_service.dart';
// // // // import 'package:whatsapp/utils/app_color.dart';
// // // // import 'package:whatsapp/utils/function_lib.dart';

// // // // import 'package:whatsapp/view_models/approved_template_vm.dart';
// // // // import 'package:whatsapp/view_models/auto_response_vm.dart';
// // // // import 'package:whatsapp/view_models/call_view_model.dart';
// // // // import 'package:whatsapp/view_models/campaign_chart_vm.dart';
// // // // import 'package:whatsapp/view_models/campaign_count_vm.dart';
// // // // import 'package:whatsapp/view_models/campaign_vm.dart';
// // // // import 'package:whatsapp/view_models/chart_list_vm.dart';
// // // // import 'package:whatsapp/view_models/get_user_vm.dart';
// // // // import 'package:whatsapp/view_models/groups_view_model.dart';
// // // // import 'package:whatsapp/view_models/lead_controller.dart';
// // // // import 'package:whatsapp/view_models/lead_count_vm.dart';
// // // // import 'package:whatsapp/view_models/lead_list_vm.dart';
// // // // import 'package:whatsapp/view_models/message_controller.dart';
// // // // import 'package:whatsapp/view_models/message_history_vm.dart';
// // // // import 'package:whatsapp/view_models/message_list_vm.dart';
// // // // import 'package:whatsapp/view_models/tags_list_vm.dart';
// // // // import 'package:whatsapp/view_models/templete_list_vm.dart';
// // // // import 'package:whatsapp/view_models/unread_count_vm.dart';
// // // // import 'package:whatsapp/view_models/user_data_list_vm.dart';
// // // // import 'package:whatsapp/view_models/wallet_controller.dart';
// // // // import 'package:whatsapp/view_models/whatsapp_setting_vm.dart';

// // // // import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
// // // // import 'package:whatsapp/views/view/splash_view.dart';

// // // // import 'firebase_options.dart';

// // // // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// // // // final RouteObserver<ModalRoute<void>> routeObserver =
// // // //     RouteObserver<ModalRoute<void>>();

// // // // /// store deep link safely until app ready
// // // // Uri? pendingDeepLink;

// // // // @pragma('vm:entry-point')
// // // // Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// // // //   await Firebase.initializeApp();
// // // // }

// // // // void main() async {
// // // //   WidgetsFlutterBinding.ensureInitialized();

// // // //   try {
// // // //     tz.initializeTimeZones();

// // // //     await Firebase.initializeApp(
// // // //       options: DefaultFirebaseOptions.currentPlatform,
// // // //     );

// // // //     FirebaseMessaging.onBackgroundMessage(
// // // //       firebaseMessagingBackgroundHandler,
// // // //     );

// // // //     await NotificationService.init();

// // // //     runApp(const MyApp());
// // // //     await NotificationService.handleInitialMessage();
// // // //   } catch (e) {
// // // //     debug("❌ Error in main(): $e");
// // // //     runApp(
// // // //       MaterialApp(
// // // //         home: Scaffold(
// // // //           body: Center(
// // // //             child: Text('App initialization failed: $e'),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class MyApp extends StatefulWidget {
// // // //   const MyApp({super.key});

// // // //   @override
// // // //   State<MyApp> createState() => _MyAppState();
// // // // }

// // // // class _MyAppState extends State<MyApp> {
// // // //   late final AppLinks _appLinks;
// // // //   StreamSubscription<Uri>? _linkSubscription;
// // // //   bool _isAppInitialized = false;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();

// // // //     try {
// // // //       debug("🚀 AppLinks initialized");
// // // //       _appLinks = AppLinks();
// // // //       _handleInitialUri();
// // // //       _listenToUriStream();

// // // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //         if (mounted) {
// // // //           setState(() {
// // // //             _isAppInitialized = true;
// // // //           });
// // // //           _processPendingDeepLink();
// // // //         }
// // // //       });
// // // //     } catch (e) {
// // // //       debug("❌ Error in MyApp initState: $e");
// // // //     }
// // // //   }

// // // //   /// 🔹 App killed state
// // // //   Future<void> _handleInitialUri() async {
// // // //     try {
// // // //       final Uri? initialUri = await _appLinks.getInitialLink();
// // // //       debug("📌 Initial URI => $initialUri");

// // // //       if (initialUri != null) {
// // // //         pendingDeepLink = initialUri;
// // // //         _processPendingDeepLink();
// // // //       }
// // // //     } catch (e) {
// // // //       debug("❌ Initial URI error: $e");
// // // //     }
// // // //   }

// // // //   /// 🔹 Background / foreground
// // // //   void _listenToUriStream() {
// // // //     _linkSubscription = _appLinks.uriLinkStream.listen(
// // // //       (Uri uri) {
// // // //         debug("🔗 Stream URI => $uri");
// // // //         pendingDeepLink = uri;
// // // //         _processPendingDeepLink();
// // // //       },
// // // //       onError: (err) {
// // // //         debug("❌ URI Stream error: $err");
// // // //       },
// // // //     );
// // // //   }

// // // //   /// 🔹 Process pending deep link
// // // //   void _processPendingDeepLink() {
// // // //     if (!_isAppInitialized || pendingDeepLink == null) return;

// // // //     _processDeepLink();
// // // //   }

// // // //   /// 🔹 Process deep link - SINGLE FUNCTION FOR EVERYTHING
// // // //   void _processDeepLink() async {
// // // //     try {
// // // //       if (pendingDeepLink == null) return;

// // // //       final uri = pendingDeepLink!;
// // // //       debug("➡️ Processing DeepLink: $uri");

// // // //       // Extract phone numbers from URL
// // // //       final Map<String, String> extractedData = _extractDataFromUrl(uri);
// // // //       final String leadPhone = extractedData['leadPhone'] ?? '';
// // // //       final String whatsappSettingNumber = extractedData['whatsappSettingNumber'] ?? '';

// // // //       if (leadPhone.isEmpty) {
// // // //         debug("❌ No phone number found in URL");
// // // //         return;
// // // //       }

// // // //       // Get user data and phone number
// // // //       final userData = await _getUserPhoneNumber();
// // // //       final String userPhone = userData['phone'] ?? '';
// // // //       final String userName = userData['name'] ?? 'WatConnect User';

// // // //       debug("📱 URL Lead Phone: $leadPhone");
// // // //       debug("📱 User Phone from Token: $userPhone");
// // // //       debug("👤 User Name: $userName");

// // // //       // Navigate to chat screen
// // // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //         final context = navigatorKey.currentContext;
// // // //         if (context == null) {
// // // //           debug("❌ Context is null, retrying...");
// // // //           Future.delayed(const Duration(milliseconds: 500), () {
// // // //             _processDeepLink();
// // // //           });
// // // //           return;
// // // //         }

// // // //         debug("🚀 Navigating to WhatsappChatScreen");

// // // //         Navigator.push(
// // // //           context,
// // // //           MaterialPageRoute(
// // // //             builder: (_) => WhatsappChatScreen(
// // // //               leadName: userName,
// // // //               wpnumber: leadPhone.isNotEmpty ? leadPhone : userPhone,
// // // //               id: whatsappSettingNumber,
// // // //             ),
// // // //           ),
// // // //         );

// // // //         pendingDeepLink = null;
// // // //       });
// // // //     } catch (e) {
// // // //       debug("❌ Error in _processDeepLink: $e");
// // // //     }
// // // //   }

// // // //   /// 🔹 SINGLE FUNCTION: Extract data from URL
// // // //   Map<String, String> _extractDataFromUrl(Uri uri) {
// // // //     final Map<String, String> data = {
// // // //       'leadPhone': '',
// // // //       'whatsappSettingNumber': ''
// // // //     };

// // // //     try {
// // // //       debug("🔍 Extracting data from URL: $uri");

// // // //       // Extract lead phone from path
// // // //       for (var segment in uri.pathSegments) {
// // // //         if (segment.startsWith('+') && segment.length > 10) {
// // // //           data['leadPhone'] = segment;
// // // //           break;
// // // //         }
// // // //       }

// // // //       // Extract whatsapp_setting_number from query
// // // //       data['whatsappSettingNumber'] =
// // // //           uri.queryParameters['whatsapp_setting_number'] ?? '';

// // // //       return data;
// // // //     } catch (e) {
// // // //       debug("❌ Error extracting data from URL: $e");
// // // //       return data;
// // // //     }
// // // //   }

// // // //   /// 🔹 SINGLE FUNCTION: Get user phone number from stored data
// // // //   Future<Map<String, String>> _getUserPhoneNumber() async {
// // // //     final Map<String, String> userData = {
// // // //       'name': 'WatConnect User',
// // // //       'phone': ''
// // // //     };

// // // //     try {
// // // //       final prefs = await SharedPreferences.getInstance();
// // // //       final userKey = prefs.getString(SharedPrefsConstants.userKey);

// // // //       if (userKey != null && userKey.isNotEmpty) {
// // // //         debug("🔑 User Key found, length: ${userKey.length}");

// // // //         // Parse JSON
// // // //         try {
// // // //           final Map<String, dynamic> jsonData = json.decode(userKey);
// // // //           debug("✅ JSON parsed successfully");

// // // //           // Check if it's the response structure with authToken
// // // //           if (jsonData['authToken'] != null) {
// // // //             final String authToken = jsonData['authToken'];
// // // //             debug("🔐 AuthToken found, decoding JWT...");

// // // //             // Decode JWT
// // // //             final Map<String, dynamic>? decodedToken = _decodeJWT(authToken);
// // // //             if (decodedToken != null) {
// // // //               userData['name'] = decodedToken['username']?.toString() ??
// // // //                                 decodedToken['email']?.toString().split('@').first ??
// // // //                                 'WatConnect User';
// // // //               userData['phone'] = _extractPhoneFromJson(decodedToken);
// // // //             }
// // // //           } else {
// // // //             // Direct JSON structure
// // // //             userData['name'] = jsonData['username']?.toString() ??
// // // //                               jsonData['email']?.toString().split('@').first ??
// // // //                               'WatConnect User';
// // // //             userData['phone'] = _extractPhoneFromJson(jsonData);
// // // //           }
// // // //         } catch (e) {
// // // //           debug("⚠️ JSON parse failed: $e, trying string extraction");

// // // //           // String extraction fallback
// // // //           userData['name'] = _extractFromString(userKey, 'username') ??
// // // //                             _extractFromString(userKey, 'email')?.split('@').first ??
// // // //                             'WatConnect User';
// // // //           userData['phone'] = _extractPhoneFromString(userKey);
// // // //         }
// // // //       }

// // // //       debug("📱 Final user data - Name: ${userData['name']}, Phone: ${userData['phone']}");
// // // //       return userData;
// // // //     } catch (e) {
// // // //       debug("❌ Error getting user phone number: $e");
// // // //       return userData;
// // // //     }
// // // //   }

// // // //   /// 🔹 Helper: Decode JWT token
// // // //   Map<String, dynamic>? _decodeJWT(String token) {
// // // //     try {
// // // //       final parts = token.split('.');
// // // //       if (parts.length != 3) return null;

// // // //       String payload = parts[1];
// // // //       while (payload.length % 4 != 0) {
// // // //         payload += '=';
// // // //       }

// // // //       final decoded = utf8.decode(base64Url.decode(payload));
// // // //       debug("🔓 Decoded JWT payload");
// // // //       return json.decode(decoded);
// // // //     } catch (e) {
// // // //       debug("❌ JWT decode failed: $e");
// // // //       return null;
// // // //     }
// // // //   }

// // // //   /// 🔹 Helper: Extract phone from JSON
// // // //   String _extractPhoneFromJson(Map<String, dynamic> json) {
// // // //     try {
// // // //       if (json['whatsapp_number'] != null) {
// // // //         String number = json['whatsapp_number'].toString();
// // // //         String countryCode = json['country_code']?.toString() ?? '+91';

// // // //         if (!number.startsWith('+')) {
// // // //           number = '$countryCode$number';
// // // //         }
// // // //         debug("✅ Extracted whatsapp_number from JSON: $number");
// // // //         return number;
// // // //       }

// // // //       // Fallback to other phone fields
// // // //       final phoneFields = ['phone', 'mobile', 'phoneNumber', 'contact'];
// // // //       for (var field in phoneFields) {
// // // //         if (json[field] != null) {
// // // //           debug("✅ Extracted $field from JSON: ${json[field]}");
// // // //           return json[field].toString();
// // // //         }
// // // //       }

// // // //       return '';
// // // //     } catch (e) {
// // // //       debug("❌ Error extracting phone from JSON: $e");
// // // //       return '';
// // // //     }
// // // //   }

// // // //   /// 🔹 Helper: Extract value from string
// // // //   String? _extractFromString(String data, String key) {
// // // //     try {
// // // //       final regex = RegExp('"$key":\\s*"([^"]+)"');
// // // //       final match = regex.firstMatch(data);
// // // //       return match?.group(1);
// // // //     } catch (e) {
// // // //       return null;
// // // //     }
// // // //   }

// // // //   /// 🔹 Helper: Extract phone from string
// // // //   String _extractPhoneFromString(String data) {
// // // //     try {
// // // //       // Try whatsapp_number first
// // // //       final whatsappRegex = RegExp(r'"whatsapp_number":\s*"([^"]+)"');
// // // //       final whatsappMatch = whatsappRegex.firstMatch(data);
// // // //       if (whatsappMatch != null && whatsappMatch.group(1) != null) {
// // // //         String number = whatsappMatch.group(1)!;

// // // //         // Try to get country code
// // // //         final countryRegex = RegExp(r'"country_code":\s*"([^"]+)"');
// // // //         final countryMatch = countryRegex.firstMatch(data);
// // // //         String countryCode = countryMatch?.group(1) ?? '+91';

// // // //         if (!number.startsWith('+')) {
// // // //           number = '$countryCode$number';
// // // //         }
// // // //         return number;
// // // //       }

// // // //       // Try other phone fields
// // // //       final phonePatterns = [
// // // //         r'"phone":\s*"([^"]+)"',
// // // //         r'"mobile":\s*"([^"]+)"',
// // // //         r'"phoneNumber":\s*"([^"]+)"'
// // // //       ];

// // // //       for (var pattern in phonePatterns) {
// // // //         final regex = RegExp(pattern);
// // // //         final match = regex.firstMatch(data);
// // // //         if (match != null && match.group(1) != null) {
// // // //           return match.group(1)!;
// // // //         }
// // // //       }

// // // //       return '';
// // // //     } catch (e) {
// // // //       debug("❌ Error extracting phone from string: $e");
// // // //       return '';
// // // //     }
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _linkSubscription?.cancel();
// // // //     super.dispose();
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //       _processPendingDeepLink();
// // // //     });

// // // //     SystemChrome.setSystemUIOverlayStyle(
// // // //       const SystemUiOverlayStyle(
// // // //         statusBarColor: Colors.transparent,
// // // //         statusBarIconBrightness: Brightness.dark,
// // // //         statusBarBrightness: Brightness.light,
// // // //       ),
// // // //     );

// // // //     SystemChrome.setPreferredOrientations([
// // // //       DeviceOrientation.portraitUp,
// // // //       DeviceOrientation.portraitDown,
// // // //     ]);

// // // //     return MultiProvider(
// // // //       providers: [
// // // //         ChangeNotifierProvider(
// // // //             create: (_) => ApprovedTemplateViewModel(context)),
// // // //         ChangeNotifierProvider(create: (_) => UnreadCountVm(context)),
// // // //         ChangeNotifierProvider(create: (_) => GroupsViewModel(context)),
// // // //         ChangeNotifierProvider(create: (_) => MessageViewModel(context)),
// // // //         ChangeNotifierProvider(create: (_) => CampaignChartViewModel(context)),
// // // //         ChangeNotifierProvider(create: (_) => LeadListViewModel(context)),
// // // //         ChangeNotifierProvider(create: (_) => TagsListViewModel(context)),
// // // //         ChangeNotifierProvider(create: (_) => CampaignViewModel(context)),
// // // //         ChangeNotifierProvider(create: (_) => MeesageHistoryViewModel(context)),
// // // //         ChangeNotifierProvider(create: (_) => LeadCountViewModel(context)),
// // // //         ChangeNotifierProvider(create: (_) => TempleteListViewModel(context)),
// // // //         ChangeNotifierProvider(create: (_) => AutoResponseViewModel(context)),
// // // //         ChangeNotifierProvider(
// // // //             create: (_) => WhatsappSettingViewModel(context)),
// // // //         ChangeNotifierProvider(create: (_) => CampaignCountViewModel(context)),
// // // //         ChangeNotifierProvider(create: (_) => ChartListViewModel(context)),
// // // //         ChangeNotifierProvider(create: (_) => GetUserViewModel(context)),
// // // //         ChangeNotifierProvider(create: (_) => UserDataListViewModel(context)),
// // // //         ChangeNotifierProvider(create: (_) => MessageController()),
// // // //         ChangeNotifierProvider(create: (_) => DashBoardController()),
// // // //         ChangeNotifierProvider(create: (_) => TemplateController()),
// // // //         ChangeNotifierProvider(create: (_) => BusinessNumberController()),
// // // //         ChangeNotifierProvider(create: (_) => CallsViewModel(context)),
// // // //         ChangeNotifierProvider(create: (_) => ChatMessageController()),
// // // //         ChangeNotifierProvider(create: (_) => SfcampaignController()),
// // // //         ChangeNotifierProvider(create: (_) => WalletController()),
// // // //         ChangeNotifierProvider(create: (_) => LeadController()),
// // // //         ChangeNotifierProvider(create: (_) => SfFileUploadController()),
// // // //       ],
// // // //       child: Builder(
// // // //         builder: (context) {
// // // //           return MaterialApp(
// // // //             debugShowCheckedModeBanner: false,
// // // //             navigatorKey: navigatorKey,
// // // //             navigatorObservers: [routeObserver],
// // // //             title: 'WatConnect',
// // // //             theme: ThemeData(
// // // //               textTheme: GoogleFonts.kohSantepheapTextTheme(),
// // // //               primaryColor: AppColor.navBarIconColor,
// // // //               appBarTheme: const AppBarTheme(
// // // //                 backgroundColor: AppColor.navBarIconColor,
// // // //               ),
// // // //             ),
// // // //             builder: EasyLoading.init(),
// // // //             home: const SplashView(),
// // // //           );
// // // //         },
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // import 'dart:convert';
// // import 'dart:async';
// // import 'dart:core';

// // import 'package:app_links/app_links.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_easyloading/flutter_easyloading.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:provider/provider.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:timezone/data/latest.dart' as tz;
// // import 'package:whatsapp/utils/app_constants.dart';

// // // Controllers & VMs
// // import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
// // import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
// // import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
// // import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
// // import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
// // import 'package:whatsapp/salesforce/controller/template_controller.dart';

// // import 'package:whatsapp/services/notifications/notification_service.dart';
// // import 'package:whatsapp/utils/app_color.dart';
// // import 'package:whatsapp/utils/function_lib.dart';

// // import 'package:whatsapp/view_models/approved_template_vm.dart';
// // import 'package:whatsapp/view_models/auto_response_vm.dart';
// // import 'package:whatsapp/view_models/call_view_model.dart';
// // import 'package:whatsapp/view_models/campaign_chart_vm.dart';
// // import 'package:whatsapp/view_models/campaign_count_vm.dart';
// // import 'package:whatsapp/view_models/campaign_vm.dart';
// // import 'package:whatsapp/view_models/chart_list_vm.dart';
// // import 'package:whatsapp/view_models/get_user_vm.dart';
// // import 'package:whatsapp/view_models/groups_view_model.dart';
// // import 'package:whatsapp/view_models/lead_controller.dart';
// // import 'package:whatsapp/view_models/lead_count_vm.dart';
// // import 'package:whatsapp/view_models/lead_list_vm.dart';
// // import 'package:whatsapp/view_models/message_controller.dart';
// // import 'package:whatsapp/view_models/message_history_vm.dart';
// // import 'package:whatsapp/view_models/message_list_vm.dart';
// // import 'package:whatsapp/view_models/tags_list_vm.dart';
// // import 'package:whatsapp/view_models/templete_list_vm.dart';
// // import 'package:whatsapp/view_models/unread_count_vm.dart';
// // import 'package:whatsapp/view_models/user_data_list_vm.dart';
// // import 'package:whatsapp/view_models/wallet_controller.dart';
// // import 'package:whatsapp/view_models/whatsapp_setting_vm.dart';

// // import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
// // import 'package:whatsapp/views/view/splash_view.dart';

// // import 'firebase_options.dart';

// // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// // final RouteObserver<ModalRoute<void>> routeObserver =
// //     RouteObserver<ModalRoute<void>>();

// // /// store deep link safely until app ready
// // Uri? pendingDeepLink;

// // @pragma('vm:entry-point')
// // Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// //   await Firebase.initializeApp();
// // }

// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();

// //   try {
// //     tz.initializeTimeZones();

// //     await Firebase.initializeApp(
// //       options: DefaultFirebaseOptions.currentPlatform,
// //     );

// //     FirebaseMessaging.onBackgroundMessage(
// //       firebaseMessagingBackgroundHandler,
// //     );

// //     await NotificationService.init();

// //     runApp(const MyApp());
// //     await NotificationService.handleInitialMessage();
// //   } catch (e) {
// //     debug("❌ Error in main(): $e");
// //     runApp(
// //       MaterialApp(
// //         home: Scaffold(
// //           body: Center(
// //             child: Text('App initialization failed: $e'),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class MyApp extends StatefulWidget {
// //   const MyApp({super.key});

// //   @override
// //   State<MyApp> createState() => _MyAppState();
// // }

// // class _MyAppState extends State<MyApp> {
// //   late final AppLinks _appLinks;
// //   StreamSubscription<Uri>? _linkSubscription;
// //   bool _isAppInitialized = false;

// //   @override
// //   void initState() {
// //     super.initState();

// //     try {
// //       debug("🚀 AppLinks initialized");
// //       _appLinks = AppLinks();
// //       _handleInitialUri();
// //       _listenToUriStream();

// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         if (mounted) {
// //           setState(() {
// //             _isAppInitialized = true;
// //           });
// //           _processPendingDeepLink();
// //         }
// //       });
// //     } catch (e) {
// //       debug("❌ Error in MyApp initState: $e");
// //     }
// //   }

// //   /// 🔹 App killed state
// //   Future<void> _handleInitialUri() async {
// //     try {
// //       final Uri? initialUri = await _appLinks.getInitialLink();
// //       debug("📌 Initial URI => $initialUri");

// //       if (initialUri != null) {
// //         pendingDeepLink = initialUri;
// //         _processPendingDeepLink();
// //       }
// //     } catch (e) {
// //       debug("❌ Initial URI error: $e");
// //     }
// //   }

// //   /// 🔹 Background / foreground
// //   void _listenToUriStream() {
// //     _linkSubscription = _appLinks.uriLinkStream.listen(
// //       (Uri uri) {
// //         debug("🔗 Stream URI => $uri");
// //         pendingDeepLink = uri;
// //         _processPendingDeepLink();
// //       },
// //       onError: (err) {
// //         debug("❌ URI Stream error: $err");
// //       },
// //     );
// //   }

// //   /// 🔹 Process pending deep link
// //   void _processPendingDeepLink() {
// //     if (!_isAppInitialized || pendingDeepLink == null) return;

// //     _processDeepLink();
// //   }

// //   /// 🔹 Process deep link - URL से phone number निकालकर chat खोलें
// //   void _processDeepLink() async {
// //     try {
// //       if (pendingDeepLink == null) {
// //         debug("⚠️ No pending deep link to process");
// //         return;
// //       }

// //       final uri = pendingDeepLink!;
// //       final uriString = uri.toString();
// //       debug("➡️ Processing DeepLink: $uriString");

// //       // Extract phone number from URL
// //       final String leadPhone = _extractLeadPhoneFromUrl(uriString);

// //       if (leadPhone.isEmpty) {
// //         debug("❌ No phone number found in URL");
// //         return;
// //       }

// //       // Extract whatsapp setting number from URL
// //       final String whatsappSettingNumber =
// //           _extractWhatsappSettingNumberFromUrl(uriString);

// //       // Get user data from stored tokens
// //       final userData = await _getUserDataFromTokens();
// //       final String leadName = userData['leadName'] ?? leadPhone;

// //       debug("📱 Extracted from URL:");
// //       debug("   Lead Phone: $leadPhone");
// //       debug("   WhatsApp Setting Number: $whatsappSettingNumber");
// //       debug("   User Name: $leadName");

// //       // Navigate to chat screen
// //       _navigateToChatScreen(leadName, leadPhone, whatsappSettingNumber);
// //     } catch (e) {
// //       debug("❌ Error in _processDeepLink: $e");
// //     }
// //   }

// //   /// 🔹 Extract lead phone number from URL
// //   String _extractLeadPhoneFromUrl(String url) {
// //     try {
// //       debug("🔍 Extracting phone number from URL: $url");

// //       final RegExp phoneRegex = RegExp(r'/history/(\+?\d+)');
// //       final Match? match = phoneRegex.firstMatch(url);

// //       if (match != null && match.group(1) != null) {
// //         String phone = match.group(1)!;
// //         debug("✅ Found phone in URL path: $phone");
// //         return phone;
// //       }

// //       // Alternative pattern: just look for +91 followed by 10 digits
// //       final RegExp altRegex = RegExp(r'(\+91\d{10})');
// //       final Match? altMatch = altRegex.firstMatch(url);

// //       if (altMatch != null && altMatch.group(1) != null) {
// //         String phone = altMatch.group(1)!;
// //         debug("✅ Found phone with alt pattern: $phone");
// //         return phone;
// //       }

// //       // Last resort: extract any number that looks like Indian phone
// //       final RegExp lastRegex = RegExp(r'(\+?91?\d{10})');
// //       final Match? lastMatch = lastRegex.firstMatch(url);

// //       if (lastMatch != null && lastMatch.group(1) != null) {
// //         String phone = lastMatch.group(1)!;
// //         // Ensure it starts with +91
// //         if (!phone.startsWith('+91') && phone.length == 10) {
// //           phone = '+91$phone';
// //         }
// //         debug("✅ Found phone with last resort pattern: $phone");
// //         return phone;
// //       }

// //       debug("❌ No phone number found in URL");
// //       return "";
// //     } catch (e) {
// //       debug("❌ Error extracting phone from URL: $e");
// //       return "";
// //     }
// //   }

// //   /// 🔹 Extract whatsapp setting number from URL
// //   String _extractWhatsappSettingNumberFromUrl(String url) {
// //     try {
// //       debug("🔍 Extracting whatsapp setting number from URL");

// //       // Extract from query parameter: whatsapp_setting_number=918306524244
// //       final RegExp regex = RegExp(r'whatsapp_setting_number=(\+?\d+)');
// //       final Match? match = regex.firstMatch(url);

// //       if (match != null && match.group(1) != null) {
// //         String number = match.group(1)!;
// //         debug("✅ Found whatsapp setting number: $number");
// //         return number;
// //       }

// //       debug("⚠️ No whatsapp setting number found in URL");
// //       return "";
// //     } catch (e) {
// //       debug("❌ Error extracting whatsapp setting number: $e");
// //       return "";
// //     }
// //   }

// //   /// 🔹 Navigate to chat screen
// //   void _navigateToChatScreen(
// //       String leadName, String leadPhone, String whatsappSettingNumber) {
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       try {
// //         final context = navigatorKey.currentContext;
// //         if (context == null) {
// //           debug("❌ Context is null, retrying in 500ms...");
// //           // Retry after delay
// //           Future.delayed(const Duration(milliseconds: 500), () {
// //             _navigateToChatScreen(leadName, leadPhone, whatsappSettingNumber);
// //           });
// //           return;
// //         }

// //         // Check if already on chat screen with same number
// //         final currentRoute = ModalRoute.of(context);
// //         if (currentRoute?.settings.name?.contains('chat') == true) {
// //           debug("⚠️ Already on chat screen");
// //           pendingDeepLink = null;
// //           return;
// //         }

// //         debug("✅ Navigating to WhatsappChatScreen with:");
// //         debug("   Lead Name: $leadName");
// //         debug("   Lead Phone: $leadPhone");
// //         debug("   ID: $whatsappSettingNumber");

// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(
// //             builder: (_) => WhatsappChatScreen(
// //               leadName: leadName,
// //               wpnumber: leadPhone,
// //               id: whatsappSettingNumber,
// //               pinnedLeads: [], // Empty list for pinned leads
// //             ),
// //           ),
// //         );

// //         pendingDeepLink = null;
// //         debug("🎉 Navigation successful!");
// //       } catch (e) {
// //         debug("❌ Navigation error: $e");
// //       }
// //     });
// //   }

// //   /// 🔹 Get user data from stored tokens
// //   Future<Map<String, String>> _getUserDataFromTokens() async {
// //     final Map<String, String> userData = {
// //       'leadName': 'WatConnect User',
// //       'phone': ''
// //     };

// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final userKey = prefs.getString(SharedPrefsConstants.userKey);

// //       if (userKey != null && userKey.isNotEmpty) {
// //         try {
// //           debug("🔍 Parsing user data JSON");

// //           final Map<String, dynamic> jsonData = json.decode(userKey);

// //           // Check if it has authToken (JWT)
// //           if (jsonData['authToken'] != null) {
// //             final String authToken = jsonData['authToken'].toString();
// //             debug("🔐 AuthToken found, decoding JWT");

// //             final Map<String, dynamic>? decodedToken = _decodeJWT(authToken);
// //             if (decodedToken != null) {
// //               userData['leadName'] = decodedToken['username']?.toString() ??
// //                   decodedToken['email']?.toString().split('@').first ??
// //                   'WatConnect User';
// //               userData['phone'] = _extractPhoneFromJson(decodedToken);
// //             }
// //           } else {
// //             // Direct JSON structure
// //             userData['leadName'] = jsonData['username']?.toString() ??
// //                 jsonData['email']?.toString().split('@').first ??
// //                 'WatConnect User';
// //             userData['phone'] = _extractPhoneFromJson(jsonData);
// //           }
// //         } catch (e) {
// //           debug("⚠️ JSON parse failed: $e, trying string extraction");

// //           // String extraction fallback
// //           userData['leadName'] = _extractFromString(userKey, 'username') ??
// //               _extractFromString(userKey, 'email')?.split('@').first ??
// //               'WatConnect User';
// //           userData['phone'] = _extractPhoneFromString(userKey);
// //         }
// //       }

// //       debug(
// //           "👤 User Data - Name: ${userData['leadName']}, Phone: ${userData['phone']}");
// //       return userData;
// //     } catch (e) {
// //       debug("❌ Error getting user data: $e");
// //       return userData;
// //     }
// //   }

// //   /// 🔹 Decode JWT token
// //   Map<String, dynamic>? _decodeJWT(String token) {
// //     try {
// //       final parts = token.split('.');
// //       if (parts.length != 3) {
// //         debug("❌ Invalid JWT format");
// //         return null;
// //       }

// //       String payload = parts[1];
// //       while (payload.length % 4 != 0) {
// //         payload += '=';
// //       }

// //       final decoded = utf8.decode(base64Url.decode(payload));
// //       debug("🔓 Decoded JWT payload");
// //       return json.decode(decoded);
// //     } catch (e) {
// //       debug("❌ JWT decode failed: $e");
// //       return null;
// //     }
// //   }

// //   /// 🔹 Extract phone from JSON
// //   String _extractPhoneFromJson(Map<String, dynamic> json) {
// //     try {
// //       if (json['whatsapp_number'] != null) {
// //         String number = json['whatsapp_number'].toString();
// //         String countryCode = json['country_code']?.toString() ?? '+91';

// //         if (!number.startsWith('+')) {
// //           number = '$countryCode$number';
// //         }
// //         debug("✅ Extracted whatsapp_number from JSON: $number");
// //         return number;
// //       }

// //       // Fallback to other phone fields
// //       final phoneFields = ['phone', 'mobile', 'phoneNumber', 'contact'];
// //       for (var field in phoneFields) {
// //         if (json[field] != null) {
// //           debug("✅ Extracted $field from JSON: ${json[field]}");
// //           return json[field].toString();
// //         }
// //       }

// //       return '';
// //     } catch (e) {
// //       debug("❌ Error extracting phone from JSON: $e");
// //       return '';
// //     }
// //   }

// //   /// 🔹 Extract value from string
// //   String? _extractFromString(String data, String key) {
// //     try {
// //       final regex = RegExp('"$key":\\s*"([^"]+)"');
// //       final match = regex.firstMatch(data);
// //       return match?.group(1);
// //     } catch (e) {
// //       return null;
// //     }
// //   }

// //   /// 🔹 Extract phone from string
// //   String _extractPhoneFromString(String data) {
// //     try {
// //       // Try whatsapp_number first
// //       final whatsappRegex = RegExp(r'"whatsapp_number":\s*"([^"]+)"');
// //       final whatsappMatch = whatsappRegex.firstMatch(data);
// //       if (whatsappMatch != null && whatsappMatch.group(1) != null) {
// //         String number = whatsappMatch.group(1)!;

// //         // Try to get country code
// //         final countryRegex = RegExp(r'"country_code":\s*"([^"]+)"');
// //         final countryMatch = countryRegex.firstMatch(data);
// //         String countryCode = countryMatch?.group(1) ?? '+91';

// //         if (!number.startsWith('+')) {
// //           number = '$countryCode$number';
// //         }
// //         return number;
// //       }

// //       // Try other phone fields
// //       final phonePatterns = [
// //         r'"phone":\s*"([^"]+)"',
// //         r'"mobile":\s*"([^"]+)"',
// //         r'"phoneNumber":\s*"([^"]+)"'
// //       ];

// //       for (var pattern in phonePatterns) {
// //         final regex = RegExp(pattern);
// //         final match = regex.firstMatch(data);
// //         if (match != null && match.group(1) != null) {
// //           return match.group(1)!;
// //         }
// //       }

// //       return '';
// //     } catch (e) {
// //       debug("❌ Error extracting phone from string: $e");
// //       return '';
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _linkSubscription?.cancel();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _processPendingDeepLink();
// //     });

// //     SystemChrome.setSystemUIOverlayStyle(
// //       const SystemUiOverlayStyle(
// //         statusBarColor: Colors.transparent,
// //         statusBarIconBrightness: Brightness.dark,
// //         statusBarBrightness: Brightness.light,
// //       ),
// //     );

// //     SystemChrome.setPreferredOrientations([
// //       DeviceOrientation.portraitUp,
// //       DeviceOrientation.portraitDown,
// //     ]);

// //     return MultiProvider(
// //       providers: [
// //         ChangeNotifierProvider(
// //             create: (_) => ApprovedTemplateViewModel(context)),
// //         ChangeNotifierProvider(create: (_) => UnreadCountVm(context)),
// //         ChangeNotifierProvider(create: (_) => GroupsViewModel(context)),
// //         ChangeNotifierProvider(create: (_) => MessageViewModel(context)),
// //         ChangeNotifierProvider(create: (_) => CampaignChartViewModel(context)),
// //         ChangeNotifierProvider(create: (_) => LeadListViewModel(context)),
// //         ChangeNotifierProvider(create: (_) => TagsListViewModel(context)),
// //         ChangeNotifierProvider(create: (_) => CampaignViewModel(context)),
// //         ChangeNotifierProvider(create: (_) => MeesageHistoryViewModel(context)),
// //         ChangeNotifierProvider(create: (_) => LeadCountViewModel(context)),
// //         ChangeNotifierProvider(create: (_) => TempleteListViewModel(context)),
// //         ChangeNotifierProvider(create: (_) => AutoResponseViewModel(context)),
// //         ChangeNotifierProvider(
// //             create: (_) => WhatsappSettingViewModel(context)),
// //         ChangeNotifierProvider(create: (_) => CampaignCountViewModel(context)),
// //         ChangeNotifierProvider(create: (_) => ChartListViewModel(context)),
// //         ChangeNotifierProvider(create: (_) => GetUserViewModel(context)),
// //         ChangeNotifierProvider(create: (_) => UserDataListViewModel(context)),
// //         ChangeNotifierProvider(create: (_) => MessageController()),
// //         ChangeNotifierProvider(create: (_) => DashBoardController()),
// //         ChangeNotifierProvider(create: (_) => TemplateController()),
// //         ChangeNotifierProvider(create: (_) => BusinessNumberController()),
// //         ChangeNotifierProvider(create: (_) => CallsViewModel(context)),
// //         ChangeNotifierProvider(create: (_) => ChatMessageController()),
// //         ChangeNotifierProvider(create: (_) => SfcampaignController()),
// //         ChangeNotifierProvider(create: (_) => WalletController()),
// //         ChangeNotifierProvider(create: (_) => LeadController()),
// //         ChangeNotifierProvider(create: (_) => SfFileUploadController()),
// //       ],
// //       child: Builder(
// //         builder: (context) {
// //           return MaterialApp(
// //             debugShowCheckedModeBanner: false,
// //             navigatorKey: navigatorKey,
// //             navigatorObservers: [routeObserver],
// //             title: 'WatConnect',
// //             theme: ThemeData(
// //               textTheme: GoogleFonts.kohSantepheapTextTheme(),
// //               primaryColor: AppColor.navBarIconColor,
// //               appBarTheme: const AppBarTheme(
// //                 backgroundColor: AppColor.navBarIconColor,
// //               ),
// //             ),
// //             builder: EasyLoading.init(),
// //             home: const SplashView(),
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }


// import 'dart:convert';
// import 'dart:async';
// import 'dart:core';

// import 'package:app_links/app_links.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:whatsapp/models/lead_model.dart';
// import 'package:whatsapp/utils/app_constants.dart';

// // Controllers & VMs
// import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
// import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
// import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
// import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
// import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
// import 'package:whatsapp/salesforce/controller/template_controller.dart';

// import 'package:whatsapp/services/notifications/notification_service.dart';
// import 'package:whatsapp/utils/app_color.dart';
// import 'package:whatsapp/utils/function_lib.dart';

// import 'package:whatsapp/view_models/approved_template_vm.dart';
// import 'package:whatsapp/view_models/auto_response_vm.dart';
// import 'package:whatsapp/view_models/call_view_model.dart';
// import 'package:whatsapp/view_models/campaign_chart_vm.dart';
// import 'package:whatsapp/view_models/campaign_count_vm.dart';
// import 'package:whatsapp/view_models/campaign_vm.dart';
// import 'package:whatsapp/view_models/chart_list_vm.dart';
// import 'package:whatsapp/view_models/get_user_vm.dart';
// import 'package:whatsapp/view_models/groups_view_model.dart';
// import 'package:whatsapp/view_models/lead_controller.dart';
// import 'package:whatsapp/view_models/lead_count_vm.dart';
// import 'package:whatsapp/view_models/lead_list_vm.dart';
// import 'package:whatsapp/view_models/message_controller.dart';
// import 'package:whatsapp/view_models/message_history_vm.dart';
// import 'package:whatsapp/view_models/message_list_vm.dart';
// import 'package:whatsapp/view_models/tags_list_vm.dart';
// import 'package:whatsapp/view_models/templete_list_vm.dart';
// import 'package:whatsapp/view_models/unread_count_vm.dart';
// import 'package:whatsapp/view_models/user_data_list_vm.dart';
// import 'package:whatsapp/view_models/wallet_controller.dart';
// import 'package:whatsapp/view_models/whatsapp_setting_vm.dart';

// import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
// import 'package:whatsapp/views/view/splash_view.dart';

// import 'firebase_options.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// final RouteObserver<ModalRoute<void>> routeObserver =
//     RouteObserver<ModalRoute<void>>();

// /// store deep link safely until app ready
// Uri? pendingDeepLink;

// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   try {
//     tz.initializeTimeZones();

//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );

//     FirebaseMessaging.onBackgroundMessage(
//       firebaseMessagingBackgroundHandler,
//     );

//     await NotificationService.init();

//     runApp(const MyApp());
//     await NotificationService.handleInitialMessage();
//   } catch (e) {
//     debug("❌ Error in main(): $e");
//     runApp(
//       MaterialApp(
//         home: Scaffold(
//           body: Center(
//             child: Text('App initialization failed: $e'),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   late final AppLinks _appLinks;
//   StreamSubscription<Uri>? _linkSubscription;
//   bool _isAppInitialized = false;

//   @override
//   void initState() {
//     super.initState();

//     try {
//       debug("🚀 AppLinks initialized");
//       _appLinks = AppLinks();
//       _handleInitialUri();
//       _listenToUriStream();

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           setState(() {
//             _isAppInitialized = true;
//           });
//           _processPendingDeepLink();
//         }
//       });
//     } catch (e) {
//       debug("❌ Error in MyApp initState: $e");
//     }
//   }

//   /// 🔹 App killed state
//   Future<void> _handleInitialUri() async {
//     try {
//       final Uri? initialUri = await _appLinks.getInitialLink();
//       debug("📌 Initial URI => $initialUri");

//       if (initialUri != null) {
//         pendingDeepLink = initialUri;
//         _processPendingDeepLink();
//       }
//     } catch (e) {
//       debug("❌ Initial URI error: $e");
//     }
//   }

//   /// 🔹 Background / foreground
//   void _listenToUriStream() {
//     _linkSubscription = _appLinks.uriLinkStream.listen(
//       (Uri uri) {
//         debug("🔗 Stream URI => $uri");
//         pendingDeepLink = uri;
//         _processPendingDeepLink();
//       },
//       onError: (err) {
//         debug("❌ URI Stream error: $err");
//       },
//     );
//   }

//   /// 🔹 Process pending deep link
//   void _processPendingDeepLink() {
//     if (!_isAppInitialized || pendingDeepLink == null) return;

//     _processDeepLink();
//   }

//   void _processDeepLink() async {
//     try {
//       if (pendingDeepLink == null) {
//         debug("⚠️ No pending deep link to process");
//         return;
//       }

//       final uri = pendingDeepLink!;
//       final uriString = uri.toString();
//       debug("➡️ Processing DeepLink: $uriString");

//       final String leadPhone = _extractLeadPhoneFromUrl(uriString);

//       if (leadPhone.isEmpty) {
//         debug("❌ No phone number found in URL");
//         return;
//       }

//       // Extract whatsapp setting number from URL
//       final String whatsappSettingNumber =
//           _extractWhatsappSettingNumberFromUrl(uriString);

//       debug("📱 Extracted from URL:");
//       debug("   Lead Phone: $leadPhone");
//       debug("   WhatsApp Setting Number: $whatsappSettingNumber");

//       // Find matching lead from LeadListViewModel
//       await _findAndNavigateToLead(leadPhone, whatsappSettingNumber);
//     } catch (e) {
//       debug("❌ Error in _processDeepLink: $e");
//     }
//   }

//   /// 🔹 Extract lead phone number from URL
//   String _extractLeadPhoneFromUrl(String url) {
//     try {
//       debug("🔍 Extracting phone number from URL: $url");

//       final RegExp phoneRegex = RegExp(r'/history/(\+?\d+)');
//       final Match? match = phoneRegex.firstMatch(url);

//       if (match != null && match.group(1) != null) {
//         String phone = match.group(1)!;
//         debug("✅ Found phone in URL path: $phone");
//         return phone;
//       }

//       // Alternative pattern: just look for +91 followed by 10 digits
//       final RegExp altRegex = RegExp(r'(\+91\d{10})');
//       final Match? altMatch = altRegex.firstMatch(url);

//       if (altMatch != null && altMatch.group(1) != null) {
//         String phone = altMatch.group(1)!;
//         debug("✅ Found phone with alt pattern: $phone");
//         return phone;
//       }

//       // Last resort: extract any number that looks like Indian phone
//       final RegExp lastRegex = RegExp(r'(\+?91?\d{10})');
//       final Match? lastMatch = lastRegex.firstMatch(url);

//       if (lastMatch != null && lastMatch.group(1) != null) {
//         String phone = lastMatch.group(1)!;
//         // Ensure it starts with +91
//         if (!phone.startsWith('+91') && phone.length == 10) {
//           phone = '+91$phone';
//         }
//         debug("✅ Found phone with last resort pattern: $phone");
//         return phone;
//       }

//       debug("❌ No phone number found in URL");
//       return "";
//     } catch (e) {
//       debug("❌ Error extracting phone from URL: $e");
//       return "";
//     }
//   }

//   /// 🔹 Extract whatsapp setting number from URL
//   String _extractWhatsappSettingNumberFromUrl(String url) {
//     try {
//       debug("🔍 Extracting whatsapp setting number from URL");

//       // Extract from query parameter: whatsapp_setting_number=918306524244
//       final RegExp regex = RegExp(r'whatsapp_setting_number=(\+?\d+)');
//       final Match? match = regex.firstMatch(url);

//       if (match != null && match.group(1) != null) {
//         String number = match.group(1)!;
//         debug("✅ Found whatsapp setting number: $number");
//         return number;
//       }

//       debug("⚠️ No whatsapp setting number found in URL");
//       return "";
//     } catch (e) {
//       debug("❌ Error extracting whatsapp setting number: $e");
//       return "";
//     }
//   }

//   /// 🔹 Find lead from LeadListViewModel and navigate
//   Future<void> _findAndNavigateToLead(
//       String leadPhone, String whatsappSettingNumber) async {
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       try {
//         final context = navigatorKey.currentContext;
//         if (context == null) {
//           debug("❌ Context is null, retrying in 500ms...");
//           Future.delayed(const Duration(milliseconds: 500), () {
//             _findAndNavigateToLead(leadPhone, whatsappSettingNumber);
//           });
//           return;
//         }

//         // Get LeadListViewModel
//         final leadListVm = Provider.of<LeadListViewModel>(context, listen: false);
        
//         // Fetch leads if not already fetched
//         if (leadListVm.viewModels.isEmpty) {
//           await leadListVm.fetch();
//           await Future.delayed(const Duration(milliseconds: 300));
//         }

//         LeadModel? matchedModel;
//         final List<LeadModel> pinnedLeads = [];

//         debug("🔍 Searching for lead with phone: $leadPhone");

//         for (var viewModel in leadListVm.viewModels) {
//           final leadmodel = viewModel.model;

//           if (leadmodel?.records != null) {
//             for (var record in leadmodel!.records!) {
//               debug("Checking lead: ${record.full_number}");

//               // Add pinned leads
//               if (record.pinned == true) {
//                 pinnedLeads.add(record);
//               }

//               // Match lead by phone number
//               if (record.full_number != null) {
//                 // Clean phone numbers for comparison
//                 String recordPhone = record.full_number!.trim();
//                 String searchPhone = leadPhone.trim();

//                 // Remove +91 if present for comparison
//                 if (recordPhone.startsWith('+91')) {
//                   recordPhone = recordPhone.substring(3);
//                 }
//                 if (searchPhone.startsWith('+91')) {
//                   searchPhone = searchPhone.substring(3);
//                 }

//                 // Also try with +91 prefix
//                 String recordPhoneWithPrefix = '+91$recordPhone';
//                 String searchPhoneWithPrefix = '+91$searchPhone';

//                 if (record.full_number == leadPhone ||
//                     record.full_number == searchPhoneWithPrefix ||
//                     recordPhone == searchPhone ||
//                     recordPhoneWithPrefix == leadPhone) {
//                   matchedModel = record;
//                   debug("✅ Found matching lead: ${record.contactname} - ${record.full_number}");
//                   break;
//                 }
//               }
//             }
//           }

//           if (matchedModel != null) break;
//         }

//         if (matchedModel == null) {
//           debug("❌ No matching lead found for phone: $leadPhone");
//           // Create a dummy lead with the phone number
//           matchedModel = LeadModel(
//             id: whatsappSettingNumber,
//             contactname: leadPhone,
//             full_number: leadPhone,
//             pinned: false,
//             // is_archived: false,
//           );
//           debug("⚠️ Using dummy lead with phone number");
//         }

//         // Navigate to chat screen
//         _navigateToChatScreen(matchedModel, pinnedLeads, whatsappSettingNumber);
//       } catch (e) {
//         debug("❌ Error finding lead: $e");
//       }
//     });
//   }

//   /// 🔹 Navigate to chat screen
//   void _navigateToChatScreen(
//       LeadModel matchedModel, List<LeadModel> pinnedLeads, String whatsappSettingNumber) {
//     try {
//       final context = navigatorKey.currentContext;
//       if (context == null) {
//         debug("❌ Context is null for navigation");
//         return;
//       }

//       // Check if already on chat screen with same number
//       final currentRoute = ModalRoute.of(context);
//       if (currentRoute?.settings.name?.contains('chat') == true) {
//         debug("⚠️ Already on chat screen");
//         pendingDeepLink = null;
//         return;
//       }

//       debug("✅ Navigating to WhatsappChatScreen with:");
//       debug("   Lead Name: ${matchedModel.contactname}");
//       debug("   Lead Phone: ${matchedModel.full_number}");
//       debug("   ID: ${matchedModel.id}");
//       debug("   Pinned Leads: ${pinnedLeads.length}");

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => WhatsappChatScreen(
//             leadName: matchedModel.contactname ?? matchedModel.full_number ?? "Unknown",
//             wpnumber: matchedModel.full_number ?? "",
//             id: matchedModel.id ?? whatsappSettingNumber,
//             model: matchedModel,
//             pinnedLeads: pinnedLeads,
//             // isArch: matchedModel.is_archived ?? false,
//           ),
//         ),
//       );

//       pendingDeepLink = null;
//       debug("🎉 Navigation successful!");
//     } catch (e) {
//       debug("❌ Navigation error: $e");
//     }
//   }

//   @override
//   void dispose() {
//     _linkSubscription?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _processPendingDeepLink();
//     });

//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.dark,
//         statusBarBrightness: Brightness.light,
//       ),
//     );

//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);

//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//             create: (_) => ApprovedTemplateViewModel(context)),
//         ChangeNotifierProvider(create: (_) => UnreadCountVm(context)),
//         ChangeNotifierProvider(create: (_) => GroupsViewModel(context)),
//         ChangeNotifierProvider(create: (_) => MessageViewModel(context)),
//         ChangeNotifierProvider(create: (_) => CampaignChartViewModel(context)),
//         ChangeNotifierProvider(create: (_) => LeadListViewModel(context)),
//         ChangeNotifierProvider(create: (_) => TagsListViewModel(context)),
//         ChangeNotifierProvider(create: (_) => CampaignViewModel(context)),
//         ChangeNotifierProvider(create: (_) => MeesageHistoryViewModel(context)),
//         ChangeNotifierProvider(create: (_) => LeadCountViewModel(context)),
//         ChangeNotifierProvider(create: (_) => TempleteListViewModel(context)),
//         ChangeNotifierProvider(create: (_) => AutoResponseViewModel(context)),
//         ChangeNotifierProvider(
//             create: (_) => WhatsappSettingViewModel(context)),
//         ChangeNotifierProvider(create: (_) => CampaignCountViewModel(context)),
//         ChangeNotifierProvider(create: (_) => ChartListViewModel(context)),
//         ChangeNotifierProvider(create: (_) => GetUserViewModel(context)),
//         ChangeNotifierProvider(create: (_) => UserDataListViewModel(context)),
//         ChangeNotifierProvider(create: (_) => MessageController()),
//         ChangeNotifierProvider(create: (_) => DashBoardController()),
//         ChangeNotifierProvider(create: (_) => TemplateController()),
//         ChangeNotifierProvider(create: (_) => BusinessNumberController()),
//         ChangeNotifierProvider(create: (_) => CallsViewModel(context)),
//         ChangeNotifierProvider(create: (_) => ChatMessageController()),
//         ChangeNotifierProvider(create: (_) => SfcampaignController()),
//         ChangeNotifierProvider(create: (_) => WalletController()),
//         ChangeNotifierProvider(create: (_) => LeadController()),
//         ChangeNotifierProvider(create: (_) => SfFileUploadController()),
//       ],
//       child: Builder(
//         builder: (context) {
//           return MaterialApp(
//             debugShowCheckedModeBanner: false,
//             navigatorKey: navigatorKey,
//             navigatorObservers: [routeObserver],
//             title: 'WatConnect',
//             theme: ThemeData(
//               textTheme: GoogleFonts.kohSantepheapTextTheme(),
//               primaryColor: AppColor.navBarIconColor,
//               appBarTheme: const AppBarTheme(
//                 backgroundColor: AppColor.navBarIconColor,
//               ),
//             ),
//             builder: EasyLoading.init(),
//             home: const SplashView(),
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:async';
import 'dart:core';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:whatsapp/models/lead_model.dart';
import 'package:whatsapp/utils/app_constants.dart';

// Controllers & VMs
import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
import 'package:whatsapp/salesforce/controller/template_controller.dart';

import 'package:whatsapp/services/notifications/notification_service.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/function_lib.dart';

import 'package:whatsapp/view_models/approved_template_vm.dart';
import 'package:whatsapp/view_models/auto_response_vm.dart';
import 'package:whatsapp/view_models/call_view_model.dart';
import 'package:whatsapp/view_models/campaign_chart_vm.dart';
import 'package:whatsapp/view_models/campaign_count_vm.dart';
import 'package:whatsapp/view_models/campaign_vm.dart';
import 'package:whatsapp/view_models/chart_list_vm.dart';
import 'package:whatsapp/view_models/get_user_vm.dart';
import 'package:whatsapp/view_models/groups_view_model.dart';
import 'package:whatsapp/view_models/lead_controller.dart';
import 'package:whatsapp/view_models/lead_count_vm.dart';
import 'package:whatsapp/view_models/lead_list_vm.dart';
import 'package:whatsapp/view_models/message_controller.dart';
import 'package:whatsapp/view_models/message_history_vm.dart';
import 'package:whatsapp/view_models/message_list_vm.dart';
import 'package:whatsapp/view_models/tags_list_vm.dart';
import 'package:whatsapp/view_models/templete_list_vm.dart';
import 'package:whatsapp/view_models/unread_count_vm.dart';
import 'package:whatsapp/view_models/user_data_list_vm.dart';
import 'package:whatsapp/view_models/wallet_controller.dart';
import 'package:whatsapp/view_models/whatsapp_setting_vm.dart';

import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
import 'package:whatsapp/views/view/splash_view.dart';

import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

/// store deep link safely until app ready
Uri? pendingDeepLink;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    tz.initializeTimeZones();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    await NotificationService.init();

    runApp(const MyApp());
    await NotificationService.handleInitialMessage();
  } catch (e) {
    debug("❌ Error in main(): $e");
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('App initialization failed: $e'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  bool _isAppInitialized = false;

  @override
  void initState() {
    super.initState();

    try {
      debug("🚀 AppLinks initialized");
      _appLinks = AppLinks();
      _handleInitialUri();
      _listenToUriStream();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isAppInitialized = true;
          });
          _processPendingDeepLink();
        }
      });
    } catch (e) {
      debug("❌ Error in MyApp initState: $e");
    }
  }

  /// 🔹 App killed state
  Future<void> _handleInitialUri() async {
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      debug("📌 Initial URI => $initialUri");

      if (initialUri != null) {
        pendingDeepLink = initialUri;
        _processPendingDeepLink();
      }
    } catch (e) {
      debug("❌ Initial URI error: $e");
    }
  }

  /// 🔹 Background / foreground
  void _listenToUriStream() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        debug("🔗 Stream URI => $uri");
        pendingDeepLink = uri;
        _processPendingDeepLink();
      },
      onError: (err) {
        debug("❌ URI Stream error: $err");
      },
    );
  }

  /// 🔹 Process pending deep link
  void _processPendingDeepLink() {
    if (!_isAppInitialized || pendingDeepLink == null) return;

    _processDeepLink();
  }

  void _processDeepLink() async {
    try {
      if (pendingDeepLink == null) {
        debug("⚠️ No pending deep link to process");
        return;
      }

      final uri = pendingDeepLink!;
      final uriString = uri.toString();
      debug("➡️ Processing DeepLink: $uriString");

      // Extract phone number from new URL pattern: /chat/917740989118
      final String leadPhone = _extractLeadPhoneFromUrl(uriString);

      if (leadPhone.isEmpty) {
        debug("❌ No phone number found in URL");
        return;
      }

      debug("📱 Extracted from URL:");
      debug("   Lead Phone: $leadPhone");

      // Find matching lead from LeadListViewModel
      await _findAndNavigateToLead(leadPhone);
    } catch (e) {
      debug("❌ Error in _processDeepLink: $e");
    }
  }

  /// 🔹 Extract lead phone number from URL - NEW PATTERN: /chat/917740989118
  String _extractLeadPhoneFromUrl(String url) {
    try {
      debug("🔍 Extracting phone number from URL: $url");

      // NEW PATTERN: /chat/917740989118
      final RegExp phoneRegex = RegExp(r'/chat/(\+?\d+)');
      final Match? match = phoneRegex.firstMatch(url);

      if (match != null && match.group(1) != null) {
        String phone = match.group(1)!;
        
        // Ensure it has +91 prefix if not already
        if (!phone.startsWith('+') && phone.length == 10) {
          phone = '+91$phone';
        } else if (!phone.startsWith('+91') && phone.startsWith('91') && phone.length == 12) {
          phone = '+$phone';
        }
        
        debug("✅ Found phone in URL path: $phone");
        return phone;
      }

      // Also try alternative pattern
      final RegExp altRegex = RegExp(r'chat/(\d{10,12})');
      final Match? altMatch = altRegex.firstMatch(url);

      if (altMatch != null && altMatch.group(1) != null) {
        String phone = altMatch.group(1)!;
        
        // Format the phone number
        if (phone.length == 10) {
          phone = '+91$phone';
        } else if (phone.length == 12 && phone.startsWith('91')) {
          phone = '+$phone';
        }
        
        debug("✅ Found phone with alt pattern: $phone");
        return phone;
      }

      debug("❌ No phone number found in URL");
      return "";
    } catch (e) {
      debug("❌ Error extracting phone from URL: $e");
      return "";
    }
  }

  /// 🔹 Find lead from LeadListViewModel and navigate
  Future<void> _findAndNavigateToLead(String leadPhone) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final context = navigatorKey.currentContext;
        if (context == null) {
          debug("❌ Context is null, retrying in 500ms...");
          Future.delayed(const Duration(milliseconds: 500), () {
            _findAndNavigateToLead(leadPhone);
          });
          return;
        }

        // Get LeadListViewModel
        final leadListVm = Provider.of<LeadListViewModel>(context, listen: false);
        
        // Fetch leads if not already fetched
        if (leadListVm.viewModels.isEmpty) {
          await leadListVm.fetch();
          await Future.delayed(const Duration(milliseconds: 300));
        }

        LeadModel? matchedModel;
        final List<LeadModel> pinnedLeads = [];

        debug("🔍 Searching for lead with phone: $leadPhone");

        for (var viewModel in leadListVm.viewModels) {
          final leadmodel = viewModel.model;

          if (leadmodel?.records != null) {
            for (var record in leadmodel!.records!) {
              debug("Checking lead: ${record.full_number}");

              // Add pinned leads
              if (record.pinned == true) {
                pinnedLeads.add(record);
              }

              // Match lead by phone number
              if (record.full_number != null) {
                // Clean phone numbers for comparison
                String recordPhone = record.full_number!.trim();
                String searchPhone = leadPhone.trim();

                // Remove +91 if present for comparison
                String recordPhoneWithoutPrefix = recordPhone;
                String searchPhoneWithoutPrefix = searchPhone;
                
                if (recordPhone.startsWith('+91')) {
                  recordPhoneWithoutPrefix = recordPhone.substring(3);
                }
                if (searchPhone.startsWith('+91')) {
                  searchPhoneWithoutPrefix = searchPhone.substring(3);
                }

                // Try multiple matching patterns
                bool isMatch = 
                    recordPhone == searchPhone ||
                    recordPhoneWithoutPrefix == searchPhoneWithoutPrefix ||
                    recordPhone == '+91$searchPhoneWithoutPrefix' ||
                    '+91$recordPhoneWithoutPrefix' == searchPhone ||
                    recordPhone == '91$searchPhoneWithoutPrefix' ||
                    '91$recordPhoneWithoutPrefix' == searchPhone;

                if (isMatch) {
                  matchedModel = record;
                  debug("✅ Found matching lead: ${record.contactname} - ${record.full_number}");
                  break;
                }
              }
            }
          }

          if (matchedModel != null) break;
        }

        if (matchedModel == null) {
          debug("❌ No matching lead found for phone: $leadPhone");
          // Create a dummy lead with the phone number
          matchedModel = LeadModel(
            id: leadPhone, // Use phone as ID
            contactname: leadPhone,
            full_number: leadPhone,
            pinned: false,
          );
          debug("⚠️ Using dummy lead with phone number");
        }

        // Navigate to chat screen
        _navigateToChatScreen(matchedModel, pinnedLeads);
      } catch (e) {
        debug("❌ Error finding lead: $e");
      }
    });
  }

  /// 🔹 Navigate to chat screen
  void _navigateToChatScreen(LeadModel matchedModel, List<LeadModel> pinnedLeads) {
    try {
      final context = navigatorKey.currentContext;
      if (context == null) {
        debug("❌ Context is null for navigation");
        return;
      }

      // Check if already on chat screen with same number
      final currentRoute = ModalRoute.of(context);
      if (currentRoute?.settings.name?.contains('chat') == true) {
        debug("⚠️ Already on chat screen");
        pendingDeepLink = null;
        return;
      }

      debug("✅ Navigating to WhatsappChatScreen with:");
      debug("   Lead Name: ${matchedModel.contactname}");
      debug("   Lead Phone: ${matchedModel.full_number}");
      debug("   ID: ${matchedModel.id}");
      debug("   Pinned Leads: ${pinnedLeads.length}");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WhatsappChatScreen(
            leadName: matchedModel.contactname ?? matchedModel.full_number ?? "Unknown",
            wpnumber: matchedModel.full_number ?? "",
            id: matchedModel.id ?? matchedModel.full_number ?? "",
            model: matchedModel,
            pinnedLeads: pinnedLeads,
          ),
        ),
      );

      pendingDeepLink = null;
      debug("🎉 Navigation successful!");
    } catch (e) {
      debug("❌ Navigation error: $e");
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processPendingDeepLink();
    });

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ApprovedTemplateViewModel(context)),
        ChangeNotifierProvider(create: (_) => UnreadCountVm(context)),
        ChangeNotifierProvider(create: (_) => GroupsViewModel(context)),
        ChangeNotifierProvider(create: (_) => MessageViewModel(context)),
        ChangeNotifierProvider(create: (_) => CampaignChartViewModel(context)),
        ChangeNotifierProvider(create: (_) => LeadListViewModel(context)),
        ChangeNotifierProvider(create: (_) => TagsListViewModel(context)),
        ChangeNotifierProvider(create: (_) => CampaignViewModel(context)),
        ChangeNotifierProvider(create: (_) => MeesageHistoryViewModel(context)),
        ChangeNotifierProvider(create: (_) => LeadCountViewModel(context)),
        ChangeNotifierProvider(create: (_) => TempleteListViewModel(context)),
        ChangeNotifierProvider(create: (_) => AutoResponseViewModel(context)),
        ChangeNotifierProvider(
            create: (_) => WhatsappSettingViewModel(context)),
        ChangeNotifierProvider(create: (_) => CampaignCountViewModel(context)),
        ChangeNotifierProvider(create: (_) => ChartListViewModel(context)),
        ChangeNotifierProvider(create: (_) => GetUserViewModel(context)),
        ChangeNotifierProvider(create: (_) => UserDataListViewModel(context)),
        ChangeNotifierProvider(create: (_) => MessageController()),
        ChangeNotifierProvider(create: (_) => DashBoardController()),
        ChangeNotifierProvider(create: (_) => TemplateController()),
        ChangeNotifierProvider(create: (_) => BusinessNumberController()),
        ChangeNotifierProvider(create: (_) => CallsViewModel(context)),
        ChangeNotifierProvider(create: (_) => ChatMessageController()),
        ChangeNotifierProvider(create: (_) => SfcampaignController()),
        ChangeNotifierProvider(create: (_) => WalletController()),
        ChangeNotifierProvider(create: (_) => LeadController()),
        ChangeNotifierProvider(create: (_) => SfFileUploadController()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            navigatorObservers: [routeObserver],
            title: 'WatConnect',
            theme: ThemeData(
              textTheme: GoogleFonts.kohSantepheapTextTheme(),
              primaryColor: AppColor.navBarIconColor,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColor.navBarIconColor,
              ),
            ),
            builder: EasyLoading.init(),
            home: const SplashView(),
          );
        },
      ),
    );
  }
}