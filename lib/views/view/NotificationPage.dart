// ignore_for_file: avoid_print, deprecated_member_use, file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/react_side/chat/controller/chat_controller.dart';
import 'package:whatsapp/react_side/chat/page/whatsapp_chat_page.dart';
import 'package:whatsapp/react_side/home/controller/home_summary_controller.dart';
import 'package:whatsapp/react_side/lead/controller/lead_list_controller.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/views/view/chat/whatsapp_chat_screen.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ScrollController _scrollController = ScrollController();

  bool shouldHideLeadNumber = false;

  @override
  void initState() {
    super.initState();

    _init();
    _scrollListener();
  }

  Future<void> _init() async {
    final ctrl = context.read<HomeSummaryController>();

    ctrl.resetPagination();
    await ctrl.fetchUnreadList();

    final prefs = await SharedPreferences.getInstance();
    shouldHideLeadNumber =
        prefs.getBool(SharedPrefsConstants.shouldHideNumber) ?? false;

    if (mounted) setState(() {});
  }

  void _scrollListener() {
    _scrollController.addListener(() {
      final ctrl = context.read<HomeSummaryController>();

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ctrl.fetchUnreadList(isLoadMore: true);
      }
    });
  }

  Future<void> _refresh() async {
    final ctrl = context.read<HomeSummaryController>();
    ctrl.resetPagination();
    await ctrl.fetchUnreadList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeSummaryController>(
      builder: (context, ctrl, child) {
        return Scaffold(
          backgroundColor: AppColor.pageBgGrey,
          appBar: AppBar(iconTheme:const IconThemeData(color: Colors.white),

            title: const Text(
              'Notifications',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: AppColor.navBarIconColor,
          ),

          body: ctrl.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColor.navBarIconColor,
                  ),
                )
              : ctrl.notificationList.isEmpty
                  ? const Center(
                      child: Text(
                        "No Data Found",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : Column(
                      children: [
                        /// 🔢 Count
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            "${ctrl.unReadData?.total ?? 0} Notifications Available",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        /// 📜 List
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: RefreshIndicator(
                              onRefresh: _refresh,
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: ctrl.notificationList.length +
                                    (ctrl.isPaginationLoading ? 1 : 0),

                                itemBuilder: (context, index) {
                                  /// 🔄 Pagination Loader
                                  if (index == ctrl.notificationList.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  final record =
                                      ctrl.notificationList[index];

                                  return _notificationItem(record, ctrl);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }

  Widget _notificationItem(record, HomeSummaryController ctrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        border: const Border(
          left: BorderSide(
            color: AppColor.navBarIconColor,
            width: 5,
          ),
        ),
      ),
      child: ListTile(
        onTap: () async {

                    final ctrl = context.read<ChatController>();
        final leadCtrl = context.read<LeadListController>();
               await ctrl.setSelectedLeadNumber( record.fullNumber );
   await leadCtrl.getLeadDetail(record.parentId ?? "");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => 
              WhatsappChatPage(

                name: record.contactName ?? "",
                number: record.fullNumber ?? "",
                leadId: record.parentId ?? "",
                // countryCode: "+91",
              ),
            ),
          ).then((_) {
            _init();
          });
        },

        leading: const CircleAvatar(
          // borderOnForeground: true,
          child: Icon(Icons.notifications),
        ),

        title: Text(
          record.contactName ?? "",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text(
          shouldHideLeadNumber
              ? "*******${record.fullNumber?.substring(record.fullNumber!.length - 5)}"
              : record.fullNumber ?? "",
        ),

        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: Text(
            record.unreadCount ?? "0",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}