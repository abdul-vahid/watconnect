// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print, avoid_function_literals_in_foreach_calls, unnecessary_const

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/models/tags_list_model.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/app_utils.dart';
import 'package:whatsapp/view_models/tags_list_vm.dart';
import 'package:whatsapp/views/view/lead_add_update_view.dart';
import 'package:whatsapp/views/view/tags_list_view.dart';

// ignore: must_be_immutable
class TagAddUpdateView extends StatefulWidget {
  TagRecord? tagData;
  TagAddUpdateView({super.key, this.tagData});

  @override
  State<TagAddUpdateView> createState() => _TagAddUpdateViewState();
}

class _TagAddUpdateViewState extends State<TagAddUpdateView> {
  final GlobalKey<FormState> _addTagFormKey = GlobalKey<FormState>();

  TextEditingController tagNameController = TextEditingController();

  // TextEditingController keywordController = new TextEditingController();

  bool firstMsg = false;
  bool isActive = true;

  int ruleLenght = 0;
  String? leadStatus;
  List<AutoTagRule> autoTagRules = [];

  final List<String> matchList = [
    "exact",
    "contains",
  ];

  @override
  void initState() {
    if (widget.tagData != null) {
      tagNameController.text = widget.tagData?.name ?? "";
      isActive = widget.tagData?.status ?? true;
      firstMsg = widget.tagData?.firstMessage == 'Yes' ||
              widget.tagData?.firstMessage == 'yes'
          ? true
          : false;

      widget.tagData?.autoTagRules?.forEach((rule) {
        autoTagRules.add(
          AutoTagRule(
            controller: TextEditingController(text: rule.keyword ?? ""),
            matchType: rule.matchType,
          ),
        );
      });
    } else {
      ruleLenght = 0;
      autoTagRules = [];
      firstMsg = false;
      isActive = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: Container(
          height: 49,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              // First button (Submit/Update)
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cardsColor,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (widget.tagData == null) {
                      if (_addTagFormKey.currentState!.validate()) {
                        createTag();
                      }
                    } else {
                      if (_addTagFormKey.currentState!.validate()) {
                        updateTag();
                      }
                    }
                  },
                  child: Text(
                    widget.tagData == null ? "Submit" : "Update",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(
                      width: 1.0,
                      color: Colors.black,
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          elevation: 2,
          title: const Text(
            "Add New Tag",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _pageBody(),
      ),
    );
  }

  _pageBody() {
    return SingleChildScrollView(
      child: Form(
          key: _addTagFormKey,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 5,
                        spreadRadius: 3,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      detailsHeading(
                        title: "Tag Information",
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            const Text('Tag Name',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 5),
                            AppUtils.getTextFormField(
                              'Enter Tag Name',
                              controller: tagNameController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please provide tag name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const Expanded(
                      flex: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Status",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Text(
                          //     "Allows auto tagging if users' first message matches")
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Transform.scale(
                        scale: 0.9,
                        child: Switch(
                          inactiveThumbColor: Colors.grey.withOpacity(0.8),
                          activeTrackColor:
                              AppColor.navBarIconColor.withOpacity(0.4),
                          activeColor: AppColor.navBarIconColor,
                          value: isActive,
                          onChanged: (value) {
                            setState(() {
                              isActive = value;
                            });
                            print("isActive: $value");
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const Expanded(
                      flex: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "First Message",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                              "Allows auto tagging if users' first message matches")
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Transform.scale(
                        scale: 0.9,
                        child: Switch(
                          inactiveThumbColor: Colors.grey.withOpacity(0.8),
                          activeTrackColor:
                              AppColor.navBarIconColor.withOpacity(0.4),
                          activeColor: AppColor.navBarIconColor,
                          value: firstMsg,
                          onChanged: (value) {
                            setState(() {
                              firstMsg = value;
                              resetAutoTagRule();
                              addAutoTagRule();
                            });
                            print("firstMsg: $value");
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                firstMsg
                    ? Column(
                        children: [
                          const SizedBox(height: 15),
                          Container(
                            decoration: BoxDecoration(
                                color: AppColor.navBarIconColor,
                                borderRadius: BorderRadius.circular(08)),
                            height: 40,
                            width: double.infinity,
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Tag Rules',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Header Row with Add Button
                          Row(
                            children: [
                              const Expanded(
                                flex: 8,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Auto Tag Rules",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        "Define keywords to automatically apply this tag")
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: GestureDetector(
                                  onTap: addAutoTagRule,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE6E6E6),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(),
                                    ),
                                    padding: const EdgeInsets.all(4.0),
                                    child: const Center(
                                      child:
                                          Icon(Icons.add, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          ...autoTagRules.asMap().entries.map((entry) {
                            int index = entry.key;
                            AutoTagRule rule = entry.value;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColor.navBarIconColor
                                            .withOpacity(0.2),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.4),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 18),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Keyword',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        AppUtils.getTextFormField(
                                          'Enter Keyword',
                                          controller: rule.controller,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please provide keyword';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Match Type',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        AppUtils.getDropdown(
                                          '--Select--',
                                          onChanged: (value) {
                                            setState(() {
                                              rule.matchType = value;
                                            });
                                          },
                                          validator: (value) => value == null
                                              ? 'Please Provide Match'
                                              : null,
                                          data: matchList,
                                          value: rule.matchType ?? "exact",
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Delete Button
                                  Positioned(
                                    right: 4,
                                    top: 0,
                                    child: GestureDetector(
                                      onTap: () => removeAutoTagRule(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColor.navBarIconColor
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColor.navBarIconColor,
                                            width: 1.3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              spreadRadius: 1,
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          size: 18,
                                          color: AppColor.navBarIconColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList()
                        ],
                      )
                    : const SizedBox()
              ],
            ),
          )),
    );
  }

  void addAutoTagRule() {
    setState(() {
      autoTagRules.add(AutoTagRule(
        controller: TextEditingController(),
      ));
    });
    print("autoTagRules::::::::after add::::   $autoTagRules");
  }

  void resetAutoTagRule() {
    setState(() {
      autoTagRules.clear();
    });
    print("autoTagRules::::::::after add::::   $autoTagRules");
  }

  void removeAutoTagRule(int index) {
    setState(() {
      autoTagRules.removeAt(index);
    });
    print("autoTagRules::::::::after remove::::   $autoTagRules");
  }

  Future<void> createTag() async {
    List autoTags = [];
    autoTagRules.forEach((rule) {
      print(
          "Keyword: ${rule.controller.text}, Match Type: ${rule.matchType ?? "exact"}");
      Map body = {
        "keyword": rule.controller.text.trim(),
        "match_type": rule.matchType?.toLowerCase() ?? "exact"
      };

      autoTags.add(body);
    });

    Map body = {};

    if (firstMsg && autoTags.isNotEmpty) {
      body = {
        "name": tagNameController.text.trim(),
        "status": isActive,
        "first_message": "Yes",
        "auto_tag_rules": autoTags
      };
    } else {
      body = {
        "name": tagNameController.text.trim(),
        "status": isActive,
        "first_message": "No",
        "auto_tag_rules": []
      };
    }

    await Provider.of<TagsListViewModel>(context, listen: false)
        .addTag(body)
        .then((onValue) {
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                        create: (_) => TagsListViewModel(context))
                  ],
                  child: const TagsListView(),
                )),
      );
    });

    print("body:: in api : $body");
  }

  Future<void> updateTag() async {
    List autoTags = [];
    autoTagRules.forEach((rule) {
      print(
          "Keyword: ${rule.controller.text}, Match Type: ${rule.matchType ?? "exact"}");
      Map body = {
        "keyword": rule.controller.text.trim(),
        "match_type": rule.matchType?.toLowerCase() ?? "exact"
      };

      autoTags.add(body);
    });

    Map body = {};

    if (firstMsg && autoTags.isNotEmpty) {
      body = {
        "id": widget.tagData?.id,
        "name": tagNameController.text.trim(),
        "status": isActive,
        "first_message": "Yes",
        "createddate": widget.tagData?.createddate,
        "lastmodifieddate": widget.tagData?.lastmodifieddate,
        "createdbyid": widget.tagData?.createdbyid,
        "lastmodifiedbyid": widget.tagData?.lastmodifiedbyid,
        "auto_tag_rules": autoTags
      };
    } else {
      body = {
        "id": widget.tagData?.id,
        "name": tagNameController.text.trim(),
        "status": isActive,
        "createddate": widget.tagData?.createddate,
        "lastmodifieddate": widget.tagData?.lastmodifieddate,
        "createdbyid": widget.tagData?.createdbyid,
        "lastmodifiedbyid": widget.tagData?.lastmodifiedbyid,
        "first_message": "No",
        "auto_tag_rules": []
      };
    }

    await Provider.of<TagsListViewModel>(context, listen: false)
        .updateTag(
      body,
      widget.tagData?.id ?? "",
    )
        .then((onValue) {
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                        create: (_) => TagsListViewModel(context))
                  ],
                  child: const TagsListView(),
                )),
      );
    });

    print("update tag body:::::: $body");
  }
}

class AutoTagRule {
  TextEditingController controller;
  String? matchType;

  AutoTagRule({required this.controller, this.matchType});
}
