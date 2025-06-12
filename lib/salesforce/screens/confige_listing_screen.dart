import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/controller/template_controller.dart';
import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
import 'package:whatsapp/salesforce/screens/sf_message_chat_screen.dart';
import 'package:whatsapp/utils/app_color.dart';

class ConfigListingScreen extends StatefulWidget {
  String type;
  ConfigListingScreen({super.key, required this.type});

  @override
  State<ConfigListingScreen> createState() => _ConfigListingScreenState();
}

class _ConfigListingScreenState extends State<ConfigListingScreen> {
  TextEditingController textController = new TextEditingController();
  String selectedValue = "";
  @override
  void initState() {
    selectedValue = widget.type;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashBoardController>(builder: (context, ref, child) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color.fromARGB(255, 255, 255, 255)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            '${ref.selectedTitle}s',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          elevation: 5,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: TextField(
                controller: textController,
                onChanged: ref.filterRecs,
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
          child: _pageBody(),
        ),
      );
    });
  }

  Future<void> _pullRefresh() async {
    return Future<void>.delayed(const Duration(seconds: 1));
  }

  _pageBody() {
    return Consumer<DashBoardController>(builder: (context, ref, child) {
      return Column(
        children: [
          Expanded(
            child: ref.configListLoader
                ? const Center(
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : ref.drawerListItems.isEmpty
                    ? Center(
                        child: Text(
                          "No ${widget.type} Found..",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height: 65,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: ref.selectedTitle,
                                      isExpanded: true,
                                      onChanged: (newValue) {
                                        // setState(() {
                                        //   selectedValue = newValue!;
                                        // });
                                        ref.setSelectedTitle(newValue ?? "");
                                        ref.drawerListApiCall(newValue ?? "");
                                      },
                                      items: ref.drawerItems
                                          .map<DropdownMenuItem<String>>(
                                              (item) {
                                        return DropdownMenuItem<String>(
                                          value: item.sObjectName,
                                          child: Text(item.sObjectName ?? ""),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              )),
                          Expanded(
                            child: ListView.builder(
                              itemCount: ref.drawerListItems.length,
                              itemBuilder: (context, index) {
                                return recordListItem(
                                    ref.drawerListItems[index]);
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

  recordListItem(SfDrawerItemModel drawerListItem) {
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
              ChatMessageController cmProvider =
                  Provider.of(context, listen: false);
              DashBoardController dbProvider =
                  Provider.of(context, listen: false);

              showBlurOnlyLoaderDialog(context);

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
                                "${phNum}",
                                style: const TextStyle(fontSize: 12),
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

void showBlurOnlyLoaderDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (BuildContext context) {
      return Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
            child: const SizedBox.expand(),
          ),
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
      );
    },
  );
}
