// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
    return GestureDetector(
      onLongPress: () {
        DashBoardController dbProvider =
            Provider.of(context, listen: false);
        dbProvider.setSelectedPinnedInfo(drawerListItem);
      },
      onTap: () async {
        String phNum =
            "${drawerListItem.countryCode ?? ""}${drawerListItem.whatsappNumber ?? ""}";
        showBlurOnlyLoaderDialog(context);
        ChatMessageController cmProvider =
            Provider.of(context, listen: false);
        DashBoardController dbProvider =
            Provider.of(context, listen: false);
        dbProvider.setSelectedPinnedInfo(null);

        dbProvider.setSelectedContaactInfo(drawerListItem);
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
                builder: (context) => SfMessageChatScreen(
                      isFromRecentChat: true,
                    )));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: drawerListItem.isPinned == true
              ? Colors.yellow.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
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

            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          drawerListItem.name ??
                              'Unknown Contact',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (drawerListItem.isPinned == true)
                        const Icon(
                          Icons.push_pin,
                          color: Colors.orange,
                          size: 16,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    drawerListItem
                            .lastMsg ??
                        'No messages yet',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Time and unread indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      formatDateTime(drawerListItem.lastMsgTime ?? 0),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        // Prevent tap from propagating to parent GestureDetector
                      },
                      onTapDown: (details) {
                        // Also prevent tap down
                      },
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                        onSelected: (String value) {
                          if (value == 'pin' || value == 'unpin') {
                            _togglePinChat(drawerListItem);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: drawerListItem.isPinned == true ? 'unpin' : 'pin',
                            child: Row(
                              children: [
                                Icon(
                                  drawerListItem.isPinned == true
                                    ? Icons.push_pin_outlined
                                    : Icons.push_pin,
                                  size: 18,
                                  color: drawerListItem.isPinned == true
                                    ? Colors.orange
                                    : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  drawerListItem.isPinned == true ? 'Unpin Chat' : 'Pin Chat',
                                  style: TextStyle(
                                    color: drawerListItem.isPinned == true
                                      ? Colors.orange
                                      : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (drawerListItem
                            .unreadCount !=
                        null &&
                    drawerListItem
                            .unreadCount! >
                        0)
                  Container(
                    margin:
                        const EdgeInsets.only(
                            top: 4),
                    padding:
                        const EdgeInsets.all(
                            6),
                    decoration:
                        const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      drawerListItem
                          .unreadCount
                          .toString(),
                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

//   void _togglePinChat(SfDrawerItemModel item) async {
//     try {
//       final chatController = Provider.of<ChatMessageController>(context, listen: false);
//       final dbController = Provider.of<DashBoardController>(context, listen: false);
//
//       // Toggle the pin status
//       final newPinStatus = !(item.isPinned ?? false);
//
//       // Show loading
//       EasyLoading.show(status: '${newPinStatus ? 'Pinning' : 'Unpinning'} chat...');
//
//       // Call the API to pin/unpin
//       await chatController.pinChatApiCall(item.id ?? '', newPinStatus);
//
//       // Update local state immediately for better UX
//       item.isPinned = newPinStatus;
//
//       // Refresh the chat list to get updated data from server
//       await dbController.getDasBoardReportApiCall();
//
//       // Dismiss loading and show success
//       EasyLoading.dismiss();
//       EasyLoading.showToast(
//         newPinStatus ? 'Chat pinned successfully' : 'Chat unpinned successfully'
//       );
//
//       // Trigger UI refresh
//       if (mounted) {
//         setState(() {});
//       }
//     } catch (e) {
//       EasyLoading.dismiss();
//       EasyLoading.showToast('Failed to ${item.isPinned == true ? 'unpin' : 'pin'} chat');
//       debugPrint('Pin/Unpin error: $e');
//     }
//   }
// }

  void _togglePinChat(SfDrawerItemModel item) async {
    try {
      final chatController = Provider.of<ChatMessageController>(context, listen: false);
      final dbController = Provider.of<DashBoardController>(context, listen: false);


      final wasPinned = item.isPinned ?? false;
      final newPinStatus = !wasPinned;


      EasyLoading.show(status: '${newPinStatus ? 'Pinning' : 'Unpinning'} chat...');


      await chatController.pinChatApiCall(item.id ?? '', newPinStatus);


      item.isPinned = newPinStatus;

      await dbController.recentChatListApiCall();


      await dbController.getDasBoardReportApiCall();


      dbController.setSelectedPinnedInfo(null);

      EasyLoading.dismiss();
      EasyLoading.showToast(
          newPinStatus ? 'Chat pinned successfully' : 'Chat unpinned successfully'
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showToast('Failed to ${item.isPinned == true ? 'unpin' : 'pin'} chat');
      debugPrint('Pin/Unpin error: $e');

      item.isPinned = !(item.isPinned ?? false);
      if (mounted) {
        setState(() {});
      }
    }
  }
String formatDateTime(int timestamp) {

  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
  final now = DateTime.now();

  final isToday = dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day;

  final timeFormat = DateFormat('h:mm a');
  final dateFormat = DateFormat('d MMM, h:mm a');

  return isToday ? timeFormat.format(dateTime) : dateFormat.format(dateTime);
}
