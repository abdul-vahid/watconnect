import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/approved_template_model/aprovedtempltemodel/component.dart';
import '../../utils/app_color.dart';
import '../../utils/app_utils.dart';
import 'package:file_picker/file_picker.dart';
import '../../utils/function_lib.dart';
import '../../view_models/campaign_vm.dart';
import '../../view_models/groups_view_model.dart';
import '../../view_models/templete_list_vm.dart';
import 'package:whatsapp/models/campaign_model/record.dart';

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
  final _addleadFormKey = GlobalKey<FormState>();
  final TextEditingController _dateStartInput = TextEditingController();
  final TextEditingController fileNameController = TextEditingController();

  TempleteListViewModel? templateVM;
  GroupsViewModel? groupsVM;

  bool isEdit = false;
  String? base64Img;
  XFile? pickedFile;
  PlatformFile? file;
  File? image;
  late CampaignViewModel campaignvm;

  String? _name, _description, _type;
  String? selectedTemplateName;
  String? SelectedTemplateCategory;
  String? selectedTemplateId;
  String? selectedLanguage;
  String? selectedHeader;
  String? selectedBody;
  String? selectedFooter;
  dynamic selectedButtons;

  List<Map<String, String>> groupsNameSet = [];
  List<String> selectedGroups = [];
  // List<String> tempateCategory = [];
  List<dynamic> tempateCategory = ['UTILITY', 'MARKETING'];
  List<String> templateName1 = [];
  Map<String, Map<String, String>> allTemplatesMap = {};

  @override
  void initState() {
    getdatabyid();
    _dateStartInput.text = widget.record.startDate.toString();
    print("Ddddddddddddd${widget.record.campaignName}");
    super.initState();
    if (widget.model != null) {
      isEdit = true;
      _name = widget.model!.campaignName;
    }
    final model = widget.model;
    if (model != null) {
      isEdit = true;
      _name = widget.model?.campaignName;
      SelectedTemplateCategory = widget.model?.campaignType;
    }
    if (widget.model?.groups != null) {
      selectedGroups = widget.model!.groups
          .map<String>((group) => group['id'].toString())
          .toList();
    }

    if (widget.model != null) {
      _dateStartInput.text = widget.model!.startDate != null
          ? widget.model!.startDate.toString()
          : '';
      _type =
          widget.model?.campaignType != '' && widget.model?.campaignType != null
              ? widget.model?.campaignType
              : null;
    }
    Provider.of<GroupsViewModel>(context, listen: false).fetchGroups();
  }

  Future<void> getdatabyid() async {
    CampaignViewModel campVM =
        Provider.of<CampaignViewModel>(context, listen: false);
    await campVM.getcampaignbyid(widget.record.campaignId.toString());
    print("Data @@@@@ fetched: ${campVM.record}");
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
              print("rec name ::${record.name}  ${selectedTemplateName}");
              if (selectedTemplateName == record.name) {
                currentTemplate = record;
                selectedTemplateId = currentTemplate.id;
                selectedLanguage = currentTemplate.language;
                print(
                    "current template::::: ${currentTemplate}  ${currentTemplate.name}");
                print(
                    "other info:: ${currentTemplate.components}   ${currentTemplate.components.runtimeType}");
                components = currentTemplate.components;
                print("Component info:: ${components.length} ${components}");

                for (var e in components) {
                  print("checking the type:: ${e.type}");
                  if (e.type == "HEADER") {
                    selectedHeader = e.text;
                  } else if (e.type == "BODY") {
                    selectedBody = e.text;
                  } else if (e.type == "FOOTER") {
                    selectedFooter = e.text;
                  } else if (e.type == "BUTTONS") {
                    selectedButtons = e.buttons;
                  }
                }
                setState(() {});
                print(
                    "components ::: ${selectedHeader}   ${selectedBody}  ${selectedButtons}");

                return;
              }
            }
          }
        }
      }
    }
  }

  void _sendTemplateSheet() {
    // Logic to handle UI update or preview
  }

  Widget _pageBody() {
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
                onSaved: (value) => _name = value,
                initialValue: widget.record?.campaignName,
                validator: (value) => value!.isEmpty ? 'Required' : null,
                onChanged: (p0) => setState(() => _name = p0),
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
              const Text('Select Template Category'),
              const SizedBox(height: 5),
              AppUtils.getDropdown(
                'Select Category',
                data: tempateCategory,
                onChanged: (p0) {
                  setState(() {
                    SelectedTemplateCategory = p0;
                    selectedTemplateName = null;

                    if (p0 != null) {
                      templateName1 = [];
                      String categoryKey = p0.toLowerCase();
                      debug("Selected Category: $categoryKey");
                      templateName1 = [
                        ...allTemplatesMap[categoryKey]?.values ?? [],
                      ];
                      debug(
                        "Updated Template List after selecting category: $templateName1",
                      );

                      // If templates are empty, debug
                      if (templateName1.isEmpty) {
                        debug(
                          "No templates found for the selected category: $categoryKey",
                        );
                      }
                    }
                  });
                },
                value: SelectedTemplateCategory,
              ),
              const SizedBox(height: 10),
              const Text('Template Name'),
              const SizedBox(height: 5),
              AppUtils.getDropdown(
                'Select Template Name',
                data: templateName1.isNotEmpty
                    ? templateName1
                    : [
                        'No Templates Available',
                      ],
                onChanged: (p0) {
                  setState(() {
                    selectedTemplateName = p0;
                  });
                  debug("Selected Template: $selectedTemplateName");
                  _setSelectedTemplates();
                  _sendTemplateSheet();
                },
                value: selectedTemplateName,
              ),
              const SizedBox(height: 10),
              const Text('Group Name'),
              const SizedBox(height: 5),
              MultiSelectDialogField(
                dialogHeight: 160,
                items: groupsNameSet
                    .map((group) =>
                        MultiSelectItem<String>(group['id']!, group['name']!))
                    .toList(),
                initialValue: selectedGroups,
                title: const Text("Select Groups"),
                selectedColor: Colors.blue,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                buttonText: const Text("Select Groups"),
                onConfirm: (results) =>
                    setState(() => selectedGroups = results.cast<String>()),
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
                    allowedExtensions: ["jpg", 'png', 'pdf', 'csv'],
                  );
                  if (result != null) {
                    file = result.files.first;
                    image = File(file!.path.toString());
                    base64Img =
                        base64Encode(File(file!.path!).readAsBytesSync());
                    fileNameController.text = file!.name;
                    await saveFileToPrefs();
                  }
                },
              ),
              const SizedBox(height: 10),
              const Text('Type'),
              const SizedBox(height: 5),
              AppUtils.getDropdown(
                'Select',
                data: ['Promotional', 'Transactional'],
                onChanged: (p0) => setState(() => _type = p0),
                value: _type,
              ),
              const SizedBox(height: 10),
              const Text('Description'),
              const SizedBox(height: 5),
              AppUtils.getTextFormField(
                'type description here..',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color.fromARGB(255, 255, 255, 255)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Clone Campaign',
            style: TextStyle(color: Colors.white),
          )),
      body: _pageBody(),
    );
  }
}
