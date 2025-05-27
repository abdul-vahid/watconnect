import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:whatsapp/main.dart';
import 'package:whatsapp/models/groups_model/groups_model.dart';
import 'package:whatsapp/models/template_model/template_model.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/view_models/lead_list_vm.dart';
import '../../models/approved_template_model/aprovedtempltemodel/component.dart';
// import '../../models/campaigndetail_model.dart';
// import '../../models/campaigndetail_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_utils.dart';
import 'package:file_picker/file_picker.dart';
import '../../utils/function_lib.dart';
import '../../view_models/campaign_vm.dart';
import '../../view_models/groups_view_model.dart';
import '../../view_models/message_list_vm.dart';
import '../../view_models/templete_list_vm.dart';
import 'package:whatsapp/models/campaign_model/record.dart';

import 'campaign_list_view.dart';

class CampaignCloneview extends StatefulWidget {
  final Record? model;
  final Record record; // Add this line
  const CampaignCloneview({
    Key? key,
    this.model,
    required this.record,
  }) : super(key: key);

  @override
  State<CampaignCloneview> createState() => _Forms();
}

class _Forms extends State<CampaignCloneview> {
  bool _isLoading = false;
  String? fileid;

  String imgToShow = "";
  late VideoPlayerController _Vcontroller;
  late MessageViewModel messageViewModel;
  final _addleadFormKey = GlobalKey<FormState>();
  final TextEditingController _dateStartInput = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController fileNameController = TextEditingController();
  final TextEditingController _tempController = TextEditingController();
  var leadlistvm;
  TempleteListViewModel? templateVM;
  GroupsViewModel? groupsVM;
  CampaignViewModel? _getaccountData;
  bool isEdit = false;
  String? base64Img;
  XFile? pickedFile;
  int count = 0;
  PlatformFile? file;
  File? image;
  File? csvFile;
  late CampaignViewModel campaignvm;
  List<Map<String, dynamic>> selectedMembers = [];
  String? _description, _type;
  String? selectedTemplateName;
  String? SelectedTemplateCategory;
  String? selectedTemplateId;
  var selectedLanguage;
  var selectedHeader;
  var selectedBody;
  var selectedFooter;
  bool isRefresh = false;
  dynamic selectedButtons;
  List<TextEditingController> controllers = [];
  List<Map<String, String>> groupsNameSet = [];
  List<String> GroupsName = [];
  List<String> selectedGroupsName = [];
  List<String> templateIds = [];
  List<String> templateNames = [];

  List<String> selectedGroups = [];
  // List<String> tempateCategory = [];
  List<dynamic> tempateCategory = [
    'All',
    'UTILITY',
    'MARKETING',
    'AUTHENTICATION'
  ];
  List<String> templateName1 = [];
  List<dynamic> types = [
    'Advertisement',
    'Banner Ads',
    'Conference',
    'Direct Mail',
    'Email',
    'Partners',
    'Public Relations',
    'Web',
    'Other',
  ];

  Map<String, Map<String, String>> allTemplatesMap = {};
  var number;

  List<String> selectedCampleadList = [];
  List<String> selectedNamesWithNumbers = [];
  List campLeadNameNum = [];
  List<Map<String, String>> leadsInCamp = [];

  @override
  void initState() {
    super.initState();
    templateVM = Provider.of<TempleteListViewModel>(context, listen: false);
    groupsVM = Provider.of<GroupsViewModel>(context, listen: false);
    templateApiCall();

    groupsVM!.fetchGroups();
    _dateStartInput.text = formatDateWithTimezone(DateTime.now());
    getdatabyid();
    campLeadList();

    // print("Ddddddddddddd${model.name!}");
    super.initState();

    Provider.of<GroupsViewModel>(context, listen: false).fetchGroups();
  }

  Future<void> saveNumberData() async {
    final prefs = await SharedPreferences.getInstance();
    number = prefs.getString('phoneNumber');
    debug("this is my number $number");
    Provider.of<TempleteListViewModel>(
      context,
      listen: false,
    ).templetefetch(number: number ?? "");
  }

  String name = "";
  String tenatCode = "";
  String cloneCsvName = "";
  String cloneCsvSize = "";
  String cloneCsvType = "";
  String cloneCsvDesc = "";

  Future<void> getdatabyid() async {
    print("working.........");

    try {
      CampaignViewModel campVM =
          Provider.of<CampaignViewModel>(context, listen: false);
      await campVM
          .getcampaignbyid(widget.record.campaignId.toString())
          .then((onValue) async {
        // print("onValue::::::::::: >>>>>>    ${onValue}");
        for (var viewModel in campVM.viewModels) {
          var model = viewModel.model;
          // print(" model.name===>$model");
          // print(" model.rec===>${model.record.campaignType}");
          // print("types:::::: ${types}");
          final prefs = await SharedPreferences.getInstance();
          setState(() {
            tenatCode =
                prefs.getString(SharedPrefsConstants.usertenantcodeKey) ?? "";
            _name.clear();
            _name.text = model.record.campaignName ?? "";
            _type = model.record.campaignType ?? "";
            // _dateStartInput.text = model.record.startDate.toString();
            fileNameController.text = model.record.fileTitle ?? "";

            cloneCsvName = model.record.fileTitle ?? "";
            cloneCsvSize = model.record.fileSize ?? "";
            cloneCsvType = model.record.fileType ?? "";
            cloneCsvDesc = model.record.fileDescription ?? "";

            // String fileTitle = model.record.fileTitle ?? "";

            print(
                "csvFile:::::: after set:::: ${csvFile}    ${csvFile.runtimeType}");
            _description = model.record.fileDescription;
            groupsNameSet = model.record.groups ?? [];

            print("imgToShow::::${imgToShow}");
            print("groupsNameSet::: ${groupsNameSet}");
            selectedGroupsName =
                groupsNameSet.map((e) => e['id'].toString()).toList();
            // _tempController.text = model.record.templateName;
            // selectedTemplateName = model.record.templateName;
            print("model.record. lead::: : ${model.record.lead_ids ?? []}");
            selectedMembers = model.record.lead_ids ?? [];
            List<Map<String, String>> lst = model.record.lead_ids ?? [];
            // leadsInCamp = selectedCampleadList = model.record.lead_ids ?? [];
            selectedCampleadList = lst
                .map((e) => '${e['name']} - ${e['whatsapp_number']}')
                .toList();
            selectedNamesWithNumbers = selectedCampleadList;

            selectedGroups =
                groupsNameSet.map((e) => e['name'].toString()).toList();
            print(
                "selectedTemplateName:::  ${groupsNameSet}   ${selectedGroups}    ${selectedTemplateName}");
          });
        }
        // _setSelectedTemplates();
      });
    } catch (e, stackTrace) {
      print("error in setting data::: ${e}       ${stackTrace}");
    }

    print("_name_name${_name.text}");
  }

  Future<void> saveFileToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (base64Img != null) {
      await prefs.setString('uploaded_file_base64', base64Img!);
    }
  }

  String formatDateWithTimezone(DateTime dateTime) {
    final formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    return formatted;
  }

  var currentTemplate;
  List<Component> components = [];
  Future<void> _setSelectedTemplates() async {
    TempleteListViewModel templeteViewModel =
        Provider.of<TempleteListViewModel>(context, listen: false);
    if (templeteViewModel.viewModels.isNotEmpty) {
      for (var viewModel in templeteViewModel.viewModels) {
        var campaignModel = viewModel.model;
        if (campaignModel?.data != null) {
          for (var record in campaignModel!.data!) {
            if (record.status != null) {
              // print("rec name ::${record.name}  $selectedTemplateName");

              if (selectedTemplateName == record.name) {
                currentTemplate = record;

                print("record.category::: ${record.category}  ${record.name}");
                SelectedTemplateCategory = record.category;
                selectedTemplateId = currentTemplate.id;
                selectedLanguage = currentTemplate.language;
                print(
                    "selectedTemplateId:::::  ${currentTemplate.id}  $selectedTemplateId ");
                print(
                    "other info:: ${currentTemplate.components}   ${currentTemplate.components.runtimeType}");
                components = currentTemplate.components;
                print("Component info:: ${components.length} $components");

                for (var e in components) {
                  print("checking the type:: ${e.type}");
                  if (e.type == "HEADER") {
                    selectedHeader = e;
                  } else if (e.type == "BODY") {
                    selectedBody = e;
                  } else if (e.type == "FOOTER") {
                    selectedFooter = e;
                  } else if (e.type == "BUTTONS") {
                    selectedButtons = e;
                  }
                }
                setState(() {});
                print(
                    "components $selectedHeader   $selectedBody  $selectedButtons");
                return;
              }
            }
          }
        }
      }
    }
  }

  bool isChecked = false;

  bool isOtherFileSelected = false;
  Future<void> _sendTemplateSheet() {
    TextEditingController _templateController = TextEditingController();
    int selectedBtnIdx = 0;
    SelectedTemplateCategory = null;
    // selectedTemplateName = null;
    isChecked = false;
    image = null;
    String text = selectedBody.text;
    imgToShow = "";
    if (selectedHeader != null &&
        selectedHeader.example != null &&
        selectedHeader.example.headerHandle != null &&
        selectedHeader.example.headerHandle.isNotEmpty) {
      print("selectedHeader>>> ${selectedHeader.example.headerHandle}");
      imgToShow = selectedHeader.example.headerHandle[0];
    } else {
      imgToShow = "";
    }
    controllers.clear();
    setState(() {
      _isLoading = false;
    });
    final regex = RegExp(r'\{\{\d+\}\}');

    count = regex.allMatches(text).length;
    file = null;
    controllers = List.generate(count, (index) => TextEditingController());
    isOtherFileSelected = false;

    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      enableDrag: false,
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => true,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.80,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Review Campaign",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.highlight_remove_outlined,
                              color: AppColor.navBarIconColor,
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                      const Divider(thickness: 1),
                      const SizedBox(height: 5),
                      Column(
                        children: List.generate(count, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextField(
                              controller: controllers[index],
                              decoration: InputDecoration(
                                labelText:
                                    "Enter value for placeholder ${index + 1}",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          );
                        }),
                      ),
                      Card(
                        elevation: 5,
                        color: const Color(0xffE3FFC9).withOpacity(0.5),
                        shadowColor: Colors.black38,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Align content properly
                            children: [
                              // Handle different formats (IMAGE, VIDEO, DOCUMENT)
                              if (selectedHeader != null &&
                                  selectedHeader.format != null)
                                file != null && selectedHeader.format == 'IMAGE'
                                    ? Image.file(image!)
                                    : file != null &&
                                            selectedHeader.format == 'VIDEO'
                                        ? Container(
                                            height: 150,
                                            width: 150,
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: const Center(
                                              child: Icon(
                                                Icons.play_arrow_rounded,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            ),
                                          )
                                        : file != null &&
                                                selectedHeader.format ==
                                                    'DOCUMENT'
                                            ? Image.asset(
                                                "assets/images/pdf.png",
                                                height: 100,
                                              )
                                            : _buildMediaWidget(
                                                selectedHeader.format,
                                                imgToShow),

                              if (selectedBody != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text("${selectedBody.text}"),
                                ),

                              const SizedBox(height: 10),

                              if (selectedButtons != null)
                                Wrap(
                                  spacing: 10,
                                  children: List.generate(
                                    selectedButtons.buttons.length,
                                    (index) {
                                      return ElevatedButton(
                                        onPressed: () {
                                          print("Button ${index + 1} clicked");
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[400],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            side: const BorderSide(
                                                color:
                                                    AppColor.navBarIconColor),
                                          ),
                                        ),
                                        child: Text(
                                          selectedButtons.buttons[index].text,
                                          style: const TextStyle(
                                              color: AppColor.navBarIconColor),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                              const SizedBox(height: 15),

                              if (selectedFooter != null)
                                Text(
                                  selectedFooter.text,
                                  style: const TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.left,
                                ),

                              const SizedBox(height: 15),

                              if (selectedHeader != null)
                                selectedHeader.format == 'IMAGE' ||
                                        selectedHeader.format == 'VIDEO' ||
                                        selectedHeader.format == 'DOCUMENT'
                                    ? InkWell(
                                        onTap: () {
                                          if (selectedHeader.format ==
                                              'IMAGE') {
                                            _pickImaFromGallery()
                                                .then((onValue) {
                                              if (onValue != null) {
                                                setState(() {
                                                  image = onValue;
                                                  isOtherFileSelected = true;
                                                });
                                              }
                                            });
                                          } else if (selectedHeader.format ==
                                              'VIDEO') {
                                            _pickVideoFromGallery()
                                                .then((onValue) {
                                              if (file != null) {
                                                setState(() {
                                                  isOtherFileSelected = true;
                                                });
                                              }
                                            });
                                          } else if (selectedHeader.format ==
                                              'DOCUMENT') {
                                            _pickDocFromGallery()
                                                .then((onValue) {
                                              if (file != null) {
                                                setState(() {
                                                  isOtherFileSelected = true;
                                                });
                                              }
                                            });
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.grey[400],
                                              border: Border.all(
                                                  color: AppColor
                                                      .navBarIconColor)),
                                          child: const Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8.0),
                                              child: Text("Choose File"),
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                              const SizedBox(
                                height: 10,
                              ),

                              Row(
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        isChecked = value!;
                                      });
                                    },
                                  ),
                                  const Expanded(
                                    child: Text(
                                      "Send on login user WhatsApp number also",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: StatefulBuilder(
                          builder: (BuildContext context, StateSetter _) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                backgroundColor: AppColor.navBarIconColor,
                              ),
                              onPressed: () async {
                                if (_isLoading) return;

                                setState(() {
                                  _isLoading = true;
                                });

                                Map<String, String> bodyTextParams = {};
                                List compoTextParams = [];
                                List numberedCampParam = [];

                                bool anyEmpty = controllers.any(
                                    (controller) => controller.text.isEmpty);
                                if (anyEmpty) {
                                  EasyLoading.showToast(
                                      'All fields are required');
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  return;
                                }

                                File? imageFile;
                                String docId = "";

                                for (int i = 0; i < controllers.length; i++) {
                                  bodyTextParams[(i + 1).toString()] =
                                      controllers[i].text;
                                  Map body = {
                                    "type": "text",
                                    "text": controllers[i].text,
                                  };
                                  compoTextParams.add(body);
                                  numberedCampParam.add(bodyTextParams);
                                }

                                // print(
                                //     "selectedHeader.format::::: ${selectedHeader}    ${selectedHeader.format}");

                                if (selectedHeader == null) {
                                  String templateToSend =
                                      selectedTemplateName ??
                                          _templateController.text;

                                  _tempController.text =
                                      selectedTemplateName ?? "";
                                  setState(() {
                                    _isLoading = false;
                                  });

                                  Navigator.pop(context);
                                  return;
                                }

                                if (selectedHeader.format == "IMAGE" ||
                                    selectedHeader.format == "VIDEO" ||
                                    selectedHeader.format == "DOCUMENT") {
                                  if (isOtherFileSelected == false) {
                                    EasyLoading.showToast(
                                        "Choose File To Continue");
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    return;
                                  } else {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    String? number =
                                        prefs.getString('phoneNumber');

                                    await messageViewModel
                                        .uploadCampFiledb(image!, number,
                                            isFromCamp: true)
                                        .then((value) {
                                      Map<String, dynamic> response =
                                          jsonDecode(value);

                                      setState(() {
                                        fileid = response['data']?[0][
                                            'id']; // <-- now globally available
                                      });

                                      print("File ID: $fileid");
                                    });
                                  }
                                  // else {
                                  //   image = await urlToFile(imgToShow);
                                  // }
                                }
                                String templateToSend = selectedTemplateName ??
                                    _templateController.text;

                                _tempController.text =
                                    selectedTemplateName ?? "";
                                setState(() {
                                  _isLoading = false;
                                });
                                if (mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      "Done",
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.white),
                                    ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _pageBody() {
    // print("_types:::: ::: :${types} ${_type}");
    return SingleChildScrollView(
      child: Form(
        key: _addleadFormKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Campaign Name'),
              const SizedBox(height: 5),
              AppUtils.getTextFormField(
                'Enter Campaign Name',
                onSaved: (value) => _name.text = value!,
                controller: _name,
                validator: (value) => value!.isEmpty ? 'Required' : null,
                onChanged: (p0) => setState(() => _name.text = p0),
              ),
              const SizedBox(height: 10),
              const Text('Start Date & Time'),
              const SizedBox(height: 5),
              TextFormField(
                controller: _dateStartInput,
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.calendar_month,
                      color: AppColor.navBarIconColor),
                  hintText: 'yyyy-MM-dd HH:mm:ss',
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                readOnly: true,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter date' : null,
                onTap: () async {
                  DateTime? dateTime =
                      await showOmniDateTimePicker(context: context);
                  if (dateTime != null) {
                    _dateStartInput.text = formatDateWithTimezone(dateTime);
                  }
                },
              ),
              const SizedBox(height: 10),
              const Text('Select Template Category*'),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  _getBootmSheet();
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: _tempController,
                    decoration: const InputDecoration(
                      // labelText: 'Tap to choose',
                      suffixIcon: Icon(Icons.arrow_drop_down),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text('Group Name'),
              const SizedBox(height: 5),
              MultiSelectDialogField(
                dialogHeight: 160,
                items: groupsNameSet
                    .map(
                      (group) => MultiSelectItem<String>(
                        group['id']!,
                        group['name']!,
                      ),
                    )
                    .toList(),
                initialValue: selectedGroupsName,
                title: groupsNameSet.isEmpty
                    ? const Center(
                        child: Text(
                        "No Groups Available",
                        style: TextStyle(fontSize: 18),
                      ))
                    : Text("Select Groups"),
                selectedColor: Colors.blue,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                buttonText: const Text("Select Groups"),
                chipDisplay: MultiSelectChipDisplay.none(),
                onConfirm: (results) {
                  print("results:::: ${results}");
                  setState(() {
                    selectedGroupsName = results.cast<String>();
                  });
                  debug(
                    "Selected groups: $selectedGroupsName",
                  );
                },
              ),
              Wrap(
                spacing: 8.0,
                children: selectedGroupsName.map((selectedItem) {
                  print("Selected Item => $selectedItem");
                  return Chip(
                    label: Text(selectedItem),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () {
                      setState(() {
                        selectedGroupsName.remove(selectedItem);
                      });
                    },
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    labelStyle: const TextStyle(color: Colors.blue),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              const Text('Select Leads'),
              MultiSelectDialogField<Map<String, dynamic>>(
                items: allContactDetails.map((member) {
                  return MultiSelectItem<Map<String, dynamic>>(
                    member,
                    "${member['name']} (${member['whatsapp_number']})",
                  );
                }).toList(),
                title: allContactDetails.isEmpty
                    ? const Center(
                        child: Text(
                        "No Leads Available",
                        style: TextStyle(fontSize: 18),
                      ))
                    : const Text("Select Leads"),
                selectedColor: Colors.blue,
                decoration: BoxDecoration(
                  // color: Colors.blue.withOpacity(0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                    color: Colors.blue,
                    width: 1,
                  ),
                ),
                buttonIcon: const Icon(
                  Icons.add,
                  // color: Colors.blue,
                ),
                buttonText: const Text(
                  "Select Leads",
                  style: TextStyle(
                    // color: Colors.blue[800],
                    fontSize: 16,
                  ),
                ),
                searchable: true,
                chipDisplay: MultiSelectChipDisplay.none(),
                initialValue: selectedMembers,
                onConfirm: (values) {
                  setState(() {
                    selectedMembers = values;
                    print("selectedMembers::::::: ${selectedMembers}");
                    // Update display list
                    selectedNamesWithNumbers = values
                        .map((member) =>
                            "${member['name']} (${member['whatsapp_number']})")
                        .toList();
                  });
                },
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                children: selectedNamesWithNumbers.map((selectedItem) {
                  return Chip(
                    label: Text(selectedItem),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () {
                      setState(() {
                        // Remove from display list
                        selectedNamesWithNumbers.remove(selectedItem);

                        // Remove the corresponding map from selectedMembers
                        selectedMembers.removeWhere((member) =>
                            "${member['name']} (${member['whatsapp_number']})" ==
                            selectedItem);

                        print("selectedMembers::: ${selectedMembers}");
                      });
                    },
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    labelStyle: const TextStyle(color: Colors.blue),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              const Text('File Upload'),
              const SizedBox(height: 5),
              TextFormField(
                controller: fileNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  hintText: 'Choose File',
                  suffixIcon: const Icon(Icons.add),
                ),
                readOnly: true,
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(
                    allowMultiple: true,
                    type: FileType.custom,
                    allowedExtensions: ['csv'],
                  );
                  if (result != null) {
                    file = result.files.first;
                    setState(() {
                      csvFile = File(file!.path.toString());
                    });

                    base64Img =
                        base64Encode(File(file!.path!).readAsBytesSync());
                    fileNameController.text = file!.name;
                    await saveFileToPrefs();
                  }
                },
              ),
              const SizedBox(height: 10),
              cloneCsvName.isNotEmpty && csvFile == null
                  ? InkWell(
                      onTap: () {
                        downloadCsv(
                            "https://admin.watconnect.com/public/${tenatCode}/campaign_files/${cloneCsvName}",
                            cloneCsvName);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: AppColor.navBarIconColor,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Center(
                            child: Text(
                              "Download CSV",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ))
                  : const SizedBox(),
              const SizedBox(
                height: 10,
              ),
              const Text('Type'),
              const SizedBox(height: 5),
              AppUtils.getDropdown(
                'Select',
                data: types,
                onChanged: (p0) {
                  setState(() {
                    _type = p0;
                    print("_typ $_type");
                  });
                },
                value: _type,
              ),
              const SizedBox(height: 10),
              const Text('Description'),
              const SizedBox(height: 5),
              AppUtils.getTextFormField(
                'type description here..',
                initialValue: _description ?? '',
                onSaved: (val) => _description = val,
                maxLines: 5,
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    if (widget.model != null) {
      return;
    }
    Provider.of<CampaignViewModel>(context, listen: false).fetchCampaign();

    isRefresh = true;
    return Future<void>.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    messageViewModel = Provider.of<MessageViewModel>(context);
    leadlistvm = Provider.of<LeadListViewModel>(context);
    groupsVM = Provider.of<GroupsViewModel>(context);

    templateVM = Provider.of<TempleteListViewModel>(context);

    if (templateVM != null && templateVM?.viewModels != null)
      // ignore: curly_braces_in_flow_control_structures
      for (var viewModel in templateVM!.viewModels) {
        TemplateModel tempmodel = viewModel.model;
        for (var record in tempmodel.data ?? []) {
          if (record.name != null && record.category != null) {
            String categoryKey = record.category!.toLowerCase();

            allTemplatesMap.putIfAbsent(categoryKey, () => {});
            allTemplatesMap[categoryKey]?[record.id] = (record.name!);
          }
        }
      }

    for (var viewModel in groupsVM!.viewModels) {
      GroupsModel groupsmodel = viewModel.model;
      for (var record in groupsmodel.records ?? []) {
        if (record.name != null && record.id != null) {
          bool exists = groupsNameSet.any((group) => group['id'] == record.id);
          if (!exists) {
            groupsNameSet.add({'id': record.id!, 'name': record.name!});
          }
        }
      }
    }
    setState(() {
      GroupsName = groupsNameSet
          .map((group) => group['name']!)
          .toList(); // Extract unique names
    });
    _getaccountData = Provider.of<CampaignViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: AppColor.navBarIconColor,
        title: const Text(
          "Clone Campaign",
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: AppUtils.getAppBody(_getaccountData!, _pageBody),
      ),
      bottomNavigationBar: Container(
        // decoration: InputDecoration(border: Border.all(12)),
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
                ),
                onPressed: () {
                  onButtonPressed();
                },
                child: const Text(
                  "Clone",
                  style: TextStyle(
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
                  side: const BorderSide(width: 1.0, color: Colors.black),
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
    );
  }

  void onButtonPressed() async {
    print("selectedGroups>>> $selectedGroups");
    print("selectedLeads>>> $selectedCampleadList");
    if (selectedGroupsName.isEmpty && fileNameController.text.trim().isEmpty) {
      EasyLoading.showToast("Upload a CSV or Select a group");
      return;
    }
    if (selectedTemplateName == null) {
      EasyLoading.showToast("Please Select Template");
      return;
    }
    if (_tempController.text.trim().isEmpty) {
      EasyLoading.showToast("Please Select Template Category");
      return;
    }
    if (_name == null) {
      EasyLoading.showToast("Please enter campaign name");
      return;
    }
    if (_dateStartInput.text.trim().isEmpty) {
      EasyLoading.showToast("Pleaseselect start date and time");
      return;
    }

    addCampaignTemplate();
    // print(
    //   "controllers::: ${controllers}  ${isChecked}  ${image}  ${isOtherFileSelected}  ${imgToShow}",
    // );
    // print(
    //   "controllers::: $controllers  $isChecked  $image  $isOtherFileSelected  $imgToShow",
    // );

    // if (controllers.isNotEmpty) {
    //   bool anyEmpty = controllers.any((controller) => controller.text.isEmpty);
    //   if (anyEmpty) {
    //     EasyLoading.showToast('All fields are required');
    //     return;
    //   }
    // }
    // if (_addleadFormKey.currentState!.validate()) {
    //   if (_name == null || _name.toString().isEmpty) {
    //     print("_name_name_name_name$_name");
    //     EasyLoading.showToast("Campaign Name is required");
    //     return;
    //   } else if (_dateStartInput.text.toString().isEmpty) {
    //     EasyLoading.showToast("Start date time is required");
    //     return;
    //   } else if (SelectedTemplateCategory == null ||
    //       selectedTemplateName.toString().isEmpty) {
    //     EasyLoading.showToast("Select Template Category");
    //     return;
    //   } else if (_type == null || _type.toString().isEmpty) {
    //     EasyLoading.showToast("Select Template Type");
    //     return;
    //   }
    //   _addleadFormKey.currentState!.save();

    // } else {
    //   print("landed here ");
    // }
  }

  Future<void> sendingCamplaign() async {
    Map<String, String> bodyTextParams = {};
    List compoTextParams = [];
    List numberedCampParam = [];

    try {
      print("controllers::: ${controllers.length}");

      for (int i = 0; i < controllers.length; i++) {
        bodyTextParams[(i + 1).toString()] = controllers[i].text;
        Map body = {"type": "text", "text": controllers[i].text};
        compoTextParams.add(body);
        numberedCampParam.add(bodyTextParams);
      }

      String templateToSend = selectedTemplateName ?? "";
      print(
          "templateToSend::: ${templateToSend}  ${compoTextParams}  ${numberedCampParam}");
      print(
          "selected header:: >><><>< ${selectedHeader}     ${templateToSend}");

      if (templateToSend.isEmpty) {
        setState(() {
          _isLoading = false;
          image = null;

          CampaignViewModel getaccountData = CampaignViewModel(context);

          Map<String, dynamic> camp = {
            'name': _name,
            'template_id': selectedTemplateId,
            'template_name': selectedTemplateName,
            'status': 'Pending',
            'business_number': number,
            'type': _type,
            'startDate': _dateStartInput.text,
            'group_ids': selectedGroupsName,
            "lead_ids": selectedMembers,
            'description': _description ?? "",
          };

          getaccountData.addCampaign(camp).then((value) async {
            if (value is Map<String, dynamic>) {
              String? campaignId = value["record"]?["id"];
              print("campaignId>>>  ${campaignId}");
              if (campaignId == null) {
                debug("Campaign ID is null. File upload skipped.");
                return;
              } else {
                Map<String, dynamic> paramBody = {
                  "campaign_id": campaignId,
                  "body_text_params": bodyTextParams,
                  "msg_history_id": null,
                  "file_id": fileid,
                  "whatsapp_number_admin": "7590889022",
                };

                MessageViewModel mstemp = MessageViewModel(context);
                var campaignResponse = await mstemp
                    .sendCampParam(
                  campParambody: paramBody,
                )
                    .then((onValue) async {
                  print("csvFile:::: ${csvFile}    ${fileNameController.text}");

                  if (csvFile != null) {
                    await messageViewModel
                        .uploadCampFiledb(csvFile!, campaignId)
                        .then((onValue) {
                      getaccountData.fetchCampaign();
                    });
                  } else if (csvFile == null &&
                      fileNameController.text.isNotEmpty) {
                    CampaignViewModel campController =
                        CampaignViewModel(context);

                    Map csvClone = {
                      "title": cloneCsvName,
                      "filetype": cloneCsvType,
                      "filesize": cloneCsvSize,
                      "description": cloneCsvDesc,
                      "campaign_id": campaignId
                    };

                    await campController.csvCloneCampaign(csvClone);
                  }
                  // await messageViewModel
                  //     .uploadCampFiledb(image!, campaignId)
                  //     .then((onValue) {
                  //   getaccountData.fetchCampaign();
                  // });
                });
              }

              debug("Uploading file with Campaign ID: $campaignId");

              // await getFileData.addFiles(image!, campaignId, fileData);
            }
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (_) => CampaignViewModel(context),
                    ),
                  ],
                  child: const CampaignListView(),
                ),
              ),
              (Route<dynamic> route) => route.isFirst,
            );
          }).catchError((error, stackTrace) {
            debug("Error: $error");
            Navigator.pop(context);
            AppUtils.getAlert(
              context,
              AppUtils.getErrorMessages(error),
              title: "Error Alert",
            );
          });
        });
      } else {
        await sendTextTemplate(
          templateToSend,
          compoTextParams,
          isChecked,
          bodyTextParams,
        ).then((onValue) {
          setState(() {
            _isLoading = false;
            image = null;

            CampaignViewModel getaccountData = CampaignViewModel(context);
            Map<String, dynamic> camp = {};
            try {
              camp = {
                'name': _name.text,
                'template_id': selectedTemplateId,
                'template_name': selectedTemplateName,
                'status': 'Pending',
                'business_number': number,
                'type': _type,
                'startDate': _dateStartInput.text,
                'group_ids': selectedGroupsName,
                "lead_ids": selectedMembers,
                'description': _description,
              };
            } catch (e) {
              print("errroeL::: ${e}");
            }

            print("camp::::::::::: ${camp}");

            getaccountData.addCampaign(camp).then((value) async {
              if (value is Map<String, dynamic>) {
                String? campaignId = value["record"]?["id"];
                print("campaignId>>>  ${campaignId}");
                if (campaignId == null) {
                  debug("Campaign ID is null. File upload skipped.");
                  return;
                } else {
                  Map<String, dynamic> paramBody = {
                    "campaign_id": campaignId,
                    "body_text_params": bodyTextParams,
                    "msg_history_id": null,
                    "file_id": fileid,
                    "whatsapp_number_admin": "7590889022",
                  };

                  MessageViewModel mstemp = MessageViewModel(context);
                  var campaignResponse = await mstemp
                      .sendCampParam(
                    campParambody: paramBody,
                  )
                      .then((onValue) async {
                    print(
                        "csvFile::  <><>:: ${csvFile}    ${fileNameController.text}");
                    if (csvFile != null) {
                      await messageViewModel
                          .uploadCampFiledb(csvFile!, campaignId)
                          .then((onValue) {
                        getaccountData.fetchCampaign();
                      });
                    } else if (csvFile == null &&
                        fileNameController.text.isNotEmpty) {
                      CampaignViewModel campController =
                          CampaignViewModel(context);

                      Map csvClone = {
                        "title": cloneCsvName,
                        "filetype": cloneCsvType,
                        "filesize": cloneCsvSize,
                        "description": cloneCsvDesc,
                        "campaign_id": campaignId
                      };

                      await campController.csvCloneCampaign(csvClone);
                    }

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MultiProvider(
                          providers: [
                            ChangeNotifierProvider(
                              create: (_) => CampaignViewModel(context),
                            ),
                          ],
                          child: const CampaignListView(),
                        ),
                      ),
                      (Route<dynamic> route) => route.isFirst,
                    );
                  });
                }

                //       debug("Uploading file with Campaign ID: $campaignId");

                //       // await getFileData.addFiles(image!, campaignId, fileData);
              }
              //     Navigator.pushAndRemoveUntil(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => MultiProvider(
              //           providers: [
              //             ChangeNotifierProvider(
              //               create: (_) => CampaignViewModel(context),
              //             ),
              //           ],
              //           child: const CampaignListView(),
              //         ),
              //       ),
              //       (Route<dynamic> route) => route.isFirst,
              //     );
              //   }).catchError((error, stackTrace) {
              //     debug("Error: $error");
              //     Navigator.pop(context);
              //     AppUtils.getAlert(
              //       context,
              //       AppUtils.getErrorMessages(error),
              //       title: "Error Alert",
              //     );
            });
          });
        });
      }
    } catch (e, stackTrace) {
      print("printing error::: ${e}   ${stackTrace}");
    }

    setState(() {
      _isLoading = true;
    });

    print("selected button::: ${selectedButtons} ");
  }

  Future<void> sendTextTemplate(
    String templateToSend,
    List compoTextParams,
    bool sendOnLoginNum,
    Map campaignParam,
  ) async {
    final mstemp = MessageViewModel(context);

    List ba = [];
    if (selectedButtons != null) {
      print("list:::: ${selectedButtons.buttons}");
      ba = selectedButtons.buttons.map((button) => button.toMap()).toList();
    }

    String footer = selectedFooter != null ? selectedFooter?.text ?? "" : "";

    Map<String, dynamic> exBodyText = {
      ...campaignParam,
      "sendToAdmin": sendOnLoginNum,
    };

    Map<String, dynamic> createtemp = {
      "id": selectedTemplateId,
      "name": templateToSend,
      "language": selectedLanguage,
      "header": selectedHeader?.format ?? "",
      "header_body": selectedHeader?.text ?? "",
      "message_body": selectedBody?.text ?? "",
      "example_body_text": exBodyText,
      "footer": footer,
      "buttons": ba,
      "business_number": number,
    };

    print("create map>>> $createtemp");

    try {
      await mstemp.createmsgtemplete(msgmobilbody: createtemp);
    } catch (e) {
      print("Error sending template: $e");
    }
  }

  Future<void> _getBootmSheet() {
    TextEditingController _templateController = TextEditingController();
    int selectedBtnIdx = 0;
    // SelectedTemplateCategory = null;
    // selectedTemplateName = null;
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      enableDrag: false,
      elevation: 1,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Category And Templete",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.highlight_remove_outlined,
                            color: AppColor.navBarIconColor,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 1),
                    const SizedBox(height: 5),
                    AppUtils.getDropdown(
                      'Select Category',
                      data: tempateCategory,
                      onChanged: (String? selectedCategory) {
                        setState(() {
                          SelectedTemplateCategory = selectedCategory;
                          selectedTemplateName = null;
                          templateNames = [];

                          if (selectedCategory != null) {
                            String categoryKey = selectedCategory.toLowerCase();

                            if (SelectedTemplateCategory != 'All') {
                              templateNames = (allTemplatesMap[categoryKey]
                                          ?.values
                                          .toSet()
                                          .toList() ??
                                      [])
                                  .map((e) => e.toString())
                                  .toSet()
                                  .toList();
                            } else {
                              _fetchTemplates();
                            }

                            debug("Selected Category: $categoryKey");
                            debug("Filtered Templates: $templateNames");
                          }
                        });
                      },
                      value: SelectedTemplateCategory,
                    ),
                    const SizedBox(height: 12),
                    AppUtils.getDropdown(
                      'Select Template Name',
                      data: templateNames,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedTemplateName = newValue;
                          _templateController.text = newValue ?? '';
                          if (newValue != null) {
                            int selectedIndex = templateNames.indexOf(newValue);

                            if (selectedIndex >= 0 &&
                                selectedIndex < templateIds.length) {
                              String selectedTemplateId =
                                  templateIds[selectedIndex];

                              print(
                                  "Selected Template ID: $selectedTemplateId");
                            } else {
                              print("Invalid index for the selected template.");
                            }
                          }
                        });
                        print(
                            "selectedTemplateName:::::::::: ${selectedTemplateName}");
                        _setSelectedTemplates();
                      },
                      value: selectedTemplateName,
                    ),
                    Center(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          minimumSize:
                              WidgetStateProperty.all(const Size(10, 20)),
                          padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10)),
                          backgroundColor:
                              WidgetStateProperty.all(AppColor.navBarIconColor),
                        ),
                        onPressed: () {
                          print(
                              "selectedTemplateName>>> ${selectedTemplateName}");
                          if (selectedTemplateName == null ||
                              selectedTemplateName == "Select Template Name") {
                            EasyLoading.showToast("Select Template Name");
                            return;
                          }
                          log("all comp info >> >>  ${selectedHeader}  ${selectedBody} ${selectedFooter} ${selectedButtons}}");
                          log("selectedBody['text']>>> ${selectedBody.text}  ");
                          final regex = RegExp(r'\{\{\d+\}\}');

                          if (regex.hasMatch(selectedBody.text) ||
                              selectedHeader.format != "TEXT") {
                            Navigator.of(context).pop();
                            _sendTemplateSheet();
                          } else {
                            String templateToSend = selectedTemplateName ??
                                _templateController.text;
                            print("Template to send: $templateToSend");

                            setState(() {
                              _tempController.text = selectedTemplateName ?? "";
                            });
                            // templetesendd(templateToSend, []);

                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text(
                          "Send",
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
                      ),
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

  Future<void> _fetchTemplates() async {
    TempleteListViewModel templeteViewModel =
        Provider.of<TempleteListViewModel>(context, listen: false);

    // Check if templeteViewModel is not null and contains viewModels
    Set<String> uniqueTemplateNames = {};

    if (templeteViewModel.viewModels.isNotEmpty) {
      for (var viewModel in templeteViewModel.viewModels) {
        var campaignModel = viewModel.model;
        if (campaignModel?.data != null) {
          for (var record in campaignModel!.data!) {
            if (record.status != null && record.name != null) {
              uniqueTemplateNames.add(record.name);
            }
          }
        }
      }

      // Update the state once with unique values
      setState(() {
        templateNames = uniqueTemplateNames.toList();
        print("templateNames::: :${templateNames}");
      });
    }
  }

  List<Map<String, dynamic>> allContactDetails = [];
  List campLeads = [];
  void campLeadList() async {
    await Provider.of<LeadListViewModel>(navigatorKey.currentContext!,
            listen: false)
        .fetchCampLeads()
        .then((onValue) {
      campLeads = [];
      List tempcampLeadsList = [];
      try {
        for (var viewModel in leadlistvm.viewModels) {
          var recentMsgmodel = viewModel.model;
          if (recentMsgmodel?.records != null) {
            for (var record in recentMsgmodel!.records!) {
              print("record::: ${record}");
              Map<String, dynamic> body = {
                "name": record.contactname,
                "member_id": record.id,
                "recordtypename": "lead",
                "whatsapp_number": record.full_number
              };
              allContactDetails.add(body);
              campLeads.add(record);
              tempcampLeadsList.add(record);
              campLeadNameNum
                  .add("${record.contactname} ${record.full_number}");
            }
          }
        }
      } catch (e) {
        print("e:::::::: ${e}");
        campLeads = [];
      }
    });
  }

  void addCampaignTemplate({File? fileToSend, bool sendToAdmin = false}) {
    sendTemplateApiCall(sendToAdmin);
  }

  Future<void> sendTemplateApiCall(bool send) async {
    final prefs = await SharedPreferences.getInstance();
    number = prefs.getString('phoneNumber');
    print("sending camplagnnnn:::::::   ${selectedButtons}");
    List ba = selectedButtons == null
        ? []
        : selectedButtons?.buttons.map((button) => button.toMap()).toList() ??
            [];
    String hdr = selectedHeader != null ? selectedHeader.format ?? "" : "";

    print("hdr hdr  hdr::: ${hdr}");
    String hdrBody;

    if (hdr.isEmpty) {
      hdrBody = "";
    } else {
      if (hdr == "IMAGE" || hdr == "VIDEO" || hdr == "DOCUMENT") {
        if (imgToShow.isNotEmpty) {
          hdrBody = imgToShow;
        } else {
          hdrBody = selectedHeader.text ?? "";
        }
      } else {
        hdrBody = selectedHeader.text ?? "";
      }
    }

    String footer = selectedFooter != null ? selectedFooter?.text ?? "" : "";
    Map<String, dynamic> createtemp = {
      "id": selectedTemplateId,
      "name": selectedTemplateName,
      "language": selectedLanguage,
      "header": hdr,
      "header_body": hdrBody,
      "message_body": selectedBody != null ? selectedBody.text : "",
      "example_body_text": {"sendToAdmin": send},
      "footer": footer,
      "buttons": ba,
      "business_number": number,
    };
    print("createtemp campaign:::: ${createtemp}");
    late MessageViewModel mstemp = MessageViewModel(context);
    mstemp.createmsgtemplete(msgmobilbody: createtemp).then((value) {
      sendingCamplaign();
    });
  }

  Future<void> templateApiCall() async {
    final prefs = await SharedPreferences.getInstance();
    number = prefs.getString('phoneNumber');
    debug("this is my number $number");
    await Provider.of<TempleteListViewModel>(
      context,
      listen: false,
    ).templetefetch(number: number ?? "").then((onValue) {
      _fetchTemplates();
    });
  }

  Widget _buildMediaWidget(String format, String content) {
    print("format:::::: $format  $content");
    switch (format) {
      case "IMAGE":
        return content.isEmpty
            ? SizedBox(
                height: 80,
                width: 80,
                child: Image.asset("assets/images/img_placeholder.png"),
              )
            : Image.network(content, fit: BoxFit.cover);

      case "VIDEO":
        return content.isNotEmpty
            ? Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              )
            : Container(
                height: 150,
                width: double.infinity,
                color: Colors.black12,
                child: const Center(
                  child: Icon(Icons.videocam_off, size: 40, color: Colors.grey),
                ),
              );

      case "DOCUMENT":
        return content.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  // openDocument(documentUrl); // Function to open the document
                },
                child: Row(
                  children: [
                    Image.asset("assets/images/doc.png",
                        height: 120, width: 120),
                  ],
                ),
              )
            : const SizedBox(); // Empty if no document

      default:
        return const SizedBox(); // If format is unknown
    }
  }

  Future<File?> _pickDocFromGallery() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ["pdf"],
    );
    if (pickedFile != null) {
      setState(() {
        file = pickedFile.files.first;
        image = File(file!.path!);
        // _Vcontroller = VideoPlayerController.file(image!);
        print("image::: $image");

        // fileNameController.text = file!.name;
      });
      return image;
    } else {
      return null;
    }
  }

  Future<File?> _pickVideoFromGallery() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ["mp4", 'mov'],
    );
    if (pickedFile != null) {
      setState(() {
        file = pickedFile.files.first;
        image = File(file!.path!);
        _Vcontroller = VideoPlayerController.file(image!);
        print("image::: $image");
        // fileNameController.text = file!.name;
      });
      return image;
    } else {
      return null;
    }
  }

  Future<File?> _pickImaFromGallery() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ["jpg", 'png'],
    );
    if (pickedFile != null) {
      setState(() {
        file = pickedFile.files.first;
        image = File(file!.path!);
        print("image::: $image");
        // fileNameController.text = file!.name;
      });
      return image;
    } else {
      return null;
    }
  }

  Future<File?> urlToFile(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();

        final filePath = '${directory.path}/downloaded_image.png';

        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        return file;
      }
    } catch (e) {
      print("Error downloading image: $e");
    }
    return null;
  }

  Future<void> downloadCsv(String url, String fileName) async {
    var status = await Permission.manageExternalStorage.status;

    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }

    if (!status.isGranted && await Permission.storage.isDenied) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      final downloadsDir = Directory('/storage/emulated/0/Download');

      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync(recursive: true);
      }

      final filePath = '${downloadsDir.path}/$fileName';
      final file = File(filePath);

      if (await file.exists()) {
        print(' File already exists. Opening...');
      } else {
        print(' Downloading file...');
        try {
          await Dio().download(url, filePath);
          print(' Download completed.');
        } catch (e) {
          print(' Download error: $e');
          return;
        }
      }

      final result = await OpenFile.open(filePath);
      print(' Open result: ${result.message}');
    } else if (await Permission.manageExternalStorage.isPermanentlyDenied ||
        await Permission.storage.isPermanentlyDenied) {
      print(" Permission permanently denied. Opening settings...");
      await openAppSettings();
    } else {
      print(" Storage permission denied.");
    }
  }
}
