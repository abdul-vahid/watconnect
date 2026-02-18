// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
// import 'package:whatsapp/salesforce/model/sf_recent_chat_model.dart';
import 'package:whatsapp/salesforce/screens/confige_listing_screen.dart';
import 'package:whatsapp/salesforce/screens/sf_message_chat_screen.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:html_unescape/html_unescape.dart';

class SfRecentChatScreen extends StatefulWidget {
  const SfRecentChatScreen({super.key});

  @override
  State<SfRecentChatScreen> createState() => _SfRecentChatScreenState();
}

class _SfRecentChatScreenState extends State<SfRecentChatScreen> {
  final parser = EmojiParser();
  final unescape = HtmlUnescape();
  @override
  void initState() {
    DashBoardController dasbController = Provider.of(context, listen: false);
    dasbController.recentChatListApiCall();

    DashBoardController dbProvider = Provider.of(context, listen: false);

    dbProvider.setSelectedPinnedInfo(null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashBoardController>(builder: (context, ref, child) {
      return Scaffold(
        backgroundColor: AppColor.pageBgGrey,
        appBar: AppBar(
          iconTheme:
              const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
          centerTitle: true,
          elevation: 2,
          backgroundColor: AppColor.navBarIconColor,
          actions: [
            ref.selectedPinnedInfo == null
                ? const SizedBox()
                : ref.selectedPinnedInfo?.isPinned ?? false
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () {
                            ref.pinUnPinApiCall(isFromRecentChat: true);
                          },
                          child: Image.asset(
                            "assets/images/unpin_icon.png",
                            color: Colors.white,
                            height: 20,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () {
                            ref.pinUnPinApiCall(isFromRecentChat: true);
                          },
                          child: const Icon(
                            Icons.push_pin,
                            color: Colors.white,
                          ),
                        ),
                      )
          ],
          title: const Text(
            "Recent Chats",
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _pullRefresh,
          child: _pageBody(),
        ),
      );
    });
  }

  Future<void> _pullRefresh() async {
    return Future<void>.delayed(const Duration(seconds: 1));
  }

  _pageBody() {
    return Consumer<DashBoardController>(
        builder: (context, dashBoardController, child) {
      return Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<DashBoardController>(builder: (context, ref, child) {
                  return Container(
                      height: 65,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: ref.selectedTitle.isNotEmpty == true
                                  ? ref.selectedTitle
                                  : null,
                              isExpanded: true,
                              hint: const Text("Select Item"),
                              onChanged: (newValue) async {
                                final selectedItem = ref.drawerItems.firstWhere(
                                  (item) => item.sObjectName == newValue,
                                );
                                ref.setSelectedDrawerItem(selectedItem);
                                await ref.setSelectedTitle(newValue ?? "");
                                ref.recentChatListApiCall();
                              },
                              items: ref.drawerItems
                                  .where((item) =>
                                      item.sObjectName != null &&
                                      item.sObjectName != "Campaign")
                                  .map<DropdownMenuItem<String>>((item) {
                                return DropdownMenuItem<String>(
                                  value: item.sObjectName!,
                                  child: Text(item.sObjectName ?? ""),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ));
                }),
                dashBoardController.sfPinnedRecentChatList.isEmpty
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8),
                        child: Text(
                          "Pinned Leads",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                dashBoardController.sfPinnedRecentChatList.isEmpty
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: SizedBox(
                          height: 90,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: dashBoardController
                                  .sfPinnedRecentChatList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onLongPress: () {
                                    DashBoardController dbProvider =
                                        Provider.of(context, listen: false);
                                    print("this is pressisng longgggg");

                                    dbProvider.setSelectedPinnedInfo(
                                        dashBoardController
                                            .sfPinnedRecentChatList[index]);
                                  },
                                  onTap: () async {
                                    String phNum =
                                        "${dashBoardController.sfPinnedRecentChatList[index].countryCode ?? ""}${dashBoardController.sfPinnedRecentChatList[index].whatsappNumber ?? ""}";
                                    showBlurOnlyLoaderDialog(context);
                                    ChatMessageController cmProvider =
                                        Provider.of(context, listen: false);
                                    DashBoardController dbProvider =
                                        Provider.of(context, listen: false);
                                    dbProvider.setSelectedPinnedInfo(null);

                                    dbProvider.setSelectedContaactInfo(
                                        dashBoardController
                                            .sfPinnedRecentChatList[index]);
                                    await cmProvider
                                        .messageHistoryApiCall(
                                      userNumber: phNum,
                                    )
                                        .then((onValue) {
                                      Navigator.pop(context);
                                    });
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SfMessageChatScreen(
                                                  pinnedLeadsList:
                                                      dashBoardController
                                                          .sfPinnedRecentChatList,
                                                  isFromRecentChat: true,
                                                )));
                                  },
                                  child: SizedBox(
                                    width: 60,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor:
                                              AppColor.navBarIconColor,
                                          child: Text(
                                            dashBoardController
                                                    .sfPinnedRecentChatList[
                                                        index]
                                                    .name!
                                                    .isNotEmpty
                                                ? dashBoardController
                                                    .sfPinnedRecentChatList[
                                                        index]
                                                    .name![0]
                                                    .toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          dashBoardController
                                                  .sfPinnedRecentChatList[index]
                                                  .name ??
                                              "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Text(
                    "${dashBoardController.sfRecentChatList.length} Chats Available",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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
                    child: dashBoardController.recentChatListLoader
                        ? const Center(
                            child: SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : dashBoardController.sfRecentChatList.isEmpty
                            ? const Center(
                                child: Text(
                                  "No Recent Chats Found..",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(
                                    top: 10.0, left: 3, right: 3),
                                child: ListView.builder(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  itemCount: dashBoardController
                                      .sfRecentChatList.length,
                                  itemBuilder: (context, index) {
                                    var item = dashBoardController
                                        .sfRecentChatList[index];
                                    return renctChatListItem(item);
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
    });
  }

  renctChatListItem(SfDrawerItemModel drawerListItem) {
    String phNum =
        "${drawerListItem.countryCode ?? ""}${drawerListItem.whatsappNumber ?? ""}";
    Color statusColor;
    statusColor = Colors.lightBlue.withOpacity(0.7);

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
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        child: GestureDetector(
          onLongPress: () {
            DashBoardController dbProvider =
                Provider.of(context, listen: false);
            dbProvider.setSelectedPinnedInfo(null);
            print("this is pressisng longgggg");

            dbProvider.setSelectedPinnedInfo(drawerListItem);
          },
          onTap: () async {
            DashBoardController dbProvider =
                Provider.of(context, listen: false);
            dbProvider.setSelectedPinnedInfo(null);
            showBlurOnlyLoaderDialog(context);
            ChatMessageController cmProvider =
                Provider.of(context, listen: false);

            dbProvider.setSelectedContaactInfo(drawerListItem);
            await cmProvider
                .messageHistoryApiCall(
              userNumber: phNum,
            )
                .then((onValue) {
              Navigator.pop(context);
              dbProvider.resentUnreadCountApiCall(phNum);
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SfMessageChatScreen(
                          pinnedLeadsList: dbProvider.sfPinnedRecentChatList,
                          isFromRecentChat: true,
                        )));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColor.navBarIconColor,
                  child: Text(
                    drawerListItem.name?.isNotEmpty == true
                        ? drawerListItem.name![0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 18,
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              drawerListItem.name ?? "Unknown",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (drawerListItem.unreadCount != null &&
                              drawerListItem.unreadCount! > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                drawerListItem.unreadCount.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          (drawerListItem.isPinned ?? false)
                              ? const Icon(Icons.push_pin)
                              : const SizedBox()
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              parser.emojify(unescape
                                  .convert(drawerListItem.lastMsg ?? "")),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          if (drawerListItem.lastMsgTime != 0)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                formatDateTime(drawerListItem.lastMsgTime ?? 0),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String formatDateTime(int timestamp) {
  // Use the timestamp directly (milliseconds)
  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
  final now = DateTime.now();

  final isToday = dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day;

  final timeFormat = DateFormat('h:mm a');
  final dateFormat = DateFormat('d MMM, h:mm a');

  return isToday ? timeFormat.format(dateTime) : dateFormat.format(dateTime);
}
