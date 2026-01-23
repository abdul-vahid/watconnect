// // ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously, prefer_typing_uninitialized_variables, unnecessary_brace_in_string_interps

// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart'
//     show SharedPreferences;
// // ignore: library_prefixes
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:whatsapp/main.dart';
// import 'package:whatsapp/models/recent_chat_model.dart';
// import 'package:whatsapp/models/unread_msg_model/unread_msg_model.dart';
// import 'package:whatsapp/utils/app_constants.dart';
// import 'package:whatsapp/utils/app_fonts.dart';
// import 'package:whatsapp/view_models/lead_controller.dart';
// import 'package:whatsapp/view_models/unread_count_vm.dart';
// import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
// import '../../models/lead_model.dart';
// import '../../utils/app_color.dart';
// import '../../utils/app_utils.dart';
// import '../../view_models/lead_list_vm.dart';
// import 'package:badges/badges.dart' as badges;

// class RecentChatView extends StatefulWidget {
//   const RecentChatView({super.key});
//   @override
//   State<RecentChatView> createState() => _RecentChatViewState();
// }

// class _RecentChatViewState extends State<RecentChatView> {
//   final List<Color> tagColors = [
//     Colors.red,
//     Colors.blue,
//     Colors.green,
//     Colors.orange,
//     Colors.purple,
//     Colors.yellow,
//     Colors.cyan,
//     Colors.pink,
//     Colors.teal,
//     Colors.brown,
//     Colors.indigo,
//     Colors.lime,
//     Colors.amber,
//     Colors.deepOrange,
//     Colors.deepPurple,
//     Colors.lightBlue,
//     Colors.lightGreen,
//     Colors.grey,
//     Colors.blueGrey,
//     Colors.black,
//     Colors.pinkAccent,
//     Colors.redAccent,
//     Colors.orangeAccent
//   ];
//   String finalResult = "";
//   IO.Socket? socket;
//   String token = "your_token_here";
//   Map<String, dynamic> userId = {};
//   String leadId = "lead_456";
//   String phNum = "+919876543210";
//   // final List<String> _leadfilter = [];
//   List<LeadModel> leadss = [];
//   TextEditingController textController = TextEditingController();
//   var leadlistvm;
//   var userlistvm;
//   // UnreadMsgModel? campginmodel;
//   List leadModelList = [];
//   List tempLeadModelList = [];
//   UnreadCountVm? unreadCountVm;
//   // List<UnreadCountMsgModel> unreadModel = [];
//   LeadListViewModel? leads;
//   String? selectlead;
//   String? selectuser;
//   bool isRefresh = false;
//   int countunread = 0;
//   List allRecentChats = [];
//   List pinnedLeads = [];

//   List unreadList = [];
//   String? number;

//   bool? shouldHideLeadNumber;
// // void filterLeadsByTag(int tagIndex) {
// //   List<LeadModel> filtered = allLeads
// //       .where((lead) => lead.tags.contains(tagIndex)) // your condition
// //       .toList();

// //   Navigator.push(
// //     context,
// //     MaterialPageRoute(
// //       builder: (_) => FilteredLeadsScreen(filteredLeads: filtered),
// //     ),
// //   );
// // }
//   @override
//   void initState() {
//     shouldHide();
//     _getUnreadCount();
//     getLeadList();
//     super.initState();
//     // connectSocket();
//   }

//   @override
//   void dispose() {
//     // disconnectSocket();
//     super.dispose();
//   }

//   bool noMatchedLeads = false;
//   List matched = [];
//   List others = [];

//   Future<void> _getUnreadCount() async {
//     final prefs = await SharedPreferences.getInstance();
//     number = prefs.getString('phoneNumber');

//     if (!mounted) return;

//     await Provider.of<UnreadCountVm>(context, listen: false)
//         .fetchunreadcount(number: number ?? "");

//     var unreadMsgModel;
//     for (var unreadModel in unreadCountVm?.viewModels ?? []) {
//       unreadMsgModel = unreadModel.model as UnreadMsgModel;
//     }

//     unreadList = unreadMsgModel?.records ?? [];

//     if (mounted) {
//       setState(() {});
//     }
//   }

//   int selectedTagId = 0;
//   List<String> tags = ["All", "Unread"];

//   void _filterLeads(String searchLead) {
//     searchLead = searchLead.trim().toLowerCase();

//     if (searchLead.isEmpty) {
//       List prioritizedLeads = [];
//       List otherLeads = [];
//       noMatchedLeads = false;

//       for (var lead in allRecentChats) {
//         bool hasUnread = unreadList.any(
//           (unread) =>
//               unread.whatsappNumber.toString().contains(lead.whatsapp_number),
//         );

//         if (hasUnread) {
//           prioritizedLeads.add(lead);
//         }
//       }

//       allRecentChats = [...prioritizedLeads, ...otherLeads];
//       allRecentChats = tempLeadModelList;

//       if (mounted) {
//         setState(() {});
//       }
//     } else {
//       matched = [];
//       others = [];

//       for (var lead in tempLeadModelList) {
//         var firstName = lead.contactname?.toLowerCase() ?? '';
//         var lastName = lead.full_number?.toLowerCase() ?? '';

//         if (firstName.contains(searchLead) || lastName.contains(searchLead)) {
//           matched.add(lead);
//         }
//       }

//       if (mounted) {
//         setState(() {
//           allRecentChats = [
//             ...matched,
//           ];
//           noMatchedLeads = matched.isEmpty;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     unreadCountVm = Provider.of<UnreadCountVm>(context);
//     leadlistvm = Provider.of<LeadListViewModel>(context);

//     return Scaffold(
//       backgroundColor: AppColor.pageBgGrey,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text(
//           'Chats',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         elevation: 5,
//         actions: [
//           showPin
//               ? Row(
//                   children: [
//                     // Tag Icon
//                     Padding(
//                       padding: const EdgeInsets.only(right: 12.0),
//                       child: InkWell(
//                         onTap: () {
//                           _showTagsBottomSheet(context);
//                         },
//                         child: const Icon(
//                           FontAwesomeIcons.tags,
//                           color: Colors.white,
//                           size: 24,
//                         ),
//                       ),
//                     ),

//                     // Pin Icon
//                     Padding(
//                       padding: const EdgeInsets.only(right: 16.0),
//                       child: InkWell(
//                         onTap: () {
//                           if (isPinned) {
//                             Provider.of<LeadListViewModel>(context,
//                                     listen: false)
//                                 .unpinChat(pinnedLeadId)
//                                 .then((onValue) {
//                               getLeadList(showLoading: false);
//                             });
//                           } else {
//                             Provider.of<LeadListViewModel>(context,
//                                     listen: false)
//                                 .pinChat(pinnedLeadId)
//                                 .then((onValue) {
//                               getLeadList(showLoading: false);
//                             });
//                           }
//                           setState(() {
//                             showPin = false;
//                             pinnedLeadId = "";
//                           });
//                         },
//                         child: isPinned == false
//                             ? const Icon(
//                                 Icons.push_pin_outlined,
//                                 color: Colors.white,
//                               )
//                             : Image.asset(
//                                 "assets/images/unpin_icon.png",
//                                 color: Colors.white,
//                                 height: 20,
//                               ),
//                       ),
//                     ),
//                   ],
//                 )
//               : const SizedBox(),
//         ],
//       ),
//       body: GestureDetector(
//         onTap: () {
//           setState(() {
//             pinnedLeadId = "";
//             showPin = false;
//             isPinned = false;
//           });
//           FocusScope.of(context).unfocus();
//         },
//         child: RefreshIndicator(
//           onRefresh: _pullRefresh,
//           child: (_pageBody()),
//         ),
//       ),
//     );
//   }

//   Future<String?> _marksread(String whatsappNumber) async {
//     final prefs = await SharedPreferences.getInstance();
//     String? number = prefs.getString('phoneNumber');

//     Map<String, String>? bodydata = {"whatsapp_number": whatsappNumber};

//     await Provider.of<UnreadCountVm>(context, listen: false).marksreadcountmsg(
//       leadnumber: whatsappNumber,
//       number: number,
//       bodydata: bodydata,
//     );
//     return null;
//   }

//   Future<void> _pullRefresh() async {
//     leads?.viewModels.clear();

//     await Provider.of<LeadListViewModel>(context, listen: false)
//         .fetchRecentChat();
//     await Provider.of<UnreadCountVm>(context, listen: false)
//         .fetchunreadcount(number: number);
//     getLeadList();
//     isRefresh = true;
//     return Future<void>.delayed(const Duration(seconds: 1));
//   }

//   Widget _pageBody() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//           child: TextField(
//             controller: textController,
//             onChanged: _filterLeads,
//             cursorColor: AppColor.navBarIconColor,
//             decoration: InputDecoration(
//               isDense: true,
//               hintText: 'Search...',
//               hintStyle: TextStyle(
//                 color: AppColor.textoriconColor.withOpacity(0.6),
//               ),
//               filled: true,
//               fillColor: Colors.white,
//               contentPadding: const EdgeInsets.all(10),
//               disabledBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: AppColor.backgroundGrey),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               border: OutlineInputBorder(
//                 borderSide: const BorderSide(color: AppColor.backgroundGrey),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: const BorderSide(
//                   color: AppColor.navBarIconColor,
//                   width: 1.5,
//                 ),
//               ),
//               prefixIcon: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: IconButton(
//                   icon: const Icon(Icons.search, color: Colors.black, size: 20),
//                   onPressed: () {},
//                 ),
//               ),
//               prefixIconConstraints: const BoxConstraints(minWidth: 40),
//             ),
//           ),
//         ),
//         pinnedLeads.isEmpty
//             ? const SizedBox()
//             : const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
//                 child: Text(
//                   "Pinned Leads",
//                   style: TextStyle(fontFamily: AppFonts.medium),
//                 ),
//               ),
//         pinnedLeads.isEmpty
//             ? const SizedBox()
//             // : Padding(
//             //     padding: const EdgeInsets.symmetric(horizontal: 12.0),
//             //     child: SizedBox(
//             //       height: 70,
//             //       child: ListView.builder(
//             //         scrollDirection: Axis.horizontal,
//             //         itemCount: pinnedLeads.length,
//             //         itemBuilder: (context, index) {
//             //           var model = pinnedLeads[index];
//             //           return Padding(
//             //             padding: const EdgeInsets.only(right: 10.0),
//             //             child: InkWell(
//             //                 onTap: () async {
//             //                   setState(() {
//             //                     pinnedLeadId = "";
//             //                     showPin = false;
//             //                     isPinned = false;
//             //                   });

//             //                   if (model.full_number != null) {
//             //                     _marksread(model.full_number ?? "");

//             //                     Navigator.push(
//             //                       context,
//             //                       MaterialPageRoute(
//             //                         builder: (context) => WhatsappChatScreen(
//             //                           pinnedLeads: pinnedLeads,
//             //                           leadName: model.contactname ?? "",
//             //                           wpnumber: model.full_number,
//             //                           id: model.id,
//             //                           contryCode: model.countrycode,
//             //                         ),
//             //                       ),
//             //                     ).then((_) {
//             //                       _getUnreadCount();
//             //                       setState(() {});
//             //                     });

//             //                     leads?.viewModels.clear();
//             //                     Provider.of<LeadListViewModel>(context,
//             //                             listen: false)
//             //                         .fetchRecentChat();
//             //                   } else {
//             //                     ScaffoldMessenger.of(context).showSnackBar(
//             //                       const SnackBar(
//             //                         content: Text('No Phone Number'),
//             //                         duration: Duration(seconds: 3),
//             //                         backgroundColor:
//             //                             AppColor.motivationCar1Color,
//             //                       ),
//             //                     );
//             //                   }
//             //                 },
//             //                 child: Container(
//             //                   width: 180, // adjust width as needed
//             //                   child: Row(
//             //                     crossAxisAlignment: CrossAxisAlignment.center,
//             //                     children: [
//             //                       // Avatar
//             //                       CircleAvatar(
//             //                         radius: 20,
//             //                         backgroundColor: AppColor.navBarIconColor,
//             //                         child: Text(
//             //                           model.contactname?.isNotEmpty == true
//             //                               ? model.contactname![0].toUpperCase()
//             //                               : '?',
//             //                           style: const TextStyle(
//             //                             fontSize: 20,
//             //                             color: Colors.white,
//             //                             fontWeight: FontWeight.bold,
//             //                           ),
//             //                         ),
//             //                       ),
//             //                       const SizedBox(
//             //                           width:
//             //                               8), // spacing between avatar and text
//             //                       // Name + Tag in a single horizontal row
//             //                       Expanded(
//             //                         child: Row(
//             //                           children: [
//             //                             Flexible(
//             //                               child: Text(
//             //                                 model.contactname ?? '',
//             //                                 maxLines: 1,
//             //                                 overflow: TextOverflow.ellipsis,
//             //                                 style: const TextStyle(
//             //                                     fontFamily: AppFonts.semiBold),
//             //                               ),
//             //                             ),
//             //                             const SizedBox(
//             //                                 width:
//             //                                     5), // small spacing between name and icon
//             //                             Icon(
//             //                               FontAwesomeIcons.tag,
//             //                               color: const Color.fromARGB(
//             //                                   255, 234, 74, 63),
//             //                               size: 14,
//             //                             ),
//             //                           ],
//             //                         ),
//             //                       ),
//             //                     ],
//             //                   ),
//             //                 )),
//             //           );
//             //         },
//             //       ),
//             //     ),
//             //   ),
//             // : Padding(
//             //     padding: const EdgeInsets.symmetric(horizontal: 12.0),
//             //     child: SizedBox(
//             //       height: 70,
//             //       child: ListView.builder(
//             //         scrollDirection: Axis.horizontal,
//             //         itemCount: pinnedLeads.length,
//             //         itemBuilder: (context, index) {
//             //           var model = pinnedLeads[index];
//             //           return Padding(
//             //             padding: const EdgeInsets.only(right: 10.0),
//             //             child: InkWell(
//             //               onTap: () async {
//             //                 // your existing onTap code
//             //               },
//             //               child: Column(
//             //                 mainAxisAlignment: MainAxisAlignment.center,
//             //                 children: [
//             //                   CircleAvatar(
//             //                     radius: 20,
//             //                     backgroundColor: AppColor.navBarIconColor,
//             //                     child: Text(
//             //                       model.contactname?.isNotEmpty == true
//             //                           ? model.contactname![0].toUpperCase()
//             //                           : '?',
//             //                       style: const TextStyle(
//             //                         fontSize: 20,
//             //                         color: Colors.white,
//             //                         fontWeight: FontWeight.bold,
//             //                       ),
//             //                     ),
//             //                   ),
//             //                   const SizedBox(height: 4),
//             //                   SizedBox(
//             //                     width: 150, // adjust width as needed
//             //                     child: Row(
//             //                       crossAxisAlignment: CrossAxisAlignment.center,
//             //                       children: [
//             //                         // Avatar
//             //                         CircleAvatar(
//             //                           radius: 20,
//             //                           backgroundColor: AppColor.navBarIconColor,
//             //                           child: Text(
//             //                             model.contactname?.isNotEmpty == true
//             //                                 ? model.contactname![0]
//             //                                     .toUpperCase()
//             //                                 : '?',
//             //                             style: const TextStyle(
//             //                               fontSize: 20,
//             //                               color: Colors.white,
//             //                               fontWeight: FontWeight.bold,
//             //                             ),
//             //                           ),
//             //                         ),
//             //                         const SizedBox(width: 8),
//             //                         // Name + Scrollable Tags
//             //                         Expanded(
//             //                           child: Row(
//             //                             children: [
//             //                               // Lead Name
//             //                               Flexible(
//             //                                 child: Text(
//             //                                   model.contactname ?? '',
//             //                                   maxLines: 1,
//             //                                   overflow: TextOverflow.ellipsis,
//             //                                   style: const TextStyle(
//             //                                       fontFamily:
//             //                                           AppFonts.semiBold),
//             //                                 ),
//             //                               ),
//             //                               const SizedBox(width: 5),
//             //                               // Scrollable tag icons
//             //                               Expanded(
//             //                                 child: SingleChildScrollView(
//             //                                   scrollDirection: Axis.horizontal,
//             //                                   child: Row(
//             //                                     children: [
//             //                                       const Padding(
//             //                                         padding: EdgeInsets.only(
//             //                                             right: 4.0),
//             //                                         child: Icon(
//             //                                           FontAwesomeIcons.tag,
//             //                                           color: Colors.red,
//             //                                           size: 14,
//             //                                         ),
//             //                                       ),
//             //                                       const Padding(
//             //                                         padding: EdgeInsets.only(
//             //                                             right: 4.0),
//             //                                         child: Icon(
//             //                                           FontAwesomeIcons.tag,
//             //                                           color: Colors.blue,
//             //                                           size: 14,
//             //                                         ),
//             //                                       ),
//             //                                       const Padding(
//             //                                         padding: EdgeInsets.only(
//             //                                             right: 4.0),
//             //                                         child: Icon(
//             //                                           FontAwesomeIcons.tag,
//             //                                           color: Colors.green,
//             //                                           size: 14,
//             //                                         ),
//             //                                       ),
//             //                                     ],
//             //                                   ),
//             //                                 ),
//             //                               ),
//             //                             ],
//             //                           ),
//             //                         ),
//             //                       ],
//             //                     ),
//             //                   )
//             //                 ],
//             //               ),
//             //             ),
//             //           );
//             //         },
//             //       ),
//             //     ),
//             //   ),
//             : Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                 child: SizedBox(
//                   height: 70,
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       children: [
//                         // Pinned leads avatars
//                         ...pinnedLeads.map((model) {
//                           return Padding(
//                             padding: const EdgeInsets.only(right: 10.0),
//                             child: InkWell(
//                               onTap: () async {
//                                 // your existing onTap code
//                               },
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   CircleAvatar(
//                                     radius: 20,
//                                     backgroundColor: AppColor.navBarIconColor,
//                                     child: Text(
//                                       model.contactname?.isNotEmpty == true
//                                           ? model.contactname![0].toUpperCase()
//                                           : '?',
//                                       style: const TextStyle(
//                                         fontSize: 20,
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   SizedBox(
//                                     width: 60,
//                                     child: Text(
//                                       model.contactname ?? '',
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       textAlign: TextAlign.center,
//                                       style: const TextStyle(
//                                           fontFamily: AppFonts.semiBold),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         }).toList(),

//                         // Clickable tags
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//         // : Padding(
//         //     padding: const EdgeInsets.symmetric(horizontal: 12.0),
//         //     child: SizedBox(
//         //       height: 70,
//         //       child: ListView.builder(
//         //           scrollDirection: Axis.horizontal,
//         //           itemCount: pinnedLeads.length,
//         //           itemBuilder: (context, index) {
//         //             var model = pinnedLeads[index];
//         //             return Padding(
//         //               padding: const EdgeInsets.only(right: 10.0),
//         //               child: InkWell(
//         //                 onTap: () async {
//         //                   setState(() {
//         //                     pinnedLeadId = "";
//         //                     showPin = false;
//         //                     isPinned = false;
//         //                   });

//         //                   if (model.full_number != null) {
//         //                     _marksread(model.full_number ?? "");

//         //                     Navigator.push(
//         //                       context,
//         //                       MaterialPageRoute(
//         //                         builder: (context) => WhatsappChatScreen(
//         //                           pinnedLeads: pinnedLeads,
//         //                           leadName: model.contactname ?? "",
//         //                           wpnumber: model.full_number,
//         //                           id: model.id,
//         //                           contryCode: model.countrycode,
//         //                         ),
//         //                       ),
//         //                     ).then((_) {
//         //                       _getUnreadCount();

//         //                       setState(() {
//         //                         // unreadMsgCount = "0";
//         //                         // unreadMsgCount = "";
//         //                       });
//         //                       // print("unreadMsgCount====${unreadMsgCount}  ");
//         //                     });
//         //                     leads?.viewModels.clear();
//         //                     Provider.of<LeadListViewModel>(context,
//         //                             listen: false)
//         //                         .fetchRecentChat();
//         //                   } else {
//         //                     ScaffoldMessenger.of(context).showSnackBar(
//         //                       const SnackBar(
//         //                         content: Text('No Phone Number '),
//         //                         duration: Duration(seconds: 3),
//         //                         backgroundColor:
//         //                             AppColor.motivationCar1Color,
//         //                       ),
//         //                     );
//         //                   }
//         //                 },
//         //                 child: SizedBox(
//         //                   width: 60,
//         //                   child: Column(
//         //                     children: [
//         //                       CircleAvatar(
//         //                         radius: 20,
//         //                         backgroundColor: AppColor.navBarIconColor,
//         //                         child: Text(
//         //                           "${pinnedLeads[index].contactname?.isNotEmpty == true ? pinnedLeads[index].contactname![0].toUpperCase() : '?'}",
//         //                           style: const TextStyle(
//         //                             fontSize: 20,
//         //                             color: Colors.white,
//         //                             fontWeight: FontWeight.bold,
//         //                           ),
//         //                         ),
//         //                       ),
//         //                       Text(
//         //                         pinnedLeads[index].contactname,
//         //                         overflow: TextOverflow.ellipsis,
//         //                         style: const TextStyle(
//         //                             fontFamily: AppFonts.semiBold),
//         //                       ),
//         //                       Text(
//         //                         pinnedLeads[index].contactname,
//         //                         overflow: TextOverflow.ellipsis,
//         //                         style: const TextStyle(
//         //                             fontFamily: AppFonts.semiBold),
//         //                       ),
//         //                     ],
//         //                   ),
//         //                 ),
//         //               ),
//         //             );
//         //           }),
//         //     ),
//         //   ),
//         Expanded(
//             child: chatLoader
//                 ? const Center(
//                     child: SizedBox(
//                       height: 50,
//                       width: 50,
//                       child: CircularProgressIndicator(),
//                     ),
//                   )
//                 : Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.5),
//                                 blurRadius: 5,
//                                 spreadRadius: 3,
//                                 offset: const Offset(2, 4),
//                               ),
//                             ],
//                             color: Colors.white,
//                             borderRadius: const BorderRadius.only(
//                               topLeft: Radius.circular(30),
//                               topRight: Radius.circular(30),
//                             ),
//                           ),
//                           child: Padding(
//                             padding:
//                                 const EdgeInsets.only(top: 12.0, bottom: 5),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 SizedBox(
//                                   height: 50,
//                                   child: SingleChildScrollView(
//                                     scrollDirection: Axis.horizontal,
//                                     child: Row(
//                                       children: [
//                                         // -------- TAG CHIPS --------
//                                         ...List.generate(tags.length, (index) {
//                                           final isSelected =
//                                               selectedTagId == index;
//                                           return Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 8.0),
//                                             child: InkWell(
//                                               onTap: () {
//                                                 setState(() {
//                                                   selectedTagId = index;
//                                                   if (index == 1) {
//                                                     unreadChatFilter();
//                                                   } else {
//                                                     allRecentChats =
//                                                         tempLeadModelList;
//                                                   }
//                                                 });
//                                               },
//                                               child: Container(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         horizontal: 12,
//                                                         vertical: 6),
//                                                 decoration: BoxDecoration(
//                                                   border: Border.all(
//                                                     color: isSelected
//                                                         ? Colors.black
//                                                         : Colors.transparent,
//                                                     width: 1.5,
//                                                   ),
//                                                   borderRadius:
//                                                       BorderRadius.circular(18),
//                                                 ),
//                                                 child: Text(
//                                                   tags[index],
//                                                   style: const TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           );
//                                         }),
//                                         Wrap(
//                                           spacing: 10,
//                                           children: uniqueTags.map((tag) {
//                                             final int index = uniqueTags.indexOf(
//                                                 tag); // to get color from tagColors
//                                             return Padding(
//                                               padding: const EdgeInsets.only(
//                                                   right: 10.0),
//                                               child: InkWell(
//                                                 borderRadius:
//                                                     BorderRadius.circular(18),
//                                                 onTap: () {
//                                                   // filterLeadsByTag(tag['id']); // use actual tag id
//                                                 },
//                                                 child: Container(
//                                                   padding:
//                                                       const EdgeInsets.all(8),
//                                                   decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             18),
//                                                     border: Border.all(
//                                                       color: tagColors[index %
//                                                           tagColors.length],
//                                                       width: 1.2,
//                                                     ),
//                                                     color: tagColors[index %
//                                                             tagColors.length]
//                                                         .withOpacity(0.1),
//                                                   ),
//                                                   child: Icon(
//                                                     FontAwesomeIcons.tag,
//                                                     color: tagColors[index %
//                                                         tagColors.length],
//                                                     size: 18,
//                                                   ),
//                                                 ),
//                                               ),
//                                             );
//                                           }).toList(),
//                                         )
//                                         // ...List.generate(23, (index) {
//                                         //   return Padding(
//                                         //     padding: const EdgeInsets.only(
//                                         //         right: 10.0),
//                                         //     child: InkWell(
//                                         //       borderRadius:
//                                         //           BorderRadius.circular(18),
//                                         //       onTap: () {
//                                         //         // filterLeadsByTag(index);
//                                         //       },
//                                         //       child: Container(
//                                         //         padding:
//                                         //             const EdgeInsets.all(8),
//                                         //         decoration: BoxDecoration(
//                                         //           borderRadius:
//                                         //               BorderRadius.circular(18),
//                                         //           border: Border.all(
//                                         //             color: tagColors[index %
//                                         //                 tagColors.length],
//                                         //             width: 1.2,
//                                         //           ),
//                                         //           // optional background
//                                         //           color: tagColors[index %
//                                         //                   tagColors.length]
//                                         //               .withOpacity(0.1),
//                                         //         ),
//                                         //         child: Icon(
//                                         //           FontAwesomeIcons.tag,
//                                         //           color: tagColors[
//                                         //               index % tagColors.length],
//                                         //           size: 18,
//                                         //         ),
//                                         //       ),
//                                         //     ),
//                                         //   );
//                                         // }),
//                                         // -------- TAG ICONS --------
//                                         // ...List.generate(23, (index) {
//                                         //   return Padding(
//                                         //     padding: const EdgeInsets.only(
//                                         //         right: 10.0),
//                                         //     child: InkWell(
//                                         //       onTap: () {
//                                         //         // filterLeadsByTag(index);
//                                         //       },
//                                         //       child: Icon(
//                                         //         FontAwesomeIcons.tag,
//                                         //         color: tagColors[
//                                         //             index % tagColors.length],
//                                         //         size: 22,
//                                         //       ),
//                                         //     ),
//                                         //   );
//                                         // }),
//                                       ],
//                                     ),
//                                   ),
//                                 ),

//                                 const Divider(),
//                                 // Lead Chat List
//                                 const SizedBox(height: 10),
//                                 allRecentChats.isEmpty || noMatchedLeads
//                                     ? const Center(
//                                         child: Padding(
//                                           padding: EdgeInsets.only(top: 38.0),
//                                           child: Text(
//                                             "No Chat Found..",
//                                             style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.w600),
//                                           ),
//                                         ),
//                                       )
//                                     : Expanded(
//                                         child: ListView.builder(
//                                           itemCount: allRecentChats.length,
//                                           physics:
//                                               const BouncingScrollPhysics(),
//                                           itemBuilder: (context, index) {
//                                             final lead = allRecentChats[index];
//                                             String unreadCount = "0";

//                                             for (var p in unreadList) {
//                                               if (lead.full_number
//                                                   .toString()
//                                                   .contains(p.whatsappNumber)) {
//                                                 unreadCount = p.unreadMsgCount;
//                                                 break;
//                                               }
//                                             }

//                                             return leadRecordList(
//                                                 lead, unreadCount);
//                                           },
//                                         ),
//                                       ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   )),
//       ],
//     );
//   }

//   bool chatLoader = false;
//   Future<void> getLeadList({bool showLoading = true}) async {
//     if (mounted) {
//       if (showLoading == true) {
//         setState(() {
//           chatLoader = true;
//         });
//       }
//     }

//     await Provider.of<LeadListViewModel>(navigatorKey.currentContext!,
//             listen: false)
//         .fetchRecentChat()
//         .then((onValue) {
//       allRecentChats = [];
//       tempLeadModelList = [];
//       pinnedLeads = [];

//       try {
//         for (var viewModel in leadlistvm.viewModels) {
//           var recentMsgmodel = viewModel.model;
//           if (recentMsgmodel?.records != null) {
//             for (var record in recentMsgmodel!.records!) {
//               allRecentChats.add(record);
//               tempLeadModelList.add(record);
//               if (record.pinned) {
//                 pinnedLeads.add(record);
//               }
//             }
//           }
//         }
//       } catch (e) {
//         allRecentChats = [];
//       }
//     });

//     if (mounted) {
//       setState(() {
//         chatLoader = false;
//       });
//     }
//   }

//   List<dynamic> uniqueTags = [];

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   uniqueTags = getUniqueTagsFromLeads();
//   // }

//   List<dynamic> getUniqueTagsFromLeads() {
//     final Set<String> seenTagIds = {};
//     final List<dynamic> uniqueTags = [];

//     for (var record in tempLeadModelList) {
//       if (record.tag_names != null && record.tag_names.isNotEmpty) {
//         for (var tag in record.tag_names) {
//           if (!seenTagIds.contains(tag['id'])) {
//             seenTagIds.add(tag['id']);
//             uniqueTags.add(tag);
//           }
//         }
//       }
//     }
//     return uniqueTags;
//   }

//   bool showPin = false;
//   String pinnedLeadId = "";
//   bool isPinned = false;

//   Widget leadRecordList(Records model, String unreadMsgCount) {
//     Color statusColor;
//     statusColor = AppColor.navBarIconColor;

//     // Function to format phone number based on shouldHideLeadNumber
//     String formatPhoneNumber(String? phoneNumber) {
//       if (phoneNumber == null || phoneNumber.isEmpty) return '';

//       if (shouldHideLeadNumber == true && phoneNumber.length > 5) {
//         // Show only last 5 digits, mask the rest with X
//         int totalLength = phoneNumber.length;
//         String lastFiveDigits = phoneNumber.substring(totalLength - 5);
//         String maskedPart = 'X' * (totalLength - 5);
//         return '$maskedPart$lastFiveDigits';
//       } else {
//         return phoneNumber;
//       }
//     }

//     return GestureDetector(
//       onLongPress: () {
//         setState(() {
//           showPin = true;
//           pinnedLeadId = model.lead_id ?? "";
//           isPinned = model.pinned ?? false;
//         });
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: showPin && pinnedLeadId == model.lead_id
//               ? AppColor.pageBgGrey
//               : Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           border: Border(
//             left: BorderSide(
//               color: statusColor,
//               width: 5,
//             ),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 5,
//               spreadRadius: 3,
//               offset: const Offset(2, 4),
//             ),
//           ],
//         ),
//         margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
//           child: InkWell(
//             onTap: () {
//               setState(() {
//                 pinnedLeadId = "";
//                 showPin = false;
//                 isPinned = false;
//               });
//               if (model.full_number != null) {
//                 _marksread(model.full_number ?? "");

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => WhatsappChatScreen(
//                       pinnedLeads: pinnedLeads,
//                       leadName: model.contactname ?? "",
//                       wpnumber: model.full_number,
//                       id: model.id,
//                       contryCode: model.countrycode,
//                     ),
//                   ),
//                 ).then((_) {
//                   _getUnreadCount();

//                   setState(() {
//                     unreadMsgCount = "0";
//                     unreadMsgCount = "";
//                   });
//                   print("unreadMsgCount====${unreadMsgCount}  ");
//                 });
//                 leads?.viewModels.clear();
//                 Provider.of<LeadListViewModel>(context, listen: false)
//                     .fetchRecentChat();
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('No Phone Number '),
//                     duration: Duration(seconds: 3),
//                     backgroundColor: AppColor.motivationCar1Color,
//                   ),
//                 );
//               }
//             },
//             child: Row(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 18.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircleAvatar(
//                         radius: 20,
//                         backgroundColor: AppColor.navBarIconColor,
//                         child: Text(
//                           model.contactname?.isNotEmpty == true
//                               ? model.contactname![0].toUpperCase()
//                               : '?',
//                           style: const TextStyle(
//                             fontSize: 20,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 10.0, horizontal: 5),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "${model.contactname}",
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontFamily: AppFonts.semiBold,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(
//                                 height: 3,
//                               ),
//                               Text(
//                                 formatPhoneNumber(model.full_number),
//                                 style: const TextStyle(fontSize: 12),
//                               ),
//                               const SizedBox(
//                                 height: 5,
//                               ),
//                               Text(
//                                 "${model.message}",
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(
//                                     fontSize: 12, color: Colors.black54),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     if (unreadMsgCount != "0" && unreadMsgCount.isNotEmpty)
//                       badges.Badge(
//                         badgeStyle: const badges.BadgeStyle(
//                           badgeColor: Colors.green,
//                         ),
//                         badgeContent: Text(
//                           unreadMsgCount,
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       )
//                     else
//                       const SizedBox.shrink(),
//                     Text(
//                       formatDateTime(model.createddate.toString()),
//                       style:
//                           const TextStyle(fontSize: 10, color: Colors.black54),
//                     ),
//                     model.pinned ?? false
//                         ? const Padding(
//                             padding: EdgeInsets.only(top: 8.0),
//                             child: Icon(
//                               Icons.push_pin,
//                               color: Colors.black87,
//                               size: 18,
//                             ),
//                           )
//                         : const SizedBox()
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   bool noRecordFound = false;
//   void filterLeads(String? filter) {
//     leadModelList = tempLeadModelList;
//     if (filter == null) return;
//     setState(() {
//       List<dynamic> matchleads = leadModelList
//           .where(
//               (lead) => lead.leadstatus?.toLowerCase() == filter.toLowerCase())
//           .toList();

//       allRecentChats = matchleads;
//       noRecordFound = matchleads.isEmpty;
//     });
//   }

//   Future<void> connectSocket() async {
//     // final prefs = await SharedPreferences.getInstance();
//     // String? number = prefs.getString('phoneNumber');

//     String tkn = await AppUtils.getToken() ?? "";
//     // Map<String, dynamic> decodedToken = JwtDecoder.decode(tkn);
//     final prefs = await SharedPreferences.getInstance();
//     String? number = prefs.getString('phoneNumber');
//     LeadController leadCtrl = Provider.of(context, listen: false);
//     token = tkn;
//     phNum = number ?? "";
//     Map<String, dynamic> decodedToken = Map<String, dynamic>.from(
//       JwtDecoder.decode(tkn),
//     );

//     token = tkn;
//     phNum = number ?? "";
//     userId = decodedToken;

//     userId.addAll({
//       "business_numbers": leadCtrl.allBusinessNumbers,
//       "business_number": number
//     });

//     log("user id sending in socket setup::::   $userId");

//     try {
//       // print("Token: $token");

//       socket = IO.io(
//         'https://admin.watconnect.com',
//         IO.OptionBuilder()
//             .setTransports(['websocket'])
//             .setPath('/ibs/socket.io')
//             .setExtraHeaders({'Authorization': 'Bearer $token'})
//             .build(),
//       );
//       socket!.connect();
//       socket!.onConnect((_) {
//         print('Connected to WebSocket recent ');
//         socket!.emit("setup", userId);
//       });
//       socket!.on("connected", (_) {
//         // print(" WebSocket setup complete");
//       });

//       socket!.on("receivedwhatsappmessage", (data) {
//         print(" New WhatsApp message: $data");
//         getLeadList(showLoading: false);
//         _getUnreadCount();
//       });

//       socket!.onDisconnect((_) {
//         print(" WebSocket Disconnected");
//       });

//       socket!.onError((error) {
//         print(" WebSocket Error: $error");
//       });
//     } catch (error) {
//       print("Error connecting to WebSocket: $error");
//     }
//   }

//   void disconnectSocket() {
//     if (socket != null) {
//       socket!.disconnect();
//       print(" WebSocket Disconnected  recent");
//     }
//   }

//   void _showTagsBottomSheet(BuildContext context) {
//     bool isCreatingNewLabel = false;
//     TextEditingController labelController = TextEditingController();

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               height: MediaQuery.of(context).size.height * 0.7,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header with title and close button
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Label chat',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () => Navigator.pop(context),
//                         icon: const Icon(Icons.close, size: 24),
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                       ),
//                     ],
//                   ),

//                   const Divider(height: 20),

//                   // New label option or TextField
//                   isCreatingNewLabel
//                       ? Row(
//                           children: [
//                             Expanded(
//                               child: TextField(
//                                 controller: labelController,
//                                 autofocus: true,
//                                 decoration: const InputDecoration(
//                                   hintText: 'Enter label name',
//                                   border: OutlineInputBorder(),
//                                   contentPadding: EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 10,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             IconButton(
//                               onPressed: () {
//                                 // Save the new label
//                                 if (labelController.text.isNotEmpty) {
//                                   print('New label: ${labelController.text}');
//                                   setState(() {
//                                     isCreatingNewLabel = false;
//                                     labelController.clear();
//                                   });
//                                 }
//                               },
//                               icon:
//                                   const Icon(Icons.check, color: Colors.green),
//                             ),
//                           ],
//                         )
//                       : ListTile(
//                           contentPadding:
//                               const EdgeInsets.symmetric(horizontal: 0),
//                           leading: const Icon(Icons.add, size: 24),
//                           title: const Text(
//                             'New label',
//                             style: TextStyle(fontSize: 16),
//                           ),
//                           onTap: () {
//                             setState(() {
//                               isCreatingNewLabel = true;
//                             });
//                           },
//                         ),

//                   const SizedBox(height: 10),

//                   // Labels list
//                   Expanded(
//                     child: ListView.builder(
//                       padding: EdgeInsets.zero,
//                       itemCount: 9,
//                       itemBuilder: (context, index) {
//                         List<Color> tagColors = [
//                           const Color(0xFF42A5F5), // Blue
//                           const Color(0xFFFDD835), // Yellow
//                           const Color(0xFFEF5350), // Red
//                           const Color(0xFFAB47BC), // Purple
//                           const Color(0xFF26A69A), // Teal
//                           const Color(0xFFFFB74D), // Orange
//                           const Color(0xFFFFB74D), // Orange
//                           const Color(0xFF66BB6A), // Green
//                           const Color(0xFF5C6BC0), // Indigo
//                         ];

//                         List<String> tagNames = [
//                           'New customer',
//                           'New order',
//                           'Pending payment',
//                           'Paid',
//                           'Order complete',
//                           'Important',
//                           'Follow up',
//                           'Lead',
//                         ];

//                         // WhatsApp Business style tag icons
//                         List<IconData> tagIcons = [
//                           FontAwesomeIcons.tags,
//                           FontAwesomeIcons.tags,
//                           FontAwesomeIcons.tags,
//                           FontAwesomeIcons.tags,
//                           FontAwesomeIcons.tags,
//                           FontAwesomeIcons.tags,
//                         ];

//                         return ListTile(
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 0,
//                             vertical: 4,
//                           ),
//                           leading: Container(
//                             width: 40,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               color: tagColors[index].withOpacity(0.15),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               tagIcons[index],
//                               size: 20,
//                               color: tagColors[index],
//                             ),
//                           ),
//                           title: Text(
//                             tagNames[index],
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                           trailing: Checkbox(
//                             value: false, // Manage state here
//                             onChanged: (value) {},
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   // Save Button
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.grey.shade300,
//                         foregroundColor: Colors.grey.shade600,
//                         elevation: 0,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: const Text(
//                         'Save',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   unreadChatFilter() {
//     List prioritizedLeads = [];
//     List otherLeads = [];

//     for (var lead in allRecentChats) {
//       bool hasUnread = unreadList.any(
//         (unread) =>
//             unread.whatsappNumber.toString().contains(lead.whatsapp_number),
//       );

//       if (hasUnread) {
//         prioritizedLeads.add(lead);
//       } else {
//         otherLeads.add(lead);
//       }
//     }

//     allRecentChats = [...prioritizedLeads];
//   }

//   String formatDateTime(String isoString) {
//     final inputDate = DateTime.parse(isoString).toLocal();
//     final now = DateTime.now();

//     final isToday = inputDate.year == now.year &&
//         inputDate.month == now.month &&
//         inputDate.day == now.day;

//     if (isToday) {
//       return DateFormat.jm().format(inputDate);
//     } else {
//       return DateFormat('MMM dd, yy').format(inputDate);
//     }
//   }

//   Future<void> shouldHide() async {
//     final prefs = await SharedPreferences.getInstance();
//     shouldHideLeadNumber = prefs.getBool(SharedPrefsConstants.shouldHideNumber);
//     setState(() {});
//   }
// }

// // // ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously, prefer_typing_uninitialized_variables, unnecessary_brace_in_string_interps

// // import 'dart:convert';
// // import 'dart:developer';

// // import 'package:flutter/material.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:intl/intl.dart';
// // import 'package:jwt_decoder/jwt_decoder.dart';
// // import 'package:provider/provider.dart';
// // import 'package:shared_preferences/shared_preferences.dart'
// //     show SharedPreferences;
// // // ignore: library_prefixes
// // import 'package:socket_io_client/socket_io_client.dart' as IO;
// // import 'package:whatsapp/main.dart';
// // import 'package:whatsapp/models/recent_chat_model.dart';
// // import 'package:whatsapp/models/unread_msg_model/unread_msg_model.dart';
// // import 'package:whatsapp/utils/app_constants.dart';
// // import 'package:whatsapp/utils/app_fonts.dart';
// // import 'package:whatsapp/view_models/lead_controller.dart';
// // import 'package:whatsapp/view_models/unread_count_vm.dart';
// // import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
// // import '../../models/lead_model.dart';
// // import '../../models/tag_model.dart'; // Tag model import करें
// // import '../../utils/app_color.dart';
// // import '../../utils/app_utils.dart';
// // import '../../view_models/lead_list_vm.dart';
// // import '../../view_models/tags_list_vm.dart'; // TagsListViewModel import करें
// // import 'package:badges/badges.dart' as badges;

// // class RecentChatView extends StatefulWidget {
// //   const RecentChatView({super.key});
// //   @override
// //   State<RecentChatView> createState() => _RecentChatViewState();
// // }

// // class _RecentChatViewState extends State<RecentChatView> {
// //   final List<Color> tagColors = [
// //     Colors.red,
// //     Colors.blue,
// //     Colors.green,
// //     Colors.orange,
// //     Colors.purple,
// //     Colors.yellow,
// //     Colors.cyan,
// //     Colors.pink,
// //     Colors.teal,
// //     Colors.brown,
// //     Colors.indigo,
// //     Colors.lime,
// //     Colors.amber,
// //     Colors.deepOrange,
// //     Colors.deepPurple,
// //     Colors.lightBlue,
// //     Colors.lightGreen,
// //     Colors.grey,
// //     Colors.blueGrey,
// //     Colors.black,
// //     Colors.pinkAccent,
// //     Colors.redAccent,
// //     Colors.orangeAccent
// //   ];
// //   String finalResult = "";
// //   IO.Socket? socket;
// //   String token = "your_token_here";
// //   Map<String, dynamic> userId = {};
// //   String leadId = "lead_456";
// //   String phNum = "+919876543210";
// //   List<LeadModel> leadss = [];
// //   TextEditingController textController = TextEditingController();
// //   var leadlistvm;
// //   var userlistvm;
// //   List leadModelList = [];
// //   List tempLeadModelList = [];
// //   UnreadCountVm? unreadCountVm;
// //   LeadListViewModel? leads;
// //   String? selectlead;
// //   String? selectuser;
// //   bool isRefresh = false;
// //   int countunread = 0;
// //   List allRecentChats = [];
// //   List pinnedLeads = [];
// //   List unreadList = [];
// //   String? number;
// //   bool? shouldHideLeadNumber;

// //   // Tags related variables
// //   List<TagModel> allTagsList = [];
// //   List<TagModel> tempTagsList = [];
// //   bool updateLoader = false;

// //   @override
// //   void initState() {
// //     shouldHide();
// //     _getUnreadCount();
// //     getLeadList();
// //     getTagsList(); // Tags fetch करें
// //     super.initState();
// //   }

// //   @override
// //   void dispose() {
// //     super.dispose();
// //   }

// //   bool noMatchedLeads = false;
// //   List matched = [];
// //   List others = [];

// //   Future<void> _getUnreadCount() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     number = prefs.getString('phoneNumber');

// //     if (!mounted) return;

// //     await Provider.of<UnreadCountVm>(context, listen: false)
// //         .fetchunreadcount(number: number ?? "");

// //     var unreadMsgModel;
// //     for (var unreadModel in unreadCountVm?.viewModels ?? []) {
// //       unreadMsgModel = unreadModel.model as UnreadMsgModel;
// //     }

// //     unreadList = unreadMsgModel?.records ?? [];

// //     if (mounted) {
// //       setState(() {});
// //     }
// //   }

// //   int selectedTagId = 0;
// //   List<String> tags = ["All", "Unread"];

// //   void _filterLeads(String searchLead) {
// //     searchLead = searchLead.trim().toLowerCase();

// //     if (searchLead.isEmpty) {
// //       List prioritizedLeads = [];
// //       List otherLeads = [];
// //       noMatchedLeads = false;

// //       for (var lead in allRecentChats) {
// //         bool hasUnread = unreadList.any(
// //           (unread) =>
// //               unread.whatsappNumber.toString().contains(lead.whatsapp_number),
// //         );

// //         if (hasUnread) {
// //           prioritizedLeads.add(lead);
// //         }
// //       }

// //       allRecentChats = [...prioritizedLeads, ...otherLeads];
// //       allRecentChats = tempLeadModelList;

// //       if (mounted) {
// //         setState(() {});
// //       }
// //     } else {
// //       matched = [];
// //       others = [];

// //       for (var lead in tempLeadModelList) {
// //         var firstName = lead.contactname?.toLowerCase() ?? '';
// //         var lastName = lead.full_number?.toLowerCase() ?? '';

// //         if (firstName.contains(searchLead) || lastName.contains(searchLead)) {
// //           matched.add(lead);
// //         }
// //       }

// //       if (mounted) {
// //         setState(() {
// //           allRecentChats = [
// //             ...matched,
// //           ];
// //           noMatchedLeads = matched.isEmpty;
// //         });
// //       }
// //     }
// //   }

// //   void filterLeadsByTag(String tagId) {
// //     List<LeadModel> filtered = allRecentChats
// //         .where((lead) => lead.tags != null && lead.tags!.contains(tagId))
// //         .toList();

// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (_) => FilteredLeadsScreen(filteredLeads: filtered),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     unreadCountVm = Provider.of<UnreadCountVm>(context);
// //     leadlistvm = Provider.of<LeadListViewModel>(context);

// //     return Scaffold(
// //       backgroundColor: AppColor.pageBgGrey,
// //       appBar: AppBar(
// //         automaticallyImplyLeading: false,
// //         title: const Text(
// //           'Chats',
// //           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
// //         ),
// //         centerTitle: true,
// //         elevation: 5,
// //         actions: [
// //           showPin
// //               ? Row(
// //                   children: [
// //                     // Tag Icon
// //                     Padding(
// //                       padding: const EdgeInsets.only(right: 12.0),
// //                       child: InkWell(
// //                         onTap: () {
// //                           _showTagsBottomSheet(context);
// //                         },
// //                         child: const Icon(
// //                           FontAwesomeIcons.tags,
// //                           color: Colors.white,
// //                           size: 24,
// //                         ),
// //                       ),
// //                     ),

// //                     // Pin Icon
// //                     Padding(
// //                       padding: const EdgeInsets.only(right: 16.0),
// //                       child: InkWell(
// //                         onTap: () {
// //                           if (isPinned) {
// //                             Provider.of<LeadListViewModel>(context,
// //                                     listen: false)
// //                                 .unpinChat(pinnedLeadId)
// //                                 .then((onValue) {
// //                               getLeadList(showLoading: false);
// //                             });
// //                           } else {
// //                             Provider.of<LeadListViewModel>(context,
// //                                     listen: false)
// //                                 .pinChat(pinnedLeadId)
// //                                 .then((onValue) {
// //                               getLeadList(showLoading: false);
// //                             });
// //                           }
// //                           setState(() {
// //                             showPin = false;
// //                             pinnedLeadId = "";
// //                           });
// //                         },
// //                         child: isPinned == false
// //                             ? const Icon(
// //                                 Icons.push_pin_outlined,
// //                                 color: Colors.white,
// //                               )
// //                             : Image.asset(
// //                                 "assets/images/unpin_icon.png",
// //                                 color: Colors.white,
// //                                 height: 20,
// //                               ),
// //                       ),
// //                     ),
// //                   ],
// //                 )
// //               : const SizedBox(),
// //         ],
// //       ),
// //       body: GestureDetector(
// //         onTap: () {
// //           setState(() {
// //             pinnedLeadId = "";
// //             showPin = false;
// //             isPinned = false;
// //           });
// //           FocusScope.of(context).unfocus();
// //         },
// //         child: RefreshIndicator(
// //           onRefresh: _pullRefresh,
// //           child: (_pageBody()),
// //         ),
// //       ),
// //     );
// //   }

// //   Future<String?> _marksread(String whatsappNumber) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     String? number = prefs.getString('phoneNumber');

// //     Map<String, String>? bodydata = {"whatsapp_number": whatsappNumber};

// //     await Provider.of<UnreadCountVm>(context, listen: false).marksreadcountmsg(
// //       leadnumber: whatsappNumber,
// //       number: number,
// //       bodydata: bodydata,
// //     );
// //     return null;
// //   }

// //   Future<void> _pullRefresh() async {
// //     leads?.viewModels.clear();

// //     await Provider.of<LeadListViewModel>(context, listen: false)
// //         .fetchRecentChat();
// //     await Provider.of<UnreadCountVm>(context, listen: false)
// //         .fetchunreadcount(number: number);
// //     getLeadList();
// //     getTagsList(); // Refresh tags
// //     isRefresh = true;
// //     return Future<void>.delayed(const Duration(seconds: 1));
// //   }

// //   Widget _pageBody() {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
// //           child: TextField(
// //             controller: textController,
// //             onChanged: _filterLeads,
// //             cursorColor: AppColor.navBarIconColor,
// //             decoration: InputDecoration(
// //               isDense: true,
// //               hintText: 'Search...',
// //               hintStyle: TextStyle(
// //                 color: AppColor.textoriconColor.withOpacity(0.6),
// //               ),
// //               filled: true,
// //               fillColor: Colors.white,
// //               contentPadding: const EdgeInsets.all(10),
// //               disabledBorder: OutlineInputBorder(
// //                 borderSide: const BorderSide(color: AppColor.backgroundGrey),
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               border: OutlineInputBorder(
// //                 borderSide: const BorderSide(color: AppColor.backgroundGrey),
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               focusedBorder: OutlineInputBorder(
// //                 borderRadius: BorderRadius.circular(10),
// //                 borderSide: const BorderSide(
// //                   color: AppColor.navBarIconColor,
// //                   width: 1.5,
// //                 ),
// //               ),
// //               prefixIcon: Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 10),
// //                 child: IconButton(
// //                   icon: const Icon(Icons.search, color: Colors.black, size: 20),
// //                   onPressed: () {},
// //                 ),
// //               ),
// //               prefixIconConstraints: const BoxConstraints(minWidth: 40),
// //             ),
// //           ),
// //         ),
// //         pinnedLeads.isEmpty
// //             ? const SizedBox()
// //             : const Padding(
// //                 padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
// //                 child: Text(
// //                   "Pinned Leads",
// //                   style: TextStyle(fontFamily: AppFonts.medium),
// //                 ),
// //               ),
// //         pinnedLeads.isEmpty
// //             ? const SizedBox()
// //             : Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 12.0),
// //                 child: SizedBox(
// //                   height: 70,
// //                   child: SingleChildScrollView(
// //                     scrollDirection: Axis.horizontal,
// //                     child: Row(
// //                       children: [
// //                         // Pinned leads avatars
// //                         ...pinnedLeads.map((model) {
// //                           return Padding(
// //                             padding: const EdgeInsets.only(right: 10.0),
// //                             child: InkWell(
// //                               onTap: () async {
// //                                 setState(() {
// //                                   pinnedLeadId = "";
// //                                   showPin = false;
// //                                   isPinned = false;
// //                                 });

// //                                 if (model.full_number != null) {
// //                                   _marksread(model.full_number ?? "");

// //                                   Navigator.push(
// //                                     context,
// //                                     MaterialPageRoute(
// //                                       builder: (context) => WhatsappChatScreen(
// //                                         pinnedLeads: pinnedLeads,
// //                                         leadName: model.contactname ?? "",
// //                                         wpnumber: model.full_number,
// //                                         id: model.id,
// //                                         contryCode: model.countrycode,
// //                                       ),
// //                                     ),
// //                                   ).then((_) {
// //                                     _getUnreadCount();
// //                                     setState(() {});
// //                                   });

// //                                   leads?.viewModels.clear();
// //                                   Provider.of<LeadListViewModel>(context,
// //                                           listen: false)
// //                                       .fetchRecentChat();
// //                                 } else {
// //                                   ScaffoldMessenger.of(context).showSnackBar(
// //                                     const SnackBar(
// //                                       content: Text('No Phone Number'),
// //                                       duration: Duration(seconds: 3),
// //                                       backgroundColor:
// //                                           AppColor.motivationCar1Color,
// //                                     ),
// //                                   );
// //                                 }
// //                               },
// //                               child: Column(
// //                                 mainAxisAlignment: MainAxisAlignment.center,
// //                                 children: [
// //                                   CircleAvatar(
// //                                     radius: 20,
// //                                     backgroundColor: AppColor.navBarIconColor,
// //                                     child: Text(
// //                                       model.contactname?.isNotEmpty == true
// //                                           ? model.contactname![0].toUpperCase()
// //                                           : '?',
// //                                       style: const TextStyle(
// //                                         fontSize: 20,
// //                                         color: Colors.white,
// //                                         fontWeight: FontWeight.bold,
// //                                       ),
// //                                     ),
// //                                   ),
// //                                   const SizedBox(height: 4),
// //                                   SizedBox(
// //                                     width: 60,
// //                                     child: Text(
// //                                       model.contactname ?? '',
// //                                       maxLines: 1,
// //                                       overflow: TextOverflow.ellipsis,
// //                                       textAlign: TextAlign.center,
// //                                       style: const TextStyle(
// //                                           fontFamily: AppFonts.semiBold),
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           );
// //                         }).toList(),

// //                         // All tags as clickable icons
// //                         if (allTagsList.isNotEmpty) ...[
// //                           const SizedBox(width: 20),
// //                           ...allTagsList.map((tag) {
// //                             return Padding(
// //                               padding: const EdgeInsets.only(right: 12.0),
// //                               child: InkWell(
// //                                 onTap: () {
// //                                   filterLeadsByTag(tag.id ?? "");
// //                                 },
// //                                 child: Column(
// //                                   mainAxisAlignment: MainAxisAlignment.center,
// //                                   children: [
// //                                     CircleAvatar(
// //                                       radius: 20,
// //                                       backgroundColor: tagColors(tag),
// //                                       child: Icon(
// //                                         FontAwesomeIcons.tag,
// //                                         color: Colors.white,
// //                                         size: 16,
// //                                       ),
// //                                     ),
// //                                     const SizedBox(height: 4),
// //                                     SizedBox(
// //                                       width: 60,
// //                                       child: Text(
// //                                         tag.title ?? 'Tag',
// //                                         maxLines: 1,
// //                                         overflow: TextOverflow.ellipsis,
// //                                         textAlign: TextAlign.center,
// //                                         style: const TextStyle(
// //                                           fontSize: 10,
// //                                           fontFamily: AppFonts.medium,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             );
// //                           }).toList(),
// //                         ]
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //         Expanded(
// //           child: chatLoader
// //               ? const Center(
// //                   child: SizedBox(
// //                     height: 50,
// //                     width: 50,
// //                     child: CircularProgressIndicator(),
// //                   ),
// //                 )
// //               : Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Expanded(
// //                       child: Container(
// //                         decoration: BoxDecoration(
// //                           boxShadow: [
// //                             BoxShadow(
// //                               color: Colors.black.withOpacity(0.5),
// //                               blurRadius: 5,
// //                               spreadRadius: 3,
// //                               offset: const Offset(2, 4),
// //                             ),
// //                           ],
// //                           color: Colors.white,
// //                           borderRadius: const BorderRadius.only(
// //                             topLeft: Radius.circular(30),
// //                             topRight: Radius.circular(30),
// //                           ),
// //                         ),
// //                         child: Padding(
// //                           padding: const EdgeInsets.only(top: 12.0, bottom: 5),
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               SizedBox(
// //                                 height: 40,
// //                                 child: ListView.builder(
// //                                   scrollDirection: Axis.horizontal,
// //                                   itemCount: tags.length,
// //                                   itemBuilder: (context, index) {
// //                                     final isSelected = selectedTagId == index;
// //                                     return Padding(
// //                                       padding: const EdgeInsets.symmetric(
// //                                           horizontal: 8.0),
// //                                       child: InkWell(
// //                                         onTap: () {
// //                                           setState(() {
// //                                             selectedTagId = index;
// //                                             if (index == 1) {
// //                                               unreadChatFilter();
// //                                             } else {
// //                                               allRecentChats =
// //                                                   tempLeadModelList;
// //                                             }
// //                                           });
// //                                         },
// //                                         child: Container(
// //                                           padding: const EdgeInsets.symmetric(
// //                                               horizontal: 12.0, vertical: 4.0),
// //                                           decoration: BoxDecoration(
// //                                             border: Border.all(
// //                                               color: isSelected
// //                                                   ? Colors.black
// //                                                   : Colors.transparent,
// //                                               width: 1.5,
// //                                             ),
// //                                             borderRadius:
// //                                                 BorderRadius.circular(18),
// //                                           ),
// //                                           child: Center(
// //                                             child: Text(
// //                                               tags[index],
// //                                               style: const TextStyle(
// //                                                 fontWeight: FontWeight.bold,
// //                                               ),
// //                                             ),
// //                                           ),
// //                                         ),
// //                                       ),
// //                                     );
// //                                   },
// //                                 ),
// //                               ),
// //                               const Divider(),
// //                               const SizedBox(height: 10),
// //                               allRecentChats.isEmpty || noMatchedLeads
// //                                   ? const Center(
// //                                       child: Padding(
// //                                         padding: EdgeInsets.only(top: 38.0),
// //                                         child: Text(
// //                                           "No Chat Found..",
// //                                           style: TextStyle(
// //                                               fontSize: 16,
// //                                               fontWeight: FontWeight.w600),
// //                                         ),
// //                                       ),
// //                                     )
// //                                   : Expanded(
// //                                       child: ListView.builder(
// //                                         itemCount: allRecentChats.length,
// //                                         physics: const BouncingScrollPhysics(),
// //                                         itemBuilder: (context, index) {
// //                                           final lead = allRecentChats[index];
// //                                           String unreadCount = "0";

// //                                           for (var p in unreadList) {
// //                                             if (lead.full_number
// //                                                 .toString()
// //                                                 .contains(p.whatsappNumber)) {
// //                                               unreadCount = p.unreadMsgCount;
// //                                               break;
// //                                             }
// //                                           }

// //                                           return leadRecordList(
// //                                               lead, unreadCount);
// //                                         },
// //                                       ),
// //                                     ),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //         ),
// //       ],
// //     );
// //   }

// //   bool chatLoader = false;
// //   Future<void> getLeadList({bool showLoading = true}) async {
// //     if (mounted) {
// //       if (showLoading == true) {
// //         setState(() {
// //           chatLoader = true;
// //         });
// //       }
// //     }

// //     await Provider.of<LeadListViewModel>(navigatorKey.currentContext!,
// //             listen: false)
// //         .fetchRecentChat()
// //         .then((onValue) {
// //       allRecentChats = [];
// //       tempLeadModelList = [];
// //       pinnedLeads = [];

// //       try {
// //         for (var viewModel in leadlistvm.viewModels) {
// //           var recentMsgmodel = viewModel.model;
// //           if (recentMsgmodel?.records != null) {
// //             for (var record in recentMsgmodel!.records!) {
// //               allRecentChats.add(record);
// //               tempLeadModelList.add(record);
// //               if (record.pinned) {
// //                 pinnedLeads.add(record);
// //               }
// //             }
// //           }
// //         }
// //       } catch (e) {
// //         allRecentChats = [];
// //       }
// //     });

// //     if (mounted) {
// //       setState(() {
// //         chatLoader = false;
// //       });
// //     }
// //   }

// //   Future<void> getTagsList() async {
// //     setState(() {
// //       updateLoader = true;
// //     });
// //     await Provider.of<TagsListViewModel>(context, listen: false)
// //         .fetchAllTags()
// //         .then((onValue) {
// //       allTagsList = [];
// //       tempTagsList = [];
// //       var taglistvm = Provider.of<TagsListViewModel>(context, listen: false);

// //       for (var viewModel in taglistvm.viewModels) {
// //         var tagmodel = viewModel.model;
// //         if (tagmodel?.records != null) {
// //           for (var record in tagmodel!.records!) {
// //             allTagsList.add(record);
// //             tempTagsList.add(record);
// //           }
// //         }
// //       }
// //       setState(() {
// //         updateLoader = false;
// //       });
// //     });
// //     setState(() {
// //       updateLoader = false;
// //     });
// //   }

// //   bool showPin = false;
// //   String pinnedLeadId = "";
// //   bool isPinned = false;

// //   Widget leadRecordList(Records model, String unreadMsgCount) {
// //     Color statusColor = AppColor.navBarIconColor;

// //     String formatPhoneNumber(String? phoneNumber) {
// //       if (phoneNumber == null || phoneNumber.isEmpty) return '';

// //       if (shouldHideLeadNumber == true && phoneNumber.length > 5) {
// //         int totalLength = phoneNumber.length;
// //         String lastFiveDigits = phoneNumber.substring(totalLength - 5);
// //         String maskedPart = 'X' * (totalLength - 5);
// //         return '$maskedPart$lastFiveDigits';
// //       } else {
// //         return phoneNumber;
// //       }
// //     }

// //     return GestureDetector(
// //       onLongPress: () {
// //         setState(() {
// //           showPin = true;
// //           pinnedLeadId = model.lead_id ?? "";
// //           isPinned = model.pinned ?? false;
// //         });
// //       },
// //       child: Container(
// //         decoration: BoxDecoration(
// //           color: showPin && pinnedLeadId == model.lead_id
// //               ? AppColor.pageBgGrey
// //               : Colors.white,
// //           borderRadius: BorderRadius.circular(10),
// //           border: Border(
// //             left: BorderSide(
// //               color: statusColor,
// //               width: 5,
// //             ),
// //           ),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.1),
// //               blurRadius: 5,
// //               spreadRadius: 3,
// //               offset: const Offset(2, 4),
// //             ),
// //           ],
// //         ),
// //         margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
// //         child: Padding(
// //           padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
// //           child: InkWell(
// //             onTap: () {
// //               setState(() {
// //                 pinnedLeadId = "";
// //                 showPin = false;
// //                 isPinned = false;
// //               });
// //               if (model.full_number != null) {
// //                 _marksread(model.full_number ?? "");

// //                 Navigator.push(
// //                   context,
// //                   MaterialPageRoute(
// //                     builder: (context) => WhatsappChatScreen(
// //                       pinnedLeads: pinnedLeads,
// //                       leadName: model.contactname ?? "",
// //                       wpnumber: model.full_number,
// //                       id: model.id,
// //                       contryCode: model.countrycode,
// //                     ),
// //                   ),
// //                 ).then((_) {
// //                   _getUnreadCount();

// //                   setState(() {
// //                     unreadMsgCount = "0";
// //                     unreadMsgCount = "";
// //                   });
// //                 });
// //                 leads?.viewModels.clear();
// //                 Provider.of<LeadListViewModel>(context, listen: false)
// //                     .fetchRecentChat();
// //               } else {
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   const SnackBar(
// //                     content: Text('No Phone Number '),
// //                     duration: Duration(seconds: 3),
// //                     backgroundColor: AppColor.motivationCar1Color,
// //                   ),
// //                 );
// //               }
// //             },
// //             child: Row(
// //               children: [
// //                 Padding(
// //                   padding: const EdgeInsets.symmetric(vertical: 18.0),
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       CircleAvatar(
// //                         radius: 20,
// //                         backgroundColor: AppColor.navBarIconColor,
// //                         child: Text(
// //                           model.contactname?.isNotEmpty == true
// //                               ? model.contactname![0].toUpperCase()
// //                               : '?',
// //                           style: const TextStyle(
// //                             fontSize: 20,
// //                             color: Colors.white,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 Expanded(
// //                   child: Padding(
// //                     padding: const EdgeInsets.symmetric(
// //                         vertical: 10.0, horizontal: 5),
// //                     child: Row(
// //                       crossAxisAlignment: CrossAxisAlignment.end,
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         Expanded(
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               Text(
// //                                 "${model.contactname}",
// //                                 style: const TextStyle(
// //                                   fontSize: 14,
// //                                   fontFamily: AppFonts.semiBold,
// //                                   fontWeight: FontWeight.bold,
// //                                 ),
// //                               ),
// //                               const SizedBox(height: 3),
// //                               Text(
// //                                 formatPhoneNumber(model.full_number),
// //                                 style: const TextStyle(fontSize: 12),
// //                               ),
// //                               const SizedBox(height: 5),
// //                               Text(
// //                                 "${model.message}",
// //                                 maxLines: 1,
// //                                 overflow: TextOverflow.ellipsis,
// //                                 style: const TextStyle(
// //                                     fontSize: 12, color: Colors.black54),
// //                               ),
// //                               // Tags display
// //                               if (model.tags != null && model.tags!.isNotEmpty)
// //                                 Padding(
// //                                   padding: const EdgeInsets.only(top: 4.0),
// //                                   child: Wrap(
// //                                     spacing: 4,
// //                                     runSpacing: 2,
// //                                     children: model.tags!
// //                                         .map((tagId) {
// //                                           final tag = allTagsList.firstWhere(
// //                                             (t) => t.id == tagId,
// //                                             orElse: () => TagModel(),
// //                                           );
// //                                           if (tag.title == null)
// //                                             return Container();
// //                                           return Container(
// //                                             padding: const EdgeInsets.symmetric(
// //                                               horizontal: 6,
// //                                               vertical: 2,
// //                                             ),
// //                                             decoration: BoxDecoration(
// //                                               color: tagColors(tag)
// //                                                   .withOpacity(0.2),
// //                                               borderRadius:
// //                                                   BorderRadius.circular(4),
// //                                               border: Border.all(
// //                                                 color: tagColors(tag),
// //                                                 width: 1,
// //                                               ),
// //                                             ),
// //                                             child: Text(
// //                                               tag.title!,
// //                                               style: TextStyle(
// //                                                 fontSize: 10,
// //                                                 color: tagColors(tag),
// //                                                 fontWeight: FontWeight.w500,
// //                                               ),
// //                                             ),
// //                                           );
// //                                         })
// //                                         .whereType<Widget>()
// //                                         .toList(),
// //                                   ),
// //                                 ),
// //                             ],
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 Column(
// //                   mainAxisAlignment: MainAxisAlignment.end,
// //                   children: [
// //                     if (unreadMsgCount != "0" && unreadMsgCount.isNotEmpty)
// //                       badges.Badge(
// //                         badgeStyle: const badges.BadgeStyle(
// //                           badgeColor: Colors.green,
// //                         ),
// //                         badgeContent: Text(
// //                           unreadMsgCount,
// //                           style: const TextStyle(color: Colors.white),
// //                         ),
// //                       )
// //                     else
// //                       const SizedBox.shrink(),
// //                     Text(
// //                       formatDateTime(model.createddate.toString()),
// //                       style:
// //                           const TextStyle(fontSize: 10, color: Colors.black54),
// //                     ),
// //                     model.pinned ?? false
// //                         ? const Padding(
// //                             padding: EdgeInsets.only(top: 8.0),
// //                             child: Icon(
// //                               Icons.push_pin,
// //                               color: Colors.black87,
// //                               size: 18,
// //                             ),
// //                           )
// //                         : const SizedBox()
// //                   ],
// //                 )
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   bool noRecordFound = false;
// //   void filterLeads(String? filter) {
// //     leadModelList = tempLeadModelList;
// //     if (filter == null) return;
// //     setState(() {
// //       List<dynamic> matchleads = leadModelList
// //           .where(
// //               (lead) => lead.leadstatus?.toLowerCase() == filter.toLowerCase())
// //           .toList();

// //       allRecentChats = matchleads;
// //       noRecordFound = matchleads.isEmpty;
// //     });
// //   }

// //   Future<void> connectSocket() async {
// //     String tkn = await AppUtils.getToken() ?? "";
// //     final prefs = await SharedPreferences.getInstance();
// //     String? number = prefs.getString('phoneNumber');
// //     LeadController leadCtrl = Provider.of(context, listen: false);
// //     token = tkn;
// //     phNum = number ?? "";
// //     Map<String, dynamic> decodedToken = Map<String, dynamic>.from(
// //       JwtDecoder.decode(tkn),
// //     );

// //     userId = decodedToken;
// //     userId.addAll({
// //       "business_numbers": leadCtrl.allBusinessNumbers,
// //       "business_number": number
// //     });

// //     log("user id sending in socket setup::::   $userId");

// //     try {
// //       socket = IO.io(
// //         'https://admin.watconnect.com',
// //         IO.OptionBuilder()
// //             .setTransports(['websocket'])
// //             .setPath('/ibs/socket.io')
// //             .setExtraHeaders({'Authorization': 'Bearer $token'})
// //             .build(),
// //       );
// //       socket!.connect();
// //       socket!.onConnect((_) {
// //         print('Connected to WebSocket recent ');
// //         socket!.emit("setup", userId);
// //       });
// //       socket!.on("connected", (_) {});

// //       socket!.on("receivedwhatsappmessage", (data) {
// //         print(" New WhatsApp message: $data");
// //         getLeadList(showLoading: false);
// //         _getUnreadCount();
// //       });

// //       socket!.onDisconnect((_) {
// //         print(" WebSocket Disconnected");
// //       });

// //       socket!.onError((error) {
// //         print(" WebSocket Error: $error");
// //       });
// //     } catch (error) {
// //       print("Error connecting to WebSocket: $error");
// //     }
// //   }

// //   void _showTagsBottomSheet(BuildContext context) {
// //     bool isCreatingNewLabel = false;
// //     TextEditingController labelController = TextEditingController();

// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.white,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       builder: (context) {
// //         return StatefulBuilder(
// //           builder: (context, setState) {
// //             return Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //               height: MediaQuery.of(context).size.height * 0.7,
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       const Text(
// //                         'Label chat',
// //                         style: TextStyle(
// //                           fontSize: 18,
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                       IconButton(
// //                         onPressed: () => Navigator.pop(context),
// //                         icon: const Icon(Icons.close, size: 24),
// //                         padding: EdgeInsets.zero,
// //                         constraints: const BoxConstraints(),
// //                       ),
// //                     ],
// //                   ),
// //                   const Divider(height: 20),
// //                   isCreatingNewLabel
// //                       ? Row(
// //                           children: [
// //                             Expanded(
// //                               child: TextField(
// //                                 controller: labelController,
// //                                 autofocus: true,
// //                                 decoration: const InputDecoration(
// //                                   hintText: 'Enter label name',
// //                                   border: OutlineInputBorder(),
// //                                   contentPadding: EdgeInsets.symmetric(
// //                                     horizontal: 12,
// //                                     vertical: 10,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                             const SizedBox(width: 8),
// //                             IconButton(
// //                               onPressed: () {
// //                                 if (labelController.text.isNotEmpty) {
// //                                   print('New label: ${labelController.text}');
// //                                   setState(() {
// //                                     isCreatingNewLabel = false;
// //                                     labelController.clear();
// //                                   });
// //                                 }
// //                               },
// //                               icon:
// //                                   const Icon(Icons.check, color: Colors.green),
// //                             ),
// //                           ],
// //                         )
// //                       : ListTile(
// //                           contentPadding:
// //                               const EdgeInsets.symmetric(horizontal: 0),
// //                           leading: const Icon(Icons.add, size: 24),
// //                           title: const Text(
// //                             'New label',
// //                             style: TextStyle(fontSize: 16),
// //                           ),
// //                           onTap: () {
// //                             setState(() {
// //                               isCreatingNewLabel = true;
// //                             });
// //                           },
// //                         ),
// //                   const SizedBox(height: 10),
// //                   Expanded(
// //                     child: updateLoader
// //                         ? const Center(child: CircularProgressIndicator())
// //                         : ListView.builder(
// //                             padding: EdgeInsets.zero,
// //                             itemCount: allTagsList.length,
// //                             itemBuilder: (context, index) {
// //                               final tag = allTagsList[index];
// //                               return ListTile(
// //                                 contentPadding: const EdgeInsets.symmetric(
// //                                   horizontal: 0,
// //                                   vertical: 4,
// //                                 ),
// //                                 leading: Container(
// //                                   width: 40,
// //                                   height: 40,
// //                                   decoration: BoxDecoration(
// //                                     color: tagColors(tag).withOpacity(0.15),
// //                                     shape: BoxShape.circle,
// //                                   ),
// //                                   child: Icon(
// //                                     FontAwesomeIcons.tag,
// //                                     size: 20,
// //                                     color: tagColors(tag),
// //                                   ),
// //                                 ),
// //                                 title: Text(
// //                                   tag.title ?? 'Untitled Tag',
// //                                   style: const TextStyle(fontSize: 16),
// //                                 ),
// //                                 trailing: Checkbox(
// //                                   value: false,
// //                                   onChanged: (value) {},
// //                                   shape: RoundedRectangleBorder(
// //                                     borderRadius: BorderRadius.circular(4),
// //                                   ),
// //                                 ),
// //                               );
// //                             },
// //                           ),
// //                   ),
// //                   const SizedBox(height: 10),
// //                   SizedBox(
// //                     width: double.infinity,
// //                     child: ElevatedButton(
// //                       onPressed: () {
// //                         Navigator.pop(context);
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Colors.grey.shade300,
// //                         foregroundColor: Colors.grey.shade600,
// //                         elevation: 0,
// //                         padding: const EdgeInsets.symmetric(vertical: 14),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                       ),
// //                       child: const Text(
// //                         'Save',
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }

// //   unreadChatFilter() {
// //     List prioritizedLeads = [];
// //     List otherLeads = [];

// //     for (var lead in allRecentChats) {
// //       bool hasUnread = unreadList.any(
// //         (unread) =>
// //             unread.whatsappNumber.toString().contains(lead.whatsapp_number),
// //       );

// //       if (hasUnread) {
// //         prioritizedLeads.add(lead);
// //       } else {
// //         otherLeads.add(lead);
// //       }
// //     }

// //     allRecentChats = [...prioritizedLeads];
// //   }

// //   String formatDateTime(String isoString) {
// //     final inputDate = DateTime.parse(isoString).toLocal();
// //     final now = DateTime.now();

// //     final isToday = inputDate.year == now.year &&
// //         inputDate.month == now.month &&
// //         inputDate.day == now.day;

// //     if (isToday) {
// //       return DateFormat.jm().format(inputDate);
// //     } else {
// //       return DateFormat('MMM dd, yy').format(inputDate);
// //     }
// //   }

// //   Future<void> shouldHide() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     shouldHideLeadNumber = prefs.getBool(SharedPrefsConstants.shouldHideNumber);
// //     setState(() {});
// //   }

// //   Color tagColors(TagModel tag) {
// //     if (tag.color != null && tag.color!.isNotEmpty) {
// //       try {
// //         return Color(int.parse('0xFF${tag.color!.replaceAll('#', '')}'));
// //       } catch (e) {
// //         return tagColors[tag.title?.hashCode ?? 0 % tagColors.length];
// //       }
// //     }
// //     return tagColors[tag.title?.hashCode ?? 0 % tagColors.length];
// //   }
// // }

// // class FilteredLeadsScreen extends StatelessWidget {
// //   final List<LeadModel> filteredLeads;

// //   const FilteredLeadsScreen({super.key, required this.filteredLeads});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Filtered Leads (${filteredLeads.length})'),
// //       ),
// //       body: filteredLeads.isEmpty
// //           ? const Center(child: Text('No leads found'))
// //           : ListView.builder(
// //               itemCount: filteredLeads.length,
// //               itemBuilder: (context, index) {
// //                 final lead = filteredLeads[index];
// //                 return ListTile(
// //                   leading: CircleAvatar(
// //                     child: Text(
// //                       lead.contactname?.isNotEmpty == true
// //                           ? lead.contactname![0].toUpperCase()
// //                           : '?',
// //                     ),
// //                   ),
// //                   title: Text(lead.contactname ?? 'Unknown'),
// //                   subtitle: Text(lead.full_number ?? 'No number'),
// //                 );
// //               },
// //             ),
// //     );
// //   }
// // }

// // ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously, prefer_typing_uninitialized_variables, unnecessary_brace_in_string_interps

// // import 'dart:convert';
// // import 'dart:developer';

// // import 'package:flutter/material.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:intl/intl.dart';
// // import 'package:jwt_decoder/jwt_decoder.dart';
// // import 'package:provider/provider.dart';
// // import 'package:shared_preferences/shared_preferences.dart'
// //     show SharedPreferences;
// // // ignore: library_prefixes
// // import 'package:socket_io_client/socket_io_client.dart' as IO;
// // import 'package:whatsapp/main.dart';
// // import 'package:whatsapp/models/recent_chat_model.dart';
// // import 'package:whatsapp/models/tags_list_model.dart';
// // import 'package:whatsapp/models/unread_msg_model/unread_msg_model.dart';
// // import 'package:whatsapp/utils/app_constants.dart';
// // import 'package:whatsapp/utils/app_fonts.dart';
// // import 'package:whatsapp/view_models/lead_controller.dart';
// // import 'package:whatsapp/view_models/unread_count_vm.dart';
// // import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
// // import '../../models/lead_model.dart';
// // // import '../../models/tag_model.dart'; // Tag model import करें
// // import '../../utils/app_color.dart';
// // import '../../utils/app_utils.dart';
// // import '../../view_models/lead_list_vm.dart';
// // import '../../view_models/tags_list_vm.dart'; // TagsListViewModel import करें
// // import 'package:badges/badges.dart' as badges;

// // class RecentChatView extends StatefulWidget {
// //   const RecentChatView({super.key});
// //   @override
// //   State<RecentChatView> createState() => _RecentChatViewState();
// // }

// // class _RecentChatViewState extends State<RecentChatView> {
// //   final List<Color> tagColors = [
// //     Colors.red,
// //     Colors.blue,
// //     Colors.green,
// //     Colors.orange,
// //     Colors.purple,
// //     Colors.yellow,
// //     Colors.cyan,
// //     Colors.pink,
// //     Colors.teal,
// //     Colors.brown,
// //     Colors.indigo,
// //     Colors.lime,
// //     Colors.amber,
// //     Colors.deepOrange,
// //     Colors.deepPurple,
// //     Colors.lightBlue,
// //     Colors.lightGreen,
// //     Colors.grey,
// //     Colors.blueGrey,
// //     Colors.black,
// //     Colors.pinkAccent,
// //     Colors.redAccent,
// //     Colors.orangeAccent
// //   ];
// //   String finalResult = "";
// //   IO.Socket? socket;
// //   String token = "your_token_here";
// //   Map<String, dynamic> userId = {};
// //   String leadId = "lead_456";
// //   String phNum = "+919876543210";
// //   List<LeadModel> leadss = [];
// //   TextEditingController textController = TextEditingController();
// //   LeadListViewModel? leadlistvm;
// //   TagsListViewModel? taglistvm;
// //   List leadModelList = [];
// //   List tempLeadModelList = [];
// //   UnreadCountVm? unreadCountVm;
// //   LeadListViewModel? leads;
// //   String? selectlead;
// //   String? selectuser;
// //   bool isRefresh = false;
// //   int countunread = 0;
// //   List allRecentChats = [];
// //   List pinnedLeads = [];
// //   List unreadList = [];
// //   String? number;
// //   bool? shouldHideLeadNumber;

// //   // Tags related variables
// //   List<TagsModel> allTagsList = [];
// //   List<TagsModel> tempTagsList = [];
// //   bool updateLoader = false;

// //   @override
// //   void initState() {
// //     shouldHide();
// //     _getUnreadCount();
// //     getLeadList();
// //     getTagsList(); // Tags fetch करें
// //     super.initState();
// //   }

// //   @override
// //   void dispose() {
// //     super.dispose();
// //   }

// //   bool noMatchedLeads = false;
// //   List matched = [];
// //   List others = [];

// //   Future<void> _getUnreadCount() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     number = prefs.getString('phoneNumber');

// //     if (!mounted) return;

// //     await Provider.of<UnreadCountVm>(context, listen: false)
// //         .fetchunreadcount(number: number ?? "");

// //     var unreadMsgModel;
// //     for (var unreadModel in unreadCountVm?.viewModels ?? []) {
// //       unreadMsgModel = unreadModel.model as UnreadMsgModel;
// //     }

// //     unreadList = unreadMsgModel?.records ?? [];

// //     if (mounted) {
// //       setState(() {});
// //     }
// //   }

// //   int selectedTagId = 0;
// //   List<String> tags = ["All", "Unread"];

// //   void _filterLeads(String searchLead) {
// //     searchLead = searchLead.trim().toLowerCase();

// //     if (searchLead.isEmpty) {
// //       List prioritizedLeads = [];
// //       List otherLeads = [];
// //       noMatchedLeads = false;

// //       for (var lead in allRecentChats) {
// //         bool hasUnread = unreadList.any(
// //           (unread) =>
// //               unread.whatsappNumber.toString().contains(lead.whatsapp_number),
// //         );

// //         if (hasUnread) {
// //           prioritizedLeads.add(lead);
// //         }
// //       }

// //       allRecentChats = [...prioritizedLeads, ...otherLeads];
// //       allRecentChats = tempLeadModelList;

// //       if (mounted) {
// //         setState(() {});
// //       }
// //     } else {
// //       matched = [];
// //       others = [];

// //       for (var lead in tempLeadModelList) {
// //         var firstName = lead.contactname?.toLowerCase() ?? '';
// //         var lastName = lead.full_number?.toLowerCase() ?? '';

// //         if (firstName.contains(searchLead) || lastName.contains(searchLead)) {
// //           matched.add(lead);
// //         }
// //       }

// //       if (mounted) {
// //         setState(() {
// //           allRecentChats = [
// //             ...matched,
// //           ];
// //           noMatchedLeads = matched.isEmpty;
// //         });
// //       }
// //     }
// //   }

// //   // void filterLeadsByTag(String tagId) {
// //   //   List<Records> filtered = allRecentChats
// //   //       .where((lead) => lead.tags != null && lead.tags!.contains(tagId))
// //   //       .toList();

// //   //   Navigator.push(
// //   //     context,
// //   //     MaterialPageRoute(
// //   //       builder: (_) => FilteredLeadsScreen(filteredLeads: filtered),
// //   //     ),
// //   //   );
// //   // }

// //   @override
// //   Widget build(BuildContext context) {
// //     unreadCountVm = Provider.of<UnreadCountVm>(context);
// //     leadlistvm = Provider.of<LeadListViewModel>(context);
// //     taglistvm = Provider.of<TagsListViewModel>(context);

// //     return Scaffold(
// //       backgroundColor: AppColor.pageBgGrey,
// //       appBar: AppBar(
// //         automaticallyImplyLeading: false,
// //         title: const Text(
// //           'Chats',
// //           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
// //         ),
// //         centerTitle: true,
// //         elevation: 5,
// //         actions: [
// //           showPin
// //               ? Row(
// //                   children: [
// //                     // Tag Icon
// //                     Padding(
// //                       padding: const EdgeInsets.only(right: 12.0),
// //                       child: InkWell(
// //                         onTap: () {
// //                           _showTagsBottomSheet(context);
// //                         },
// //                         child: const Icon(
// //                           FontAwesomeIcons.tags,
// //                           color: Colors.white,
// //                           size: 24,
// //                         ),
// //                       ),
// //                     ),

// //                     // Pin Icon
// //                     Padding(
// //                       padding: const EdgeInsets.only(right: 16.0),
// //                       child: InkWell(
// //                         onTap: () {
// //                           if (isPinned) {
// //                             Provider.of<LeadListViewModel>(context,
// //                                     listen: false)
// //                                 .unpinChat(pinnedLeadId)
// //                                 .then((onValue) {
// //                               getLeadList(showLoading: false);
// //                             });
// //                           } else {
// //                             Provider.of<LeadListViewModel>(context,
// //                                     listen: false)
// //                                 .pinChat(pinnedLeadId)
// //                                 .then((onValue) {
// //                               getLeadList(showLoading: false);
// //                             });
// //                           }
// //                           setState(() {
// //                             showPin = false;
// //                             pinnedLeadId = "";
// //                           });
// //                         },
// //                         child: isPinned == false
// //                             ? const Icon(
// //                                 Icons.push_pin_outlined,
// //                                 color: Colors.white,
// //                               )
// //                             : Image.asset(
// //                                 "assets/images/unpin_icon.png",
// //                                 color: Colors.white,
// //                                 height: 20,
// //                               ),
// //                       ),
// //                     ),
// //                   ],
// //                 )
// //               : const SizedBox(),
// //         ],
// //       ),
// //       body: GestureDetector(
// //         onTap: () {
// //           setState(() {
// //             pinnedLeadId = "";
// //             showPin = false;
// //             isPinned = false;
// //           });
// //           FocusScope.of(context).unfocus();
// //         },
// //         child: RefreshIndicator(
// //           onRefresh: _pullRefresh,
// //           child: (_pageBody()),
// //         ),
// //       ),
// //     );
// //   }

// //   Future<String?> _marksread(String whatsappNumber) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     String? number = prefs.getString('phoneNumber');

// //     Map<String, String>? bodydata = {"whatsapp_number": whatsappNumber};

// //     await Provider.of<UnreadCountVm>(context, listen: false).marksreadcountmsg(
// //       leadnumber: whatsappNumber,
// //       number: number,
// //       bodydata: bodydata,
// //     );
// //     return null;
// //   }

// //   Future<void> _pullRefresh() async {
// //     leads?.viewModels.clear();

// //     await Provider.of<LeadListViewModel>(context, listen: false)
// //         .fetchRecentChat();
// //     await Provider.of<UnreadCountVm>(context, listen: false)
// //         .fetchunreadcount(number: number);
// //     getLeadList();
// //     getTagsList(); // Refresh tags
// //     isRefresh = true;
// //     return Future<void>.delayed(const Duration(seconds: 1));
// //   }

// //   Widget _pageBody() {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
// //           child: TextField(
// //             controller: textController,
// //             onChanged: _filterLeads,
// //             cursorColor: AppColor.navBarIconColor,
// //             decoration: InputDecoration(
// //               isDense: true,
// //               hintText: 'Search...',
// //               hintStyle: TextStyle(
// //                 color: AppColor.textoriconColor.withOpacity(0.6),
// //               ),
// //               filled: true,
// //               fillColor: Colors.white,
// //               contentPadding: const EdgeInsets.all(10),
// //               disabledBorder: OutlineInputBorder(
// //                 borderSide: const BorderSide(color: AppColor.backgroundGrey),
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               border: OutlineInputBorder(
// //                 borderSide: const BorderSide(color: AppColor.backgroundGrey),
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               focusedBorder: OutlineInputBorder(
// //                 borderRadius: BorderRadius.circular(10),
// //                 borderSide: const BorderSide(
// //                   color: AppColor.navBarIconColor,
// //                   width: 1.5,
// //                 ),
// //               ),
// //               prefixIcon: Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 10),
// //                 child: IconButton(
// //                   icon: const Icon(Icons.search, color: Colors.black, size: 20),
// //                   onPressed: () {},
// //                 ),
// //               ),
// //               prefixIconConstraints: const BoxConstraints(minWidth: 40),
// //             ),
// //           ),
// //         ),
// //         pinnedLeads.isEmpty
// //             ? const SizedBox()
// //             : const Padding(
// //                 padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
// //                 child: Text(
// //                   "Pinned Leads",
// //                   style: TextStyle(fontFamily: AppFonts.medium),
// //                 ),
// //               ),
// //         pinnedLeads.isEmpty
// //             ? const SizedBox()
// //             : Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 12.0),
// //                 child: SizedBox(
// //                   height: 70,
// //                   child: SingleChildScrollView(
// //                     scrollDirection: Axis.horizontal,
// //                     child: Row(
// //                       children: [
// //                         // Pinned leads avatars
// //                         ...pinnedLeads.map((model) {
// //                           return Padding(
// //                             padding: const EdgeInsets.only(right: 10.0),
// //                             child: InkWell(
// //                               onTap: () async {
// //                                 setState(() {
// //                                   pinnedLeadId = "";
// //                                   showPin = false;
// //                                   isPinned = false;
// //                                 });

// //                                 if (model.full_number != null) {
// //                                   _marksread(model.full_number ?? "");

// //                                   Navigator.push(
// //                                     context,
// //                                     MaterialPageRoute(
// //                                       builder: (context) => WhatsappChatScreen(
// //                                         pinnedLeads: pinnedLeads,
// //                                         leadName: model.contactname ?? "",
// //                                         wpnumber: model.full_number,
// //                                         id: model.id,
// //                                         contryCode: model.countrycode,
// //                                       ),
// //                                     ),
// //                                   ).then((_) {
// //                                     _getUnreadCount();
// //                                     setState(() {});
// //                                   });

// //                                   leads?.viewModels.clear();
// //                                   Provider.of<LeadListViewModel>(context,
// //                                           listen: false)
// //                                       .fetchRecentChat();
// //                                 } else {
// //                                   ScaffoldMessenger.of(context).showSnackBar(
// //                                     const SnackBar(
// //                                       content: Text('No Phone Number'),
// //                                       duration: Duration(seconds: 3),
// //                                       backgroundColor:
// //                                           AppColor.motivationCar1Color,
// //                                     ),
// //                                   );
// //                                 }
// //                               },
// //                               child: Column(
// //                                 mainAxisAlignment: MainAxisAlignment.center,
// //                                 children: [
// //                                   CircleAvatar(
// //                                     radius: 20,
// //                                     backgroundColor: AppColor.navBarIconColor,
// //                                     child: Text(
// //                                       model.contactname?.isNotEmpty == true
// //                                           ? model.contactname![0].toUpperCase()
// //                                           : '?',
// //                                       style: const TextStyle(
// //                                         fontSize: 20,
// //                                         color: Colors.white,
// //                                         fontWeight: FontWeight.bold,
// //                                       ),
// //                                     ),
// //                                   ),
// //                                   const SizedBox(height: 4),
// //                                   SizedBox(
// //                                     width: 60,
// //                                     child: Text(
// //                                       model.contactname ?? '',
// //                                       maxLines: 1,
// //                                       overflow: TextOverflow.ellipsis,
// //                                       textAlign: TextAlign.center,
// //                                       style: const TextStyle(
// //                                           fontFamily: AppFonts.semiBold),
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           );
// //                         }).toList(),

// //                         // All tags as clickable icons
// //                         if (allTagsList.isNotEmpty) ...[
// //                           const SizedBox(width: 20),
// //                           ...allTagsList.map((tag) {
// //                             return Padding(
// //                               padding: const EdgeInsets.only(right: 12.0),
// //                               child: InkWell(
// //                                 // onTap: () {
// //                                 //   filterLeadsByTag(tag.id ?? "");
// //                                 // },
// //                                 child: Column(
// //                                   mainAxisAlignment: MainAxisAlignment.center,
// //                                   children: [
// //                                     CircleAvatar(
// //                                       radius: 20,
// //                                       // backgroundColor: tagColors(tag),
// //                                       child: const Icon(
// //                                         FontAwesomeIcons.tag,
// //                                         color: Colors.white,
// //                                         size: 16,
// //                                       ),
// //                                     ),
// //                                     const SizedBox(height: 4),
// //                                     SizedBox(
// //                                       width: 60,
// //                                       child: Text(
// //                                         tag.tag_name ?? 'Tag',
// //                                         maxLines: 1,
// //                                         overflow: TextOverflow.ellipsis,
// //                                         textAlign: TextAlign.center,
// //                                         style: const TextStyle(
// //                                           fontSize: 10,
// //                                           fontFamily: AppFonts.medium,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             );
// //                           }).toList(),
// //                         ]
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //         Expanded(
// //           child: chatLoader
// //               ? const Center(
// //                   child: SizedBox(
// //                     height: 50,
// //                     width: 50,
// //                     child: CircularProgressIndicator(),
// //                   ),
// //                 )
// //               : Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Expanded(
// //                       child: Container(
// //                         decoration: BoxDecoration(
// //                           boxShadow: [
// //                             BoxShadow(
// //                               color: Colors.black.withOpacity(0.5),
// //                               blurRadius: 5,
// //                               spreadRadius: 3,
// //                               offset: const Offset(2, 4),
// //                             ),
// //                           ],
// //                           color: Colors.white,
// //                           borderRadius: const BorderRadius.only(
// //                             topLeft: Radius.circular(30),
// //                             topRight: Radius.circular(30),
// //                           ),
// //                         ),
// //                         child: Padding(
// //                           padding: const EdgeInsets.only(top: 12.0, bottom: 5),
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               SizedBox(
// //                                 height: 40,
// //                                 child: ListView.builder(
// //                                   scrollDirection: Axis.horizontal,
// //                                   itemCount: tags.length,
// //                                   itemBuilder: (context, index) {
// //                                     final isSelected = selectedTagId == index;
// //                                     return Padding(
// //                                       padding: const EdgeInsets.symmetric(
// //                                           horizontal: 8.0),
// //                                       child: InkWell(
// //                                         onTap: () {
// //                                           setState(() {
// //                                             selectedTagId = index;
// //                                             if (index == 1) {
// //                                               unreadChatFilter();
// //                                             } else {
// //                                               allRecentChats =
// //                                                   tempLeadModelList;
// //                                             }
// //                                           });
// //                                         },
// //                                         child: Container(
// //                                           padding: const EdgeInsets.symmetric(
// //                                               horizontal: 12.0, vertical: 4.0),
// //                                           decoration: BoxDecoration(
// //                                             border: Border.all(
// //                                               color: isSelected
// //                                                   ? Colors.black
// //                                                   : Colors.transparent,
// //                                               width: 1.5,
// //                                             ),
// //                                             borderRadius:
// //                                                 BorderRadius.circular(18),
// //                                           ),
// //                                           child: Center(
// //                                             child: Text(
// //                                               tags[index],
// //                                               style: const TextStyle(
// //                                                 fontWeight: FontWeight.bold,
// //                                               ),
// //                                             ),
// //                                           ),
// //                                         ),
// //                                       ),
// //                                     );
// //                                   },
// //                                 ),
// //                               ),
// //                               const Divider(),
// //                               const SizedBox(height: 10),
// //                               allRecentChats.isEmpty || noMatchedLeads
// //                                   ? const Center(
// //                                       child: Padding(
// //                                         padding: EdgeInsets.only(top: 38.0),
// //                                         child: Text(
// //                                           "No Chat Found..",
// //                                           style: TextStyle(
// //                                               fontSize: 16,
// //                                               fontWeight: FontWeight.w600),
// //                                         ),
// //                                       ),
// //                                     )
// //                                   : Expanded(
// //                                       child: ListView.builder(
// //                                         itemCount: allRecentChats.length,
// //                                         physics: const BouncingScrollPhysics(),
// //                                         itemBuilder: (context, index) {
// //                                           final lead = allRecentChats[index];
// //                                           String unreadCount = "0";

// //                                           for (var p in unreadList) {
// //                                             if (lead.full_number
// //                                                 .toString()
// //                                                 .contains(p.whatsappNumber)) {
// //                                               unreadCount = p.unreadMsgCount;
// //                                               break;
// //                                             }
// //                                           }

// //                                           return leadRecordList(
// //                                               lead, unreadCount);
// //                                         },
// //                                       ),
// //                                     ),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //         ),
// //       ],
// //     );
// //   }

// //   bool chatLoader = false;
// //   Future<void> getLeadList({bool showLoading = true}) async {
// //     if (mounted) {
// //       if (showLoading == true) {
// //         setState(() {
// //           chatLoader = true;
// //         });
// //       }
// //     }

// //     await Provider.of<LeadListViewModel>(navigatorKey.currentContext!,
// //             listen: false)
// //         .fetchRecentChat()
// //         .then((onValue) {
// //       allRecentChats = [];
// //       tempLeadModelList = [];
// //       pinnedLeads = [];

// //       try {
// //         for (var viewModel in leadlistvm!.viewModels) {
// //           var recentMsgmodel = viewModel.model;
// //           if (recentMsgmodel?.records != null) {
// //             for (var record in recentMsgmodel!.records!) {
// //               allRecentChats.add(record);
// //               tempLeadModelList.add(record);
// //               if (record.pinned) {
// //                 pinnedLeads.add(record);
// //               }
// //             }
// //           }
// //         }
// //       } catch (e) {
// //         allRecentChats = [];
// //       }
// //     });

// //     if (mounted) {
// //       setState(() {
// //         chatLoader = false;
// //       });
// //     }
// //   }

// //   Future<void> getTagsList() async {
// //     setState(() {
// //       updateLoader = true;
// //     });
// //     await Provider.of<TagsListViewModel>(context, listen: false)
// //         .fetchAllTags()
// //         .then((onValue) {
// //       allTagsList = [];
// //       tempTagsList = [];

// //       for (var viewModel in taglistvm!.viewModels) {
// //         var tagmodel = viewModel.model;
// //         if (tagmodel?.records != null) {
// //           for (var record in tagmodel!.records!) {
// //             allTagsList.add(record);
// //             tempTagsList.add(record);
// //           }
// //         }
// //       }
// //       setState(() {
// //         updateLoader = false;
// //       });
// //     });
// //     setState(() {
// //       updateLoader = false;
// //     });
// //   }

// //   bool showPin = false;
// //   String pinnedLeadId = "";
// //   bool isPinned = false;

// //   Widget leadRecordList(Records model, String unreadMsgCount) {
// // =    Color statusColor = AppColor.navBarIconColor;

// //     String formatPhoneNumber(String? phoneNumber) {
// //       if (phoneNumber == null || phoneNumber.isEmpty) return '';

// //       if (shouldHideLeadNumber == true && phoneNumber.length > 5) {
// //         int totalLength = phoneNumber.length;
// //         String lastFiveDigits = phoneNumber.substring(totalLength - 5);
// //         String maskedPart = 'X' * (totalLength - 5);
// //         return '$maskedPart$lastFiveDigits';
// //       } else {
// //         return phoneNumber;
// //       }
// //     }

// //     return GestureDetector(
// //       onLongPress: () {
// //         setState(() {
// //           showPin = true;
// //           pinnedLeadId = model.lead_id ?? "";
// //           isPinned = model.pinned ?? false;
// //         });
// //       },
// //       child: Container(
// //         decoration: BoxDecoration(
// //           color: showPin && pinnedLeadId == model.lead_id
// //               ? AppColor.pageBgGrey
// //               : Colors.white,
// //           borderRadius: BorderRadius.circular(10),
// //           border: Border(
// //             left: BorderSide(
// //               color: statusColor,
// //               width: 5,
// //             ),
// //           ),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.1),
// //               blurRadius: 5,
// //               spreadRadius: 3,
// //               offset: const Offset(2, 4),
// //             ),
// //           ],
// //         ),
// //         margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
// //         child: Padding(
// //           padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
// //           child: InkWell(
// //             onTap: () {
// //               setState(() {
// //                 pinnedLeadId = "";
// //                 showPin = false;
// //                 isPinned = false;
// //               });
// //               if (model.full_number != null) {
// //                 _marksread(model.full_number ?? "");

// //                 Navigator.push(
// //                   context,
// //                   MaterialPageRoute(
// //                     builder: (context) => WhatsappChatScreen(
// //                       pinnedLeads: pinnedLeads,
// //                       leadName: model.contactname ?? "",
// //                       wpnumber: model.full_number,
// //                       id: model.id,
// //                       contryCode: model.countrycode,
// //                     ),
// //                   ),
// //                 ).then((_) {
// //                   _getUnreadCount();

// //                   setState(() {
// //                     unreadMsgCount = "0";
// //                     unreadMsgCount = "";
// //                   });
// //                 });
// //                 leads?.viewModels.clear();
// //                 Provider.of<LeadListViewModel>(context, listen: false)
// //                     .fetchRecentChat();
// //               } else {
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   const SnackBar(
// //                     content: Text('No Phone Number '),
// //                     duration: Duration(seconds: 3),
// //                     backgroundColor: AppColor.motivationCar1Color,
// //                   ),
// //                 );
// //               }
// //             },
// //             child: Row(
// //               children: [
// //                 Padding(
// //                   padding: const EdgeInsets.symmetric(vertical: 18.0),
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       CircleAvatar(
// //                         radius: 20,
// //                         backgroundColor: AppColor.navBarIconColor,
// //                         child: Text(
// //                           model.contactname?.isNotEmpty == true
// //                               ? model.contactname![0].toUpperCase()
// //                               : '?',
// //                           style: const TextStyle(
// //                             fontSize: 20,
// //                             color: Colors.white,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 Expanded(
// //                   child: Padding(
// //                     padding: const EdgeInsets.symmetric(
// //                         vertical: 10.0, horizontal: 5),
// //                     child: Row(
// //                       crossAxisAlignment: CrossAxisAlignment.end,
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         Expanded(
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               Text(
// //                                 "${model.contactname}",
// //                                 style: const TextStyle(
// //                                   fontSize: 14,
// //                                   fontFamily: AppFonts.semiBold,
// //                                   fontWeight: FontWeight.bold,
// //                                 ),
// //                               ),
// //                               const SizedBox(height: 3),
// //                               Text(
// //                                 formatPhoneNumber(model.full_number),
// //                                 style: const TextStyle(fontSize: 12),
// //                               ),
// //                               const SizedBox(height: 5),
// //                               Text(
// //                                 "${model.message}",
// //                                 maxLines: 1,
// //                                 overflow: TextOverflow.ellipsis,
// //                                 style: const TextStyle(
// //                                     fontSize: 12, color: Colors.black54),
// //                               ),
// //                               // Tags display
// //                               if (model.tagname != null && model.tagname!.isNotEmpty)
// //                                 Padding(
// //                                   padding: const EdgeInsets.only(top: 4.0),
// //                                   child: Wrap(
// //                                     spacing: 4,
// //                                     runSpacing: 2,
// //                                     children: model.tagname!
// //                                         .map((tagId) {
// //                                           final tag = allTagsList.firstWhere(
// //                                             (t) => t.id == tagId,
// //                                             orElse: () => TagsModel(),
// //                                           );
// //                                           if (tag.title == null)
// //                                             return Container();
// //                                           return Container(
// //                                             padding: const EdgeInsets.symmetric(
// //                                               horizontal: 6,
// //                                               vertical: 2,
// //                                             ),
// //                                             decoration: BoxDecoration(
// //                                               // color: tagColors(tag)
// //                                                   .withOpacity(0.2),
// //                                               borderRadius:
// //                                                   BorderRadius.circular(4),
// //                                               border: Border.all(
// //                                                 // color: tagColors(tag),
// //                                                 width: 1,
// //                                               ),
// //                                             ),
// //                                             child: Text(
// //                                               // tag.title!,
// //                                               style: TextStyle(
// //                                                 fontSize: 10,
// //                                                 // color: tagColors(tag),
// //                                                 fontWeight: FontWeight.w500,
// //                                               ),
// //                                             ),
// //                                           );
// //                                         })
// //                                         .whereType<Widget>()
// //                                         .toList(),
// //                                   ),
// //                                 ),
// //                             ],
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 Column(
// //                   mainAxisAlignment: MainAxisAlignment.end,
// //                   children: [
// //                     if (unreadMsgCount != "0" && unreadMsgCount.isNotEmpty)
// //                       badges.Badge(
// //                         badgeStyle: const badges.BadgeStyle(
// //                           badgeColor: Colors.green,
// //                         ),
// //                         badgeContent: Text(
// //                           unreadMsgCount,
// //                           style: const TextStyle(color: Colors.white),
// //                         ),
// //                       )
// //                     else
// //                       const SizedBox.shrink(),
// //                     Text(
// //                       formatDateTime(model.createddate.toString()),
// //                       style:
// //                           const TextStyle(fontSize: 10, color: Colors.black54),
// //                     ),
// //                     model.pinned ?? false
// //                         ? const Padding(
// //                             padding: EdgeInsets.only(top: 8.0),
// //                             child: Icon(
// //                               Icons.push_pin,
// //                               color: Colors.black87,
// //                               size: 18,
// //                             ),
// //                           )
// //                         : const SizedBox()
// //                   ],
// //                 )
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   bool noRecordFound = false;
// //   void filterLeads(String? filter) {
// //     leadModelList = tempLeadModelList;
// //     if (filter == null) return;
// //     setState(() {
// //       List<dynamic> matchleads = leadModelList
// //           .where(
// //               (lead) => lead.leadstatus?.toLowerCase() == filter.toLowerCase())
// //           .toList();

// //       allRecentChats = matchleads;
// //       noRecordFound = matchleads.isEmpty;
// //     });
// //   }

// //   Future<void> connectSocket() async {
// //     String tkn = await AppUtils.getToken() ?? "";
// //     final prefs = await SharedPreferences.getInstance();
// //     String? number = prefs.getString('phoneNumber');
// //     LeadController leadCtrl = Provider.of(context, listen: false);
// //     token = tkn;
// //     phNum = number ?? "";
// //     Map<String, dynamic> decodedToken = Map<String, dynamic>.from(
// //       JwtDecoder.decode(tkn),
// //     );

// //     userId = decodedToken;
// //     userId.addAll({
// //       "business_numbers": leadCtrl.allBusinessNumbers,
// //       "business_number": number
// //     });

// //     log("user id sending in socket setup::::   $userId");

// //     try {
// //       socket = IO.io(
// //         'https://admin.watconnect.com',
// //         IO.OptionBuilder()
// //             .setTransports(['websocket'])
// //             .setPath('/ibs/socket.io')
// //             .setExtraHeaders({'Authorization': 'Bearer $token'})
// //             .build(),
// //       );
// //       socket!.connect();
// //       socket!.onConnect((_) {
// //         print('Connected to WebSocket recent ');
// //         socket!.emit("setup", userId);
// //       });
// //       socket!.on("connected", (_) {});

// //       socket!.on("receivedwhatsappmessage", (data) {
// //         print(" New WhatsApp message: $data");
// //         getLeadList(showLoading: false);
// //         _getUnreadCount();
// //       });

// //       socket!.onDisconnect((_) {
// //         print(" WebSocket Disconnected");
// //       });

// //       socket!.onError((error) {
// //         print(" WebSocket Error: $error");
// //       });
// //     } catch (error) {
// //       print("Error connecting to WebSocket: $error");
// //     }
// //   }

// //   void _showTagsBottomSheet(BuildContext context) {
// //     bool isCreatingNewLabel = false;
// //     TextEditingController labelController = TextEditingController();

// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.white,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       builder: (context) {
// //         return StatefulBuilder(
// //           builder: (context, setState) {
// //             return Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //               height: MediaQuery.of(context).size.height * 0.7,
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       const Text(
// //                         'Label chat',
// //                         style: TextStyle(
// //                           fontSize: 18,
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                       IconButton(
// //                         onPressed: () => Navigator.pop(context),
// //                         icon: const Icon(Icons.close, size: 24),
// //                         padding: EdgeInsets.zero,
// //                         constraints: const BoxConstraints(),
// //                       ),
// //                     ],
// //                   ),
// //                   const Divider(height: 20),
// //                   isCreatingNewLabel
// //                       ? Row(
// //                           children: [
// //                             Expanded(
// //                               child: TextField(
// //                                 controller: labelController,
// //                                 autofocus: true,
// //                                 decoration: const InputDecoration(
// //                                   hintText: 'Enter label name',
// //                                   border: OutlineInputBorder(),
// //                                   contentPadding: EdgeInsets.symmetric(
// //                                     horizontal: 12,
// //                                     vertical: 10,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                             const SizedBox(width: 8),
// //                             IconButton(
// //                               onPressed: () {
// //                                 if (labelController.text.isNotEmpty) {
// //                                   print('New label: ${labelController.text}');
// //                                   setState(() {
// //                                     isCreatingNewLabel = false;
// //                                     labelController.clear();
// //                                   });
// //                                 }
// //                               },
// //                               icon:
// //                                   const Icon(Icons.check, color: Colors.green),
// //                             ),
// //                           ],
// //                         )
// //                       : ListTile(
// //                           contentPadding:
// //                               const EdgeInsets.symmetric(horizontal: 0),
// //                           leading: const Icon(Icons.add, size: 24),
// //                           title: const Text(
// //                             'New label',
// //                             style: TextStyle(fontSize: 16),
// //                           ),
// //                           onTap: () {
// //                             setState(() {
// //                               isCreatingNewLabel = true;
// //                             });
// //                           },
// //                         ),
// //                   const SizedBox(height: 10),
// //                   Expanded(
// //                     child: updateLoader
// //                         ? const Center(child: CircularProgressIndicator())
// //                         : ListView.builder(
// //                             padding: EdgeInsets.zero,
// //                             itemCount: allTagsList.length,
// //                             itemBuilder: (context, index) {
// //                               final tag = allTagsList[index];
// //                               return ListTile(
// //                                 contentPadding: const EdgeInsets.symmetric(
// //                                   horizontal: 0,
// //                                   vertical: 4,
// //                                 ),
// //                                 leading: Container(
// //                                   width: 40,
// //                                   height: 40,
// //                                   decoration: BoxDecoration(
// //                                     color: tagColors(tag).withOpacity(0.15),
// //                                     shape: BoxShape.circle,
// //                                   ),
// //                                   child: Icon(
// //                                     FontAwesomeIcons.tag,
// //                                     size: 20,
// //                                     color: tagColors(tag),
// //                                   ),
// //                                 ),
// //                                 title: Text(
// //                                   tag.title ?? 'Untitled Tag',
// //                                   style: const TextStyle(fontSize: 16),
// //                                 ),
// //                                 trailing: Checkbox(
// //                                   value: false,
// //                                   onChanged: (value) {},
// //                                   shape: RoundedRectangleBorder(
// //                                     borderRadius: BorderRadius.circular(4),
// //                                   ),
// //                                 ),
// //                               );
// //                             },
// //                           ),
// //                   ),
// //                   const SizedBox(height: 10),
// //                   SizedBox(
// //                     width: double.infinity,
// //                     child: ElevatedButton(
// //                       onPressed: () {
// //                         Navigator.pop(context);
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Colors.grey.shade300,
// //                         foregroundColor: Colors.grey.shade600,
// //                         elevation: 0,
// //                         padding: const EdgeInsets.symmetric(vertical: 14),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                       ),
// //                       child: const Text(
// //                         'Save',
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }

// //   unreadChatFilter() {
// //     List prioritizedLeads = [];
// //     List otherLeads = [];

// //     for (var lead in allRecentChats) {
// //       bool hasUnread = unreadList.any(
// //         (unread) =>
// //             unread.whatsappNumber.toString().contains(lead.whatsapp_number),
// //       );

// //       if (hasUnread) {
// //         prioritizedLeads.add(lead);
// //       } else {
// //         otherLeads.add(lead);
// //       }
// //     }

// //     allRecentChats = [...prioritizedLeads];
// //   }

// //   String formatDateTime(String isoString) {
// //     final inputDate = DateTime.parse(isoString).toLocal();
// //     final now = DateTime.now();

// //     final isToday = inputDate.year == now.year &&
// //         inputDate.month == now.month &&
// //         inputDate.day == now.day;

// //     if (isToday) {
// //       return DateFormat.jm().format(inputDate);
// //     } else {
// //       return DateFormat('MMM dd, yy').format(inputDate);
// //     }
// //   }

// //   Future<void> shouldHide() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     shouldHideLeadNumber = prefs.getBool(SharedPrefsConstants.shouldHideNumber);
// //     setState(() {});
// //   }

// //   // Color tagColors(TagsModel tag) {
// //   //   if (tag.color != null && tag.color!.isNotEmpty) {
// //   //     try {
// //   //       return Color(int.parse('0xFF${tag.color!.replaceAll('#', '')}'));
// //   //     } catch (e) {
// //   //       return tagColors[tag.title?.hashCode ?? 0 % tagColors.length];
// //   //     }
// //   //   }
// //   //   return tagColors[tag.title?.hashCode ?? 0 % tagColors.length];
// //   // }
// // }

// // class FilteredLeadsScreen extends StatelessWidget {
// //   final List<Records> filteredLeads;

// //   const FilteredLeadsScreen({super.key, required this.filteredLeads});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Filtered Leads (${filteredLeads.length})'),
// //       ),
// //       body: filteredLeads.isEmpty
// //           ? const Center(child: Text('No leads found'))
// //           : ListView.builder(
// //               itemCount: filteredLeads.length,
// //               itemBuilder: (context, index) {
// //                 final lead = filteredLeads[index];
// //                 return ListTile(
// //                   leading: CircleAvatar(
// //                     child: Text(
// //                       lead.contactname?.isNotEmpty == true
// //                           ? lead.contactname![0].toUpperCase()
// //                           : '?',
// //                     ),
// //                   ),
// //                   title: Text(lead.contactname ?? 'Unknown'),
// //                   subtitle: Text(lead.full_number ?? 'No number'),
// //                 );
// //               },
// //             ),
// //     );
// //   }
// // }

// ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously, prefer_typing_uninitialized_variables, unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:whatsapp/main.dart';
import 'package:whatsapp/models/recent_chat_model.dart';
import 'package:whatsapp/models/unread_msg_model/unread_msg_model.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_fonts.dart';
import 'package:whatsapp/view_models/lead_controller.dart';
import 'package:whatsapp/view_models/unread_count_vm.dart';
import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
import '../../models/lead_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_utils.dart';
import '../../view_models/lead_list_vm.dart';
import 'package:badges/badges.dart' as badges;

class RecentChatView extends StatefulWidget {
  const RecentChatView({super.key});
  @override
  State<RecentChatView> createState() => _RecentChatViewState();
}

class _RecentChatViewState extends State<RecentChatView> {
  final List<Color> tagColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.cyan,
    Colors.pink,
    Colors.teal,
    Colors.brown,
    Colors.indigo,
    Colors.lime,
    Colors.amber,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
    Colors.pinkAccent,
    Colors.redAccent,
    Colors.orangeAccent
  ];
  String finalResult = "";
  IO.Socket? socket;
  String token = "your_token_here";
  Map<String, dynamic> userId = {};
  String leadId = "lead_456";
  String phNum = "+919876543210";
  // final List<String> _leadfilter = [];
  List<LeadModel> leadss = [];
  TextEditingController textController = TextEditingController();
  var leadlistvm;
  var userlistvm;
  // UnreadMsgModel? campginmodel;
  List leadModelList = [];
  List tempLeadModelList = [];
  UnreadCountVm? unreadCountVm;
  // List<UnreadCountMsgModel> unreadModel = [];
  LeadListViewModel? leads;
  String? selectlead;
  String? selectuser;
  bool isRefresh = false;
  int countunread = 0;
  List allRecentChats = [];
  List pinnedLeads = [];

  List unreadList = [];
  String? number;

  bool? shouldHideLeadNumber;

  // For tag filtering
  String? selectedTagId;
  String? selectedTagName;
  bool isTagFilterActive = false;

  // List of unique tags from all leads
  List<Map<String, dynamic>> allUniqueTags = [];

  @override
  void initState() {
    shouldHide();
    _getUnreadCount();
    getLeadList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool noMatchedLeads = false;
  List matched = [];
  List others = [];

  Future<void> _getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    number = prefs.getString('phoneNumber');

    if (!mounted) return;

    await Provider.of<UnreadCountVm>(context, listen: false)
        .fetchunreadcount(number: number ?? "");

    var unreadMsgModel;
    for (var unreadModel in unreadCountVm?.viewModels ?? []) {
      unreadMsgModel = unreadModel.model as UnreadMsgModel;
    }

    unreadList = unreadMsgModel?.records ?? [];

    if (mounted) {
      setState(() {});
    }
  }

  int selectedFilterId = 0;
  List<String> filters = ["All", "Unread"];

  void _filterLeads(String searchLead) {
    searchLead = searchLead.trim().toLowerCase();

    if (searchLead.isEmpty) {
      if (isTagFilterActive) {
        _applyTagFilter();
      } else if (selectedFilterId == 1) {
        unreadChatFilter();
      } else {
        allRecentChats = tempLeadModelList;
      }

      if (mounted) {
        setState(() {});
      }
    } else {
      matched = [];
      others = [];

      List sourceList = isTagFilterActive
          ? _getFilteredLeadsByTag(selectedTagId)
          : (selectedFilterId == 1 ? _getUnreadLeads() : tempLeadModelList);

      for (var lead in sourceList) {
        var firstName = lead.contactname?.toLowerCase() ?? '';
        var lastName = lead.full_number?.toLowerCase() ?? '';

        if (firstName.contains(searchLead) || lastName.contains(searchLead)) {
          matched.add(lead);
        }
      }

      if (mounted) {
        setState(() {
          allRecentChats = [...matched];
          noMatchedLeads = matched.isEmpty;
        });
      }
    }
  }

  void _applyTagFilter() {
    if (selectedTagId == null) {
      allRecentChats = tempLeadModelList;
      isTagFilterActive = false;
    } else {
      allRecentChats = _getFilteredLeadsByTag(selectedTagId);
      isTagFilterActive = true;
    }
    setState(() {});
  }

  List _getFilteredLeadsByTag(String? tagId) {
    if (tagId == null) return tempLeadModelList;

    return tempLeadModelList.where((lead) {
      if (lead.tag_names == null) return false;
      return lead.tag_names.any((tag) => tag['id'] == tagId);
    }).toList();
  }

  List _getUnreadLeads() {
    List<dynamic> prioritizedLeads = [];

    for (var lead in tempLeadModelList) {
      bool hasUnread = unreadList.any(
        (unread) =>
            unread.whatsappNumber.toString().contains(lead.whatsapp_number),
      );

      if (hasUnread) {
        prioritizedLeads.add(lead);
      }
    }

    return prioritizedLeads;
  }

  void _extractUniqueTags() {
    final Set<String> seenTagIds = {};
    allUniqueTags = [];

    for (var record in tempLeadModelList) {
      if (record.tag_names != null && record.tag_names.isNotEmpty) {
        for (var tag in record.tag_names) {
          if (!seenTagIds.contains(tag['id'])) {
            seenTagIds.add(tag['id']);
            allUniqueTags.add({
              'id': tag['id'],
              'name': tag['name'],
              'color': tagColors[allUniqueTags.length % tagColors.length]
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    unreadCountVm = Provider.of<UnreadCountVm>(context);
    leadlistvm = Provider.of<LeadListViewModel>(context);

    return Scaffold(
      backgroundColor: AppColor.pageBgGrey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: isTagFilterActive
            ? Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTagId = null;
                        selectedTagName = null;
                        isTagFilterActive = false;
                        allRecentChats = tempLeadModelList;
                      });
                    },
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    selectedTagName ?? 'Tag',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : const Text(
                'Chats',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
        centerTitle: true,
        elevation: 5,
        actions: [
          showPin
              ? Row(
                  children: [
                    // Tag Icon
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: InkWell(
                        onTap: () {
                          _showTagsBottomSheet(context);
                        },
                        child: const Icon(
                          FontAwesomeIcons.tags,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),

                    // Pin Icon
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: InkWell(
                        onTap: () {
                          if (isPinned) {
                            Provider.of<LeadListViewModel>(context,
                                    listen: false)
                                .unpinChat(pinnedLeadId)
                                .then((onValue) {
                              getLeadList(showLoading: false);
                            });
                          } else {
                            Provider.of<LeadListViewModel>(context,
                                    listen: false)
                                .pinChat(pinnedLeadId)
                                .then((onValue) {
                              getLeadList(showLoading: false);
                            });
                          }
                          setState(() {
                            showPin = false;
                            pinnedLeadId = "";
                          });
                        },
                        child: isPinned == false
                            ? const Icon(
                                Icons.push_pin_outlined,
                                color: Colors.white,
                              )
                            : Image.asset(
                                "assets/images/unpin_icon.png",
                                color: Colors.white,
                                height: 20,
                              ),
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            pinnedLeadId = "";
            showPin = false;
            isPinned = false;
          });
          FocusScope.of(context).unfocus();
        },
        child: RefreshIndicator(
          onRefresh: _pullRefresh,
          child: (_pageBody()),
        ),
      ),
    );
  }

  Future<String?> _marksread(String whatsappNumber) async {
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    Map<String, String>? bodydata = {"whatsapp_number": whatsappNumber};

    await Provider.of<UnreadCountVm>(context, listen: false).marksreadcountmsg(
      leadnumber: whatsappNumber,
      number: number,
      bodydata: bodydata,
    );
    return null;
  }

  Future<void> _pullRefresh() async {
    leads?.viewModels.clear();

    await Provider.of<LeadListViewModel>(context, listen: false)
        .fetchRecentChat();
    await Provider.of<UnreadCountVm>(context, listen: false)
        .fetchunreadcount(number: number);
    getLeadList();
    isRefresh = true;
    return Future<void>.delayed(const Duration(seconds: 1));
  }

  Widget _pageBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: TextField(
            controller: textController,
            onChanged: _filterLeads,
            cursorColor: AppColor.navBarIconColor,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search...',
              hintStyle: TextStyle(
                color: AppColor.textoriconColor.withOpacity(0.6),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(10),
              disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColor.backgroundGrey),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColor.backgroundGrey),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColor.navBarIconColor,
                  width: 1.5,
                ),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  icon: const Icon(Icons.search, color: Colors.black, size: 20),
                  onPressed: () {},
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 40),
            ),
          ),
        ),
        pinnedLeads.isEmpty
            ? const SizedBox()
            : const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                child: Text(
                  "Pinned Leads",
                  style: TextStyle(fontFamily: AppFonts.medium),
                ),
              ),
        pinnedLeads.isEmpty
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SizedBox(
                  height: 70,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Pinned leads avatars
                        ...pinnedLeads.map((model) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: InkWell(
                              onTap: () async {
                                setState(() {
                                  pinnedLeadId = "";
                                  showPin = false;
                                  isPinned = false;
                                });

                                if (model.full_number != null) {
                                  _marksread(model.full_number ?? "");

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WhatsappChatScreen(
                                        pinnedLeads: pinnedLeads,
                                        leadName: model.contactname ?? "",
                                        wpnumber: model.full_number,
                                        id: model.id,
                                        contryCode: model.countrycode,
                                      ),
                                    ),
                                  ).then((_) {
                                    _getUnreadCount();
                                    setState(() {});
                                  });

                                  leads?.viewModels.clear();
                                  Provider.of<LeadListViewModel>(context,
                                          listen: false)
                                      .fetchRecentChat();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No Phone Number'),
                                      duration: Duration(seconds: 3),
                                      backgroundColor:
                                          AppColor.motivationCar1Color,
                                    ),
                                  );
                                }
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColor.navBarIconColor,
                                    child: Text(
                                      model.contactname?.isNotEmpty == true
                                          ? model.contactname![0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      model.contactname ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontFamily: AppFonts.semiBold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
        Expanded(
            child: chatLoader
                ? const Center(
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 5,
                                spreadRadius: 3,
                                offset: const Offset(2, 4),
                              ),
                            ],
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 12.0, bottom: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 50,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        // -------- FILTER CHIPS (All, Unread) --------
                                        ...List.generate(filters.length,
                                            (index) {
                                          final isSelected =
                                              selectedFilterId == index &&
                                                  !isTagFilterActive;
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  selectedFilterId = index;
                                                  selectedTagId = null;
                                                  selectedTagName = null;
                                                  isTagFilterActive = false;
                                                  if (index == 1) {
                                                    unreadChatFilter();
                                                  } else {
                                                    allRecentChats =
                                                        tempLeadModelList;
                                                  }
                                                });
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? Colors.black
                                                        : Colors.transparent,
                                                    width: 1.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),
                                                child: Text(
                                                  filters[index],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),

                                        // -------- TAG ICONS --------
                                        ...allUniqueTags.map((tag) {
                                          final isSelected =
                                              isTagFilterActive &&
                                                  selectedTagId == tag['id'];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10.0),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              onTap: () {
                                                setState(() {
                                                  selectedTagId = tag['id'];
                                                  selectedTagName = tag['name'];
                                                  selectedFilterId = -1;
                                                  isTagFilterActive = true;
                                                  _applyTagFilter();
                                                });
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? Colors.black
                                                        : tag['color'],
                                                    width:
                                                        isSelected ? 1.5 : 1.2,
                                                  ),
                                                  color: tag['color']
                                                      .withOpacity(0.1),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      FontAwesomeIcons.tag,
                                                      color: tag['color'],
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      tag['name'],
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: tag['color'],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                                ),

                                const Divider(),
                                // Lead Chat List
                                const SizedBox(height: 10),
                                allRecentChats.isEmpty || noMatchedLeads
                                    ? const Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 38.0),
                                          child: Text(
                                            "No Chat Found..",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        child: ListView.builder(
                                          itemCount: allRecentChats.length,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            final lead = allRecentChats[index];
                                            String unreadCount = "0";

                                            for (var p in unreadList) {
                                              if (lead.full_number
                                                  .toString()
                                                  .contains(p.whatsappNumber)) {
                                                unreadCount = p.unreadMsgCount;
                                                break;
                                              }
                                            }

                                            return leadRecordList(
                                                lead, unreadCount);
                                          },
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
      ],
    );
  }

  bool chatLoader = false;
  Future<void> getLeadList({bool showLoading = true}) async {
    if (mounted) {
      if (showLoading == true) {
        setState(() {
          chatLoader = true;
        });
      }
    }

    await Provider.of<LeadListViewModel>(navigatorKey.currentContext!,
            listen: false)
        .fetchRecentChat()
        .then((onValue) {
      allRecentChats = [];
      tempLeadModelList = [];
      pinnedLeads = [];

      try {
        for (var viewModel in leadlistvm.viewModels) {
          var recentMsgmodel = viewModel.model;
          if (recentMsgmodel?.records != null) {
            for (var record in recentMsgmodel!.records!) {
              allRecentChats.add(record);
              tempLeadModelList.add(record);
              if (record.pinned) {
                pinnedLeads.add(record);
              }
            }
          }
        }
        // Extract unique tags from all leads
        _extractUniqueTags();
      } catch (e) {
        allRecentChats = [];
      }
    });

    if (mounted) {
      setState(() {
        chatLoader = false;
      });
    }
  }

  bool showPin = false;
  String pinnedLeadId = "";
  bool isPinned = false;

  Widget leadRecordList(Records model, String unreadMsgCount) {
    Color statusColor;
    statusColor = AppColor.navBarIconColor;

    String formatPhoneNumber(String? phoneNumber) {
      if (phoneNumber == null || phoneNumber.isEmpty) return '';

      if (shouldHideLeadNumber == true && phoneNumber.length > 5) {
        int totalLength = phoneNumber.length;
        String lastFiveDigits = phoneNumber.substring(totalLength - 5);
        String maskedPart = 'X' * (totalLength - 5);
        return '$maskedPart$lastFiveDigits';
      } else {
        return phoneNumber;
      }
    }

    return GestureDetector(
      onLongPress: () {
        setState(() {
          showPin = true;
          pinnedLeadId = model.lead_id ?? "";
          isPinned = model.pinned ?? false;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: showPin && pinnedLeadId == model.lead_id
              ? AppColor.pageBgGrey
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(
              color: statusColor,
              width: 5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 3,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
          child: InkWell(
            onTap: () {
              setState(() {
                pinnedLeadId = "";
                showPin = false;
                isPinned = false;
              });
              if (model.full_number != null) {
                _marksread(model.full_number ?? "");

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WhatsappChatScreen(
                      pinnedLeads: pinnedLeads,
                      leadName: model.contactname ?? "",
                      wpnumber: model.full_number,
                      id: model.id,
                      contryCode: model.countrycode,
                    ),
                  ),
                ).then((_) {
                  _getUnreadCount();

                  setState(() {
                    unreadMsgCount = "0";
                    unreadMsgCount = "";
                  });
                });
                leads?.viewModels.clear();
                Provider.of<LeadListViewModel>(context, listen: false)
                    .fetchRecentChat();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No Phone Number '),
                    duration: Duration(seconds: 3),
                    backgroundColor: AppColor.motivationCar1Color,
                  ),
                );
              }
            },
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColor.navBarIconColor,
                        child: Text(
                          model.contactname?.isNotEmpty == true
                              ? model.contactname![0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${model.contactname}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: AppFonts.semiBold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Text(
                                formatPhoneNumber(model.full_number),
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                "${model.message}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                              // Display tags if available
                              if (model.tag_names != null &&
                                  model.tag_names!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Wrap(
                                    spacing: 4,
                                    runSpacing: 2,
                                    children:
                                        model.tag_names!.map<Widget>((tag) {
                                      final tagColor = allUniqueTags.firstWhere(
                                        (t) => t['id'] == tag['id'],
                                        orElse: () => {'color': Colors.grey},
                                      )['color'];
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: tagColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                            color: tagColor,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.tag,
                                              size: 10,
                                              color: tagColor,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              tag['name'],
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: tagColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (unreadMsgCount != "0" && unreadMsgCount.isNotEmpty)
                      badges.Badge(
                        badgeStyle: const badges.BadgeStyle(
                          badgeColor: Colors.green,
                        ),
                        badgeContent: Text(
                          unreadMsgCount,
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    Text(
                      formatDateTime(model.createddate.toString()),
                      style:
                          const TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                    model.pinned ?? false
                        ? const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Icon(
                              Icons.push_pin,
                              color: Colors.black87,
                              size: 18,
                            ),
                          )
                        : const SizedBox()
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool noRecordFound = false;
  void filterLeads(String? filter) {
    leadModelList = tempLeadModelList;
    if (filter == null) return;
    setState(() {
      List<dynamic> matchleads = leadModelList
          .where(
              (lead) => lead.leadstatus?.toLowerCase() == filter.toLowerCase())
          .toList();

      allRecentChats = matchleads;
      noRecordFound = matchleads.isEmpty;
    });
  }

  Future<void> connectSocket() async {
    String tkn = await AppUtils.getToken() ?? "";
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');
    LeadController leadCtrl = Provider.of(context, listen: false);
    token = tkn;
    phNum = number ?? "";
    Map<String, dynamic> decodedToken = Map<String, dynamic>.from(
      JwtDecoder.decode(tkn),
    );

    token = tkn;
    phNum = number ?? "";
    userId = decodedToken;

    userId.addAll({
      "business_numbers": leadCtrl.allBusinessNumbers,
      "business_number": number
    });

    // log("user id sending in socket setup::::   $userId");

    try {
      socket = IO.io(
        'https://admin.watconnect.com',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setPath('/ibs/socket.io')
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .build(),
      );
      socket!.connect();
      socket!.onConnect((_) {
        print('Connected to WebSocket recent ');
        socket!.emit("setup", userId);
      });
      socket!.on("connected", (_) {});

      socket!.on("receivedwhatsappmessage", (data) {
        print(" New WhatsApp message: $data");
        getLeadList(showLoading: false);
        _getUnreadCount();
      });

      socket!.onDisconnect((_) {
        print(" WebSocket Disconnected");
      });

      socket!.onError((error) {
        print(" WebSocket Error: $error");
      });
    } catch (error) {
      print("Error connecting to WebSocket: $error");
    }
  }

  void _showTagsBottomSheet(BuildContext context) {
    bool isCreatingNewLabel = false;
    TextEditingController labelController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Label chat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 24),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  isCreatingNewLabel
                      ? Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: labelController,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  hintText: 'Enter label name',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                if (labelController.text.isNotEmpty) {
                                  print('New label: ${labelController.text}');
                                  setState(() {
                                    isCreatingNewLabel = false;
                                    labelController.clear();
                                  });
                                }
                              },
                              icon:
                                  const Icon(Icons.check, color: Colors.green),
                            ),
                          ],
                        )
                      : ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 0),
                          leading: const Icon(Icons.add, size: 24),
                          title: const Text(
                            'New label',
                            style: TextStyle(fontSize: 16),
                          ),
                          onTap: () {
                            setState(() {
                              isCreatingNewLabel = true;
                            });
                          },
                        ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: allUniqueTags.length,
                      itemBuilder: (context, index) {
                        final tag = allUniqueTags[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: tag['color'].withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              FontAwesomeIcons.tag,
                              size: 20,
                              color: tag['color'],
                            ),
                          ),
                          title: Text(
                            tag['name'],
                            style: const TextStyle(fontSize: 16),
                          ),
                          trailing: Checkbox(
                            value: selectedTagId == tag['id'],
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedTagId = tag['id'];
                                  selectedTagName = tag['name'];
                                  isTagFilterActive = true;
                                } else {
                                  selectedTagId = null;
                                  selectedTagName = null;
                                  isTagFilterActive = false;
                                }
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (selectedTagId != null) {
                          _applyTagFilter();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.grey.shade600,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  unreadChatFilter() {
    List prioritizedLeads = [];
    List otherLeads = [];

    for (var lead in allRecentChats) {
      bool hasUnread = unreadList.any(
        (unread) =>
            unread.whatsappNumber.toString().contains(lead.whatsapp_number),
      );

      if (hasUnread) {
        prioritizedLeads.add(lead);
      } else {
        otherLeads.add(lead);
      }
    }

    allRecentChats = [...prioritizedLeads];
  }

  String formatDateTime(String isoString) {
    final inputDate = DateTime.parse(isoString).toLocal();
    final now = DateTime.now();

    final isToday = inputDate.year == now.year &&
        inputDate.month == now.month &&
        inputDate.day == now.day;

    if (isToday) {
      // return DateFormat.jm().format(inputDate);
      return DateFormat('MMM dd, yyyy').format(inputDate);
    } else {
      return DateFormat('MMM dd, yyyy').format(inputDate);
    }
  }

  Future<void> shouldHide() async {
    final prefs = await SharedPreferences.getInstance();
    shouldHideLeadNumber = prefs.getBool(SharedPrefsConstants.shouldHideNumber);
    setState(() {});
  }
}
