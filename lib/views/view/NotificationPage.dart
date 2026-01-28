// ignore_for_file: avoid_print, deprecated_member_use, file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/view_models/unread_count_vm.dart';
import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';
import '../../models/unread_msg_model/record.dart';
import '../../models/unread_msg_model/unread_msg_model.dart'
    show UnreadMsgModel;

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  UnreadCountVm? unreadcountvm;
  List<Record> data = [];

  bool isLoading = false;

  void fetchcount() async {
    setState(() {
      isLoading = true;
    });
    try {
      unreadcountvm = Provider.of<UnreadCountVm>(context, listen: false);
      final prefs = await SharedPreferences.getInstance();
      String? number = prefs.getString('phoneNumber');
      await unreadcountvm!.fetchunreadcount(number: number).then((_) {
        unreadcountvm!.viewModels.length;
        print("djjdjdjdjdjj${unreadcountvm!.viewModels.length}");

        for (var i in unreadcountvm!.viewModels) {
          UnreadMsgModel datanread = i.model;

          if (datanread.records != null) {
            for (var record in datanread.records!) {
              if (!data.any((r) => r.whatsappNumber == record.whatsappNumber)) {
                data.add(record);
              }
            }
          }
        }
        print("dattaaa=>$data");
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    shouldHide();
    fetchcount();
  }

  bool shouldHideLeadNumber = false;
  Future<void> shouldHide() async {
    final prefs = await SharedPreferences.getInstance();
    shouldHideLeadNumber =
        prefs.getBool(SharedPrefsConstants.shouldHideNumber) ?? false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    unreadcountvm = Provider.of<UnreadCountVm>(context);

    return Scaffold(
      backgroundColor: AppColor.pageBgGrey,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColor.navBarIconColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: AppColor.navBarIconColor,
            ))
          : data.isEmpty
              ? const Center(
                  child: Text(
                    "No Data Found",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 12),
                      child: Text(
                        " ${data.length} Notifications Available",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
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
                              left: 12.0, right: 12, top: 20),
                          child: ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final record = data[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                      spreadRadius: 2,
                                      offset: const Offset(2, 4),
                                    ),
                                  ],
                                  border: const Border(
                                    left: BorderSide(
                                      color: AppColor.navBarIconColor,
                                      width: 5,
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            WhatsappChatScreen(
                                          pinnedLeads: [],
                                          leadName: record.name ?? "",
                                          wpnumber: record.whatsappNumber ?? "",
                                          id: record.parentId ?? "",
                                          contryCode: "+91",
                                        ),
                                      ),
                                    ).then((_) {
                                      fetchcount();
                                      setState(() {});
                                    });
                                  },
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        color: AppColor.navBarIconColor,
                                        width: 3,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.notifications,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    record.name ?? "",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  subtitle: Text(
                                    shouldHideLeadNumber
                                        ? "*******${record.whatsappNumber?.substring(record.whatsappNumber!.length - 5)}"
                                        : record.whatsappNumber ?? "",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          record.unreadMsgCount ?? "0",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
