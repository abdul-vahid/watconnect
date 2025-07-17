import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
// import 'package:whatsapp/salesforce/controller/template_controller.dart';
import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
import 'package:whatsapp/salesforce/screens/sf_message_chat_screen.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/app_fonts.dart';

class ConfigListingScreen extends StatefulWidget {
  String type;
  ConfigListingScreen({super.key, required this.type});

  @override
  State<ConfigListingScreen> createState() => _ConfigListingScreenState();
}

class _ConfigListingScreenState extends State<ConfigListingScreen> {
  final TextEditingController textController = new TextEditingController();
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
        backgroundColor: AppColor.pageBgGrey,
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
      final Map<String, int> unreadCountMap = {
        for (var item in ref.configUnreadCountList)
          if (item.id != null) item.id!: item.unreadCount ?? 0
      };

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
                                        ref.drawerListApiCall(
                                            type: newValue ?? "");
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
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
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
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 2,
                                                spreadRadius: 2,
                                                offset: const Offset(1, 1),
                                              ),
                                            ],
                                            color: Colors.white,
                                            border: Border.all(
                                                color: AppColor.backgroundGrey),
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: Center(
                                          child: Stack(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.all(10.0),
                                                child: Icon(
                                                  Icons.filter_list,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                  size: 20,
                                                ),
                                              ),
                                              ref.configStatusList.length == 0
                                                  ? SizedBox()
                                                  : Positioned(
                                                      left: 8,
                                                      top: 5,
                                                      child: Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .brown),
                                                        child: Center(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4.0),
                                                            child: Text(
                                                              ref.configStatusList
                                                                  .length
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
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
                                    onChanged: ref.filterRecs,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Search...',
                                      hintStyle: TextStyle(
                                        color: AppColor.textoriconColor
                                            .withOpacity(0.6),
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
                                        borderSide: const BorderSide(
                                            color: AppColor.backgroundGrey),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: AppColor.backgroundGrey),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      prefixIcon: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Icon(Icons.search)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15,
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
                                    left: 4.0, right: 4, top: 15),
                                child: ListView.builder(
                                  itemCount: ref.drawerListItems.length,
                                  itemBuilder: (context, index) {
                                    final drawerItem =
                                        ref.drawerListItems[index];
                                    final count =
                                        unreadCountMap[drawerItem.id] ?? 0;
                                    return recordListItem(drawerItem, count);
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

  recordListItem(SfDrawerItemModel drawerListItem, int cnt) {
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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SfMessageChatScreen()));
          },
          child: Row(
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
                                fontFamily: AppFonts.semiBold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            drawerListItem.status!.isEmpty
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 3.0),
                                    child: Text(
                                      drawerListItem.status ?? "",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColor.navBarIconColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                            Text(
                              phNum,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      cnt == 0
                          ? const SizedBox()
                          : Container(
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    cnt.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                    ],
                  ),
                ),
              ),
            ],
          ),
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
          return Consumer<DashBoardController>(
              builder: (context, dashbrdController, child) {
            return Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  'Status Filter',
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
                    MultiSelectDialogField<String>(
                      items: [
                        'All',
                        'New',
                        'Contacted',
                        'Under Discussion',
                        'Follow-Up',
                        "No Response",
                        "Close Lost",
                        "Qualified",
                        "Closed Converted"
                      ].map((e) => MultiSelectItem<String>(e, e)).toList(),
                      title: const Flexible(
                        child: Text(
                          "Select Status",
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
                        dashbrdController.setConfigStatusList(selected);
                        // Update selectleadList with the confirmed selections
                        // selectleadList = selected;
                      },
                      initialValue: [],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      children: dashbrdController.configStatusList
                          .map((selectedItem) {
                        return Chip(
                          label: Text(selectedItem),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () {
                            dashbrdController
                                .removeFromConfigStatusList(selectedItem);
                          },
                          backgroundColor: Colors.blue.withOpacity(0.2),
                          labelStyle: const TextStyle(color: Colors.blue),
                        );
                      }).toList(),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            dashbrdController.resetConfigStatusList();
                            dashbrdController.filterConfig();

                            Navigator.pop(context);
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
                            dashbrdController.filterConfig();
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
                    const SizedBox(
                      height: 25,
                    )
                  ],
                ),
              ),
            );
          });
        });
  }
}

void showBlurOnlyLoaderDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.2),
    builder: (BuildContext context) {
      return Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0.1, sigmaY: 0.1),
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
