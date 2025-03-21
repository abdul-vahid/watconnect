// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
// import 'package:multi_select_flutter/util/multi_select_item.dart';
// import 'package:omni_datetime_picker/omni_datetime_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../models/campaign_model/campaign_model.dart';

// import '../../models/groups_model/groups_model.dart';
// import '../../models/template_model/template_model.dart';
// import '../../utils/app_color.dart';
// import '../../utils/app_utils.dart';
// import '../../utils/function_lib.dart';
// import 'package:file_picker/file_picker.dart';
// import '../../view_models/campaign_vm.dart';
// import '../../view_models/groups_view_model.dart';
// import '../../view_models/templete_list_vm.dart';
// import 'campaign_list_view.dart';
// import 'package:whatsapp/models/campaign_model/record.dart';

// // ignore: must_be_immutable
// class CampaignAddUpdateView extends StatefulWidget {
//   late Record? model;
//   CampaignAddUpdateView({Key? key, this.model}) : super(key: key);

//   @override
//   State<CampaignAddUpdateView> createState() => _Forms();
// }

// class _Forms extends State<CampaignAddUpdateView> {
//   TempleteListViewModel? templateVM;
//   GroupsViewModel? groupsVM;

//   TextEditingController fileNameController = TextEditingController();
//   bool isEdit = false;
//   String? base64Img;
//   ImagePicker picker = ImagePicker();
//   XFile? pickedFile;
//   PlatformFile? file;
//   var number;
//   List<String> GroupsName = [];
//   List<String> selectedGroups = [];
//   String? selectedTemplateName;
//   String? SelectedTemplateCategory;
//   String? selectedTemplateId;
//   var selectedType;
//   CampaignModel? campData = CampaignModel();
//   File? image;
//   // File? image;

//   Future<void> saveNumberData() async {
//     final prefs = await SharedPreferences.getInstance();
//     number = prefs.getString('phoneNumber');
//     debug("this is my number $number");
//     Provider.of<TempleteListViewModel>(
//       context,
//       listen: false,
//     ).templetefetch(number: number ?? "");
//   }

//   @override
//   void initState() {
//     super.initState();
//     saveNumberData();
//     final model = widget.model;
//     if (model != null) {
//       isEdit = true;
//     }
//     if (widget.model?.groups != null) {
//       selectedGroups = widget.model!.groups
//           .map<String>((group) => group['id'].toString())
//           .toList();
//     }

//     Provider.of<GroupsViewModel>(context, listen: false).fetchGroups();
//   }

//   CampaignViewModel? _getaccountData;
//   List<dynamic> types = [
//     'Advertisement',
//     'Banner Ads',
//     'Confrence',
//     'Direct Mail',
//     'Email',
//     'Partners',
//     'Public Relations',
//     'Web',
//     'Other',
//   ];
//   List<dynamic> tempateCategory = ['UTILITY', 'MARKETING'];
//   // Map<String, List<String>> allTemplatesMap = {};
//   Map<String, Map<String, dynamic>> allTemplatesMap = {};
//   List<dynamic> templateName1 = [];
//   // Map<String, dynamic> templateName1 = {};
//   Set<Map<String, String>> groupsNameSet = {};
//   String? _name;
//   String? _templeteName;
//   String? _type;
//   String? _groupName;
//   String? _description;

//   final GlobalKey<FormState> _addleadFormKey = GlobalKey<FormState>();
//   final TextEditingController _dateStartInput = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     if (widget.model != null) {
//       _dateStartInput.text = widget.model!.startDate != null
//           ? widget.model!.startDate.toString()
//           : '';
//       _type =
//           widget.model?.campaignType != '' && widget.model?.campaignType != null
//               ? widget.model?.campaignType
//               : null;
//     }
//     debug('hello $templateName1');
//     templateVM = Provider.of<TempleteListViewModel>(context);
//     groupsVM = Provider.of<GroupsViewModel>(context);
//     _getaccountData = Provider.of<CampaignViewModel>(context);

//     for (var viewModel in templateVM!.viewModels) {
//       TemplateModel tempmodel = viewModel.model;
//       for (var record in tempmodel.data ?? []) {
//         if (record.name != null && record.category != null) {
//           String categoryKey = record.category!.toLowerCase();
//           debug('categoryKey my : $categoryKey');

//           allTemplatesMap.putIfAbsent(categoryKey, () => {});
//           allTemplatesMap[categoryKey]?[record.id] = (record.name!);
//         }
//       }
//     }
//     debug("All Templates Map Data: $allTemplatesMap");

//     for (var viewModel in groupsVM!.viewModels) {
//       GroupsModel groupsmodel = viewModel.model;
//       for (var record in groupsmodel.records ?? []) {
//         if (record.name != null && record.id != null) {
//           bool exists = groupsNameSet.any((group) => group['id'] == record.id);
//           if (!exists) {
//             groupsNameSet.add({'id': record.id!, 'name': record.name!});
//           }
//         }
//       }
//     }

//     setState(() {
//       GroupsName = groupsNameSet
//           .map((group) => group['name']!)
//           .toList(); // Extract unique names
//     });
//     // This code use of Group Name get end here

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back,
//               color: Color.fromARGB(255, 255, 255, 255)),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         automaticallyImplyLeading: true,
//         centerTitle: true,
//         elevation: 2,
//         backgroundColor: AppColor.navBarIconColor,
//         title: Text(
//           isEdit ? "Edit Campaign" : "Add Campaign",
//           style: const TextStyle(
//               color: Color.fromARGB(255, 255, 255, 255),
//               fontSize: 20,
//               fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: _pageBody(),
//     );
//   }

//   // this code use of download file start here
//   Future<void> saveFileToPrefs() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String>? files = prefs.getStringList('uploaded_files') ?? [];

//     if (file == null || base64Img == null) {
//       debug("No file selected to save.");
//       return;
//     }

//     Map<String, dynamic> fileData = {
//       "name": file!.name,
//       "extension": file!.extension,
//       "size": file!.size.toString(),
//       "base64": base64Img,
//     };

//     files.add(jsonEncode(fileData));
//     await prefs.setStringList('uploaded_files', files);

//     debug("File saved successfully.");
//   }
//   // this code use of download file end here

//   Widget _pageBody() {
//     return SingleChildScrollView(
//       child: Form(
//         key: _addleadFormKey,
//         child: Padding(
//           padding: const EdgeInsets.only(
//             left: 14,
//             right: 14,
//             top: 10,
//             bottom: 05,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               const Text(
//                 'Campaign Name',
//               ),
//               const SizedBox(height: 5),
//               AppUtils.getTextFormField(
//                 'Enter Campaign Name',
//                 // initialValue: widget.model?.records,
//                 onSaved: (value) {
//                   _name = value;
//                 },
//                 initialValue: widget.model?.campaignName,
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Required';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 10),
//               const Text(
//                 'Start Date & Time',
//               ),
//               const SizedBox(height: 5),
//               TextFormField(
//                 controller: _dateStartInput,
//                 decoration: InputDecoration(
//                   suffixIcon: const Icon(
//                     Icons.calendar_month,
//                     color: AppColor.navBarIconColor,
//                   ),
//                   contentPadding: const EdgeInsets.fromLTRB(
//                     5.0,
//                     10.0,
//                     5.0,
//                     10.0,
//                   ),
//                   hintText: 'yyyy-MM-dd HH:mm:ss',
//                   // contentPadding: EdgeInsets.only(left: 15),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(08),
//                     // borderSide:
//                     //     BorderSide(color: AppColor.appBarColor, width: 1.0),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(08),
//                     borderSide: const BorderSide(
//                       color: Colors.grey,
//                       width: 1.0,
//                     ),
//                   ),

//                   //labelText: "Select Date"
//                 ),
//                 readOnly: true,
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Please enter date';
//                   }
//                   return null;
//                 },
//                 onTap: () async {
//                   DateTime? dateTime = await showOmniDateTimePicker(
//                     context: context,
//                   );

//                   if (dateTime != null) {
//                     // String formattedDate =
//                     //     DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
//                     //         .format(dateTime.toLocal());
//                     String formattedDate = formatDateWithTimezone(dateTime);

//                     setState(() {
//                       _dateStartInput.text =
//                           formattedDate; //set output date to TextField value.
//                     });
//                     debug('dateTime==>$dateTime===>$formattedDate');
//                   } else {}
//                 },
//               ),
//               if (isEdit == false) const SizedBox(height: 10),
//               if (isEdit == false)
//                 const Text(
//                   'Select Template Category',
//                 ),
//               if (isEdit == false) const SizedBox(height: 5),
//               if (isEdit == false)
//                 AppUtils.getDropdown(
//                   'Select Category',
//                   data: tempateCategory, // Static categories
//                   onChanged: (p0) {
//                     setState(() {
//                       SelectedTemplateCategory = p0;
//                       selectedTemplateName = null; // Reset template dropdown

//                       if (p0 != null) {
//                         templateName1 = [];
//                         String categoryKey =
//                             p0.toLowerCase(); // Convert category to lowercase
//                         debug("Selected Category: $categoryKey");
//                         templateName1 = [
//                           ...allTemplatesMap[categoryKey]?.values ?? [],
//                         ];
//                         debug(
//                           "Updated Template List after selecting category: $templateName1",
//                         );

//                         // If templates are empty, debug
//                         if (templateName1.isEmpty) {
//                           debug(
//                             "No templates found for the selected category: $categoryKey",
//                           );
//                         }
//                       }
//                     });
//                   },
//                   value: SelectedTemplateCategory,
//                 ),
//               if (isEdit == false) const SizedBox(height: 10),
//               if (isEdit == false)
//                 const Text(
//                   'Template Name',
//                 ),
//               if (isEdit == false) const SizedBox(height: 5),
//               if (isEdit == false)
//                 AppUtils.getDropdown(
//                   'Select Template Name',
//                   data: templateName1.isNotEmpty
//                       ? templateName1
//                       : [
//                           'No Templates Available',
//                         ],
//                   onChanged: (p0) {
//                     setState(() {
//                       selectedTemplateName = p0;
//                     });
//                     debug("Selected Template: $selectedTemplateName");
//                   },
//                   value: selectedTemplateName,
//                 ),

//               const SizedBox(height: 10),

//               const Text(
//                 'Group Name',
//               ),

//               const SizedBox(height: 5),

//               MultiSelectDialogField(
//                 items: groupsNameSet
//                     .map(
//                       (group) => MultiSelectItem<String>(
//                         group['id']!,
//                         group['name']!,
//                       ),
//                     )
//                     .toList(),
//                 initialValue: selectedGroups,
//                 title: const Text("Select Groups"),
//                 selectedColor: Colors.blue,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.blue, width: 1),
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 buttonText: const Text("Select Groups"),
//                 onConfirm: (results) {
//                   // Update selectedGroups with selected items
//                   setState(() {
//                     selectedGroups = results.cast<String>();
//                   });
//                   debug(
//                     "Selected groups: $selectedGroups",
//                   ); // debug selected groups
//                 },
//               ),
//               if (isEdit == false) const SizedBox(height: 10),
//               if (isEdit == false)
//                 const Text(
//                   'File Upload',
//                 ),
//               const SizedBox(height: 05),
//               if (isEdit == false)
//                 TextFormField(
//                   //initialValue: widget.model?.title,
//                   controller: fileNameController,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(08),
//                     ),
//                     hintText: 'Choose File',
//                     suffixIcon: const Icon(Icons.add),
//                   ),
//                   readOnly: true,
//                   onTap: () async {
//                     final result = await FilePicker.platform.pickFiles(
//                       allowMultiple: true,
//                       type: FileType.custom,
//                       allowedExtensions: ["jpg", 'png', 'pdf', 'csv'],
//                     );

//                     result == null
//                         ? const Text(
//                             'No File Selected',
//                             style: TextStyle(color: Colors.black),
//                           )
//                         : file = result.files.first;

//                     debug('File Name: ${file?.name}');
//                     debug('File Byte Size: ${file?.size}');
//                     debug('File Type: ${file?.extension}');
//                     debug('File Path: ${file?.path}');
//                     image = File(file!.path.toString());
//                     final convertBytes =
//                         File(file!.path.toString()).readAsBytesSync();
//                     base64Img = base64Encode(convertBytes);
//                     String fileName = file!.path.toString().split('/').last;
//                     fileNameController.text = fileName;
//                     await saveFileToPrefs();
//                     setState(() {});
//                   },
//                 ),

//               const SizedBox(height: 10),

//               const Text(
//                 'Type',
//               ),

//               const SizedBox(height: 5),

//               AppUtils.getDropdown(
//                 'Select',
//                 data: types,
//                 onChanged: (p0) {
//                   setState(() {
//                     _type = p0;
//                   });
//                 },
//                 value: _type,
//               ),
//               if (isEdit == false) const SizedBox(height: 10),
//               if (isEdit == false)
//                 const Text(
//                   'Description',
//                 ),
//               if (isEdit == false) const SizedBox(height: 5),
//               if (isEdit == false)
//                 AppUtils.getTextFormField(
//                   'type description here..',

//                   // initialValue: widget.model?.email,
//                   onSaved: (email) {
//                     _description = email;
//                   },
//                   maxLines: 5,
//                 ),
//               const SizedBox(height: 10),

//               const SizedBox(height: 15),

//               //----------This Code Use of Cancel and Submit Button Showing Start Here---------------
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   OutlinedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.only(left: 10, right: 10),
//                       side: const BorderSide(
//                         width: 1.0,
//                         color: AppColor.navBarIconColor,
//                       ),
//                     ),
//                     child: const Text(
//                       'Cancel',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: AppColor.navBarIconColor,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColor.navBarIconColor,
//                       padding: const EdgeInsets.only(left: 10, right: 10),
//                     ),
//                     onPressed: isEdit ? updateData : onButtonPressed,
//                     child: Text(
//                       isEdit ? "Update" : "Submit",
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               //----------End Code of Cancel and Submit Button Showing Start Here---------------
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String formatDateWithTimezone(DateTime dateTime) {
//     dateTime = dateTime.toLocal();
//     Duration offset = dateTime.timeZoneOffset;
//     String hours = offset.inHours.abs().toString().padLeft(2, '0');
//     String minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
//     String sign = offset.isNegative ? '-' : '+';

//     return "${DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(dateTime)}$sign$hours:$minutes";
//   }

//   void onButtonPressed() async {
//     CampaignViewModel getaccountData = CampaignViewModel(context);

//     if (_addleadFormKey.currentState!.validate()) {
//       _addleadFormKey.currentState!.save();
//       AppUtils.onLoading(context, "Saving, please wait...");
//       Map<String, dynamic> camp = {
//         'name': _name,
//         'template_id': '596762876546658',
//         'template_name': selectedTemplateName,
//         'status': 'Pending',
//         'business_number': number,
//         'type': _type,
//         'startDate': _dateStartInput.text,
//         'group_ids': selectedGroups,
//         'description': _description,
//       };

//       getaccountData.addCampaign(camp).then((value) async {
//         if (value is Map<String, dynamic>) {
//           String? campaignId = value["record"]?["id"];
//           if (campaignId == null) {
//             debug("Campaign ID is null. File upload skipped.");
//             return;
//           }

//           debug("Uploading file with Campaign ID: $campaignId");

//           // await getFileData.addFiles(image!, campaignId, fileData);
//         }
//         // ignore: use_build_context_synchronously
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(
//             builder: (context) => MultiProvider(
//               providers: [
//                 ChangeNotifierProvider(
//                   create: (_) => CampaignViewModel(context),
//                 ),
//               ],
//               child: const CampaignListView(),
//             ),
//           ),
//           (Route<dynamic> route) => route.isFirst,
//         );
//       }).catchError((error, stackTrace) {
//         debug("Error: $error");
//         Navigator.pop(context);
//         AppUtils.getAlert(
//           context,
//           AppUtils.getErrorMessages(error),
//           title: "Error Alert",
//         );
//       });
//     }
//   }

//   Future<void> updateData() async {
//     var id = widget.model?.campaignId;
//     if (_addleadFormKey.currentState!.validate()) {
//       _addleadFormKey.currentState!.save();
//       AppUtils.onLoading(context, "Saving, please wait...");
//       Map<String, dynamic> camp = {
//         'name': _name,
//         'type': _type,
//         'startDate': _dateStartInput.text,
//         'group_ids': selectedGroups,
//       };
//       AppUtils.onLoading(context, "Updating, please wait...");
//       Provider.of<CampaignViewModel>(context, listen: false)
//           .updateCampaign(id, camp)
//           .then((value) {
//         debug('campaignUpdate==$value');
//       });
//       Navigator.pop(context);
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Your record has been updated please pull to refresh '),
//           duration: Duration(seconds: 3),
//           backgroundColor: Colors.green,
//         ),
//       );
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(
//           builder: (context) => MultiProvider(
//             providers: [
//               ChangeNotifierProvider(
//                 create: (_) => CampaignViewModel(context),
//               ),
//             ],
//             child: const CampaignListView(),
//           ),
//         ),
//         (Route<dynamic> route) => route.isFirst,
//       );
//     }
//   }
// }

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
  CampaignAddUpdateView({Key? key, this.model}) : super(key: key);

  @override
  State<CampaignAddUpdateView> createState() => _Forms();
}

class _Forms extends State<CampaignAddUpdateView> {
  TempleteListViewModel? templateVM;
  GroupsViewModel? groupsVM;

  TextEditingController fileNameController = TextEditingController();
  bool isEdit = false;
  String? base64Img;
  ImagePicker picker = ImagePicker();
  XFile? pickedFile;
  PlatformFile? file;
  var number;
  List<String> GroupsName = [];
  List<String> selectedGroups = [];
  String? selectedTemplateName;
  String? SelectedTemplateCategory;
  String? selectedTemplateId;
  var selectedType;
  CampaignModel? campData = CampaignModel();
  File? image;
  // File? image;

  Future<void> saveNumberData() async {
    final prefs = await SharedPreferences.getInstance();
    number = prefs.getString('phoneNumber');
    debug("this is my number $number");
    Provider.of<TempleteListViewModel>(
      context,
      listen: false,
    ).templetefetch(number: number ?? "");
  }

  @override
  void initState() {
    super.initState();
    saveNumberData();
    final model = widget.model;
    if (model != null) {
      isEdit = true;
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
  List<dynamic> tempateCategory = ['UTILITY', 'MARKETING'];
  // Map<String, List<String>> allTemplatesMap = {};
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

  @override
  Widget build(BuildContext context) {
    debug('hello $templateName1');
    templateVM = Provider.of<TempleteListViewModel>(context);
    groupsVM = Provider.of<GroupsViewModel>(context);
    _getaccountData = Provider.of<CampaignViewModel>(context);

    for (var viewModel in templateVM!.viewModels) {
      TemplateModel tempmodel = viewModel.model;
      for (var record in tempmodel.data ?? []) {
        if (record.name != null && record.category != null) {
          String categoryKey = record.category!.toLowerCase();
          debug('categoryKey my : $categoryKey');

          allTemplatesMap.putIfAbsent(categoryKey, () => {});
          allTemplatesMap[categoryKey]?[record.id] = (record.name!);
        }
      }
    }
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
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        automaticallyImplyLeading: true,
        centerTitle: true,
        elevation: 2,
        backgroundColor: AppColor.navBarIconColor,
        title: Text(
          isEdit ? "Edit Campaign" : "Add Campaign",
          style: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: _pageBody(),
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
  // this code use of download file end here

  Widget _pageBody() {
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
              Text(
                'Campaign Name',
              ),
              const SizedBox(height: 5),
              AppUtils.getTextFormField(
                'Enter Campaign Name',
                // initialValue: widget.model?.records,
                onSaved: (value) {
                  _name = value;
                },
                initialValue: widget.model?.campaignName,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Text(
                'Start Date & Time',
              ),
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
                  // contentPadding: EdgeInsets.only(left: 15),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(08),
                    // borderSide:
                    //     BorderSide(color: AppColor.appBarColor, width: 1.0),
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
                  DateTime? dateTime = await showOmniDateTimePicker(
                    context: context,
                  );

                  if (dateTime != null) {
                    // String formattedDate =
                    //     DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
                    //         .format(dateTime.toLocal());
                    String formattedDate = formatDateWithTimezone(dateTime);

                    setState(() {
                      _dateStartInput.text =
                          formattedDate; //set output date to TextField value.
                    });
                    debug('dateTime==>$dateTime===>$formattedDate');
                  } else {}
                },
              ),
              if (isEdit == false) const SizedBox(height: 10),
              if (isEdit == false)
                Text(
                  'Select Template Category',
                ),
              if (isEdit == false) const SizedBox(height: 5),
              if (isEdit == false)
                AppUtils.getDropdown(
                  'Select Category',
                  data: tempateCategory, // Static categories
                  onChanged: (p0) {
                    setState(() {
                      SelectedTemplateCategory = p0;
                      selectedTemplateName = null; // Reset template dropdown

                      if (p0 != null) {
                        templateName1 = [];
                        String categoryKey =
                            p0.toLowerCase(); // Convert category to lowercase
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
              if (isEdit == false) const SizedBox(height: 10),
              if (isEdit == false)
                Text(
                  'Template Name',
                ),
              if (isEdit == false) const SizedBox(height: 5),
              if (isEdit == false)
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
                  },
                  value: selectedTemplateName,
                ),

              const SizedBox(height: 10),

              Text(
                'Group Name',
              ),

              const SizedBox(height: 5),

              MultiSelectDialogField(
                items: groupsNameSet
                    .map(
                      (group) => MultiSelectItem<String>(
                        group['id']!,
                        group['name']!,
                      ),
                    )
                    .toList(),
                initialValue: selectedGroups,
                title: Text("Select Groups"),
                selectedColor: Colors.blue,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                buttonText: Text("Select Groups"),
                onConfirm: (results) {
                  // Update selectedGroups with selected items
                  setState(() {
                    selectedGroups = results.cast<String>();
                  });
                  debug(
                    "Selected groups: $selectedGroups",
                  ); // debug selected groups
                },
              ),
              if (isEdit == false) const SizedBox(height: 10),
              if (isEdit == false)
                Text(
                  'File Upload',
                ),
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
                      allowedExtensions: ["jpg", 'png', 'pdf', 'csv'],
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
                    image = File(file!.path.toString());
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

              Text(
                'Type',
              ),

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
              if (isEdit == false)
                Text(
                  'Description',
                ),
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

              //----------This Code Use of Cancel and Submit Button Showing Start Here---------------
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      side: const BorderSide(
                        width: 1.0,
                        color: AppColor.navBarIconColor,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColor.navBarIconColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.navBarIconColor,
                      padding: const EdgeInsets.only(left: 10, right: 10),
                    ),
                    onPressed: isEdit ? updateData : onButtonPressed,
                    child: Text(
                      isEdit ? "Update" : "Submit",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              //----------End Code of Cancel and Submit Button Showing Start Here---------------
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

    return DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(dateTime) +
        "$sign$hours:$minutes";
  }

  void onButtonPressed() async {
    CampaignViewModel getaccountData = CampaignViewModel(context);

    if (_addleadFormKey.currentState!.validate()) {
      _addleadFormKey.currentState!.save();
      AppUtils.onLoading(context, "Saving, please wait...");
      Map<String, dynamic> camp = {
        'name': _name,
        'template_id': '596762876546658',
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
          if (campaignId == null) {
            debug("Campaign ID is null. File upload skipped.");
            return;
          }

          debug("Uploading file with Campaign ID: $campaignId");

          // await getFileData.addFiles(image!, campaignId, fileData);
        }
        // ignore: use_build_context_synchronously
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
    }
  }

  Future<void> updateData() async {
    var id = widget.model?.campaignId;
    if (_addleadFormKey.currentState!.validate()) {
      _addleadFormKey.currentState!.save();
      AppUtils.onLoading(context, "Saving, please wait...");
      Map<String, dynamic> camp = {
        'name': _name,
        'type': _type,
        'startDate': _dateStartInput.text,
        'group_ids': selectedGroups,
      };
      print("camp before siending::: ${camp}");
      AppUtils.onLoading(context, "Updating, please wait...");
      Provider.of<CampaignViewModel>(context, listen: false)
          .updateCampaign(id, camp)
          .then((value) {
        debug('campaignUpdate==$value');
      });
      Navigator.pop(context);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your record has been updated please pull to refresh '),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
        ),
      );
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
    }
  }
}
