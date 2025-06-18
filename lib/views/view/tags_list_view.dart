import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/models/tags_list_model.dart';
import 'package:whatsapp/utils/app_color.dart';
// import 'package:whatsapp/view_models/lead_list_vm.dart';
import 'package:whatsapp/view_models/tags_list_vm.dart';
import 'package:whatsapp/views/view/tag_add_update_view.dart';

class TagsListView extends StatefulWidget {
  const TagsListView({super.key});

  @override
  State<TagsListView> createState() => _TagsListViewState();
}

class _TagsListViewState extends State<TagsListView> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    getTagsList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                      builder: (context) => TagAddUpdateView(),
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
          'Tags',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 5,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: TextField(
              controller: searchController,
              onChanged: _searchTags,
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
                  child: Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.filter_list,
                          color: Color.fromARGB(255, 0, 0, 0),
                          size: 20,
                        ),
                        onPressed: () {
                          _showFilterBottomSheet(context);
                        },
                      ),
                      // selectleadList.isEmpty
                      // ? const SizedBox()
                      // : Container(
                      //     decoration: const BoxDecoration(
                      //         color: AppColor.navBarIconColor,
                      //         shape: BoxShape.circle),
                      //     child: Padding(
                      //       padding: const EdgeInsets.all(8.0),
                      //       child: Text(
                      //         "${selectleadList.length}",
                      //         style: const TextStyle(color: Colors.white),
                      //       ),
                      //     ),
                      //   )
                    ],
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 40),
              ),
            ),
          ),
        ),
      ),
      body: _pageBody(),
    );
  }

  List<TagRecord> allTagsList = [];
  List<TagRecord> tempTagsList = [];
  bool updateLoader = false;
  Future<void> getTagsList() async {
    setState(() {
      updateLoader = true;
    });
    await Provider.of<TagsListViewModel>(context, listen: false)
        .fetchAllTags()
        .then((onValue) {
      allTagsList = [];
      var taglistvm = Provider.of<TagsListViewModel>(context, listen: false);

      for (var viewModel in taglistvm.viewModels) {
        var tagmodel = viewModel.model;
        if (tagmodel?.records != null) {
          for (var record in tagmodel!.records!) {
            allTagsList.add(record);
            tempTagsList.add(record);
            // allLeads.add(record);
          }
        }
      }
      setState(() {
        updateLoader = false;
      });
    });
    setState(() {
      updateLoader = false;
    });
  }

  void _searchTags(String filter) {
    print("filyerL:::: ${filter}");
    var searchTag = filter.trim().toLowerCase();
    if (searchTag.isEmpty) {
      setState(() {
        allTagsList = tempTagsList;
      });
    } else {
      List matched = [];
      List others = [];

      for (var tag in allTagsList) {
        var firstName = tag.name?.toLowerCase();

        if (firstName!.contains(searchTag)) {
          matched.add(tag);
        } else {
          // others.add(lead);
        }
      }

      setState(() {
        allTagsList = [...matched, ...others];
        // noMatchedLeads = matched.isEmpty;
      });
    }
  }

  Widget _pageBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        allTagsList.isEmpty
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${allTagsList.length} Records Found",
                  textAlign: TextAlign.left,
                ),
              ),
        Expanded(
          child: updateLoader
              ? const Center(
                  child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator()))
              // : noMatchedLeads || noRecordFound
              //     ? const Center(
              //         child: Text(
              //           "No Record Found",
              //           style: TextStyle(fontSize: 20),
              //         ),
              //       )
              : allTagsList.isEmpty
                  ? const Center(
                      child: Text(
                        "No Leads Available..",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: allTagsList.length,
                        itemBuilder: (context, index) {
                          print(
                              "index:::::::::::::::::::::::::::::::::::::::::::: ${index}");

                          if (index >= allTagsList.length) {
                            return const SizedBox(); // or just return nothing
                          }
                          var tag = allTagsList[index];

                          return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TagAddUpdateView(
                                              tagData: tag,
                                            )));
                              },
                              child: tagRecordList(tag));
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  void _applyFilter(List<String> selectedStatuses) {
    List<TagRecord> filtered = [];

    if (selectedStatuses.contains("Blocked") &&
        selectedStatuses.contains("Active")) {
      filtered = tempTagsList;
    } else if (selectedStatuses.contains("Blocked")) {
      filtered = tempTagsList.where((tag) => tag.status == false).toList();
    } else if (selectedStatuses.contains("Active")) {
      filtered = tempTagsList.where((tag) => tag.status == true).toList();
    }

    setState(() {
      selectTagList = selectedStatuses;
      allTagsList = filtered;
    });
  }

  Widget tagRecordList(TagRecord tag) {
    Color statusColor;
    if (tag.status == true) {
      statusColor = Colors.lightBlue.withOpacity(0.7);
    } else {
      statusColor = AppColor.motivationCar1Color;
    }

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
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 3,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${tag.name}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            // tag.autoTagRules!.isEmpty ? Text("Rule : ") :

            tag.autoTagRules!.isEmpty
                ? SizedBox()
                : const Padding(
                    padding: EdgeInsets.only(top: 8.0, left: 5, bottom: 4),
                    child: Text(
                      "Auto Tag Rules : ",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            Wrap(
              spacing: 10,
              children: tag.autoTagRules!.map((tag) {
                return Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: Container(
                    decoration: const BoxDecoration(
                        // border: Border.all(
                        //   color: AppColor.navBarIconColor,
                        // ),
                        // color: Colors.blue.withOpacity(0.2),
                        // borderRadius: BorderRadius.circular(4)
                        ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Icon(
                          //   FontAwesomeIcons.tags,
                          //   size: 12,
                          //   color: AppColor.navBarIconColor,
                          // ),
                          const CircleAvatar(
                            backgroundColor: AppColor.navBarIconColor,
                            radius: 4,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                              child: RichText(
                            text: TextSpan(
                              style:
                                  const TextStyle(fontSize: 12), // base style
                              children: [
                                const TextSpan(
                                  text: 'Keyword: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: '${tag.keyword ?? ""}  ',
                                  style: const TextStyle(
                                    color: AppColor.navBarIconColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const TextSpan(
                                  text: 'Match: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: tag.matchType ?? "",
                                  style: const TextStyle(
                                    color: AppColor.navBarIconColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            // Container(
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(100),
            //     color: Colors.lightBlue.withOpacity(0.7),
            //   ),
            //   child: Padding(
            //     padding:
            //         const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
            //     child: Text(
            //       "${model.leadstatus?.isNotEmpty == true ? model.leadstatus : ''}",
            //       style: const TextStyle(
            //         fontSize: 10,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  List<String> selectTagList = [];

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      enableDrag: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                                  'Tags Status Filter',
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
                          // border: Border.all(
                          //   color: Colors.black,
                          //   width: 0.2,
                          // ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MultiSelectDialogField<String>(
                              items: ['Active', 'Blocked']
                                  .map((e) => MultiSelectItem<String>(e, e))
                                  .toList(),
                              title: const Text(
                                "Select Tag Status",
                                style: TextStyle(fontSize: 15),
                              ),
                              buttonText: const Text("Select Tag Status"),
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
                                  selectTagList = selected;
                                });
                              },
                              initialValue: [],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8.0,
                              children: selectTagList.map((selectedItem) {
                                return Chip(
                                  label: Text(selectedItem),
                                  deleteIcon: const Icon(Icons.close),
                                  onDeleted: () {
                                    setState(() {
                                      selectTagList.remove(selectedItem);
                                    });
                                  },
                                  backgroundColor: Colors.blue.withOpacity(0.2),
                                  labelStyle:
                                      const TextStyle(color: Colors.blue),
                                );
                              }).toList(),
                            ),
                          ],
                        )

                        //  DropdownButtonFormField<String>(
                        //   hint: const Text('Select Status'),
                        //   items: uniquePaymentTerms.map((String value) {
                        //     return DropdownMenuItem<String>(
                        //       value: value,
                        //       child: Text(value),
                        //     );
                        //   }).toList(),
                        //   onChanged: (String? newValue) {
                        //     setState(() {
                        //       selectedcampaign = newValue;
                        //     });
                        //   },
                        //   value: selectedcampaign,
                        // ),
                        ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(
                              () {
                                selectTagList = [];
                                allTagsList = tempTagsList;
                              },
                            );
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
                            print("selectTagList:::  ::   ${selectTagList}");
                            allTagsList = [];
                            _applyFilter(selectTagList);

                            setState(() {});
                            Navigator.pop(context);
                            // _filterLeads(selectCampList);
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
}
