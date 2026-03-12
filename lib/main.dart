
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
//calll
              if (objectType == "lead") return "lead";
              if (objectType == "contact") return "contact";
              if (objectType == "opportunity") return "opportunity";
            }
          }
        }
        //aaaaaaaaa
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
