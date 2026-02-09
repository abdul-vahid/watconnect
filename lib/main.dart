// // // // // // import 'dart:convert';
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
// // // // // // import 'package:whatsapp/models/lead_model.dart';
// // // // // // import 'package:whatsapp/utils/app_constants.dart';

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
// // // // // //   WidgetsFlutterBinding.ensureInitialized();

// // // // // //   try {
// // // // // //     tz.initializeTimeZones();

// // // // // //     await Firebase.initializeApp(
// // // // // //       options: DefaultFirebaseOptions.currentPlatform,
// // // // // //     );

// // // // // //     FirebaseMessaging.onBackgroundMessage(
// // // // // //       firebaseMessagingBackgroundHandler,
// // // // // //     );

// // // // // //     await NotificationService.init();

// // // // // //     runApp(const MyApp());
// // // // // //     await NotificationService.handleInitialMessage();
// // // // // //   } catch (e) {
// // // // // //     debug("  Error in main(): $e");
// // // // // //     runApp(
// // // // // //       MaterialApp(
// // // // // //         home: Scaffold(
// // // // // //           body: Center(
// // // // // //             child: Text('App initialization failed: $e'),
// // // // // //           ),
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
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

// // // // // //   @override
// // // // // //   void initState() {
// // // // // //     super.initState();

// // // // // //     try {
// // // // // //       debug("🚀 AppLinks initialized");
// // // // // //       _appLinks = AppLinks();
// // // // // //       _handleInitialUri();
// // // // // //       _listenToUriStream();

// // // // // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // //         if (mounted) {
// // // // // //           setState(() {
// // // // // //             _isAppInitialized = true;
// // // // // //           });
// // // // // //           _processPendingDeepLink();
// // // // // //         }
// // // // // //       });
// // // // // //     } catch (e) {
// // // // // //       debug("  Error in MyApp initState: $e");
// // // // // //     }
// // // // // //   }

// // // // // //   /// 🔹 App killed state
// // // // // //   Future<void> _handleInitialUri() async {
// // // // // //     try {
// // // // // //       final Uri? initialUri = await _appLinks.getInitialLink();
// // // // // //       debug("📌 Initial URI => $initialUri");

// // // // // //       if (initialUri != null) {
// // // // // //         pendingDeepLink = initialUri;
// // // // // //         _processPendingDeepLink();
// // // // // //       }
// // // // // //     } catch (e) {
// // // // // //       debug("  Initial URI error: $e");
// // // // // //     }
// // // // // //   }

// // // // // //   /// 🔹 Background / foreground
// // // // // //   void _listenToUriStream() {
// // // // // //     _linkSubscription = _appLinks.uriLinkStream.listen(
// // // // // //       (Uri uri) {
// // // // // //         debug("🔗 Stream URI => $uri");
// // // // // //         pendingDeepLink = uri;
// // // // // //         _processPendingDeepLink();
// // // // // //       },
// // // // // //       onError: (err) {
// // // // // //         debug("  URI Stream error: $err");
// // // // // //       },
// // // // // //     );
// // // // // //   }

// // // // // //   /// 🔹 Process pending deep link
// // // // // //   void _processPendingDeepLink() {
// // // // // //     if (!_isAppInitialized || pendingDeepLink == null) return;

// // // // // //     _processDeepLink();
// // // // // //   }

// // // // // //   void _processDeepLink() async {
// // // // // //     try {
// // // // // //       if (pendingDeepLink == null) {
// // // // // //         debug(" No pending deep link to process");
// // // // // //         return;
// // // // // //       }

// // // // // //       final uri = pendingDeepLink!;
// // // // // //       final uriString = uri.toString();
// // // // // //       debug("➡️ Processing DeepLink: $uriString");

// // // // // //       // Extract phone number from new URL pattern: /chat/917740989118
// // // // // //       final String leadPhone = _extractLeadPhoneFromUrl(uriString);

// // // // // //       if (leadPhone.isEmpty) {
// // // // // //         debug("  No phone number found in URL");
// // // // // //         return;
// // // // // //       }

// // // // // //       debug(" Extracted from URL:");
// // // // // //       debug("   Lead Phone: $leadPhone");

// // // // // //       // Find matching lead from LeadListViewModel
// // // // // //       await _findAndNavigateToLead(leadPhone);
// // // // // //     } catch (e) {
// // // // // //       debug("  Error in _processDeepLink: $e");
// // // // // //     }
// // // // // //   }

// // // // // //   /// 🔹 Extract lead phone number from URL - NEW PATTERN: /chat/917740989118
// // // // // //   String _extractLeadPhoneFromUrl(String url) {
// // // // // //     try {
// // // // // //       debug("  Extracting phone number from URL: $url");

// // // // // //       // NEW PATTERN: /chat/917740989118
// // // // // //       final RegExp phoneRegex = RegExp(r'/chat/(\+?\d+)');
// // // // // //       final Match? match = phoneRegex.firstMatch(url);

// // // // // //       if (match != null && match.group(1) != null) {
// // // // // //         String phone = match.group(1)!;

// // // // // //         // Ensure it has +91 prefix if not already
// // // // // //         if (!phone.startsWith('+') && phone.length == 10) {
// // // // // //           phone = '+91$phone';
// // // // // //         } else if (!phone.startsWith('+91') && phone.startsWith('91') && phone.length == 12) {
// // // // // //           phone = '+$phone';
// // // // // //         }

// // // // // //         debug("  Found phone in URL path: $phone");
// // // // // //         return phone;
// // // // // //       }

// // // // // //       // Also try alternative pattern
// // // // // //       final RegExp altRegex = RegExp(r'chat/(\d{10,12})');
// // // // // //       final Match? altMatch = altRegex.firstMatch(url);

// // // // // //       if (altMatch != null && altMatch.group(1) != null) {
// // // // // //         String phone = altMatch.group(1)!;

// // // // // //         // Format the phone number
// // // // // //         if (phone.length == 10) {
// // // // // //           phone = '+91$phone';
// // // // // //         } else if (phone.length == 12 && phone.startsWith('91')) {
// // // // // //           phone = '+$phone';
// // // // // //         }

// // // // // //         debug("  Found phone with alt pattern: $phone");
// // // // // //         return phone;
// // // // // //       }

// // // // // //       debug("  No phone number found in URL");
// // // // // //       return "";
// // // // // //     } catch (e) {
// // // // // //       debug("  Error extracting phone from URL: $e");
// // // // // //       return "";
// // // // // //     }
// // // // // //   }

// // // // // //   /// 🔹 Find lead from LeadListViewModel and navigate
// // // // // //   Future<void> _findAndNavigateToLead(String leadPhone) async {
// // // // // //     WidgetsBinding.instance.addPostFrameCallback((_) async {
// // // // // //       try {
// // // // // //         final context = navigatorKey.currentContext;
// // // // // //         if (context == null) {
// // // // // //           debug("  Context is null, retrying in 500ms...");
// // // // // //           Future.delayed(const Duration(milliseconds: 500), () {
// // // // // //             _findAndNavigateToLead(leadPhone);
// // // // // //           });
// // // // // //           return;
// // // // // //         }

// // // // // //         // Get LeadListViewModel
// // // // // //         final leadListVm = Provider.of<LeadListViewModel>(context, listen: false);

// // // // // //         // Fetch leads if not already fetched
// // // // // //         if (leadListVm.viewModels.isEmpty) {
// // // // // //           await leadListVm.fetch();
// // // // // //           await Future.delayed(const Duration(milliseconds: 300));
// // // // // //         }

// // // // // //         LeadModel? matchedModel;
// // // // // //         final List<LeadModel> pinnedLeads = [];

// // // // // //         debug("  Searching for lead with phone: $leadPhone");

// // // // // //         for (var viewModel in leadListVm.viewModels) {
// // // // // //           final leadmodel = viewModel.model;

// // // // // //           if (leadmodel?.records != null) {
// // // // // //             for (var record in leadmodel!.records!) {
// // // // // //               debug("Checking lead: ${record.full_number}");

// // // // // //               // Add pinned leads
// // // // // //               if (record.pinned == true) {
// // // // // //                 pinnedLeads.add(record);
// // // // // //               }

// // // // // //               // Match lead by phone number
// // // // // //               if (record.full_number != null) {
// // // // // //                 // Clean phone numbers for comparison
// // // // // //                 String recordPhone = record.full_number!.trim();
// // // // // //                 String searchPhone = leadPhone.trim();

// // // // // //                 // Remove +91 if present for comparison
// // // // // //                 String recordPhoneWithoutPrefix = recordPhone;
// // // // // //                 String searchPhoneWithoutPrefix = searchPhone;

// // // // // //                 if (recordPhone.startsWith('+91')) {
// // // // // //                   recordPhoneWithoutPrefix = recordPhone.substring(3);
// // // // // //                 }
// // // // // //                 if (searchPhone.startsWith('+91')) {
// // // // // //                   searchPhoneWithoutPrefix = searchPhone.substring(3);
// // // // // //                 }

// // // // // //                 // Try multiple matching patterns
// // // // // //                 bool isMatch =
// // // // // //                     recordPhone == searchPhone ||
// // // // // //                     recordPhoneWithoutPrefix == searchPhoneWithoutPrefix ||
// // // // // //                     recordPhone == '+91$searchPhoneWithoutPrefix' ||
// // // // // //                     '+91$recordPhoneWithoutPrefix' == searchPhone ||
// // // // // //                     recordPhone == '91$searchPhoneWithoutPrefix' ||
// // // // // //                     '91$recordPhoneWithoutPrefix' == searchPhone;

// // // // // //                 if (isMatch) {
// // // // // //                   matchedModel = record;
// // // // // //                   debug("  Found matching lead: ${record.contactname} - ${record.full_number}");
// // // // // //                   break;
// // // // // //                 }
// // // // // //               }
// // // // // //             }
// // // // // //           }

// // // // // //           if (matchedModel != null) break;
// // // // // //         }

// // // // // //         if (matchedModel == null) {
// // // // // //           debug("  No matching lead found for phone: $leadPhone");
// // // // // //           // Create a dummy lead with the phone number
// // // // // //           matchedModel = LeadModel(
// // // // // //             id: leadPhone, // Use phone as ID
// // // // // //             contactname: leadPhone,
// // // // // //             full_number: leadPhone,
// // // // // //             pinned: false,
// // // // // //           );
// // // // // //           debug(" Using dummy lead with phone number");
// // // // // //         }

// // // // // //         // Navigate to chat screen
// // // // // //         _navigateToChatScreen(matchedModel, pinnedLeads);
// // // // // //       } catch (e) {
// // // // // //         debug("  Error finding lead: $e");
// // // // // //       }
// // // // // //     });
// // // // // //   }

// // // // // //   /// 🔹 Navigate to chat screen
// // // // // //   void _navigateToChatScreen(LeadModel matchedModel, List<LeadModel> pinnedLeads) {
// // // // // //     try {
// // // // // //       final context = navigatorKey.currentContext;
// // // // // //       if (context == null) {
// // // // // //         debug("  Context is null for navigation");
// // // // // //         return;
// // // // // //       }

// // // // // //       final currentRoute = ModalRoute.of(context);
// // // // // //       if (currentRoute?.settings.name?.contains('chat') == true) {
// // // // // //         debug(" Already on chat screen");
// // // // // //         pendingDeepLink = null;
// // // // // //         return;
// // // // // //       }

// // // // // //       debug("  Navigating to WhatsappChatScreen with:");
// // // // // //       debug("   Lead Name: ${matchedModel.contactname}");
// // // // // //       debug("   Lead Phone: ${matchedModel.full_number}");
// // // // // //       debug("   ID: ${matchedModel.id}");
// // // // // //       debug("   Pinned Leads: ${pinnedLeads.length}");

// // // // // //       Navigator.push(
// // // // // //         context,
// // // // // //         MaterialPageRoute(
// // // // // //           builder: (_) => WhatsappChatScreen(
// // // // // //             leadName: matchedModel.contactname ?? matchedModel.full_number ?? "Unknown",
// // // // // //             wpnumber: matchedModel.full_number ?? "",
// // // // // //             id: matchedModel.id ?? matchedModel.full_number ?? "",
// // // // // //             model: matchedModel,
// // // // // //             pinnedLeads: pinnedLeads,
// // // // // //           ),
// // // // // //         ),
// // // // // //       );

// // // // // //       pendingDeepLink = null;
// // // // // //       debug("🎉 Navigation successful!");
// // // // // //     } catch (e) {
// // // // // //       debug("  Navigation error: $e");
// // // // // //     }
// // // // // //   }

// // // // // //   @override
// // // // // //   void dispose() {
// // // // // //     _linkSubscription?.cancel();
// // // // // //     super.dispose();
// // // // // //   }

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // //       _processPendingDeepLink();
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
// // // // // //       child: Builder(
// // // // // //         builder: (context) {
// // // // // //           return MaterialApp(
// // // // // //             debugShowCheckedModeBanner: false,
// // // // // //             navigatorKey: navigatorKey,
// // // // // //             navigatorObservers: [routeObserver],
// // // // // //             title: 'WatConnect',
// // // // // //             theme: ThemeData(
// // // // // //               textTheme: GoogleFonts.kohSantepheapTextTheme(),
// // // // // //               primaryColor: AppColor.navBarIconColor,
// // // // // //               appBarTheme: const AppBarTheme(
// // // // // //                 backgroundColor: AppColor.navBarIconColor,
// // // // // //               ),
// // // // // //             ),
// // // // // //             builder: EasyLoading.init(),
// // // // // //             home: const SplashView(),
// // // // // //           );
// // // // // //         },
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // import 'dart:convert';
// // // // // import 'dart:async';
// // // // // import 'dart:core';

// // // // // import 'package:app_links/app_links.dart';
// // // // // import 'package:firebase_core/firebase_core.dart';
// // // // // import 'package:firebase_messaging/firebase_messaging.dart';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:flutter/services.dart';
// // // // // import 'package:flutter_easyloading/flutter_easyloading.dart';
// // // // // // import 'package:get/get.dart';
// // // // // import 'package:google_fonts/google_fonts.dart';
// // // // // import 'package:provider/provider.dart';
// // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // // import 'package:timezone/data/latest.dart' as tz;
// // // // // import 'package:whatsapp/models/lead_model.dart';
// // // // // import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
// // // // // import 'package:whatsapp/salesforce/screens/sf_message_chat_screen.dart';
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
// // // // // // Import your Salesforce chat screen
// // // // // // import 'package:whatsapp/views/view/salesforce_chat_screen.dart';
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
// // // // //     debug("  Error in main(): $e");
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

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();

// // // // //     try {
// // // // //       debug("🚀 AppLinks initialized");
// // // // //       _appLinks = AppLinks();
// // // // //       _handleInitialUri();
// // // // //       _listenToUriStream();

// // // // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // //         if (mounted) {
// // // // //           setState(() {
// // // // //             _isAppInitialized = true;
// // // // //           });
// // // // //           _processPendingDeepLink();
// // // // //         }
// // // // //       });
// // // // //     } catch (e) {
// // // // //       debug("  Error in MyApp initState: $e");
// // // // //     }
// // // // //   }

// // // // //   /// 🔹 App killed state
// // // // //   Future<void> _handleInitialUri() async {
// // // // //     try {
// // // // //       final Uri? initialUri = await _appLinks.getInitialLink();
// // // // //       debug("📌 Initial URI => $initialUri");

// // // // //       if (initialUri != null) {
// // // // //         pendingDeepLink = initialUri;
// // // // //         _processPendingDeepLink();
// // // // //       }
// // // // //     } catch (e) {
// // // // //       debug("  Initial URI error: $e");
// // // // //     }
// // // // //   }

// // // // //   void _listenToUriStream() {
// // // // //     _linkSubscription = _appLinks.uriLinkStream.listen(
// // // // //       (Uri uri) {
// // // // //         debug("🔗 Stream URI => $uri");
// // // // //         pendingDeepLink = uri;
// // // // //         _processPendingDeepLink();
// // // // //       },
// // // // //       onError: (err) {
// // // // //         debug("  URI Stream error: $err");
// // // // //       },
// // // // //     );
// // // // //   }

// // // // //   /// 🔹 Process pending deep link
// // // // //   void _processPendingDeepLink() {
// // // // //     if (!_isAppInitialized || pendingDeepLink == null) return;

// // // // //     _processDeepLink();
// // // // //   }

// // // // //   void _processDeepLink() async {
// // // // //     try {
// // // // //       if (pendingDeepLink == null) {
// // // // //         debug(" No pending deep link to process");
// // // // //         return;
// // // // //       }

// // // // //       final uri = pendingDeepLink!;
// // // // //       final uriString = uri.toString();
// // // // //       debug("➡️ Processing DeepLink: $uriString");

// // // // //       final Map<String, String> extractedData = _extractDataFromUrl(uriString);

// // // // //       final String? leadPhone = extractedData['phone'];
// // // // //       final String? objectType = extractedData['objectType'];
// // // // //       if (leadPhone == null || leadPhone.isEmpty) {
// // // // //         debug("  No phone number found in URL");
// // // // //         return;
// // // // //       }

// // // // //       debug(" Extracted from URL:");
// // // // //       debug("   Lead Phone: $leadPhone");
// // // // //       debug("   Object Type: $objectType");

// // // // //       await _findAndNavigateToLead(leadPhone, objectType);
// // // // //     } catch (e) {
// // // // //       debug("  Error in _processDeepLink: $e");
// // // // //     }
// // // // //   }

// // // // //   /// 🔹 Extract phone number and object type from URL
// // // // //   Map<String, String> _extractDataFromUrl(String url) {
// // // // //     Map<String, String> result = {'phone': '', 'objectType': ''};

// // // // //     try {
// // // // //       debug("  Extracting data from URL: $url");

// // // // //       // PATTERN 1: /chat/9198824246750 (WhatsApp direct chat)
// // // // //       if (url.contains('/chat/') &&
// // // // //           !url.contains('/Lead/chat/') &&
// // // // //           !url.contains('/Contact/chat/') &&
// // // // //           !url.contains('/Opportunity/chat/')) {
// // // // //         final RegExp phoneRegex = RegExp(r'/chat/(\+?\d+)');
// // // // //         final Match? match = phoneRegex.firstMatch(url);

// // // // //         if (match != null && match.group(1) != null) {
// // // // //           String phone = match.group(1)!;
// // // // //           phone = _formatPhoneNumber(phone);
// // // // //           result['phone'] = phone;
// // // // //           result['objectType'] = 'whatsapp';
// // // // //           debug("  Found WhatsApp direct chat number: $phone");
// // // // //           return result;
// // // // //         }
// // // // //       }

// // // // //       // PATTERN 2: /Lead/chat/917740989118 (Salesforce Lead)
// // // // //       // PATTERN 3: /Contact/chat/917740989118 (Salesforce Contact)
// // // // //       // PATTERN 4: /Opportunity/chat/917740989118 (Salesforce Opportunity)
// // // // //       final RegExp sfRegex =
// // // // //           RegExp(r'\/(Lead|Contact|Opportunity)\/chat\/(\+?\d+)');
// // // // //       final Match? sfMatch = sfRegex.firstMatch(url);

// // // // //       if (sfMatch != null) {
// // // // //         String objectType = sfMatch.group(1)!;
// // // // //         String phone = sfMatch.group(2)!;
// // // // //         phone = _formatPhoneNumber(phone);

// // // // //         result['phone'] = phone;
// // // // //         result['objectType'] =
// // // // //             objectType.toLowerCase(); // lead, contact, opportunity
// // // // //         debug("  Found Salesforce $objectType chat number: $phone");
// // // // //         return result;
// // // // //       }

// // // // //       // Alternative pattern for phone extraction
// // // // //       final RegExp altRegex = RegExp(r'chat/(\d{10,12})');
// // // // //       final Match? altMatch = altRegex.firstMatch(url);

// // // // //       if (altMatch != null && altMatch.group(1) != null) {
// // // // //         String phone = altMatch.group(1)!;
// // // // //         phone = _formatPhoneNumber(phone);

// // // // //         // Determine object type based on URL structure
// // // // //         if (url.contains('/Lead/')) {
// // // // //           result['objectType'] = 'lead';
// // // // //         } else if (url.contains('/Contact/')) {
// // // // //           result['objectType'] = 'contact';
// // // // //         } else if (url.contains('/Opportunity/')) {
// // // // //           result['objectType'] = 'opportunity';
// // // // //         } else {
// // // // //           result['objectType'] = 'whatsapp';
// // // // //         }

// // // // //         result['phone'] = phone;
// // // // //         debug(
// // // // //             "  Found phone with alt pattern: $phone (type: ${result['objectType']})");
// // // // //         return result;
// // // // //       }

// // // // //       debug("  No valid data found in URL");
// // // // //       return result;
// // // // //     } catch (e) {
// // // // //       debug("  Error extracting data from URL: $e");
// // // // //       return result;
// // // // //     }
// // // // //   }

// // // // //   /// 🔹 Format phone number with proper prefix
// // // // //   String _formatPhoneNumber(String phone) {
// // // // //     // Remove any non-digit characters except +
// // // // //     phone = phone.replaceAll(RegExp(r'[^\d+]'), '');

// // // // //     if (!phone.startsWith('+')) {
// // // // //       if (phone.length == 10) {
// // // // //         return '+91$phone';
// // // // //       } else if (phone.length == 12 && phone.startsWith('91')) {
// // // // //         return '+$phone';
// // // // //       }
// // // // //     }
// // // // //     return phone;
// // // // //   }

// // // // //   /// 🔹 Find lead and navigate with Salesforce object handling
// // // // //   Future<void> _findAndNavigateToLead(
// // // // //       String leadPhone, String? objectType) async {
// // // // //     WidgetsBinding.instance.addPostFrameCallback((_) async {
// // // // //       try {
// // // // //         final context = navigatorKey.currentContext;
// // // // //         if (context == null) {
// // // // //           debug("  Context is null, retrying in 500ms...");
// // // // //           Future.delayed(const Duration(milliseconds: 500), () {
// // // // //             _findAndNavigateToLead(leadPhone, objectType);
// // // // //           });
// // // // //           return;
// // // // //         }

// // // // //         // Get LeadListViewModel
// // // // //         final leadListVm =
// // // // //             Provider.of<LeadListViewModel>(context, listen: false);

// // // // //         // Fetch leads if not already fetched
// // // // //         if (leadListVm.viewModels.isEmpty) {
// // // // //           await leadListVm.fetch();
// // // // //           await Future.delayed(const Duration(milliseconds: 300));
// // // // //         }

// // // // //         LeadModel? matchedModel;
// // // // //         final List<LeadModel> pinnedLeads = [];

// // // // //         debug(
// // // // //             "  Searching for lead with phone: $leadPhone (object type: $objectType)");

// // // // //         for (var viewModel in leadListVm.viewModels) {
// // // // //           final leadmodel = viewModel.model;

// // // // //           if (leadmodel?.records != null) {
// // // // //             for (var record in leadmodel!.records!) {
// // // // //               debug("Checking lead: ${record.full_number}");
// // // // //               if (record.pinned == true) {
// // // // //                 pinnedLeads.add(record);
// // // // //               }
// // // // //               if (record.full_number != null) {
// // // // //                 String recordPhone = record.full_number!.trim();
// // // // //                 String searchPhone = leadPhone.trim();
// // // // //                 String recordPhoneWithoutPrefix = recordPhone;
// // // // //                 String searchPhoneWithoutPrefix = searchPhone;

// // // // //                 if (recordPhone.startsWith('+91')) {
// // // // //                   recordPhoneWithoutPrefix = recordPhone.substring(3);
// // // // //                 }
// // // // //                 if (searchPhone.startsWith('+91')) {
// // // // //                   searchPhoneWithoutPrefix = searchPhone.substring(3);
// // // // //                 }

// // // // //                 // Try multiple matching patterns
// // // // //                 bool isMatch = recordPhone == searchPhone ||
// // // // //                     recordPhoneWithoutPrefix == searchPhoneWithoutPrefix ||
// // // // //                     recordPhone == '+91$searchPhoneWithoutPrefix' ||
// // // // //                     '+91$recordPhoneWithoutPrefix' == searchPhone ||
// // // // //                     recordPhone == '91$searchPhoneWithoutPrefix' ||
// // // // //                     '91$recordPhoneWithoutPrefix' == searchPhone;

// // // // //                 if (isMatch) {
// // // // //                   matchedModel = record;
// // // // //                   debug(
// // // // //                       "  Found matching lead: ${record.contactname} - ${record.full_number}");
// // // // //                   break;
// // // // //                 }
// // // // //               }
// // // // //             }
// // // // //           }

// // // // //           if (matchedModel != null) break;
// // // // //         }

// // // // //         if (matchedModel == null) {
// // // // //           debug("  No matching lead found for phone: $leadPhone");
// // // // //           matchedModel = LeadModel(
// // // // //             id: leadPhone,
// // // // //             contactname: leadPhone,
// // // // //             full_number: leadPhone,
// // // // //             pinned: false,
// // // // //           );
// // // // //           debug(" Using dummy lead with phone number");
// // // // //         }

// // // // //         await _navigateToChatScreen(matchedModel, pinnedLeads, objectType);
// // // // //       } catch (e) {
// // // // //         debug("  Error finding lead: $e");
// // // // //       }
// // // // //     });
// // // // //   }

// // // // //   Future<void> _navigateToChatScreen(LeadModel matchedModel,
// // // // //       List<LeadModel> pinnedLeads, String? objectType) async {
// // // // //     try {
// // // // //       final context = navigatorKey.currentContext;
// // // // //       if (context == null) {
// // // // //         debug("  Context is null for navigation");
// // // // //         return;
// // // // //       }

// // // // //       final currentRoute = ModalRoute.of(context);
// // // // //       if (currentRoute?.settings.name?.contains('chat') == true) {
// // // // //         debug(" Already on chat screen");
// // // // //         pendingDeepLink = null;
// // // // //         return;
// // // // //       }

// // // // //       debug("📊 Navigation Details:");
// // // // //       debug("   Lead Name: ${matchedModel.contactname}");
// // // // //       debug("   Lead Phone: ${matchedModel.full_number}");
// // // // //       debug("   ID: ${matchedModel.id}");
// // // // //       debug("   Object Type: $objectType");
// // // // //       debug("   Pinned Leads: ${pinnedLeads.length}");

// // // // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // // // //       String sfAccessToken =
// // // // //           prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";
// // // // //       debug("message: Salesforce Access Token = $sfAccessToken");
// // // // //       bool isSalesforceUrl = objectType != null &&
// // // // //           ['lead', 'contact', 'opportunity'].contains(objectType.toLowerCase());
// // // // //       debug("isSalesforceUrl: $isSalesforceUrl");
// // // // //       bool isWhatsappUrl =
// // // // //           objectType == null || objectType.toLowerCase() == 'whatsapp';

// // // // //       debug("🔗 Salesforce Token Present: ${sfAccessToken.isNotEmpty}");
// // // // //       debug("🏷️ Is Salesforce URL: $isSalesforceUrl");
// // // // //       debug("💬 Is WhatsApp URL: $isWhatsappUrl");

// // // // //       if (isSalesforceUrl && sfAccessToken.isNotEmpty) {
// // // // //         debug("🚀 Navigating to Salesforce Chat Screen for $objectType");

// // // // //         try {
// // // // //           String sObjectName = '';
// // // // //           switch (objectType.toLowerCase()) {
// // // // //             case 'lead':
// // // // //               sObjectName = 'Lead';
// // // // //               break;
// // // // //             case 'contact':
// // // // //               sObjectName = 'Contact';
// // // // //               break;
// // // // //             case 'opportunity':
// // // // //               sObjectName = 'Opportunity';
// // // // //               break;
// // // // //             default:
// // // // //               sObjectName = 'Lead';
// // // // //           }

// // // // //           debug("📞 Making API call for sObject: $sObjectName");

// // // // //           //   ACTUAL NAVIGATION TO SALESFORCE CHAT SCREEN ADDED HERE
// // // // //           _navigateToSalesforceChat(
// // // // //               context, matchedModel, pinnedLeads, sObjectName);

// // // // //           pendingDeepLink = null;
// // // // //           debug("🎉 Salesforce navigation successful for $objectType!");
// // // // //         } catch (e) {
// // // // //           debug("  Salesforce API/ Navigation error: $e");

// // // // //           _navigateToWhatsAppChat(context, matchedModel, pinnedLeads);
// // // // //         }
// // // // //       } else if (isWhatsappUrl || (isSalesforceUrl && sfAccessToken.isEmpty)) {
// // // // //         if (isSalesforceUrl && sfAccessToken.isEmpty) {
// // // // //           debug("🔐 Salesforce token missing - falling back to WhatsApp chat");
// // // // //           ScaffoldMessenger.of(context).showSnackBar(
// // // // //             SnackBar(
// // // // //               content: Text('Please login to Salesforce for $objectType chat'),
// // // // //               duration: Duration(seconds: 2),
// // // // //             ),
// // // // //           );
// // // // //         }

// // // // //         _navigateToWhatsAppChat(context, matchedModel, pinnedLeads);
// // // // //       } else {
// // // // //         debug(" Unknown URL pattern - falling back to WhatsApp chat");
// // // // //         _navigateToWhatsAppChat(context, matchedModel, pinnedLeads);
// // // // //       }
// // // // //     } catch (e) {
// // // // //       debug("  Navigation error: $e");
// // // // //       // Final fallback
// // // // //       final context = navigatorKey.currentContext;
// // // // //       if (context != null) {
// // // // //         _navigateToWhatsAppChat(context, matchedModel, pinnedLeads);
// // // // //       }
// // // // //     }
// // // // //   }

// // // // // //   NEW FUNCTION TO NAVIGATE TO SALESFORCE CHAT SCREEN
// // // // //   void _navigateToSalesforceChat(
// // // // //     BuildContext context,
// // // // //     LeadModel matchedModel,
// // // // //     List<LeadModel> pinnedLeads,
// // // // //     String sObjectName,
// // // // //   ) {
// // // // //     debug("💙 Navigating to Salesforce Chat Screen for $sObjectName");

// // // // //     // Convert pinnedLeads (List<LeadModel>) to List<SfDrawerItemModel> if needed
// // // // //     List<SfDrawerItemModel> sfPinnedLeads = [];

// // // // //     Navigator.push(
// // // // //       context,
// // // // //       MaterialPageRoute(
// // // // //         builder: (_) => SfMessageChatScreen(
// // // // //           // Pass required parameters
// // // // //           pinnedLeadsList: sfPinnedLeads,
// // // // //           isFromRecentChat: false,
// // // // //           // You might need to pass additional data like:
// // // // //           // leadId: matchedModel.id,
// // // // //           // leadPhone: matchedModel.full_number,
// // // // //           // leadName: matchedModel.contactname,
// // // // //           // sObjectType: sObjectName,
// // // // //         ),
// // // // //       ),
// // // // //     );

// // // // //     pendingDeepLink = null;
// // // // //     debug("🎉 Salesforce Chat Screen navigation completed!");
// // // // //   }

// // // // //   void _navigateToWhatsAppChat(BuildContext context, LeadModel matchedModel,
// // // // //       List<LeadModel> pinnedLeads) {
// // // // //     debug("💚 Navigating to WhatsApp Chat Screen");

// // // // //     Navigator.push(
// // // // //       context,
// // // // //       MaterialPageRoute(
// // // // //         builder: (_) => WhatsappChatScreen(
// // // // //           leadName:
// // // // //               matchedModel.contactname ?? matchedModel.full_number ?? "Unknown",
// // // // //           wpnumber: matchedModel.full_number ?? "",
// // // // //           id: matchedModel.id ?? matchedModel.full_number ?? "",
// // // // //           model: matchedModel,
// // // // //           pinnedLeads: pinnedLeads,
// // // // //         ),
// // // // //       ),
// // // // //     );

// // // // //     pendingDeepLink = null;
// // // // //     debug("🎉 WhatsApp navigation successful!");
// // // // //   }

// // // // //   @override
// // // // //   void dispose() {
// // // // //     _linkSubscription?.cancel();
// // // // //     super.dispose();
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // //       _processPendingDeepLink();
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

// // // // // // // // // // // import 'dart:async';
// // // // // // // // // // // import 'dart:core';

// // // // // // // // // // // import 'package:app_links/app_links.dart';
// // // // // // // // // // // import 'package:firebase_core/firebase_core.dart';
// // // // // // // // // // // import 'package:firebase_messaging/firebase_messaging.dart';
// // // // // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // // // // import 'package:flutter/services.dart';
// // // // // // // // // // // import 'package:flutter_easyloading/flutter_easyloading.dart';
// // // // // // // // // // // import 'package:google_fonts/google_fonts.dart';
// // // // // // // // // // // import 'package:provider/provider.dart';
// // // // // // // // // // // import 'package:timezone/data/latest.dart' as tz;

// // // // // // // // // // // // Controllers & VMs
// // // // // // // // // // // import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
// // // // // // // // // // // import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
// // // // // // // // // // // import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
// // // // // // // // // // // import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
// // // // // // // // // // // import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
// // // // // // // // // // // import 'package:whatsapp/salesforce/controller/template_controller.dart';

// // // // // // // // // // // import 'package:whatsapp/services/notifications/notification_service.dart';
// // // // // // // // // // // import 'package:whatsapp/utils/app_color.dart';
// // // // // // // // // // // import 'package:whatsapp/utils/function_lib.dart';

// // // // // // // // // // // import 'package:whatsapp/view_models/approved_template_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/auto_response_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/call_view_model.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/campaign_chart_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/campaign_count_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/campaign_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/chart_list_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/get_user_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/groups_view_model.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/lead_controller.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/lead_count_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/lead_list_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/message_controller.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/message_history_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/message_list_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/tags_list_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/templete_list_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/unread_count_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/user_data_list_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/wallet_controller.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/whatsapp_setting_vm.dart';

// // // // // // // // // // // import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
// // // // // // // // // // // import 'package:whatsapp/views/view/splash_view.dart';

// // // // // // // // // // // import 'firebase_options.dart';

// // // // // // // // // // // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// // // // // // // // // // // final RouteObserver<ModalRoute<void>> routeObserver =
// // // // // // // // // // //     RouteObserver<ModalRoute<void>>();

// // // // // // // // // // // @pragma('vm:entry-point')
// // // // // // // // // // // Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// // // // // // // // // // //   await Firebase.initializeApp();
// // // // // // // // // // // }

// // // // // // // // // // // void main() async {
// // // // // // // // // // //   tz.initializeTimeZones();

// // // // // // // // // // //   WidgetsFlutterBinding.ensureInitialized();
// // // // // // // // // // //   await Firebase.initializeApp(
// // // // // // // // // // //     options: DefaultFirebaseOptions.currentPlatform,
// // // // // // // // // // //   );

// // // // // // // // // // //   FirebaseMessaging.onBackgroundMessage(
// // // // // // // // // // //     firebaseMessagingBackgroundHandler,
// // // // // // // // // // //   );

// // // // // // // // // // //   await NotificationService.init();

// // // // // // // // // // //   runApp(const MyApp());
// // // // // // // // // // //   await NotificationService.handleInitialMessage();
// // // // // // // // // // // }

// // // // // // // // // // // class MyApp extends StatefulWidget {
// // // // // // // // // // //   const MyApp({super.key});

// // // // // // // // // // //   @override
// // // // // // // // // // //   State<MyApp> createState() => _MyAppState();
// // // // // // // // // // // }

// // // // // // // // // // // class _MyAppState extends State<MyApp> {
// // // // // // // // // // //   late final AppLinks _appLinks;
// // // // // // // // // // //   StreamSubscription<Uri>? _linkSubscription;

// // // // // // // // // // //   @override
// // // // // // // // // // //   void initState() {
// // // // // // // // // // //     super.initState();
// // // // // // // // // // //     debug("🚀 AppLinks initialized");

// // // // // // // // // // //     _appLinks = AppLinks();
// // // // // // // // // // //     _handleInitialUri();
// // // // // // // // // // //     _listenToUriStream();
// // // // // // // // // // //   }

// // // // // // // // // // //   Future<void> _handleInitialUri() async {
// // // // // // // // // // //     try {
// // // // // // // // // // //       final Uri? initialUri = await _appLinks.getInitialLink();
// // // // // // // // // // //       debug("📌 Initial URI => $initialUri");

// // // // // // // // // // //       if (initialUri != null) {
// // // // // // // // // // //         _handleDeepLink(initialUri);
// // // // // // // // // // //       }
// // // // // // // // // // //     } catch (e) {
// // // // // // // // // // //       debug("  Initial URI error: $e");
// // // // // // // // // // //     }
// // // // // // // // // // //   }

// // // // // // // // // // //   /// 🔹 Runtime links
// // // // // // // // // // //   void _listenToUriStream() {
// // // // // // // // // // //     _linkSubscription = _appLinks.uriLinkStream.listen(
// // // // // // // // // // //       (Uri uri) {
// // // // // // // // // // //         debug("🔗 Stream URI => $uri");
// // // // // // // // // // //         _handleDeepLink(uri);
// // // // // // // // // // //       },
// // // // // // // // // // //       onError: (err) {
// // // // // // // // // // //         debug("  URI Stream error: $err");
// // // // // // // // // // //       },
// // // // // // // // // // //     );
// // // // // // // // // // //   }

// // // // // // // // // // //   /// 🔹 Deep link navigation
// // // // // // // // // // //   void _handleDeepLink(Uri uri) {
// // // // // // // // // // //     debug("➡️ Handling DeepLink: $uri");

// // // // // // // // // // //     if (uri.pathSegments.contains('chat')) {
// // // // // // // // // // //       final params = uri.queryParameters;

// // // // // // // // // // //       final leadName = params['name'] ?? 'WatConnect';
// // // // // // // // // // //       final wpnumber = params['number'] ?? '';
// // // // // // // // // // //       final id = params['id'];

// // // // // // // // // // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // // // // // //         final context = navigatorKey.currentContext;
// // // // // // // // // // //         if (context != null) {
// // // // // // // // // // //           Navigator.push(
// // // // // // // // // // //             context,
// // // // // // // // // // //             MaterialPageRoute(
// // // // // // // // // // //               builder: (_) => WhatsappChatScreen(
// // // // // // // // // // //                 leadName: leadName,
// // // // // // // // // // //                 wpnumber: wpnumber,
// // // // // // // // // // //                 id: id,
// // // // // // // // // // //               ),
// // // // // // // // // // //             ),
// // // // // // // // // // //           );
// // // // // // // // // // //         }
// // // // // // // // // // //       });
// // // // // // // // // // //     }
// // // // // // // // // // //   }

// // // // // // // // // // //   @override
// // // // // // // // // // //   void dispose() {
// // // // // // // // // // //     _linkSubscription?.cancel();
// // // // // // // // // // //     super.dispose();
// // // // // // // // // // //   }

// // // // // // // // // // //   @override
// // // // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // // // //     SystemChrome.setSystemUIOverlayStyle(
// // // // // // // // // // //       const SystemUiOverlayStyle(
// // // // // // // // // // //         statusBarColor: Colors.transparent,
// // // // // // // // // // //         statusBarIconBrightness: Brightness.dark,
// // // // // // // // // // //         statusBarBrightness: Brightness.light,
// // // // // // // // // // //       ),
// // // // // // // // // // //     );

// // // // // // // // // // //     SystemChrome.setPreferredOrientations([
// // // // // // // // // // //       DeviceOrientation.portraitUp,
// // // // // // // // // // //       DeviceOrientation.portraitDown,
// // // // // // // // // // //     ]);

// // // // // // // // // // //     return MultiProvider(
// // // // // // // // // // //       providers: [
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => ApprovedTemplateViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => UnreadCountVm(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => GroupsViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => MessageViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => CampaignChartViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => LeadListViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => TagsListViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => CampaignViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => MeesageHistoryViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => LeadCountViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => TempleteListViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => AutoResponseViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => WhatsappSettingViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => CampaignCountViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => ChartListViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => GetUserViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => UserDataListViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => MessageController()),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => DashBoardController()),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => TemplateController()),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => BusinessNumberController()),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => CallsViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => ChatMessageController()),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => SfcampaignController()),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => WalletController()),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => LeadController()),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => SfFileUploadController()),
// // // // // // // // // // //       ],
// // // // // // // // // // //       child: MaterialApp(
// // // // // // // // // // //         debugShowCheckedModeBanner: false,
// // // // // // // // // // //         navigatorKey: navigatorKey,
// // // // // // // // // // //         navigatorObservers: [routeObserver],
// // // // // // // // // // //         title: 'WatConnect',
// // // // // // // // // // //         theme: ThemeData(
// // // // // // // // // // //           textTheme: GoogleFonts.kohSantepheapTextTheme(),
// // // // // // // // // // //           primaryColor: AppColor.navBarIconColor,
// // // // // // // // // // //           appBarTheme: const AppBarTheme(
// // // // // // // // // // //             backgroundColor: AppColor.navBarIconColor,
// // // // // // // // // // //           ),
// // // // // // // // // // //         ),
// // // // // // // // // // //         builder: EasyLoading.init(),
// // // // // // // // // // //         home: const SplashView(),
// // // // // // // // // // //       ),
// // // // // // // // // // //     );
// // // // // // // // // // //   }
// // // // // // // // // // // // }

// // // // // // // // // // // import 'dart:async';
// // // // // // // // // // // import 'dart:core';

// // // // // // // // // // // import 'package:app_links/app_links.dart';
// // // // // // // // // // // import 'package:firebase_core/firebase_core.dart';
// // // // // // // // // // // import 'package:firebase_messaging/firebase_messaging.dart';
// // // // // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // // // // import 'package:flutter/services.dart';
// // // // // // // // // // // import 'package:flutter_easyloading/flutter_easyloading.dart';
// // // // // // // // // // // import 'package:google_fonts/google_fonts.dart';
// // // // // // // // // // // import 'package:provider/provider.dart';
// // // // // // // // // // // import 'package:timezone/data/latest.dart' as tz;

// // // // // // // // // // // // Controllers & VMs
// // // // // // // // // // // import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
// // // // // // // // // // // import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
// // // // // // // // // // // import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
// // // // // // // // // // // import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
// // // // // // // // // // // import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
// // // // // // // // // // // import 'package:whatsapp/salesforce/controller/template_controller.dart';

// // // // // // // // // // // import 'package:whatsapp/services/notifications/notification_service.dart';
// // // // // // // // // // // import 'package:whatsapp/utils/app_color.dart';
// // // // // // // // // // // import 'package:whatsapp/utils/function_lib.dart';

// // // // // // // // // // // import 'package:whatsapp/view_models/approved_template_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/auto_response_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/call_view_model.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/campaign_chart_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/campaign_count_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/campaign_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/chart_list_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/get_user_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/groups_view_model.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/lead_controller.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/lead_count_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/lead_list_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/message_controller.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/message_history_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/message_list_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/tags_list_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/templete_list_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/unread_count_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/user_data_list_vm.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/wallet_controller.dart';
// // // // // // // // // // // import 'package:whatsapp/view_models/whatsapp_setting_vm.dart';

// // // // // // // // // // // import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
// // // // // // // // // // // import 'package:whatsapp/views/view/splash_view.dart';

// // // // // // // // // // // import 'firebase_options.dart';

// // // // // // // // // // // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// // // // // // // // // // // final RouteObserver<ModalRoute<void>> routeObserver =
// // // // // // // // // // //     RouteObserver<ModalRoute<void>>();

// // // // // // // // // // // /// store deep link safely until app ready
// // // // // // // // // // // Uri? pendingDeepLink;

// // // // // // // // // // // @pragma('vm:entry-point')
// // // // // // // // // // // Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// // // // // // // // // // //   await Firebase.initializeApp();
// // // // // // // // // // // }

// // // // // // // // // // // void main() async {
// // // // // // // // // // //   tz.initializeTimeZones();

// // // // // // // // // // //   WidgetsFlutterBinding.ensureInitialized();
// // // // // // // // // // //   await Firebase.initializeApp(
// // // // // // // // // // //     options: DefaultFirebaseOptions.currentPlatform,
// // // // // // // // // // //   );

// // // // // // // // // // //   FirebaseMessaging.onBackgroundMessage(
// // // // // // // // // // //     firebaseMessagingBackgroundHandler,
// // // // // // // // // // //   );

// // // // // // // // // // //   await NotificationService.init();

// // // // // // // // // // //   runApp(const MyApp());
// // // // // // // // // // //   await NotificationService.handleInitialMessage();
// // // // // // // // // // // }

// // // // // // // // // // // class MyApp extends StatefulWidget {
// // // // // // // // // // //   const MyApp({super.key});

// // // // // // // // // // //   @override
// // // // // // // // // // //   State<MyApp> createState() => _MyAppState();
// // // // // // // // // // // }

// // // // // // // // // // // class _MyAppState extends State<MyApp> {
// // // // // // // // // // //   late final AppLinks _appLinks;
// // // // // // // // // // //   StreamSubscription<Uri>? _linkSubscription;

// // // // // // // // // // //   @override
// // // // // // // // // // //   void initState() {
// // // // // // // // // // //     super.initState();
// // // // // // // // // // //     debug("🚀 AppLinks initialized");

// // // // // // // // // // //     _appLinks = AppLinks();
// // // // // // // // // // //     _handleInitialUri();
// // // // // // // // // // //     _listenToUriStream();
// // // // // // // // // // //   }

// // // // // // // // // // //   /// 🔹 App killed state
// // // // // // // // // // //   Future<void> _handleInitialUri() async {
// // // // // // // // // // //     try {
// // // // // // // // // // //       final Uri? initialUri = await _appLinks.getInitialLink();
// // // // // // // // // // //       debug("📌 Initial URI => $initialUri");

// // // // // // // // // // //       if (initialUri != null) {
// // // // // // // // // // //         pendingDeepLink = initialUri;
// // // // // // // // // // //       }
// // // // // // // // // // //     } catch (e) {
// // // // // // // // // // //       debug("  Initial URI error: $e");
// // // // // // // // // // //     }
// // // // // // // // // // //   }

// // // // // // // // // // //   /// 🔹 Background / foreground
// // // // // // // // // // //   void _listenToUriStream() {
// // // // // // // // // // //     _linkSubscription = _appLinks.uriLinkStream.listen(
// // // // // // // // // // //       (Uri uri) {
// // // // // // // // // // //         debug("🔗 Stream URI => $uri");
// // // // // // // // // // //         pendingDeepLink = uri;
// // // // // // // // // // //         _processDeepLink();
// // // // // // // // // // //       },
// // // // // // // // // // //       onError: (err) {
// // // // // // // // // // //         debug("  URI Stream error: $err");
// // // // // // // // // // //       },
// // // // // // // // // // //     );
// // // // // // // // // // //   }

// // // // // // // // // // //   /// 🔹 Process deep link after providers ready
// // // // // // // // // // //   void _processDeepLink() {
// // // // // // // // // // //     if (pendingDeepLink == null) return;

// // // // // // // // // // //     final uri = pendingDeepLink!;
// // // // // // // // // // //     debug("➡️ Processing DeepLink: $uri");

// // // // // // // // // // //     if (!uri.pathSegments.contains('chat')) return;

// // // // // // // // // // //     final params = uri.queryParameters;
// // // // // // // // // // //     final leadName = params['name'] ?? 'WatConnect';
// // // // // // // // // // //     final wpnumber = params['number'] ?? '';
// // // // // // // // // // //     final id = params['id'];

// // // // // // // // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // // // // // //       final context = navigatorKey.currentContext;
// // // // // // // // // // //       if (context == null) return;

// // // // // // // // // // //       /// ensure providers exist
// // // // // // // // // // //       Provider.of<MessageController>(context, listen: false);
// // // // // // // // // // //       Provider.of<MessageViewModel>(context, listen: false);

// // // // // // // // // // //       Navigator.push(
// // // // // // // // // // //         context,
// // // // // // // // // // //         MaterialPageRoute(
// // // // // // // // // // //           builder: (_) => WhatsappChatScreen(
// // // // // // // // // // //             leadName: leadName,
// // // // // // // // // // //             wpnumber: wpnumber,
// // // // // // // // // // //             id: id,
// // // // // // // // // // //           ),
// // // // // // // // // // //         ),
// // // // // // // // // // //       );

// // // // // // // // // // //       pendingDeepLink = null;
// // // // // // // // // // //     });
// // // // // // // // // // //   }

// // // // // // // // // // //   @override
// // // // // // // // // // //   void dispose() {
// // // // // // // // // // //     _linkSubscription?.cancel();
// // // // // // // // // // //     super.dispose();
// // // // // // // // // // //   }

// // // // // // // // // // //   @override
// // // // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // // // //     /// call deep link after UI built
// // // // // // // // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // // // // // //       _processDeepLink();
// // // // // // // // // // //     });

// // // // // // // // // // //     SystemChrome.setSystemUIOverlayStyle(
// // // // // // // // // // //       const SystemUiOverlayStyle(
// // // // // // // // // // //         statusBarColor: Colors.transparent,
// // // // // // // // // // //         statusBarIconBrightness: Brightness.dark,
// // // // // // // // // // //         statusBarBrightness: Brightness.light,
// // // // // // // // // // //       ),
// // // // // // // // // // //     );

// // // // // // // // // // //     SystemChrome.setPreferredOrientations([
// // // // // // // // // // //       DeviceOrientation.portraitUp,
// // // // // // // // // // //       DeviceOrientation.portraitDown,
// // // // // // // // // // //     ]);

// // // // // // // // // // //     return MultiProvider(
// // // // // // // // // // //       providers: [
// // // // // // // // // // //         ChangeNotifierProvider(
// // // // // // // // // // //             create: (_) => ApprovedTemplateViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => UnreadCountVm(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => GroupsViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => MessageViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => CampaignChartViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => LeadListViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => TagsListViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => CampaignViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => MeesageHistoryViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => LeadCountViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => TempleteListViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => AutoResponseViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(
// // // // // // // // // // //             create: (_) => WhatsappSettingViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => CampaignCountViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => ChartListViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => GetUserViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => UserDataListViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => MessageController()),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => DashBoardController()),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => TemplateController()),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => BusinessNumberController()),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => CallsViewModel(context)),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => ChatMessageController()),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => SfcampaignController()),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => WalletController()),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => LeadController()),
// // // // // // // // // // //         ChangeNotifierProvider(create: (_) => SfFileUploadController()),
// // // // // // // // // // //       ],
// // // // // // // // // // //       child: MaterialApp(
// // // // // // // // // // //         debugShowCheckedModeBanner: false,
// // // // // // // // // // //         navigatorKey: navigatorKey,
// // // // // // // // // // //         navigatorObservers: [routeObserver],
// // // // // // // // // // //         title: 'WatConnect',
// // // // // // // // // // //         theme: ThemeData(
// // // // // // // // // // //           textTheme: GoogleFonts.kohSantepheapTextTheme(),
// // // // // // // // // // //           primaryColor: AppColor.navBarIconColor,
// // // // // // // // // // //           appBarTheme: const AppBarTheme(
// // // // // // // // // // //             backgroundColor: AppColor.navBarIconColor,
// // // // // // // // // // //           ),
// // // // // // // // // // //         ),
// // // // // // // // // // //         builder: EasyLoading.init(),
// // // // // // // // // // //         home: const SplashView(),
// // // // // // // // // // //       ),
// // // // // // // // // // //     );
// // // // // // // // // // //   }
// // // // // // // // // // // }

// // // // // // // // // // import 'dart:async';
// // // // // // // // // // import 'dart:core';

// // // // // // // // // // import 'package:app_links/app_links.dart';
// // // // // // // // // // import 'package:firebase_core/firebase_core.dart';
// // // // // // // // // // import 'package:firebase_messaging/firebase_messaging.dart';
// // // // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // // // import 'package:flutter/services.dart';
// // // // // // // // // // import 'package:flutter_easyloading/flutter_easyloading.dart';
// // // // // // // // // // import 'package:google_fonts/google_fonts.dart';
// // // // // // // // // // import 'package:provider/provider.dart';
// // // // // // // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // // // // // // // import 'package:timezone/data/latest.dart' as tz;
// // // // // // // // // // import 'package:shared_preferences/shared_preferences.dart';

// // // // // // // // // // // Controllers & VMs
// // // // // // // // // // import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
// // // // // // // // // // import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
// // // // // // // // // // import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
// // // // // // // // // // import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
// // // // // // // // // // import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
// // // // // // // // // // import 'package:whatsapp/salesforce/controller/template_controller.dart';

// // // // // // // // // // import 'package:whatsapp/services/notifications/notification_service.dart';
// // // // // // // // // // import 'package:whatsapp/utils/app_color.dart';
// // // // // // // // // // import 'package:whatsapp/utils/function_lib.dart';

// // // // // // // // // // import 'package:whatsapp/view_models/approved_template_vm.dart';
// // // // // // // // // // import 'package:whatsapp/view_models/auto_response_vm.dart';
// // // // // // // // // // import 'package:whatsapp/view_models/call_view_model.dart';
// // // // // // // // // // import 'package:whatsapp/view_models/campaign_chart_vm.dart';
// // // // // // // // // // import 'package:whatsapp/view_models/campaign_count_vm.dart';
// // // // // // // // // // import 'package:whatsapp/view_models/campaign_vm.dart';
// // // // // // // // // // import 'package:whatsapp/view_models/chart_list_vm.dart';
// // // // // // // // // // import 'package:whatsapp/view_models/get_user_vm.dart';
// // // // // // // // // // import 'package:whatsapp/view_models/groups_view_model.dart';
// // // // // // // // // // import 'package:whatsapp/view_models/lead_controller.dart';
// // // // // // // // // // import 'package:whatsapp/view_models/lead_count_vm.dart';
// // // // // // // // // // import 'package:whatsapp/view_models/lead_list_vm.dart';
// // // // // // // // // // import 'package:whatsapp/view_models/message_controller.dart';
// // // // // // // // // // import 'package:whatsapp/view_models/message_history_vm.dart';
// // // // // // // // // // import 'package:whatsapp/view_models/message_list_vm.dart';
// // // // // // // // // // import 'package:whatsapp/view_models/tags_list_vm.dart';
// // // // // // // // // // import 'package:whatsapp/view_models/templete_list_vm.dart';
// // // // // // // // // // import 'package:whatsapp/view_models/unread_count_vm.dart';
// // // // // // // // // // import 'package:whatsapp/view_models/user_data_list_vm.dart';
// // // // // // // // // // import 'package:whatsapp/view_models/wallet_controller.dart';
// // // // // // // // // // import 'package:whatsapp/view_models/whatsapp_setting_vm.dart';

// // // // // // // // // // import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
// // // // // // // // // // import 'package:whatsapp/views/view/splash_view.dart';

// // // // // // // // // // import 'firebase_options.dart';
// // // // // // // // // // import 'utils/app_constants.dart';

// // // // // // // // // // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// // // // // // // // // // final RouteObserver<ModalRoute<void>> routeObserver =
// // // // // // // // // //     RouteObserver<ModalRoute<void>>();

// // // // // // // // // // /// store deep link safely until app ready
// // // // // // // // // // Uri? pendingDeepLink;

// // // // // // // // // // @pragma('vm:entry-point')
// // // // // // // // // // Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// // // // // // // // // //   await Firebase.initializeApp();
// // // // // // // // // // }

// // // // // // // // // // void main() async {
// // // // // // // // // //   tz.initializeTimeZones();

// // // // // // // // // //   WidgetsFlutterBinding.ensureInitialized();
// // // // // // // // // //   await Firebase.initializeApp(
// // // // // // // // // //     options: DefaultFirebaseOptions.currentPlatform,
// // // // // // // // // //   );

// // // // // // // // // //   FirebaseMessaging.onBackgroundMessage(
// // // // // // // // // //     firebaseMessagingBackgroundHandler,
// // // // // // // // // //   );

// // // // // // // // // //   await NotificationService.init();

// // // // // // // // // //   // Initialize SharedPreferences
// // // // // // // // // //   final prefs = await SharedPreferences.getInstance();

// // // // // // // // // //   // Check for pending deep link from notification
// // // // // // // // // //   WidgetsBinding.instance.addPostFrameCallback((_) async {
// // // // // // // // // //     await _handlePendingDeepLinkFromNotification(prefs);
// // // // // // // // // //   });

// // // // // // // // // //   runApp(const MyApp());
// // // // // // // // // //   await NotificationService.handleInitialMessage();
// // // // // // // // // // }

// // // // // // // // // // Future<void> _handlePendingDeepLinkFromNotification(SharedPreferences prefs) async {
// // // // // // // // // //   try {

// // // // // // // // // //     final notificationData = prefs.getString('pending_notification_data');
// // // // // // // // // //     if (notificationData != null && notificationData.isNotEmpty) {
// // // // // // // // // //       debug(" Processing pending notification data: $notificationData");

// // // // // // // // // //       final phoneNumber = _extractPhoneNumberFromNotification(notificationData);
// // // // // // // // // //       final leadName = _extractLeadNameFromNotification(notificationData);

// // // // // // // // // //       if (phoneNumber.isNotEmpty) {

// // // // // // // // // //         final deepLinkUri = Uri.parse('https://admin.watconnect.com//chat?number=$phoneNumber&name=$leadName');
// // // // // // // // // //         debug("deepLinkUri: $deepLinkUri");
// // // // // // // // // //         pendingDeepLink = deepLinkUri;

// // // // // // // // // //         await prefs.remove('pending_notification_data');
// // // // // // // // // //       }
// // // // // // // // // //     }
// // // // // // // // // //   } catch (e) {
// // // // // // // // // //     debug("  Error processing pending notification: $e");
// // // // // // // // // //   }
// // // // // // // // // // }

// // // // // // // // // // String _extractPhoneNumberFromNotification(String data) {
// // // // // // // // // //   // Implement your logic to extract phone number from notification data
// // // // // // // // // //   // This depends on how your notification payload is structured
// // // // // // // // // //   try {
// // // // // // // // // //     // Example: if data contains phone number directly
// // // // // // // // // //     if (data.contains('phone') || data.contains('number')) {
// // // // // // // // // //       final regex = RegExp(r'(\+?\d[\d\s\-\(\)]{8,}\d)');
// // // // // // // // // //       final match = regex.firstMatch(data);
// // // // // // // // // //       return match?.group(0) ?? '';
// // // // // // // // // //     }
// // // // // // // // // //     return '';
// // // // // // // // // //   } catch (e) {
// // // // // // // // // //     return '';
// // // // // // // // // //   }
// // // // // // // // // // }

// // // // // // // // // // String _extractLeadNameFromNotification(String data) {
// // // // // // // // // //   // Implement your logic to extract lead name from notification data
// // // // // // // // // //   // This depends on how your notification payload is structured
// // // // // // // // // //   try {
// // // // // // // // // //     if (data.contains('name') || data.contains('lead')) {
// // // // // // // // // //       final regex = RegExp(r'"name"\s*:\s*"([^"]+)"');
// // // // // // // // // //       final match = regex.firstMatch(data);
// // // // // // // // // //       return match?.group(1) ?? 'WatConnect';
// // // // // // // // // //     }
// // // // // // // // // //     return 'WatConnect';
// // // // // // // // // //   } catch (e) {
// // // // // // // // // //     return 'WatConnect';
// // // // // // // // // //   }
// // // // // // // // // // }

// // // // // // // // // // class MyApp extends StatefulWidget {
// // // // // // // // // //   const MyApp({super.key});

// // // // // // // // // //   @override
// // // // // // // // // //   State<MyApp> createState() => _MyAppState();
// // // // // // // // // // }

// // // // // // // // // // class _MyAppState extends State<MyApp> {
// // // // // // // // // //   late final AppLinks _appLinks;
// // // // // // // // // //   StreamSubscription<Uri>? _linkSubscription;
// // // // // // // // // //   bool _isAppInitialized = false;
// // // // // // // // // //   bool _areProvidersReady = false;

// // // // // // // // // //   @override
// // // // // // // // // //   void initState() {
// // // // // // // // // //     super.initState();
// // // // // // // // // //     debug("🚀 AppLinks initialized");

// // // // // // // // // //     _appLinks = AppLinks();
// // // // // // // // // //     _handleInitialUri();
// // // // // // // // // //     _listenToUriStream();

// // // // // // // // // //     // Set app as initialized after a short delay
// // // // // // // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // // // // //       setState(() {
// // // // // // // // // //         _isAppInitialized = true;
// // // // // // // // // //       });
// // // // // // // // // //       _checkAndProcessDeepLink();
// // // // // // // // // //     });
// // // // // // // // // //   }

// // // // // // // // // //   /// 🔹 App killed state
// // // // // // // // // //   Future<void> _handleInitialUri() async {
// // // // // // // // // //     try {
// // // // // // // // // //       final Uri? initialUri = await _appLinks.getInitialLink();
// // // // // // // // // //       debug("📌 Initial URI => $initialUri");

// // // // // // // // // //       if (initialUri != null) {
// // // // // // // // // //         pendingDeepLink = initialUri;
// // // // // // // // // //         _checkAndProcessDeepLink();
// // // // // // // // // //       }
// // // // // // // // // //     } catch (e) {
// // // // // // // // // //       debug("  Initial URI error: $e");
// // // // // // // // // //     }
// // // // // // // // // //   }

// // // // // // // // // //   /// 🔹 Background / foreground
// // // // // // // // // //   void _listenToUriStream() {
// // // // // // // // // //     _linkSubscription = _appLinks.uriLinkStream.listen(
// // // // // // // // // //       (Uri uri) {
// // // // // // // // // //         debug("🔗 Stream URI => $uri");
// // // // // // // // // //         pendingDeepLink = uri;
// // // // // // // // // //         _checkAndProcessDeepLink();
// // // // // // // // // //       },
// // // // // // // // // //       onError: (err) {
// // // // // // // // // //         debug("  URI Stream error: $err");
// // // // // // // // // //       },
// // // // // // // // // //     );
// // // // // // // // // //   }

// // // // // // // // // //   void _checkAndProcessDeepLink() {
// // // // // // // // // //     if (pendingDeepLink == null || !_isAppInitialized || !_areProvidersReady) {
// // // // // // // // // //       return;
// // // // // // // // // //     }

// // // // // // // // // //     _processDeepLink();
// // // // // // // // // //   }

// // // // // // // // // //   void _processDeepLink() async {
// // // // // // // // // //     if (pendingDeepLink == null) return;

// // // // // // // // // //     final uri = pendingDeepLink!;
// // // // // // // // // //     debug("➡️ Processing DeepLink: $uri");

// // // // // // // // // //     if (!uri.pathSegments.contains('chat')) return;

// // // // // // // // // //     final params = uri.queryParameters;
// // // // // // // // // //     String leadName = params['name'] ?? 'WatConnect';
// // // // // // // // // //     String wpnumber = params['number'] ?? '';
// // // // // // // // // //     final id = params['id'];

// // // // // // // // // //     if (wpnumber.isEmpty) {
// // // // // // // // // //       wpnumber = await _extractPhoneNumberFromToken();
// // // // // // // // // //     }

// // // // // // // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // // // // //       final context = navigatorKey.currentContext;
// // // // // // // // // //       if (context == null) {
// // // // // // // // // //         debug("  Context is null, cannot navigate");
// // // // // // // // // //         return;
// // // // // // // // // //       }

// // // // // // // // // //       Navigator.push(
// // // // // // // // // //         context,
// // // // // // // // // //         MaterialPageRoute(
// // // // // // // // // //           builder: (_) => WhatsappChatScreen(
// // // // // // // // // //             leadName: leadName,
// // // // // // // // // //             wpnumber: wpnumber,
// // // // // // // // // //             id: id,
// // // // // // // // // //           ),
// // // // // // // // // //         ),
// // // // // // // // // //       );

// // // // // // // // // //       pendingDeepLink = null;
// // // // // // // // // //     });
// // // // // // // // // //   }

// // // // // // // // // //   Future<String> _extractPhoneNumberFromToken() async {
// // // // // // // // // //     try {
// // // // // // // // // //       final prefs = await SharedPreferences.getInstance();

// // // // // // // // // //       String phoneNumber = prefs.getString('user_phone') ??
// // // // // // // // // //                           prefs.getString('phone_number') ??
// // // // // // // // // //                           prefs.getString('wp_number') ??
// // // // // // // // // //                           '';

// // // // // // // // // //       if (phoneNumber.isEmpty) {
// // // // // // // // // //         final userData = prefs.getString(SharedPrefsConstants.accessTokenKey);
// // // // // // // // // //         if (userData != null && userData.isNotEmpty) {

// // // // // // // // // //           phoneNumber = _extractPhoneFromUserData(userData);
// // // // // // // // // //         }
// // // // // // // // // //       }

// // // // // // // // // //       if (phoneNumber.isEmpty) {
// // // // // // // // // //         final fcmToken = await FirebaseMessaging.instance.getToken();
// // // // // // // // // //         debug(" FCM Token: $fcmToken");

// // // // // // // // // //       }

// // // // // // // // // //       debug(" Extracted phone number from token: $phoneNumber");
// // // // // // // // // //       return phoneNumber;
// // // // // // // // // //     } catch (e) {
// // // // // // // // // //       debug("  Error extracting phone number from token: $e");
// // // // // // // // // //       return '';
// // // // // // // // // //     }
// // // // // // // // // //   }

// // // // // // // // // //   /// 🔹 Extract phone number from user data string
// // // // // // // // // //   String _extractPhoneFromUserData(String userData) {
// // // // // // // // // //     try {
// // // // // // // // // //       // Assuming userData is JSON string
// // // // // // // // // //       // You might need to parse it properly based on your actual structure
// // // // // // // // // //       if (userData.contains('phone') || userData.contains('mobile')) {
// // // // // // // // // //         final regex = RegExp(r'"phone":\s*"([^"]+)"');
// // // // // // // // // //         final match = regex.firstMatch(userData);
// // // // // // // // // //         return match?.group(1) ?? '';
// // // // // // // // // //       }
// // // // // // // // // //       return '';
// // // // // // // // // //     } catch (e) {
// // // // // // // // // //       return '';
// // // // // // // // // //     }
// // // // // // // // // //   }

// // // // // // // // // //   /// 🔹 Callback when providers are ready
// // // // // // // // // //   void _onProvidersReady() {
// // // // // // // // // //     if (!_areProvidersReady) {
// // // // // // // // // //       setState(() {
// // // // // // // // // //         _areProvidersReady = true;
// // // // // // // // // //       });
// // // // // // // // // //       _checkAndProcessDeepLink();
// // // // // // // // // //     }
// // // // // // // // // //   }

// // // // // // // // // //   @override
// // // // // // // // // //   void dispose() {
// // // // // // // // // //     _linkSubscription?.cancel();
// // // // // // // // // //     super.dispose();
// // // // // // // // // //   }

// // // // // // // // // //   @override
// // // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // // //     // Call providers ready callback after UI is built
// // // // // // // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // // // // //       _onProvidersReady();
// // // // // // // // // //     });

// // // // // // // // // //     SystemChrome.setSystemUIOverlayStyle(
// // // // // // // // // //       const SystemUiOverlayStyle(
// // // // // // // // // //         statusBarColor: Colors.transparent,
// // // // // // // // // //         statusBarIconBrightness: Brightness.dark,
// // // // // // // // // //         statusBarBrightness: Brightness.light,
// // // // // // // // // //       ),
// // // // // // // // // //     );

// // // // // // // // // //     SystemChrome.setPreferredOrientations([
// // // // // // // // // //       DeviceOrientation.portraitUp,
// // // // // // // // // //       DeviceOrientation.portraitDown,
// // // // // // // // // //     ]);

// // // // // // // // // //     return MultiProvider(
// // // // // // // // // //       providers: [
// // // // // // // // // //         ChangeNotifierProvider(
// // // // // // // // // //             create: (_) => ApprovedTemplateViewModel(context)),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => UnreadCountVm(context)),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => GroupsViewModel(context)),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => MessageViewModel(context)),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => CampaignChartViewModel(context)),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => LeadListViewModel(context)),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => TagsListViewModel(context)),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => CampaignViewModel(context)),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => MeesageHistoryViewModel(context)),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => LeadCountViewModel(context)),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => TempleteListViewModel(context)),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => AutoResponseViewModel(context)),
// // // // // // // // // //         ChangeNotifierProvider(
// // // // // // // // // //             create: (_) => WhatsappSettingViewModel(context)),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => CampaignCountViewModel(context)),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => ChartListViewModel(context)),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => GetUserViewModel(context)),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => UserDataListViewModel(context)),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => MessageController()),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => DashBoardController()),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => TemplateController()),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => BusinessNumberController()),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => CallsViewModel(context)),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => ChatMessageController()),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => SfcampaignController()),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => WalletController()),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => LeadController()),
// // // // // // // // // //         ChangeNotifierProvider(create: (_) => SfFileUploadController()),
// // // // // // // // // //       ],
// // // // // // // // // //       child: MaterialApp(
// // // // // // // // // //         debugShowCheckedModeBanner: false,
// // // // // // // // // //         navigatorKey: navigatorKey,
// // // // // // // // // //         navigatorObservers: [routeObserver],
// // // // // // // // // //         title: 'WatConnect',
// // // // // // // // // //         theme: ThemeData(
// // // // // // // // // //           textTheme: GoogleFonts.kohSantepheapTextTheme(),
// // // // // // // // // //           primaryColor: AppColor.navBarIconColor,
// // // // // // // // // //           appBarTheme: const AppBarTheme(
// // // // // // // // // //             backgroundColor: AppColor.navBarIconColor,
// // // // // // // // // //           ),
// // // // // // // // // //         ),
// // // // // // // // // //         builder: EasyLoading.init(),
// // // // // // // // // //         home: const SplashView(),
// // // // // // // // // //         // Handle route for deep linking
// // // // // // // // // //         onGenerateRoute: (settings) {
// // // // // // // // // //           // This can be used for more advanced routing if needed
// // // // // // // // // //           return null;
// // // // // // // // // //         },
// // // // // // // // // //       ),
// // // // // // // // // //     );
// // // // // // // // // //   }
// // // // // // // // // // }
// // // // // // // // // import 'dart:async';
// // // // // // // // // import 'dart:core';

// // // // // // // // // import 'package:app_links/app_links.dart';
// // // // // // // // // import 'package:firebase_core/firebase_core.dart';
// // // // // // // // // import 'package:firebase_messaging/firebase_messaging.dart';
// // // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // // import 'package:flutter/services.dart';
// // // // // // // // // import 'package:flutter_easyloading/flutter_easyloading.dart';
// // // // // // // // // import 'package:google_fonts/google_fonts.dart';
// // // // // // // // // import 'package:provider/provider.dart';
// // // // // // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // // // // // // import 'package:timezone/data/latest.dart' as tz;
// // // // // // // // // import 'package:whatsapp/utils/app_constants.dart';

// // // // // // // // // // Controllers & VMs
// // // // // // // // // import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
// // // // // // // // // import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
// // // // // // // // // import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
// // // // // // // // // import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
// // // // // // // // // import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
// // // // // // // // // import 'package:whatsapp/salesforce/controller/template_controller.dart';

// // // // // // // // // import 'package:whatsapp/services/notifications/notification_service.dart';
// // // // // // // // // import 'package:whatsapp/utils/app_color.dart';
// // // // // // // // // import 'package:whatsapp/utils/function_lib.dart';

// // // // // // // // // import 'package:whatsapp/view_models/approved_template_vm.dart';
// // // // // // // // // import 'package:whatsapp/view_models/auto_response_vm.dart';
// // // // // // // // // import 'package:whatsapp/view_models/call_view_model.dart';
// // // // // // // // // import 'package:whatsapp/view_models/campaign_chart_vm.dart';
// // // // // // // // // import 'package:whatsapp/view_models/campaign_count_vm.dart';
// // // // // // // // // import 'package:whatsapp/view_models/campaign_vm.dart';
// // // // // // // // // import 'package:whatsapp/view_models/chart_list_vm.dart';
// // // // // // // // // import 'package:whatsapp/view_models/get_user_vm.dart';
// // // // // // // // // import 'package:whatsapp/view_models/groups_view_model.dart';
// // // // // // // // // import 'package:whatsapp/view_models/lead_controller.dart';
// // // // // // // // // import 'package:whatsapp/view_models/lead_count_vm.dart';
// // // // // // // // // import 'package:whatsapp/view_models/lead_list_vm.dart';
// // // // // // // // // import 'package:whatsapp/view_models/message_controller.dart';
// // // // // // // // // import 'package:whatsapp/view_models/message_history_vm.dart';
// // // // // // // // // import 'package:whatsapp/view_models/message_list_vm.dart';
// // // // // // // // // import 'package:whatsapp/view_models/tags_list_vm.dart';
// // // // // // // // // import 'package:whatsapp/view_models/templete_list_vm.dart';
// // // // // // // // // import 'package:whatsapp/view_models/unread_count_vm.dart';
// // // // // // // // // import 'package:whatsapp/view_models/user_data_list_vm.dart';
// // // // // // // // // import 'package:whatsapp/view_models/wallet_controller.dart';
// // // // // // // // // import 'package:whatsapp/view_models/whatsapp_setting_vm.dart';

// // // // // // // // // import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
// // // // // // // // // import 'package:whatsapp/views/view/splash_view.dart';

// // // // // // // // // import 'firebase_options.dart';

// // // // // // // // // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// // // // // // // // // final RouteObserver<ModalRoute<void>> routeObserver =
// // // // // // // // //     RouteObserver<ModalRoute<void>>();

// // // // // // // // // /// store deep link safely until app ready
// // // // // // // // // Uri? pendingDeepLink;

// // // // // // // // // @pragma('vm:entry-point')
// // // // // // // // // Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// // // // // // // // //   await Firebase.initializeApp();
// // // // // // // // // }

// // // // // // // // // void main() async {
// // // // // // // // //   WidgetsFlutterBinding.ensureInitialized();

// // // // // // // // //   try {
// // // // // // // // //     tz.initializeTimeZones();

// // // // // // // // //     await Firebase.initializeApp(
// // // // // // // // //       options: DefaultFirebaseOptions.currentPlatform,
// // // // // // // // //     );

// // // // // // // // //     FirebaseMessaging.onBackgroundMessage(
// // // // // // // // //       firebaseMessagingBackgroundHandler,
// // // // // // // // //     );

// // // // // // // // //     await NotificationService.init();

// // // // // // // // //     runApp(const MyApp());
// // // // // // // // //     await NotificationService.handleInitialMessage();
// // // // // // // // //   } catch (e) {
// // // // // // // // //     debug("  Error in main(): $e");
// // // // // // // // //     // You might want to show an error screen here
// // // // // // // // //     runApp(
// // // // // // // // //       MaterialApp(
// // // // // // // // //         home: Scaffold(
// // // // // // // // //           body: Center(
// // // // // // // // //             child: Text('App initialization failed: $e'),
// // // // // // // // //           ),
// // // // // // // // //         ),
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // // }

// // // // // // // // // class MyApp extends StatefulWidget {
// // // // // // // // //   const MyApp({super.key});

// // // // // // // // //   @override
// // // // // // // // //   State<MyApp> createState() => _MyAppState();
// // // // // // // // // }

// // // // // // // // // class _MyAppState extends State<MyApp> {
// // // // // // // // //   late final AppLinks _appLinks;
// // // // // // // // //   StreamSubscription<Uri>? _linkSubscription;
// // // // // // // // //   bool _isAppInitialized = false;
// // // // // // // // //   bool _areProvidersReady = false;

// // // // // // // // //   @override
// // // // // // // // //   void initState() {
// // // // // // // // //     super.initState();

// // // // // // // // //     try {
// // // // // // // // //       debug("🚀 AppLinks initialized");
// // // // // // // // //       _appLinks = AppLinks();
// // // // // // // // //       _handleInitialUri();
// // // // // // // // //       _listenToUriStream();

// // // // // // // // //       // Set app as initialized after a short delay
// // // // // // // // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // // // //         if (mounted) {
// // // // // // // // //           setState(() {
// // // // // // // // //             _isAppInitialized = true;
// // // // // // // // //           });
// // // // // // // // //           _checkAndProcessDeepLink();
// // // // // // // // //         }
// // // // // // // // //       });
// // // // // // // // //     } catch (e) {
// // // // // // // // //       debug("  Error in MyApp initState: $e");
// // // // // // // // //     }
// // // // // // // // //   }

// // // // // // // // //   /// 🔹 App killed state
// // // // // // // // //   Future<void> _handleInitialUri() async {
// // // // // // // // //     try {
// // // // // // // // //       final Uri? initialUri = await _appLinks.getInitialLink();
// // // // // // // // //       debug("📌 Initial URI => $initialUri");

// // // // // // // // //       if (initialUri != null) {
// // // // // // // // //         pendingDeepLink = initialUri;
// // // // // // // // //         _checkAndProcessDeepLink();
// // // // // // // // //       }
// // // // // // // // //     } catch (e) {
// // // // // // // // //       debug("  Initial URI error: $e");
// // // // // // // // //     }
// // // // // // // // //   }

// // // // // // // // //   /// 🔹 Background / foreground
// // // // // // // // //   void _listenToUriStream() {
// // // // // // // // //     _linkSubscription = _appLinks.uriLinkStream.listen(
// // // // // // // // //       (Uri uri) {
// // // // // // // // //         debug("🔗 Stream URI => $uri");
// // // // // // // // //         pendingDeepLink = uri;
// // // // // // // // //         _checkAndProcessDeepLink();
// // // // // // // // //       },
// // // // // // // // //       onError: (err) {
// // // // // // // // //         debug("  URI Stream error: $err");
// // // // // // // // //       },
// // // // // // // // //     );
// // // // // // // // //   }

// // // // // // // // //   /// 🔹 Check conditions and process deep link
// // // // // // // // //   void _checkAndProcessDeepLink() {
// // // // // // // // //     try {
// // // // // // // // //       if (pendingDeepLink == null ||
// // // // // // // // //           !_isAppInitialized ||
// // // // // // // // //           !_areProvidersReady) {
// // // // // // // // //         debug("⏳ Skipping deep link - conditions not met");
// // // // // // // // //         return;
// // // // // // // // //       }

// // // // // // // // //       _processDeepLink();
// // // // // // // // //     } catch (e) {
// // // // // // // // //       debug("  Error in checkAndProcessDeepLink: $e");
// // // // // // // // //     }
// // // // // // // // //   }

// // // // // // // // //   /// 🔹 Extract phone numbers from URL path and query parameters
// // // // // // // // //   Map<String, String> _extractPhoneNumbersFromUri(Uri uri) {
// // // // // // // // //     final Map<String, String> phoneNumbers = {
// // // // // // // // //       'leadPhone': '',
// // // // // // // // //       'whatsappSettingNumber': ''
// // // // // // // // //     };

// // // // // // // // //     try {
// // // // // // // // //       debug("  Extracting phone numbers from URI: $uri");

// // // // // // // // //       // Extract lead phone from path (e.g., /message/history/+917740989118)
// // // // // // // // //       final pathSegments = uri.pathSegments;
// // // // // // // // //       for (var segment in pathSegments) {
// // // // // // // // //         if (segment.startsWith('+') && segment.length > 10) {
// // // // // // // // //           phoneNumbers['leadPhone'] = segment;
// // // // // // // // //           debug(" Found lead phone in path: ${phoneNumbers['leadPhone']}");
// // // // // // // // //           break;
// // // // // // // // //         }
// // // // // // // // //       }

// // // // // // // // //       // Extract whatsapp_setting_number from query parameters
// // // // // // // // //       final queryParams = uri.queryParameters;
// // // // // // // // //       if (queryParams.containsKey('whatsapp_setting_number')) {
// // // // // // // // //         phoneNumbers['whatsappSettingNumber'] =
// // // // // // // // //             queryParams['whatsapp_setting_number']!;
// // // // // // // // //         debug(
// // // // // // // // //             " Found whatsapp setting number: ${phoneNumbers['whatsappSettingNumber']}");
// // // // // // // // //       }

// // // // // // // // //       // If not found in query, try to extract from full URL
// // // // // // // // //       if (phoneNumbers['whatsappSettingNumber']!.isEmpty) {
// // // // // // // // //         final urlString = uri.toString();
// // // // // // // // //         final regex = RegExp(r'whatsapp_setting_number=(\+?\d+)');
// // // // // // // // //         final match = regex.firstMatch(urlString);
// // // // // // // // //         if (match != null && match.group(1) != null) {
// // // // // // // // //           phoneNumbers['whatsappSettingNumber'] = match.group(1)!;
// // // // // // // // //           debug(
// // // // // // // // //               " Extracted whatsapp setting number from URL: ${phoneNumbers['whatsappSettingNumber']}");
// // // // // // // // //         }
// // // // // // // // //       }

// // // // // // // // //       return phoneNumbers;
// // // // // // // // //     } catch (e) {
// // // // // // // // //       debug("  Error extracting phone numbers: $e");
// // // // // // // // //       return phoneNumbers;
// // // // // // // // //     }
// // // // // // // // //   }

// // // // // // // // //   /// 🔹 Process deep link after providers ready
// // // // // // // // //   void _processDeepLink() async {
// // // // // // // // //     try {
// // // // // // // // //       if (pendingDeepLink == null) {
// // // // // // // // //         debug(" No pending deep link to process");
// // // // // // // // //         return;
// // // // // // // // //       }

// // // // // // // // //       final uri = pendingDeepLink!;
// // // // // // // // //       debug("➡️ Processing DeepLink: $uri");

// // // // // // // // //       // Check if this is your API URL pattern
// // // // // // // // //       final isMessageHistoryUrl =
// // // // // // // // //           uri.toString().contains('/api/whatsapp/message/history/');

// // // // // // // // //       if (isMessageHistoryUrl) {
// // // // // // // // //         // Extract phone numbers from URL
// // // // // // // // //         final phoneNumbers = _extractPhoneNumbersFromUri(uri);
// // // // // // // // //         final leadPhone = phoneNumbers['leadPhone'] ?? '';
// // // // // // // // //         final whatsappSettingNumber =
// // // // // // // // //             phoneNumbers['whatsappSettingNumber'] ?? '';

// // // // // // // // //         if (leadPhone.isEmpty) {
// // // // // // // // //           debug("  Lead phone number not found in URL");
// // // // // // // // //           return;
// // // // // // // // //         }

// // // // // // // // //         // Get additional data from tokens if needed
// // // // // // // // //         final userData = await _getUserDataFromTokens();
// // // // // // // // //         final leadName = userData['leadName'] ?? 'WatConnect User';

// // // // // // // // //         // Navigate to chat screen
// // // // // // // // //         WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // // // //           try {
// // // // // // // // //             final context = navigatorKey.currentContext;
// // // // // // // // //             if (context == null) {
// // // // // // // // //               debug("  Context is null, cannot navigate");
// // // // // // // // //               // Try again after delay
// // // // // // // // //               Future.delayed(const Duration(milliseconds: 500), () {
// // // // // // // // //                 _processDeepLink();
// // // // // // // // //               });
// // // // // // // // //               return;
// // // // // // // // //             }

// // // // // // // // //             // Check if we're already on chat screen
// // // // // // // // //             final currentRoute = ModalRoute.of(context);
// // // // // // // // //             if (currentRoute?.settings.name?.contains('chat') == true) {
// // // // // // // // //               debug(" Already on chat screen, skipping navigation");
// // // // // // // // //               pendingDeepLink = null;
// // // // // // // // //               return;
// // // // // // // // //             }

// // // // // // // // //             debug("🚀 Navigating to chat screen with:");
// // // // // // // // //             debug("   Lead Phone: $leadPhone");
// // // // // // // // //             debug("   WhatsApp Setting Number: $whatsappSettingNumber");
// // // // // // // // //             debug("   Lead Name: $leadName");

// // // // // // // // //             Navigator.push(
// // // // // // // // //               context,
// // // // // // // // //               MaterialPageRoute(
// // // // // // // // //                 builder: (_) => WhatsappChatScreen(
// // // // // // // // //                   leadName: leadName,
// // // // // // // // //                   wpnumber: leadPhone, // Use lead phone as wpnumber
// // // // // // // // //                   id: whatsappSettingNumber, // Use whatsapp setting number as id
// // // // // // // // //                 ),
// // // // // // // // //               ),
// // // // // // // // //             );

// // // // // // // // //             pendingDeepLink = null;
// // // // // // // // //           } catch (e) {
// // // // // // // // //             debug("  Navigation error: $e");
// // // // // // // // //           }
// // // // // // // // //         });
// // // // // // // // //       } else {
// // // // // // // // //         // Handle other deep link patterns
// // // // // // // // //         final params = uri.queryParameters;
// // // // // // // // //         String leadName = params['name'] ?? 'WatConnect User';
// // // // // // // // //         String wpnumber = params['number'] ?? '';
// // // // // // // // //         final id = params['id'];

// // // // // // // // //         // If phone number is empty, try to extract from token
// // // // // // // // //         if (wpnumber.isEmpty) {
// // // // // // // // //           wpnumber = await _extractPhoneNumberFromToken();
// // // // // // // // //         }

// // // // // // // // //         if (wpnumber.isNotEmpty) {
// // // // // // // // //           WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // // // //             try {
// // // // // // // // //               final context = navigatorKey.currentContext;
// // // // // // // // //               if (context == null) {
// // // // // // // // //                 debug("  Context is null, cannot navigate");
// // // // // // // // //                 Future.delayed(const Duration(milliseconds: 500), () {
// // // // // // // // //                   _processDeepLink();
// // // // // // // // //                 });
// // // // // // // // //                 return;
// // // // // // // // //               }

// // // // // // // // //               Navigator.push(
// // // // // // // // //                 context,
// // // // // // // // //                 MaterialPageRoute(
// // // // // // // // //                   builder: (_) => WhatsappChatScreen(
// // // // // // // // //                     leadName: leadName,
// // // // // // // // //                     wpnumber: wpnumber,
// // // // // // // // //                     id: id ?? '',
// // // // // // // // //                   ),
// // // // // // // // //                 ),
// // // // // // // // //               );

// // // // // // // // //               pendingDeepLink = null;
// // // // // // // // //             } catch (e) {
// // // // // // // // //               debug("  Navigation error: $e");
// // // // // // // // //             }
// // // // // // // // //           });
// // // // // // // // //         }
// // // // // // // // //       }
// // // // // // // // //     } catch (e) {
// // // // // // // // //       debug("  Error processing deep link: $e");
// // // // // // // // //     }
// // // // // // // // //   }

// // // // // // // // //   /// 🔹 Get user data from stored tokens
// // // // // // // // //   Future<Map<String, String>> _getUserDataFromTokens() async {
// // // // // // // // //     final Map<String, String> userData = {
// // // // // // // // //       'leadName': 'WatConnect User',
// // // // // // // // //       'phone': ''
// // // // // // // // //     };

// // // // // // // // //     try {
// // // // // // // // //       final prefs = await SharedPreferences.getInstance();

// // // // // // // // //       // Get access token
// // // // // // // // //       final accessToken = prefs.getString(SharedPrefsConstants.accessTokenKey);
// // // // // // // // //       final sfAccessToken = prefs.getString(SharedPrefsConstants.sfAccessToken);
// // // // // // // // //       final userKey = prefs.getString(SharedPrefsConstants.userKey);

// // // // // // // // //       debug("🔑 Tokens found:");
// // // // // // // // //       debug("   Access Token: ${accessToken?.substring(0, 20)}...");
// // // // // // // // //       debug("   SF Access Token: ${sfAccessToken?.substring(0, 20)}...");
// // // // // // // // //       debug("   User Key: ${userKey?.substring(0, 20)}...");

// // // // // // // // //       // Extract lead name from user data if available
// // // // // // // // //       if (userKey != null && userKey.isNotEmpty) {
// // // // // // // // //         try {
// // // // // // // // //           // Parse user data to extract name
// // // // // // // // //           if (userKey.contains('"name"')) {
// // // // // // // // //             final regex = RegExp(r'"name":\s*"([^"]+)"');
// // // // // // // // //             final match = regex.firstMatch(userKey);
// // // // // // // // //             if (match != null && match.group(1) != null) {
// // // // // // // // //               userData['leadName'] = match.group(1)!;
// // // // // // // // //             }
// // // // // // // // //           } else if (userKey.contains('"firstName"')) {
// // // // // // // // //             final regex = RegExp(r'"firstName":\s*"([^"]+)"');
// // // // // // // // //             final match = regex.firstMatch(userKey);
// // // // // // // // //             if (match != null && match.group(1) != null) {
// // // // // // // // //               userData['leadName'] = match.group(1)!;
// // // // // // // // //             }
// // // // // // // // //           }
// // // // // // // // //         } catch (e) {
// // // // // // // // //           debug("  Error parsing user data: $e");
// // // // // // // // //         }
// // // // // // // // //       }

// // // // // // // // //       // Extract phone number if needed
// // // // // // // // //       userData['phone'] = await _extractPhoneNumberFromToken();

// // // // // // // // //       return userData;
// // // // // // // // //     } catch (e) {
// // // // // // // // //       debug("  Error getting user data from tokens: $e");
// // // // // // // // //       return userData;
// // // // // // // // //     }
// // // // // // // // //   }

// // // // // // // // //   /// 🔹 Extract phone number from stored token
// // // // // // // // //   Future<String> _extractPhoneNumberFromToken() async {
// // // // // // // // //     try {
// // // // // // // // //       final prefs = await SharedPreferences.getInstance();

// // // // // // // // //       // Try to get phone number from various possible storage locations
// // // // // // // // //       String phoneNumber = prefs.getString('user_phone') ??
// // // // // // // // //           prefs.getString('phone_number') ??
// // // // // // // // //           prefs.getString('wp_number') ??
// // // // // // // // //           prefs.getString('lead_phone') ??
// // // // // // // // //           '';

// // // // // // // // //       // If not found in prefs, try to extract from user data
// // // // // // // // //       if (phoneNumber.isEmpty) {
// // // // // // // // //         final userData = prefs.getString(SharedPrefsConstants.userKey);
// // // // // // // // //         if (userData != null && userData.isNotEmpty) {
// // // // // // // // //           phoneNumber = _extractPhoneFromUserData(userData);
// // // // // // // // //         }
// // // // // // // // //       }

// // // // // // // // //       // If still empty, try access token
// // // // // // // // //       if (phoneNumber.isEmpty) {
// // // // // // // // //         final accessToken =
// // // // // // // // //             prefs.getString(SharedPrefsConstants.accessTokenKey);
// // // // // // // // //         debug(
// // // // // // // // //             "Access Token for phone extraction: ${accessToken?.substring(0, 20)}...");
// // // // // // // // //         if (accessToken != null && accessToken.isNotEmpty) {
// // // // // // // // //           phoneNumber = _extractPhoneFromAccessToken(accessToken);
// // // // // // // // //           debug("Extracted phone from access token: $phoneNumber");
// // // // // // // // //         }
// // // // // // // // //       }

// // // // // // // // //       debug(
// // // // // // // // //           " Extracted phone number from token: ${phoneNumber.isNotEmpty ? phoneNumber : 'Not found'}");
// // // // // // // // //       return phoneNumber;
// // // // // // // // //     } catch (e) {
// // // // // // // // //       debug("  Error extracting phone number from token: $e");
// // // // // // // // //       return '';
// // // // // // // // //     }
// // // // // // // // //   }

// // // // // // // // //   /// 🔹 Extract phone number from user data string
// // // // // // // // //   String _extractPhoneFromUserData(String userData) {
// // // // // // // // //     try {
// // // // // // // // //       // Try different patterns for phone number
// // // // // // // // //       final patterns = [
// // // // // // // // //         r'"phone":\s*"([^"]+)"',
// // // // // // // // //         r'"mobile":\s*"([^"]+)"',
// // // // // // // // //         r'"phoneNumber":\s*"([^"]+)"',
// // // // // // // // //         r'"contact":\s*"([^"]+)"',
// // // // // // // // //         r'"whatsapp":\s*"([^"]+)"',
// // // // // // // // //       ];

// // // // // // // // //       for (var pattern in patterns) {
// // // // // // // // //         final regex = RegExp(pattern);
// // // // // // // // //         final match = regex.firstMatch(userData);
// // // // // // // // //         if (match != null &&
// // // // // // // // //             match.group(1) != null &&
// // // // // // // // //             match.group(1)!.isNotEmpty) {
// // // // // // // // //           return match.group(1)!;
// // // // // // // // //         }
// // // // // // // // //       }
// // // // // // // // //       return '';
// // // // // // // // //     } catch (e) {
// // // // // // // // //       debug("  Error extracting phone from user data: $e");
// // // // // // // // //       return '';
// // // // // // // // //     }
// // // // // // // // //   }

// // // // // // // // //   String _extractPhoneFromAccessToken(String accessToken) {
// // // // // // // // //     try {
// // // // // // // // //       debug(" Extracting phone from access token payload $accessToken");
// // // // // // // // //       if (accessToken.contains('.')) {
// // // // // // // // //         final parts = accessToken.split('.');
// // // // // // // // //         if (parts.length >= 2) {
// // // // // // // // //           final payload = parts[1];
// // // // // // // // //           debug("  Extracting phone from access token payload$payload");
// // // // // // // // //           if (payload.contains('phone') || payload.contains('mobile')) {
// // // // // // // // //             final regex = RegExp(r'phone[^:]*:\s*"([^"]+)"');
// // // // // // // // //             final match = regex.firstMatch(payload);
// // // // // // // // //             if (match != null && match.group(1) != null) {
// // // // // // // // //               return match.group(1)!;
// // // // // // // // //             }
// // // // // // // // //           }
// // // // // // // // //         }
// // // // // // // // //       }
// // // // // // // // //       return '';
// // // // // // // // //     } catch (e) {
// // // // // // // // //       debug("  Error extracting phone from access token: $e");
// // // // // // // // //       return '';
// // // // // // // // //     }
// // // // // // // // //   }

// // // // // // // // //   void _onProvidersReady() {
// // // // // // // // //     try {
// // // // // // // // //       if (!_areProvidersReady && mounted) {
// // // // // // // // //         setState(() {
// // // // // // // // //           _areProvidersReady = true;
// // // // // // // // //         });
// // // // // // // // //         _checkAndProcessDeepLink();
// // // // // // // // //       }
// // // // // // // // //     } catch (e) {
// // // // // // // // //       debug("  Error in onProvidersReady: $e");
// // // // // // // // //     }
// // // // // // // // //   }

// // // // // // // // //   @override
// // // // // // // // //   void dispose() {
// // // // // // // // //     _linkSubscription?.cancel();
// // // // // // // // //     super.dispose();
// // // // // // // // //   }

// // // // // // // // //   @override
// // // // // // // // //   Widget build(BuildContext context) {

// // // // // // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // // // //       _onProvidersReady();
// // // // // // // // //     });

// // // // // // // // //     SystemChrome.setSystemUIOverlayStyle(
// // // // // // // // //       const SystemUiOverlayStyle(
// // // // // // // // //         statusBarColor: Colors.transparent,
// // // // // // // // //         statusBarIconBrightness: Brightness.dark,
// // // // // // // // //         statusBarBrightness: Brightness.light,
// // // // // // // // //       ),
// // // // // // // // //     );

// // // // // // // // //     SystemChrome.setPreferredOrientations([
// // // // // // // // //       DeviceOrientation.portraitUp,
// // // // // // // // //       DeviceOrientation.portraitDown,
// // // // // // // // //     ]);

// // // // // // // // //     return MultiProvider(
// // // // // // // // //       providers: [
// // // // // // // // //         ChangeNotifierProvider(
// // // // // // // // //             create: (_) => ApprovedTemplateViewModel(context)),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => UnreadCountVm(context)),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => GroupsViewModel(context)),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => MessageViewModel(context)),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => CampaignChartViewModel(context)),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => LeadListViewModel(context)),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => TagsListViewModel(context)),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => CampaignViewModel(context)),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => MeesageHistoryViewModel(context)),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => LeadCountViewModel(context)),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => TempleteListViewModel(context)),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => AutoResponseViewModel(context)),
// // // // // // // // //         ChangeNotifierProvider(
// // // // // // // // //             create: (_) => WhatsappSettingViewModel(context)),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => CampaignCountViewModel(context)),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => ChartListViewModel(context)),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => GetUserViewModel(context)),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => UserDataListViewModel(context)),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => MessageController()),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => DashBoardController()),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => TemplateController()),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => BusinessNumberController()),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => CallsViewModel(context)),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => ChatMessageController()),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => SfcampaignController()),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => WalletController()),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => LeadController()),
// // // // // // // // //         ChangeNotifierProvider(create: (_) => SfFileUploadController()),
// // // // // // // // //       ],
// // // // // // // // //       child: Builder(
// // // // // // // // //         builder: (context) {
// // // // // // // // //           // Ensure providers are initialized
// // // // // // // // //           WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // // // //             _onProvidersReady();
// // // // // // // // //           });

// // // // // // // // //           return MaterialApp(
// // // // // // // // //             debugShowCheckedModeBanner: false,
// // // // // // // // //             navigatorKey: navigatorKey,
// // // // // // // // //             navigatorObservers: [routeObserver],
// // // // // // // // //             title: 'WatConnect',
// // // // // // // // //             theme: ThemeData(
// // // // // // // // //               textTheme: GoogleFonts.kohSantepheapTextTheme(),
// // // // // // // // //               primaryColor: AppColor.navBarIconColor,
// // // // // // // // //               appBarTheme: const AppBarTheme(
// // // // // // // // //                 backgroundColor: AppColor.navBarIconColor,
// // // // // // // // //               ),
// // // // // // // // //             ),
// // // // // // // // //             builder: EasyLoading.init(),
// // // // // // // // //             home: const SplashView(),
// // // // // // // // //           );
// // // // // // // // //         },
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // // }
// // // // // // // import 'dart:convert';
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
// // // // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // // // // import 'package:timezone/data/latest.dart' as tz;
// // // // // // // import 'package:whatsapp/utils/app_constants.dart';

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
// // // // // // //   WidgetsFlutterBinding.ensureInitialized();

// // // // // // //   try {
// // // // // // //     tz.initializeTimeZones();

// // // // // // //     await Firebase.initializeApp(
// // // // // // //       options: DefaultFirebaseOptions.currentPlatform,
// // // // // // //     );

// // // // // // //     FirebaseMessaging.onBackgroundMessage(
// // // // // // //       firebaseMessagingBackgroundHandler,
// // // // // // //     );

// // // // // // //     await NotificationService.init();

// // // // // // //     runApp(const MyApp());
// // // // // // //     await NotificationService.handleInitialMessage();
// // // // // // //   } catch (e) {
// // // // // // //     debug("  Error in main(): $e");
// // // // // // //     // You might want to show an error screen here
// // // // // // //     runApp(
// // // // // // //       MaterialApp(
// // // // // // //         home: Scaffold(
// // // // // // //           body: Center(
// // // // // // //             child: Text('App initialization failed: $e'),
// // // // // // //           ),
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }

// // // // // // // class MyApp extends StatefulWidget {
// // // // // // //   const MyApp({super.key});

// // // // // // //   @override
// // // // // // //   State<MyApp> createState() => _MyAppState();
// // // // // // // }

// // // // // // // class _MyAppState extends State<MyApp> {
// // // // // // //   late final AppLinks _appLinks;
// // // // // // //   StreamSubscription<Uri>? _linkSubscription;
// // // // // // //   bool _isAppInitialized = false;
// // // // // // //   bool _areProvidersReady = false;

// // // // // // //   @override
// // // // // // //   void initState() {
// // // // // // //     super.initState();

// // // // // // //     try {
// // // // // // //       debug("🚀 AppLinks initialized");
// // // // // // //       _appLinks = AppLinks();
// // // // // // //       _handleInitialUri();
// // // // // // //       _listenToUriStream();

// // // // // // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // //         if (mounted) {
// // // // // // //           setState(() {
// // // // // // //             _isAppInitialized = true;
// // // // // // //           });
// // // // // // //           _checkAndProcessDeepLink();
// // // // // // //         }
// // // // // // //       });
// // // // // // //     } catch (e) {
// // // // // // //       debug("  Error in MyApp initState: $e");
// // // // // // //     }
// // // // // // //   }

// // // // // // //   Future<void> _handleInitialUri() async {
// // // // // // //     try {
// // // // // // //       final Uri? initialUri = await _appLinks.getInitialLink();
// // // // // // //       debug("📌 Initial URI => $initialUri");

// // // // // // //       if (initialUri != null) {
// // // // // // //         pendingDeepLink = initialUri;
// // // // // // //         _checkAndProcessDeepLink();
// // // // // // //       }
// // // // // // //     } catch (e) {
// // // // // // //       debug("  Initial URI error: $e");
// // // // // // //     }
// // // // // // //   }

// // // // // // //   void _listenToUriStream() {
// // // // // // //     _linkSubscription = _appLinks.uriLinkStream.listen(
// // // // // // //       (Uri uri) {
// // // // // // //         debug("🔗 Stream URI => $uri");
// // // // // // //         pendingDeepLink = uri;
// // // // // // //         _checkAndProcessDeepLink();
// // // // // // //       },
// // // // // // //       onError: (err) {
// // // // // // //         debug("  URI Stream error: $err");
// // // // // // //       },
// // // // // // //     );
// // // // // // //   }

// // // // // // //   /// 🔹 Check conditions and process deep link
// // // // // // //   void _checkAndProcessDeepLink() {
// // // // // // //     try {
// // // // // // //       if (pendingDeepLink == null ||
// // // // // // //           !_isAppInitialized ||
// // // // // // //           !_areProvidersReady) {
// // // // // // //         debug("⏳ Skipping deep link - conditions not met");
// // // // // // //         return;
// // // // // // //       }

// // // // // // //       _processDeepLink();
// // // // // // //     } catch (e) {
// // // // // // //       debug("  Error in checkAndProcessDeepLink: $e");
// // // // // // //     }
// // // // // // //   }

// // // // // // //   /// 🔹 Extract phone numbers from URL path and query parameters
// // // // // // //   Map<String, String> _extractPhoneNumbersFromUri(Uri uri) {
// // // // // // //     final Map<String, String> phoneNumbers = {
// // // // // // //       'leadPhone': '',
// // // // // // //       'whatsappSettingNumber': ''
// // // // // // //     };

// // // // // // //     try {
// // // // // // //       debug("  Extracting phone numbers from URI: $uri");

// // // // // // //       // Extract lead phone from path (e.g., /message/history/+917740989118)
// // // // // // //       final pathSegments = uri.pathSegments;
// // // // // // //       for (var segment in pathSegments) {
// // // // // // //         if (segment.startsWith('+') && segment.length > 10) {
// // // // // // //           phoneNumbers['leadPhone'] = segment;
// // // // // // //           debug(" Found lead phone in path: ${phoneNumbers['leadPhone']}");
// // // // // // //           break;
// // // // // // //         }
// // // // // // //       }

// // // // // // //       // Extract whatsapp_setting_number from query parameters
// // // // // // //       final queryParams = uri.queryParameters;
// // // // // // //       if (queryParams.containsKey('whatsapp_setting_number')) {
// // // // // // //         phoneNumbers['whatsappSettingNumber'] =
// // // // // // //             queryParams['whatsapp_setting_number']!;
// // // // // // //         debug(
// // // // // // //             " Found whatsapp setting number: ${phoneNumbers['whatsappSettingNumber']}");
// // // // // // //       }

// // // // // // //       // If not found in query, try to extract from full URL
// // // // // // //       if (phoneNumbers['whatsappSettingNumber']!.isEmpty) {
// // // // // // //         final urlString = uri.toString();
// // // // // // //         final regex = RegExp(r'whatsapp_setting_number=(\+?\d+)');
// // // // // // //         final match = regex.firstMatch(urlString);
// // // // // // //         if (match != null && match.group(1) != null) {
// // // // // // //           phoneNumbers['whatsappSettingNumber'] = match.group(1)!;
// // // // // // //           debug(
// // // // // // //               " Extracted whatsapp setting number from URL: ${phoneNumbers['whatsappSettingNumber']}");
// // // // // // //         }
// // // // // // //       }

// // // // // // //       return phoneNumbers;
// // // // // // //     } catch (e) {
// // // // // // //       debug("  Error extracting phone numbers: $e");
// // // // // // //       return phoneNumbers;
// // // // // // //     }
// // // // // // //   }

// // // // // // //   /// 🔹 Process deep link after providers ready
// // // // // // // //   void _processDeepLink() async {
// // // // // // // //     try {
// // // // // // // //       if (pendingDeepLink == null) {
// // // // // // // //         debug(" No pending deep link to process");
// // // // // // // //         return;
// // // // // // // //       }

// // // // // // // //       final uri = pendingDeepLink!;
// // // // // // // //       debug("➡️ Processing DeepLink: $uri");

// // // // // // // //       // Check if this is your API URL pattern
// // // // // // // //       final isMessageHistoryUrl =
// // // // // // // //           uri.toString().contains('/api/whatsapp/message/history/');
// // // // // // // // debug("isMessageHistoryUrlisMessageHistoryUrl$isMessageHistoryUrl");
// // // // // // // //       if (isMessageHistoryUrl) {
// // // // // // // //         // Extract phone numbers from URL
// // // // // // // //         final phoneNumbers = _extractPhoneNumbersFromUri(uri);
// // // // // // // //         debug("phoneNumbersphoneNumbersphoneNumbers$phoneNumbers");
// // // // // // // //         String leadPhone = phoneNumbers['leadPhone'] ?? '';
// // // // // // // //         final whatsappSettingNumber =
// // // // // // // //             phoneNumbers['whatsappSettingNumber'] ?? '';

// // // // // // // //         // Get user data from stored tokens
// // // // // // // //         final userData = await _getUserDataFromTokens();
// // // // // // // //         debug("userDatauserDatauserData$userData");
// // // // // // // //         final leadName = userData['leadName'] ?? 'WatConnect User';

// // // // // // // //         // Get user's whatsapp number from token
// // // // // // // //         final userWhatsappNumber = userData['whatsappNumber'] ?? '';

// // // // // // // //         // If lead phone is empty but we have user's whatsapp number, use that
// // // // // // // //         if (leadPhone.isEmpty && userWhatsappNumber.isNotEmpty) {
// // // // // // // //           leadPhone = userWhatsappNumber;
// // // // // // // //           debug(" Using user's whatsapp number as lead phone: $leadPhone");
// // // // // // // //         }

// // // // // // // //         if (leadPhone.isEmpty) {
// // // // // // // //           debug("  Lead phone number not found in URL or tokens");
// // // // // // // //           return;
// // // // // // // //         }

// // // // // // // //         // Navigate to chat screen
// // // // // // // //         WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // // //           try {
// // // // // // // //             final context = navigatorKey.currentContext;
// // // // // // // //             if (context == null) {
// // // // // // // //               debug("  Context is null, cannot navigate");
// // // // // // // //               // Try again after delay
// // // // // // // //               Future.delayed(const Duration(milliseconds: 500), () {
// // // // // // // //                 _processDeepLink();
// // // // // // // //               });
// // // // // // // //               return;
// // // // // // // //             }

// // // // // // // //             // Check if we're already on chat screen
// // // // // // // //             final currentRoute = ModalRoute.of(context);
// // // // // // // //             if (currentRoute?.settings.name?.contains('chat') == true) {
// // // // // // // //               debug(" Already on chat screen, skipping navigation");
// // // // // // // //               pendingDeepLink = null;
// // // // // // // //               return;
// // // // // // // //             }

// // // // // // // //             debug("🚀 Navigating to chat screen with:");
// // // // // // // //             debug("   Lead Phone: $leadPhone");
// // // // // // // //             debug("   WhatsApp Setting Number: $whatsappSettingNumber");
// // // // // // // //             debug("   Lead Name: $leadName");
// // // // // // // //             debug("   User WhatsApp Number: $userWhatsappNumber");

// // // // // // // //             Navigator.push(
// // // // // // // //               context,
// // // // // // // //               MaterialPageRoute(
// // // // // // // //                 builder: (_) => WhatsappChatScreen(
// // // // // // // //                   leadName: leadName,
// // // // // // // //                   wpnumber: leadPhone, // Use lead phone as wpnumber
// // // // // // // //                   id: whatsappSettingNumber, // Use whatsapp setting number as id
// // // // // // // //                 ),
// // // // // // // //               ),
// // // // // // // //             );

// // // // // // // //             pendingDeepLink = null;
// // // // // // // //           } catch (e) {
// // // // // // // //             debug("  Navigation error: $e");
// // // // // // // //           }
// // // // // // // //         });
// // // // // // // //       } else {
// // // // // // // //         // Handle other deep link patterns
// // // // // // // //         final params = uri.queryParameters;
// // // // // // // //         String leadName = params['name'] ?? 'WatConnect User';
// // // // // // // //         String wpnumber = params['number'] ?? '';
// // // // // // // //         final id = params['id'];

// // // // // // // //         // If phone number is empty, try to extract from token
// // // // // // // //         if (wpnumber.isEmpty) {
// // // // // // // //           final userData = await _getUserDataFromTokens();
// // // // // // // //           wpnumber = userData['whatsappNumber'] ?? '';
// // // // // // // //         }

// // // // // // // //         if (wpnumber.isNotEmpty) {
// // // // // // // //           WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // // //             try {
// // // // // // // //               final context = navigatorKey.currentContext;
// // // // // // // //               if (context == null) {
// // // // // // // //                 debug("  Context is null, cannot navigate");
// // // // // // // //                 Future.delayed(const Duration(milliseconds: 500), () {
// // // // // // // //                   _processDeepLink();
// // // // // // // //                 });
// // // // // // // //                 return;
// // // // // // // //               }

// // // // // // // //               Navigator.push(
// // // // // // // //                 context,
// // // // // // // //                 MaterialPageRoute(
// // // // // // // //                   builder: (_) => WhatsappChatScreen(
// // // // // // // //                     leadName: leadName,
// // // // // // // //                     wpnumber: wpnumber,
// // // // // // // //                     id: id ?? '',
// // // // // // // //                   ),
// // // // // // // //                 ),
// // // // // // // //               );

// // // // // // // //               pendingDeepLink = null;
// // // // // // // //             } catch (e) {
// // // // // // // //               debug("  Navigation error: $e");
// // // // // // // //             }
// // // // // // // //           });
// // // // // // // //         }
// // // // // // // //       }
// // // // // // // //     } catch (e) {
// // // // // // // //       debug("  Error processing deep link: $e");
// // // // // // // //     }
// // // // // // // //   }
// // // // // // //   void _processDeepLink() async {
// // // // // // //     try {
// // // // // // //       if (pendingDeepLink == null) {
// // // // // // //         debug(" No pending deep link to process");
// // // // // // //         return;
// // // // // // //       }

// // // // // // //       final uri = pendingDeepLink!;
// // // // // // //       final uriString = uri.toString();
// // // // // // //       debug("➡️ Processing DeepLink: $uriString");

// // // // // // //       // DIRECT NAVIGATION WITHOUT CHECKS
// // // // // // //       final String leadPhone = "+917740989118";
// // // // // // //       final String whatsappSettingNumber = "918306524244";

// // // // // // //       debug("🚀 NAVIGATING WITH STATIC VALUES:");
// // // // // // //       debug("   Lead Phone: $leadPhone");
// // // // // // //       debug("   WhatsApp Setting Number: $whatsappSettingNumber");

// // // // // // //       // Get user data
// // // // // // //       final userData = await _getUserDataFromTokens();
// // // // // // //       final String leadName = userData['leadName'] ?? 'WatConnect User';

// // // // // // //       debug("👤 User Name: $leadName");

// // // // // // //       // Navigate immediately - no conditions
// // // // // // //       _navigateToChatScreen(leadName, leadPhone, whatsappSettingNumber);
// // // // // // //     } catch (e) {
// // // // // // //       debug("  Error in _processDeepLink: $e");
// // // // // // //     }
// // // // // // //   }

// // // // // // //   /// Navigate to chat screen
// // // // // // //   void _navigateToChatScreen(
// // // // // // //       String leadName, String leadPhone, String whatsappSettingNumber) {
// // // // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // //       try {
// // // // // // //         final context = navigatorKey.currentContext;
// // // // // // //         if (context == null) {
// // // // // // //           debug("  Context is null, retrying in 500ms...");
// // // // // // //           // Retry after delay
// // // // // // //           Future.delayed(const Duration(milliseconds: 500), () {
// // // // // // //             _navigateToChatScreen(leadName, leadPhone, whatsappSettingNumber);
// // // // // // //           });
// // // // // // //           return;
// // // // // // //         }

// // // // // // //         // Check if already on chat screen
// // // // // // //         final currentRoute = ModalRoute.of(context);
// // // // // // //         if (currentRoute?.settings.name?.contains('chat') == true) {
// // // // // // //           debug(" Already on chat screen");
// // // // // // //           pendingDeepLink = null;
// // // // // // //           return;
// // // // // // //         }

// // // // // // //         debug("  Navigating to WhatsappChatScreen");

// // // // // // //         Navigator.push(
// // // // // // //           context,
// // // // // // //           MaterialPageRoute(
// // // // // // //             builder: (_) => WhatsappChatScreen(
// // // // // // //               leadName: leadName,
// // // // // // //               wpnumber: leadPhone,
// // // // // // //               id: whatsappSettingNumber,
// // // // // // //             ),
// // // // // // //           ),
// // // // // // //         );

// // // // // // //         pendingDeepLink = null;
// // // // // // //         debug("🎉 Navigation successful!");
// // // // // // //       } catch (e) {
// // // // // // //         debug("  Navigation error: $e");
// // // // // // //       }
// // // // // // //     });
// // // // // // //   }

// // // // // // //   /// Get user data from stored tokens
// // // // // // //   Future<Map<String, String>> _getUserDataFromTokens() async {
// // // // // // //     final Map<String, String> userData = {
// // // // // // //       'leadName': 'WatConnect User',
// // // // // // //       'whatsappNumber': ''
// // // // // // //     };

// // // // // // //     try {
// // // // // // //       final prefs = await SharedPreferences.getInstance();
// // // // // // //       final userKey = prefs.getString(SharedPrefsConstants.userKey);

// // // // // // //       if (userKey != null && userKey.isNotEmpty) {
// // // // // // //         try {
// // // // // // //           // Parse the JSON
// // // // // // //           final Map<String, dynamic> jsonData = json.decode(userKey);

// // // // // // //           // Check if it has authToken
// // // // // // //           if (jsonData['authToken'] != null) {
// // // // // // //             final String authToken = jsonData['authToken'].toString();
// // // // // // //             debug("  Found authToken");

// // // // // // //             // Decode JWT
// // // // // // //             final Map<String, dynamic>? decodedToken =
// // // // // // //                 _decodeJWTToken(authToken);
// // // // // // //             if (decodedToken != null) {
// // // // // // //               userData['leadName'] = decodedToken['username']?.toString() ??
// // // // // // //                   decodedToken['email']?.toString().split('@').first ??
// // // // // // //                   'WatConnect User';

// // // // // // //               // Extract whatsapp number
// // // // // // //               if (decodedToken['whatsapp_number'] != null) {
// // // // // // //                 String number = decodedToken['whatsapp_number'].toString();
// // // // // // //                 String countryCode =
// // // // // // //                     decodedToken['country_code']?.toString() ?? '+91';

// // // // // // //                 if (!number.startsWith('+')) {
// // // // // // //                   number = '$countryCode$number';
// // // // // // //                 }
// // // // // // //                 userData['whatsappNumber'] = number;
// // // // // // //               }
// // // // // // //             }
// // // // // // //           } else if (jsonData['username'] != null) {
// // // // // // //             // Direct data (not JWT)
// // // // // // //             userData['leadName'] = jsonData['username'].toString();
// // // // // // //           }
// // // // // // //         } catch (e) {
// // // // // // //           debug(" JSON parse failed: $e");
// // // // // // //           // String extraction fallback
// // // // // // //           if (userKey.contains('username')) {
// // // // // // //             final regex = RegExp(r'"username":\s*"([^"]+)"');
// // // // // // //             final match = regex.firstMatch(userKey);
// // // // // // //             if (match != null && match.group(1) != null) {
// // // // // // //               userData['leadName'] = match.group(1)!;
// // // // // // //             }
// // // // // // //           }
// // // // // // //         }
// // // // // // //       }

// // // // // // //       debug("👤 User Data: ${userData['leadName']}");
// // // // // // //       return userData;
// // // // // // //     } catch (e) {
// // // // // // //       debug("  Error getting user data: $e");
// // // // // // //       return userData;
// // // // // // //     }
// // // // // // //   }

// // // // // // //   /// Decode JWT token
// // // // // // //   Map<String, dynamic>? _decodeJWTToken(String token) {
// // // // // // //     try {
// // // // // // //       final parts = token.split('.');
// // // // // // //       if (parts.length != 3) {
// // // // // // //         debug("  Invalid JWT format");
// // // // // // //         return null;
// // // // // // //       }

// // // // // // //       String payload = parts[1];
// // // // // // //       while (payload.length % 4 != 0) {
// // // // // // //         payload += '=';
// // // // // // //       }

// // // // // // //       final decoded = utf8.decode(base64Url.decode(payload));
// // // // // // //       return json.decode(decoded);
// // // // // // //     } catch (e) {
// // // // // // //       debug("  JWT decode failed: $e");
// // // // // // //       return null;
// // // // // // //     }
// // // // // // //   }
// // // // // // //   // Future<Map<String, String>> _getUserDataFromTokens() async {
// // // // // // //   //   final Map<String, String> userData = {
// // // // // // //   //     'leadName': 'WatConnect User',
// // // // // // //   //     'whatsappNumber': '',
// // // // // // //   //     'phone': ''
// // // // // // //   //   };

// // // // // // //   //   try {
// // // // // // //   //     final prefs = await SharedPreferences.getInstance();

// // // // // // //   //     // Get access token
// // // // // // //   //     final accessToken = prefs.getString(SharedPrefsConstants.accessTokenKey);
// // // // // // //   //     final sfAccessToken = prefs.getString(SharedPrefsConstants.sfAccessToken);
// // // // // // //   //     final userKey = prefs.getString(SharedPrefsConstants.userKey);

// // // // // // //   //     debug("🔑 Tokens found:");
// // // // // // //   //     debug("   Access Token: ${accessToken?.substring(0, min(20, accessToken?.length ?? 0))}...");
// // // // // // //   //     debug("   SF Access Token: ${sfAccessToken?.substring(0, min(20, sfAccessToken?.length ?? 0))}...");
// // // // // // //   //     debug("   User Key: ${userKey?.substring(0, min(20, userKey?.length ?? 0))}...");

// // // // // // //   //     // Extract user data from userKey (which contains your JSON)
// // // // // // //   //     if (userKey != null && userKey.isNotEmpty) {
// // // // // // //   //       try {
// // // // // // //   //         debug("  Parsing user JSON data");

// // // // // // //   //         // Parse the JSON
// // // // // // //   //         final Map<String, dynamic> userJson = json.decode(userKey);

// // // // // // //   //         // Extract username
// // // // // // //   //         if (userJson['username'] != null) {
// // // // // // //   //           userData['leadName'] = userJson['username'].toString();
// // // // // // //   //           debug("👤 Found username: ${userData['leadName']}");
// // // // // // //   //         } else if (userJson['email'] != null) {
// // // // // // //   //           userData['leadName'] = userJson['email'].toString().split('@').first;
// // // // // // //   //         }

// // // // // // //   //         // Extract whatsapp_number - THIS IS THE KEY FIELD
// // // // // // //   //         if (userJson['whatsapp_number'] != null) {
// // // // // // //   //           String whatsappNumber = userJson['whatsapp_number'].toString();
// // // // // // //   //           String countryCode = userJson['country_code']?.toString() ?? '+91';

// // // // // // //   //           // Add country code if not already present
// // // // // // //   //           if (!whatsappNumber.startsWith('+')) {
// // // // // // //   //             whatsappNumber = '$countryCode$whatsappNumber';
// // // // // // //   //           }

// // // // // // //   //           userData['whatsappNumber'] = whatsappNumber;
// // // // // // //   //           debug(" Found whatsapp_number: ${userData['whatsappNumber']}");
// // // // // // //   //         }

// // // // // // //   //         // Also extract phone for backward compatibility
// // // // // // //   //         if (userJson['phone'] != null) {
// // // // // // //   //           userData['phone'] = userJson['phone'].toString();
// // // // // // //   //         } else if (userJson['mobile'] != null) {
// // // // // // //   //           userData['phone'] = userJson['mobile'].toString();
// // // // // // //   //         }

// // // // // // //   //       } catch (e) {
// // // // // // //   //         debug("  Error parsing user JSON: $e");

// // // // // // //   //         // Fallback: try to extract from string if JSON parsing fails
// // // // // // //   //         if (userKey.contains('whatsapp_number')) {
// // // // // // //   //           final regex = RegExp(r'"whatsapp_number":\s*"([^"]+)"');
// // // // // // //   //           final match = regex.firstMatch(userKey);
// // // // // // //   //           if (match != null && match.group(1) != null) {
// // // // // // //   //             userData['whatsappNumber'] = '+91${match.group(1)!}';
// // // // // // //   //             debug(" Extracted whatsapp_number from string: ${userData['whatsappNumber']}");
// // // // // // //   //           }
// // // // // // //   //         }

// // // // // // //   //         if (userKey.contains('username')) {
// // // // // // //   //           final regex = RegExp(r'"username":\s*"([^"]+)"');
// // // // // // //   //           final match = regex.firstMatch(userKey);
// // // // // // //   //           if (match != null && match.group(1) != null) {
// // // // // // //   //             userData['leadName'] = match.group(1)!;
// // // // // // //   //           }
// // // // // // //   //         }
// // // // // // //   //       }
// // // // // // //   //     }

// // // // // // //   //     // If whatsapp number still empty, try other sources
// // // // // // //   //     if (userData['whatsappNumber']!.isEmpty) {
// // // // // // //   //       userData['whatsappNumber'] = await _extractPhoneNumberFromToken();
// // // // // // //   //     }

// // // // // // //   //     return userData;
// // // // // // //   //   } catch (e) {
// // // // // // //   //     debug("  Error getting user data from tokens: $e");
// // // // // // //   //     return userData;
// // // // // // //   //   }
// // // // // // //   // }

// // // // // // //   int min(int a, int b) => a < b ? a : b;

// // // // // // //   /// 🔹 Extract phone number from stored token
// // // // // // //   Future<String> _extractPhoneNumberFromToken() async {
// // // // // // //     try {
// // // // // // //       final prefs = await SharedPreferences.getInstance();

// // // // // // //       // Try to get phone number from various possible storage locations
// // // // // // //       String phoneNumber = prefs.getString('user_phone') ??
// // // // // // //           prefs.getString('phone_number') ??
// // // // // // //           prefs.getString('wp_number') ??
// // // // // // //           prefs.getString('lead_phone') ??
// // // // // // //           prefs.getString('whatsapp_number') ?? // Add this key
// // // // // // //           '';

// // // // // // //       // If not found in prefs, try to extract from user data
// // // // // // //       if (phoneNumber.isEmpty) {
// // // // // // //         final userData = prefs.getString(SharedPrefsConstants.userKey);
// // // // // // //         if (userData != null && userData.isNotEmpty) {
// // // // // // //           phoneNumber = _extractWhatsappNumberFromUserData(userData);
// // // // // // //         }
// // // // // // //       }

// // // // // // //       debug(
// // // // // // //           " Extracted phone number from token: ${phoneNumber.isNotEmpty ? phoneNumber : 'Not found'}");
// // // // // // //       return phoneNumber;
// // // // // // //     } catch (e) {
// // // // // // //       debug("  Error extracting phone number from token: $e");
// // // // // // //       return '';
// // // // // // //     }
// // // // // // //   }

// // // // // // //   /// 🔹 Extract whatsapp number from user data string
// // // // // // //   String _extractWhatsappNumberFromUserData(String userData) {
// // // // // // //     try {
// // // // // // //       debug("  Searching for whatsapp_number in user data");

// // // // // // //       // First try to parse as JSON
// // // // // // //       try {
// // // // // // //         // Decode the JSON string
// // // // // // //         final Map<String, dynamic> jsonData = json.decode(userData);
// // // // // // //         debug("  Parsed JSON: $jsonData");

// // // // // // //         // Check if whatsapp_number exists
// // // // // // //         if (jsonData['whatsapp_number'] != null) {
// // // // // // //           String number = jsonData['whatsapp_number'].toString();
// // // // // // //           debug("Original number: $number");

// // // // // // //           // Use country_code from JSON if present, else default to +91
// // // // // // //           String countryCode = jsonData['country_code']?.toString() ?? '+91';

// // // // // // //           // Prepend country code if number doesn't already start with '+'
// // // // // // //           if (!number.startsWith('+')) {
// // // // // // //             number = '$countryCode$number';
// // // // // // //           }

// // // // // // //           debug("Final WhatsApp number: $number");
// // // // // // //           return number;
// // // // // // //         } else {
// // // // // // //           debug(" whatsapp_number not found in JSON");
// // // // // // //         }
// // // // // // //       } catch (e) {
// // // // // // //         debug(" Failed to parse JSON, trying string extraction. Error: $e");
// // // // // // //       }

// // // // // // //       // Try different patterns for whatsapp number
// // // // // // //       final patterns = [
// // // // // // //         r'"whatsapp_number":\s*"([^"]+)"', // Primary pattern
// // // // // // //         r'"whatsappNumber":\s*"([^"]+)"',
// // // // // // //         r'"phone":\s*"([^"]+)"',
// // // // // // //         r'"mobile":\s*"([^"]+)"',
// // // // // // //         r'"phoneNumber":\s*"([^"]+)"',
// // // // // // //         r'"contact":\s*"([^"]+)"',
// // // // // // //         r'"whatsapp":\s*"([^"]+)"',
// // // // // // //       ];

// // // // // // //       for (var pattern in patterns) {
// // // // // // //         final regex = RegExp(pattern);
// // // // // // //         final match = regex.firstMatch(userData);
// // // // // // //         if (match != null &&
// // // // // // //             match.group(1) != null &&
// // // // // // //             match.group(1)!.isNotEmpty) {
// // // // // // //           String number = match.group(1)!;
// // // // // // //           debug("  Found number with pattern $pattern: $number");

// // // // // // //           // Add country code if it's a whatsapp_number and doesn't have +
// // // // // // //           if (pattern.contains('whatsapp') && !number.startsWith('+')) {
// // // // // // //             number = '+91$number';
// // // // // // //           }
// // // // // // //           return number;
// // // // // // //         }
// // // // // // //       }

// // // // // // //       debug("  No phone number found in user data");
// // // // // // //       return '';
// // // // // // //     } catch (e) {
// // // // // // //       debug("  Error extracting whatsapp number from user data: $e");
// // // // // // //       return '';
// // // // // // //     }
// // // // // // //   }

// // // // // // //   /// 🔹 Extract phone number from access token
// // // // // // //   String _extractPhoneFromAccessToken(String accessToken) {
// // // // // // //     try {
// // // // // // //       debug("  Extracting phone from access token");

// // // // // // //       // First check if it's JWT
// // // // // // //       if (accessToken.contains('.')) {
// // // // // // //         final parts = accessToken.split('.');
// // // // // // //         if (parts.length >= 2) {
// // // // // // //           try {
// // // // // // //             // Decode base64 payload
// // // // // // //             String payload = parts[1];
// // // // // // //             // Add padding if needed
// // // // // // //             while (payload.length % 4 != 0) {
// // // // // // //               payload += '=';
// // // // // // //             }

// // // // // // //             // Decode from base64
// // // // // // //             final decodedPayload = utf8.decode(base64Url.decode(payload));
// // // // // // //             debug("📄 Decoded JWT payload: $decodedPayload");

// // // // // // //             // Parse as JSON
// // // // // // //             final payloadJson = json.decode(decodedPayload);

// // // // // // //             // Look for phone/whatsapp number in payload
// // // // // // //             if (payloadJson['whatsapp_number'] != null) {
// // // // // // //               return payloadJson['whatsapp_number'].toString();
// // // // // // //             }
// // // // // // //             if (payloadJson['phone'] != null) {
// // // // // // //               return payloadJson['phone'].toString();
// // // // // // //             }
// // // // // // //             if (payloadJson['mobile'] != null) {
// // // // // // //               return payloadJson['mobile'].toString();
// // // // // // //             }
// // // // // // //           } catch (e) {
// // // // // // //             debug(" Could not decode JWT payload: $e");
// // // // // // //           }
// // // // // // //         }
// // // // // // //       }

// // // // // // //       // Fallback: simple string search
// // // // // // //       if (accessToken.contains('whatsapp_number')) {
// // // // // // //         final regex = RegExp(r'whatsapp_number[^:]*:\s*"([^"]+)"');
// // // // // // //         final match = regex.firstMatch(accessToken);
// // // // // // //         if (match != null && match.group(1) != null) {
// // // // // // //           return match.group(1)!;
// // // // // // //         }
// // // // // // //       }

// // // // // // //       return '';
// // // // // // //     } catch (e) {
// // // // // // //       debug("  Error extracting phone from access token: $e");
// // // // // // //       return '';
// // // // // // //     }
// // // // // // //   }

// // // // // // //   /// 🔹 Callback when providers are ready
// // // // // // //   void _onProvidersReady() {
// // // // // // //     try {
// // // // // // //       if (!_areProvidersReady && mounted) {
// // // // // // //         setState(() {
// // // // // // //           _areProvidersReady = true;
// // // // // // //         });
// // // // // // //         _checkAndProcessDeepLink();
// // // // // // //       }
// // // // // // //     } catch (e) {
// // // // // // //       debug("  Error in onProvidersReady: $e");
// // // // // // //     }
// // // // // // //   }

// // // // // // //   @override
// // // // // // //   void dispose() {
// // // // // // //     _linkSubscription?.cancel();
// // // // // // //     super.dispose();
// // // // // // //   }

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     // Call providers ready callback after UI is built
// // // // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // //       _onProvidersReady();
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
// // // // // // //       child: Builder(
// // // // // // //         builder: (context) {
// // // // // // //           // Ensure providers are initialized
// // // // // // //           WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // //             _onProvidersReady();
// // // // // // //           });

// // // // // // //           return MaterialApp(
// // // // // // //             debugShowCheckedModeBanner: false,
// // // // // // //             navigatorKey: navigatorKey,
// // // // // // //             navigatorObservers: [routeObserver],
// // // // // // //             title: 'WatConnect',
// // // // // // //             theme: ThemeData(
// // // // // // //               textTheme: GoogleFonts.kohSantepheapTextTheme(),
// // // // // // //               primaryColor: AppColor.navBarIconColor,
// // // // // // //               appBarTheme: const AppBarTheme(
// // // // // // //                 backgroundColor: AppColor.navBarIconColor,
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //             builder: EasyLoading.init(),
// // // // // // //             home: const SplashView(),
// // // // // // //           );
// // // // // // //         },
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }

// // // // // // // // import 'dart:convert';
// // // // // // // // import 'dart:async';
// // // // // // // // import 'dart:core';

// // // // // // // // import 'package:app_links/app_links.dart';
// // // // // // // // import 'package:firebase_core/firebase_core.dart';
// // // // // // // // import 'package:firebase_messaging/firebase_messaging.dart';
// // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // import 'package:flutter/services.dart';
// // // // // // // // import 'package:flutter_easyloading/flutter_easyloading.dart';
// // // // // // // // import 'package:google_fonts/google_fonts.dart';
// // // // // // // // import 'package:provider/provider.dart';
// // // // // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // // // // // import 'package:timezone/data/latest.dart' as tz;
// // // // // // // // import 'package:whatsapp/utils/app_constants.dart';

// // // // // // // // // Controllers & VMs
// // // // // // // // import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
// // // // // // // // import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
// // // // // // // // import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
// // // // // // // // import 'package:whatsapp/salesforce/controller/sfCampaign_controller.dart';
// // // // // // // // import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
// // // // // // // // import 'package:whatsapp/salesforce/controller/template_controller.dart';

// // // // // // // // import 'package:whatsapp/services/notifications/notification_service.dart';
// // // // // // // // import 'package:whatsapp/utils/app_color.dart';
// // // // // // // // import 'package:whatsapp/utils/function_lib.dart';

// // // // // // // // import 'package:whatsapp/view_models/approved_template_vm.dart';
// // // // // // // // import 'package:whatsapp/view_models/auto_response_vm.dart';
// // // // // // // // import 'package:whatsapp/view_models/call_view_model.dart';
// // // // // // // // import 'package:whatsapp/view_models/campaign_chart_vm.dart';
// // // // // // // // import 'package:whatsapp/view_models/campaign_count_vm.dart';
// // // // // // // // import 'package:whatsapp/view_models/campaign_vm.dart';
// // // // // // // // import 'package:whatsapp/view_models/chart_list_vm.dart';
// // // // // // // // import 'package:whatsapp/view_models/get_user_vm.dart';
// // // // // // // // import 'package:whatsapp/view_models/groups_view_model.dart';
// // // // // // // // import 'package:whatsapp/view_models/lead_controller.dart';
// // // // // // // // import 'package:whatsapp/view_models/lead_count_vm.dart';
// // // // // // // // import 'package:whatsapp/view_models/lead_list_vm.dart';
// // // // // // // // import 'package:whatsapp/view_models/message_controller.dart';
// // // // // // // // import 'package:whatsapp/view_models/message_history_vm.dart';
// // // // // // // // import 'package:whatsapp/view_models/message_list_vm.dart';
// // // // // // // // import 'package:whatsapp/view_models/tags_list_vm.dart';
// // // // // // // // import 'package:whatsapp/view_models/templete_list_vm.dart';
// // // // // // // // import 'package:whatsapp/view_models/unread_count_vm.dart';
// // // // // // // // import 'package:whatsapp/view_models/user_data_list_vm.dart';
// // // // // // // // import 'package:whatsapp/view_models/wallet_controller.dart';
// // // // // // // // import 'package:whatsapp/view_models/whatsapp_setting_vm.dart';

// // // // // // // // import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
// // // // // // // // import 'package:whatsapp/views/view/splash_view.dart';

// // // // // // // // import 'firebase_options.dart';

// // // // // // // // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// // // // // // // // final RouteObserver<ModalRoute<void>> routeObserver =
// // // // // // // //     RouteObserver<ModalRoute<void>>();

// // // // // // // // /// store deep link safely until app ready
// // // // // // // // Uri? pendingDeepLink;

// // // // // // // // @pragma('vm:entry-point')
// // // // // // // // Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// // // // // // // //   await Firebase.initializeApp();
// // // // // // // // }

// // // // // // // // void main() async {
// // // // // // // //   WidgetsFlutterBinding.ensureInitialized();

// // // // // // // //   try {
// // // // // // // //     tz.initializeTimeZones();

// // // // // // // //     await Firebase.initializeApp(
// // // // // // // //       options: DefaultFirebaseOptions.currentPlatform,
// // // // // // // //     );

// // // // // // // //     FirebaseMessaging.onBackgroundMessage(
// // // // // // // //       firebaseMessagingBackgroundHandler,
// // // // // // // //     );

// // // // // // // //     await NotificationService.init();

// // // // // // // //     runApp(const MyApp());
// // // // // // // //     await NotificationService.handleInitialMessage();
// // // // // // // //   } catch (e) {
// // // // // // // //     debug("  Error in main(): $e");
// // // // // // // //     runApp(
// // // // // // // //       MaterialApp(
// // // // // // // //         home: Scaffold(
// // // // // // // //           body: Center(
// // // // // // // //             child: Text('App initialization failed: $e'),
// // // // // // // //           ),
// // // // // // // //         ),
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // // }

// // // // // // // // class MyApp extends StatefulWidget {
// // // // // // // //   const MyApp({super.key});

// // // // // // // //   @override
// // // // // // // //   State<MyApp> createState() => _MyAppState();
// // // // // // // // }

// // // // // // // // class _MyAppState extends State<MyApp> {
// // // // // // // //   late final AppLinks _appLinks;
// // // // // // // //   StreamSubscription<Uri>? _linkSubscription;
// // // // // // // //   bool _isAppInitialized = false;

// // // // // // // //   @override
// // // // // // // //   void initState() {
// // // // // // // //     super.initState();

// // // // // // // //     try {
// // // // // // // //       debug("🚀 AppLinks initialized");
// // // // // // // //       _appLinks = AppLinks();
// // // // // // // //       _handleInitialUri();
// // // // // // // //       _listenToUriStream();

// // // // // // // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // // //         if (mounted) {
// // // // // // // //           setState(() {
// // // // // // // //             _isAppInitialized = true;
// // // // // // // //           });
// // // // // // // //           _processPendingDeepLink();
// // // // // // // //         }
// // // // // // // //       });
// // // // // // // //     } catch (e) {
// // // // // // // //       debug("  Error in MyApp initState: $e");
// // // // // // // //     }
// // // // // // // //   }

// // // // // // // //   /// 🔹 App killed state
// // // // // // // //   Future<void> _handleInitialUri() async {
// // // // // // // //     try {
// // // // // // // //       final Uri? initialUri = await _appLinks.getInitialLink();
// // // // // // // //       debug("📌 Initial URI => $initialUri");

// // // // // // // //       if (initialUri != null) {
// // // // // // // //         pendingDeepLink = initialUri;
// // // // // // // //         _processPendingDeepLink();
// // // // // // // //       }
// // // // // // // //     } catch (e) {
// // // // // // // //       debug("  Initial URI error: $e");
// // // // // // // //     }
// // // // // // // //   }

// // // // // // // //   /// 🔹 Background / foreground
// // // // // // // //   void _listenToUriStream() {
// // // // // // // //     _linkSubscription = _appLinks.uriLinkStream.listen(
// // // // // // // //       (Uri uri) {
// // // // // // // //         debug("🔗 Stream URI => $uri");
// // // // // // // //         pendingDeepLink = uri;
// // // // // // // //         _processPendingDeepLink();
// // // // // // // //       },
// // // // // // // //       onError: (err) {
// // // // // // // //         debug("  URI Stream error: $err");
// // // // // // // //       },
// // // // // // // //     );
// // // // // // // //   }

// // // // // // // //   /// 🔹 Process pending deep link
// // // // // // // //   void _processPendingDeepLink() {
// // // // // // // //     if (!_isAppInitialized || pendingDeepLink == null) return;

// // // // // // // //     _processDeepLink();
// // // // // // // //   }

// // // // // // // //   /// 🔹 Process deep link - SINGLE FUNCTION FOR EVERYTHING
// // // // // // // //   void _processDeepLink() async {
// // // // // // // //     try {
// // // // // // // //       if (pendingDeepLink == null) return;

// // // // // // // //       final uri = pendingDeepLink!;
// // // // // // // //       debug("➡️ Processing DeepLink: $uri");

// // // // // // // //       // Extract phone numbers from URL
// // // // // // // //       final Map<String, String> extractedData = _extractDataFromUrl(uri);
// // // // // // // //       final String leadPhone = extractedData['leadPhone'] ?? '';
// // // // // // // //       final String whatsappSettingNumber = extractedData['whatsappSettingNumber'] ?? '';

// // // // // // // //       if (leadPhone.isEmpty) {
// // // // // // // //         debug("  No phone number found in URL");
// // // // // // // //         return;
// // // // // // // //       }

// // // // // // // //       // Get user data and phone number
// // // // // // // //       final userData = await _getUserPhoneNumber();
// // // // // // // //       final String userPhone = userData['phone'] ?? '';
// // // // // // // //       final String userName = userData['name'] ?? 'WatConnect User';

// // // // // // // //       debug(" URL Lead Phone: $leadPhone");
// // // // // // // //       debug(" User Phone from Token: $userPhone");
// // // // // // // //       debug("👤 User Name: $userName");

// // // // // // // //       // Navigate to chat screen
// // // // // // // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // // //         final context = navigatorKey.currentContext;
// // // // // // // //         if (context == null) {
// // // // // // // //           debug("  Context is null, retrying...");
// // // // // // // //           Future.delayed(const Duration(milliseconds: 500), () {
// // // // // // // //             _processDeepLink();
// // // // // // // //           });
// // // // // // // //           return;
// // // // // // // //         }

// // // // // // // //         debug("🚀 Navigating to WhatsappChatScreen");

// // // // // // // //         Navigator.push(
// // // // // // // //           context,
// // // // // // // //           MaterialPageRoute(
// // // // // // // //             builder: (_) => WhatsappChatScreen(
// // // // // // // //               leadName: userName,
// // // // // // // //               wpnumber: leadPhone.isNotEmpty ? leadPhone : userPhone,
// // // // // // // //               id: whatsappSettingNumber,
// // // // // // // //             ),
// // // // // // // //           ),
// // // // // // // //         );

// // // // // // // //         pendingDeepLink = null;
// // // // // // // //       });
// // // // // // // //     } catch (e) {
// // // // // // // //       debug("  Error in _processDeepLink: $e");
// // // // // // // //     }
// // // // // // // //   }

// // // // // // // //   /// 🔹 SINGLE FUNCTION: Extract data from URL
// // // // // // // //   Map<String, String> _extractDataFromUrl(Uri uri) {
// // // // // // // //     final Map<String, String> data = {
// // // // // // // //       'leadPhone': '',
// // // // // // // //       'whatsappSettingNumber': ''
// // // // // // // //     };

// // // // // // // //     try {
// // // // // // // //       debug("  Extracting data from URL: $uri");

// // // // // // // //       // Extract lead phone from path
// // // // // // // //       for (var segment in uri.pathSegments) {
// // // // // // // //         if (segment.startsWith('+') && segment.length > 10) {
// // // // // // // //           data['leadPhone'] = segment;
// // // // // // // //           break;
// // // // // // // //         }
// // // // // // // //       }

// // // // // // // //       // Extract whatsapp_setting_number from query
// // // // // // // //       data['whatsappSettingNumber'] =
// // // // // // // //           uri.queryParameters['whatsapp_setting_number'] ?? '';

// // // // // // // //       return data;
// // // // // // // //     } catch (e) {
// // // // // // // //       debug("  Error extracting data from URL: $e");
// // // // // // // //       return data;
// // // // // // // //     }
// // // // // // // //   }

// // // // // // // //   /// 🔹 SINGLE FUNCTION: Get user phone number from stored data
// // // // // // // //   Future<Map<String, String>> _getUserPhoneNumber() async {
// // // // // // // //     final Map<String, String> userData = {
// // // // // // // //       'name': 'WatConnect User',
// // // // // // // //       'phone': ''
// // // // // // // //     };

// // // // // // // //     try {
// // // // // // // //       final prefs = await SharedPreferences.getInstance();
// // // // // // // //       final userKey = prefs.getString(SharedPrefsConstants.userKey);

// // // // // // // //       if (userKey != null && userKey.isNotEmpty) {
// // // // // // // //         debug("🔑 User Key found, length: ${userKey.length}");

// // // // // // // //         // Parse JSON
// // // // // // // //         try {
// // // // // // // //           final Map<String, dynamic> jsonData = json.decode(userKey);
// // // // // // // //           debug("  JSON parsed successfully");

// // // // // // // //           // Check if it's the response structure with authToken
// // // // // // // //           if (jsonData['authToken'] != null) {
// // // // // // // //             final String authToken = jsonData['authToken'];
// // // // // // // //             debug("🔐 AuthToken found, decoding JWT...");

// // // // // // // //             // Decode JWT
// // // // // // // //             final Map<String, dynamic>? decodedToken = _decodeJWT(authToken);
// // // // // // // //             if (decodedToken != null) {
// // // // // // // //               userData['name'] = decodedToken['username']?.toString() ??
// // // // // // // //                                 decodedToken['email']?.toString().split('@').first ??
// // // // // // // //                                 'WatConnect User';
// // // // // // // //               userData['phone'] = _extractPhoneFromJson(decodedToken);
// // // // // // // //             }
// // // // // // // //           } else {
// // // // // // // //             // Direct JSON structure
// // // // // // // //             userData['name'] = jsonData['username']?.toString() ??
// // // // // // // //                               jsonData['email']?.toString().split('@').first ??
// // // // // // // //                               'WatConnect User';
// // // // // // // //             userData['phone'] = _extractPhoneFromJson(jsonData);
// // // // // // // //           }
// // // // // // // //         } catch (e) {
// // // // // // // //           debug(" JSON parse failed: $e, trying string extraction");

// // // // // // // //           // String extraction fallback
// // // // // // // //           userData['name'] = _extractFromString(userKey, 'username') ??
// // // // // // // //                             _extractFromString(userKey, 'email')?.split('@').first ??
// // // // // // // //                             'WatConnect User';
// // // // // // // //           userData['phone'] = _extractPhoneFromString(userKey);
// // // // // // // //         }
// // // // // // // //       }

// // // // // // // //       debug(" Final user data - Name: ${userData['name']}, Phone: ${userData['phone']}");
// // // // // // // //       return userData;
// // // // // // // //     } catch (e) {
// // // // // // // //       debug("  Error getting user phone number: $e");
// // // // // // // //       return userData;
// // // // // // // //     }
// // // // // // // //   }

// // // // // // // //   /// 🔹 Helper: Decode JWT token
// // // // // // // //   Map<String, dynamic>? _decodeJWT(String token) {
// // // // // // // //     try {
// // // // // // // //       final parts = token.split('.');
// // // // // // // //       if (parts.length != 3) return null;

// // // // // // // //       String payload = parts[1];
// // // // // // // //       while (payload.length % 4 != 0) {
// // // // // // // //         payload += '=';
// // // // // // // //       }

// // // // // // // //       final decoded = utf8.decode(base64Url.decode(payload));
// // // // // // // //       debug("🔓 Decoded JWT payload");
// // // // // // // //       return json.decode(decoded);
// // // // // // // //     } catch (e) {
// // // // // // // //       debug("  JWT decode failed: $e");
// // // // // // // //       return null;
// // // // // // // //     }
// // // // // // // //   }

// // // // // // // //   /// 🔹 Helper: Extract phone from JSON
// // // // // // // //   String _extractPhoneFromJson(Map<String, dynamic> json) {
// // // // // // // //     try {
// // // // // // // //       if (json['whatsapp_number'] != null) {
// // // // // // // //         String number = json['whatsapp_number'].toString();
// // // // // // // //         String countryCode = json['country_code']?.toString() ?? '+91';

// // // // // // // //         if (!number.startsWith('+')) {
// // // // // // // //           number = '$countryCode$number';
// // // // // // // //         }
// // // // // // // //         debug("  Extracted whatsapp_number from JSON: $number");
// // // // // // // //         return number;
// // // // // // // //       }

// // // // // // // //       // Fallback to other phone fields
// // // // // // // //       final phoneFields = ['phone', 'mobile', 'phoneNumber', 'contact'];
// // // // // // // //       for (var field in phoneFields) {
// // // // // // // //         if (json[field] != null) {
// // // // // // // //           debug("  Extracted $field from JSON: ${json[field]}");
// // // // // // // //           return json[field].toString();
// // // // // // // //         }
// // // // // // // //       }

// // // // // // // //       return '';
// // // // // // // //     } catch (e) {
// // // // // // // //       debug("  Error extracting phone from JSON: $e");
// // // // // // // //       return '';
// // // // // // // //     }
// // // // // // // //   }

// // // // // // // //   /// 🔹 Helper: Extract value from string
// // // // // // // //   String? _extractFromString(String data, String key) {
// // // // // // // //     try {
// // // // // // // //       final regex = RegExp('"$key":\\s*"([^"]+)"');
// // // // // // // //       final match = regex.firstMatch(data);
// // // // // // // //       return match?.group(1);
// // // // // // // //     } catch (e) {
// // // // // // // //       return null;
// // // // // // // //     }
// // // // // // // //   }

// // // // // // // //   /// 🔹 Helper: Extract phone from string
// // // // // // // //   String _extractPhoneFromString(String data) {
// // // // // // // //     try {
// // // // // // // //       // Try whatsapp_number first
// // // // // // // //       final whatsappRegex = RegExp(r'"whatsapp_number":\s*"([^"]+)"');
// // // // // // // //       final whatsappMatch = whatsappRegex.firstMatch(data);
// // // // // // // //       if (whatsappMatch != null && whatsappMatch.group(1) != null) {
// // // // // // // //         String number = whatsappMatch.group(1)!;

// // // // // // // //         // Try to get country code
// // // // // // // //         final countryRegex = RegExp(r'"country_code":\s*"([^"]+)"');
// // // // // // // //         final countryMatch = countryRegex.firstMatch(data);
// // // // // // // //         String countryCode = countryMatch?.group(1) ?? '+91';

// // // // // // // //         if (!number.startsWith('+')) {
// // // // // // // //           number = '$countryCode$number';
// // // // // // // //         }
// // // // // // // //         return number;
// // // // // // // //       }

// // // // // // // //       // Try other phone fields
// // // // // // // //       final phonePatterns = [
// // // // // // // //         r'"phone":\s*"([^"]+)"',
// // // // // // // //         r'"mobile":\s*"([^"]+)"',
// // // // // // // //         r'"phoneNumber":\s*"([^"]+)"'
// // // // // // // //       ];

// // // // // // // //       for (var pattern in phonePatterns) {
// // // // // // // //         final regex = RegExp(pattern);
// // // // // // // //         final match = regex.firstMatch(data);
// // // // // // // //         if (match != null && match.group(1) != null) {
// // // // // // // //           return match.group(1)!;
// // // // // // // //         }
// // // // // // // //       }

// // // // // // // //       return '';
// // // // // // // //     } catch (e) {
// // // // // // // //       debug("  Error extracting phone from string: $e");
// // // // // // // //       return '';
// // // // // // // //     }
// // // // // // // //   }

// // // // // // // //   @override
// // // // // // // //   void dispose() {
// // // // // // // //     _linkSubscription?.cancel();
// // // // // // // //     super.dispose();
// // // // // // // //   }

// // // // // // // //   @override
// // // // // // // //   Widget build(BuildContext context) {
// // // // // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // // //       _processPendingDeepLink();
// // // // // // // //     });

// // // // // // // //     SystemChrome.setSystemUIOverlayStyle(
// // // // // // // //       const SystemUiOverlayStyle(
// // // // // // // //         statusBarColor: Colors.transparent,
// // // // // // // //         statusBarIconBrightness: Brightness.dark,
// // // // // // // //         statusBarBrightness: Brightness.light,
// // // // // // // //       ),
// // // // // // // //     );

// // // // // // // //     SystemChrome.setPreferredOrientations([
// // // // // // // //       DeviceOrientation.portraitUp,
// // // // // // // //       DeviceOrientation.portraitDown,
// // // // // // // //     ]);

// // // // // // // //     return MultiProvider(
// // // // // // // //       providers: [
// // // // // // // //         ChangeNotifierProvider(
// // // // // // // //             create: (_) => ApprovedTemplateViewModel(context)),
// // // // // // // //         ChangeNotifierProvider(create: (_) => UnreadCountVm(context)),
// // // // // // // //         ChangeNotifierProvider(create: (_) => GroupsViewModel(context)),
// // // // // // // //         ChangeNotifierProvider(create: (_) => MessageViewModel(context)),
// // // // // // // //         ChangeNotifierProvider(create: (_) => CampaignChartViewModel(context)),
// // // // // // // //         ChangeNotifierProvider(create: (_) => LeadListViewModel(context)),
// // // // // // // //         ChangeNotifierProvider(create: (_) => TagsListViewModel(context)),
// // // // // // // //         ChangeNotifierProvider(create: (_) => CampaignViewModel(context)),
// // // // // // // //         ChangeNotifierProvider(create: (_) => MeesageHistoryViewModel(context)),
// // // // // // // //         ChangeNotifierProvider(create: (_) => LeadCountViewModel(context)),
// // // // // // // //         ChangeNotifierProvider(create: (_) => TempleteListViewModel(context)),
// // // // // // // //         ChangeNotifierProvider(create: (_) => AutoResponseViewModel(context)),
// // // // // // // //         ChangeNotifierProvider(
// // // // // // // //             create: (_) => WhatsappSettingViewModel(context)),
// // // // // // // //         ChangeNotifierProvider(create: (_) => CampaignCountViewModel(context)),
// // // // // // // //         ChangeNotifierProvider(create: (_) => ChartListViewModel(context)),
// // // // // // // //         ChangeNotifierProvider(create: (_) => GetUserViewModel(context)),
// // // // // // // //         ChangeNotifierProvider(create: (_) => UserDataListViewModel(context)),
// // // // // // // //         ChangeNotifierProvider(create: (_) => MessageController()),
// // // // // // // //         ChangeNotifierProvider(create: (_) => DashBoardController()),
// // // // // // // //         ChangeNotifierProvider(create: (_) => TemplateController()),
// // // // // // // //         ChangeNotifierProvider(create: (_) => BusinessNumberController()),
// // // // // // // //         ChangeNotifierProvider(create: (_) => CallsViewModel(context)),
// // // // // // // //         ChangeNotifierProvider(create: (_) => ChatMessageController()),
// // // // // // // //         ChangeNotifierProvider(create: (_) => SfcampaignController()),
// // // // // // // //         ChangeNotifierProvider(create: (_) => WalletController()),
// // // // // // // //         ChangeNotifierProvider(create: (_) => LeadController()),
// // // // // // // //         ChangeNotifierProvider(create: (_) => SfFileUploadController()),
// // // // // // // //       ],
// // // // // // // //       child: Builder(
// // // // // // // //         builder: (context) {
// // // // // // // //           return MaterialApp(
// // // // // // // //             debugShowCheckedModeBanner: false,
// // // // // // // //             navigatorKey: navigatorKey,
// // // // // // // //             navigatorObservers: [routeObserver],
// // // // // // // //             title: 'WatConnect',
// // // // // // // //             theme: ThemeData(
// // // // // // // //               textTheme: GoogleFonts.kohSantepheapTextTheme(),
// // // // // // // //               primaryColor: AppColor.navBarIconColor,
// // // // // // // //               appBarTheme: const AppBarTheme(
// // // // // // // //                 backgroundColor: AppColor.navBarIconColor,
// // // // // // // //               ),
// // // // // // // //             ),
// // // // // // // //             builder: EasyLoading.init(),
// // // // // // // //             home: const SplashView(),
// // // // // // // //           );
// // // // // // // //         },
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // // }

// // // // // // import 'dart:convert';
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
// // // // // // import 'package:whatsapp/utils/app_constants.dart';

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
// // // // // //   WidgetsFlutterBinding.ensureInitialized();

// // // // // //   try {
// // // // // //     tz.initializeTimeZones();

// // // // // //     await Firebase.initializeApp(
// // // // // //       options: DefaultFirebaseOptions.currentPlatform,
// // // // // //     );

// // // // // //     FirebaseMessaging.onBackgroundMessage(
// // // // // //       firebaseMessagingBackgroundHandler,
// // // // // //     );

// // // // // //     await NotificationService.init();

// // // // // //     runApp(const MyApp());
// // // // // //     await NotificationService.handleInitialMessage();
// // // // // //   } catch (e) {
// // // // // //     debug("  Error in main(): $e");
// // // // // //     runApp(
// // // // // //       MaterialApp(
// // // // // //         home: Scaffold(
// // // // // //           body: Center(
// // // // // //             child: Text('App initialization failed: $e'),
// // // // // //           ),
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
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

// // // // // //   @override
// // // // // //   void initState() {
// // // // // //     super.initState();

// // // // // //     try {
// // // // // //       debug("🚀 AppLinks initialized");
// // // // // //       _appLinks = AppLinks();
// // // // // //       _handleInitialUri();
// // // // // //       _listenToUriStream();

// // // // // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // //         if (mounted) {
// // // // // //           setState(() {
// // // // // //             _isAppInitialized = true;
// // // // // //           });
// // // // // //           _processPendingDeepLink();
// // // // // //         }
// // // // // //       });
// // // // // //     } catch (e) {
// // // // // //       debug("  Error in MyApp initState: $e");
// // // // // //     }
// // // // // //   }

// // // // // //   /// 🔹 App killed state
// // // // // //   Future<void> _handleInitialUri() async {
// // // // // //     try {
// // // // // //       final Uri? initialUri = await _appLinks.getInitialLink();
// // // // // //       debug("📌 Initial URI => $initialUri");

// // // // // //       if (initialUri != null) {
// // // // // //         pendingDeepLink = initialUri;
// // // // // //         _processPendingDeepLink();
// // // // // //       }
// // // // // //     } catch (e) {
// // // // // //       debug("  Initial URI error: $e");
// // // // // //     }
// // // // // //   }

// // // // // //   /// 🔹 Background / foreground
// // // // // //   void _listenToUriStream() {
// // // // // //     _linkSubscription = _appLinks.uriLinkStream.listen(
// // // // // //       (Uri uri) {
// // // // // //         debug("🔗 Stream URI => $uri");
// // // // // //         pendingDeepLink = uri;
// // // // // //         _processPendingDeepLink();
// // // // // //       },
// // // // // //       onError: (err) {
// // // // // //         debug("  URI Stream error: $err");
// // // // // //       },
// // // // // //     );
// // // // // //   }

// // // // // //   /// 🔹 Process pending deep link
// // // // // //   void _processPendingDeepLink() {
// // // // // //     if (!_isAppInitialized || pendingDeepLink == null) return;

// // // // // //     _processDeepLink();
// // // // // //   }

// // // // // //   /// 🔹 Process deep link - URL से phone number निकालकर chat खोलें
// // // // // //   void _processDeepLink() async {
// // // // // //     try {
// // // // // //       if (pendingDeepLink == null) {
// // // // // //         debug(" No pending deep link to process");
// // // // // //         return;
// // // // // //       }

// // // // // //       final uri = pendingDeepLink!;
// // // // // //       final uriString = uri.toString();
// // // // // //       debug("➡️ Processing DeepLink: $uriString");

// // // // // //       // Extract phone number from URL
// // // // // //       final String leadPhone = _extractLeadPhoneFromUrl(uriString);

// // // // // //       if (leadPhone.isEmpty) {
// // // // // //         debug("  No phone number found in URL");
// // // // // //         return;
// // // // // //       }

// // // // // //       // Extract whatsapp setting number from URL
// // // // // //       final String whatsappSettingNumber =
// // // // // //           _extractWhatsappSettingNumberFromUrl(uriString);

// // // // // //       // Get user data from stored tokens
// // // // // //       final userData = await _getUserDataFromTokens();
// // // // // //       final String leadName = userData['leadName'] ?? leadPhone;

// // // // // //       debug(" Extracted from URL:");
// // // // // //       debug("   Lead Phone: $leadPhone");
// // // // // //       debug("   WhatsApp Setting Number: $whatsappSettingNumber");
// // // // // //       debug("   User Name: $leadName");

// // // // // //       // Navigate to chat screen
// // // // // //       _navigateToChatScreen(leadName, leadPhone, whatsappSettingNumber);
// // // // // //     } catch (e) {
// // // // // //       debug("  Error in _processDeepLink: $e");
// // // // // //     }
// // // // // //   }

// // // // // //   /// 🔹 Extract lead phone number from URL
// // // // // //   String _extractLeadPhoneFromUrl(String url) {
// // // // // //     try {
// // // // // //       debug("  Extracting phone number from URL: $url");

// // // // // //       final RegExp phoneRegex = RegExp(r'/history/(\+?\d+)');
// // // // // //       final Match? match = phoneRegex.firstMatch(url);

// // // // // //       if (match != null && match.group(1) != null) {
// // // // // //         String phone = match.group(1)!;
// // // // // //         debug("  Found phone in URL path: $phone");
// // // // // //         return phone;
// // // // // //       }

// // // // // //       // Alternative pattern: just look for +91 followed by 10 digits
// // // // // //       final RegExp altRegex = RegExp(r'(\+91\d{10})');
// // // // // //       final Match? altMatch = altRegex.firstMatch(url);

// // // // // //       if (altMatch != null && altMatch.group(1) != null) {
// // // // // //         String phone = altMatch.group(1)!;
// // // // // //         debug("  Found phone with alt pattern: $phone");
// // // // // //         return phone;
// // // // // //       }

// // // // // //       // Last resort: extract any number that looks like Indian phone
// // // // // //       final RegExp lastRegex = RegExp(r'(\+?91?\d{10})');
// // // // // //       final Match? lastMatch = lastRegex.firstMatch(url);

// // // // // //       if (lastMatch != null && lastMatch.group(1) != null) {
// // // // // //         String phone = lastMatch.group(1)!;
// // // // // //         // Ensure it starts with +91
// // // // // //         if (!phone.startsWith('+91') && phone.length == 10) {
// // // // // //           phone = '+91$phone';
// // // // // //         }
// // // // // //         debug("  Found phone with last resort pattern: $phone");
// // // // // //         return phone;
// // // // // //       }

// // // // // //       debug("  No phone number found in URL");
// // // // // //       return "";
// // // // // //     } catch (e) {
// // // // // //       debug("  Error extracting phone from URL: $e");
// // // // // //       return "";
// // // // // //     }
// // // // // //   }

// // // // // //   /// 🔹 Extract whatsapp setting number from URL
// // // // // //   String _extractWhatsappSettingNumberFromUrl(String url) {
// // // // // //     try {
// // // // // //       debug("  Extracting whatsapp setting number from URL");

// // // // // //       // Extract from query parameter: whatsapp_setting_number=918306524244
// // // // // //       final RegExp regex = RegExp(r'whatsapp_setting_number=(\+?\d+)');
// // // // // //       final Match? match = regex.firstMatch(url);

// // // // // //       if (match != null && match.group(1) != null) {
// // // // // //         String number = match.group(1)!;
// // // // // //         debug("  Found whatsapp setting number: $number");
// // // // // //         return number;
// // // // // //       }

// // // // // //       debug(" No whatsapp setting number found in URL");
// // // // // //       return "";
// // // // // //     } catch (e) {
// // // // // //       debug("  Error extracting whatsapp setting number: $e");
// // // // // //       return "";
// // // // // //     }
// // // // // //   }

// // // // // //   /// 🔹 Navigate to chat screen
// // // // // //   void _navigateToChatScreen(
// // // // // //       String leadName, String leadPhone, String whatsappSettingNumber) {
// // // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // //       try {
// // // // // //         final context = navigatorKey.currentContext;
// // // // // //         if (context == null) {
// // // // // //           debug("  Context is null, retrying in 500ms...");
// // // // // //           // Retry after delay
// // // // // //           Future.delayed(const Duration(milliseconds: 500), () {
// // // // // //             _navigateToChatScreen(leadName, leadPhone, whatsappSettingNumber);
// // // // // //           });
// // // // // //           return;
// // // // // //         }

// // // // // //         // Check if already on chat screen with same number
// // // // // //         final currentRoute = ModalRoute.of(context);
// // // // // //         if (currentRoute?.settings.name?.contains('chat') == true) {
// // // // // //           debug(" Already on chat screen");
// // // // // //           pendingDeepLink = null;
// // // // // //           return;
// // // // // //         }

// // // // // //         debug("  Navigating to WhatsappChatScreen with:");
// // // // // //         debug("   Lead Name: $leadName");
// // // // // //         debug("   Lead Phone: $leadPhone");
// // // // // //         debug("   ID: $whatsappSettingNumber");

// // // // // //         Navigator.push(
// // // // // //           context,
// // // // // //           MaterialPageRoute(
// // // // // //             builder: (_) => WhatsappChatScreen(
// // // // // //               leadName: leadName,
// // // // // //               wpnumber: leadPhone,
// // // // // //               id: whatsappSettingNumber,
// // // // // //               pinnedLeads: [], // Empty list for pinned leads
// // // // // //             ),
// // // // // //           ),
// // // // // //         );

// // // // // //         pendingDeepLink = null;
// // // // // //         debug("🎉 Navigation successful!");
// // // // // //       } catch (e) {
// // // // // //         debug("  Navigation error: $e");
// // // // // //       }
// // // // // //     });
// // // // // //   }

// // // // // //   /// 🔹 Get user data from stored tokens
// // // // // //   Future<Map<String, String>> _getUserDataFromTokens() async {
// // // // // //     final Map<String, String> userData = {
// // // // // //       'leadName': 'WatConnect User',
// // // // // //       'phone': ''
// // // // // //     };

// // // // // //     try {
// // // // // //       final prefs = await SharedPreferences.getInstance();
// // // // // //       final userKey = prefs.getString(SharedPrefsConstants.userKey);

// // // // // //       if (userKey != null && userKey.isNotEmpty) {
// // // // // //         try {
// // // // // //           debug("  Parsing user data JSON");

// // // // // //           final Map<String, dynamic> jsonData = json.decode(userKey);

// // // // // //           // Check if it has authToken (JWT)
// // // // // //           if (jsonData['authToken'] != null) {
// // // // // //             final String authToken = jsonData['authToken'].toString();
// // // // // //             debug("🔐 AuthToken found, decoding JWT");

// // // // // //             final Map<String, dynamic>? decodedToken = _decodeJWT(authToken);
// // // // // //             if (decodedToken != null) {
// // // // // //               userData['leadName'] = decodedToken['username']?.toString() ??
// // // // // //                   decodedToken['email']?.toString().split('@').first ??
// // // // // //                   'WatConnect User';
// // // // // //               userData['phone'] = _extractPhoneFromJson(decodedToken);
// // // // // //             }
// // // // // //           } else {
// // // // // //             // Direct JSON structure
// // // // // //             userData['leadName'] = jsonData['username']?.toString() ??
// // // // // //                 jsonData['email']?.toString().split('@').first ??
// // // // // //                 'WatConnect User';
// // // // // //             userData['phone'] = _extractPhoneFromJson(jsonData);
// // // // // //           }
// // // // // //         } catch (e) {
// // // // // //           debug(" JSON parse failed: $e, trying string extraction");

// // // // // //           // String extraction fallback
// // // // // //           userData['leadName'] = _extractFromString(userKey, 'username') ??
// // // // // //               _extractFromString(userKey, 'email')?.split('@').first ??
// // // // // //               'WatConnect User';
// // // // // //           userData['phone'] = _extractPhoneFromString(userKey);
// // // // // //         }
// // // // // //       }

// // // // // //       debug(
// // // // // //           "👤 User Data - Name: ${userData['leadName']}, Phone: ${userData['phone']}");
// // // // // //       return userData;
// // // // // //     } catch (e) {
// // // // // //       debug("  Error getting user data: $e");
// // // // // //       return userData;
// // // // // //     }
// // // // // //   }

// // // // // //   /// 🔹 Decode JWT token
// // // // // //   Map<String, dynamic>? _decodeJWT(String token) {
// // // // // //     try {
// // // // // //       final parts = token.split('.');
// // // // // //       if (parts.length != 3) {
// // // // // //         debug("  Invalid JWT format");
// // // // // //         return null;
// // // // // //       }

// // // // // //       String payload = parts[1];
// // // // // //       while (payload.length % 4 != 0) {
// // // // // //         payload += '=';
// // // // // //       }

// // // // // //       final decoded = utf8.decode(base64Url.decode(payload));
// // // // // //       debug("🔓 Decoded JWT payload");
// // // // // //       return json.decode(decoded);
// // // // // //     } catch (e) {
// // // // // //       debug("  JWT decode failed: $e");
// // // // // //       return null;
// // // // // //     }
// // // // // //   }

// // // // // //   /// 🔹 Extract phone from JSON
// // // // // //   String _extractPhoneFromJson(Map<String, dynamic> json) {
// // // // // //     try {
// // // // // //       if (json['whatsapp_number'] != null) {
// // // // // //         String number = json['whatsapp_number'].toString();
// // // // // //         String countryCode = json['country_code']?.toString() ?? '+91';

// // // // // //         if (!number.startsWith('+')) {
// // // // // //           number = '$countryCode$number';
// // // // // //         }
// // // // // //         debug("  Extracted whatsapp_number from JSON: $number");
// // // // // //         return number;
// // // // // //       }

// // // // // //       // Fallback to other phone fields
// // // // // //       final phoneFields = ['phone', 'mobile', 'phoneNumber', 'contact'];
// // // // // //       for (var field in phoneFields) {
// // // // // //         if (json[field] != null) {
// // // // // //           debug("  Extracted $field from JSON: ${json[field]}");
// // // // // //           return json[field].toString();
// // // // // //         }
// // // // // //       }

// // // // // //       return '';
// // // // // //     } catch (e) {
// // // // // //       debug("  Error extracting phone from JSON: $e");
// // // // // //       return '';
// // // // // //     }
// // // // // //   }

// // // // // //   /// 🔹 Extract value from string
// // // // // //   String? _extractFromString(String data, String key) {
// // // // // //     try {
// // // // // //       final regex = RegExp('"$key":\\s*"([^"]+)"');
// // // // // //       final match = regex.firstMatch(data);
// // // // // //       return match?.group(1);
// // // // // //     } catch (e) {
// // // // // //       return null;
// // // // // //     }
// // // // // //   }

// // // // // //   /// 🔹 Extract phone from string
// // // // // //   String _extractPhoneFromString(String data) {
// // // // // //     try {
// // // // // //       // Try whatsapp_number first
// // // // // //       final whatsappRegex = RegExp(r'"whatsapp_number":\s*"([^"]+)"');
// // // // // //       final whatsappMatch = whatsappRegex.firstMatch(data);
// // // // // //       if (whatsappMatch != null && whatsappMatch.group(1) != null) {
// // // // // //         String number = whatsappMatch.group(1)!;

// // // // // //         // Try to get country code
// // // // // //         final countryRegex = RegExp(r'"country_code":\s*"([^"]+)"');
// // // // // //         final countryMatch = countryRegex.firstMatch(data);
// // // // // //         String countryCode = countryMatch?.group(1) ?? '+91';

// // // // // //         if (!number.startsWith('+')) {
// // // // // //           number = '$countryCode$number';
// // // // // //         }
// // // // // //         return number;
// // // // // //       }

// // // // // //       // Try other phone fields
// // // // // //       final phonePatterns = [
// // // // // //         r'"phone":\s*"([^"]+)"',
// // // // // //         r'"mobile":\s*"([^"]+)"',
// // // // // //         r'"phoneNumber":\s*"([^"]+)"'
// // // // // //       ];

// // // // // //       for (var pattern in phonePatterns) {
// // // // // //         final regex = RegExp(pattern);
// // // // // //         final match = regex.firstMatch(data);
// // // // // //         if (match != null && match.group(1) != null) {
// // // // // //           return match.group(1)!;
// // // // // //         }
// // // // // //       }

// // // // // //       return '';
// // // // // //     } catch (e) {
// // // // // //       debug("  Error extracting phone from string: $e");
// // // // // //       return '';
// // // // // //     }
// // // // // //   }

// // // // // //   @override
// // // // // //   void dispose() {
// // // // // //     _linkSubscription?.cancel();
// // // // // //     super.dispose();
// // // // // //   }

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // //       _processPendingDeepLink();
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
// // // // // //       child: Builder(
// // // // // //         builder: (context) {
// // // // // //           return MaterialApp(
// // // // // //             debugShowCheckedModeBanner: false,
// // // // // //             navigatorKey: navigatorKey,
// // // // // //             navigatorObservers: [routeObserver],
// // // // // //             title: 'WatConnect',
// // // // // //             theme: ThemeData(
// // // // // //               textTheme: GoogleFonts.kohSantepheapTextTheme(),
// // // // // //               primaryColor: AppColor.navBarIconColor,
// // // // // //               appBarTheme: const AppBarTheme(
// // // // // //                 backgroundColor: AppColor.navBarIconColor,
// // // // // //               ),
// // // // // //             ),
// // // // // //             builder: EasyLoading.init(),
// // // // // //             home: const SplashView(),
// // // // // //           );
// // // // // //         },
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }

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
// // // // import 'package:whatsapp/models/lead_model.dart';
// // // // import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
// // // // import 'package:whatsapp/salesforce/screens/sf_message_chat_screen.dart';
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
// // // //     debug("  Error in main(): $e");
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
// // // //       debug("  Error in MyApp initState: $e");
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
// // // //       debug("  Initial URI error: $e");
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
// // // //         debug("  URI Stream error: $err");
// // // //       },
// // // //     );
// // // //   }

// // // //   /// 🔹 Process pending deep link
// // // //   void _processPendingDeepLink() {
// // // //     if (!_isAppInitialized || pendingDeepLink == null) return;

// // // //     _processDeepLink();
// // // //   }

// // // //   void _processDeepLink() async {
// // // //     try {
// // // //       if (pendingDeepLink == null) {
// // // //         debug(" No pending deep link to process");
// // // //         return;
// // // //       }

// // // //       final uri = pendingDeepLink!;
// // // //       final uriString = uri.toString();
// // // //       debug("➡️ Processing DeepLink: $uriString");

// // // //       final String leadPhone = _extractLeadPhoneFromUrl(uriString);

// // // //       if (leadPhone.isEmpty) {
// // // //         debug("  No phone number found in URL");
// // // //         return;
// // // //       }

// // // //       // Extract whatsapp setting number from URL
// // // //       final String whatsappSettingNumber =
// // // //           _extractWhatsappSettingNumberFromUrl(uriString);

// // // //       debug(" Extracted from URL:");
// // // //       debug("   Lead Phone: $leadPhone");
// // // //       debug("   WhatsApp Setting Number: $whatsappSettingNumber");

// // // //       // Find matching lead from LeadListViewModel
// // // //       await _findAndNavigateToLead(leadPhone, whatsappSettingNumber);
// // // //     } catch (e) {
// // // //       debug("  Error in _processDeepLink: $e");
// // // //     }
// // // //   }

// // // //   /// 🔹 Extract lead phone number from URL
// // // //   String _extractLeadPhoneFromUrl(String url) {
// // // //     try {
// // // //       debug("  Extracting phone number from URL: $url");

// // // //       // Salesforce URL: /Lead/chat/{phone}
// // // //       final RegExp leadChatRegex = RegExp(r'/Lead/chat/(\d+)');
// // // //       final Match? leadMatch = leadChatRegex.firstMatch(url);
// // // //       if (leadMatch != null && leadMatch.group(1) != null) {
// // // //         return '+91${leadMatch.group(1)!}'; // Ensure +91 prefix
// // // //       }

// // // //       // Node.js URL: /chat/{phone}
// // // //       final RegExp nodeChatRegex = RegExp(r'/chat/(\d+)');
// // // //       final Match? nodeMatch = nodeChatRegex.firstMatch(url);
// // // //       if (nodeMatch != null && nodeMatch.group(1) != null) {
// // // //         return '+91${nodeMatch.group(1)!}';
// // // //       }

// // // //       debug("  No phone number found in URL");
// // // //       return "";
// // // //     } catch (e) {
// // // //       debug("  Error extracting phone from URL: $e");
// // // //       return "";
// // // //     }
// // // //   }

// // // //   /// 🔹 Extract whatsapp setting number from URL
// // // //   String _extractWhatsappSettingNumberFromUrl(String url) {
// // // //     try {
// // // //       debug("  Extracting whatsapp setting number from URL");

// // // //       // Extract from query parameter: whatsapp_setting_number=918306524244
// // // //       final RegExp regex = RegExp(r'whatsapp_setting_number=(\+?\d+)');
// // // //       final Match? match = regex.firstMatch(url);

// // // //       if (match != null && match.group(1) != null) {
// // // //         String number = match.group(1)!;
// // // //         debug("  Found whatsapp setting number: $number");
// // // //         return number;
// // // //       }

// // // //       debug(" No whatsapp setting number found in URL");
// // // //       return "";
// // // //     } catch (e) {
// // // //       debug("  Error extracting whatsapp setting number: $e");
// // // //       return "";
// // // //     }
// // // //   }

// // // //   /// 🔹 Find lead from LeadListViewModel and navigate
// // // //   Future<void> _findAndNavigateToLead(
// // // //       String leadPhone, String whatsappSettingNumber) async {
// // // //     WidgetsBinding.instance.addPostFrameCallback((_) async {
// // // //       try {
// // // //         final context = navigatorKey.currentContext;
// // // //         if (context == null) {
// // // //           debug("  Context is null, retrying in 500ms...");
// // // //           Future.delayed(const Duration(milliseconds: 500), () {
// // // //             _findAndNavigateToLead(leadPhone, whatsappSettingNumber);
// // // //           });
// // // //           return;
// // // //         }

// // // //         // Get LeadListViewModel
// // // //         final leadListVm =
// // // //             Provider.of<LeadListViewModel>(context, listen: false);

// // // //         // Fetch leads if not already fetched
// // // //         if (leadListVm.viewModels.isEmpty) {
// // // //           await leadListVm.fetch();
// // // //           await Future.delayed(const Duration(milliseconds: 300));
// // // //         }

// // // //         LeadModel? matchedModel;
// // // //         final List<LeadModel> pinnedLeads = [];

// // // //         debug("  Searching for lead with phone: $leadPhone");

// // // //         for (var viewModel in leadListVm.viewModels) {
// // // //           final leadmodel = viewModel.model;

// // // //           if (leadmodel?.records != null) {
// // // //             for (var record in leadmodel!.records!) {
// // // //               debug("Checking lead: ${record.full_number}");

// // // //               // Add pinned leads
// // // //               if (record.pinned == true) {
// // // //                 pinnedLeads.add(record);
// // // //               }

// // // //               // Match lead by phone number
// // // //               if (record.full_number != null) {
// // // //                 // Clean phone numbers for comparison
// // // //                 String recordPhone = record.full_number!.trim();
// // // //                 String searchPhone = leadPhone.trim();

// // // //                 // Remove +91 if present for comparison
// // // //                 if (recordPhone.startsWith('+91')) {
// // // //                   recordPhone = recordPhone.substring(3);
// // // //                 }
// // // //                 if (searchPhone.startsWith('+91')) {
// // // //                   searchPhone = searchPhone.substring(3);
// // // //                 }

// // // //                 // Also try with +91 prefix
// // // //                 String recordPhoneWithPrefix = '+91$recordPhone';
// // // //                 String searchPhoneWithPrefix = '+91$searchPhone';

// // // //                 if (record.full_number == leadPhone ||
// // // //                     record.full_number == searchPhoneWithPrefix ||
// // // //                     recordPhone == searchPhone ||
// // // //                     recordPhoneWithPrefix == leadPhone) {
// // // //                   matchedModel = record;
// // // //                   debug(
// // // //                       "  Found matching lead: ${record.contactname} - ${record.full_number}");
// // // //                   break;
// // // //                 }
// // // //               }
// // // //             }
// // // //           }

// // // //           if (matchedModel != null) break;
// // // //         }

// // // //         if (matchedModel == null) {
// // // //           debug("  No matching lead found for phone: $leadPhone");
// // // //           // Create a dummy lead with the phone number
// // // //           matchedModel = LeadModel(
// // // //             id: whatsappSettingNumber,
// // // //             contactname: leadPhone,
// // // //             full_number: leadPhone,
// // // //             pinned: false,
// // // //             // is_archived: false,
// // // //           );
// // // //           debug(" Using dummy lead with phone number");
// // // //         }

// // // //         // Navigate to chat screen
// // // //         _navigateToChatScreen(matchedModel, pinnedLeads, whatsappSettingNumber);
// // // //       } catch (e) {
// // // //         debug("  Error finding lead: $e");
// // // //       }
// // // //     });
// // // //   }

// // // //   void _navigateToWhatsAppChat(BuildContext context, LeadModel matchedModel,
// // // //       List<LeadModel> pinnedLeads) {
// // // //     debug("💚 Navigating to WhatsApp Chat Screen");

// // // //     Navigator.push(
// // // //       context,
// // // //       MaterialPageRoute(
// // // //         builder: (_) => WhatsappChatScreen(
// // // //           leadName:
// // // //               matchedModel.contactname ?? matchedModel.full_number ?? "Unknown",
// // // //           wpnumber: matchedModel.full_number ?? "",
// // // //           id: matchedModel.id ?? matchedModel.full_number ?? "",
// // // //           model: matchedModel,
// // // //           pinnedLeads: pinnedLeads,
// // // //         ),
// // // //       ),
// // // //     );

// // // //     pendingDeepLink = null;
// // // //     debug("🎉 WhatsApp navigation successful!");
// // // //   }

// // // //   Future<void> _navigateToChatScreen(LeadModel matchedModel,
// // // //       List<LeadModel> pinnedLeads, String? objectType) async {
// // // //     try {
// // // //       final context = navigatorKey.currentContext;
// // // //       if (context == null) {
// // // //         debug("  Context is null for navigation");
// // // //         return;
// // // //       }

// // // //       final currentRoute = ModalRoute.of(context);
// // // //       if (currentRoute?.settings.name?.contains('chat') == true) {
// // // //         debug(" Already on chat screen");
// // // //         pendingDeepLink = null;
// // // //         return;
// // // //       }

// // // //       debug("📊 Navigation Details:");
// // // //       debug("   Lead Name: ${matchedModel.contactname}");
// // // //       debug("   Lead Phone: ${matchedModel.full_number}");
// // // //       debug("   ID: ${matchedModel.id}");
// // // //       debug("   Object Type: $objectType");
// // // //       debug("   Pinned Leads: ${pinnedLeads.length}");

// // // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //       String sfAccessToken =
// // // //           prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";
// // // //       debug("message: Salesforce Access Token = $sfAccessToken");
// // // //       bool isSalesforceUrl = objectType != null &&
// // // //           ['lead', 'contact', 'opportunity'].contains(objectType.toLowerCase());
// // // //       debug("isSalesforceUrl: $isSalesforceUrl");
// // // //       bool isWhatsappUrl =
// // // //           objectType == null || objectType.toLowerCase() == 'whatsapp';

// // // //       debug("🔗 Salesforce Token Present: ${sfAccessToken.isNotEmpty}");
// // // //       debug("🏷️ Is Salesforce URL: $isSalesforceUrl");
// // // //       debug("💬 Is WhatsApp URL: $isWhatsappUrl");

// // // //       if (isSalesforceUrl && sfAccessToken.isNotEmpty) {
// // // //         debug("🚀 Navigating to Salesforce Chat Screen for $objectType");

// // // //         try {
// // // //           String sObjectName = '';
// // // //           switch (objectType.toLowerCase()) {
// // // //             case 'lead':
// // // //               sObjectName = 'Lead';
// // // //               break;
// // // //             case 'contact':
// // // //               sObjectName = 'Contact';
// // // //               break;
// // // //             case 'opportunity':
// // // //               sObjectName = 'Opportunity';
// // // //               break;
// // // //             default:
// // // //               sObjectName = 'Lead';
// // // //           }

// // // //           debug("📞 Making API call for sObject: $sObjectName");

// // // //           //   ACTUAL NAVIGATION TO SALESFORCE CHAT SCREEN ADDED HERE
// // // //           _navigateToSalesforceChat(
// // // //               context, matchedModel, pinnedLeads, sObjectName);

// // // //           pendingDeepLink = null;
// // // //           debug("🎉 Salesforce navigation successful for $objectType!");
// // // //         } catch (e) {
// // // //           debug("  Salesforce API/ Navigation error: $e");

// // // //           _navigateToWhatsAppChat(context, matchedModel, pinnedLeads);
// // // //         }
// // // //       } else if (isWhatsappUrl || (isSalesforceUrl && sfAccessToken.isEmpty)) {
// // // //         if (isSalesforceUrl && sfAccessToken.isEmpty) {
// // // //           debug("🔐 Salesforce token missing - falling back to WhatsApp chat");
// // // //           ScaffoldMessenger.of(context).showSnackBar(
// // // //             SnackBar(
// // // //               content: Text('Please login to Salesforce for $objectType chat'),
// // // //               duration: Duration(seconds: 2),
// // // //             ),
// // // //           );
// // // //         }

// // // //         _navigateToWhatsAppChat(context, matchedModel, pinnedLeads);
// // // //       } else {
// // // //         debug(" Unknown URL pattern - falling back to WhatsApp chat");
// // // //         _navigateToWhatsAppChat(context, matchedModel, pinnedLeads);
// // // //       }
// // // //     } catch (e) {
// // // //       debug("  Navigation error: $e");
// // // //       // Final fallback
// // // //       final context = navigatorKey.currentContext;
// // // //       if (context != null) {
// // // //         _navigateToWhatsAppChat(context, matchedModel, pinnedLeads);
// // // //       }
// // // //     }
// // // //   }

// // // //   void _navigateToSalesforceChat(
// // // //     BuildContext context,
// // // //     LeadModel matchedModel,
// // // //     List<LeadModel> pinnedLeads,
// // // //     String sObjectName,
// // // //   ) {
// // // //     debug("💙 Navigating to Salesforce Chat Screen for $sObjectName");

// // // //     // Convert pinnedLeads (List<LeadModel>) to List<SfDrawerItemModel> if needed
// // // //     List<SfDrawerItemModel> sfPinnedLeads = [];

// // // //     Navigator.push(
// // // //       context,
// // // //       MaterialPageRoute(
// // // //         builder: (_) => SfMessageChatScreen(
// // // //           // Pass required parameters
// // // //           pinnedLeadsList: sfPinnedLeads,
// // // //           isFromRecentChat: false,
// // // //           // You might need to pass additional data like:
// // // //           // leadId: matchedModel.id,
// // // //           // leadPhone: matchedModel.full_number,
// // // //           // leadName: matchedModel.contactname,
// // // //           // sObjectType: sObjectName,
// // // //         ),
// // // //       ),
// // // //     );

// // // //     pendingDeepLink = null;
// // // //     debug("🎉 Salesforce Chat Screen navigation completed!");
// // // //   }

// // // //   /// 🔹 Navigate to chat screen
// // // //   // void _navigateToChatScreen(LeadModel matchedModel,
// // // //   //     List<LeadModel> pinnedLeads, String whatsappSettingNumber) {
// // // //   //   try {
// // // //   //     final context = navigatorKey.currentContext;
// // // //   //     if (context == null) {
// // // //   //       debug("  Context is null for navigation");
// // // //   //       return;
// // // //   //     }

// // // //   //     // Check if already on chat screen with same number
// // // //   //     final currentRoute = ModalRoute.of(context);
// // // //   //     if (currentRoute?.settings.name?.contains('chat') == true) {
// // // //   //       debug(" Already on chat screen");
// // // //   //       pendingDeepLink = null;
// // // //   //       return;
// // // //   //     }

// // // //   //     debug("  Navigating to WhatsappChatScreen with:");
// // // //   //     debug("   Lead Name: ${matchedModel.contactname}");
// // // //   //     debug("   Lead Phone: ${matchedModel.full_number}");
// // // //   //     debug("   ID: ${matchedModel.id}");
// // // //   //     debug("   Pinned Leads: ${pinnedLeads.length}");

// // // //   //     Navigator.push(
// // // //   //       context,
// // // //   //       MaterialPageRoute(
// // // //   //         builder: (_) => WhatsappChatScreen(
// // // //   //           leadName: matchedModel.contactname ??
// // // //   //               matchedModel.full_number ??
// // // //   //               "Unknown",
// // // //   //           wpnumber: matchedModel.full_number ?? "",
// // // //   //           id: matchedModel.id ?? whatsappSettingNumber,
// // // //   //           model: matchedModel,
// // // //   //           pinnedLeads: pinnedLeads,
// // // //   //           // isArch: matchedModel.is_archived ?? false,
// // // //   //         ),
// // // //   //       ),
// // // //   //     );

// // // //   //     pendingDeepLink = null;
// // // //   //     debug("🎉 Navigation successful!");
// // // //   //   } catch (e) {
// // // //   //     debug("  Navigation error: $e");
// // // //   //   }
// // // //   // }

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

// // // // // import 'dart:convert';
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
// // // // // import 'package:whatsapp/models/lead_model.dart';
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
// // // // //     debug("  Error in main(): $e");
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

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();

// // // // //     try {
// // // // //       debug("🚀 AppLinks initialized");
// // // // //       _appLinks = AppLinks();
// // // // //       _handleInitialUri();
// // // // //       _listenToUriStream();

// // // // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // //         if (mounted) {
// // // // //           setState(() {
// // // // //             _isAppInitialized = true;
// // // // //           });
// // // // //           _processPendingDeepLink();
// // // // //         }
// // // // //       });
// // // // //     } catch (e) {
// // // // //       debug("  Error in MyApp initState: $e");
// // // // //     }
// // // // //   }

// // // // //   /// 🔹 App killed state
// // // // //   Future<void> _handleInitialUri() async {
// // // // //     try {
// // // // //       final Uri? initialUri = await _appLinks.getInitialLink();
// // // // //       debug("📌 Initial URI => $initialUri");

// // // // //       if (initialUri != null) {
// // // // //         pendingDeepLink = initialUri;
// // // // //         _processPendingDeepLink();
// // // // //       }
// // // // //     } catch (e) {
// // // // //       debug("  Initial URI error: $e");
// // // // //     }
// // // // //   }

// // // // //   /// 🔹 Background / foreground
// // // // //   void _listenToUriStream() {
// // // // //     _linkSubscription = _appLinks.uriLinkStream.listen(
// // // // //       (Uri uri) {
// // // // //         debug("🔗 Stream URI => $uri");
// // // // //         pendingDeepLink = uri;
// // // // //         _processPendingDeepLink();
// // // // //       },
// // // // //       onError: (err) {
// // // // //         debug("  URI Stream error: $err");
// // // // //       },
// // // // //     );
// // // // //   }

// // // // //   /// 🔹 Process pending deep link
// // // // //   void _processPendingDeepLink() {
// // // // //     if (!_isAppInitialized || pendingDeepLink == null) return;

// // // // //     _processDeepLink();
// // // // //   }

// // // // //   void _processDeepLink() async {
// // // // //     try {
// // // // //       if (pendingDeepLink == null) {
// // // // //         debug(" No pending deep link to process");
// // // // //         return;
// // // // //       }

// // // // //       final uri = pendingDeepLink!;
// // // // //       final uriString = uri.toString();
// // // // //       debug("➡️ Processing DeepLink: $uriString");

// // // // //       // Extract phone number from new URL pattern: /chat/917740989118
// // // // //       final String leadPhone = _extractLeadPhoneFromUrl(uriString);

// // // // //       if (leadPhone.isEmpty) {
// // // // //         debug("  No phone number found in URL");
// // // // //         return;
// // // // //       }

// // // // //       debug(" Extracted from URL:");
// // // // //       debug("   Lead Phone: $leadPhone");

// // // // //       // Find matching lead from LeadListViewModel
// // // // //       await _findAndNavigateToLead(leadPhone);
// // // // //     } catch (e) {
// // // // //       debug("  Error in _processDeepLink: $e");
// // // // //     }
// // // // //   }

// // // // //   /// 🔹 Extract lead phone number from URL - NEW PATTERN: /chat/917740989118
// // // // //   String _extractLeadPhoneFromUrl(String url) {
// // // // //     try {
// // // // //       debug("  Extracting phone number from URL: $url");

// // // // //       // NEW PATTERN: /chat/917740989118
// // // // //       final RegExp phoneRegex = RegExp(r'/chat/(\+?\d+)');
// // // // //       final Match? match = phoneRegex.firstMatch(url);

// // // // //       if (match != null && match.group(1) != null) {
// // // // //         String phone = match.group(1)!;

// // // // //         // Ensure it has +91 prefix if not already
// // // // //         if (!phone.startsWith('+') && phone.length == 10) {
// // // // //           phone = '+91$phone';
// // // // //         } else if (!phone.startsWith('+91') && phone.startsWith('91') && phone.length == 12) {
// // // // //           phone = '+$phone';
// // // // //         }

// // // // //         debug("  Found phone in URL path: $phone");
// // // // //         return phone;
// // // // //       }

// // // // //       // Also try alternative pattern
// // // // //       final RegExp altRegex = RegExp(r'chat/(\d{10,12})');
// // // // //       final Match? altMatch = altRegex.firstMatch(url);

// // // // //       if (altMatch != null && altMatch.group(1) != null) {
// // // // //         String phone = altMatch.group(1)!;

// // // // //         // Format the phone number
// // // // //         if (phone.length == 10) {
// // // // //           phone = '+91$phone';
// // // // //         } else if (phone.length == 12 && phone.startsWith('91')) {
// // // // //           phone = '+$phone';
// // // // //         }

// // // // //         debug("  Found phone with alt pattern: $phone");
// // // // //         return phone;
// // // // //       }

// // // // //       debug("  No phone number found in URL");
// // // // //       return "";
// // // // //     } catch (e) {
// // // // //       debug("  Error extracting phone from URL: $e");
// // // // //       return "";
// // // // //     }
// // // // //   }

// // // // //   /// 🔹 Find lead from LeadListViewModel and navigate
// // // // //   Future<void> _findAndNavigateToLead(String leadPhone) async {
// // // // //     WidgetsBinding.instance.addPostFrameCallback((_) async {
// // // // //       try {
// // // // //         final context = navigatorKey.currentContext;
// // // // //         if (context == null) {
// // // // //           debug("  Context is null, retrying in 500ms...");
// // // // //           Future.delayed(const Duration(milliseconds: 500), () {
// // // // //             _findAndNavigateToLead(leadPhone);
// // // // //           });
// // // // //           return;
// // // // //         }

// // // // //         // Get LeadListViewModel
// // // // //         final leadListVm = Provider.of<LeadListViewModel>(context, listen: false);

// // // // //         // Fetch leads if not already fetched
// // // // //         if (leadListVm.viewModels.isEmpty) {
// // // // //           await leadListVm.fetch();
// // // // //           await Future.delayed(const Duration(milliseconds: 300));
// // // // //         }

// // // // //         LeadModel? matchedModel;
// // // // //         final List<LeadModel> pinnedLeads = [];

// // // // //         debug("  Searching for lead with phone: $leadPhone");

// // // // //         for (var viewModel in leadListVm.viewModels) {
// // // // //           final leadmodel = viewModel.model;

// // // // //           if (leadmodel?.records != null) {
// // // // //             for (var record in leadmodel!.records!) {
// // // // //               debug("Checking lead: ${record.full_number}");

// // // // //               // Add pinned leads
// // // // //               if (record.pinned == true) {
// // // // //                 pinnedLeads.add(record);
// // // // //               }

// // // // //               // Match lead by phone number
// // // // //               if (record.full_number != null) {
// // // // //                 // Clean phone numbers for comparison
// // // // //                 String recordPhone = record.full_number!.trim();
// // // // //                 String searchPhone = leadPhone.trim();

// // // // //                 // Remove +91 if present for comparison
// // // // //                 String recordPhoneWithoutPrefix = recordPhone;
// // // // //                 String searchPhoneWithoutPrefix = searchPhone;

// // // // //                 if (recordPhone.startsWith('+91')) {
// // // // //                   recordPhoneWithoutPrefix = recordPhone.substring(3);
// // // // //                 }
// // // // //                 if (searchPhone.startsWith('+91')) {
// // // // //                   searchPhoneWithoutPrefix = searchPhone.substring(3);
// // // // //                 }

// // // // //                 // Try multiple matching patterns
// // // // //                 bool isMatch =
// // // // //                     recordPhone == searchPhone ||
// // // // //                     recordPhoneWithoutPrefix == searchPhoneWithoutPrefix ||
// // // // //                     recordPhone == '+91$searchPhoneWithoutPrefix' ||
// // // // //                     '+91$recordPhoneWithoutPrefix' == searchPhone ||
// // // // //                     recordPhone == '91$searchPhoneWithoutPrefix' ||
// // // // //                     '91$recordPhoneWithoutPrefix' == searchPhone;

// // // // //                 if (isMatch) {
// // // // //                   matchedModel = record;
// // // // //                   debug("  Found matching lead: ${record.contactname} - ${record.full_number}");
// // // // //                   break;
// // // // //                 }
// // // // //               }
// // // // //             }
// // // // //           }

// // // // //           if (matchedModel != null) break;
// // // // //         }

// // // // //         if (matchedModel == null) {
// // // // //           debug("  No matching lead found for phone: $leadPhone");
// // // // //           // Create a dummy lead with the phone number
// // // // //           matchedModel = LeadModel(
// // // // //             id: leadPhone, // Use phone as ID
// // // // //             contactname: leadPhone,
// // // // //             full_number: leadPhone,
// // // // //             pinned: false,
// // // // //           );
// // // // //           debug(" Using dummy lead with phone number");
// // // // //         }

// // // // //         // Navigate to chat screen
// // // // //         _navigateToChatScreen(matchedModel, pinnedLeads);
// // // // //       } catch (e) {
// // // // //         debug("  Error finding lead: $e");
// // // // //       }
// // // // //     });
// // // // //   }

// // // // //   /// 🔹 Navigate to chat screen
// // // // //   void _navigateToChatScreen(LeadModel matchedModel, List<LeadModel> pinnedLeads) {
// // // // //     try {
// // // // //       final context = navigatorKey.currentContext;
// // // // //       if (context == null) {
// // // // //         debug("  Context is null for navigation");
// // // // //         return;
// // // // //       }

// // // // //       // Check if already on chat screen with same number
// // // // //       final currentRoute = ModalRoute.of(context);
// // // // //       if (currentRoute?.settings.name?.contains('chat') == true) {
// // // // //         debug(" Already on chat screen");
// // // // //         pendingDeepLink = null;
// // // // //         return;
// // // // //       }

// // // // //       debug("  Navigating to WhatsappChatScreen with:");
// // // // //       debug("   Lead Name: ${matchedModel.contactname}");
// // // // //       debug("   Lead Phone: ${matchedModel.full_number}");
// // // // //       debug("   ID: ${matchedModel.id}");
// // // // //       debug("   Pinned Leads: ${pinnedLeads.length}");

// // // // //       Navigator.push(
// // // // //         context,
// // // // //         MaterialPageRoute(
// // // // //           builder: (_) => WhatsappChatScreen(
// // // // //             leadName: matchedModel.contactname ?? matchedModel.full_number ?? "Unknown",
// // // // //             wpnumber: matchedModel.full_number ?? "",
// // // // //             id: matchedModel.id ?? matchedModel.full_number ?? "",
// // // // //             model: matchedModel,
// // // // //             pinnedLeads: pinnedLeads,
// // // // //           ),
// // // // //         ),
// // // // //       );

// // // // //       pendingDeepLink = null;
// // // // //       debug("🎉 Navigation successful!");
// // // // //     } catch (e) {
// // // // //       debug("  Navigation error: $e");
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
// // // // //       _processPendingDeepLink();
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

// // // import 'dart:async';
// // // import 'dart:convert';

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
// // // import 'package:whatsapp/models/lead_model.dart';
// // // import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
// // // import 'package:whatsapp/salesforce/screens/sf_message_chat_screen.dart';
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
// // //     debug("  Error in main(): $e");
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
// // //           _processPendingDeepLink();
// // //         }
// // //       });
// // //     } catch (e) {
// // //       debug("  Error in MyApp initState: $e");
// // //     }
// // //   }

// // //   /// 🔹 App killed state
// // //   Future<void> _handleInitialUri() async {
// // //     try {
// // //       final Uri? initialUri = await _appLinks.getInitialLink();
// // //       debug("📌 Initial URI => $initialUri");

// // //       if (initialUri != null) {
// // //         pendingDeepLink = initialUri;
// // //         _processPendingDeepLink();
// // //       }
// // //     } catch (e) {
// // //       debug("  Initial URI error: $e");
// // //     }
// // //   }

// // //   /// 🔹 Background / foreground
// // //   void _listenToUriStream() {
// // //     _linkSubscription = _appLinks.uriLinkStream.listen(
// // //       (Uri uri) {
// // //         debug("🔗 Stream URI => $uri");
// // //         pendingDeepLink = uri;
// // //         _processPendingDeepLink();
// // //       },
// // //       onError: (err) {
// // //         debug("  URI Stream error: $err");
// // //       },
// // //     );
// // //   }

// // //   /// 🔹 Process pending deep link
// // //   void _processPendingDeepLink() {
// // //     if (!_isAppInitialized || pendingDeepLink == null) return;

// // //     _processDeepLink();
// // //   }

// // //  void _processDeepLink() async {
// // //   try {
// // //     if (pendingDeepLink == null) {
// // //       debug(" No pending deep link to process");
// // //       return;
// // //     }

// // //     final uri = pendingDeepLink!;
// // //     final uriString = uri.toString();

// // //     debug("=" * 50);
// // //     debug("🔗 FULL URL ANALYSIS");
// // //     debug("=" * 50);
// // //     debug("📌 Complete URI: $uri");
// // //     debug("📌 URI.toString(): $uriString");
// // //     debug("📌 Path: ${uri.path}");
// // //     debug("📌 Path Segments: ${uri.pathSegments}");
// // //     debug("📌 Host: ${uri.host}");
// // //     debug("📌 Scheme: ${uri.scheme}");
// // //     debug("📌 Query: ${uri.query}");
// // //     debug("=" * 50);

// // //     final String leadPhone = _extractLeadPhoneFromUrl(uriString);

// // //     if (leadPhone.isEmpty) {
// // //       debug("  No phone number found in URL");
// // //       return;
// // //     }

// // //     // Extract object type from URL (Lead, Contact, Opportunity, or whatsapp)
// // //     final String objectType = _extractObjectTypeFromUrl(uriString);

// // //     debug(" Extracted from URL:");
// // //     debug("   Lead Phone: $leadPhone");
// // //     debug("   Object Type: $objectType");

// // //     // Find matching lead from LeadListViewModel
// // //     await _findAndNavigateToLead(leadPhone, objectType);
// // //   } catch (e) {
// // //     debug("  Error in _processDeepLink: $e");
// // //   }
// // // }
// // //   /// 🔹 Extract lead phone number from URL
// // //   String _extractLeadPhoneFromUrl(String url) {
// // //     try {
// // //       debug("  Extracting phone number from URL: $url");

// // //       // Salesforce URL: /Lead/chat/{phone}
// // //       final RegExp leadChatRegex = RegExp(r'/Lead/chat/(\d+)');
// // //       final Match? leadMatch = leadChatRegex.firstMatch(url);
// // //       if (leadMatch != null && leadMatch.group(1) != null) {
// // //         String phone = leadMatch.group(1)!;
// // //         // Ensure it has +91 prefix
// // //         if (!phone.startsWith('+91') && !phone.startsWith('+')) {
// // //           return '+91$phone';
// // //         }
// // //         return phone;
// // //       }

// // //       // Salesforce URL: /Contact/chat/{phone}
// // //       final RegExp contactChatRegex = RegExp(r'/Contact/chat/(\d+)');
// // //       final Match? contactMatch = contactChatRegex.firstMatch(url);
// // //       if (contactMatch != null && contactMatch.group(1) != null) {
// // //         String phone = contactMatch.group(1)!;
// // //         if (!phone.startsWith('+91') && !phone.startsWith('+')) {
// // //           return '+91$phone';
// // //         }
// // //         return phone;
// // //       }

// // //       // Salesforce URL: /Opportunity/chat/{phone}
// // //       final RegExp opportunityChatRegex = RegExp(r'/Opportunity/chat/(\d+)');
// // //       final Match? opportunityMatch = opportunityChatRegex.firstMatch(url);
// // //       if (opportunityMatch != null && opportunityMatch.group(1) != null) {
// // //         String phone = opportunityMatch.group(1)!;
// // //         if (!phone.startsWith('+91') && !phone.startsWith('+')) {
// // //           return '+91$phone';
// // //         }
// // //         return phone;
// // //       }

// // //       // Node.js URL: /chat/{phone}
// // //       final RegExp nodeChatRegex = RegExp(r'/chat/(\d+)');
// // //       final Match? nodeMatch = nodeChatRegex.firstMatch(url);
// // //       if (nodeMatch != null && nodeMatch.group(1) != null) {
// // //         String phone = nodeMatch.group(1)!;
// // //         if (!phone.startsWith('+91') && !phone.startsWith('+')) {
// // //           return '+91$phone';
// // //         }
// // //         return phone;
// // //       }

// // //       // Try with query parameter format
// // //       final RegExp queryRegex = RegExp(r'phone=(\+?\d+)');
// // //       final Match? queryMatch = queryRegex.firstMatch(url);
// // //       if (queryMatch != null && queryMatch.group(1) != null) {
// // //         String phone = queryMatch.group(1)!;
// // //         if (!phone.startsWith('+91') && !phone.startsWith('+')) {
// // //           return '+91$phone';
// // //         }
// // //         return phone;
// // //       }

// // //       debug("  No phone number found in URL");
// // //       return "";
// // //     } catch (e) {
// // //       debug("  Error extracting phone from URL: $e");
// // //       return "";
// // //     }
// // //   }

// // //   /// 🔹 Extract object type from URL (Lead, Contact, Opportunity)
// // //   String _extractObjectTypeFromUrl(String url) {
// // //     try {
// // //       debug("  Extracting object type from URL");

// // //       if (url.contains('/Lead/chat/')) {
// // //         return 'lead';
// // //       } else if (url.contains('/Contact/chat/')) {
// // //         return 'contact';
// // //       } else if (url.contains('/Opportunity/chat/')) {
// // //         return 'opportunity';
// // //       } else if (url.contains('/chat/')) {
// // //         return 'whatsapp'; // Regular WhatsApp chat
// // //       }

// // //       debug(" No object type found in URL");
// // //       return "whatsapp"; // Default to whatsapp
// // //     } catch (e) {
// // //       debug("  Error extracting object type: $e");
// // //       return "whatsapp";
// // //     }
// // //   }

// // //   /// 🔹 Find lead from LeadListViewModel and navigate
// // //   Future<void> _findAndNavigateToLead(
// // //       String leadPhone, String objectType) async {
// // //     WidgetsBinding.instance.addPostFrameCallback((_) async {
// // //       try {
// // //         final context = navigatorKey.currentContext;
// // //         if (context == null) {
// // //           debug("  Context is null, retrying in 500ms...");
// // //           Future.delayed(const Duration(milliseconds: 500), () {
// // //             _findAndNavigateToLead(leadPhone, objectType);
// // //           });
// // //           return;
// // //         }

// // //         // Get LeadListViewModel
// // //         final leadListVm =
// // //             Provider.of<LeadListViewModel>(context, listen: false);

// // //         // Fetch leads if not already fetched
// // //         if (leadListVm.viewModels.isEmpty) {
// // //           await leadListVm.fetch();
// // //           await Future.delayed(const Duration(milliseconds: 300));
// // //         }

// // //         LeadModel? matchedModel;
// // //         final List<LeadModel> pinnedLeads = [];

// // //         debug("  Searching for lead with phone: $leadPhone");

// // //         for (var viewModel in leadListVm.viewModels) {
// // //           final leadmodel = viewModel.model;

// // //           if (leadmodel?.records != null) {
// // //             for (var record in leadmodel!.records!) {
// // //               debug("Checking lead: ${record.full_number}");

// // //               // Add pinned leads
// // //               if (record.pinned == true) {
// // //                 pinnedLeads.add(record);
// // //               }

// // //               // Match lead by phone number
// // //               if (record.full_number != null) {
// // //                 // Clean phone numbers for comparison
// // //                 String recordPhone = record.full_number!.trim();
// // //                 String searchPhone = leadPhone.trim();

// // //                 // Remove +91 if present for comparison
// // //                 if (recordPhone.startsWith('+91')) {
// // //                   recordPhone = recordPhone.substring(3);
// // //                 }
// // //                 if (searchPhone.startsWith('+91')) {
// // //                   searchPhone = searchPhone.substring(3);
// // //                 }

// // //                 // Also try with +91 prefix
// // //                 String recordPhoneWithPrefix = '+91$recordPhone';
// // //                 String searchPhoneWithPrefix = '+91$searchPhone';

// // //                 if (record.full_number == leadPhone ||
// // //                     record.full_number == searchPhoneWithPrefix ||
// // //                     recordPhone == searchPhone ||
// // //                     recordPhoneWithPrefix == leadPhone) {
// // //                   matchedModel = record;
// // //                   debug(
// // //                       "  Found matching lead: ${record.contactname} - ${record.full_number}");
// // //                   break;
// // //                 }
// // //               }
// // //             }
// // //           }

// // //           if (matchedModel != null) break;
// // //         }

// // //         if (matchedModel == null) {
// // //           debug("  No matching lead found for phone: $leadPhone");
// // //           // Create a dummy lead with the phone number
// // //           matchedModel = LeadModel(
// // //             id: leadPhone, // Use phone as ID for dummy lead
// // //             contactname: leadPhone,
// // //             full_number: leadPhone,
// // //             pinned: false,
// // //           );
// // //           debug(" Using dummy lead with phone number");
// // //         }

// // //         // Navigate to chat screen
// // //         _navigateToChatScreen(matchedModel, pinnedLeads, objectType);
// // //       } catch (e) {
// // //         debug("  Error finding lead: $e");
// // //       }
// // //     });
// // //   }

// // //   void _navigateToWhatsAppChat(BuildContext context, LeadModel matchedModel,
// // //       List<LeadModel> pinnedLeads) {
// // //     debug("💚 Navigating to WhatsApp Chat Screen");

// // //     Navigator.push(
// // //       context,
// // //       MaterialPageRoute(
// // //         builder: (_) => WhatsappChatScreen(
// // //           leadName:
// // //               matchedModel.contactname ?? matchedModel.full_number ?? "Unknown",
// // //           wpnumber: matchedModel.full_number ?? "",
// // //           id: matchedModel.id ?? matchedModel.full_number ?? "",
// // //           model: matchedModel,
// // //           pinnedLeads: pinnedLeads,
// // //         ),
// // //       ),
// // //     );

// // //     pendingDeepLink = null;
// // //     debug("🎉 WhatsApp navigation successful!");
// // //   }

// // //     Future<void> _navigateToChatScreen(LeadModel matchedModel,
// // //         List<LeadModel> pinnedLeads, String objectType) async {
// // //       try {
// // //         final context = navigatorKey.currentContext;
// // //         if (context == null) {
// // //           debug("  Context is null for navigation");
// // //           return;
// // //         }

// // //         final currentRoute = ModalRoute.of(context);
// // //         if (currentRoute?.settings.name?.contains('chat') == true) {
// // //           debug(" Already on chat screen");
// // //           pendingDeepLink = null;
// // //           return;
// // //         }

// // //         debug("📊 Navigation Details:");
// // //         debug("   Lead Name: ${matchedModel.contactname}");
// // //         debug("   Lead Phone: ${matchedModel.full_number}");
// // //         debug("   ID: ${matchedModel.id}");
// // //         debug("   Object Type: $objectType");
// // //         debug("   Pinned Leads: ${pinnedLeads.length}");

// // //         SharedPreferences prefs = await SharedPreferences.getInstance();
// // //         String sfAccessToken =
// // //             prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";
// // //         debug("message: Salesforce Access Token = $sfAccessToken");

// // //         bool isSalesforceUrl = objectType != null &&
// // //             ['lead', 'contact', 'opportunity'].contains(objectType.toLowerCase());
// // //         debug("isSalesforceUrl: $isSalesforceUrl");
// // //         bool isWhatsappUrl = objectType == null || objectType.toLowerCase() == 'whatsapp';

// // //         debug("🔗 Salesforce Token Present: ${sfAccessToken.isNotEmpty}");
// // //         debug("🏷️ Is Salesforce URL: $isSalesforceUrl");
// // //         debug("💬 Is WhatsApp URL: $isWhatsappUrl");

// // //         if (isSalesforceUrl && sfAccessToken.isNotEmpty) {
// // //           debug("🚀 Navigating to Salesforce Chat Screen for $objectType");

// // //           try {
// // //             String sObjectName = '';
// // //             switch (objectType.toLowerCase()) {
// // //               case 'lead':
// // //                 sObjectName = 'Lead';
// // //                 break;
// // //               case 'contact':
// // //                 sObjectName = 'Contact';
// // //                 break;
// // //               case 'opportunity':
// // //                 sObjectName = 'Opportunity';
// // //                 break;
// // //               default:
// // //                 sObjectName = 'Lead';
// // //             }

// // //             debug("📞 Making API call for sObject: $sObjectName");

// // //             _navigateToSalesforceChat(
// // //                 context, matchedModel, pinnedLeads, sObjectName, leadPhone: matchedModel.full_number ?? "");

// // //             pendingDeepLink = null;
// // //             debug("🎉 Salesforce navigation successful for $objectType!");
// // //           } catch (e) {
// // //             debug("  Salesforce API/ Navigation error: $e");

// // //             _navigateToWhatsAppChat(context, matchedModel, pinnedLeads);
// // //           }
// // //         } else if (isWhatsappUrl || (isSalesforceUrl && sfAccessToken.isEmpty)) {
// // //           if (isSalesforceUrl && sfAccessToken.isEmpty) {
// // //             debug("🔐 Salesforce token missing - falling back to WhatsApp chat");
// // //             ScaffoldMessenger.of(context).showSnackBar(
// // //               SnackBar(
// // //                 content: Text('Please login to Salesforce for $objectType chat'),
// // //                 duration: Duration(seconds: 2),
// // //               ),
// // //             );
// // //           }

// // //           _navigateToWhatsAppChat(context, matchedModel, pinnedLeads);
// // //         } else {
// // //           debug(" Unknown URL pattern - falling back to WhatsApp chat");
// // //           _navigateToWhatsAppChat(context, matchedModel, pinnedLeads);
// // //         }
// // //       } catch (e) {
// // //         debug("  Navigation error: $e");
// // //         // Final fallback
// // //         final context = navigatorKey.currentContext;
// // //         if (context != null) {
// // //           _navigateToWhatsAppChat(context, matchedModel, pinnedLeads);
// // //         }
// // //       }
// // //     }

// // //     void _navigateToSalesforceChat(
// // //       BuildContext context,
// // //       LeadModel matchedModel,
// // //       List<LeadModel> pinnedLeads,
// // //       String sObjectName, {
// // //       String leadPhone = "",
// // //     }) {
// // //       debug("💙 Navigating to Salesforce Chat Screen for $sObjectName");

// // //       // Convert pinnedLeads (List<LeadModel>) to List<SfDrawerItemModel> if needed
// // //       List<SfDrawerItemModel> sfPinnedLeads = [];

// // //       Navigator.push(
// // //         context,
// // //         MaterialPageRoute(
// // //           builder: (_) => SfMessageChatScreen(
// // //             // Pass required parameters
// // //             pinnedLeadsList: sfPinnedLeads,
// // //             isFromRecentChat: false,
// // //             // Pass lead data for pre-loading
// // //             // initialLeadData: {
// // //             //   'id': matchedModel.id,
// // //             //   'phone': matchedModel.full_number ?? leadPhone,
// // //             //   'name': matchedModel.contactname ?? leadPhone,
// // //             //   'sObjectType': sObjectName,
// // //             // },
// // //           ),
// // //         ),
// // //       );

// // //       pendingDeepLink = null;
// // //       debug("🎉 Salesforce Chat Screen navigation completed!");
// // //     }

// // //   @override
// // //   void dispose() {
// // //     _linkSubscription?.cancel();
// // //     super.dispose();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // //       _processPendingDeepLink();
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

// // import 'dart:async';
// // import 'dart:convert';

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
// // import 'package:whatsapp/models/lead_model.dart';
// // import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
// // import 'package:whatsapp/salesforce/screens/sf_message_chat_screen.dart';
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
// // import 'package:whatsapp/views/view/splash_view.dart';

// // import 'firebase_options.dart';

// // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// // final RouteObserver<ModalRoute<void>> routeObserver =
// //     RouteObserver<ModalRoute<void>>();

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
// //     debug(" Error in main(): $e");
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
// //       debug(" Error in MyApp initState: $e");
// //     }
// //   }

// //   Future<void> _handleInitialUri() async {
// //     try {
// //       final Uri? initialUri = await _appLinks.getInitialLink();
// //       debug("📌 Initial URI => $initialUri");

// //       if (initialUri != null) {
// //         pendingDeepLink = initialUri;
// //         _processPendingDeepLink();
// //       }
// //     } catch (e) {
// //       debug(" Error in _handleInitialUri: $e");
// //     }
// //   }

// //   void _listenToUriStream() {
// //     _linkSubscription = _appLinks.uriLinkStream.listen(
// //       (Uri uri) {
// //         debug("Stream URI => $uri");
// //         pendingDeepLink = uri;
// //         _processPendingDeepLink();
// //       },
// //       onError: (err) {
// //         debug(" Error in URI Stream: $err");
// //       },
// //     );
// //   }

// //   void _processPendingDeepLink() {
// //     if (!_isAppInitialized || pendingDeepLink == null) return;

// //     _processDeepLink();
// //   }

// //   void _processDeepLink() async {
// //     debug("hfghjkljhgjkljhgjkljhgjkljhg");
// //     try {
// //       if (pendingDeepLink == null) {
// //         debug(" No pending deep link to process");
// //         return;
// //       }

// //       final uri = pendingDeepLink!;
// //       final uriString = uri.toString();

// //       debug("=" * 50);
// //       debug("🔗 DEEP LINK PROCESSING");
// //       debug("=" * 50);
// //       debug("📌 Full URL: $uriString");
// //       debug("📌 Path: ${uri.path}");
// //       debug("📌 Path Segments: ${uri.pathSegments}");
// //       debug("=" * 50);

// //       final String leadPhone = _extractLeadPhoneFromUrl(uriString);
// //       final String objectType = _extractObjectTypeFromUrl(uriString);

// //       debug(" EXTRACTED INFORMATION:");
// //       debug("   Phone Number: $leadPhone");
// //       debug("   Object Type: $objectType");
// //       debug("=" * 50);

// //       if (leadPhone.isEmpty) {
// //         debug("  No phone number found in URL");
// //         return;
// //       }
// //       await _findAndNavigateToLead(leadPhone, objectType);
// //     } catch (e) {
// //       debug("  Error in _processDeepLink: $e");
// //     }
// //   }

// //   String _extractLeadPhoneFromUrl(String url) {
// //     try {
// //       debug("📞 Extracting phone from URL: $url");

// //       try {
// //         Uri uri = Uri.parse(url);
// //         List<String> segments = uri.pathSegments;

// //         if (segments.length >= 3) {
// //           for (int i = 0; i < segments.length - 1; i++) {
// //             if (segments[i].toLowerCase() == "chat" &&
// //                 i + 1 < segments.length) {
// //               String phone = segments[i + 1];
// //               debug("  Found phone in path segments: $phone");
// //               return phone;
// //             }
// //           }
// //         }
// //       } catch (e) {
// //         debug(" Could not parse URL: $e");
// //       }

// //       // Fallback to regex patterns
// //       // Pattern: /Lead/chat/91740989118
// //       final RegExp leadChatRegex = RegExp(r'/(?:Lead|lead)/chat/(\d{10,})');
// //       final Match? leadMatch = leadChatRegex.firstMatch(url);
// //       if (leadMatch != null && leadMatch.group(1) != null) {
// //         String phone = leadMatch.group(1)!;
// //         debug("  Found phone with Lead pattern: $phone");
// //         return phone;
// //       }

// //       // Pattern: /Contact/chat/91740989118
// //       final RegExp contactChatRegex =
// //           RegExp(r'/(?:Contact|contact)/chat/(\d{10,})');
// //       final Match? contactMatch = contactChatRegex.firstMatch(url);
// //       if (contactMatch != null && contactMatch.group(1) != null) {
// //         String phone = contactMatch.group(1)!;
// //         debug("  Found phone with Contact pattern: $phone");
// //         return phone;
// //       }

// //       // Pattern: /chat/91740989118
// //       final RegExp simpleChatRegex = RegExp(r'/chat/(\d{10,})');
// //       final Match? simpleMatch = simpleChatRegex.firstMatch(url);
// //       if (simpleMatch != null && simpleMatch.group(1) != null) {
// //         String phone = simpleMatch.group(1)!;
// //         debug("  Found phone with simple chat pattern: $phone");
// //         return phone;
// //       }

// //       debug("  No phone number found in URL");
// //       return "";
// //     } catch (e) {
// //       debug("  Error extracting phone from URL: $e");
// //       return "";
// //     }
// //   }

// //   String _extractObjectTypeFromUrl(String url) {
// //     try {
// //       debug("🏷️ Extracting object type from URL");
// //       try {
// //         Uri uri = Uri.parse(url);
// //         List<String> segments = uri.pathSegments;

// //         if (segments.isNotEmpty) {
// //           String firstSegment = segments[0].toLowerCase();

// //           if (firstSegment == "lead") {
// //             debug("  Object type: lead");
// //             return "lead";
// //           } else if (firstSegment == "contact") {
// //             debug("  Object type: contact");
// //             return "contact";
// //           } else if (firstSegment == "opportunity") {
// //             debug("  Object type: opportunity");
// //             return "opportunity";
// //           } else if (firstSegment == "chat") {
// //             debug("  Object type: whatsapp");
// //             return "Lead";
// //           }
// //         }
// //       } catch (e) {
// //         debug(" Could not parse URL for object type: $e");
// //       }

// //       // Fallback to string matching
// //       if (url.toLowerCase().contains('/lead/chat/')) {
// //         debug("  Object type: lead (string match)");
// //         return 'lead';
// //       } else if (url.toLowerCase().contains('/contact/chat/')) {
// //         debug("  Object type: contact (string match)");
// //         return 'contact';
// //       } else if (url.toLowerCase().contains('/opportunity/chat/')) {
// //         debug("  Object type: opportunity (string match)");
// //         return 'opportunity';
// //       } else if (url.toLowerCase().contains('/chat/')) {
// //         debug("  Object type: whatsapp (string match)");
// //         return 'whatsapp';
// //       }

// //       debug(" No object type found, defaulting to whatsapp");
// //       return "whatsapp";
// //     } catch (e) {
// //       debug("  Error extracting object type: $e");
// //       return "whatsapp";
// //     }
// //   }

// //   // Future<void> _findAndNavigateToLead(
// //   //     String leadPhone, String objectType) async {
// //   //   WidgetsBinding.instance.addPostFrameCallback((_) async {
// //   //     try {
// //   //       final context = navigatorKey.currentContext;
// //   //       if (context == null) {
// //   //         debug("  Context is null, retrying...");
// //   //         Future.delayed(const Duration(milliseconds: 500), () {
// //   //           _findAndNavigateToLead(leadPhone, objectType);
// //   //         });
// //   //         return;
// //   //       }

// //   //       debug("  Searching for lead with phone: $leadPhone");
// //   //       debug("   Object Type: $objectType");

// //   //       final leadListVm =
// //   //           Provider.of<LeadListViewModel>(context, listen: false);

// //   //       if (leadListVm.viewModels.isEmpty) {
// //   //         await leadListVm.fetch();
// //   //         await Future.delayed(const Duration(milliseconds: 500));
// //   //       }

// //   //       LeadModel? matchedModel;
// //   //       final List<LeadModel> pinnedLeads = [];

// //   //       for (var viewModel in leadListVm.viewModels) {
// //   //         final leadmodel = viewModel.model;

// //   //         if (leadmodel?.records != null) {
// //   //           for (var record in leadmodel!.records!) {

// //   //             if (record.pinned == true) {
// //   //               pinnedLeads.add(record);
// //   //             }

// //   //             if (record.full_number != null &&
// //   //                 _isPhoneMatch(record.full_number!, leadPhone)) {
// //   //               matchedModel = record;
// //   //               debug(
// //   //                   "  Found matching lead: ${record.contactname} (${record.full_number})");
// //   //               break;
// //   //             }
// //   //           }
// //   //         }

// //   //         if (matchedModel != null) break;
// //   //       }

// //   //       if (matchedModel == null) {
// //   //         debug("  No matching lead found, creating dummy lead");
// //   //         // Create dummy lead
// //   //         matchedModel = LeadModel(
// //   //           id: leadPhone,
// //   //           contactname: "Unknown ($leadPhone)",
// //   //           full_number: leadPhone,
// //   //           pinned: false,
// //   //         );
// //   //       }

// //   //       // Navigate to appropriate chat screen
// //   //       debug("🚀 Navigating to chat screen...");
// //   //       // _navigateToAppropriateChatScreen(matchedModel, pinnedLeads, objectType);
// //   //     } catch (e) {
// //   //       debug("  Error finding lead: $e");
// //   //       // Even if there's an error, try to navigate with dummy lead
// //   //       final context = navigatorKey.currentContext;
// //   //       if (context != null) {
// //   //         LeadModel dummyLead = LeadModel(
// //   //           id: leadPhone,
// //   //           contactname: "Unknown ($leadPhone)",
// //   //           full_number: leadPhone,
// //   //           pinned: false,
// //   //         );
// //   //         _navigateToWhatsAppChat(context, dummyLead, []);
// //   //       }
// //   //     }
// //   //   });
// //   // }
// //   Future<void> _findAndNavigateToLead(
// //     String leadPhone, String objectType) async {

// //   try {

// //     final context = navigatorKey.currentContext;
// //     if (context == null) return;
// //  DashBoardController dbController =
// //           Provider.of(navigatorKey.currentContext!, listen: false);

// //     ///   SAFE API CALL
// //     String type = dbController.drawerItems.isNotEmpty
// //         ? dbController.drawerItems.first.sObjectName ?? "Lead"
// //         : "Lead";

// //     await dbController.drawerListApiCall(type: type);

// //     LeadModel? matchedLead;
// //     List<LeadModel> pinnedLeads = [];

// //     ///   FIND LEAD
// //     for (var item in dbController.drawerItems) {

// //       if (item.configName == true) {
// //         pinnedLeads.add(item);
// //       }

// //       if (item.full_number != null &&
// //           _isPhoneMatch(item.full_number!, leadPhone)) {

// //         matchedLead = item;
// //         break;
// //       }
// //     }

// //     /// ❗ Dummy lead if not found
// //     matchedLead ??= LeadModel(
// //       id: leadPhone,
// //       contactname: "Unknown ($leadPhone)",
// //       full_number: leadPhone,
// //       pinned: false,
// //     );

// //     debug("🚀 Opening Chat for ${matchedLead.full_number}");

// //     Navigator.pushAndRemoveUntil(
// //       context,
// //       MaterialPageRoute(
// //         builder: (_) => SfMessageChatScreen(
// //           isFromRecentChat: false,
// //         ),
// //       ),
// //       (route) => route.isFirst,
// //     );

// //   } catch (e) {
// //     debug("  Deep link navigation error: $e");
// //   }
// // }

// //   bool _isPhoneMatch(String recordPhone, String searchPhone) {
// //     String recordDigits = recordPhone.replaceAll(RegExp(r'[^\d]'), '');
// //     String searchDigits = searchPhone.replaceAll(RegExp(r'[^\d]'), '');
// //     if (recordDigits == searchDigits) {
// //       return true;
// //     }
// //     if (recordDigits.length >= 10 && searchDigits.length >= 10) {
// //       String recordLast10 = recordDigits.substring(recordDigits.length - 10);
// //       String searchLast10 = searchDigits.substring(searchDigits.length - 10);

// //       return recordLast10 == searchLast10;
// //     }

// //     return false;
// //   }

// //   // Future<void> _navigateToAppropriateChatScreen(LeadModel matchedModel,
// //   //     List<LeadModel> pinnedLeads, String objectType) async {
// //   //   try {
// //   //     final context = navigatorKey.currentContext;
// //   //     if (context == null) {
// //   //       debug("  Context is null for navigation");
// //   //       return;
// //   //     }

// //   //     debug("📍 Navigation Decision:");
// //   //     debug("   Object Type: $objectType");
// //   //     debug("   Lead Phone: ${matchedModel.full_number}");
// //   //     debug("   Lead Name: ${matchedModel.contactname}");

// //   //     // Check if we should navigate to Salesforce or WhatsApp
// //   //     if (objectType == 'lead' ||
// //   //         objectType == 'contact' ||
// //   //         objectType == 'opportunity') {
// //   //       // Check Salesforce authentication
// //   //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //   //       String sfAccessToken =
// //   //           prefs.getString(SharedPrefsConstants.sfAccessToken) ?? "";

// //   //       if (sfAccessToken.isNotEmpty) {
// //   //         debug("🔵 Navigating to Salesforce Chat");
// //   //         _navigateToWhatsAppChat(context, matchedModel, pinnedLeads);

// //   //         // _navigateToSalesforceChat(context, matchedModel, objectType);
// //   //       } else {
// //   //         debug("🟡 Salesforce token missing, using WhatsApp");
// //   //         _navigateToWhatsAppChat(context, matchedModel, pinnedLeads);
// //   //       }
// //   //     } else {
// //   //       // Default to WhatsApp chat
// //   //       debug("🟢 Navigating to WhatsApp Chat");
// //   //       _navigateToWhatsAppChat(context, matchedModel, pinnedLeads);
// //   //     }

// //   //     pendingDeepLink = null;
// //   //     debug("  Navigation completed!");
// //   //   } catch (e) {
// //   //     debug("  Navigation error: $e");
// //   //     // Fallback to WhatsApp chat
// //   //     final context = navigatorKey.currentContext;
// //   //     if (context != null) {
// //   //       _navigateToWhatsAppChat(context, matchedModel, pinnedLeads);
// //   //     }
// //   //   }
// //   // }

// //   /// 🔹 Navigate to WhatsApp Chat Screen
// //   void _navigateToWhatsAppChat(BuildContext context, LeadModel matchedModel,
// //       List<LeadModel> pinnedLeads) {
// //     debug("💚 Opening WhatsApp Chat...");

// //     // Use Navigator.pushAndRemoveUntil to ensure clean navigation
// //     // Navigator.pushAndRemoveUntil(
// //     //   context,
// //     //   MaterialPageRoute(
// //     //     builder: (_) => WhatsappChatScreen(
// //     //       leadName:
// //     //           matchedModel.contactname ?? matchedModel.full_number ?? "Unknown",
// //     //       wpnumber: matchedModel.full_number ?? "",
// //     //       id: matchedModel.id ?? matchedModel.full_number ?? "",
// //     //       model: matchedModel,
// //     //       pinnedLeads: pinnedLeads,
// //     //     ),
// //     //   ),
// //     //   (route) => route.isFirst, // Go back to home if needed
// //     // );
// //     Navigator.pushAndRemoveUntil(
// //       context,
// //       MaterialPageRoute(
// //         builder: (_) => SfMessageChatScreen(
// //           // pinnedLeadsList: sfPinnedLeads,
// //           isFromRecentChat: false,
// //           // Pass initial data if your SfMessageChatScreen supports it
// //           // initialLeadPhone: matchedModel.full_number,
// //           // initialLeadName: matchedModel.contactname,
// //           // initialObjectType: sObjectName,
// //         ),
// //       ),
// //       (route) => route.isFirst, // Go back to home if needed
// //     );
// //     debug("  WhatsApp Chat opened successfully!");
// //   }

// //   /// 🔹 Navigate to Salesforce Chat Screen
// //   // void _navigateToSalesforceChat(
// //   //   BuildContext context,
// //   //   LeadModel matchedModel,
// //   //   String objectType,
// //   // ) {
// //   //   debug("💙 Opening Salesforce Chat for $objectType");

// //   //   String sObjectName = objectType[0].toUpperCase() + objectType.substring(1);

// //   //   // Create empty pinned leads list for Salesforce
// //   //   List<SfDrawerItemModel> sfPinnedLeads = [];

// //   //   // Navigator.pushAndRemoveUntil(
// //   //   //   context,
// //   //   //   MaterialPageRoute(
// //   //   //     builder: (_) => SfMessageChatScreen(
// //   //   //       pinnedLeadsList: sfPinnedLeads,
// //   //   //       isFromRecentChat: false,
// //   //   //       // Pass initial data if your SfMessageChatScreen supports it
// //   //   //       // initialLeadPhone: matchedModel.full_number,
// //   //   //       // initialLeadName: matchedModel.contactname,
// //   //   //       // initialObjectType: sObjectName,
// //   //   //     ),
// //   //   //   ),
// //   //   //   (route) => route.isFirst,
// //   //   // );

// //   //   debug("  Salesforce Chat opened successfully!");
// //   // }

// //   @override
// //   void dispose() {
// //     _linkSubscription?.cancel();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       debug(
// //           "_isAppInitialized_isAppInitialized_isAppInitialized$_isAppInitialized");
// //       if (_isAppInitialized) {
// //         debug("🏁 App initialized, processing any pending deep link");
// //         _processPendingDeepLink();
// //       }
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

// import 'dart:async';
// import 'dart:convert';

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
// import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
// import 'package:whatsapp/salesforce/screens/sf_message_chat_screen.dart';
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
// import 'package:whatsapp/views/view/splash_view.dart';

// import 'firebase_options.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// final RouteObserver<ModalRoute<void>> routeObserver =
//     RouteObserver<ModalRoute<void>>();

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
//     debug("  Error in main(): $e");
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
//       debug("  Error in MyApp initState: $e");
//     }
//   }

//   Future<void> _handleInitialUri() async {
//     try {
//       final Uri? initialUri = await _appLinks.getInitialLink();
//       debug("📌 Initial URI => $initialUri");

//       if (initialUri != null) {
//         pendingDeepLink = initialUri;
//         _processPendingDeepLink();
//       }
//     } catch (e) {
//       debug("  Error in _handleInitialUri: $e");
//     }
//   }

//   void _listenToUriStream() {
//     _linkSubscription = _appLinks.uriLinkStream.listen(
//       (Uri uri) {
//         debug("📥 Stream URI => $uri");
//         pendingDeepLink = uri;
//         _processPendingDeepLink();
//       },
//       onError: (err) {
//         debug("  Error in URI Stream: $err");
//       },
//     );
//   }

//   void _processPendingDeepLink() {
//     if (!_isAppInitialized || pendingDeepLink == null) return;
//     _processDeepLink();
//   }

//   void _processDeepLink() async {
//     try {
//       if (pendingDeepLink == null) {
//         debug(" No pending deep link to process");
//         return;
//       }

//       final uri = pendingDeepLink!;
//       final uriString = uri.toString();

//       debug("=" * 50);
//       debug("🔗 DEEP LINK PROCESSING");
//       debug("=" * 50);
//       debug("📌 Full URL: $uriString");
//       debug("📌 Path: ${uri.path}");
//       debug("📌 Path Segments: ${uri.pathSegments}");
//       debug("=" * 50);

//       final String leadPhone = _extractLeadPhoneFromUrl(uriString);
//       final String objectType = _extractObjectTypeFromUrl(uriString);

//       debug(" EXTRACTED INFORMATION:");
//       debug("   Phone Number: $leadPhone");
//       debug("   Object Type: $objectType");
//       debug("=" * 50);

//       if (leadPhone.isEmpty) {
//         debug("  No phone number found in URL");
//         return;
//       }
//       await _findAndNavigateToLead(leadPhone, objectType);
//     } catch (e) {
//       debug("  Error in _processDeepLink: $e");
//     }
//   }

//   String _extractLeadPhoneFromUrl(String url) {
//     try {
//       debug("📞 Extracting phone from URL: $url");

//       try {
//         Uri uri = Uri.parse(url);
//         List<String> segments = uri.pathSegments;

//         if (segments.length >= 3) {
//           for (int i = 0; i < segments.length - 1; i++) {
//             if (segments[i].toLowerCase() == "chat" &&
//                 i + 1 < segments.length) {
//               String phone = segments[i + 1];
//               debug("  Found phone in path segments: $phone");
//               return phone;
//             }
//           }
//         }
//       } catch (e) {
//         debug(" Could not parse URL: $e");
//       }

//       // Fallback to regex patterns
//       // Pattern: /Lead/chat/91740989118
//       final RegExp leadChatRegex = RegExp(r'/(?:Lead|lead)/chat/(\d{10,})');
//       final Match? leadMatch = leadChatRegex.firstMatch(url);
//       if (leadMatch != null && leadMatch.group(1) != null) {
//         String phone = leadMatch.group(1)!;
//         debug("  Found phone with Lead pattern: $phone");
//         return phone;
//       }

//       // Pattern: /Contact/chat/91740989118
//       final RegExp contactChatRegex =
//           RegExp(r'/(?:Contact|contact)/chat/(\d{10,})');
//       final Match? contactMatch = contactChatRegex.firstMatch(url);
//       if (contactMatch != null && contactMatch.group(1) != null) {
//         String phone = contactMatch.group(1)!;
//         debug("  Found phone with Contact pattern: $phone");
//         return phone;
//       }

//       // Pattern: /chat/91740989118
//       final RegExp simpleChatRegex = RegExp(r'/chat/(\d{10,})');
//       final Match? simpleMatch = simpleChatRegex.firstMatch(url);
//       if (simpleMatch != null && simpleMatch.group(1) != null) {
//         String phone = simpleMatch.group(1)!;
//         debug("  Found phone with simple chat pattern: $phone");
//         return phone;
//       }

//       debug("  No phone number found in URL");
//       return "";
//     } catch (e) {
//       debug("  Error extracting phone from URL: $e");
//       return "";
//     }
//   }

//   String _extractObjectTypeFromUrl(String url) {
//     try {
//       debug("🏷️ Extracting object type from URL");
//       try {
//         Uri uri = Uri.parse(url);
//         List<String> segments = uri.pathSegments;

//         if (segments.isNotEmpty) {
//           String firstSegment = segments[0].toLowerCase();

//           if (firstSegment == "lead") {
//             debug("  Object type: lead");
//             return "lead";
//           } else if (firstSegment == "contact") {
//             debug("  Object type: contact");
//             return "contact";
//           } else if (firstSegment == "opportunity") {
//             debug("  Object type: opportunity");
//             return "opportunity";
//           } else if (firstSegment == "chat") {
//             debug("  Object type: whatsapp");
//             return "Lead";
//           }
//         }
//       } catch (e) {
//         debug(" Could not parse URL for object type: $e");
//       }

//       // Fallback to string matching
//       if (url.toLowerCase().contains('/lead/chat/')) {
//         debug("  Object type: lead (string match)");
//         return 'lead';
//       } else if (url.toLowerCase().contains('/contact/chat/')) {
//         debug("  Object type: contact (string match)");
//         return 'contact';
//       } else if (url.toLowerCase().contains('/opportunity/chat/')) {
//         debug("  Object type: opportunity (string match)");
//         return 'opportunity';
//       } else if (url.toLowerCase().contains('/chat/')) {
//         debug("  Object type: whatsapp (string match)");
//         return 'whatsapp';
//       }

//       debug(" No object type found, defaulting to whatsapp");
//       return "whatsapp";
//     } catch (e) {
//       debug("  Error extracting object type: $e");
//       return "whatsapp";
//     }
//   }

//   // Future<void> _findAndNavigateToLead(
//   //     String leadPhone, String objectType) async {
//   //   WidgetsBinding.instance.addPostFrameCallback((_) async {
//   //     try {
//   //       final BuildContext? context = navigatorKey.currentContext;
//   //       if (context == null) {
//   //         debug("  Context is null, retrying...");
//   //         Future.delayed(const Duration(milliseconds: 500), () {
//   //           _findAndNavigateToLead(leadPhone, objectType);
//   //         });
//   //         return;
//   //       }

//   //       debug("  Searching for lead with phone: $leadPhone");
//   //       debug("   Object Type: $objectType");

//   //       //   Call dashboard API before processing
//   //       await _callDashboardApi(context);

//   //       // Get the dashboard controller
//   //       final DashBoardController? dbController =
//   //           Provider.of<DashBoardController>(context, listen: false);

//   //       if (dbController == null) {
//   //         debug("  DashBoardController not found");
//   //         return;
//   //       }

//   //       // Call drawer list API
//   //       String type = dbController.drawerItems.isNotEmpty &&
//   //               dbController.drawerItems.first.sObjectName != null
//   //           ? dbController.drawerItems.first.sObjectName!
//   //           : "Lead";

//   //       await dbController.drawerListApiCall(type: type);

//   //       LeadModel? matchedLead;
//   //       final List<LeadModel> pinnedLeads = [];

//   //       //   Find the matching lead in drawer items
//   //       for (var item in dbController.drawerItems) {
//   //         // Check if item is pinned
//   //         if (item.configName == true) {
//   //           pinnedLeads.add(item as LeadModel);
//   //         }

//   //         // Check for phone match
//   //         if (item.whatsAppNumberField != null &&
//   //             _isPhoneMatch(item.whatsAppNumberField!, leadPhone)) {
//   //           matchedLead = item as LeadModel?;
//   //           break;
//   //         }
//   //       }

//   //       // ❗ Create dummy lead if not found
//   //       matchedLead ??= LeadModel(
//   //         id: leadPhone,
//   //         contactname: "Unknown ($leadPhone)",
//   //         full_number: leadPhone,
//   //         pinned: false,
//   //       );

//   //       debug("🚀 Opening Chat for ${matchedLead.full_number}");

//   //       // Navigate to chat screen
//   //       await _navigateToChatScreen(
//   //         context,
//   //         matchedLead,
//   //         pinnedLeads,
//   //         objectType,
//   //       );
//   //     } catch (e) {
//   //       debug("  Error in _findAndNavigateToLead: $e");
//   //       _handleNavigationError(leadPhone, e);
//   //     }
//   //   });
//   // }
//   Future<void> _findAndNavigateToLead(
//     String leadPhone, String objectType) async {
//   WidgetsBinding.instance.addPostFrameCallback((_) async {
//     try {
//       final BuildContext? context = navigatorKey.currentContext;
//       if (context == null) {
//         debug("  Context is null, retrying...");
//         Future.delayed(const Duration(milliseconds: 500), () {
//           _findAndNavigateToLead(leadPhone, objectType);
//         });
//         return;
//       }

//       debug("  Searching for lead with phone: $leadPhone");
//       debug("   Object Type: $objectType");

//       //   Get dashboard controller FIRST
//       final DashBoardController? dbController =
//           Provider.of<DashBoardController>(context, listen: false);

//       if (dbController == null) {
//         debug("  DashBoardController not found");
//         return;
//       }

//       //   Call dashboard API before processing
//       await _callDashboardApi(context);

//       // Call drawer list API
//       String type = dbController.drawerItems.isNotEmpty &&
//               dbController.drawerItems.first.sObjectName != null
//           ? dbController.drawerItems.first.sObjectName!
//           : "Lead";

//       await dbController.drawerListApiCall(type: type);

//       SfDrawerItemModel? matchedLead;
//       final List<SfDrawerItemModel> pinnedLeads = [];

//       //   Find the matching lead in drawer items
//       for (var item in dbController.drawerItems) {
//         // Check if item is pinned
//         // if (item.configName == true) {
//         //   pinnedLeads.add(item);
//         // }

//         // Check for phone match - IMPORTANT: Check multiple phone fields
//         String? phoneToCheck = item.whatsAppNumberField ??
//                               item.whatsAppNumberField ;
//                               // item.phone_number ??
//                               // item.full_number;

//         if (phoneToCheck != null && _isPhoneMatch(phoneToCheck, leadPhone)) {
//           // matchedLead = item;
//           // debug("  Found matching lead: ${item.name} - ${phoneToCheck}");
//           break;
//         }
//       }

//       // ❗ Create dummy lead if not found
//       if (matchedLead == null) {
//         debug(" No matching lead found, creating dummy");
//         matchedLead = SfDrawerItemModel(
//           id: leadPhone,
//           name: "Unknown ($leadPhone)",
//           whatsappNumber: leadPhone,
//           // full_number: leadPhone,
//           countryCode: "91",
//         );
//       }

//       //   CRITICAL: Set selected contact info BEFORE navigation
//       debug(" Setting selected contact: ${matchedLead.name}");
//       dbController.setSelectedContaactInfo(matchedLead);

//       //   Also set pinned info if needed
//       dbController.setSelectedPinnedInfo(null);

//       debug("🚀 Opening Chat for ${matchedLead.whatsappNumber}");

//       // Navigate to chat screen
//       await _navigateToChatScreen(
//         context,
//         matchedLead,
//         pinnedLeads,
//         objectType,
//       );
//     } catch (e, stackTrace) {
//       debug("  Error in _findAndNavigateToLead: $e");
//       debug("Stack trace: $stackTrace");
//       _handleNavigationError(leadPhone, e);
//     }
//   });
// }

// Future<void> _navigateToChatScreen(
//   BuildContext context,
//   SfDrawerItemModel matchedLead,
//   List<SfDrawerItemModel> pinnedLeads,
//   String objectType,
// ) async {
//   try {
//     debug("📍 Navigating to chat screen...");
//     debug("   Lead Name: ${matchedLead.name}");
//     debug("   Phone: ${matchedLead.whatsappNumber}");
//     debug("   Object Type: $objectType");

//     //   Get ChatMessageController and load messages BEFORE navigation
//     ChatMessageController chatController =
//         Provider.of<ChatMessageController>(context, listen: false);

//     String phoneNumber = matchedLead.whatsappNumber ?? "";
//     if (phoneNumber.isNotEmpty) {
//       debug("📥 Loading messages for: $phoneNumber");
//       await chatController.messageHistoryApiCall(
//         userNumber: phoneNumber,
//         isFirstTime: true,
//       );
//     }

//     // Navigate to Salesforce chat screen
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(
//         builder: (_) => SfMessageChatScreen(
//           pinnedLeadsList: pinnedLeads,
//           isFromRecentChat: false,
//         ),
//       ),
//       (route) => route.isFirst,
//     );

//     pendingDeepLink = null;
//     debug("  Navigation completed successfully!");
//   } catch (e, stackTrace) {
//     debug("  Navigation error: $e");
//     debug("Stack trace: $stackTrace");
//     rethrow;
//   }
// }

// void _handleNavigationError(String leadPhone, Object error) {
//   debug(" Handling navigation error: $error");

//   final BuildContext? context = navigatorKey.currentContext;
//   if (context == null) {
//     debug("  Context is null, cannot handle error");
//     return;
//   }

//   // Even on error, try to navigate with dummy lead
//   try {
//     SfDrawerItemModel dummyLead = SfDrawerItemModel(
//       id: leadPhone,
//       name: "Unknown ($leadPhone)",
//       whatsappNumber: leadPhone,
//       // full_number: leadPhone,
//       countryCode: "91",
//     );

//     //   Set contact info before navigation
//     DashBoardController dbController =
//         Provider.of<DashBoardController>(context, listen: false);
//     dbController.setSelectedContaactInfo(dummyLead);

//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(
//         builder: (_) => SfMessageChatScreen(
//           isFromRecentChat: false,
//         ),
//       ),
//       (route) => route.isFirst,
//     );
//   } catch (e) {
//     debug("  Even fallback navigation failed: $e");
//   }
// }

//   Future<void> _callDashboardApi(BuildContext context) async {
//     try {
//       debug("📊 Calling dashboard API...");
//       final DashBoardController? dbController =
//           Provider.of<DashBoardController>(context, listen: false);

//       if (dbController != null) {
//         await dbController.getDasBoardReportApiCall();
//         debug("  Dashboard API called successfully");
//       } else {
//         debug(" DashboardController not available");
//       }
//     } catch (e) {
//       debug("  Error calling dashboard API: $e");
//       // Continue execution even if dashboard API fails
//     }
//   }

//   // Future<void> _navigateToChatScreen(
//   //   BuildContext context,
//   //   LeadModel matchedLead,
//   //   List<LeadModel> pinnedLeads,
//   //   String objectType,
//   // ) async {
//   //   try {
//   //     debug("📍 Navigating to chat screen...");
//   //     debug("   Lead Name: ${matchedLead.contactname}");
//   //     debug("   Phone: ${matchedLead.full_number}");
//   //     debug("   Object Type: $objectType");

//   //     // Navigate to Salesforce chat screen
//   //     await Navigator.pushAndRemoveUntil(
//   //       context,
//   //       MaterialPageRoute(
//   //         builder: (_) => SfMessageChatScreen(
//   //           isFromRecentChat: false,
//   //           // Pass initial data if supported by your SfMessageChatScreen
//   //           // initialLeadPhone: matchedLead.full_number,
//   //           // initialLeadName: matchedLead.contactname,
//   //           // initialLeadId: matchedLead.id,
//   //         ),
//   //       ),
//   //       (route) => route.isFirst,
//   //     );

//   //     pendingDeepLink = null;
//   //     debug("  Navigation completed successfully!");
//   //   } catch (e) {
//   //     debug("  Navigation error: $e");
//   //     rethrow;
//   //   }
//   // }

//   // void _handleNavigationError(String leadPhone, Object error) {
//   //   debug(" Handling navigation error: $error");

//   //   final BuildContext? context = navigatorKey.currentContext;
//   //   if (context == null) {
//   //     debug("  Context is null, cannot handle error");
//   //     return;
//   //   }

//   //   // Even on error, try to navigate with dummy lead
//   //   try {
//   //     LeadModel dummyLead = LeadModel(
//   //       id: leadPhone,
//   //       contactname: " ($leadPhone)",
//   //       full_number: leadPhone,
//   //       pinned: false,
//   //     );

//   //     Navigator.pushAndRemoveUntil(
//   //       context,
//   //       MaterialPageRoute(
//   //         builder: (_) => SfMessageChatScreen(
//   //           isFromRecentChat: false,
//   //         ),
//   //       ),
//   //       (route) => route.isFirst,
//   //     );
//   //   } catch (e) {
//   //     debug("  Even fallback navigation failed: $e");
//   //   }
//   // }

//   bool _isPhoneMatch(String recordPhone, String searchPhone) {
//     try {
//       final String recordDigits = recordPhone.replaceAll(RegExp(r'[^\d]'), '');
//       final String searchDigits = searchPhone.replaceAll(RegExp(r'[^\d]'), '');

//       if (recordDigits == searchDigits) {
//         return true;
//       }

//       if (recordDigits.length >= 10 && searchDigits.length >= 10) {
//         final String recordLast10 =
//             recordDigits.substring(recordDigits.length - 10);
//         final String searchLast10 =
//             searchDigits.substring(searchDigits.length - 10);

//         return recordLast10 == searchLast10;
//       }

//       return false;
//     } catch (e) {
//       debug("  Error in phone matching: $e");
//       return false;
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
//       if (_isAppInitialized) {
//         debug("🏁 App initialized, processing any pending deep link");
//         _processPendingDeepLink();
//       }
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
//           create: (_) => ApprovedTemplateViewModel(context),
//         ),
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
//           create: (_) => WhatsappSettingViewModel(context),
//         ),
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

import 'dart:async';
import 'dart:convert';

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
import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
import 'package:whatsapp/salesforce/screens/sf_message_chat_screen.dart';
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
import 'package:whatsapp/views/view/splash_view.dart';

import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

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
    debug("  Error in main(): $e");
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
      debug("  Error in MyApp initState: $e");
    }
  }

  Future<void> _handleInitialUri() async {
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      debug("📌 Initial URI => $initialUri");

      if (initialUri != null) {
        pendingDeepLink = initialUri;
        _processPendingDeepLink();
      }
    } catch (e) {
      debug("  Error in _handleInitialUri: $e");
    }
  }

  void _listenToUriStream() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        debug("📥 Stream URI => $uri");
        pendingDeepLink = uri;
        _processPendingDeepLink();
      },
      onError: (err) {
        debug("  Error in URI Stream: $err");
      },
    );
  }

  void _processPendingDeepLink() {
    if (!_isAppInitialized || pendingDeepLink == null) return;
    _processDeepLink();
  }

  void _processDeepLink() async {
    try {
      if (pendingDeepLink == null) {
        debug(" No pending deep link to process");
        return;
      }

      final uri = pendingDeepLink!;
      final uriString = uri.toString();

      debug("=" * 50);
      debug("🔗 DEEP LINK PROCESSING");
      debug("=" * 50);
      debug("📌 Full URL: $uriString");
      debug("📌 Path: ${uri.path}");
      debug("📌 Path Segments: ${uri.pathSegments}");
      debug("=" * 50);

      final String leadPhone = _extractLeadPhoneFromUrl(uriString);
      final String objectType = _extractObjectTypeFromUrl(uriString);

      debug(" EXTRACTED INFORMATION:");
      debug("   Phone Number: $leadPhone");
      debug("   Object Type: $objectType");
      debug("=" * 50);

      if (leadPhone.isEmpty) {
        debug("  No phone number found in URL");
        return;
      }
      await _findAndNavigateToLead(leadPhone, objectType);
    } catch (e) {
      debug("  Error in _processDeepLink: $e");
    }
  }

  String _extractLeadPhoneFromUrl(String url) {
    try {
      debug("📞 Extracting phone from URL: $url");

      try {
        Uri uri = Uri.parse(url);
        List<String> segments = uri.pathSegments;

        debug("  Path segments: $segments");

        if (segments.length >= 3) {
          for (int i = 0; i < segments.length - 2; i++) {
            if (segments[i].toLowerCase() == "chat" &&
                i + 2 < segments.length) {
              String phone = segments[i + 2];
              debug("  Found phone in chat/object/phone pattern: $phone");
              return phone;
            }
          }
        }

        if (segments.length >= 3) {
          for (int i = 0; i < segments.length - 1; i++) {
            if (segments[i].toLowerCase() == "chat" &&
                i + 1 < segments.length) {
              String phone = segments[i + 1];
              debug("  Found phone in path segments: $phone");
              return phone;
            }
          }
        }
      } catch (e) {
        debug(" Could not parse URL: $e");
      }

      final RegExp newChatPattern = RegExp(
          r'/chat/(?:Lead|lead|Contact|contact|Opportunity|opportunity)/(\d{10,})');
      final Match? newPatternMatch = newChatPattern.firstMatch(url);
      if (newPatternMatch != null && newPatternMatch.group(1) != null) {
        String phone = newPatternMatch.group(1)!;
        debug("  Found phone with new chat pattern: $phone");
        return phone;
      }

      final RegExp leadChatRegex = RegExp(r'/(?:Lead|lead)/chat/(\d{10,})');
      final Match? leadMatch = leadChatRegex.firstMatch(url);
      if (leadMatch != null && leadMatch.group(1) != null) {
        String phone = leadMatch.group(1)!;
        debug("  Found phone with Lead pattern: $phone");
        return phone;
      }

      final RegExp contactChatRegex =
          RegExp(r'/(?:Contact|contact)/chat/(\d{10,})');
      final Match? contactMatch = contactChatRegex.firstMatch(url);
      if (contactMatch != null && contactMatch.group(1) != null) {
        String phone = contactMatch.group(1)!;
        debug("  Found phone with Contact pattern: $phone");
        return phone;
      }

      final RegExp simpleChatRegex = RegExp(r'/chat/(\d{10,})');
      final Match? simpleMatch = simpleChatRegex.firstMatch(url);
      if (simpleMatch != null && simpleMatch.group(1) != null) {
        String phone = simpleMatch.group(1)!;
        debug("  Found phone with simple chat pattern: $phone");
        return phone;
      }

      debug("  No phone number found in URL");
      return "";
    } catch (e) {
      debug("  Error extracting phone from URL: $e");
      return "";
    }
  }

  String _normalizeObject(String value) {
    return value.toLowerCase().replaceAll('__c', '');
  }

  String _extractObjectTypeFromUrl(String url) {
    try {
      debug("🏷️ Extracting object type from URL: $url");

      try {
        Uri uri = Uri.parse(url);
        List<String> segments = uri.pathSegments;

        debug("  All segments: $segments");
        if (segments.length >= 3) {
          for (int i = 0; i < segments.length - 2; i++) {
            if (segments[i].toLowerCase() == "chat" &&
                i + 1 < segments.length) {
              String rawObject = segments[i + 1];
              String objectType = _normalizeObject(rawObject);

              if (rawObject.endsWith('__c')) {
                return rawObject;
              }
              // String objectType = _normalizeObject(segments[i + 1]);

              if (objectType == "lead") return "lead";
              if (objectType == "contact") return "contact";
              if (objectType == "opportunity") return "opportunity";
            }
          }
        }

        if (segments.isNotEmpty) {
          String firstRaw = segments[0];

          if (firstRaw.endsWith('__c')) {
            return firstRaw;
          }

          String firstSegment = _normalizeObject(firstRaw);

          if (firstSegment == "lead") return "lead";
          if (firstSegment == "contact") return "contact";
          if (firstSegment == "opportunity") return "opportunity";
        }

        // if (segments.length >= 3) {
        //   for (int i = 0; i < segments.length - 2; i++) {
        //     if (segments[i].toLowerCase() == "chat" &&
        //         i + 1 < segments.length) {
        //       String objectType = segments[i + 1].toLowerCase();
        //       // debug(
        //       //     "  Found object type in chat/object/phone pattern: $objectType");

        //       if (objectType == "lead")
        //         return "lead";
        //       else if (objectType == "contact")
        //         return "contact";
        //       else if (objectType == "opportunity") return "opportunity";
        //     }
        //   }
        // }

        if (segments.isNotEmpty) {
          String firstSegment = segments[0].toLowerCase();

          if (firstSegment == "Lead") {
            debug("  Object type: lead (first segment)");
            return "lead";
          } else if (firstSegment == "Contact") {
            debug("  Object type: contact (first segment)");
            return "contact";
          } else if (firstSegment == "opportunity") {
            debug("  Object type: opportunity (first segment)");
            return "opportunity";
          } else if (firstSegment == "chat") {
            debug("  Object type: whatsapp (first segment is chat)");
            return ""; // Default lead
          }
        }
      } catch (e) {
        debug(" Could not parse URL for object type: $e");
      }

      if (RegExp(r'/chat/(?:Lead|lead)/\d').hasMatch(url)) {
        debug("  Object type: lead (new chat pattern)");
        return 'lead';
      } else if (RegExp(r'/chat/(?:Contact|contact)/\d').hasMatch(url)) {
        debug("  Object type: contact (new chat pattern)");
        return 'contact';
      } else if (RegExp(r'/chat/(?:Opportunity|opportunity)/\d')
          .hasMatch(url)) {
        debug("  Object type: opportunity (new chat pattern)");
        return 'opportunity';
      }

      if (url.toLowerCase().contains('/lead/chat/')) {
        debug("  Object type: lead (old pattern)");
        return 'lead';
      } else if (url.toLowerCase().contains('/contact/chat/')) {
        debug("  Object type: contact (old pattern)");
        return 'contact';
      } else if (url.toLowerCase().contains('/opportunity/chat/')) {
        debug("  Object type: opportunity (old pattern)");
        return 'opportunity';
      } else if (url.toLowerCase().contains('/chat/')) {
        debug("  Object type: whatsapp (simple chat)");
        return 'lead';
      }

      debug(" No object type found, defaulting to lead");
      return "lead";
    } catch (e) {
      debug("  Error extracting object type: $e");
      return "lead";
    }
  }

  String normalizePhone(String? phone) {
    if (phone == null) return "";
    return phone
        .replaceAll(RegExp(r'[^0-9]'), '')
        .replaceFirst(RegExp(r'^91'), '');
  }

  Future<void> _findAndNavigateToLead(
      String leadPhone, String objectType) async {
    debug("objectTypeobjectType $objectType");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final BuildContext? context = navigatorKey.currentContext;

        if (context == null) {
          debug("  Context null, retrying...");
          Future.delayed(const Duration(milliseconds: 500), () {
            _findAndNavigateToLead(leadPhone, objectType);
          });
          return;
        }

        debug("  Searching lead: $leadPhone");

        final DashBoardController dbController =
            Provider.of<DashBoardController>(context, listen: false);

        await _callDashboardApi(context);

        String type = objectType.toLowerCase();
        if (type.isNotEmpty) {
          type = type[0].toUpperCase() + type.substring(1);
        }

        debug("Drawer type->$type");
        await dbController.drawerListApiCall(type: type);

        SfDrawerItemModel? matchedLead;
        final List<SfDrawerItemModel> pinnedLeads = [];
        final normalizedLeadPhone = normalizePhone(leadPhone);

        debug("🔍 Searching for: $leadPhone");
        debug("🔍 Normalized Lead Phone: $normalizedLeadPhone");

        for (var item in dbController.drawerListItems) {
          debug("📞 List Number Raw: ${item.whatsappNumber}");
          debug(
              "📞 List Number Normalized: ${normalizePhone(item.whatsappNumber)}");
        }

        matchedLead = dbController.drawerListItems.firstWhere(
          (item) {
            final normalizedItemPhone = normalizePhone(item.whatsappNumber);

            debug("➡️ Comparing:");
            debug("   Lead: $normalizedLeadPhone");
            debug("   Item: $normalizedItemPhone");

            return normalizedItemPhone == normalizedLeadPhone;
          },
          orElse: () {
            debug("❌ No matching lead found");
            return SfDrawerItemModel();
          },
        );

        if (matchedLead.whatsappNumber != null &&
            matchedLead.whatsappNumber!.isNotEmpty) {
          debug("✅ MATCH FOUND!");
          debug("👤 Name: ${matchedLead.name}");
          debug("📱 Phone: ${matchedLead.whatsappNumber}");
        } else {
          debug(" No match found, creating dummy");

          matchedLead = SfDrawerItemModel(
            id: leadPhone,
            name: leadPhone,
            whatsappNumber: leadPhone,
            countryCode: "91",
          );
        }

        debug(" Selected: ${matchedLead.name}");

        dbController.setSelectedContaactInfo(matchedLead);
        dbController.setSelectedPinnedInfo(null);

        debug("🚀 Opening chat");

        await _navigateToChatScreen(
          context,
          matchedLead,
          pinnedLeads,
          objectType,
        );
      } catch (e, stackTrace) {
        debug("  Error: $e");
        debug("Stack: $stackTrace");
        _handleNavigationError(leadPhone, e);
      }
    });
  }
//   Future<void> _findAndNavigateToLead(
//       String leadPhone, String objectType) async {
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       try {
//         final BuildContext? context = navigatorKey.currentContext;

//         if (context == null) {
//           debug("  Context null, retrying...");
//           Future.delayed(const Duration(milliseconds: 500), () {
//             _findAndNavigateToLead(leadPhone, objectType);
//           });
//           return;
//         }

//         debug("  Searching lead: $leadPhone");

//         final DashBoardController dbController =
//             Provider.of<DashBoardController>(context, listen: false);

//         await _callDashboardApi(context);
// debug("objectTypeobjectType$objectType");
//         String type = objectType;
//         // String type = "Lead";

//         debug("Drawer type->$type");
//         await dbController.drawerListApiCall(type: type);

//         SfDrawerItemModel? matchedLead;
//         final List<SfDrawerItemModel> pinnedLeads = [];
// final normalizedLeadPhone = normalizePhone(leadPhone);

// debug("🔍 Searching for: $leadPhone");
// debug("🔍 Normalized Lead Phone: $normalizedLeadPhone");

// // Print all numbers from list
// for (var item in dbController.drawerListItems) {
//   debug("📞 List Number Raw: ${item.whatsappNumber}");
//   debug("📞 List Number Normalized: ${normalizePhone(item.whatsappNumber)}");
// }

// matchedLead = dbController.drawerListItems.firstWhere(
//   (item) {
//     final normalizedItemPhone = normalizePhone(item.whatsappNumber);

//     debug("➡️ Comparing:");
//     debug("   Lead: $normalizedLeadPhone");
//     debug("   Item: $normalizedItemPhone");

//     return normalizedItemPhone == normalizedLeadPhone;
//   },
//   orElse: () {
//     debug("❌ No matching lead found");
//     return SfDrawerItemModel();
//   },
// );

// if (matchedLead.whatsappNumber != null &&
//     matchedLead.whatsappNumber!.isNotEmpty) {
//   debug("✅ MATCH FOUND!");
//   debug("👤 Name: ${matchedLead.name}");
//   debug("📱 Phone: ${matchedLead.whatsappNumber}");
// }

//         if (matchedLead.whatsappNumber != null &&
//             matchedLead.whatsappNumber!.isNotEmpty) {
//           debug(" Found lead: ${matchedLead.name}");
//         } else {
//           debug(" No match found, creating dummy");

//           matchedLead = SfDrawerItemModel(
//             id: leadPhone,
//             name: leadPhone,
//             whatsappNumber: leadPhone,
//             countryCode: "91",
//           );
//         }

//         debug(" Selected: ${matchedLead.name}");

//         dbController.setSelectedContaactInfo(matchedLead);
//         dbController.setSelectedPinnedInfo(null);

//         debug("🚀 Opening chat");

//         await _navigateToChatScreen(
//           context,
//           matchedLead,
//           pinnedLeads,
//           objectType,
//         );
//       } catch (e, stackTrace) {
//         debug("  Error: $e");
//         debug("Stack: $stackTrace");
//         _handleNavigationError(leadPhone, e);
//       }
//     });
//   }

  Future<void> _navigateToChatScreen(
    BuildContext context,
    SfDrawerItemModel matchedLead,
    List<SfDrawerItemModel> pinnedLeads,
    String objectType,
  ) async {
    try {
      debug("📍 Navigating to chat screen...");
      debug("   Lead Name: ${matchedLead.name}");
      debug("   Phone: ${matchedLead.whatsappNumber}");
      debug("   Object Type: $objectType");

      ChatMessageController chatController =
          Provider.of<ChatMessageController>(context, listen: false);

      String phoneNumber = matchedLead.whatsappNumber ?? "";
      if (phoneNumber.isNotEmpty) {
        debug("📥 Loading messages for: $phoneNumber");
        await chatController.messageHistoryApiCall(
          userNumber: phoneNumber,
          isFirstTime: true,
        );
      }
// future.delay()
      // Future.delayed(Duration(seconds: 4), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => SfMessageChatScreen(
            pinnedLeadsList: pinnedLeads,
            isFromRecentChat: false,
          ),
        ),
        (route) => false,
      );
      // });
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => SfMessageChatScreen(
      //       pinnedLeadsList: pinnedLeads,
      //       isFromRecentChat: false,
      //     ),
      //   ),
      //   (route) => route.isFirst,
      // );

      pendingDeepLink = null;
      debug("  Navigation completed successfully!");
    } catch (e, stackTrace) {
      debug("  Navigation error: $e");
      debug("Stack trace: $stackTrace");
      rethrow;
    }
  }

  void _handleNavigationError(String leadPhone, Object error) {
    debug(" Handling navigation error: $error");

    final BuildContext? context = navigatorKey.currentContext;
    if (context == null) {
      debug("  Context is null, cannot handle error");
      return;
    }

    // Even on error, try to navigate with dummy lead
    try {
      SfDrawerItemModel dummyLead = SfDrawerItemModel(
        id: leadPhone,
        name: "Unknown ($leadPhone)",
        whatsappNumber: leadPhone,
        countryCode: "91",
        // phone_number: leadPhone,
      );

      //   Set contact info before navigation
      DashBoardController dbController =
          Provider.of<DashBoardController>(context, listen: false);
      dbController.setSelectedContaactInfo(dummyLead);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => SfMessageChatScreen(
            isFromRecentChat: false,
          ),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      debug("  Even fallback navigation failed: $e");
    }
  }

  Future<void> _callDashboardApi(BuildContext context) async {
    try {
      debug("📊 Calling dashboard API...");
      final DashBoardController? dbController =
          Provider.of<DashBoardController>(context, listen: false);

      if (dbController != null) {
        await dbController.getDasBoardReportApiCall();
        debug("  Dashboard API called successfully");
      } else {
        debug(" DashboardController not available");
      }
    } catch (e) {
      debug("  Error calling dashboard API: $e");
      // Continue execution even if dashboard API fails
    }
  }

  bool _isPhoneMatch(String recordPhone, String searchPhone) {
    try {
      if (recordPhone.isEmpty || searchPhone.isEmpty) return false;

      final String recordDigits = recordPhone.replaceAll(RegExp(r'[^\d]'), '');
      final String searchDigits = searchPhone.replaceAll(RegExp(r'[^\d]'), '');

      if (recordDigits.isEmpty || searchDigits.isEmpty) return false;

      // Exact match
      if (recordDigits == searchDigits) {
        return true;
      }

      // Last 10 digits match
      if (recordDigits.length >= 10 && searchDigits.length >= 10) {
        final String recordLast10 =
            recordDigits.substring(recordDigits.length - 10);
        final String searchLast10 =
            searchDigits.substring(searchDigits.length - 10);

        return recordLast10 == searchLast10;
      }

      // Last 8 digits match (fallback)
      if (recordDigits.length >= 8 && searchDigits.length >= 8) {
        final String recordLast8 =
            recordDigits.substring(recordDigits.length - 8);
        final String searchLast8 =
            searchDigits.substring(searchDigits.length - 8);

        return recordLast8 == searchLast8;
      }

      return false;
    } catch (e) {
      debug("  Error in phone matching: $e");
      return false;
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
      if (_isAppInitialized) {
        debug("🏁 App initialized, processing any pending deep link");
        _processPendingDeepLink();
      }
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
          create: (_) => ApprovedTemplateViewModel(context),
        ),
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
          create: (_) => WhatsappSettingViewModel(context),
        ),
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
