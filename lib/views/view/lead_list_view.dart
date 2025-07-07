import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:whatsapp/main.dart';
import 'package:whatsapp/models/tags_list_model.dart';
import 'package:whatsapp/models/unread_msg_model/unread_msg_model.dart';
import 'package:whatsapp/salesforce/screens/sf_dashboard.dart';
import 'package:whatsapp/utils/app_fonts.dart';
import 'package:whatsapp/view_models/unread_count_vm.dart';
import 'package:whatsapp/views/view/whatsapp_message_view.dart';
import '../../models/lead_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_utils.dart';
import '../../view_models/lead_list_vm.dart';
import '../../view_models/user_data_list_vm.dart';
import 'lead_add_update_view.dart';

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

  List leadModelList = [];
  List tempLeadModelList = [];
  UnreadCountVm? unreadCountVm;

  LeadListViewModel? leads;
  String? selectlead;
  String? selectuser;
  bool isRefresh = false;
  int countunread = 0;
  List allLeads = [];
  List unreadList = [];
  List<String> selectleadList = [];
  List<String> selectTagFilterList = [];

  String? number;

  int selectedFilterId = 0;
  List<String> filters = ["All", "Unread", "Filter"];
  List<String> tags = [];
  @override
  void initState() {
    selectleadList = [];
    getTags();
    _getUnreadCount();
    selectTagFilterList = [];
    getLeadList();
    // connectSocket();
    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   routeObserver.subscribe(this, ModalRoute.of(context)!);
  // }

  @override
  void dispose() {
    // disconnectSocket();
    // routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when coming back to this screen
    // connectSocket();
  }

  Future<void> _getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    number = prefs.getString('phoneNumber');

    if (!mounted) return;
    Provider.of<LeadListViewModel>(context, listen: false).fetch();
    await Provider.of<UnreadCountVm>(context, listen: false)
        .fetchunreadcount(number: number ?? "");

    var unreadMsgModel;
    for (var unreadModel in unreadCountVm?.viewModels ?? []) {
      unreadMsgModel = unreadModel.model as UnreadMsgModel;
    }
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
            Padding(
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
          leading: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Color.fromARGB(255, 255, 255, 255)),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FooterNavbarPage()),
                  (route) => false, // remove all previous routes
                );
              }),
          automaticallyImplyLeading: false,
          title: const Text(
            'Leads',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          elevation: 5,
        ),
        body: RefreshIndicator(onRefresh: _pullRefresh, child: _pageBody()
            //  AppUtils.getAppBody(leadlistvm!, _pageBody),
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
            List<String> uniquePaymentTerms = _leadfilter.toSet().toList();

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
                              onConfirm: (List<String> selected) {
                                setState(() {
                                  // Update selectleadList with the confirmed selections
                                  selectleadList = selected;
                                });
                              },
                              initialValue: [],
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
    print("sajdjsahdjsah jhsjhkjdhakj${whatsappNumber}");

    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    Map<String, String>? bodydata = {"whatsapp_number": whatsappNumber};

    var response = await Provider.of<UnreadCountVm>(context, listen: false)
        .marksreadcountmsg(
      leadnumber: whatsappNumber,
      number: number,
      bodydata: bodydata,
    );
    return null;
  }

  Future<void> _pullRefresh() async {
    leads?.viewModels.clear();

    Provider.of<LeadListViewModel>(context, listen: false).fetch();

    Provider.of<UnreadCountVm>(context, listen: false)
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
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
          child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () {
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
                  });
                  if (index == 1) {
                    unreadChatFilter();
                  } else if (index == 0) {
                    setState(() {
                      allLeads = tempLeadModelList;
                    });
                  } else {
                    showModalBottomSheet(
                        context: context,
                        useSafeArea: true,
                        isScrollControlled: true,
                        enableDrag: false,
                        builder: (context) {
                          String _selectedOption = 'AND';
                          return StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState) {
                            return Container(
                              height: MediaQuery.of(context).size.height * .45,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Row(
                                      children: [
                                        const Text(
                                          "Filter Tags",
                                          style: TextStyle(
                                              fontFamily: AppFonts.bold,
                                              fontSize: 17),
                                        ),
                                        Spacer(),
                                        IconButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            icon:
                                                const Icon(Icons.close_rounded))
                                      ],
                                    ),
                                  ),
                                  Divider(),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'AND',
                                            groupValue: _selectedOption,
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedOption = value!;
                                              });
                                            },
                                          ),
                                          const Text('AND'),
                                        ],
                                      ),
                                      const SizedBox(width: 20),
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'OR',
                                            groupValue: _selectedOption,
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedOption = value!;
                                              });
                                            },
                                          ),
                                          const Text('OR'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Wrap(
                                    spacing: 8.0,
                                    children: tags.map((tag) {
                                      return InkWell(
                                        onTap: () {
                                          if (selectTagFilterList
                                              .contains(tag)) {
                                            selectTagFilterList.remove(tag);
                                          } else {
                                            selectTagFilterList.add(tag);
                                          }
                                          setState(() {});
                                        },
                                        child: Chip(
                                          label: Text(tag),
                                          backgroundColor:
                                              Colors.blue.withOpacity(0.2),
                                          labelStyle: const TextStyle(
                                              color: Colors.blue),
                                          side: BorderSide(
                                              color: selectTagFilterList
                                                      .contains(tag)
                                                  ? Colors.black
                                                  : Colors.transparent,
                                              width: selectTagFilterList
                                                      .contains(tag)
                                                  ? 2
                                                  : 0),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              allLeads = tempLeadModelList;
                                              selectTagFilterList.clear();
                                            });

                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color:
                                                    AppColor.navBarIconColor),
                                            child: const Center(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10.0,
                                                    horizontal: 20),
                                                child: Text(
                                                  "Clear",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            // 1. Perform filtering (synchronously)

                                            tagBasedFilter(_selectedOption);
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color:
                                                    AppColor.navBarIconColor),
                                            child: const Center(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10.0,
                                                    horizontal: 20),
                                                child: Text(
                                                  "Apply",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          });
                        });
                    // getTagBasedList(tags[index]);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 179, 238, 243),
                      border: Border.all(
                          color: selectedFilterId == index
                              ? Colors.black
                              : Colors.transparent,
                          width: 1.5),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                        child: Text(
                      filters[index],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ),
                ),
              );
            },
          ),
        ),
        allLeads.isEmpty
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${allLeads.length} Leads Available",
                  style: TextStyle(fontWeight: FontWeight.w600),
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
              : noMatchedLeads || noRecordFound
                  ? const Center(
                      child: Text(
                        "No Record Found",
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  : allLeads.isEmpty
                      ? const Center(
                          child: Text(
                            "No Leads Available..",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
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
                                  padding: const EdgeInsets.only(
                                      top: 22.0, left: 6, right: 6),
                                  child: ListView.builder(
                                    itemCount: allLeads.length,
                                    itemBuilder: (context, index) {
                                      var unreadCount = "0";
                                      var lead = allLeads[index];

                                      for (var p in unreadList) {
                                        if (p.whatsappNumber
                                            .toString()
                                            .contains(lead.whatsappNumber)) {
                                          unreadCount = p.unreadMsgCount;
                                          break;
                                        }
                                      }

                                      return leadRecordList(lead, unreadCount);
                                    },
                                  ),
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
        // ignore: deprecated_member_use
        statusColor = Colors.lightBlue.withOpacity(0.7);
        break;
      case 'Closed - Converted && Closed - Not Converted':
        statusColor = AppColor.motivationCar1Color;
        break;
      default:
        // ignore: deprecated_member_use
        statusColor = Colors.lightBlue.withOpacity(0.7);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: statusColor,
            width: 5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
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
            // print("model=>${model.toMap()}");
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
                  builder: (context) => ChatScreen(
                    leadName: (model.firstname != null &&
                            model.firstname!.isNotEmpty)
                        ? '${model.firstname} ${model.lastname ?? ""}'
                        : (model.lastname != null && model.lastname!.isNotEmpty)
                            ? model.lastname!
                            : "No Name Available",
                    wpnumber: model.whatsappNumber!.contains("+")
                        ? model.whatsappNumber ?? ""
                        : "${model.countryCode}${model.whatsappNumber ?? ""}",
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
              print("unreadMsgCount====${unreadMsgCount}  ");

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
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => LeadDetailView(
                  //       model: model,
                  //     ),
                  //   ),
                  // );
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColor.navBarIconColor,
                  child: Text(
                    "${model.firstname?.isNotEmpty == true ? model.firstname![0].toUpperCase() : '?'}",
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      model.whatsappNumber?.isNotEmpty == true
                          ? model.whatsappNumber!.contains("+")
                              ? model.whatsappNumber ?? ""
                              : "${model.countryCode}${model.whatsappNumber ?? ""}"
                          : '',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      "${model.email?.isNotEmpty == true ? model.email : ''}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.lightBlue.withOpacity(0.7),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8),
                        child: Text(
                          "${model.leadstatus?.isNotEmpty == true ? model.leadstatus : ''}",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
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
                      if (unreadMsgCount != "0" && unreadMsgCount.isNotEmpty)
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
                      const Icon(Icons.arrow_circle_right_outlined)
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool noRecordFound = false;

  tagBasedFilter(String selOption) {
    List filteredLeads = [];

    if (selectTagFilterList.isEmpty) {
      filteredLeads = tempLeadModelList;
    } else if (selOption == "AND") {
      filteredLeads = tempLeadModelList.where((lead) {
        final leadTagNames = lead.tagNames.map((tag) => tag.name).toSet();
        return leadTagNames.every(
          (tagName) => selectTagFilterList.contains(tagName),
        );
      }).toList();
    } else if (selOption == "OR") {
      filteredLeads = tempLeadModelList.where((lead) {
        final leadTagNames = lead.tagNames.map((tag) => tag.name).toSet();
        return leadTagNames.any(
          (tagName) => selectTagFilterList.contains(tagName),
        );
      }).toList();
    }

    setState(() {
      allLeads.clear();
      allLeads = filteredLeads;
    });
  }

  filterLeads(List filter) {
    print("filter::: ${filter}");
    print("empty :::  ${tempLeadModelList.length}");
    leadModelList = tempLeadModelList;
    if (filter.isEmpty) {
      leadModelList = tempLeadModelList;
      allLeads = tempLeadModelList;
      setState(() {
        allLeads = tempLeadModelList;
        noRecordFound = false;
      });
    }

    if (filter.contains('All')) {
      print("it was here in all ");

      setState(() {
        allLeads = tempLeadModelList;
        noRecordFound = false;
      });
    } else {
      List<dynamic> matchleads = leadModelList.where((lead) {
        return filter
            .map((e) => e.toLowerCase())
            .contains(lead.leadstatus?.toLowerCase());
      }).toList();

      setState(() {
        allLeads = matchleads;
        noRecordFound = matchleads.isEmpty;
      });

      print("tempLeadModelList:::::::::::::  ${tempLeadModelList.length}");
      print("matchleadsmatchleads${matchleads}");
    }
  }

  Future<void> connectSocket() async {
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    String tkn = await AppUtils.getToken() ?? "";
    Map<String, dynamic> decodedToken = JwtDecoder.decode(tkn);

    token = tkn;
    phNum = number ?? "";
    userId = decodedToken;

    try {
      // print("Token: $token");

      socket = IO.io(
        'https://admin.watconnect.com',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setPath('/swp/socket.io')
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

  bool updateLoader = false;
  Future<void> getLeadList() async {
    setState(() {
      updateLoader = true;
    });
    await Provider.of<LeadListViewModel>(context, listen: false)
        .fetch()
        .then((onValue) {
      allLeads = [];
      print(
          " leadlistvm.viewModels:::::::::::::::::: ${leadlistvm.viewModels}");
      for (var viewModel in leadlistvm.viewModels) {
        var leadmodel = viewModel.model;
        if (leadmodel?.records != null) {
          for (var record in leadmodel!.records!) {
            tempLeadModelList.add(record);
            allLeads.add(record);
          }
        }
      }

      setState(() {
        updateLoader = false;
      });
      setState(() {});
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
    print("prioritizedLeads:::::::::  ${prioritizedLeads}");
    print("otherLeads:::::::::  ${otherLeads}");

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

      tags.clear(); // Clear if it's reused

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

  // void getTagBasedList(String tg) {
  //   if (tg == "All") {
  //     allLeads = List.from(tempLeadModelList);
  //   } else if (tg == "Unread") {
  //     allLeads = tempLeadModelList
  //         .where((lead) => lead.isUnread == true)
  //         .toList(); // Assuming such a field
  //   } else {
  //     allLeads = tempLeadModelList.where((lead) {
  //       return lead.tagNames.any((tag) => tag.name == tg);
  //     }).toList();
  //   }
  // }
}
