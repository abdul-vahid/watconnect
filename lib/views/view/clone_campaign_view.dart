import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../../models/approved_template_model/aprovedtempltemodel/component.dart';
import '../../models/campaigndetail_model.dart';
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
  late VideoPlayerController _Vcontroller;
  final _addleadFormKey = GlobalKey<FormState>();
  final TextEditingController _dateStartInput = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController fileNameController = TextEditingController();

  TempleteListViewModel? templateVM;
  GroupsViewModel? groupsVM;
  CampaignViewModel? _getaccountData;
  bool isEdit = false;
  String? base64Img;
  XFile? pickedFile;
  PlatformFile? file;
  File? image;
  late CampaignViewModel campaignvm;

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
  List<String> selectedGroups = [];
  // List<String> tempateCategory = [];
  List<dynamic> tempateCategory = ['UTILITY', 'MARKETING'];
  List<String> templateName1 = [];
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
  Map<String, Map<String, String>> allTemplatesMap = {};
  var number;
  @override
  void initState() {
    super.initState();
    templateVM = Provider.of<TempleteListViewModel>(context, listen: false);
    groupsVM = Provider.of<GroupsViewModel>(context, listen: false);

    groupsVM!.fetchGroups(); // Make sure this loads before pre-selecting groups
    getdatabyid();

    _dateStartInput.text = widget.record.startDate.toString();
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

  Future<void> getdatabyid() async {
    print("working.........");

    CampaignViewModel campVM =
        Provider.of<CampaignViewModel>(context, listen: false);
    await campVM.getcampaignbyid(widget.record.campaignId.toString());

    for (var viewModel in campVM.viewModels) {
      CampaigndetailModel model = viewModel.model;
      print(" model.name===>${model.name}");

      setState(() {
        _name.text = model.name ?? "";
        _type = model.type;
        // _description = model.description ?? "";

        if (model.startDate != null) {
          _dateStartInput.text = formatDateWithTimezone(model.startDate!);
        }

        if (model.name != null) {
          _name.text = model.name!;
        }

        // Set Template Category & Template Name
        // if (model.templateCategory != null) {
        //   SelectedTemplateCategory = model.templateCategory;
        //   String categoryKey = SelectedTemplateCategory!.toLowerCase();
        //   templateName1 = [...allTemplatesMap[categoryKey]?.values ?? []];

        //   if (model.templateName != null &&
        //       templateName1.contains(model.templateName)) {
        //     selectedTemplateName = model.templateName;
        //   }
        // }

        // Set Group IDs
        // if (model.groupIds != null && model.groupIds!.isNotEmpty) {
        //   selectedGroups = model.groupIds!
        //       .map<String>((group) => group['id'].toString())
        //       .toList();
        // }

        // // Set File Info if available
        // if (model.fileName != null && model.base64File != null) {
        //   fileNameController.text = model.fileName!;
        //   base64Img = model.base64File!;
        //   // file/image loading logic if needed
        // }

        _setSelectedTemplates();
      });
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
                    "components ${selectedHeader}   ${selectedBody}  ${selectedButtons}");
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
    isChecked = false;
    image = null;
    String text = selectedBody.text;
    imgToShow = "";
    if (selectedHeader != null) {
      final example = selectedHeader!.example;
      if (example != null &&
          example.headerHandle != null &&
          example.headerHandle!.isNotEmpty) {
        print("selectedHeader>>> ${example.headerHandle}");
        imgToShow = example.headerHandle![0];
      } else {
        imgToShow = "";
      }
    } else {
      imgToShow = "";
    }

    controllers.clear();

    final regex = RegExp(r'\{\{\d+\}\}');

    int count = regex.allMatches(text).length;
    file = null;
    controllers = List.generate(count, (index) => TextEditingController());
    isOtherFileSelected = false;
    Widget _buildMediaWidget(String format, String content) {
      print("format:::::: ${format}  ${content}");
      switch (format) {
        case "IMAGE":
          return content.isEmpty
              ? Container(
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
                  child: Center(
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
                  child: Center(
                    child:
                        Icon(Icons.videocam_off, size: 40, color: Colors.grey),
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
              : SizedBox(); // Empty if no document

        default:
          return SizedBox(); // If format is unknown
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

          fileNameController.text = file!.name;
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
          print("image::: ${image}");
          fileNameController.text = file!.name;
        });
        return image;
      } else {
        return null;
      }
    }

    Future<void> sendTemplateApiCall(bool send) async {
      late MessageViewModel mstemp = MessageViewModel(context);
      List ba =
          selectedButtons?.buttons.map((button) => button.toMap()).toList() ??
              [];
      String footer = selectedFooter?.text ?? "";
      Map<String, dynamic> createtemp = {
        "id": selectedTemplateId,
        "name": selectedTemplateName,
        "language": selectedLanguage,
        "header": selectedHeader != null ? selectedHeader.format : "",
        "header_body": selectedHeader.text ?? "",
        "message_body": selectedBody.text,
        "example_body_text": {"sendToAdmin": send},
        "footer": footer,
        "buttons": ba,
        "business_number": number,
      };

      print("createtemp campaign:::: ${createtemp}");

      // mstemp.createmsgtemplete(msgmobilbody: createtemp).then((value) {});
    }

    void addCampaignTemplate({File? fileToSend, bool sendToAdmin = false}) {
      sendTemplateApiCall(sendToAdmin);
    }

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
                      SizedBox(height: 10),
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
                        color: Color(0xffE3FFC9).withOpacity(0.5),
                        shadowColor: Colors.black38,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Align content properly
                            children: [
                              if (selectedHeader != null &&
                                  selectedHeader!.format != null)
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
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.play_arrow_rounded,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            ),
                                          )
                                        : file != null &&
                                                selectedHeader!.format ==
                                                    'DOCUMENT'
                                            ? Image.asset(
                                                "assets/images/pdf.png",
                                                height: 100,
                                              )
                                            : _buildMediaWidget(
                                                selectedHeader.format,
                                                imgToShow,
                                              ),
                              if (selectedBody != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: Text("${selectedBody.text}"),
                                ),
                              SizedBox(height: 10),
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
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            side: BorderSide(
                                              color: AppColor.navBarIconColor,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          selectedButtons.buttons[index].text,
                                          style: TextStyle(
                                            color: AppColor.navBarIconColor,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              SizedBox(height: 15),
                              if (selectedFooter != null)
                                Text(
                                  selectedFooter!.text,
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.left,
                                ),
                              SizedBox(height: 15),
                              if (selectedHeader != null)
                                selectedHeader.format == 'IMAGE' ||
                                        selectedHeader?.format == 'VIDEO' ||
                                        selectedHeader!.format == 'DOCUMENT'
                                    ? InkWell(
                                        onTap: () {
                                          if (selectedHeader.format ==
                                              'IMAGE') {
                                            _pickImaFromGallery()
                                                .then((onValue) {
                                              print("onValue>>> ${onValue}");
                                              if (onValue != null) {
                                                setState(() {
                                                  image = onValue;

                                                  isOtherFileSelected = true;
                                                });
                                              }
                                            });
                                          } else if (selectedHeader.format ==
                                              'VIDEO') {
                                            _pickVideoFromGallery().then((
                                              onValue,
                                            ) {
                                              if (onValue != null) {
                                                setState(() {
                                                  image = onValue;
                                                  isOtherFileSelected = true;
                                                });
                                              }
                                            });
                                          } else if (selectedHeader.format ==
                                              'DOCUMENT') {
                                            _pickDocFromGallery()
                                                .then((onValue) {
                                              if (onValue != null) {
                                                setState(() {
                                                  image = onValue;
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
                                              color: AppColor.navBarIconColor,
                                            ),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                              ),
                                              child: Text("Choose File"),
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                              SizedBox(height: 10),
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
                                  Expanded(
                                    child: Text(
                                      "Send on login user WhatsApp number also",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      InkWell(
                        onTap: () {
                          setState(() {});
                          if (controllers.isNotEmpty) {
                            bool anyEmpty = controllers.any(
                              (controller) => controller.text.isEmpty,
                            );
                            if (anyEmpty) {
                              // EasyLoading.showToast('All fields are required');

                              return;
                            }
                          }
                          Navigator.pop(context);
                          print(
                            "image here:: ${image}  ${isOtherFileSelected}",
                          );
                          addCampaignTemplate(
                              fileToSend: image, sendToAdmin: isChecked);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColor.navBarIconColor,
                              width: 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 8,
                              ),
                              child: Text(
                                "Done",
                                style: TextStyle(
                                  color: AppColor.navBarIconColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
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
<<<<<<< HEAD
                onSaved: (value) => _name = value,
                initialValue: widget.record.campaignName,
=======
                onSaved: (value) => _name.text = value!,
                controller: _name,
>>>>>>> c6075d5452734643fc138c5b3295c977e6e05bde
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
                      templateName1 = [
                        ...allTemplatesMap[categoryKey]?.values ?? []
                      ];

                      if (templateName1.isEmpty) {
                        debugPrint("No templates found for: $categoryKey");
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
                    : ['No Templates Available'],
                onChanged: (p0) {
                  setState(() {
                    selectedTemplateName = p0;
                  });
                  debugPrint("Selected Template: $selectedTemplateName");
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
                data: types,
                onChanged: (p0) {
                  setState(() {
                    _type = p0;
                    print("_typ ${_type}");
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
        title: Text(
          "Clone Campaign",
          style: const TextStyle(
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
    print("selectedGroups>>> ${selectedGroups}");
    print(
      "controllers::: ${controllers}  ${isChecked}  ${image}  ${isOtherFileSelected}  ${imgToShow}",
    );

    if (controllers.isNotEmpty) {
      bool anyEmpty = controllers.any((controller) => controller.text.isEmpty);
      if (anyEmpty) {
        EasyLoading.showToast('All fields are required');
        return;
      }
    }
    if (_addleadFormKey.currentState!.validate()) {
      if (_name == null || _name.toString().isEmpty) {
        print("_name_name_name_name${_name}");
        EasyLoading.showToast("Campaign Name is required");
        return;
      } else if (_dateStartInput.text.toString().isEmpty) {
        EasyLoading.showToast("Start date time is required");
        return;
      } else if (SelectedTemplateCategory == null ||
          selectedTemplateName.toString().isEmpty) {
        EasyLoading.showToast("Select Template Category");
        return;
      } else if (_type == null || _type.toString().isEmpty) {
        EasyLoading.showToast("Select Template Type");
        return;
      }
      _addleadFormKey.currentState!.save();
      AppUtils.onLoading(context, "Saving, please wait...");
      sendingCamplaign();
    } else {
      print("landed here ");
    }
  }

  Future<void> sendingCamplaign() async {
    Map<String, String> bodyTextParams = {};
    List compoTextParams = [];
    List numberedCampParam = [];
    bool anyEmpty = controllers.any((controller) => controller.text.isEmpty);

    if (anyEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    File? imageFile;
    String docId = "";
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
          'name': _name,
          'template_id': selectedTemplateId,
          'template_name': selectedTemplateName,
          'status': 'Pending',
          'business_number': number,
          'type': _type,
          'startDate': _dateStartInput.text,
          'group_ids': selectedGroups,
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
            'name': _name,
            'template_id': selectedTemplateId,
            'template_name': selectedTemplateName,
            'status': 'Pending',
            'business_number': number,
            'type': _type,
            'startDate': _dateStartInput.text,
            'group_ids': selectedGroups,
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

    List ba = [];
    if (selectedButtons != null) {
      print("list:::: ${selectedButtons.buttons}");
      ba = selectedButtons.buttons.map((button) => button.toMap()).toList();
    }

    String footer = selectedFooter?.text ?? "";

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
}
