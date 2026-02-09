import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:whatsapp/main.dart';
import 'package:whatsapp/models/recent_chat_model.dart';
import 'package:whatsapp/models/unread_msg_model/unread_msg_model.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_fonts.dart';
import 'package:whatsapp/view_models/lead_controller.dart';
import 'package:whatsapp/view_models/unread_count_vm.dart';
import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
import 'package:whatsapp/views/view/recent_archieve_chat.dart';
import '../../models/lead_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_utils.dart';
import '../../utils/function_lib.dart';
import '../../view_models/lead_list_vm.dart';

class RecentChatView extends StatefulWidget {
  const RecentChatView({super.key});
  @override
  State<RecentChatView> createState() => _RecentChatViewState();
}

class _RecentChatViewState extends State<RecentChatView> {
  final List<Color> tagColors = [
    Colors.blue,
  ];

  String finalResult = "";
  IO.Socket? socket;
  String token = "";
  Map<String, dynamic> userId = {};
  String leadId = "lead_456";
  String phNum = "+919876543210";
  List<LeadModel> leadss = [];
  TextEditingController textController = TextEditingController();
  var leadlistvm;
  var userlistvm;
  List leadModelList = [];
  List tempLeadModelList = [];
  UnreadCountVm? unreadCountVm;
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
  List<Map<String, dynamic>> selectedTagsForFilter = [];

  List<Map<String, dynamic>> allUniqueTags = [];

  Records? currentLeadForTagEditing;

  List<String> selectedTagIdsForCurrentLead = [];

  bool isCreatingNewLabel = false;
  TextEditingController newTagController = TextEditingController();

  final int maxTagsToShow = 3;

  @override
  void initState() {
    shouldHide();
    _getUnreadCount();
    getLeadList();
    super.initState();
  }

  @override
  void dispose() {
    newTagController.dispose();
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
          ? _getFilteredLeadsByTags(selectedTagsForFilter)
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
    if (selectedTagsForFilter.isEmpty) {
      allRecentChats = tempLeadModelList;
      isTagFilterActive = false;
    } else {
      allRecentChats = _getFilteredLeadsByTags(selectedTagsForFilter);
      isTagFilterActive = true;
    }
    setState(() {});
  }

  List _getFilteredLeadsByTags(List<Map<String, dynamic>> tags) {
    if (tags.isEmpty) return tempLeadModelList;

    return tempLeadModelList.where((lead) {
      if (lead.tag_names == null || lead.tag_names.isEmpty) return false;

      // Check if lead has all selected tags
      for (var selectedTag in tags) {
        bool hasTag =
            lead.tag_names.any((tag) => tag['id'] == selectedTag['id']);
        if (!hasTag) return false;
      }
      return true;
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

    return FocusDetector(
      onFocusGained: () {
        getLeadList(showLoading: false);
      },
      child: Scaffold(
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
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
          centerTitle: true,
          elevation: 5,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RecentArchieveChatView()));
              },
              icon: Icon(Icons.archive),
              color: Colors.white,
            ),
            showPin
                ? Row(
                    children: [
                      // Tag Icon
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: InkWell(
                          onTap: () {
                            _showTagsBottomSheet(
                                context, currentLeadForTagEditing!);
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
                                        id: model.lead_id,
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
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor:
                                            AppColor.navBarIconColor,
                                        child: Text(
                                          model.contactname?.isNotEmpty == true
                                              ? model.contactname![0]
                                                  .toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.push_pin,
                                            size: 12,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ],
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
                                                  selectedTagsForFilter.clear();
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
                                        // Filter button for tags
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            onTap: () {
                                              _showFilterTagsBottomSheet();
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                left: 12,
                                                right: 12,
                                                top: 8,
                                                bottom: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                border: Border.all(
                                                  color: isTagFilterActive
                                                      ? Colors.blue
                                                      : Colors.grey,
                                                  width: 1.2,
                                                ),
                                                color: isTagFilterActive
                                                    ? Colors.blue
                                                        .withOpacity(0.1)
                                                    : Colors.transparent,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    FontAwesomeIcons.filter,
                                                    color: Colors.grey,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  const Text(
                                                    'Filter',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  if (selectedTagsForFilter
                                                      .isNotEmpty)
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 6),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.blue,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Text(
                                                        selectedTagsForFilter
                                                            .length
                                                            .toString(),
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(),
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
                debug("pinne");
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
    Color statusColor = AppColor.navBarIconColor;

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

    List<dynamic> visibleTags =
        model.tag_names != null && model.tag_names!.isNotEmpty
            ? model.tag_names!.length > maxTagsToShow
                ? model.tag_names!.sublist(0, maxTagsToShow)
                : model.tag_names!
            : [];

    bool hasMoreTags =
        model.tag_names != null && model.tag_names!.length > maxTagsToShow;
    int remainingTagsCount =
        model.tag_names != null ? model.tag_names!.length - maxTagsToShow : 0;

    Color tagIconColor = Colors.grey[600]!;
    if (visibleTags.isNotEmpty) {
      try {
        final tag = visibleTags[0];
        final tagIndex = allUniqueTags.indexWhere((t) => t['id'] == tag['id']);
        if (tagIndex != -1) {
          tagIconColor = allUniqueTags[tagIndex]['color'];
        }
      } catch (e) {
        tagIconColor = Colors.grey[600]!;
      }
    }

    bool hasUnread = unreadMsgCount != "0" && unreadMsgCount.isNotEmpty;

    return model.isArchived!
        ? const SizedBox()
        : GestureDetector(
            onLongPress: () {
              setState(() {
                showPin = true;
                pinnedLeadId = model.lead_id ?? "";
                isPinned = model.pinned ?? false;
                currentLeadForTagEditing = model;
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
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColor.navBarIconColor,
                            child: Text(
                              model.contactname?.isNotEmpty == true
                                  ? model.contactname![0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (model.pinned ?? false)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.push_pin,
                                size: 12,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
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
                                  id: model.lead_id,
                                  isArch: model.isArchived,
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
                                content: Text('No Phone Number '),
                                duration: Duration(seconds: 3),
                                backgroundColor: AppColor.motivationCar1Color,
                              ),
                            );
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Name and Tag Icon
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      // Contact name with ellipsis
                                      Flexible(
                                        child: Text(
                                          "${model.contactname}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: AppFonts.semiBold,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      // Tag icon with bigger size and scope
                                      if (visibleTags.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 6),
                                          child: InkWell(
                                            onTap: () {
                                              _showTagsBottomSheet(
                                                  context, model);
                                            },
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    FontAwesomeIcons.tag,
                                                    size: 20,
                                                    color: tagIconColor,
                                                  ),
                                                  // Tags count दिखाएं
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4),
                                                    child: Text(
                                                      // Total tags count दिखाएं
                                                      '+${model.tag_names?.length ?? 0}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: tagIconColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Phone number
                            Text(
                              formatPhoneNumber(model.full_number),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Last message
                            Text(
                              "${model.message}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (hasUnread)
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                unreadMsgCount,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.more_vert,
                              size: 18, color: Colors.black54),
                          onSelected: (value) {
                            if (value == 'pin') {
                              _handlePinAction(model);
                            } else if (value == 'tags') {
                              _showTagsBottomSheet(context, model);
                            } else if (value == 'archieve') {
                              _toggleArchiveStatus(model?.lead_id ?? "");
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'archieve',
                              child: Row(
                                children: [
                                  Icon(
                                    model.isArchived ?? false
                                        ? Icons.archive
                                        : Icons.unarchive,
                                    color: Colors.black87,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                      model.isArchived ?? false
                                          ? 'Un-Archive'
                                          : 'Archive',
                                      style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'pin',
                              child: Row(
                                children: [
                                  Icon(
                                    model.pinned ?? false
                                        ? Icons.push_pin
                                        : Icons.push_pin_outlined,
                                    color: Colors.black87,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(model.pinned ?? false ? 'Unpin' : 'Pin',
                                      style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'tags',
                              child: Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.tags,
                                    color: tagIconColor,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Manage Tags',
                                      style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatMessageTime(model.createddate.toString()),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
  }

// String _formatMessageTime(String isoString) {
//   try {
//     final inputDate = DateTime.parse(isoString).toLocal();
//     final now = DateTime.now();

//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final messageDate =
//         DateTime(inputDate.year, inputDate.month, inputDate.day);

//     final time = DateFormat('h:mm a').format(inputDate);

//     if (messageDate == today) {
//       return time;
//     } else if (messageDate == yesterday) {
//       return 'Yesterday, $time';
//     } else {
//       return DateFormat('MM/dd/yy').format(inputDate);
//     }
//   } catch (e) {
//     return '';
//   }
// }

  String _formatMessageTime(String isoString) {
    try {
      final inputDate = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();

      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDate =
          DateTime(inputDate.year, inputDate.month, inputDate.day);

      final time = DateFormat('h:mm a').format(inputDate);

      if (messageDate == today) {
        return time;
      } else if (messageDate == yesterday) {
        return 'Yesterday, $time';
      } else {
        return DateFormat('dd/MM/yy').format(inputDate); // 👈 changed
      }
    } catch (e) {
      return '';
    }
  }

  Future<void> _removeTagFromLead(Records lead, String tagId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Tag'),
        content: Text('Remove this tag from ${lead.contactname ?? "contact"}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              List<dynamic> currentTags = List.from(lead.tag_names ?? []);
              currentTags.removeWhere((tag) => tag['id'] == tagId);

              final index = tempLeadModelList
                  .indexWhere((item) => item.lead_id == lead.lead_id);
              if (index != -1) {
                setState(() {
                  tempLeadModelList[index].tag_names = currentTags;

                  final leadIndex = allRecentChats
                      .indexWhere((item) => item.lead_id == lead.lead_id);
                  if (leadIndex != -1) {
                    allRecentChats[leadIndex].tag_names = currentTags;
                  }

                  final pinnedIndex = pinnedLeads
                      .indexWhere((item) => item.lead_id == lead.lead_id);
                  if (pinnedIndex != -1) {
                    pinnedLeads[pinnedIndex].tag_names = currentTags;
                  }
                });
              }

              await _updateLeadTags(lead.lead_id ?? "", currentTags);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tag removed from lead'),
                  duration: Duration(seconds: 2),
                  backgroundColor: AppColor.cardsColor,
                ),
              );
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateLeadTags(String leadId, List<dynamic> tags) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await AppUtils.getToken();

      final url =
          Uri.parse('https://admin.watconnect.com/ibs/api/leads/$leadId');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final leadData = json.decode(response.body);
        final records = leadData['records'];

        final payload = {
          "id": records['id'],
          "firstname": records['firstname'] ?? "",
          "lastname": records['lastname'] ?? "",
          "country_code": records['country_code'] ?? "",
          "whatsapp_number": records['whatsapp_number'] ?? "",
          "email": records['email'] ?? "",
          "dob": records['dob'] ?? "",
          "tag_names": tags,
          "leadsource": records['leadsource'] ?? "",
          "state": records['state'] ?? "",
          "city": records['city'] ?? "",
          "leadstatus": records['leadstatus'] ?? "Open - Not Contacted",
          "ownername": records['ownername'] ?? "",
          "ownerid": records['ownerid'] ?? "",
          "ownerids": records['ownerids'] ?? [],
          "address": records['address'] ?? "",
          "description": records['description'] ?? "",
          "all_owner_names": records['all_owner_names'] ?? [],
          "blocked": records['blocked'] ?? false
        };

        final updateResponse = await http.put(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(payload),
        );

        if (updateResponse.statusCode == 200) {
          print('Tags updated successfully for lead: $leadId');
        } else {
          print('Failed to update tags: ${updateResponse.statusCode}');
        }
      }
    } catch (e) {
      print('Error updating lead tags: $e');
    }
  }

  void _handlePinAction(Records model) {
    if (model.pinned ?? false) {
      Provider.of<LeadListViewModel>(context, listen: false)
          .unpinChat(model.lead_id ?? "")
          .then((onValue) {
        getLeadList(showLoading: false);
      });
    } else {
      Provider.of<LeadListViewModel>(context, listen: false)
          .pinChat(model.lead_id ?? "")
          .then((onValue) {
        getLeadList(showLoading: false);
      });
    }
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

  void _showFilterTagsBottomSheet() {
    List<String> selectedFilterTagIds =
        selectedTagsForFilter.map((tag) => tag['id'] as String).toList();

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
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter by Labels',
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

                  // Selected Tags Preview
                  if (selectedFilterTagIds.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected for Filter:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedFilterTagIds.map<Widget>((tagId) {
                            final tag = allUniqueTags.firstWhere(
                              (t) => t['id'] == tagId,
                              orElse: () => {
                                'id': tagId,
                                'name': 'Unknown',
                                'color': Colors.grey
                              },
                            );
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: tag['color'].withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: tag['color'],
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.tag,
                                    size: 2,
                                    color: tag['color'],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    tag['name'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: tag['color'],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedFilterTagIds.remove(tagId);
                                      });
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: tag['color'],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // Selection Instructions
                  if (selectedFilterTagIds.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Select at least one label to enable Apply Filter',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Label Selection Header
                  const Text(
                    'Select Labels to Filter:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Labels List
                  Expanded(
                    child: allUniqueTags.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.tags,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No labels available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: allUniqueTags.length,
                            itemBuilder: (context, index) {
                              final tag = allUniqueTags[index];
                              final isSelected =
                                  selectedFilterTagIds.contains(tag['id']);

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
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        if (!selectedFilterTagIds
                                            .contains(tag['id'])) {
                                          selectedFilterTagIds.add(tag['id']);
                                        }
                                      } else {
                                        selectedFilterTagIds.remove(tag['id']);
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

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Clear all filters and update parent state
                            setState(() {
                              selectedTagsForFilter.clear();
                              isTagFilterActive = false;
                              allRecentChats = tempLeadModelList;

                              // Also clear the local selected tags in bottom sheet
                              selectedFilterTagIds.clear();
                            });

                            // Call callback to update parent widget if needed
                            // if (widget.onFilterCleared != null) {
                            //   widget.onFilterCleared!();
                            // }

                            // Navigate back
                            Navigator.pop(context);

                            // Show success message
                            EasyLoading.showSuccess('Filter cleared');

                            // Refresh the parent widget
                            if (mounted) {
                              setState(() {});
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Clear Filter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedFilterTagIds.isEmpty
                              ? null // Disable button when no tags selected
                              : () {
                                  setState(() {
                                    selectedTagsForFilter = allUniqueTags
                                        .where((tag) => selectedFilterTagIds
                                            .contains(tag['id']))
                                        .toList();
                                    isTagFilterActive =
                                        selectedTagsForFilter.isNotEmpty;
                                    _applyTagFilter();
                                  });
                                  Navigator.pop(context);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedFilterTagIds.isEmpty
                                ? Colors.grey.shade300 // Disabled color
                                : AppColor.navBarIconColor,
                            foregroundColor: selectedFilterTagIds.isEmpty
                                ? Colors.grey.shade600 // Disabled text color
                                : Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Apply Filter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: selectedFilterTagIds.isEmpty
                                  ? Colors.grey.shade600
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showTagsBottomSheet(BuildContext context, Records lead) {
    selectedTagIdsForCurrentLead =
        lead.tag_names?.map((tag) => tag['id'] as String).toList() ?? [];
    newTagController.clear();

    List<Map<String, dynamic>> sortedTags = List.from(allUniqueTags);
    sortedTags.sort((a, b) {
      bool aSelected = selectedTagIdsForCurrentLead.contains(a['id']);
      bool bSelected = selectedTagIdsForCurrentLead.contains(b['id']);
      if (aSelected && !bSelected) return -1;
      if (!aSelected && bSelected) return 1;
      return 0;
    });

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
            bool hasChanges = false;

            final List<String> originalTags =
                lead.tag_names?.map((tag) => tag['id'] as String).toList() ??
                    [];
            hasChanges =
                !_areListsEqual(originalTags, selectedTagIdsForCurrentLead);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Label chat',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lead.contactname ?? 'Unknown Contact',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Total: ${selectedTagIdsForCurrentLead.length} selected',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
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

                  // Create new label button
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColor.cardsColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 24,
                        color: AppColor.navBarIconColor,
                      ),
                    ),
                    title: const Text(
                      'Create new label',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      setState(() {
                        isCreatingNewLabel = true;
                      });
                    },
                  ),

                  // New label creation UI
                  if (isCreatingNewLabel)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'Create New Label',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: newTagController,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Enter label name',
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  suffixIcon: newTagController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () =>
                                              newTagController.clear(),
                                        )
                                      : null,
                                ),
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isCreatingNewLabel = false;
                                  newTagController.clear();
                                });
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: newTagController.text.trim().isNotEmpty
                                  ? () async {
                                      final tagName =
                                          newTagController.text.trim();

                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );

                                      final newTag =
                                          await _createTagInBackend(tagName);

                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }

                                      if (newTag != null && context.mounted) {
                                        setState(() {
                                          allUniqueTags.add({
                                            'id': newTag['id'],
                                            'name': newTag['name'],
                                            'color': tagColors[
                                                allUniqueTags.length %
                                                    tagColors.length]
                                          });

                                          selectedTagIdsForCurrentLead
                                              .add(newTag['id']);

                                          newTagController.clear();
                                          isCreatingNewLabel = false;

                                          sortedTags = List.from(allUniqueTags);
                                          sortedTags.sort((a, b) {
                                            bool aSelected =
                                                selectedTagIdsForCurrentLead
                                                    .contains(a['id']);
                                            bool bSelected =
                                                selectedTagIdsForCurrentLead
                                                    .contains(b['id']);
                                            if (aSelected && !bSelected)
                                              return -1;
                                            if (!aSelected && bSelected)
                                              return 1;
                                            return 0;
                                          });
                                        });

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Label "$tagName" created successfully'),
                                            duration:
                                                const Duration(seconds: 2),
                                            backgroundColor:
                                                AppColor.cardsColor,
                                          ),
                                        );
                                      } else if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Failed to create label'),
                                            duration: Duration(seconds: 2),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    newTagController.text.trim().isNotEmpty
                                        ? AppColor.navBarIconColor
                                        : Colors.grey.shade300,
                                foregroundColor:
                                    newTagController.text.trim().isNotEmpty
                                        ? Colors.white
                                        : Colors.grey.shade600,
                              ),
                              child: const Text('Create Label'),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                      ],
                    ),

                  const SizedBox(height: 10),
                  const Text(
                    'Available Labels',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: sortedTags.isEmpty && !isCreatingNewLabel
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.tags,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No labels available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Create your first label',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: sortedTags.length,
                            itemBuilder: (context, index) {
                              final tag = sortedTags[index];
                              final isSelected = selectedTagIdsForCurrentLead
                                  .contains(tag['id']);

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
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        if (!selectedTagIdsForCurrentLead
                                            .contains(tag['id'])) {
                                          selectedTagIdsForCurrentLead
                                              .add(tag['id']);
                                        }
                                      } else {
                                        selectedTagIdsForCurrentLead
                                            .remove(tag['id']);
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
                      onPressed: hasChanges
                          ? () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              await _saveTagsToLead(
                                  lead, selectedTagIdsForCurrentLead);

                              if (context.mounted) {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasChanges
                            ? AppColor.navBarIconColor
                            : Colors.grey.shade300,
                        foregroundColor:
                            hasChanges ? Colors.white : Colors.grey.shade600,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save Labels',
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

  Future<Map<String, dynamic>?> _createTagInBackend(String tagName) async {
    try {
      final token = await AppUtils.getToken();
      final url =
          Uri.parse('https://admin.watconnect.com/ibs/api/whatsapp/tag');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': tagName,
          'status': true,
          'first_message': 'No',
          'auto_tag_rules': []
        }),
      );

      print('Tag creation response status: ${response.statusCode}');
      print('Tag creation response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['record'] != null) {
          final record = responseData['record'];
          return {
            'id': record['id'],
            'name': record['name'],
            'status': record['status'] ?? true,
            'createddate': record['createddate'],
            'first_message': record['first_message'] ?? 'No',
          };
        } else if (responseData['id'] != null) {
          return {
            'id': responseData['id'],
            'name': tagName,
            'status': true,
            'first_message': 'No',
          };
        }
      } else {
        print('Failed to create tag: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error creating tag: $e');
    }

    return {
      'id': 'new_tag_${DateTime.now().millisecondsSinceEpoch}',
      'name': tagName,
      'status': true,
      'first_message': 'No',
    };
  }

  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (var i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  Future<void> _saveTagsToLead(
      Records lead, List<String> selectedTagIds) async {
    final selectedTags = allUniqueTags
        .where((tag) => selectedTagIds.contains(tag['id']))
        .map((tag) => {
              'id': tag['id'],
              'name': tag['name'],
            })
        .toList();

    final index =
        tempLeadModelList.indexWhere((item) => item.lead_id == lead.lead_id);
    if (index != -1) {
      setState(() {
        tempLeadModelList[index].tag_names = selectedTags;

        final leadIndex =
            allRecentChats.indexWhere((item) => item.lead_id == lead.lead_id);
        if (leadIndex != -1) {
          allRecentChats[leadIndex].tag_names = selectedTags;
        }

        final pinnedIndex =
            pinnedLeads.indexWhere((item) => item.lead_id == lead.lead_id);
        if (pinnedIndex != -1) {
          pinnedLeads[pinnedIndex].tag_names = selectedTags;
        }
      });
    }

    await _updateLeadTags(lead.lead_id ?? "", selectedTags);

    setState(() {
      _extractUniqueTags();
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${selectedTagIds.length} label${selectedTagIds.length == 1 ? '' : 's'} applied to ${lead.contactname ?? 'contact'}',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteTag(String tagId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Label'),
        content: const Text(
            'Are you sure you want to delete this label? This will remove it from all chats.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final token = await AppUtils.getToken();
                final url = Uri.parse(
                    'https://admin.watconnect.com/ibs/api/whatsapp/tag/$tagId');

                final response = await http.delete(
                  url,
                  headers: {
                    'Authorization': 'Bearer $token',
                  },
                );

                if (response.statusCode == 200 || response.statusCode == 204) {
                  setState(() {
                    allUniqueTags.removeWhere((tag) => tag['id'] == tagId);

                    for (var lead in tempLeadModelList) {
                      if (lead.tag_names != null) {
                        lead.tag_names
                            ?.removeWhere((tag) => tag['id'] == tagId);
                      }
                    }

                    if (selectedTagsForFilter
                        .any((tag) => tag['id'] == tagId)) {
                      selectedTagsForFilter
                          .removeWhere((tag) => tag['id'] == tagId);
                      _applyTagFilter();
                    }
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Label deleted successfully'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete label'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error deleting label'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                  ),
                );
              }

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
    try {
      final inputDate = DateTime.parse(isoString).toLocal();
      final formatter = DateFormat('dd/MM/yyyy HH:mm');
      return formatter.format(inputDate);
    } catch (e) {
      return isoString;
    }
  }

  Future<void> shouldHide() async {
    final prefs = await SharedPreferences.getInstance();
    shouldHideLeadNumber = prefs.getBool(SharedPrefsConstants.shouldHideNumber);
    setState(() {});
  }

  Future<void> _toggleArchiveStatus(String id) async {
    try {
      final LeadListViewModel leadData =
          Provider.of<LeadListViewModel>(context, listen: false);

      Map<String, dynamic> body = {"id": id, "is_archived": true};

      EasyLoading.show(status: 'Processing...');

      await leadData.updatelead(body, id ?? "");

      EasyLoading.dismiss();

      EasyLoading.showToast('Chat Archived Successfully');

      getLeadList();
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showToast('Failed to update archive status');
      print('Error in _toggleArchiveStatus: $e');
    }
  }
}
