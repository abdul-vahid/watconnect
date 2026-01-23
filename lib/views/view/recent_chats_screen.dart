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
