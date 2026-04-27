// // ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use, prefer_typing_uninitialized_variables, non_constant_identifier_names

// import 'dart:developer';

// import 'package:focus_detector/focus_detector.dart';
// // ignore: library_prefixes
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// import 'package:flutter/material.dart';
// import 'package:flutter/material.dart' as badges;
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';

// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:whatsapp/salesforce/controller/drawer_controller.dart';

// import 'package:whatsapp/utils/app_constants.dart';
// import 'package:whatsapp/utils/app_fonts.dart';
// import 'package:whatsapp/utils/app_utils.dart';
// import 'package:whatsapp/utils/notification_utils.dart';
// import 'package:whatsapp/view_models/campaign_chart_vm.dart';
// import 'package:whatsapp/view_models/get_user_vm.dart';
// import 'package:whatsapp/view_models/lead_controller.dart';

// import 'package:whatsapp/view_models/unread_count_vm.dart';
// import 'package:whatsapp/views/view/NotificationPage.dart';
// import 'package:whatsapp/views/view/campaign_list_view.dart';
// import 'package:whatsapp/views/view/lead/lead_list_view.dart';
// import 'package:whatsapp/views/widgets/home_page_cards.dart';

// import '../../models/auto_response_model.dart';
// import '../../models/campaign_count_model/campaign_count_model.dart';
// import '../../models/campaignchart_model/campaign_chart_vm.dart';
// import '../../models/lead_count_agent_model.dart';
// import '../../models/lead_count_model.dart';
// import '../../models/leadsmonthmodel.dart';
// import '../../models/template_model/template_model.dart';
// import '../../models/unread_msg_model/unread_msg_model.dart';
// import '../../utils/app_color.dart';
// import '../../utils/function_lib.dart' show debug;
// import '../../view_models/auto_response_vm.dart';
// import '../../view_models/campaign_count_vm.dart';
// import '../../view_models/lead_count_vm.dart';
// import '../../view_models/templete_list_vm.dart';
// import '../../view_models/whatsapp_setting_vm.dart';
// import '../widgets/app_drawer_widget.dart';

// // ignore: must_be_immutable
// class HomeView extends StatefulWidget {
//   final LeadCountAgentModel? agentModel;
//   final Leadsmonthmodel? monthmodel;

//   const HomeView({Key? key, this.agentModel, this.monthmodel}) : super(key: key);

//   @override
//   State<HomeView> createState() => _HomeViewState();
// }

// class _HomeViewState extends State<HomeView> {
 
//   IO.Socket? _socket;
  

//   final Map<String, String> _itemsMap = {};
//   final List<dynamic> _allNums = [];
//   final List<dynamic> _allWhNums = [];
//   final List<ChartData> _businessData = [];
//   final List<TemplateChartData> _templateData = [];
  

//   String _phNum = "+919876543210";
//   String _token = "your_token_here";
//   String? _selectedWhatsAppNumber;
//   String _selectedNumber = "";
  

//   String? _countNewLeads;
//   String? _autoResponseCount;
//   String? _campaignCount = '0';
//   int? _templateCount;
//   int? _unreadDataCount;
//   String? _globalUnreadCount;
  

//   bool _isInitialized = false;
//   bool _isLoading = false;
  

//   final List<Color> _areaColor = [
//     AppColor.navBarIconColor,
//     const Color.fromARGB(255, 205, 244, 247),
//     Colors.blue,
//     Colors.green,
//   ];
  
//   late final TooltipBehavior _tooltipBehavior;
//   List<String> _modules = [];

//   @override
//   void initState() {
//     super.initState();
//     _tooltipBehavior = TooltipBehavior(enable: true);
//     NotificationUtil.registerToken();
//     _initializeData();
//   }

//   @override
//   void dispose() {
//     _disconnectSocket();
//     super.dispose();
//   }


  
//   Future<void> _initializeData() async {
//     if (_isInitialized) return;

//     setState(() => _isLoading = true);
    
//     await _getAvailableModules();
//     await _getPhoneNumber();
//     await _fetchInitialData();
    
//     setState(() {
//       _isInitialized = true;
//       _isLoading = false;
//     });
//   }

//   Future<void> _getAvailableModules() async {
//     final prefs = await SharedPreferences.getInstance();
//     _modules = prefs.getStringList(SharedPrefsConstants.userAvailableMoulesKey) ?? [];
//     print("modules:::: $_modules");
//   }

//   Future<String?> _getPhoneNumber() async {
//     final prefs = await SharedPreferences.getInstance();
//     final phoneNumber = prefs.getString('selectedWhatsAppNumber');
//     debug('Retrieved phone number: $phoneNumber');
//     return phoneNumber;
//   }

//   Future<void> _fetchInitialData() async {
//     try {
//       await _checkPasswordChange();
      
//       final prefs = await SharedPreferences.getInstance();
//       String? selectedWhatsAppNumber = prefs.getString('phoneNumber');

//       await Provider.of<WhatsappSettingViewModel>(context, listen: false).fetch();

//       final whatsAppVM = Provider.of<WhatsappSettingViewModel>(context, listen: false);
      
//       if (selectedWhatsAppNumber == null || selectedWhatsAppNumber.isEmpty) {
//         if (whatsAppVM.viewModels.isNotEmpty) {
//           selectedWhatsAppNumber = whatsAppVM.viewModels[0].model.record[0].phone;
//           _selectedNumber = selectedWhatsAppNumber ?? "";
//           await prefs.setString('phoneNumber', selectedWhatsAppNumber ?? "");
//         }
//       } else {
//         _selectedNumber = selectedWhatsAppNumber;
//       }

//       debugPrint('Selected WhatsApp Number: $selectedWhatsAppNumber');

    
//       await _fetchAllDataConcurrently(selectedWhatsAppNumber);
      
//     } catch (e, stackTrace) {
//       print('Error in _fetchInitialData: $e. $stackTrace');
//     } finally {
//       EasyLoading.dismiss();
//     }
//   }

//   Future<void> _fetchAllDataConcurrently(String? whatsappNumber) async {
//     final List<Future<void>> futures = [];
    
//     futures.add(Provider.of<CampaignChartViewModel>(context, listen: false)
//         .fetchCampaignChart(number: whatsappNumber));
//     futures.add(Provider.of<TempleteListViewModel>(context, listen: false)
//         .templeteCountfetch(number: whatsappNumber));
//     futures.add(Provider.of<TempleteListViewModel>(context, listen: false)
//         .templetefetch(number: whatsappNumber));
//     futures.add(Provider.of<CampaignCountViewModel>(context, listen: false)
//         .fetchCampaignCount(number: whatsappNumber));
//     futures.add(Provider.of<LeadCountViewModel>(context, listen: false).countNewLead());
//     futures.add(Provider.of<AutoResponseViewModel>(context, listen: false).autoResponseFetch());
//     futures.add(_getUnreadCount()); 
    
//     await Future.wait(futures);
//   }

  
//   Future<void> _refreshDataWithNewNumber(String number) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('phoneNumber', number);

//     final List<Future<void>> futures = [
//       Provider.of<CampaignCountViewModel>(context, listen: false)
//           .fetchCampaignCount(number: number),
//       Provider.of<TempleteListViewModel>(context, listen: false)
//           .templeteCountfetch(number: number),
//       Provider.of<CampaignChartViewModel>(context, listen: false)
//           .fetchCampaignChart(number: number),
//     ];
    
//     await Future.wait(futures);

//     if (mounted) setState(() {});
//   }

 
  
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<WhatsappSettingViewModel>(
//       builder: (context, whatsAppSettingVM, child) {
//         _updateItemsMap(whatsAppSettingVM);

//         return Consumer<DashBoardController>(
//           builder: (context, ref, child) {
//             return _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : FocusDetector(
//                     onFocusGained: () {
//                       log('Home Screen focused again');
//                       _connectSocket();
//                     },
//                     onFocusLost: () {
//                       _disconnectSocket();
//                     },
//                     child: Scaffold(
//                       backgroundColor: Colors.white,
//                       drawer: const AppDrawerWidget(),
//                       appBar: _buildAppBar(whatsAppSettingVM),
//                       body: _buildBody(),
//                     ),
//                   );
//           },
//         );
//       },
//     );
//   }

//   PreferredSizeWidget _buildAppBar(WhatsappSettingViewModel whatsAppSettingVM) {
//     return AppBar(
//       iconTheme: const IconThemeData(color: Colors.white),
//       centerTitle: true,
//       elevation: 2,
//       backgroundColor: AppColor.navBarIconColor,
//       title: const Text("Home", style: TextStyle(color: Colors.white)),
//       actions: [
//         _buildNotificationIcon(),
//         _buildPhoneMenu(whatsAppSettingVM),
//       ],
//     );
//   }

//   Widget _buildNotificationIcon() {
//     return Consumer<UnreadCountVm>(
//       builder: (context, unreadCountVm, child) {
//         final totalUnreadCount = _calculateUnreadCount(unreadCountVm);

//         return IconButton(
//           tooltip: "Messages",
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const NotificationPage()),
//             );
//           },
//           icon: Stack(
//             children: [
//               const Icon(Icons.notifications, size: 28),
//               if (totalUnreadCount > 0)
//                 Positioned(
//                   right: 0,
//                   top: 0,
//                   child: badges.Badge(
//                     isLabelVisible: true,
//                     label: Text(
//                       totalUnreadCount.toString(),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     backgroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
//                     padding: const EdgeInsets.all(2),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildPhoneMenu(WhatsappSettingViewModel whatsAppSettingVM) {
//     return PopupMenuButton<String>(
//       position: PopupMenuPosition.under,
//       icon: const Icon(Icons.phone, size: 23, color: Colors.white),
//       itemBuilder: (BuildContext context) {
//         return _allNums.map((number) {
//           final isSelected = number.phone == _selectedNumber;
//           return PopupMenuItem<String>(
//             value: number.phone,
//             child: Row(
//               children: [
//                 if (isSelected)
//                   const Icon(Icons.check, color: Colors.blue, size: 20),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     "${number.name} ${number.phone} ",
//                     style: TextStyle(
//                       fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                       color: isSelected ? Colors.blue : Colors.black,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }).toList();
//       },
//       onSelected: (value) async {
//         print('Selected: $value');
//         setState(() => _isLoading = true);

//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('phoneNumber', value);
//         _selectedNumber = value;
//         await _refreshDataWithNewNumber(value);

//         setState(() => _isLoading = false);

//         EasyLoading.showToast("$value marked as selected",
//             toastPosition: EasyLoadingToastPosition.bottom);
//       },
//     );
//   }

//   Widget _buildBody() {
//     return Consumer<LeadCountViewModel>(
//       builder: (context, leadCountVM, child) {
//         return Consumer<AutoResponseViewModel>(
//           builder: (context, autoResponseVM, child) {
//             return Consumer<CampaignCountViewModel>(
//               builder: (context, campaignVM, child) {
//                 return Consumer<TempleteListViewModel>(
//                   builder: (context, templateVM, child) {
//                     return Consumer<CampaignChartViewModel>(
//                       builder: (context, chartListVM, child) {
//                         _updateCounts(leadCountVM, autoResponseVM, campaignVM, templateVM);
//                         _updateBusinessData(chartListVM);
//                         _updateTemplateData(templateVM);

//                         return SingleChildScrollView(
//                           child: Column(
//                             children: [
//                               const SizedBox(height: 12),
//                               _buildTopCards(),
//                               const SizedBox(height: 20),
//                               _buildCharts(),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildTopCards() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 15.0),
//       child: Row(
//         children: [
//           HomePageCard(
//             title: "All Leads",
//             subtitle: "${(_countNewLeads ?? 0).toString()} / Total",
//             icon: Icons.leaderboard_rounded,
//             polygonAsset: "assets/images/home_polygon.png",
//             tap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const LeadListView()),
//               );
//             },
//           ),
//           const SizedBox(width: 10),
//           HomePageCard(
//             title: "All Campaigns",
//             subtitle: "${(_campaignCount ?? 0).toString()} / Total",
//             icon: Icons.leaderboard_rounded,
//             polygonAsset: "assets/images/home_polygon.png",
//             tap: () {
//               if (_modules.contains("Campaign") || _modules.contains('Campaigns')) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const CampaignListView()),
//                 );
//               } else {
//                 EasyLoading.showToast("Access to Campaign is not included in this Plan");
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCharts() {
//     return Padding(
//       padding: const EdgeInsets.all(15),
//       child: Column(
//         children: [
//           if (_modules.contains("Campaign") && _campaignCount != "0")
//             _buildCampaignChart(),
//           if (_modules.contains("Campaign") && _campaignCount != "0")
//             const SizedBox(height: 20),
//           if (_templateData.isNotEmpty) _buildTemplateChart(),
//         ],
//       ),
//     );
//   }

//   Widget _buildCampaignChart() {
//     return Container(
//       decoration: _buildChartDecoration(),
//       child: Column(
//         children: [
//           const SizedBox(height: 10),
//           const Text(
//             'Campaign',
//             style: TextStyle(
//               color: Colors.black,
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//             ),
//           ),
//           SfCircularChart(
//             tooltipBehavior: _tooltipBehavior,
//             legend: const Legend(
//               isVisible: true,
//               position: LegendPosition.top,
//               overflowMode: LegendItemOverflowMode.wrap,
//             ),
//             series: <PieSeries<ChartData, String>>[
//               PieSeries<ChartData, String>(
//                 legendIconType: LegendIconType.circle,
//                 radius: '100',
//                 dataSource: _businessData,
//                 enableTooltip: true,
//                 pointColorMapper: (ChartData sales, int index) =>
//                     _areaColor[index % _areaColor.length],
//                 xValueMapper: (ChartData sales, _) => sales.status,
//                 yValueMapper: (ChartData sales, _) => sales.count,
//               )
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTemplateChart() {
//     return Container(
//       decoration: _buildChartDecoration(),
//       child: Column(
//         children: [
//           const SizedBox(height: 10),
//           const Text(
//             'Template',
//             style: TextStyle(
//               color: Colors.black,
//               fontFamily: AppFonts.semiBold,
//               fontSize: 18,
//             ),
//           ),
//           SfCircularChart(
//             tooltipBehavior: _tooltipBehavior,
//             legend: const Legend(
//               isVisible: true,
//               position: LegendPosition.top,
//               overflowMode: LegendItemOverflowMode.wrap,
//             ),
//             series: <DoughnutSeries<TemplateChartData, String>>[
//               DoughnutSeries<TemplateChartData, String>(
//                 radius: '100',
//                 dataSource: _templateData,
//                 enableTooltip: true,
//                 pointColorMapper: (TemplateChartData sales, int index) =>
//                     _areaColor[index % _areaColor.length],
//                 xValueMapper: (TemplateChartData sales, _) => sales.status,
//                 yValueMapper: (TemplateChartData sales, _) => sales.count,
//               )
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   BoxDecoration _buildChartDecoration() {
//     return BoxDecoration(
//       borderRadius: BorderRadius.circular(16),
//       color: Colors.white,
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.12),
//           blurRadius: 6,
//           spreadRadius: 2,
//           offset: const Offset(0, 2),
//         ),
//       ],
//     );
//   }


  
//   void _updateItemsMap(WhatsappSettingViewModel whatsAppSettingVM) {
//     final leadController = Provider.of<LeadController>(context, listen: false);
//     _itemsMap.clear();
//     leadController.clearAllBusNums();
//     _allNums.clear();

//     for (var viewModel in whatsAppSettingVM.viewModels) {
//       final nmodel = viewModel.model;
//       if (nmodel != null) {
//         for (var record in nmodel.record ?? []) {
//           _allNums.add(record);
//           leadController.setAllBusNums(record.phone);
//           _allWhNums.add("${record.name} ${record.phone}");
//           _itemsMap[record.phone] = "${record.name} ${record.phone}";
//         }
//       }
//     }

//     print("all business numbers::::  ${leadController.allBusinessNumbers}");
//   }

//   void _updateCounts(
//     LeadCountViewModel leadCountVM,
//     AutoResponseViewModel autoResponseVM,
//     CampaignCountViewModel campaignVM,
//     TempleteListViewModel templateVM,
//   ) {
//     for (var viewModel in leadCountVM.viewModels) {
//       if (viewModel.model is NewLeadCountModel) {
//         final nmodel = viewModel.model as NewLeadCountModel;
//         _countNewLeads = nmodel.total;
//       }
//     }

//     for (var viewModel in autoResponseVM.viewModels) {
//       if (viewModel.model is AutoResponseModel) {
//         final automodel = viewModel.model as AutoResponseModel;
//         _autoResponseCount = automodel.total;
//       }
//     }

//     for (var viewModel in campaignVM.viewModels) {
//       if (viewModel.model is CampaignCountModel) {
//         final campmodel = viewModel.model as CampaignCountModel;
//         final pend = campmodel.result?.pending ?? "0";
//         final comp = campmodel.result?.completed ?? "0";
//         final abort = campmodel.result?.aborted ?? "0";
//         final prog = campmodel.result?.inProgress ?? "0";
//         final allCamp = int.parse(pend) + int.parse(comp) + int.parse(abort) + int.parse(prog);
//         _campaignCount = allCamp.toString();
//       }
//     }

  
//     for (var viewModel in templateVM.viewModels) {
//       if (viewModel.model is TemplateModel) {
//         final tempmodel = viewModel.model as TemplateModel;
//         _templateCount = tempmodel.data?.length;
//       }
//     }
//   }

//   void _updateTemplateData(TempleteListViewModel templateVM) {
//     final Map<String, int> categoryCount = {};
//     _templateData.clear();

//     for (var viewModel in templateVM.viewModels) {
//       if (viewModel.model is TemplateModel) {
//         final templateModel = viewModel.model as TemplateModel;
//         if (templateModel.data != null) {
//           for (var entry in templateModel.data!) {
//             final templateCategory = entry.category;
//             if (templateCategory != null) {
//               categoryCount[templateCategory] = (categoryCount[templateCategory] ?? 0) + 1;
//             }
//           }
//         }
//       }
//     }

//     categoryCount.forEach((category, count) {
//       _templateData.add(TemplateChartData(category, count));
//     });
//   }

//   void _updateBusinessData(CampaignChartViewModel chartListVM) {
//     _businessData.clear();

//     for (var viewModel in chartListVM.viewModels) {
//       if (viewModel.model is CampaignChartModel) {
//         final countagent = viewModel.model as CampaignChartModel;
//         if (countagent.result != null) {
//           final completed = int.parse(countagent.result?.completed ?? "0");
//           final pending = int.parse(countagent.result?.pending ?? "0");
//           final inProgress = int.parse(countagent.result?.inProgress ?? "0");
//           final aborted = int.parse(countagent.result?.aborted ?? "0");

//           _businessData.addAll([
//             ChartData("Pending", pending),
//             ChartData("In Progress", inProgress),
//             ChartData("Completed", completed),
//             ChartData("Aborted", aborted),
//           ]);
//         }
//       }
//     }
//   }

//   int _calculateUnreadCount(UnreadCountVm unreadCountVm) {
//     int totalUnreadCount = 0;
//     for (var viewModel in unreadCountVm.viewModels) {
//       if (viewModel.model is UnreadMsgModel) {
//         final unreadvm = viewModel.model as UnreadMsgModel;
//         totalUnreadCount = unreadvm.records?.length ?? 0;
//       }
//     }
//     return totalUnreadCount;
//   }

//   Future<void> _getUnreadCount() async {
//     final prefs = await SharedPreferences.getInstance();
//     final number = prefs.getString('phoneNumber');

//     if (!mounted) return;

//     await Provider.of<UnreadCountVm>(context, listen: false)
//         .fetchunreadcount(number: number ?? "");

//     if (mounted) setState(() {});
//   }

  
//   Future<void> _connectSocket() async {
//     log("connecting to socket::::::::::::::::::::::::::::::::: ");
    
//     final prefs = await SharedPreferences.getInstance();
//     final number = prefs.getString('phoneNumber');
//     final leadCtrl = Provider.of<LeadController>(context, listen: false);
//     final tkn = await AppUtils.getToken() ?? "";
    
//     Map<String, dynamic> decodedToken = {};
//     try {
//       decodedToken = Map<String, dynamic>.from(JwtDecoder.decode(tkn));
//     } catch (e, stackTrace) {
//       print("error in decode token >>>. $e. >>>> $stackTrace");
//     }
    
//     _token = tkn;
//     _phNum = number ?? "";
    
//     final userId = {
//       ...decodedToken,
//       "business_numbers": leadCtrl.allBusinessNumbers,
//       "business_number": number
//     };

//     log("user id sending in socket setup::::   $userId");

//     try {
//       _socket = IO.io(
//         'https://admin.watconnect.com',
//         IO.OptionBuilder()
//             .setTransports(['websocket'])
//             .setPath('/ibs/socket.io')
//             .setExtraHeaders({'Authorization': 'Bearer $_token'})
//             .build(),
//       );
      
//       _socket!.connect();
//       _socket!.onConnect((_) {
//         print('Connected to WebSocket on home');
//         _socket!.emit("setup", userId);
//       });
//       _socket!.on("connected", (_) {});
//       _socket!.on("receivedwhatsappmessage", (data) {
//         _getUnreadCount();
//       });
//       _socket!.onDisconnect((_) {
//         print(" WebSocket Disconnected home");
//       });
//       _socket!.onError((error) {
//         print(" WebSocket Error home: $error");
//       });
//     } catch (error) {
//       print("Error connecting to WebSocket home: $error");
//     }
//   }

//   void _disconnectSocket() {
//     _socket?.disconnect();
//     print(" WebSocket Disconnected on home");
//   }

 
  
//   Future<void> _checkPasswordChange() async {
//     final tkn = await AppUtils.getToken() ?? "";
//     Map<String, dynamic> decodedToken;
    
//     try {
//       decodedToken = Map<String, dynamic>.from(JwtDecoder.decode(tkn));
//     } catch (e) {
//       print("Error decoding token: $e");
//       return;
//     }

//     final userCtrl = Provider.of<GetUserViewModel>(context, listen: false);
//     userCtrl.clearUserData();
//     await userCtrl.fetchUser();
    
//     for (var viewModel in userCtrl.viewModels) {
//       final model = viewModel.model;
//       print("model password_changed_at ${model.password_changed_at}. decoded token>>> ${decodedToken['password_changed_at']}");

//       if (model.password_changed_at != decodedToken['password_changed_at']) {
//         AppUtils.logout(context);
//       }
//     }
//   }
// }


// class ChartData {
//   final String status;
//   final int count;
  
//   ChartData(this.status, this.count);
// }

// class TemplateChartData {
//   final String status;
//   final int count;
  
//   TemplateChartData(this.status, this.count);
// }