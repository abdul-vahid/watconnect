import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:path/path.dart' as p;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:video_player/video_player.dart';
import 'package:whatsapp/main.dart';
import 'package:whatsapp/models/approved_template_model/aprovedtempltemodel/component.dart';
import 'package:whatsapp/view_models/lead_list_vm.dart';
import 'package:whatsapp/view_models/message_list_vm.dart';
import 'package:whatsapp/views/view/clone_campaign_view.dart';
import '../../models/campaign_model/campaign_model.dart';

import '../../models/groups_model/groups_model.dart';
import '../../models/template_model/template_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_utils.dart';
import '../../utils/function_lib.dart';
import 'package:file_picker/file_picker.dart';
import '../../view_models/campaign_vm.dart';
import '../../view_models/groups_view_model.dart';
import '../../view_models/templete_list_vm.dart';
import 'campaign_list_view.dart';
import 'package:whatsapp/models/campaign_model/record.dart';

// ignore: must_be_immutable
class CampaignAddUpdateView extends StatefulWidget {
  late Record? model;
  bool isClone;
  CampaignAddUpdateView({Key? key, this.model, this.isClone = false})
      : super(key: key);

  @override
  State<CampaignAddUpdateView> createState() => _Forms();
}

class _Forms extends State<CampaignAddUpdateView> {
  TempleteListViewModel? templateVM;
  GroupsViewModel? groupsVM;
  List<TextEditingController> controllers = [];
  TextEditingController fileNameController = TextEditingController();
  TextEditingController _templateController = TextEditingController();
  late MessageViewModel messageViewModel;
  bool isEdit = false;
  int count = 0;
  String? base64Img;
  var leadlistvm;
  ImagePicker picker = ImagePicker();
  XFile? pickedFile;
  PlatformFile? file;
  var number;
  List<String> GroupsName = [];
  List<String> selectedGroupsName = [];
  List<String> selectedGroupIds = [];
  List<String> selectedNamesWithNumbers = [];
  String? selectedTemplateName;
  String? SelectedTemplateCategory;
  String? selectedTemplateId;
  var selectedType;
  late VideoPlayerController _Vcontroller;
  var selectedLanguage;
  var selectedHeader;
  var selectedBody;
  var selectedFooter;
  dynamic selectedButtons;
  CampaignModel? campData = CampaignModel();
  File? image;
  File? csvFile;
  // File? image;
  var campaignvm;
  List leadsToSend = [];
  bool isRefresh = false;
  List<Map<String, dynamic>> selectedMembers = [];
  List<Map<String, dynamic>> allContactDetails = [];

  List<Map<String, dynamic>> selectedGroups = [];
  List<Map<String, dynamic>> allGroupDetails = [];

  List<String> selectedCampleadList = [];
  List campLeadNameNum = [];

  Future<void> saveNumberData() async {
    final prefs = await SharedPreferences.getInstance();
    number = prefs.getString('phoneNumber');
    debug("this is my number $number");
    await Provider.of<TempleteListViewModel>(
      context,
      listen: false,
    ).templetefetch(number: number ?? "");
  }

  @override
  void initState() {
    super.initState();
    saveNumberData();
    _fetchTemplates();
    campLeadList();

    final model = widget.model;
    if (model != null) {
      isEdit = true;
      _name = widget.model?.campaignName;
      SelectedTemplateCategory = widget.model?.campaignType;
    }
    if (widget.model?.groups != null) {
      print(
          "widget.model?.groups:::: ${widget.model?.groups}  ${widget.model?.groups.runtimeType}");

      List<Map<String, dynamic>> mapList =
          widget.model?.groups.cast<Map<String, dynamic>>();
      selectedGroups = mapList;
      // selectedGroupsName =
      //     selectedGroups.map<String>((e) => e['name'].toString()).toList();
      selectedGroupsName = selectedGroups
          .map<String>((group) => group['name'].toString())
          .toList();

      selectedGroupIds = selectedGroups
          .map<String>((group) => group['id'].toString())
          .toList();

      print(
          "selectedGroupsName  ids ::: ${selectedGroupsName}  ${selectedGroupIds}");
    }

    if (widget.model != null) {
      _dateStartInput.text = widget.model!.startDate != null
          ? widget.model!.startDate.toString()
          : '';
      _type =
          widget.model?.campaignType != '' && widget.model?.campaignType != null
              ? widget.model?.campaignType
              : null;
    } else {
      _type = "Web";
      count = 0;
      _tempController.text = "Select Template";
      templateNames.add("Select Template Name");
    }

    Provider.of<GroupsViewModel>(context, listen: false).fetchGroups();
  }

  List<String> templateIds = [];
  List<String> templateNames = [];
  CampaignViewModel? _getaccountData;
  List<dynamic> types = [
    'Advertisement',
    'Banner Ads',
    'Confrence',
    'Direct Mail',
    'Email',
    'Partners',
    'Public Relations',
    'Web',
    'Other',
  ];
  List<dynamic> tempateCategory = [
    'All',
    'UTILITY',
    'MARKETING',
    'AUTHENTICATION',
  ];

  Map<String, Map<String, dynamic>> allTemplatesMap = {};
  List<dynamic> templateName1 = [];
  // Map<String, dynamic> templateName1 = {};
  Set<Map<String, String>> groupsNameSet = {};
  String? _name;
  String? _templeteName;
  String? _type;
  String? _groupName;
  String? _description;

  final GlobalKey<FormState> _addleadFormKey = GlobalKey<FormState>();
  final TextEditingController _dateStartInput = TextEditingController();
  final TextEditingController _tempController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    leadlistvm = Provider.of<LeadListViewModel>(context);
    debug('hello $templateName1');
    messageViewModel = Provider.of<MessageViewModel>(context);
    templateVM = Provider.of<TempleteListViewModel>(context);
    groupsVM = Provider.of<GroupsViewModel>(context);
    _getaccountData = Provider.of<CampaignViewModel>(context);

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
    debug("All Templates Map Data: $allTemplatesMap");

    debug("All Templates Map Data: $allTemplatesMap");

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
      allGroupDetails = groupsNameSet.toList();
      print("allGroupDetails::: ::: allGroupDetails:::::: ${allGroupDetails}");
    }

    setState(() {
      GroupsName = groupsNameSet
          .map((group) => group['name']!)
          .toList(); // Extract unique names
    });
    // This code use of Group Name get end here

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // automaticallyImplyLeading: true,
        centerTitle: true,
        elevation: 2,
        backgroundColor: AppColor.navBarIconColor,
        title: Text(
          isEdit && widget.isClone == false
              ? "Edit Campaign"
              : widget.isClone
                  ? "Clone Campaign"
                  : "Add Campaign",
          style: const TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _pageBody(),
      //  AppUtils.getAppBody(_getaccountData!, _pageBody),
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
                onPressed: isEdit ? updateData : onButtonPressed,
                child: Text(
                  isEdit ? "Update" : "Submit",
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

  // this code use of download file start here
  Future<void> saveFileToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? files = prefs.getStringList('uploaded_files') ?? [];

    if (file == null || base64Img == null) {
      debug("No file selected to save.");
      return;
    }

    Map<String, dynamic> fileData = {
      "name": file!.name,
      "extension": file!.extension,
      "size": file!.size.toString(),
      "base64": base64Img,
    };

    files.add(jsonEncode(fileData));
    await prefs.setStringList('uploaded_files', files);

    debug("File saved successfully.");
  }

  Future<void> _pullRefresh() async {
    if (widget.model != null) {
      return;
    }
    Provider.of<CampaignViewModel>(context, listen: false).fetchCampaign();

    isRefresh = true;
    return Future<void>.delayed(const Duration(seconds: 1));
  }

  Widget _pageBody() {
    print("selectedGroups  page body ::::::::::: ${selectedGroups}");
    return SingleChildScrollView(
      child: Form(
        key: _addleadFormKey,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 14,
            right: 14,
            top: 10,
            bottom: 05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Campaign Name'),
              const SizedBox(height: 5),
              AppUtils.getTextFormField(
                'Enter Campaign Name',
                // initialValue: widget.model?.records,
                onSaved: (value) {},
                initialValue: widget.model?.campaignName,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
                onChanged: (p0) {
                  setState(() {
                    _name = p0;
                    print("name:: # ${_name}");
                  });
                },
              ),
              const SizedBox(height: 10),
              const Text('Start Date & Time'),
              const SizedBox(height: 5),
              TextFormField(
                controller: _dateStartInput,
                decoration: InputDecoration(
                  suffixIcon: const Icon(
                    Icons.calendar_month,
                    color: AppColor.navBarIconColor,
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(
                    5.0,
                    10.0,
                    5.0,
                    10.0,
                  ),
                  hintText: 'yyyy-MM-dd HH:mm:ss',

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(08),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(08),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  //labelText: "Select Date"
                ),
                readOnly: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter date';
                  }
                  return null;
                },
                onTap: () async {
                  // DateTime? dateTime = await showOmniDateTimePicker(
                  //   context: context,
                  // );

                  // String formattedDate =
                  //     DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
                  //         .format(dateTime.toLocal());
                  // String formattedDate = formatDateWithTimezone(dateTime!);

                  DateTime? dateTime =
                      await showOmniDateTimePicker(context: context);

                  if (dateTime != null) {
                    _dateStartInput.text = formatToKolkataISOString(dateTime);
                  }
                },
              ),
              if (isEdit == false) const SizedBox(height: 10),
              if (isEdit == false) const Text('Select Template Category *'),
              if (isEdit == false) const SizedBox(height: 5),
              if (isEdit == false)
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
              const Text('Select Groups'),
              const SizedBox(height: 5),
              MultiSelectDialogField<Map<String, dynamic>>(
                dialogHeight: 160,
                items: allGroupDetails.map((group) {
                  return MultiSelectItem<Map<String, dynamic>>(
                      group, "${group['name']}");
                }).toList(),
                initialValue: selectedGroups,
                title: allGroupDetails.isEmpty
                    ? const Center(
                        child: Text(
                        "No Groups Available",
                        style: TextStyle(fontSize: 18),
                      ))
                    : const Text("Select Groups"),
                selectedColor: Colors.blue,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                buttonText: const Text("Select Groups"),
                chipDisplay: MultiSelectChipDisplay.none(),
                onConfirm: (results) {
                  setState(() {
                    // Filter selected items based on `allGroupDetails` reference matching
                    selectedGroups = allGroupDetails
                        .where((group) =>
                            results.any((r) => r['id'] == group['id']))
                        .toList();

                    // Update the dependent lists
                    selectedGroupsName =
                        selectedGroups.map((res) => "${res['name']}").toList();
                    selectedGroupIds =
                        selectedGroups.map((res) => "${res['id']}").toList();
                  });
                },
              ),
              const SizedBox(height: 10),

              // Display selected groups as chips
              Wrap(
                spacing: 8.0,
                children: selectedGroups.map((selectedItem) {
                  return Chip(
                    label: Text(selectedItem['name']),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () {
                      setState(() {
                        final delId = selectedItem['id'];

                        // Find the actual reference from selectedGroups
                        final toRemove = selectedGroups.firstWhere(
                          (item) => item['id'] == delId,
                        );

                        // Remove by reference
                        selectedGroups.remove(toRemove);

                        // Update the dependent lists
                        selectedGroupsName = selectedGroups
                            .map((res) => "${res['name']}")
                            .toList();
                        selectedGroupIds = selectedGroups
                            .map((res) => "${res['id']}")
                            .toList();
                      });
                    },
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    labelStyle: const TextStyle(color: Colors.blue),
                  );
                }).toList(),
              ),

              if (isEdit == false) const SizedBox(height: 2),
              if (isEdit == false) const Text('Select Leads'),
              if (isEdit == false) const SizedBox(height: 5),
              if (isEdit == false)
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
                  ),
                  buttonText: const Text(
                    "Select Leads",
                    style: TextStyle(
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
              if (isEdit == false) const SizedBox(height: 10),
              if (isEdit == false)
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
              // const SizedBox(height: 5),
              if (isEdit == false) const SizedBox(height: 10),
              if (isEdit == false) const Text('File Upload'),
              const SizedBox(height: 05),
              if (isEdit == false)
                TextFormField(
                  //initialValue: widget.model?.title,
                  controller: fileNameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(08),
                    ),
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

                    result == null
                        ? const Text(
                            'No File Selected',
                            style: TextStyle(color: Colors.black),
                          )
                        : file = result.files.first;

                    debug('File Name: ${file?.name}');
                    debug('File Byte Size: ${file?.size}');
                    debug('File Type: ${file?.extension}');
                    debug('File Path: ${file?.path}');
                    csvFile = File(file!.path.toString());
                    debug('csvFile Path: ${csvFile}');
                    final convertBytes =
                        File(file!.path.toString()).readAsBytesSync();
                    base64Img = base64Encode(convertBytes);
                    String fileName = file!.path.toString().split('/').last;
                    fileNameController.text = fileName;
                    await saveFileToPrefs();
                    setState(() {});
                  },
                ),
              const SizedBox(height: 10),
              if (isEdit == false)
                InkWell(
                    onTap: () async {
                      downloadCSV(context);
                    },
                    child: Container(
                      // width: 180,
                      decoration: BoxDecoration(
                          color: AppColor.navBarIconColor,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Center(
                          child: Text(
                            "Download Sample CSV",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )),
              if (isEdit == false) const SizedBox(height: 10),
              const Text('Type'),
              const SizedBox(height: 5),
              AppUtils.getDropdown(
                'Select',
                data: types,
                onChanged: (p0) {
                  setState(() {
                    _type = p0;
                    print("_type::: ${_type}");
                  });
                },
                value: _type,
              ),
              if (isEdit == false) const SizedBox(height: 10),
              if (isEdit == false) const Text('Description'),
              if (isEdit == false) const SizedBox(height: 5),
              if (isEdit == false)
                AppUtils.getTextFormField(
                  'type description here..',

                  // initialValue: widget.model?.email,
                  onSaved: (email) {
                    _description = email;
                  },
                  maxLines: 5,
                ),
              const SizedBox(height: 10),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  String formatDateWithTimezone(DateTime dateTime) {
    dateTime = dateTime.toLocal();
    Duration offset = dateTime.timeZoneOffset;
    String hours = offset.inHours.abs().toString().padLeft(2, '0');
    String minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    String sign = offset.isNegative ? '-' : '+';

    return "${DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(dateTime)}$sign$hours:$minutes";
  }

  void onButtonPressed() async {
    print("fileNameControllerL::::: ${fileNameController.text}");
    print("selectedGroups:::: ${selectedGroupsName}");
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
    if (_name?.trim() == null) {
      EasyLoading.showToast("Please enter campaign name");
      return;
    }
    if (_dateStartInput.text.trim().isEmpty) {
      EasyLoading.showToast("Pleaseselect start date and time");
      return;
    }
    print(
      "controllers::: ${controllers}  ${isChecked}  ${image}  ${isOtherFileSelected}  ${imgToShow}",
    );
    addCampaignTemplate();
    // if (_addleadFormKey.currentState!.validate()) {
    //   print("validatinggggg");
    //   if (_name == null || _name.toString().isEmpty) {
    //     print("validatinggggg   1");
    //     return;
    //   } else if (_dateStartInput.text.toString().isEmpty) {
    //     print("validatinggggg   2");
    //     return;
    //   } else if (SelectedTemplateCategory == null ||
    //       selectedTemplateName.toString().isEmpty) {
    //     print("validatinggggg   3");
    //     return;
    //   } else if (_type == null || _type.toString().isEmpty) {
    //     print("validatinggggg   4");
    //     return;
    //   }
    //   _addleadFormKey.currentState!.save();

    //   print("creatingggg the campainggg");
    //   AppUtils.onLoading(context, "Saving, please wait...");

    //   // sendingCamplaign();

    // } else {
    //   print("landed here ");
    // }
  }

  Future<void> updateData() async {
    var id = widget.model?.campaignId;
    if (_addleadFormKey.currentState!.validate()) {
      _addleadFormKey.currentState!.save();
      AppUtils.onLoading(context, "Saving, please wait...");
      Map<String, dynamic> camp = {
        'name': _name?.trim(),
        'type': _type,
        'startDate': _dateStartInput.text,
        'group_ids': selectedGroupIds,
        "template_name": widget.model?.templateName ?? "",
        "id": widget.model?.campaignId ?? "",
      };
      print("camp before siending::: ${camp}");
      AppUtils.onLoading(context, "Updating, please wait...");
      Provider.of<CampaignViewModel>(
        context,
        listen: false,
      ).updateCampaign(id, camp).then((value) {
        debug('campaignUpdate==$value');
        Navigator.pop(context);
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.pop(context, true);
        });

        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => MultiProvider(
        //       providers: [
        //         ChangeNotifierProvider(
        //           create: (_) => CampaignViewModel(context),
        //         ),
        //       ],
        //       child: const CampaignListView(),
        //     ),
        //   ),
        // );
      });
    }
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
              print("rec name ::${record.name}  ${selectedTemplateName}");
              if (selectedTemplateName == record.name) {
                currentTemplate = record;
                selectedTemplateId = currentTemplate.id;
                selectedLanguage = currentTemplate.language;
                log(
                  "current template::::: ${currentTemplate}  ${currentTemplate.name}",
                );
                print(
                  "other info:: ${currentTemplate.components}   ${currentTemplate.components.runtimeType}",
                );
                components = currentTemplate.components;
                print("Component info:: ${components.length} ${components}");

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

                log(
                  "components ::: ${selectedHeader}   ${selectedBody}  ${selectedButtons}",
                );

                return;
              }
            }
          }
        }
      }
    }
  }

  bool isChecked = false;
  String imgToShow = "";
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

                                String templateToSend = selectedTemplateName ??
                                    _templateController.text;

                                _tempController.text =
                                    selectedTemplateName ?? "";

                                // print(
                                //     "selectedHeader.format::::: ${selectedHeader}    ${selectedHeader.format}");

                                if (selectedHeader == null) {
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

  Widget _buildMediaWidget(String format, String content) {
    print("format:::::: ${format}  ${content}");
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
        print("image::: ${image}");

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
        print("image::: ${image}");
        fileNameController.text = file!.name;
      });
      return image;
    } else {
      return null;
    }
  }

  String? fileid;
  Future<File?> _pickImaFromGallery() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ["jpg", 'png'],
    );

    if (pickedFile != null) {
      final picked = pickedFile.files.first;
      final img = File(picked.path!);

      // Always return the file
      if (mounted) {
        setState(() {
          file = picked;
          image = img;
          print("image::: $image");
          fileNameController.text = file!.name;
        });
      }

      return img;
    }

    return null;
  }

  void addCampaignTemplate({File? fileToSend, bool sendToAdmin = false}) {
    sendTemplateApiCall(sendToAdmin);
  }

  Future<void> sendTemplateApiCall(bool send) async {
    final prefs = await SharedPreferences.getInstance();
    number = prefs.getString('phoneNumber');
    print("sending camplagnnnn::::::: ${fileid}  ${imgToShow}");
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

  bool _isLoading = false;
  Future<void> sendingCamplaign() async {
    Map<String, String> bodyTextParams = {};
    List compoTextParams = [];
    List numberedCampParam = [];

    // bool anyEmpty = controllers.any((controller) => controller.text.isEmpty);
    // if (anyEmpty) {
    //   // EasyLoading.showToast('All fields are required');

    //   setState(() {
    //     _isLoading = false;
    //   });
    //   return;
    // }

    // File? imageFile;
    // String docId = "";
    for (int i = 0; i < controllers.length; i++) {
      bodyTextParams[(i + 1).toString()] = controllers[i].text;
      Map body = {"type": "text", "text": controllers[i].text};
      compoTextParams.add(body);
      numberedCampParam.add(bodyTextParams);
    }

    String templateToSend = selectedTemplateName ?? "";

    print("selected header:: >><><>< ${selectedHeader}     ${templateToSend}");

    setState(() {
      _isLoading = true;
    });

    if (templateToSend.isEmpty) {
      setState(() {
        _isLoading = false;
        image = null;

        CampaignViewModel getaccountData = CampaignViewModel(context);

        Map<String, dynamic> camp = {
          'name': _name?.trim(),
          'template_id': selectedTemplateId,
          'template_name': selectedTemplateName,
          'status': 'Pending',
          'business_number': number,
          'type': _type,
          'startDate': _dateStartInput.text,
          'group_ids': selectedGroupIds,
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
                print("csvFile ::::   ${csvFile}");

                print("image ::::   ${image}");
                if (csvFile != null) {
                  await messageViewModel
                      .uploadCampFiledb(csvFile!, campaignId, isFromCamp: false)
                      .then((onValue) {
                    getaccountData.fetchCampaign();
                  });
                }
                if (image != null) {
                  await messageViewModel
                      .uploadCampFiledb(image!, campaignId)
                      .then((onValue) {
                    getaccountData.fetchCampaign();
                  });
                }
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

          Map<String, dynamic> camp = {
            'name': _name?.trim(),
            'template_id': selectedTemplateId,
            'template_name': selectedTemplateName,
            'status': 'Pending',
            'business_number': number,
            'type': _type,
            'startDate': _dateStartInput.text,
            'group_ids': selectedGroupIds,
            "lead_ids": selectedMembers,
            'description': _description,
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
                var campaignResponse = await mstemp.sendCampParam(
                  campParambody: paramBody,
                );
              }
              print("csvFile ::::   ${csvFile}");

              print("image ::::   ${image}");
              if (csvFile != null) {
                await messageViewModel
                    .uploadCampFiledb(csvFile!, campaignId, isFromCamp: false)
                    .then((onValue) {
                  getaccountData.fetchCampaign();
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
      });
    }

    print("selected button::: ${selectedButtons} ");
  }

  Future<void> sendTextTemplate(
    String templateToSend,
    List compoTextParams,
    bool sendOnLoginNum,
    Map campaignParam,
  ) async {
    final mstemp = MessageViewModel(context);

    // List ba = [];
    // if (selectedButtons != null) {
    //   print("list:::: ${selectedButtons.buttons}");
    //   ba = selectedButtons.buttons.map((button) => button.toMap()).toList();
    // }

    // String footer = selectedFooter?.text ?? "";

    Map<String, dynamic> exBodyText = {
      ...campaignParam,
      "sendToAdmin": sendOnLoginNum,
    };

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
      "example_body_text": {"sendToAdmin": false},
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

  Future<bool> requestManageExternalStoragePermission(
      BuildContext context) async {
    var status = await Permission.manageExternalStorage.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      var result = await Permission.manageExternalStorage.request();
      if (result.isGranted) return true;
      if (result.isPermanentlyDenied) {
        _showSettingsDialog(context);
        return false;
      } else {
        _showPermissionDeniedSnackBar(context);
        return false;
      }
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(context);
      return false;
    }
    return false;
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Permission Required"),
        content: Text("Please enable Manage External Storage from Settings."),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Open Settings"),
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Permission denied. Cannot proceed.")),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Storage Permission Required"),
        content:
            Text("Please allow storage access to save and view CSV files."),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: Text("Open Settings"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          )
        ],
      ),
    );
  }

  // Future<bool> requestStoragePermission(BuildContext context) async {

  // PermissionStatus status = await Permission.storage.status;

  // // If already granted
  // if (status.isGranted) return true;

  // // If denied (but not permanently)
  // if (status.isDenied) {
  //   PermissionStatus newStatus = await Permission.storage.request();
  //   return newStatus.isGranted;
  // }

  // // If permanently denied
  // if (status.isPermanentlyDenied) {
  //   // Show dialog to guide user to settings
  //   await showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Storage Permission Needed'),
  //       content: const Text(
  //           'To download files, you must enable storage permission in app settings.'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () async {
  //             Navigator.of(context).pop();
  //             await openAppSettings();
  //           },
  //           child: Text('Open Settings'),
  //         ),
  //       ],
  //     ),
  //   );
  //   return false;
  // }

  // }

  Future<String> getDownloadPath() async {
    Directory dir = Directory('/storage/emulated/0/Download');
    if (!await dir.exists()) {
      dir = await getExternalStorageDirectory() ?? Directory.systemTemp;
    }
    return dir.path;
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

  Future<void> downloadFile(String url, String fileName) async {
    try {
      EasyLoading.showToast("Downloading...");

      Directory directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        throw Exception("Unsupported platform");
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      String filePath = '${directory.path}/$fileName';

      Dio dio = Dio();
      await dio.download(url, filePath, onReceiveProgress: (received, total) {
        if (total != -1) {
          print(
              'Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
        }
      });
      EasyLoading.showToast("File downloaded to: $filePath");
    } catch (e) {
      EasyLoading.showToast("Download Failed");
    }
  }

  Future<void> _fetchTemplates() async {
    TempleteListViewModel templeteViewModel =
        Provider.of<TempleteListViewModel>(context, listen: false);

    // Check if templeteViewModel is not null and contains viewModels
    if (templeteViewModel.viewModels.isNotEmpty) {
      for (var viewModel in templeteViewModel.viewModels) {
        var campaignModel = viewModel.model;
        if (campaignModel?.data != null) {
          for (var record in campaignModel!.data!) {
            if (record.status != null) {
              setState(() {
                templateNames.add(record.name);
              });
            }
          }
        }
      }
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

  Future<int> _getAndroidVersion() async {
    try {
      return int.parse((await File('/system/build.prop').readAsLines())
          .firstWhere((line) => line.contains('ro.build.version.sdk'))
          .split('=')[1]);
    } catch (_) {
      return Platform.version.contains('Android')
          ? int.tryParse(Platform.version.split(' ')[1].split('.')[0]) ?? 33
          : 33;
    }
  }

  Future<void> downloadCSV(BuildContext context) async {
    List<List<dynamic>> rows = [
      ["Name", "Country Code", "Number"],
      ["John", "+91", "XXXXXXXXXX"]
    ];
    String csv = const ListToCsvConverter().convert(rows);

    final Directory? downloadsDir = await getApplicationDocumentsDirectory();

    if (downloadsDir != null) {
      final String downloadsPath =
          downloadsDir.path.replaceAll("Android/data", "Download");
      final file = File('$downloadsPath/sample.csv');
      await file.create(recursive: true);
      await file.writeAsString(csv);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("CSV saved"),
          action: SnackBarAction(
            label: "Open",
            onPressed: () {
              OpenFile.open(file.path);
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to access Downloads directory")),
      );
    }
  }
}
