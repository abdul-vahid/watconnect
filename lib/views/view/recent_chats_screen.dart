// ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously, prefer_typing_uninitialized_variables, unnecessary_brace_in_string_interps

import 'dart:developer';

import 'package:flutter/material.dart';
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

  @override
  void initState() {
    shouldHide();
    _getUnreadCount();
    getLeadList();
    super.initState();
    // connectSocket();
  }

  @override
  void dispose() {
    // disconnectSocket();
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

  int selectedTagId = 0;
  List<String> tags = ["All", "Unread"];

  void _filterLeads(String searchLead) {
    searchLead = searchLead.trim().toLowerCase();

    if (searchLead.isEmpty) {
      List prioritizedLeads = [];
      List otherLeads = [];
      noMatchedLeads = false;

      for (var lead in allRecentChats) {
        bool hasUnread = unreadList.any(
          (unread) =>
              unread.whatsappNumber.toString().contains(lead.whatsapp_number),
        );

        if (hasUnread) {
          prioritizedLeads.add(lead);
        }
      }

      allRecentChats = [...prioritizedLeads, ...otherLeads];
      allRecentChats = tempLeadModelList;

      if (mounted) {
        setState(() {});
      }
    } else {
      matched = [];
      others = [];

      for (var lead in tempLeadModelList) {
        var firstName = lead.contactname?.toLowerCase() ?? '';
        var lastName = lead.full_number?.toLowerCase() ?? '';

        if (firstName.contains(searchLead) || lastName.contains(searchLead)) {
          matched.add(lead);
        }
      }

      if (mounted) {
        setState(() {
          allRecentChats = [
            ...matched,
          ];
          noMatchedLeads = matched.isEmpty;
        });
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
        title: const Text(
          'Chats',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 5,
        actions: [
          showPin
              ? Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: InkWell(
                    onTap: () {
                      if (isPinned) {
                        Provider.of<LeadListViewModel>(context, listen: false)
                            .unpinChat(pinnedLeadId)
                            .then((onValue) {
                          getLeadList(showLoading: false);
                        });
                      } else {
                        Provider.of<LeadListViewModel>(context, listen: false)
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
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: pinnedLeads.length,
                      itemBuilder: (context, index) {
                        var model = pinnedLeads[index];
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

                                  setState(() {
                                    // unreadMsgCount = "0";
                                    // unreadMsgCount = "";
                                  });
                                  // print("unreadMsgCount====${unreadMsgCount}  ");
                                });
                                leads?.viewModels.clear();
                                Provider.of<LeadListViewModel>(context,
                                        listen: false)
                                    .fetchRecentChat();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('No Phone Number '),
                                    duration: Duration(seconds: 3),
                                    backgroundColor:
                                        AppColor.motivationCar1Color,
                                  ),
                                );
                              }
                            },
                            child: SizedBox(
                              width: 60,
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColor.navBarIconColor,
                                    child: Text(
                                      "${pinnedLeads[index].contactname?.isNotEmpty == true ? pinnedLeads[index].contactname![0].toUpperCase() : '?'}",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    pinnedLeads[index].contactname,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontFamily: AppFonts.semiBold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
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
                                  height: 40,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: tags.length,
                                    itemBuilder: (context, index) {
                                      final isSelected = selectedTagId == index;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedTagId = index;
                                              if (index == 1) {
                                                unreadChatFilter();
                                              } else {
                                                allRecentChats =
                                                    tempLeadModelList;
                                              }
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12.0,
                                                vertical: 4.0),
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
                                            child: Center(
                                              child: Text(
                                                tags[index],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
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

    // Function to format phone number based on shouldHideLeadNumber
    String formatPhoneNumber(String? phoneNumber) {
      if (phoneNumber == null || phoneNumber.isEmpty) return '';

      if (shouldHideLeadNumber == true && phoneNumber.length > 5) {
        // Show only last 5 digits, mask the rest with X
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
                  print("unreadMsgCount====${unreadMsgCount}  ");
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
    // final prefs = await SharedPreferences.getInstance();
    // String? number = prefs.getString('phoneNumber');

    String tkn = await AppUtils.getToken() ?? "";
    // Map<String, dynamic> decodedToken = JwtDecoder.decode(tkn);
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

    log("user id sending in socket setup::::   $userId");

    try {
      // print("Token: $token");

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
      socket!.on("connected", (_) {
        // print(" WebSocket setup complete");
      });

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

  void disconnectSocket() {
    if (socket != null) {
      socket!.disconnect();
      print(" WebSocket Disconnected  recent");
    }
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
      return DateFormat.jm().format(inputDate);
    } else {
      return DateFormat('MMM dd, yy').format(inputDate);
    }
  }

  Future<void> shouldHide() async {
    final prefs = await SharedPreferences.getInstance();
    shouldHideLeadNumber = prefs.getBool(SharedPrefsConstants.shouldHideNumber);
    setState(() {});
  }
}
