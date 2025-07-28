// import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
// ignore_for_file: deprecated_member_use, avoid_print, prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/models/template_model/template_model.dart';
import 'package:whatsapp/view_models/templete_list_vm.dart';
import '../../models/user_model/user_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_utils.dart';

class TempleteListView extends StatefulWidget {
  const TempleteListView({super.key});

  @override
  State<TempleteListView> createState() => _TempleteListView();
}

class _TempleteListView extends State<TempleteListView> {
  String? selecttemplte;
  var templetevm;
  String searchTemp = "";
  List allTemplates = [];

  List tempTemplates = [];
  List<String> templetefilter = [];
  // late NotchBottomBarController _controller;
  TextEditingController textController = TextEditingController();
  TemplateModel? model1;
  var templeteViewModel;
  TempleteListViewModel? contacts;
  bool isRefresh = false;
  UserModel? userModel;
  List<String> selectTempList = [];
  void getProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userModel = AppUtils.getSessionUser(prefs);
    });
  }

  void _getNumberFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');
    print("number fetch===>$number");

    await Provider.of<TempleteListViewModel>(context, listen: false)
        .templetefetch(number: number);

    getProfileData();
  }

  @override
  void initState() {
    super.initState();
    allTemplates = [];
    tempTemplates = [];
    selectTempList = ['approved'];
    searchTemp = "";
    // _controller = NotchBottomBarController();
    _getNumberFromPreferences();
    getAllTemp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBgGrey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Template',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: AppUtils.getAppBody(templeteViewModel!, _pageBody),
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
            List<String> uniqtempletestatus = templetefilter.toSet().toList();
            uniqtempletestatus.add("All");
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
                                  'Template Status Filter',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white),
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
                              items: uniqtempletestatus
                                  .map((e) => MultiSelectItem<String>(e, e))
                                  .toList(),
                              title: const Flexible(
                                child: Flexible(
                                  child: Text(
                                    "Select Template Status",
                                    style: TextStyle(fontSize: 18),
                                    overflow: TextOverflow
                                        .ellipsis, // Handles overflow with ellipsis
                                  ),
                                ),
                              ),
                              buttonText: const Text("Select Template Status"),
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
                                  selectTempList = selected;
                                });
                              },
                              initialValue: const [],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8.0,
                              children: selectTempList.map((selectedItem) {
                                return Chip(
                                  label: Text(selectedItem),
                                  deleteIcon: const Icon(Icons.close),
                                  onDeleted: () {
                                    setState(() {
                                      selectTempList.remove(selectedItem);
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
                    // DropdownButtonFormField<String>(
                    //   isDense: true,
                    //   // isExpanded: true,
                    //   // menuMaxHeight: 10,
                    //   hint: const Text('Select Template Status'),
                    //   items: uniqtempletestatus.map((String value) {
                    //     return DropdownMenuItem<String>(
                    //       value: value,
                    //       child: Text(value),
                    //     );
                    //   }).toList(),
                    //   onChanged: (String? newValue) {
                    //     setState(() {
                    //       selecttemplte = newValue;
                    //     });
                    //   },
                    //   value: selecttemplte,
                    // ),
                    const SizedBox(height: 7),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            selecttemplte = "";
                            selectTempList = ['approved'];
                            filterLeads(selectTempList);
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
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            filterLeads(selectTempList);
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
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void filterLeads(List filter) {
    print(
        "filter:::::$filter  ${tempTemplates.length} ${allTemplates.length}  ${allTemplates.length}  ${allTemplates.runtimeType}");

    if (filter.contains('All') || filter.isEmpty) {
      allTemplates = tempTemplates;
      Navigator.pop(context);

      setState(() {});
      return;
    } else {
      List<dynamic> matchleads = tempTemplates.where((lead) {
        return filter
            .map((e) => e.toLowerCase())
            .contains(lead.status?.toLowerCase());
      }).toList();
      setState(() {
        allTemplates = matchleads;
      });
      print("cammam   ${matchleads.length}");
      Navigator.pop(context);
      return;
    }
  }

  Future<void> _pullRefresh() async {
    setState(() {
      contacts?.viewModels.clear();
      isRefresh = true;
    });
    return Future<void>.delayed(const Duration(seconds: 2));
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
                          selectTempList.isEmpty
                              ? const SizedBox()
                              : Container(
                                  decoration: const BoxDecoration(
                                      color: AppColor.navBarIconColor,
                                      shape: BoxShape.circle),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "${selectTempList.length}",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 9,
                child: TextField(
                  onChanged: searchLeads,
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(
                      color: AppColor.textoriconColor.withOpacity(0.6),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColor.navBarIconColor,
                        width: 1.5,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
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
        allTemplates.isEmpty || noMatchedLeads
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${allTemplates.length} Records Found",
                  textAlign: TextAlign.left,
                ),
              ),
        Expanded(
          child: allTemplates.isEmpty || noMatchedLeads
              ? const Center(
                  child: Text(
                    "No Templates Available..",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                )
              : Container(
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
                    padding: const EdgeInsets.only(top: 18.0),
                    child: ListView.builder(
                        itemCount: allTemplates.length,
                        itemBuilder: (context, index) {
                          Color statusColor = Colors.red;
                          String statusText = "";

                          if (allTemplates[index].status == "APPROVED") {
                            print("shshhsshshh");
                            statusColor = AppColor.navBarIconColor;
                            statusText = "Approved";
                          } else if (allTemplates[index].status == 'REJECTED') {
                            statusColor = Colors.red;
                            statusText = "Rejected";
                          } else {
                            statusColor = Colors.grey;
                            statusText = "Unknown";
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 7.0, horizontal: 10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: const Border(
                                  left: BorderSide(
                                    color: AppColor.navBarIconColor,
                                    width: 5,
                                  ),
                                  right: BorderSide(
                                    color: AppColor.navBarIconColor,
                                    width: 5,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                    spreadRadius: 2,
                                    offset: const Offset(2, 4),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  formatTemplateName(
                                                      allTemplates[index].name),
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  allTemplates[index]
                                                          .category ??
                                                      "",
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: AppColor
                                                          .containerBoxColor),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  allTemplates[index]
                                                          .language ??
                                                      "",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: statusColor,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  statusText,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ),
          // child: ListView(
          //   children: getContactWidgets(),
          // ),
        ),
      ],
    );
  }

  List<Widget> getContactWidgets() {
    List<Widget> widgets = [];
    for (var viewModel in templeteViewModel.viewModels) {
      TemplateModel model = viewModel.model;
      if (model.data?.isNotEmpty ?? false) {
        widgets.addAll(contactRecordList(model));
      }
    }
    return widgets;
  }

  List<Widget> contactRecordList(TemplateModel model) {
    List<Widget> widgets = [];
    for (var record in model.data ?? []) {
      Color statusColor = Colors.red;
      String statusText = "";

      if (record.status == "APPROVED") {
        print("shshhsshshh");
        statusColor = AppColor.navBarIconColor;
        statusText = "Approved";
      } else if (record.status == 'REJECTED') {
        print("kisisisiisiisi");
        statusColor = Colors.red;
        statusText = "Rejected";
      } else {
        statusColor = Colors.grey;
        statusText = "Unknown";
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: const Border(
                left: BorderSide(
                  color: AppColor.navBarIconColor,
                  width: 5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  spreadRadius: 2,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {},
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.name ?? "",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                record.category ?? "",
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColor.containerBoxColor),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                record.language ?? "",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                statusText,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  bool noMatchedLeads = false;
  void searchLeads(String value) {
    searchTemp = value.trim().toLowerCase();
    if (searchTemp.isEmpty) {
      allTemplates = tempTemplates;
      noMatchedLeads = false;
      setState(() {});
    } else {
      List matched = [];
      List others = [];

      for (var lead in allTemplates) {
        var firstName = lead.name?.toLowerCase() ?? '';
        var lastName = lead.category?.toLowerCase() ?? '';
        var leadStatus = lead.language?.toLowerCase() ?? '';

        if (firstName.contains(searchTemp) ||
            lastName.contains(searchTemp) ||
            leadStatus.contains(searchTemp)) {
          matched.add(lead);
        } else {
          others.add(lead);
        }
      }

      setState(() {
        allTemplates = [
          ...matched,
        ];
        noMatchedLeads = matched.isEmpty;
      });
    }
  }

  void getAllTemp() {
    templeteViewModel =
        Provider.of<TempleteListViewModel>(context, listen: false);

    for (var viewModel in templeteViewModel!.viewModels) {
      var campginmodel = viewModel.model;
      if (campginmodel?.data != null) {
        allTemplates = [];
        log("selecttemplte:::: $selecttemplte");
        for (var record in campginmodel!.data!) {
          if (record.status != null) {
            tempTemplates.add(record);
            templetefilter.add(record.status!);
            if (selecttemplte == 'All') {
              allTemplates.add(record);
            } else if (selecttemplte != null &&
                selecttemplte != '' &&
                selecttemplte?.toLowerCase() != "approved") {
              if (record.status.toString().toLowerCase() ==
                  selecttemplte?.toLowerCase()) {
                allTemplates.add(record);
              }
            } else {
              selecttemplte = null;

              if (record.status.toString().toLowerCase() == "approved") {
                if (record.status.toString().toLowerCase() == "approved") {
                  allTemplates.add(record);
                }
              }
            }

            if (searchTemp.isNotEmpty) {
              List tempUsers = allTemplates;
              allTemplates = [];
              allTemplates = tempUsers.where((user) {
                var firstName = user.name?.toLowerCase() ?? '';
                print(
                    "Checking user: ${user.name}, Result: ${firstName.contains(searchTemp)}");
                return firstName.contains(searchTemp);
              }).toList();
            }
          }
        }
        setState(() {});
      }
    }
  }

  String formatTemplateName(String? name) {
    if (name == null) return "";
    return name
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }
}
