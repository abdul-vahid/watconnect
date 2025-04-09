import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:whatsapp/models/unread_msg_model/unread_msg_model.dart';
import 'package:whatsapp/view_models/unread_count_vm.dart';
import 'package:whatsapp/views/view/whatsapp_message_view.dart';
import '../../models/lead_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_utils.dart';
import '../../view_models/lead_list_vm.dart';
import '../../view_models/user_data_list_vm.dart';
import 'lead_add_update_view.dart';
import 'lead_detail_view.dart';
import 'package:badges/badges.dart' as badges;

class LeadListView extends StatefulWidget {
  const LeadListView({super.key});
  @override
  State<LeadListView> createState() => _LeadListViewState();
}

class _LeadListViewState extends State<LeadListView> {
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
  List<LeadModel> leadModelList = [];
  List<LeadModel> tempLeadModelList = [];
  UnreadCountVm? unreadCountVm;
  // List<UnreadCountMsgModel> unreadModel = [];
  LeadListViewModel? leads;
  String? selectlead;
  String? selectuser;
  bool isRefresh = false;
  int countunread = 0;
  String? number;
  @override
  void initState() {
    // _marksread();
    _getUnreadCount();
    super.initState();
    connectSocket();
    tempLeadModelList = leadModelList;
    Provider.of<LeadListViewModel>(context, listen: false).fetch();
  }

  @override
  void dispose() {
    disconnectSocket();

    super.dispose();
  }

  Future<void> _getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    number = prefs.getString('phoneNumber');
    var a = Provider.of<UnreadCountVm>(context, listen: false)
        .fetchunreadcount(number: number ?? "");

    print("aaaaaaaaaaaaaa=>$a");
  }

  // Future<void> _marksread(String? whatsappNumber, String? leadId) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   number = prefs.getString('phoneNumber');

  //   if (number != null && whatsappNumber != null) {
  //     Map<String, String>? bodydata = {"whatsapp_number": whatsappNumber};

  //     await Provider.of<UnreadCountVm>(context, listen: false)
  //         .marksreadcountmsg(
  //       leadnumber: whatsappNumber,
  //       number: number,
  //       bodydata: bodydata,
  //     );

  //     print("Lead with WhatsApp $whatsappNumber marked as read");
  //   }
  // }

  void _filterLeads(String searchLead) {
    setState(() {
      searchLead = searchLead.trim().toLowerCase();

      if (searchLead.isEmpty) {
        leadModelList = List.from(tempLeadModelList);
      } else {
        leadModelList = tempLeadModelList.where((leadModel) {
          var firstName = leadModel.firstname?.toLowerCase() ?? '';
          var lastName = leadModel.lastname?.toLowerCase() ?? '';
          var leadStatus = leadModel.leadstatus?.toLowerCase() ?? '';

          return firstName.contains(searchLead) ||
              lastName.contains(searchLead) ||
              leadStatus.contains(searchLead);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (leadlistvm != null) {
      for (var viewModel in leadlistvm!.viewModels) {
        _leadfilter.add(viewModel.model.leadstatus);
      }
    }

    unreadCountVm = Provider.of<UnreadCountVm>(context);
    leadlistvm = Provider.of<LeadListViewModel>(context);
    userlistvm = Provider.of<UserDataListViewModel>(context);

    if (leadlistvm != null) {
      for (var viewModel in leadlistvm!.viewModels) {
        tempLeadModelList.add(viewModel.model);
      }
    }

    return Scaffold(
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        automaticallyImplyLeading: false,
        title: const Text(
          'Leads',
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
                      Icons.filter_list,
                      color: Color.fromARGB(255, 0, 0, 0),
                      size: 20,
                    ),
                    onPressed: () {
                      _showFilterBottomSheet(context);
                    },
                  ),
                ),
                // suffixIcon: Padding(
                //   padding: const EdgeInsets.all(5.0),
                //   child: Align(
                //     alignment: Alignment.topLeft,
                //     child: Container(
                //       margin: EdgeInsets.only(left: 10),
                //       height: 40,
                //       width: 40,
                //       child: FloatingActionButton(
                //         elevation: 0.5,
                //         backgroundColor: AppColor.navBarIconColor,
                //         shape: const CircleBorder(),
                //         tooltip: 'Filter',
                //         onPressed: () {
                //           _showFilterBottomSheet(context);
                //         },
                //         child: const Icon(
                //           Icons.filter_list_rounded,
                //           color: Colors.white,
                //           size: 23,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                prefixIconConstraints: const BoxConstraints(minWidth: 40),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: AppUtils.getAppBody(leadlistvm!, _pageBody),
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
    Provider.of<LeadListViewModel>(context, listen: false).fetch();

    Provider.of<UnreadCountVm>(context, listen: false)
        .fetchunreadcount(number: number);
    Provider.of<LeadListViewModel>(context, listen: false).fetch();
    isRefresh = true;
    return Future<void>.delayed(const Duration(seconds: 1));
  }

  Widget _pageBody() {
    return Column(
      children: [
        Expanded(
            child: ListView(
          children: getLeadWidgets(),
        ))
      ],
    );
  }

  List<Widget> getLeadWidgets() {
    List<Widget> widgets = [];
    Set<String> uniqueIds = {};

    for (var viewModel in leadModelList) {
      LeadModel model = viewModel;

      var unreadRecord = unreadCountVm?.viewModels.firstWhere(
        (unreadModel) {
          if (unreadModel.model is UnreadMsgModel) {
            var unreadMsgModel = unreadModel.model as UnreadMsgModel;
            return unreadMsgModel.records?.any(
                  (record) => record.whatsappNumber == model.whatsapp_number,
                ) ??
                false;
          }
          return false;
        },
        orElse: () => null,
      );

      if (unreadRecord != null) {
        var matchingRecords = unreadRecord.model.records
            ?.where((record) => record.whatsappNumber == model.whatsapp_number)
            .toList();

        var unreadMsgCount =
            matchingRecords != null && matchingRecords.isNotEmpty
                ? matchingRecords.first.unreadMsgCount
                : "";

        if (!uniqueIds.contains(model.id)) {
          uniqueIds.add(model.id!);

          widgets.add(Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) async {
              var res = await _marksread(model.whatsapp_number ?? "");
            },
            background: Container(
              color: Colors.green,
              alignment: Alignment.centerRight,
              child: const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.chat_sharp, color: Colors.white),
              ),
            ),
            child: leadRecordList(model, unreadMsgCount),
          ));
        }
      } else {
        if (!uniqueIds.contains(model.id)) {
          uniqueIds.add(model.id!);
          widgets.add(leadRecordList(model, ""));
        }
      }
    }

    return widgets;
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

    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) {
        print("model=>${model.toMap()}");
        if (model.whatsapp_number != null) {
          _marksread(model.whatsapp_number ?? "");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                leadName:
                    (model.firstname != null && model.firstname!.isNotEmpty)
                        ? '${model.firstname} ${model.lastname ?? ""}'
                        : (model.lastname != null && model.lastname!.isNotEmpty)
                            ? model.lastname!
                            : "No Name Available",
                wpnumber: model.whatsapp_number ?? "",
                model: model,
              ),
            ),
          ).then((_) {
            // Call your function here when user comes back
            Provider.of<UnreadCountVm>(context, listen: false)
                .fetchunreadcount(number: number ?? "");
            setState(() {
              unreadMsgCount = "0";
              unreadMsgCount = "";
            });
            print("unreadMsgCount====${unreadMsgCount}  ");
          });

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
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerRight,
        child: const Padding(
          padding: EdgeInsets.only(right: 20),
          child: Icon(Icons.chat_sharp, color: Colors.white),
        ),
      ),
      child: Container(
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LeadDetailView(
                    model: model,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                CircleAvatar(
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
                        "${model.whatsapp_number?.isNotEmpty == true ? model.whatsapp_number : ''}",
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
                          padding: const EdgeInsets.all(2.0),
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
                    if (unreadMsgCount != "0" && unreadMsgCount.isNotEmpty)
                      badges.Badge(
                        badgeContent: Text(
                          unreadMsgCount,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    // IconButton(
                    //   onPressed: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => LeadDetailView(
                    //           model: model,
                    //         ),
                    //       ),
                    //     );
                    //   },
                    //   icon: const Icon(
                    //     Icons.arrow_forward_ios,
                    //     color: Colors.black45,
                    //   ),
                    //   iconSize: 22,
                    //   tooltip: 'Details',
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // child: Container(
      //   decoration: BoxDecoration(
      //     color: Colors.white,
      //     borderRadius: BorderRadius.circular(10),
      //     border: Border(
      //       left: BorderSide(
      //         color: statusColor,
      //         width: 5,
      //       ),
      //     ),
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.black.withOpacity(0.1),
      //         blurRadius: 5,
      //         spreadRadius: 3,
      //         offset: const Offset(2, 4),
      //       ),
      //     ],
      //   ),
      //   margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      //   child: Padding(
      //     padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
      //     child: InkWell(
      //       onTap: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => LeadDetailView(
      //               model: model,
      //             ),
      //           ),
      //         );
      //       },
      //       child: ListTile(
      //         contentPadding: EdgeInsets.zero,
      //         title: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Expanded(
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   Text(
      //                     "${model.firstname?.isNotEmpty == true ? model.firstname : 'No Phone Number'} ${model.lastname?.isNotEmpty == true ? model.lastname : ''}",
      //                     style: const TextStyle(
      //                       fontSize: 14,
      //                       fontWeight: FontWeight.bold,
      //                     ),
      //                   ),
      //                   Text(
      //                     "${model.whatsapp_number?.isNotEmpty == true ? model.whatsapp_number : ''}",
      //                     style: const TextStyle(
      //                       fontSize: 12,
      //                     ),
      //                   ),
      //                   Text(
      //                     "${model.email?.isNotEmpty == true ? model.email : ''}",
      //                     style: const TextStyle(
      //                       fontSize: 12,
      //                     ),
      //                   ),
      //                   Container(
      //                     decoration: BoxDecoration(
      //                         borderRadius: BorderRadius.circular(100),
      //                         color: Colors.lightBlue.withOpacity(0.7)),
      //                     child: Padding(
      //                       padding: const EdgeInsets.all(2.0),
      //                       child: Text(
      //                         "${model.leadstatus?.isNotEmpty == true ? model.leadstatus : ''}",
      //                         style: const TextStyle(
      //                             fontSize: 10, color: Colors.white),
      //                       ),
      //                     ),
      //                   ),
      //                   const SizedBox(
      //                     height: 4,
      //                   ),
      //                 ],
      //               ),
      //             ),
      //             Row(
      //               mainAxisAlignment: MainAxisAlignment.end,
      //               children: [
      //                 const SizedBox(width: 10),
      //                 IconButton(
      //                   onPressed: () {
      //                     Navigator.push(
      //                       context,
      //                       MaterialPageRoute(
      //                         builder: (context) => LeadDetailView(
      //                           model: model,
      //                         ),
      //                       ),
      //                     );
      //                   },
      //                   icon: const Icon(
      //                     Icons.arrow_forward_ios,
      //                     color: Colors.black45,
      //                   ),
      //                   iconSize: 22,
      //                   tooltip: 'Details',
      //                 ),
      //                 if (unreadMsgCount != "0" && unreadMsgCount.isNotEmpty)
      //                   badges.Badge(
      //                     badgeContent: Text(
      //                       unreadMsgCount,
      //                       style: const TextStyle(
      //                         color: Colors.white,
      //                       ),
      //                     ),
      //                   )
      //                 else
      //                   const SizedBox.shrink(),
      //               ],
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  void filterLeads(String? filter) {
    leadModelList = tempLeadModelList;
    if (filter == null) return;
    setState(() {
      leadModelList = leadModelList
          .where(
              (lead) => lead.leadstatus?.toLowerCase() == filter.toLowerCase())
          .toList();
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
        print(" WebSocket setup complete");
      });

      socket!.on("receivedwhatsappmessage", (data) {
        print("📩 New WhatsApp message: $data");
        Provider.of<UnreadCountVm>(context, listen: false)
            .fetchunreadcount(number: number ?? "");
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
}
