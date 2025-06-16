import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/models/tags_lsit_model.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/view_models/lead_list_vm.dart';
import 'package:whatsapp/view_models/tags_list_vm.dart';
import 'package:whatsapp/views/view/tag_add_update_view.dart';

class TagsListView extends StatefulWidget {
  const TagsListView({super.key});

  @override
  State<TagsListView> createState() => _TagsListViewState();
}

class _TagsListViewState extends State<TagsListView> {
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
              // controller: textController,
              // onChanged: _filterLeads,
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
                          // _showFilterBottomSheet(context);
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
                          var unreadCount = "0";
                          var tag = allTagsList[index];

                          return tagRecordList(tag);
                        },
                      ),
                    ),
        ),
      ],
    );
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
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            tag.autoTagRules!.isEmpty
                ? const Text(
                    "Rule: -",
                    style: TextStyle(fontSize: 12),
                  )
                : Text(
                    "Rule: ${tag.autoTagRules!.first.keyword ?? ""}",
                    style: const TextStyle(fontSize: 12),
                  ),
            tag.autoTagRules!.isEmpty
                ? SizedBox()
                : Text(
                    "${tag.autoTagRules!.first.matchType ?? ""}",
                    style: const TextStyle(fontSize: 12),
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
}
