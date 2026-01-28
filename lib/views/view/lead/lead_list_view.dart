// ignore_for_file: deprecated_member_use, avoid_print, use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:whatsapp/models/tags_list_model.dart';
import 'package:whatsapp/models/unread_msg_model/unread_msg_model.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_fonts.dart';
import 'package:whatsapp/view_models/lead_controller.dart';
import 'package:whatsapp/view_models/unread_count_vm.dart';
import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
import '../../../models/lead_model.dart';
import '../../../utils/app_color.dart';
import '../../../utils/app_utils.dart';
import '../../../view_models/lead_list_vm.dart';
import '../../../view_models/user_data_list_vm.dart';
import '../lead_add_update_view.dart';

import 'package:badges/badges.dart' as badges;

class LeadListView extends StatefulWidget {
  const LeadListView({super.key});
  @override
  State<LeadListView> createState() => _LeadListViewState();
}

class _LeadListViewState extends State<LeadListView> with RouteAware {
  String finalResult = "";
  IO.Socket? socket;
  String token = "your_token_here";
  var userId;
  String leadId = "lead_456";
  String phNum = "+919876543210";
  final List<String> _leadfilter = [];
  List<LeadModel> leadss = [];
  TextEditingController textController = TextEditingController();
  var leadlistvm;
  var userlistvm;

  List<String> idsToDelete = [];

  List leadModelList = [];
  List tempLeadModelList = [];
  List backupListModel = [];
  UnreadCountVm? unreadCountVm;

  LeadListViewModel? leads;
  String? selectlead;
  String? selectuser;
  bool isRefresh = false;
  int countunread = 0;
  List allLeads = [];
  List pinnedLeads = [];

  List unreadList = [];
  List<String> selectleadList = [];
  List<String> selectTagFilterList = [];

  String? number;

  int selectedFilterId = 0;
  List<String> filters = ["All", "Unread", "Filter"];
  List<String> tags = [];

  bool? shouldHideLeadNumber;
  @override
  void initState() {
    selectleadList = [];
    shouldHide();

    print("shouldHideLeadNumber::::::   $shouldHideLeadNumber");
    getTags();
    _getUnreadCount();
    selectTagFilterList = [];
    getLeadList();
    // connectSocket();
    super.initState();
  }

  @override
  void dispose() {
    // disconnectSocket();
    // routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    number = prefs.getString('phoneNumber');
    unreadList = [];
    if (!mounted) return;
    Provider.of<LeadListViewModel>(context, listen: false).fetch();
    await Provider.of<UnreadCountVm>(context, listen: false)
        .fetchunreadcount(number: number ?? "");

    var unreadMsgModel;
    for (var unreadModel in unreadCountVm?.viewModels ?? []) {
      unreadMsgModel = unreadModel.model as UnreadMsgModel;
    }
    print(" unreadMsgModel.records::::::::::   ${unreadMsgModel.records}");
    unreadList = unreadMsgModel.records ?? [];
    setState(() {});
  }

  bool noMatchedLeads = false;

  void _filterLeads(String searchLead) {
    searchLead = searchLead.trim().toLowerCase();

    if (searchLead.isEmpty) {
      setState(() {
        noMatchedLeads = false;
        setState(() {
          allLeads = tempLeadModelList;
        });
      });
    } else {
      List<LeadModel> matched = [];
      List<LeadModel> others = [];

      for (var lead in allLeads) {
        var firstName = lead.firstname?.toLowerCase() ?? '';
        var lastName = lead.lastname?.toLowerCase() ?? '';
        var leadStatus = lead.leadstatus?.toLowerCase() ?? '';

        if (firstName.contains(searchLead) ||
            lastName.contains(searchLead) ||
            leadStatus.contains(searchLead)) {
          matched.add(lead);
        } else {
          // others.add(lead);
        }
      }

      setState(() {
        allLeads = [...matched, ...others];
        noMatchedLeads = matched.isEmpty;
      });
    }
  }

  bool showPin = false;
  bool showBulkBin = false;
  bool isPinned = false;
  String pinnedLeadId = "";

  @override
  Widget build(BuildContext context) {
    unreadCountVm = Provider.of<UnreadCountVm>(context);
    leadlistvm = Provider.of<LeadListViewModel>(context);
    userlistvm = Provider.of<UserDataListViewModel>(context);

    return FocusDetector(
      onFocusGained: () {
        // print("Screen focused again");
        log('\x1B[95mFCM     Leads Screen focused again::::::::::::::::::::::::::::::::::::::::::::::::::');

        connectSocket();
      },
      onFocusLost: () {
        disconnectSocket();
      },
      child: Scaffold(
        backgroundColor: AppColor.pageBgGrey,
        appBar: AppBar(
          actions: [
            Row(
              children: [
                // idsToDelete.isNotEmpty
                //     ? InkWell(
                //         onTap: () {
                //           Map<String, dynamic> body = {"ids": idsToDelete};
                //           print("list to dlete :::  $body");
                //           // Provider.of<LeadListViewModel>(context, listen: false)
                //           //     .deleteBulkLead(body)
                //           //     .then((onValue) {
                //           //    print("onval:::   $onValue");
                //           //    idsToDelete.clear();
                //           // });
                //         },
                //         child: const Icon(
                //           Icons.delete,
                //           color: Colors.white,
                //         ))
                //     : const SizedBox.shrink(),
                showPin
                    // && idsToDelete.length > 1
                    ? Row(
                        children: [
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'view':
                                  showTagDialog(context);
                                  break;
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem<String>(
                                value: 'view',
                                child: Text('View Tags'),
                              ),
                            ],
                            icon: const Icon(
                              Icons.label,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
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
                                idsToDelete.clear();
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
                        ],
                      )
                    : const SizedBox(),
                const SizedBox(
                  width: 10,
                ),
                showPin
                    ? SizedBox()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: CircleAvatar(
                          backgroundColor: AppColor.navBarIconColor,
                          child: IconButton(
                            icon: const Icon(
                              FontAwesomeIcons.add,
                              size: 25,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LeadAddView(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ],
            ),
          ],
          leading: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Color.fromARGB(255, 255, 255, 255)),
              onPressed: () {
                Navigator.pop(context);
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => const FooterNavbarPage()),
                //   (route) => false, // remove all previous routes
                // );
              }),
          automaticallyImplyLeading: false,
          title: const Text(
            'Leads',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          elevation: 5,
        ),
        body: GestureDetector(
          onTap: () {
            setState(() {
              pinnedLeadId = "";
              showPin = false;
              idsToDelete.clear();
              isPinned = false;
            });
          },
          child: RefreshIndicator(onRefresh: _pullRefresh, child: _pageBody()),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      enableDrag: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            _leadfilter.toSet().toList();

            return Container(
              // height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: AppColor.navBarIconColor,
                                borderRadius: BorderRadius.circular(8)),
                            height: 40,
                            width: 350,
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Lead Status Filter',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MultiSelectDialogField<String>(
                              items: [
                                'All',
                                'Working - Contacted',
                                'Open - Not Contacted',
                                'Closed - Converted',
                                'Closed - Not Converted',
                                'Proposal Stage',
                              ]
                                  .map((e) => MultiSelectItem<String>(e, e))
                                  .toList(),
                              title: const Flexible(
                                child: Text(
                                  "Select Leads Status",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              buttonText: const Text("Select Leads Status"),
                              searchable: true,
                              dialogWidth: 300,
                              dialogHeight: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                              ),
                              chipDisplay: MultiSelectChipDisplay.none(),
                              onConfirm: (List<String> selected) {
                                setState(() {
                                  selectleadList = selected;
                                });
                              },
                              initialValue: const [],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8.0,
                              children: selectleadList.map((selectedItem) {
                                return Chip(
                                  label: Text(selectedItem),
                                  deleteIcon: const Icon(Icons.close),
                                  onDeleted: () {
                                    setState(() {
                                      selectleadList.remove(selectedItem);
                                    });
                                  },
                                  backgroundColor: Colors.blue.withOpacity(0.2),
                                  labelStyle:
                                      const TextStyle(color: Colors.blue),
                                );
                              }).toList(),
                            ),
                          ],
                        )),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            selectleadList = [];
                            filterLeads(['All']);
                            Navigator.pop(context);
                            // Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.cardsColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Clear Filters',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            filterLeads(selectleadList);
                            Navigator.pop(context);
                            // Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.cardsColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _marksread(String whatsappNumber) async {
    print("sajdjsahdjsah jhsjhkjdhakj$whatsappNumber");

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
    // Clear all lists first
    leads?.viewModels.clear();
    tempLeadModelList.clear();
    allLeads.clear();
    pinnedLeads.clear();

    await Provider.of<LeadListViewModel>(context, listen: false).fetch();
    await Provider.of<UnreadCountVm>(context, listen: false)
        .fetchunreadcount(number: number);

    getLeadList(showLoading: false);

    isRefresh = true;
    return Future<void>.delayed(const Duration(seconds: 1));
  }

  Widget _pageBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
          child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        pinnedLeadId = "";
                        showPin = false;
                        isPinned = false;
                        idsToDelete.clear();
                      });
                      _showFilterBottomSheet(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 2,
                              spreadRadius: 2,
                              offset: const Offset(1, 1),
                            ),
                          ],
                          color: Colors.white,
                          border: Border.all(color: AppColor.backgroundGrey),
                          borderRadius: BorderRadius.circular(12)),
                      child: Center(
                        child: Stack(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(
                                Icons.filter_list,
                                color: Color.fromARGB(255, 0, 0, 0),
                                size: 20,
                              ),
                            ),
                            selectleadList.isEmpty
                                ? const SizedBox()
                                : Container(
                                    decoration: const BoxDecoration(
                                        color: AppColor.navBarIconColor,
                                        shape: BoxShape.circle),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "${selectleadList.length}",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  )
                          ],
                        ),
                      ),
                    ),
                  )),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 9,
                child: TextField(
                  controller: textController,
                  onChanged: _filterLeads,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search...',
                    hintStyle: TextStyle(
                      color: AppColor.textoriconColor.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColor.navBarIconColor,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                    disabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: AppColor.backgroundGrey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: AppColor.backgroundGrey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.search)),
                  ),
                ),
              ),
            ],
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
                                idsToDelete.clear();
                                isPinned = false;
                              });
                              var num = "";
                              if (model.whatsappNumber!.contains("+")) {
                                num = model.whatsappNumber ?? "";
                              } else {
                                num =
                                    "${model.countryCode}${model.whatsappNumber}";
                              }
                              print(
                                  "model  finalResult=>${model.whatsappNumber}");
                              if (model.whatsappNumber != null) {
                                _marksread(num);

                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WhatsappChatScreen(
                                      pinnedLeads: pinnedLeads,
                                      leadName: model.contactname,
                                      wpnumber: model.full_number,
                                      id: model.id,
                                      model: model,
                                      // contryCode: model.countrycode,
                                    ),
                                  ),
                                ).then((onValue) {
                                  _marksread(num);
                                  _getUnreadCount();
                                });
                                if (result == true) {
                                  print("is result getting true.........?");
                                  _getUnreadCount();
                                  getLeadList();
                                }

                                _getUnreadCount();
                                Provider.of<UnreadCountVm>(context,
                                        listen: false)
                                    .fetchunreadcount(number: number ?? "");
                                setState(() {
                                  // unreadMsgCount = "0";
                                  // unreadMsgCount = "";
                                });
                                // print("unreadMsgCount====${unreadMsgCount}  ");

                                leads?.viewModels.clear();
                                Provider.of<LeadListViewModel>(context,
                                        listen: false)
                                    .fetch();
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
        ///////////////////////////////////////////////////////////////////
        allLeads.isEmpty
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${allLeads.length} Leads Available",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.left,
                ),
              ),
        Expanded(
          child: updateLoader
              ? const Center(
                  child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator()))
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 55,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: filters.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedFilterId = index;
                                        pinnedLeadId = "";
                                        showPin = false;
                                        idsToDelete.clear();
                                        isPinned = false;
                                      });
                                      if (index == 1) {
                                        unreadChatFilter();
                                      } else if (index == 0) {
                                        setState(() {
                                          print(
                                              "tempLeadModelList::::::::::: $tempLeadModelList");
                                          allLeads = tempLeadModelList;
                                        });
                                      } else {
                                        showModalBottomSheet(
                                          context: context,
                                          useSafeArea: true,
                                          isScrollControlled: true,
                                          enableDrag: false,
                                          builder: (context) {
                                            String selectedOption = 'AND';
                                            return StatefulBuilder(
                                              builder: (BuildContext context,
                                                  StateSetter setState) {
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
                                                            .viewInsets
                                                            .bottom,
                                                  ),
                                                  child: ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                      maxHeight:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.85,
                                                    ),
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(15.0),
                                                            child: Row(
                                                              children: [
                                                                const Text(
                                                                  "Filter Tags",
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        AppFonts
                                                                            .bold,
                                                                    fontSize:
                                                                        17,
                                                                  ),
                                                                ),
                                                                const Spacer(),
                                                                IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .close_rounded),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const Divider(),
                                                          Row(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Radio<String>(
                                                                    value:
                                                                        'AND',
                                                                    groupValue:
                                                                        selectedOption,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        selectedOption =
                                                                            value!;
                                                                      });
                                                                    },
                                                                  ),
                                                                  const Text(
                                                                      'AND'),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                  width: 20),
                                                              Row(
                                                                children: [
                                                                  Radio<String>(
                                                                    value: 'OR',
                                                                    groupValue:
                                                                        selectedOption,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        selectedOption =
                                                                            value!;
                                                                      });
                                                                    },
                                                                  ),
                                                                  const Text(
                                                                      'OR'),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          LayoutBuilder(
                                                            builder: (context,
                                                                constraints) {
                                                              return SingleChildScrollView(
                                                                child: Wrap(
                                                                  spacing: 8.0,
                                                                  runSpacing:
                                                                      8.0,
                                                                  children: tags
                                                                      .map(
                                                                          (tag) {
                                                                    return InkWell(
                                                                      onTap:
                                                                          () {
                                                                        if (selectTagFilterList
                                                                            .contains(tag)) {
                                                                          selectTagFilterList
                                                                              .remove(tag);
                                                                        } else {
                                                                          selectTagFilterList
                                                                              .add(tag);
                                                                        }
                                                                        setState(
                                                                            () {
                                                                          pinnedLeadId =
                                                                              "";
                                                                          showPin =
                                                                              false;
                                                                          idsToDelete
                                                                              .clear();
                                                                          isPinned =
                                                                              false;
                                                                        });
                                                                      },
                                                                      child:
                                                                          Chip(
                                                                        label: Text(
                                                                            tag),
                                                                        backgroundColor: Colors
                                                                            .blue
                                                                            .withOpacity(0.2),
                                                                        labelStyle:
                                                                            const TextStyle(color: Colors.blue),
                                                                        side:
                                                                            BorderSide(
                                                                          color: selectTagFilterList.contains(tag)
                                                                              ? Colors.black
                                                                              : Colors.transparent,
                                                                          width: selectTagFilterList.contains(tag)
                                                                              ? 2
                                                                              : 0,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          const SizedBox(
                                                              height: 20),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(15.0),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      allLeads =
                                                                          tempLeadModelList;
                                                                      selectTagFilterList
                                                                          .clear();
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      color: AppColor
                                                                          .navBarIconColor,
                                                                    ),
                                                                    child:
                                                                        const Center(
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            EdgeInsets.symmetric(
                                                                          vertical:
                                                                              10.0,
                                                                          horizontal:
                                                                              20,
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          "Clear",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 20),
                                                                InkWell(
                                                                  onTap: () {
                                                                    tagBasedFilter(
                                                                        selectedOption);
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      color: AppColor
                                                                          .navBarIconColor,
                                                                    ),
                                                                    child:
                                                                        const Center(
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            EdgeInsets.symmetric(
                                                                          vertical:
                                                                              10.0,
                                                                          horizontal:
                                                                              20,
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          "Apply",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0, vertical: 4.0),
                                        decoration: BoxDecoration(
                                          // color: const Color.fromARGB(
                                          //     255, 179, 238, 243),
                                          border: Border.all(
                                              color: selectedFilterId == index
                                                  ? Colors.black
                                                  : Colors.transparent,
                                              width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        child: Center(
                                            child: Text(
                                          filters[index],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const Divider(),
                            noMatchedLeads || noRecordFound
                                ? const Center(
                                    child: Text(
                                      "No Record Found",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  )
                                : allLeads.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.only(top: 28.0),
                                        child: Center(
                                          child: Text(
                                            "No Leads Available..",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 2.0, left: 6, right: 6),
                                          child: ListView.builder(
                                            itemCount: allLeads.length,
                                            itemBuilder: (context, index) {
                                              var unreadCount = "0";
                                              var lead = allLeads[index];

                                              for (var p in unreadList) {
                                                if (p.whatsappNumber
                                                    .toString()
                                                    .contains(
                                                        lead.whatsappNumber)) {
                                                  unreadCount =
                                                      p.unreadMsgCount;
                                                  break;
                                                }
                                              }

                                              return leadRecordList(
                                                  lead, unreadCount);
                                            },
                                          ),
                                        ),
                                      ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget leadRecordList(LeadModel model, String unreadMsgCount) {
    Color statusColor;
    switch (model.leadstatus) {
      case 'Contacted':
        statusColor = const Color.fromARGB(255, 46, 198, 69);
        break;
      case 'Open - Not Contacted && Working - Contacted':
        statusColor = Colors.lightBlue.withOpacity(0.7);
        break;
      case 'Closed - Converted && Closed - Not Converted':
        statusColor = AppColor.motivationCar1Color;
        break;
      default:
        statusColor = Colors.lightBlue.withOpacity(0.7);
        break;
    }

    String formatPhoneNumber(String? phoneNumber, String? countryCode) {
      if (phoneNumber == null || phoneNumber.isEmpty) return '';

      String fullNumber = phoneNumber.contains("+")
          ? phoneNumber
          : "${countryCode ?? ''}$phoneNumber";

      if (shouldHideLeadNumber == true && fullNumber.length > 5) {
        int totalLength = fullNumber.length;
        String lastFiveDigits = fullNumber.substring(totalLength - 5);
        String maskedPart = 'X' * (totalLength - 5);
        return '$maskedPart$lastFiveDigits';
      } else {
        return fullNumber;
      }
    }

    return GestureDetector(
      onLongPress: () {
        setState(() {
          selectedLead = model;
          showPin = true;
          showBulkBin = true;
          addToDeleteList(model.lead_id ?? "");
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
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
          child: InkWell(
            onTap: () async {
              setState(() {
                pinnedLeadId = "";
                showPin = false;
                idsToDelete.clear();
                isPinned = false;
              });
              var num = "";
              if (model.whatsappNumber!.contains("+")) {
                num = model.whatsappNumber ?? "";
              } else {
                num = "${model.countryCode}${model.whatsappNumber}";
              }
              print("model  finalResult=>${model.whatsappNumber}");
              if (model.whatsappNumber != null) {
                _marksread(num);

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WhatsappChatScreen(
                      pinnedLeads: pinnedLeads,
                      leadName: (model.contactname != null &&
                              model.contactname!.isNotEmpty)
                          ? '${model.contactname}'
                          : "No Name Available",
                      wpnumber: model.full_number,
                      id: model.id,
                      model: model,
                    ),
                  ),
                ).then((onValue) {
                  _marksread(num);
                  _getUnreadCount();
                });
                if (result == true) {
                  print("is result getting true.........?");
                  _getUnreadCount();
                  getLeadList();
                }

                _getUnreadCount();
                Provider.of<UnreadCountVm>(context, listen: false)
                    .fetchunreadcount(number: number ?? "");
                setState(() {
                  unreadMsgCount = "0";
                  unreadMsgCount = "";
                });
                print("unreadMsgCount====$unreadMsgCount  ");

                leads?.viewModels.clear();
                Provider.of<LeadListViewModel>(context, listen: false).fetch();
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
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColor.navBarIconColor,
                      child: Text(
                        model.firstname?.isNotEmpty == true
                            ? model.firstname![0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${model.firstname?.isNotEmpty == true ? model.firstname : 'No Phone Number'} ${model.lastname?.isNotEmpty == true ? model.lastname : ''}",
                          style: const TextStyle(
                              fontSize: 15, fontFamily: AppFonts.semiBold),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          formatPhoneNumber(
                              model.whatsappNumber, model.countryCode),
                          style: const TextStyle(fontSize: 12),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Text(
                            "${model.leadstatus?.isNotEmpty == true ? model.leadstatus : ''}",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColor.navBarIconColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                  // Arrow and Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          if (unreadMsgCount != "0" &&
                              unreadMsgCount.isNotEmpty)
                            badges.Badge(
                              badgeStyle: const badges.BadgeStyle(
                                badgeColor: Colors.green,
                              ),
                              badgeContent: Text(
                                unreadMsgCount,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          const Icon(Icons.arrow_circle_right_outlined),
                          model.pinned ?? false
                              ? const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Icon(
                                    Icons.push_pin,
                                    color: Colors.black54,
                                    size: 16,
                                  ),
                                )
                              : const SizedBox()
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool noRecordFound = false;

  tagBasedFilter(String selOption) {
    List filteredLeads = [];

    // Always use tempLeadModelList as source
    if (selectTagFilterList.isEmpty) {
      filteredLeads = List.from(tempLeadModelList);
    } else {
      if (selOption == "AND") {
        filteredLeads = tempLeadModelList.where((lead) {
          final leadTagNames = lead.tagNames.map((tag) => tag.name).toSet();
          return selectTagFilterList.every(
            (tagName) => leadTagNames.contains(tagName),
          );
        }).toList();
      } else if (selOption == "OR") {
        filteredLeads = tempLeadModelList.where((lead) {
          final leadTagNames =
              lead.tagNames.map((tag) => tag.name.toLowerCase()).toSet();
          return selectTagFilterList
              .map((e) => e.toLowerCase())
              .any((tagName) => leadTagNames.contains(tagName));
        }).toList();
      }
    }

    // Remove duplicates
    var uniqueFilteredLeads = filteredLeads
        .fold<Map<String, dynamic>>({}, (map, lead) {
          if (!map.containsKey(lead.id)) {
            map[lead.id] = lead;
          }
          return map;
        })
        .values
        .toList();

    allLeads.clear();
    allLeads.addAll(uniqueFilteredLeads);

    setState(() {});
  }

  filterLeads(List filter) {
    print("tempLeadModelList:: $filter ::::::: $tempLeadModelList ");

    print("filter.contains('All'):::::::: ${filter.contains('All')}");
    if (filter.isEmpty || filter.contains('All')) {
      print("backupListModel:::: $backupListModel");

      setState(() {
        noRecordFound = false;
        allLeads.clear();
        allLeads.addAll(backupListModel);
      });
      return;
    }

    List<dynamic> matchleads = tempLeadModelList.where((lead) {
      return filter
          .map((e) => e.toLowerCase())
          .contains(lead.leadstatus?.toLowerCase());
    }).toList();

    // Remove duplicates
    var uniqueMatchleads = matchleads
        .fold<Map<String, dynamic>>({}, (map, lead) {
          if (!map.containsKey(lead.id)) {
            map[lead.id] = lead;
          }
          return map;
        })
        .values
        .toList();

    allLeads.clear();
    allLeads.addAll(uniqueMatchleads);

    setState(() {
      noRecordFound = uniqueMatchleads.isEmpty;
    });
  }

  bool updateLoader = false;
  Future<void> getLeadList({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        updateLoader = true;
      });
    }

    // CLEAR LISTS FIRST
    tempLeadModelList.clear();
    allLeads.clear();
    // backupListModel.clear();
    pinnedLeads.clear();

    await Provider.of<LeadListViewModel>(context, listen: false)
        .fetch()
        .then((onValue) {
      for (var viewModel in leadlistvm.viewModels) {
        var leadmodel = viewModel.model;
        if (leadmodel?.records != null) {
          for (var record in leadmodel!.records!) {
            if (!tempLeadModelList.any((item) => item.id == record.id)) {
              tempLeadModelList.add(record);
            }
            backupListModel = tempLeadModelList;

            if (!allLeads.any((item) => item.id == record.id)) {
              allLeads.add(record);
            }

            if (record.pinned &&
                !pinnedLeads.any((item) => item.id == record.id)) {
              pinnedLeads.add(record);
            }
          }
        }
      }

      setState(() {
        updateLoader = false;
      });
    });

    setState(() {
      updateLoader = false;
    });
  }

  unreadChatFilter() {
    List prioritizedLeads = [];
    List otherLeads = [];

    for (var lead in allLeads) {
      bool hasUnread = unreadList.any(
        (unread) =>
            unread.whatsappNumber.toString().contains(lead.whatsappNumber),
      );

      if (hasUnread) {
        prioritizedLeads.add(lead);
      } else {
        otherLeads.add(lead);
      }
    }
    print("prioritizedLeads:::::::::  $prioritizedLeads");
    print("otherLeads:::::::::  $otherLeads");

    allLeads = [
      ...prioritizedLeads,
    ];
    setState(() {});
  }

  List<TagRecord> tagsNameSet = [];
  Future<void> getTags() async {
    await Provider.of<LeadListViewModel>(context, listen: false)
        .fetchLeadTags()
        .then((onValue) {
      tags = [];
      leadlistvm = Provider.of<LeadListViewModel>(context, listen: false);

      tags.clear();

      for (var viewModel in leadlistvm.viewModels) {
        var leadmodel = viewModel.model;
        if (leadmodel?.records != null) {
          for (var record in leadmodel!.records!) {
            tagsNameSet.add(record);

            if (!tags.contains(record.name)) {
              print("tags record name::: ${record.name}");
              tags.add(record.name);
            }
          }
        }
      }

      //   }
      setState(() {});
    });
  }

  void addToDeleteList(String leadId) {
    if (idsToDelete.contains(leadId)) {
      idsToDelete.remove(leadId);
    } else {
      idsToDelete.add(leadId);
    }
    setState(() {});
  }

  Future<void> connectSocket() async {
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    LeadController leadCtrl = Provider.of(context, listen: false);

    String tkn = await AppUtils.getToken() ?? "";
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
        print('Connected to WebSocket Leadlist');
        socket!.emit("setup", userId);
      });
      socket!.on("connected", (_) {
        // print(" WebSocket setup complete");
      });

      socket!.on("receivedwhatsappmessage", (data) {
        print(" New WhatsApp message: $data");
        _getUnreadCount();
      });

      socket!.onDisconnect((_) {
        // print(" WebSocket Disconnected");
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
      print(" WebSocket Disconnected");
    }
  }

  Future<void> shouldHide() async {
    final prefs = await SharedPreferences.getInstance();
    shouldHideLeadNumber = prefs.getBool(SharedPrefsConstants.shouldHideNumber);
    setState(() {});
  }

  LeadModel? selectedLead;
  void showTagDialog(BuildContext context) {
    final tags = selectedLead?.tagNames ?? [];
    final hasTags = tags.isNotEmpty;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 24,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasTags
                            ? 'Tags (${tags.length} ${tags.length == 1 ? 'tag' : 'tags'})'
                            : 'Tags ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                if (!hasTags)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.label_off_rounded,
                            color: Colors.grey.shade400,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No tags added',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.3,
                        ),
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: tags.map((tag) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.blue.shade600.withOpacity(0.1),
                                  border: Border.all(
                                    color:
                                        Colors.blue.shade600.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.label_rounded,
                                        color: Colors.blue.shade600,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        tag.name ?? '-',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade800,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
