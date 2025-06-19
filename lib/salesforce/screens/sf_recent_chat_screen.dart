import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
// import 'package:whatsapp/salesforce/model/sf_recent_chat_model.dart';
import 'package:whatsapp/salesforce/screens/confige_listing_screen.dart';
import 'package:whatsapp/salesforce/screens/sf_message_chat_screen.dart';
import 'package:whatsapp/utils/app_color.dart';

class SfRecentChatScreen extends StatefulWidget {
  const SfRecentChatScreen({super.key});

  @override
  State<SfRecentChatScreen> createState() => _SfRecentChatScreenState();
}

class _SfRecentChatScreenState extends State<SfRecentChatScreen> {
  @override
  void initState() {
    DashBoardController dasbController = Provider.of(context, listen: false);
    dasbController.recentChatListApiCall();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme:
            const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
        centerTitle: true,
        elevation: 2,
        backgroundColor: AppColor.navBarIconColor,
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
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(
                                "${dashBoardController.sfRecentChatList.length} Chats Available",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount:
                                  dashBoardController.sfRecentChatList.length,
                              itemBuilder: (context, index) {
                                var item =
                                    dashBoardController.sfRecentChatList[index];
                                return renctChatListItem(item);
                              },
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

    return InkWell(
      onTap: () {},
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
            onTap: () async {
              showBlurOnlyLoaderDialog(context);
              ChatMessageController cmProvider =
                  Provider.of(context, listen: false);
              DashBoardController dbProvider =
                  Provider.of(context, listen: false);

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
                      builder: (context) => SfMessageChatScreen()));
            },
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColor.navBarIconColor,
                      child: Text(
                        drawerListItem.name?.isNotEmpty == true
                            ? drawerListItem.name![0].toUpperCase()
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
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${drawerListItem.name}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${drawerListItem.lastMsg ?? ""} ",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey
                                    // fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
