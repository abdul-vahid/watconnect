import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:whatsapp/main.dart';
import 'package:whatsapp/models/recent_chat_model.dart';
import 'package:whatsapp/models/unread_msg_model/unread_msg_model.dart';
import 'package:whatsapp/view_models/unread_count_vm.dart';
import 'package:whatsapp/views/view/whatsapp_message_view.dart';
import '../../models/lead_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_utils.dart';
import '../../view_models/lead_list_vm.dart';
import '../../view_models/user_data_list_vm.dart';
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
  var userId;
  String leadId = "lead_456";
  String phNum = "+919876543210";
  final List<String> _leadfilter = [];
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
  List unreadList = [];
  String? number;
  @override
  void initState() {
    // _marksread();
    _getUnreadCount();
    getLeadList();
    super.initState();
    connectSocket();
  }

  @override
  void dispose() {
    disconnectSocket();

    super.dispose();
  }

  bool noMatchedLeads = false;
  List matched = [];
  List others = [];
  Future<void> _getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    number = prefs.getString('phoneNumber');

    if (!mounted) return;
    Provider.of<LeadListViewModel>(context, listen: false).fetch();
    await Provider.of<UnreadCountVm>(context, listen: false)
        .fetchunreadcount(number: number ?? "");

    var unreadMsgModel;
    print(" unreadCountVm?.viewModels ::: ${unreadCountVm?.viewModels}");
    for (var unreadModel in unreadCountVm?.viewModels ?? []) {
      unreadMsgModel = unreadModel.model as UnreadMsgModel;
    }
    unreadList = unreadMsgModel.records ?? [];
    setState(() {});
  }

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
        } else {
          otherLeads.add(lead);
        }
      }

      allRecentChats = [...prioritizedLeads, ...otherLeads];

      setState(() {});
      // setState(() {
      //   allLeads = List.from(originalAllLeads); // restore original
      // });
    } else {
      for (var lead in tempLeadModelList) {
        var firstName = lead.contactname?.toLowerCase() ?? '';

        if (firstName.contains(searchLead)) {
          matched.add(lead);
        } else {
          others.add(lead);
        }
      }

      setState(() {
        allRecentChats = [...matched, ...others];
        noMatchedLeads = matched.isEmpty ? true : false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (leadlistvm != null) {
    //   for (var viewModel in leadlistvm!.viewModels) {
    //     _leadfilter.add(viewModel.model.leadstatus);
    //   }
    // }

    unreadCountVm = Provider.of<UnreadCountVm>(context);
    leadlistvm = Provider.of<LeadListViewModel>(context);
    // userlistvm = Provider.of<UserDataListViewModel>(context);

    // print("unreadCountVm::: ${unreadCountVm?.viewModels[0].toString()}");

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Recent Chats',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 5,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(30),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Color.fromARGB(255, 0, 0, 0),
                      size: 20,
                    ),
                    onPressed: () {
                      // _showFilterBottomSheet(context);
                    },
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 40),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: AppUtils.getAppBody(leadlistvm, _pageBody),
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
              height: 220,
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

                    // Payment Term Dropdown
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        hint: const Text('Select Leads Status'),
                        items: [
                          DropdownMenuItem(
                            value: 'Working - Contacted',
                            child: Text('Working - Contacted'),
                          ),
                          DropdownMenuItem(
                            value: 'Open - Not Contacted',
                            child: Text('Open - Not Contacted'),
                          ),
                          DropdownMenuItem(
                            value: 'Closed - Converted',
                            child: Text('Closed - Converted'),
                          ),
                          DropdownMenuItem(
                            value: 'Closed - Not Converted',
                            child: Text('Closed - Not Converted'),
                          ),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            selectlead = newValue;
                          });
                        },
                        value: selectlead,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            filterLeads(selectlead);
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

    if (number != null) {
      Map<String, String>? bodydata = {"whatsapp_number": whatsappNumber};

      var response = await Provider.of<UnreadCountVm>(context, listen: false)
          .marksreadcountmsg(
        leadnumber: whatsappNumber,
        number: number,
        bodydata: bodydata,
      );
    }
    return null;
  }

  Future<void> _pullRefresh() async {
    leads?.viewModels.clear();

    Provider.of<LeadListViewModel>(context, listen: false).fetchRecentChat();

    Provider.of<UnreadCountVm>(context, listen: false)
        .fetchunreadcount(number: number);
    getLeadList();
    isRefresh = true;
    return Future<void>.delayed(const Duration(seconds: 1));
  }

  Widget _pageBody() {
    return Column(
      children: [
        allRecentChats.isEmpty
            ? Center(
                child: Text(
                "No Chat Found..",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ))
            // : noMatchedLeads || noRecordFound
            //     ? Center(
            //         child: Text(
            //         "No Chat Found..",
            //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            //       ))
            : Expanded(
                child: ListView.builder(
                itemCount: allRecentChats.length,
                itemBuilder: (context, index) {
                  var unreadCount = "0";
                  var lead = allRecentChats[index];

                  for (var p in unreadList) {
                    if (lead.full_number
                        .toString()
                        .contains(p.whatsappNumber)) {
                      unreadCount = p.unreadMsgCount;
                      break;
                    }
                  }

                  return leadRecordList(lead, unreadCount);
                },
              ))
      ],
    );
  }

  Widget leadRecordList(Records model, String unreadMsgCount) {
    Color statusColor;
    statusColor = Colors.lightBlue.withOpacity(0.7);
    // switch (model.leadstatus) {
    //   case 'Contacted':
    //     statusColor = const Color.fromARGB(255, 46, 198, 69);
    //     break;
    //   case 'Open - Not Contacted && Working - Contacted':
    //     statusColor = Colors.lightBlue.withOpacity(0.7);
    //     break;
    //   case 'Closed - Converted && Closed - Not Converted':
    //     statusColor = AppColor.motivationCar1Color;
    //     break;
    //   default:
    //     statusColor = Colors.lightBlue.withOpacity(0.7);
    //     break;
    // }

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
          // onTap: () {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => LeadDetailView(

          //       ),
          //     ),
          //   );
          // },
          onTap: () {
            if (model.full_number != null) {
              _marksread(model.full_number ?? "");

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    leadName: model.contactname ?? "",
                    wpnumber: model.full_number,
                    id: model.id,
                  ),
                ),
              ).then((_) {
                _getUnreadCount();
                // Provider.of<UnreadCountVm>(context, listen: false)
                //     .fetchunreadcount(number: number ?? "");
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
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColor.navBarIconColor,
                child: Text(
                  "${model.contactname?.isNotEmpty == true ? model.contactname![0].toUpperCase() : '?'}",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${model.contactname}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${model.full_number}",
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
              // Arrow and Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (unreadMsgCount != "0" && unreadMsgCount.isNotEmpty)
                    badges.Badge(
                      badgeStyle: badges.BadgeStyle(
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
                ],
              ),
            ],
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
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    String tkn = await AppUtils.getToken() ?? "";
    Map<String, dynamic> decodedToken = JwtDecoder.decode(tkn);

    token = tkn;
    phNum = number ?? "";
    userId = decodedToken;

    try {
      print("Token: $token");

      socket = IO.io(
        'https://sandbox.watconnect.com',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setPath('/swp/socket.io')
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .build(),
      );
      socket!.connect();
      socket!.onConnect((_) {
        print('Connected to WebSocket');
        socket!.emit("setup", userId);
      });
      socket!.on("connected", (_) {
        // print(" WebSocket setup complete");
      });

      socket!.on("receivedwhatsappmessage", (data) {
        print(" New WhatsApp message: $data");
        getLeadList();
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
      print(" WebSocket Disconnected");
    }
  }

  Future<void> getLeadList() async {
    print("getLeadList:::getLeadList{}4");
    await Provider.of<LeadListViewModel>(navigatorKey.currentContext!,
            listen: false)
        .fetchRecentChat()
        .then((onValue) {
      print(
          " dbfjsdlvdsl}::: }  ${leadlistvm.viewModels}   ${leadlistvm.viewModels.runtimeType}   ${leadlistvm.viewModels.length} ");
      allRecentChats = [];
      try {
        for (var viewModel in leadlistvm.viewModels) {
          var recentMsgmodel = viewModel.model;
          if (recentMsgmodel?.records != null) {
            for (var record in recentMsgmodel!.records!) {
              print("record::: ${record}");
              allRecentChats.add(record);
              tempLeadModelList.add(record);
            }
          }
        }
      } catch (e) {
        print("e:::::::: ${e}");
        allRecentChats = [];
      }
      // setState(() {});

      print(" dbfjsdlvdsl${allRecentChats}");
    });
  }
}
