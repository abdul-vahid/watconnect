// import 'dart:developer';

// import 'dart:convert';
// import 'dart:io';
// import 'dart:ui';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:open_file/open_file.dart';
// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart' show Provider;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:whatsapp/models/approved_template_model/aprovedtempltemodel/component.dart';
// import 'package:whatsapp/models/approved_template_model/aprovedtempltemodel/datum.dart';
// import 'package:whatsapp/models/lead_model.dart';
// import 'package:whatsapp/utils/app_color.dart';
// import 'package:whatsapp/utils/function_lib.dart';
// import 'package:whatsapp/view_models/templete_list_vm.dart';
// import 'package:whatsapp/views/view/show_pdf.dart';
// import 'package:whatsapp/views/view/show_video.dart';

// import '../../models/template_model/template_model.dart';
// import '../../models/user_model/user_model.dart';
// import '../../utils/app_utils.dart';
// import '../../view_models/message_list_vm.dart';

// import 'package:loading_animation_widget/loading_animation_widget.dart';

// class ChatScreen extends StatefulWidget {
//   final String? leadName;
//   final String? wpnumber;
//   final LeadModel model;
//   const ChatScreen({
//     Key? key,
//     this.leadName,
//     this.wpnumber,
//     required this.model,
//   }) : super(key: key);

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   List<TextEditingController> controllers = [];

//   List<String> templateNamesss = []; // Global list to store template names
//   List<String> templateIds = []; // Global list to store template ids
//   String msghistoryid = "";
//   final ScrollController _scrollController = ScrollController();
//   bool isImageSent = false;
//   bool _isLoading = true;
//   int lenOfRec = 0;
//   String? globalParentId;
//   XFile? selectedImage;
//   String base64Image = '';
//   String? SelectedTemplateCategory;
//   Map<String, Map<String, dynamic>> allTemplatesMap = {};
//   List<dynamic> templateName1 = [];
//   String? templeteidmessage;
//   List<String> templateNames = [];
//   String? selectedTemplate;
//   String templetmsgid = "";
//   var templeteViewModel;
//   String messageid = "";
//   late MessageViewModel messageViewModel;
//   final TextEditingController _controller = TextEditingController();
//   TextEditingController fileNameController = TextEditingController();
//   ImagePicker picker = ImagePicker();
//   File? image;
//   PlatformFile? file;
//   bool isRefresh = false;
//   UserModel? userModel;
//   bool historyExists = false;
//   List allMessages = [];
//   String? fileid;
//   List<dynamic> tempateCategory = ['UTILITY', 'MARKETING', 'AUTHENTICATION'];
//   String? selectedTemplateName;

//   var selectedHeader;
//   var selectedBody;
//   var selectedFooter;
//   dynamic? selectedButtons;

//   TempleteListViewModel? templateVM;

//   bool showLoader = false;
//   String userName = "";
//   @override
//   void initState() {
//     _fetchTemplates();
//     super.initState();
//     _pullRefresh();
//     showLoader = false;
//     _getPhoneNumber();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollToBottom();
//     });
//     print("Lead Number =>${widget.wpnumber}    ");
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent + 200,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     log("is build method calling alwayss");
//     messageViewModel = Provider.of<MessageViewModel>(context);

//     allMessages = [];
//     for (var viewModel in messageViewModel.viewModels) {
//       final model = viewModel.model;
//       if (model.records?.isNotEmpty ?? false) {
//         allMessages.addAll(messageViewModel.viewModels[0].model.records);
//       }
//     }
//     _scrollToBottom();
//     setState(() {});
//     print("all messages:: ${allMessages.length}  ${allMessages}");

//     templateVM = Provider.of<TempleteListViewModel>(context);
//     messageViewModel = Provider.of<MessageViewModel>(context);
//     if (templateVM != null && templateVM?.viewModels != null)
//       for (var viewModel in templateVM!.viewModels) {
//         TemplateModel tempmodel = viewModel.model;
//         for (var record in tempmodel.data ?? []) {
//           if (record.name != null && record.category != null) {
//             String categoryKey = record.category!.toLowerCase();

//             allTemplatesMap.putIfAbsent(categoryKey, () => {});
//             allTemplatesMap[categoryKey]?[record.id] = (record.name!);
//           }
//         }
//       }
//     debug("All Templates Map Data: $allTemplatesMap");

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back,
//             color: Colors.white,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: GestureDetector(
//           onTap: () {
//             _showProfileDialog(context);
//           },
//           child: Row(
//             children: [
//               const CircleAvatar(
//                 backgroundImage: NetworkImage(
//                   'https://www.w3schools.com/w3images/avatar2.png',
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
// <<<<<<< HEAD
//                   (widget.leadName?.isNotEmpty ?? false)
//                       ? widget.leadName!
//                       : "No Name Available",
// =======
//                   widget.leadName ?? "",
// >>>>>>> 813b123304381bd70160caac717d8440da61f371
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           PopupMenuButton<String>(
//             icon: const Icon(
//               Icons.more_vert,
//               color: Colors.white,
//             ),
// <<<<<<< HEAD
//             onSelected: (String value) {
//               if (value == 'delete') {
//                 _showDeleteDialog(); // Show the delete dialog when 'Delete' is selected
//               }
// =======
//             onPressed: () {
//               _showDeleteDialog();
// >>>>>>> 813b123304381bd70160caac717d8440da61f371
//             },
//             itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//               const PopupMenuItem<String>(
//                 value: 'delete',
//                 child: Text('Delete'),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: Container(
//         child: Stack(
//           children: [
//             RefreshIndicator(
//               onRefresh: _pullRefresh,
//               child: _isLoading ? Container() : _pageBody(),
//             ),
//             if (_isLoading)
//               Positioned.fill(
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
//                   child: Container(
//                     color: Colors.white.withOpacity(0.2),
//                     child: Center(
//                       child: LoadingAnimationWidget.flickr(
//                         leftDotColor: AppColor.cardsColor,
//                         rightDotColor: AppColor.navBarIconColor,
//                         size: 40,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showProfileDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Center(
//                   child: CircleAvatar(
//                     radius: 50,
//                     backgroundImage: NetworkImage(
//                       'https://www.w3schools.com/w3images/avatar2.png',
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Center(
//                   child: Text(
//                     widget.leadName ?? "No Name Provided",
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 18),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Center(
//                   child: Text(
//                     widget.wpnumber ?? "No Name Provided",
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 18),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: AppColor.navBarIconColor,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Text(
//                   "Close",
//                   style: TextStyle(
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void deletechat() async {
//     print("delete function callin g working");
//     final prefs = await SharedPreferences.getInstance();
//     String? number = prefs.getString('phoneNumber');
//     late MessageViewModel msgdelete = MessageViewModel(context);
//     msgdelete
//         .msghistorydelete(leadnumber: widget.wpnumber, number: number)
//         .then((value) => {
//               print("deeeelete sucefulyyy"),
//             });
//   }

//   Future<void> _showDeleteDialog() async {
//     await showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'Are you sure you want to delete this Chat histoy?',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.black,
//                 ),
//               ),
//               const SizedBox(height: 15),
//               const Divider(),
//               const SizedBox(height: 15),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   TextButton(
//                     style: TextButton.styleFrom(
//                       foregroundColor: Colors.grey,
//                       backgroundColor: Colors.grey[200],
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Text(
//                       'No',
//                       style: TextStyle(fontSize: 14),
//                     ),
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                   const SizedBox(width: 20),
//                   TextButton(
//                     style: TextButton.styleFrom(
//                       foregroundColor: Colors.white,
//                       backgroundColor: AppColor.navBarIconColor,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Text(
//                       'Yes',
//                       style: TextStyle(fontSize: 14),
//                     ),
//                     onPressed: () {
//                       deletechat();
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void messagesendd(String text) async {
//     print("messagesendd called");

//     late TempleteListViewModel tm = TempleteListViewModel(context);
//     late MessageViewModel ms = MessageViewModel(context);
//     final prefs = await SharedPreferences.getInstance();
//     String? number = prefs.getString('phoneNumber');
//     print("numbernumbernumber${number}");
//     if (number == null || number.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Phone number not found'),
//           duration: Duration(seconds: 3),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//     print("wpppp=>${widget.wpnumber}");
//     var leadnumber = widget.wpnumber;
//     Map<String, dynamic> addmsModel = {
//       "messaging_product": "whatsapp",
//       "recipient_type": "individual",
//       "to": leadnumber,
//       "type": "text",
//       "text": {"preview_url": false, "body": text}
//     };

//     Map<String, dynamic> msgmobilebody = {
//       "parent_id": widget.model.id,
//       "name": widget.leadName,
//       "message_template_id": null,
//       "whatsapp_number": leadnumber,
//       "message": text,
//       "status": "Outgoing",
//       "recordtypename": "lead",
//       "file_id": null,
//       "is_read": true,
//       "business_number": number,
//       "message_id": messageid
//     };
//     print("msgmobilebody${msgmobilebody}");
//     ms.sendMessage(number: number, addmsModel: addmsModel).then((value) {
//       print("valueee=>$value");
//       if (value.isNotEmpty) {
//         var messageId = value['messages'];
//         print('Message ID: ${messageId[0]['id']}');
//         messageid = messageId[0]['id'];
//         msgmobilebody['message_id'] = messageid;

//         ms.sendmsgmobile(msgmobilbody: msgmobilebody).then((value) {
//           print("valueee1=>$value");
//           if (value['delivery_status'] == "sent") {
//             _controller.clear();

//             setState(() {
//               showLoader = false;
//             });
//           }
//         });

//         ms.Fetchmsghistorydata(leadnumber: leadnumber, number: number);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Message sent successfully'),
//             duration: Duration(seconds: 3),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to send message'),
//             duration: Duration(seconds: 3),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }).catchError((error) {
//       Navigator.pop(context);
//       print('Error: $error');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $error'),
//           duration: const Duration(seconds: 3),
//           backgroundColor: Colors.red,
//         ),
//       );
//     });
//   }

//   void templetesendd(String templateToSend, List? compo) async {
//     print("tempeeppeppepepeppep=>$templateToSend");
//     late MessageViewModel mstemp = MessageViewModel(context);
//     print("agyaaaaaaaaaa");
//     TempleteListViewModel templeteViewModel =
//         Provider.of<TempleteListViewModel>(context, listen: false);
//     print("wpppp=>${widget.wpnumber}");
//     var leadnumber = widget.wpnumber;
//     final prefs = await SharedPreferences.getInstance();
//     String? number = prefs.getString('phoneNumber');

//     Map<String, dynamic> templateBody = {
//       "messaging_product": "whatsapp",
//       "to": leadnumber,
//       "type": "template",
// <<<<<<< HEAD
//       // "category": "MARKETING",
// =======
// >>>>>>> 813b123304381bd70160caac717d8440da61f371
//       "template": {
//         "name": templateToSend,
//         "language": {"code": "en_US"},
//         "components": [
//           {"type": "header", "parameters": []},
//           {"type": "body", "parameters": []}
//         ]
//       }
//     };
//     print("templetete body=>$templateBody");

//     Map<String, dynamic> createtemp = {
//       "id": null,
//       "name": templateToSend,
//       "language": "en",
//       "category": "MARKETING",
//       "header": "TEXT",
//       "header_body": "template header",
//       "message_body": templateToSend,
//       "example_body_text": {"sendToAdmin": false},
//       "footer": selectedFooter.text,
//       "buttons": [],
//       "business_number": number
//     };

//     mstemp.createmsgtemplete(msgmobilbody: createtemp).then((value) => {
//           templeteidmessage = value['id'],
//           print("temmplet msg id==========>$templeteidmessage"),
//           print("ccretae objetctt resposne= > $value")
//         });

//     mstemp
//         .sendtemplete(number: number, msgmobilbody: templateBody)
//         .then((value) {
//       print("value=== templete>$value");
//       print("value=== template>${value['messages'][0]['id']}");

//       Map<String, dynamic> msghistorydata = {
//         "parent_id": widget.model.id,
//         "name": widget.leadName,
//         "message_template_id": templeteidmessage,
//         "whatsapp_number": leadnumber,
//         "message": "",
//         "status": "Outgoing",
//         "recordtypename": "recentlyMessage",
//         "file_id": null,
//         "is_read": true,
//         "business_number": number,
//         "message_id": templetmsgid,
//         "id": currentTemplate.id
//       };

//       print("body before sending::: ${msghistorydata}");
//       mstemp.semdtempmsghistory(msghistorydata: msghistorydata).then(
//           (value) => {print("semdtempmsghistorysemdtempmsghistory=>$value")});
//     });

//     print("temmplet msg::::: id==========>$templeteidmessage");
//   }

//   Future<void> _pullRefresh() async {
//     setState(() {
//       _isLoading = true;
//     });

//     await Future.delayed(const Duration(seconds: 1));

//     setState(() {
//       _isLoading = false;
//     });
//     var leadnumber = widget.wpnumber;
//     final prefs = await SharedPreferences.getInstance();
//     String? number = prefs.getString('phoneNumber');
//     print("number=>$number");
//     await Provider.of<MessageViewModel>(context, listen: false)
//         .Fetchmsghistorydata(leadnumber: leadnumber, number: number);
//     await Future.delayed(const Duration(seconds: 1));
//   }

//   Future<void> _getPhoneNumber() async {
//     final prefs = await SharedPreferences.getInstance();
//     userName = prefs.getString('userName') ?? "Me";
//     setState(() {});
//     String? number = prefs.getString('phoneNumber');
//     if (number != null) {
//       messageViewModel.Fetchmsghistorydata(
//         leadnumber: widget.wpnumber ?? "",
//         number: number,
//       );
//     } else {
//       print('Number not found in SharedPreferences');
//     }
//     _getProfileData();
//   }

//   Future<void> _getProfileData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       userModel = AppUtils.getSessionUser(prefs);
//     });
//   }

//   void _showPicker() async {
//     await showModalBottomSheet(
//       context: context,
//       backgroundColor: AppColor.navBarIconColor,
//       builder: (context) => Wrap(
//         children: <Widget>[
//           ListTile(
//             leading: const Icon(Icons.photo_library, color: Colors.white),
//             title: const Text(
//               'Choose from Gallery',
//               style: TextStyle(color: Colors.white),
//             ),
//             onTap: _pickImageFromGallery,
//           ),
//           ListTile(
//             leading: const Icon(Icons.camera_alt, color: Colors.white),
//             title: const Text(
//               'Take a Photo',
//               style: TextStyle(color: Colors.white),
//             ),
//             onTap: _pickImageFromCamera,
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _pickImageFromGallery() async {
//     final pickedFile = await FilePicker.platform.pickFiles(
//       allowMultiple: false,
//       type: FileType.custom,
//       allowedExtensions: ["jpg", 'png', 'pdf', 'html', 'mp4', 'mov', 'avi'],
//     );
//     if (pickedFile != null) {
//       file = pickedFile.files.first;

//       setState(() {
//         image = File(file!.path!);
//         print("image::: ${image}");
//         fileNameController.text = file!.name;
//       });
//     }
//     Navigator.of(context).pop();
//   }

//   Future<void> _pickImageFromCamera() async {
//     final pickedFile = await picker.pickImage(
//       source: ImageSource.camera,
//       imageQuality: 80,
//     );
//     if (pickedFile != null) {
//       setState(() {
//         image = File(pickedFile.path);
//         fileNameController.text = pickedFile.path.split('/').last;
//       });
//     }
//     Navigator.of(context).pop();
//   }

//   void filesend(String type) {
//     print("typyp=>$type");
//     if (type == "image") {
//       imagesend(type);
//     } else if (type == "document" || type == "pdf") {
//       documetsend(type);
//     } else if (type == "video") {
//       print("SAdddddddddddddddddddddd");
//       videosend(type);
//     } else {
//       debugPrint("Unsupported file type: $type");
//     }
//   }

// <<<<<<< HEAD
//   void videosend(type) async {
//     print("woking....");
//     final prefs = await SharedPreferences.getInstance();
//     String? number = prefs.getString('phoneNumber');
//     if (image != null) {
//       print("image=>$image");
//       String? response = await messageViewModel.uploadvideo(image!, number);
//       if (response != null) {
//         print("type===>$type");
//         debugPrint('video sedn video sendResponse: $response');
//         var jsonResponse = jsonDecode(response);
//         String? doucmentid = jsonResponse['id'];
//         debugPrint('video sedn video send File ID: $doucmentid');
//         Map<String, dynamic> imagebody = {
//           "messaging_product": "whatsapp",
//           "recipient_type": "individual",
//           "to": widget.model.whatsapp_number,
//           "type": type,
//           type: {"id": doucmentid, "caption": "document"}
//         };
//         String? responseimage = await messageViewModel
//             .uploadimagewithdoucmentid(bodyy: imagebody, number: number)
//             .then((value) {
//           print("video sedn video send send value----->$value");
//           return null;
//         });

//         String? leadid = widget.model.id;
//         print("video sedn video send sned lead id=>$leadid");

//         String? sendimagedatabase = await messageViewModel
//             .uploadFiledb(image!, number, leadid)
//             .then((value) {
//           print("video sedn video send send----upload dididi->$value");

//           Map<String, dynamic> response = jsonDecode(value);

//           fileid = response['records']?[0]['id'];

//           print("ID: $fileid");
//           return null;
//         });
//         debug("widget.leadNamewidget.leadName${widget.leadName}");
//         Map<String, dynamic> imagehistorydata = {
//           "parent_id": leadid,
//           "name": widget.leadName,
//           "message_template_id": null,
//           "whatsapp_number": widget.wpnumber,
//           "message": "",
//           "status": "Outgoing",
//           "recordtypename": "lead",
//           "file_id": fileid,
//           "business_number": number,
//           "is_read": true
//         };
//         print("\x1B[33mdsdsfsdfsd$imagehistorydata\x1B[0m");

//         print("fileidfileid$fileid");
//         String? sendhistoryimage = await messageViewModel
//             .sendimagehistory(
//           msghistorydata: imagehistorydata,
//         )
//             .then((value) {
//           print("\x1B[32msendhistoryimagesendhistoryimage$value\x1B[0m");
//           return null;
//         });
//       } else {
//         debugPrint('Image upload failed or response was null');
//       }
//     } else {
//       debugPrint('No image selected');
// =======
//   String docId = "";

//   Future<String> getDocId() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? number = prefs.getString('phoneNumber');
//     String? response = await messageViewModel.uploadFile(image!, number);
//     if (response != null) {
//       var jsonResponse = jsonDecode(response);
//       return jsonResponse['id'].toString();
//     } else {
//       return "";
// >>>>>>> 813b123304381bd70160caac717d8440da61f371
//     }
//   }

//   void imagesend(String type) async {
//     print("woking....");
//     final prefs = await SharedPreferences.getInstance();
//     String? number = prefs.getString('phoneNumber');

//     if (image != null) {
//       print("type===> image  $type");
//       String? response = await messageViewModel.uploadFile(image!, number);

//       if (response != null) {
//         debugPrint('Image uploaded successfully, Response: $response');

//         var jsonResponse = jsonDecode(response);
//         String? doucmentid = jsonResponse['id'];

//         debugPrint('Uploaded File ID: $doucmentid');
//         debugPrint(
//             "widget.model.whatsapp_number${widget.model.whatsapp_number}");
//         Map<String, dynamic> imagebody = {
//           "messaging_product": "whatsapp",
//           "recipient_type": "individual",
//           "to": widget.model.whatsapp_number,
//           "type": type,
//           type: {"id": doucmentid, "caption": "Image caption"}
//         };
//         print("ississiis=>$imagebody");
//         String? responseimage = await messageViewModel
//             .uploadimagewithdoucmentid(bodyy: imagebody, number: number)
//             .then((value) {
//           print("value----->$value");
//           return null;
//         });

//         String? leadid = widget.model.id;
//         print("leadid=>$leadid");

//         String? sendimagedatabase = await messageViewModel
//             .uploadFiledb(image!, number, leadid)
//             .then((value) {
//           print("value----upload dididi->${value}");

//           Map<String, dynamic> response = jsonDecode(value);

//           fileid = response['records']?[0]['id'];

//           print("ID: $fileid");
//           return null;
//         });

//         Map<String, dynamic> imagehistorydata = {
//           "parent_id": leadid,
//           "name": widget.leadName,
//           "message_template_id": null,
//           "whatsapp_number": widget.wpnumber,
//           "message": "",
//           "status": "Outgoing",
//           "recordtypename": "lead",
//           "file_id": fileid,
//           "business_number": number,
//           "is_read": true
//         };
//         print("\x1B[33mdsdsfsdfsd${imagehistorydata}\x1B[0m");

//         print("fileidfileid${fileid}");
//         String? sendhistoryimage = await messageViewModel
//             .sendimagehistory(
//           msghistorydata: imagehistorydata,
//         )
//             .then((value) {
//           print("\x1B[32msendhistoryimagesendhistoryimage${value}\x1B[0m");
//           return null;
//         });
//       } else {
//         debugPrint('Image upload failed or response was null');
//       }
//     } else {
//       debugPrint('No image selected');
//     }
//     print("after all functions arecalled::::");
//     setState(() {
//       isImageSent = true;
//       showLoader = false;
//     });
//   }

//   void documetsend(type) async {
//     print("woking....");
//     final prefs = await SharedPreferences.getInstance();
//     String? number = prefs.getString('phoneNumber');

//     if (image != null) {
//       String? response = await messageViewModel.uploadFile(image!, number);

//       if (response != null) {
//         print("type===>$type");
//         debugPrint('doucment uploaded successfully, Response: $response');

//         var jsonResponse = jsonDecode(response);
//         String? doucmentid = jsonResponse['id'];
//         debugPrint('doument File ID: $doucmentid');
//         Map<String, dynamic> imagebody = {
//           "messaging_product": "whatsapp",
//           "recipient_type": "individual",
//           "to": widget.model.whatsapp_number,
//           "type": type,
//           type: {"id": doucmentid, "caption": "document"}
//         };
//         String? responseimage = await messageViewModel
//             .uploadimagewithdoucmentid(bodyy: imagebody, number: number)
//             .then((value) {
//           print("document send value----->$value");
//           return null;
//         });

//         String? leadid = widget.model.id;
//         print("document sned lead id=>$leadid");

//         String? sendimagedatabase = await messageViewModel
//             .uploadFiledb(image!, number, leadid)
//             .then((value) {
//           print("document send----upload dididi->${value}");

//           Map<String, dynamic> response = jsonDecode(value);

//           fileid = response['records']?[0]['id'];

//           print("ID: $fileid");
//           return null;
//         });
//         debug("widget.leadNamewidget.leadName${widget.leadName}");
//         Map<String, dynamic> imagehistorydata = {
//           "parent_id": leadid,
//           "name": widget.leadName,
//           "message_template_id": null,
//           "whatsapp_number": widget.wpnumber,
//           "message": "",
//           "status": "Outgoing",
//           "recordtypename": "lead",
//           "file_id": fileid,
//           "business_number": number,
//           "is_read": true
//         };
//         print("\x1B[33mdsdsfsdfsd${imagehistorydata}\x1B[0m");

//         print("fileidfileid${fileid}");
//         String? sendhistoryimage = await messageViewModel
//             .sendimagehistory(
//           msghistorydata: imagehistorydata,
//         )
//             .then((value) {
//           print("\x1B[32msendhistoryimagesendhistoryimage${value}\x1B[0m");
//           return null;
//         });
//       } else {
//         debugPrint('Image upload failed or response was null');
//       }
//     } else {
//       debugPrint('No image selected');
//     }

//     setState(() {
//       isImageSent = true;
//       showLoader = false;
//     });
//   }

//   Widget _pageBody() {
//     print("all messages length::: ${allMessages.length}");
//     return Column(
//       children: [
//         Expanded(
//           child: ListView.builder(
//               controller: _scrollController,
//               itemCount: allMessages.length,
//               itemBuilder: (context, index) {
//                 DateTime now = DateTime.now();
//                 String formattedTime = DateFormat('hh:mm a').format(now);

//                 DateTime utcTime = allMessages[index].createddate;
//                 DateTime istTimee =
//                     utcTime.add(const Duration(hours: 5, minutes: 30));
//                 formattedTime = DateFormat('hh:mm a').format(istTimee);
//                 bool isSameDay(DateTime? dateA, DateTime? dateB) {
//                   return dateA?.year == dateB?.year &&
//                       dateA?.month == dateB?.month &&
//                       dateA?.day == dateB?.day;
//                 }

//                 // DateTime now = DateTime.now();

//                 String dayLabel = '';
//                 if (isSameDay(istTimee, now)) {
//                   dayLabel = 'Today';
//                 } else if (isSameDay(
//                     istTimee, now.subtract(const Duration(days: 1)))) {
//                   dayLabel = 'Yesterday';
//                 } else {
//                   dayLabel = DateFormat('EEEE').format(istTimee);
//                 }
//                 // String formattedTimee = DateFormat('hh:mm a').format(istTimee);

//                 // String finalFormattedTime = '$dayLabel, $formattedTimee';
//                 String finalFormattedTime = '$dayLabel';
//                 // print("finalFormattedTime=>$finalFormattedTime");

//                 // print(finalFormattedTime);
//                 String title = allMessages[index].title ?? "";
//                 String msghistoryid = allMessages[index].id;
//                 // print("sjdhjshdjas=>$msghistoryid");
//                 String imageUrl = "";
//                 if (title.isNotEmpty) {
//                   imageUrl =
//                       "https://sandbox.watconnect.com/public/demo/attachment/$title";
//                 }

//                 return GestureDetector(
//                   onLongPress: () => _showSimpleDialog(allMessages[index].id),
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 5),
//                     padding: const EdgeInsets.all(1),
//                     child: Align(
//                       alignment: _getAlignment(allMessages[index].status),
//                       child: Padding(
//                         padding: const EdgeInsets.all(2.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             if (index == 0)
//                               Align(
//                                 alignment: Alignment.topCenter,
//                                 child: Text(
//                                   finalFormattedTime,
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 14,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               )
//                             else
//                               const SizedBox.shrink(),
//                             Text(
//                               allMessages[index].status == "Incoming"
//                                   ? allMessages[index].name
//                                   : userName,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 13,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             if (allMessages[index].message != null &&
//                                 allMessages[index].message!.isNotEmpty)
//                               IntrinsicWidth(
//                                 child: Container(
//                                   constraints: BoxConstraints(
//                                     maxWidth:
//                                         MediaQuery.of(context).size.width *
//                                             0.65,
//                                   ),
//                                   margin:
//                                       const EdgeInsets.symmetric(vertical: 4),
//                                   padding: const EdgeInsets.all(10),
//                                   decoration: BoxDecoration(
//                                     color:
//                                         allMessages[index].status == "Outgoing"
//                                             ? const Color(0xff594EBA)
//                                             : const Color(0xff221B41),
//                                     borderRadius: BorderRadius.only(
//                                       topLeft: const Radius.circular(12),
//                                       topRight: const Radius.circular(12),
//                                       bottomLeft: allMessages[index].status ==
//                                               "Outgoing"
//                                           ? const Radius.circular(12)
//                                           : const Radius.circular(0),
//                                       bottomRight: allMessages[index].status ==
//                                               "Outgoing"
//                                           ? const Radius.circular(0)
//                                           : const Radius.circular(12),
//                                     ),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.2),
//                                         blurRadius: 4,
//                                         offset: const Offset(2, 2),
//                                       )
//                                     ],
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         allMessages[index].message!,
//                                         style: const TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.white,
//                                           height: 1.5,
//                                         ),
//                                         maxLines: 4,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                       const SizedBox(height: 6),
//                                       if (allMessages[index].status ==
//                                           "Outgoing")
//                                         if (allMessages[index].deliveryStatus !=
//                                             null)
//                                           Align(
//                                             alignment: Alignment.bottomRight,
//                                             child: Icon(
//                                               Icons.done_all,
//                                               color: allMessages[index]
//                                                           .deliveryStatus ==
//                                                       "read"
//                                                   ? Colors.green
//                                                   : Colors.white,
//                                               size: 16,
//                                             ),
//                                           ),
//                                       if (allMessages[index].erormessage !=
//                                               null &&
//                                           allMessages[index]
//                                               .erormessage
//                                               .isNotEmpty)
//                                         Text(
//                                           allMessages[index].erormessage,
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 10,
//                                             color: Colors.red,
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               )
//                             else
//                               const SizedBox.shrink(),
//                             if (allMessages[index].templateName != null ||
//                                 allMessages[index].headerBody != null)
//                               Container(
//                                 constraints: BoxConstraints(
//                                   maxWidth:
//                                       MediaQuery.of(context).size.width * 0.65,
//                                 ),
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 8,
//                                   horizontal: 12,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.only(
//                                     topLeft: Radius.circular(8),
//                                     topRight: Radius.circular(8),
//                                     bottomLeft: Radius.circular(8),
//                                     bottomRight: Radius.circular(0),
//                                   ),
//                                   color: allMessages[index].status == "Outgoing"
//                                       ? const Color(0xff594EBA)
//                                       : const Color(0xff221B41),
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     RichText(
//                                       text: TextSpan(
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 14,
//                                           color: Colors.white,
//                                         ),
//                                         children: [
//                                           if (allMessages[index].headerBody !=
//                                               null)
//                                             TextSpan(
//                                               text:
//                                                   '${capitalize(allMessages[index].headerBody!)}\n',
//                                               style: const TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           if (allMessages[index].templateName !=
//                                               null)
//                                             TextSpan(
//                                               text:
//                                                   '${allMessages[index].templateName}\n',
//                                               style: const TextStyle(
//                                                   // Slightly heavier for emphasis
//                                                   ),
//                                             ),
//                                           if (allMessages[index].footer != null)
//                                             TextSpan(
//                                               text: allMessages[index].footer,
//                                               style: const TextStyle(
//                                                 fontWeight: FontWeight.normal,
//                                                 fontSize: 12,
//                                                 color: Colors.grey,
//                                               ),
//                                             ),
//                                         ],
//                                       ),
//                                     ),
//                                     if (allMessages[index].status == "Outgoing")
//                                       if (allMessages[index].deliveryStatus ==
//                                               "delivered" ||
//                                           allMessages[index].deliveryStatus ==
//                                               "sent")
//                                         Row(
//                                           mainAxisAlignment:
//                                               allMessages[index].status ==
//                                                       "Outgoing"
//                                                   ? MainAxisAlignment.end
//                                                   : MainAxisAlignment.start,
//                                           children: [
//                                             IconButton(
//                                               icon: const Icon(
//                                                 Icons.done_all,
//                                                 color: Color.fromARGB(
//                                                     255, 255, 255, 255),
//                                               ),
//                                               onPressed: () {},
//                                             ),
//                                           ],
//                                         ),
//                                     if (allMessages[index].deliveryStatus ==
//                                         "read")
//                                       IconButton(
//                                         icon: const Icon(Icons.done_all,
//                                             color: Colors.green),
//                                         onPressed: () {},
//                                       )
//                                     else
//                                       const SizedBox.shrink(),
//                                   ],
//                                 ),
//                               )
//                             else
//                               const SizedBox.shrink(),
//                             Text(
//                               formattedTime,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                             if (imageUrl.isNotEmpty)
//                               Container(
//                                 margin: const EdgeInsets.symmetric(vertical: 8),
//                                 child: GestureDetector(
//                                   onTap: () async {
//                                     print(
//                                         "imageurl before show::: ${imageUrl}");
//                                     if (imageUrl
//                                         .split('.')
//                                         .last
//                                         .contains('pdf')) {
//                                       Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (context) => ViewPdf(
//                                                     pdfUrl: imageUrl,
//                                                   )));
//                                     } else if (imageUrl
//                                         .split('.')
//                                         .last
//                                         .contains('mp4')) {
//                                       Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (context) => ViewVideo(
//                                                     videoUrl: imageUrl,
//                                                   )));
//                                     } else if (imageUrl
//                                             .split('.')
//                                             .last
//                                             .contains('png') ||
//                                         imageUrl
//                                             .split('.')
//                                             .last
//                                             .contains('jpg') ||
//                                         imageUrl
//                                             .split('.')
//                                             .last
//                                             .contains('jpeg')) {
//                                       showDialog(
//                                         context: context,
//                                         builder: (BuildContext context) {
//                                           return AlertDialog(
//                                             title: const Text("Image Details"),
//                                             content: Column(
//                                               mainAxisSize: MainAxisSize.min,
//                                               children: [
//                                                 Image.network(
//                                                   imageUrl,
//                                                   height: 300,
//                                                   width: 300,
//                                                   fit: BoxFit.cover,
//                                                   loadingBuilder:
//                                                       (BuildContext context,
//                                                           Widget child,
//                                                           ImageChunkEvent?
//                                                               loadingProgress) {
//                                                     if (loadingProgress ==
//                                                         null) {
//                                                       return child;
//                                                     } else {
//                                                       return Center(
//                                                         child:
//                                                             CircularProgressIndicator(
//                                                           value: loadingProgress
//                                                                       .expectedTotalBytes !=
//                                                                   null
//                                                               ? loadingProgress
//                                                                       .cumulativeBytesLoaded /
//                                                                   (loadingProgress
//                                                                           .expectedTotalBytes ??
//                                                                       1)
//                                                               : null,
//                                                         ),
//                                                       );
//                                                     }
//                                                   },
//                                                   errorBuilder: (context, error,
//                                                       stackTrace) {
//                                                     return const SizedBox
//                                                         .shrink();
//                                                   },
//                                                 ),
//                                               ],
//                                             ),
//                                             actions: <Widget>[
//                                               TextButton(
//                                                 onPressed: () {
//                                                   Navigator.of(context).pop();
//                                                 },
//                                                 child: Container(
//                                                   padding: const EdgeInsets
//                                                       .symmetric(
//                                                       vertical: 8,
//                                                       horizontal: 16),
//                                                   decoration: BoxDecoration(
//                                                     color: AppColor
//                                                         .navBarIconColor,
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             8),
//                                                   ),
//                                                   child: const Text(
//                                                     "Close",
//                                                     style: TextStyle(
//                                                       color: Colors.white,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       );
//                                     } else {
//                                       print("it is supposed to be here");
//                                       try {
//                                         final dir =
//                                             await getTemporaryDirectory();
//                                         String fileName =
//                                             imageUrl.split('/').last;
//                                         final filePath =
//                                             '${dir.path}/${fileName}';

//                                         final response =
//                                             await http.get(Uri.parse(imageUrl));

//                                         if (response.statusCode == 200) {
//                                           final file = File(filePath);
//                                           await file
//                                               .writeAsBytes(response.bodyBytes);

//                                           print(
//                                               "File downloaded to: $filePath");

//                                           OpenFile.open(filePath);
//                                         }
//                                       } catch (e) {
//                                         print("error in opening file:: ${e}");
//                                       }
//                                     }
//                                   },
//                                   child: Column(
//                                     children: [
//                                       imageUrl.split('.').last.contains('pdf')
//                                           ? IntrinsicWidth(
//                                               child: Container(
//                                                 decoration: BoxDecoration(
//                                                   color: allMessages[index]
//                                                               .status ==
//                                                           "Outgoing"
//                                                       ? const Color(0xff594EBA)
//                                                       : const Color(0xff221B41),
//                                                   borderRadius:
//                                                       BorderRadius.only(
//                                                     topLeft:
//                                                         const Radius.circular(
//                                                             12),
//                                                     topRight:
//                                                         const Radius.circular(
//                                                             12),
//                                                     bottomLeft: allMessages[
//                                                                     index]
//                                                                 .status ==
//                                                             "Outgoing"
//                                                         ? const Radius.circular(
//                                                             12)
//                                                         : const Radius.circular(
//                                                             0),
//                                                     bottomRight: allMessages[
//                                                                     index]
//                                                                 .status ==
//                                                             "Outgoing"
//                                                         ? const Radius.circular(
//                                                             0)
//                                                         : const Radius.circular(
//                                                             12),
//                                                   ),
//                                                   boxShadow: [
//                                                     BoxShadow(
//                                                       color: Colors.black
//                                                           .withOpacity(0.2),
//                                                       blurRadius: 4,
//                                                       offset:
//                                                           const Offset(2, 2),
//                                                     )
//                                                   ],
//                                                 ),
//                                                 child: Padding(
//                                                   padding: const EdgeInsets
//                                                       .symmetric(vertical: 8.0),
//                                                   child: Column(
//                                                     children: [
//                                                       Image.asset(
//                                                         "assets/images/pdf.png",
//                                                         height: 120,
//                                                         width: 120,
//                                                       ),
//                                                       if (allMessages[index]
//                                                                   .deliveryStatus ==
//                                                               "delivered" ||
//                                                           allMessages[index]
//                                                                   .deliveryStatus ==
//                                                               "sent")
//                                                         Row(
//                                                           mainAxisAlignment: allMessages[
//                                                                           index]
//                                                                       .status ==
//                                                                   "Outgoing"
//                                                               ? MainAxisAlignment
//                                                                   .end
//                                                               : MainAxisAlignment
//                                                                   .start,
//                                                           children: [
//                                                             IconButton(
//                                                               icon: const Icon(
//                                                                 Icons.done_all,
//                                                                 color: Color
//                                                                     .fromARGB(
//                                                                         255,
//                                                                         255,
//                                                                         255,
//                                                                         255),
//                                                               ),
//                                                               onPressed: () {},
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       if (allMessages[index]
//                                                               .deliveryStatus ==
//                                                           "read")
//                                                         Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .end,
//                                                           children: [
//                                                             IconButton(
//                                                               icon: const Icon(
//                                                                   Icons
//                                                                       .done_all,
//                                                                   color: Colors
//                                                                       .green),
//                                                               onPressed: () {},
//                                                             ),
//                                                           ],
//                                                         )
//                                                       else
//                                                         const SizedBox.shrink(),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             )
//                                           : imageUrl
//                                                   .split('.')
//                                                   .last
//                                                   .contains('mp4')
//                                               ? IntrinsicWidth(
//                                                   child: Container(
//                                                     decoration: BoxDecoration(
//                                                       color: allMessages[index]
//                                                                   .status ==
//                                                               "Outgoing"
//                                                           ? const Color(
//                                                               0xff594EBA)
//                                                           : const Color(
//                                                               0xff221B41),
//                                                       borderRadius:
//                                                           BorderRadius.only(
//                                                         topLeft: const Radius
//                                                             .circular(12),
//                                                         topRight: const Radius
//                                                             .circular(12),
//                                                         bottomLeft: allMessages[
//                                                                         index]
//                                                                     .status ==
//                                                                 "Outgoing"
//                                                             ? const Radius
//                                                                 .circular(12)
//                                                             : const Radius
//                                                                 .circular(0),
//                                                         bottomRight: allMessages[
//                                                                         index]
//                                                                     .status ==
//                                                                 "Outgoing"
//                                                             ? const Radius
//                                                                 .circular(0)
//                                                             : const Radius
//                                                                 .circular(12),
//                                                       ),
//                                                       boxShadow: [
//                                                         BoxShadow(
//                                                           color: Colors.black
//                                                               .withOpacity(0.2),
//                                                           blurRadius: 4,
//                                                           offset: const Offset(
//                                                               2, 2),
//                                                         )
//                                                       ],
//                                                     ),
//                                                     child: Padding(
//                                                       padding: const EdgeInsets
//                                                           .symmetric(
//                                                           vertical: 8.0),
//                                                       child: Column(
//                                                         children: [
//                                                           Image.asset(
//                                                             "assets/images/video.png",
//                                                             height: 120,
//                                                             width: 120,
//                                                           ),
//                                                           if (allMessages[index]
//                                                                   .status ==
//                                                               "Outgoing")
//                                                             if (allMessages[index]
//                                                                         .deliveryStatus ==
//                                                                     "delivered" ||
//                                                                 allMessages[index]
//                                                                         .deliveryStatus ==
//                                                                     "sent")
//                                                               IconButton(
//                                                                 icon:
//                                                                     const Icon(
//                                                                   Icons
//                                                                       .done_all,
//                                                                   color: Color
//                                                                       .fromARGB(
//                                                                           255,
//                                                                           255,
//                                                                           255,
//                                                                           255),
//                                                                 ),
//                                                                 onPressed:
//                                                                     () {},
//                                                               ),
//                                                           // if (allMessages[index]
//                                                           //         .deliveryStatus ==
//                                                           //     "sent")
//                                                           //   Row(
//                                                           //     mainAxisAlignment:
//                                                           //         MainAxisAlignment
//                                                           //             .end,
//                                                           //     children: [
//                                                           //       IconButton(
//                                                           //         icon: const Icon(
//                                                           //             Icons
//                                                           //                 .check,
//                                                           //             color: Colors
//                                                           //                 .white),
//                                                           //         onPressed:
//                                                           //             () {},
//                                                           //       ),
//                                                           //     ],
//                                                           //   ),
//                                                           if (allMessages[index]
//                                                                   .deliveryStatus ==
//                                                               "read")
//                                                             Row(
//                                                               mainAxisAlignment:
//                                                                   MainAxisAlignment
//                                                                       .end,
//                                                               children: [
//                                                                 IconButton(
//                                                                   icon: const Icon(
//                                                                       Icons
//                                                                           .done_all,
//                                                                       color: Colors
//                                                                           .green),
//                                                                   onPressed:
//                                                                       () {},
//                                                                 ),
//                                                               ],
//                                                             )
//                                                           else
//                                                             const SizedBox
//                                                                 .shrink(),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 )
//                                               : imageUrl
//                                                           .split('.')
//                                                           .last
//                                                           .contains('png') ||
//                                                       imageUrl
//                                                           .split('.')
//                                                           .last
//                                                           .contains('jpg') ||
//                                                       imageUrl
//                                                           .split('.')
//                                                           .last
//                                                           .contains('jpeg')
//                                                   ? IntrinsicWidth(
//                                                       child: Container(
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           color: allMessages[
//                                                                           index]
//                                                                       .status ==
//                                                                   "Outgoing"
//                                                               ? const Color(
//                                                                   0xff594EBA)
//                                                               : const Color(
//                                                                   0xff221B41),
//                                                           borderRadius:
//                                                               BorderRadius.only(
//                                                             topLeft:
//                                                                 const Radius
//                                                                     .circular(
//                                                                     12),
//                                                             topRight:
//                                                                 const Radius
//                                                                     .circular(
//                                                                     12),
//                                                             bottomLeft: allMessages[
//                                                                             index]
//                                                                         .status ==
//                                                                     "Outgoing"
//                                                                 ? const Radius
//                                                                     .circular(
//                                                                     12)
//                                                                 : const Radius
//                                                                     .circular(
//                                                                     0),
//                                                             bottomRight: allMessages[
//                                                                             index]
//                                                                         .status ==
//                                                                     "Outgoing"
//                                                                 ? const Radius
//                                                                     .circular(0)
//                                                                 : const Radius
//                                                                     .circular(
//                                                                     12),
//                                                           ),
//                                                           boxShadow: [
//                                                             BoxShadow(
//                                                               color: Colors
//                                                                   .black
//                                                                   .withOpacity(
//                                                                       0.2),
//                                                               blurRadius: 4,
//                                                               offset:
//                                                                   const Offset(
//                                                                       2, 2),
//                                                             )
//                                                           ],
//                                                         ),
//                                                         child: Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .symmetric(
//                                                                   vertical: 8.0,
//                                                                   horizontal:
//                                                                       4),
//                                                           child: Column(
//                                                             children: [
//                                                               Image.network(
//                                                                 imageUrl,
//                                                                 height: 120,
//                                                                 width: 120,
//                                                                 fit: BoxFit
//                                                                     .cover,
//                                                                 loadingBuilder: (BuildContext
//                                                                         context,
//                                                                     Widget
//                                                                         child,
//                                                                     ImageChunkEvent?
//                                                                         loadingProgress) {
//                                                                   if (loadingProgress ==
//                                                                       null) {
//                                                                     return child;
//                                                                   } else {
//                                                                     return Center(
//                                                                       child:
//                                                                           CircularProgressIndicator(
//                                                                         color: Colors
//                                                                             .black,
//                                                                         value: loadingProgress.expectedTotalBytes !=
//                                                                                 null
//                                                                             ? loadingProgress.cumulativeBytesLoaded /
//                                                                                 (loadingProgress.expectedTotalBytes ?? 1)
//                                                                             : null,
//                                                                       ),
//                                                                     );
//                                                                   }
//                                                                 },
//                                                                 errorBuilder:
//                                                                     (context,
//                                                                         error,
//                                                                         stackTrace) {
//                                                                   return const SizedBox
//                                                                       .shrink();
//                                                                 },
//                                                               ),
//                                                               if (allMessages[
//                                                                           index]
//                                                                       .status ==
//                                                                   "Outgoing")
//                                                                 if (allMessages[index]
//                                                                             .deliveryStatus ==
//                                                                         "delivered" ||
//                                                                     allMessages[index]
//                                                                             .deliveryStatus ==
//                                                                         "sent")
//                                                                   Row(
//                                                                     mainAxisAlignment: allMessages[index].status ==
//                                                                             "Outgoing"
//                                                                         ? MainAxisAlignment
//                                                                             .end
//                                                                         : MainAxisAlignment
//                                                                             .start,
//                                                                     children: [
//                                                                       IconButton(
//                                                                         icon:
//                                                                             const Icon(
//                                                                           Icons
//                                                                               .done_all,
//                                                                           color: Color.fromARGB(
//                                                                               255,
//                                                                               255,
//                                                                               255,
//                                                                               255),
//                                                                         ),
//                                                                         onPressed:
//                                                                             () {},
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                               if (allMessages[
//                                                                           index]
//                                                                       .deliveryStatus ==
//                                                                   "read")
//                                                                 IconButton(
//                                                                   icon: const Icon(
//                                                                       Icons
//                                                                           .done_all,
//                                                                       color: Colors
//                                                                           .green),
//                                                                   onPressed:
//                                                                       () {},
//                                                                 )
//                                                               else
//                                                                 const SizedBox
//                                                                     .shrink(),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     )
//                                                   : IntrinsicWidth(
//                                                       child: Container(
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           color: allMessages[
//                                                                           index]
//                                                                       .status ==
//                                                                   "Outgoing"
//                                                               ? const Color(
//                                                                   0xff594EBA)
//                                                               : const Color(
//                                                                   0xff221B41),
//                                                           borderRadius:
//                                                               BorderRadius.only(
//                                                             topLeft:
//                                                                 const Radius
//                                                                     .circular(
//                                                                     12),
//                                                             topRight:
//                                                                 const Radius
//                                                                     .circular(
//                                                                     12),
//                                                             bottomLeft: allMessages[
//                                                                             index]
//                                                                         .status ==
//                                                                     "Outgoing"
//                                                                 ? const Radius
//                                                                     .circular(
//                                                                     12)
//                                                                 : const Radius
//                                                                     .circular(
//                                                                     0),
//                                                             bottomRight: allMessages[
//                                                                             index]
//                                                                         .status ==
//                                                                     "Outgoing"
//                                                                 ? const Radius
//                                                                     .circular(0)
//                                                                 : const Radius
//                                                                     .circular(
//                                                                     12),
//                                                           ),
//                                                           boxShadow: [
//                                                             BoxShadow(
//                                                               color: Colors
//                                                                   .black
//                                                                   .withOpacity(
//                                                                       0.2),
//                                                               blurRadius: 4,
//                                                               offset:
//                                                                   const Offset(
//                                                                       2, 2),
//                                                             )
//                                                           ],
//                                                         ),
//                                                         child: Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .symmetric(
//                                                                   vertical:
//                                                                       8.0),
//                                                           child: Column(
//                                                             children: [
//                                                               Image.asset(
//                                                                 "assets/images/doc.png",
//                                                                 height: 120,
//                                                                 width: 120,
//                                                               ),
//                                                               if (allMessages[
//                                                                           index]
//                                                                       .status ==
//                                                                   "Outgoing")
//                                                                 if (allMessages[index]
//                                                                             .deliveryStatus ==
//                                                                         "delivered" ||
//                                                                     allMessages[index]
//                                                                             .deliveryStatus ==
//                                                                         "sent")
//                                                                   IconButton(
//                                                                     icon:
//                                                                         const Icon(
//                                                                       Icons
//                                                                           .done_all,
//                                                                       color: Color.fromARGB(
//                                                                           255,
//                                                                           255,
//                                                                           255,
//                                                                           255),
//                                                                     ),
//                                                                     onPressed:
//                                                                         () {},
//                                                                   ),
//                                                               if (allMessages[
//                                                                           index]
//                                                                       .deliveryStatus ==
//                                                                   "read")
//                                                                 Row(
//                                                                   mainAxisAlignment:
//                                                                       MainAxisAlignment
//                                                                           .end,
//                                                                   children: [
//                                                                     IconButton(
//                                                                       icon: const Icon(
//                                                                           Icons
//                                                                               .done_all,
//                                                                           color:
//                                                                               Colors.green),
//                                                                       onPressed:
//                                                                           () {},
//                                                                     ),
//                                                                   ],
//                                                                 )
//                                                               else
//                                                                 const SizedBox
//                                                                     .shrink(),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                     ],
//                                   ),
//                                 ),
//                               )
//                             else
//                               const SizedBox.shrink(),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//         ),
//         _buildMessageInputArea(),
//       ],
//     );
//   }

//   void singlemsgdelete(msghistoryid) async {
//     print("Single delete attempt for message with ID: $msghistoryid");

//     if (msghistoryid.isEmpty) {
//       print("Invalid message ID. Cannot delete.");
//       return;
//     }
//     var msghistoryidd = msghistoryid;
//     print("sdhsdhjdhjsdhfdks=>$msghistoryidd");

//     var bodyy = jsonEncode({
//       "ids": [msghistoryidd]
//     });

//     print("Request hdshsd jhds body: $bodyy");
//     MessageViewModel msgdelete = MessageViewModel(context);
//     msgdelete.singlemsgdelete(bodyy).then((value) {
//       // isdelete = true;
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("deleted sucefully")));
//       print("Delete single message successfully");
//     }).catchError((error) {
//       print("Error deleting message: $error");
//     });
//   }

//   Alignment _getAlignment(String? status) {
//     if (status == "Outgoing") {
//       return Alignment.centerRight;
//     } else if (status == "Incoming") {
//       return Alignment.centerLeft;
//     } else {
//       return Alignment.center;
//     }
//   }

//   Widget _buildMessageInputArea() {
//     messageViewModel = Provider.of<MessageViewModel>(context);

//     print(
//         " messageViewModel.viewModels.length:::::: ${messageViewModel.viewModels}   ${showLoader} ");

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           IconButton(
//             icon: const Icon(Icons.attach_file),
//             onPressed: _showPicker,
//           ),
//           Expanded(
//             child: Row(
//               children: [
//                 image != null && isImageSent == false
//                     ? image.toString().split('.').last.contains('pdf')
//                         ? Container(
//                             width: 50,
//                             height: 50,
//                             margin: const EdgeInsets.only(right: 8.0),
//                             decoration: BoxDecoration(
//                               // color: Colors.blue,
//                               borderRadius: BorderRadius.circular(8.0),
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(8.0),
//                               child: Image.asset(
//                                 "assets/images/pdf.png",
//                                 width: 50,
//                                 height: 50,
//                                 fit: BoxFit.cover, // Ensures full coverage
//                               ),
//                             ),
//                           )
//                         : Container(
//                             width: 50,
//                             height: 50,
//                             margin: const EdgeInsets.only(right: 8.0),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8.0),
//                               image: DecorationImage(
//                                 image: FileImage(image!),
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           )
//                     : const SizedBox.shrink(),
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: const Color(0xFFF1F1F1),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             decoration: BoxDecoration(
//               color: const Color.fromARGB(255, 148, 188, 206),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: IconButton(
//               icon: const Icon(Icons.code, color: Colors.white),
//               onPressed: () {
//                 _getBootmSheet();
//               },
//             ),
//           ),
//           allMessages.length == 0
//               ? SizedBox()
//               : Container(
//                   decoration: BoxDecoration(
//                     color: AppColor.cardsColor,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: showLoader
//                       ? Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Container(
//                             height: 30,
//                             width: 30,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                             ),
//                           ),
//                         )
//                       : IconButton(
//                           icon: const Icon(Icons.send, color: Colors.white),
//                           onPressed: () async {
//                             print("image$image");
//                             setState(() {
//                               showLoader = true;
//                             });

//                             if (image != null) {
//                               String fileExtension =
//                                   path.extension(image!.path).toLowerCase();
//                               print("File Extension: $fileExtension");

//                               if (fileExtension == '.jpg' ||
//                                   fileExtension == '.jpeg') {
//                                 print("🖼 Sending Image...");
//                                 filesend("image");
//                               } else if (fileExtension == '.mp4' ||
//                                   fileExtension == '.avi' ||
//                                   fileExtension == '.mov') {
//                                 print("🎥 Sending Video...");
//                                 filesend("video");
//                               } else if (fileExtension == '.html' ||
//                                   fileExtension == '.txt') {
//                                 print("🎥 Sending text document...");
//                                 filesend("document");
//                               } else {
//                                 print("📄 Sending Document...");
//                                 filesend("document");
//                               }
//                             } else if (_controller.text.trim().isNotEmpty) {
//                               showLoader = false;
//                               messagesendd(_controller.text);
//                             } else {
//                               ScaffoldMessenger.of(context)
//                                   .showSnackBar(SnackBar(
//                                       content: Text(
//                                 "please Type Message",
//                                 selectionColor: Colors.amber,
//                               )));
//                               print(
//                                   "⚠ No file or text entered. Doing nothing.");
//                             }
//                             _controller.clear();
//                             setState(() {});
//                           },
//                         )),
//         ],
//       ),
//     );
//   }

//   Future<void> _showSimpleDialog(id) async {
//     await showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return SimpleDialog(
//           backgroundColor: AppColor.cardsColor,
//           title: const Text(
//             'Are you sure want to Delete Message',
//             style: TextStyle(fontSize: 14, color: Colors.white),
//           ),
//           children: <Widget>[
//             Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {
//                         print("mmms=>${id}");
//                         singlemsgdelete(id);
//                         Navigator.of(context).pop();
//                       },
//                       child: const Text(
//                         "ok",
//                         style: TextStyle(fontSize: 13),
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 6,
//                     ),
//                     ElevatedButton(
//                       style: ButtonStyle(
//                         minimumSize:
//                             WidgetStateProperty.all(const Size(10, 20)),
//                         padding: WidgetStateProperty.all(
//                             const EdgeInsets.symmetric(
//                                 horizontal: 20, vertical: 10)),
//                       ),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: const Text(
//                         "Cancel",
//                         style: TextStyle(
//                           fontSize: 13,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _fetchTemplates() async {
//     TempleteListViewModel templeteViewModel =
//         Provider.of<TempleteListViewModel>(context, listen: false);

//     // Check if templeteViewModel is not null and contains viewModels
//     if (templeteViewModel.viewModels.isNotEmpty) {
//       for (var viewModel in templeteViewModel.viewModels) {
//         var campaignModel = viewModel.model;
//         if (campaignModel?.data != null) {
//           for (var record in campaignModel!.data!) {
//             if (record.status != null) {
//               print("Record template Status: ${record.name}");
//               setState(() {
//                 templateNames.add(record.name);
//                 print("Templates => $templateNames");
//               });
//             }
//           }
//         }
//       }
//     }
//   }

//   var currentTemplate;
//   List<Component> components = [];

//   Future<void> _setSelectedTemplates() async {
//     TempleteListViewModel templeteViewModel =
//         Provider.of<TempleteListViewModel>(context, listen: false);

//     if (templeteViewModel != null && templeteViewModel.viewModels.isNotEmpty) {
//       for (var viewModel in templeteViewModel.viewModels) {
//         var campaignModel = viewModel.model;
//         if (campaignModel?.data != null) {
//           for (var record in campaignModel!.data!) {
//             if (record.status != null) {
//               print("rec name ::${record.name}  ${selectedTemplateName}");
//               if (selectedTemplateName == record.name) {
//                 currentTemplate = record;

//                 log("current template::::: ${currentTemplate}  ${currentTemplate.name}");
//                 print(
//                     "other info:: ${currentTemplate.components}   ${currentTemplate.components.runtimeType}");
//                 components = currentTemplate.components;
//                 print("Component info:: ${components.length} ${components}");

//                 for (var e in components) {
//                   print("checking the type:: ${e.type}");
//                   if (e.type == "HEADER") {
//                     selectedHeader = e;
//                   } else if (e.type == "BODY") {
//                     selectedBody = e;
//                   } else if (e.type == "FOOTER") {
//                     selectedFooter = e;
//                   } else if (e.type == "BUTTONS") {
//                     selectedButtons = e;
//                   }
//                 }

// // Call setState once after processing all components
//                 setState(() {});

//                 log("components ::: ${selectedHeader}   ${selectedBody}  ${selectedButtons}");

//                 return;
//               }
//             }
//           }
//         }
//       }
//     }
//   }

//   void gtcategorybytemplate() {
//     print(templateNames);
//   }

//   Future<void> _sendTemplateSheet() {
//     bool isChecked = false;
//     String text = selectedBody.text;
//     String imgToShow = "";
//     if (selectedHeader != null &&
//         selectedHeader.example.headerHandle != null &&
//         selectedHeader.example.headerHandle.isNotEmpty) {
//       print("selectedHeader>>> ${selectedHeader.example.headerHandle}");
//       imgToShow = selectedHeader.example.headerHandle[0];
//     } else {
//       imgToShow = "";
//     }

//     print("selectedHeader.format>>>> ${selectedHeader.format}");

//     final regex = RegExp(r'\{\{\d+\}\}');

//     int count = regex.allMatches(text).length;

//     controllers = List.generate(count, (index) => TextEditingController());

//     return showModalBottomSheet<void>(
//       context: context,
//       useSafeArea: true,
//       isScrollControlled: true,
//       enableDrag: false,
//       elevation: 1,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Container(
//               height: MediaQuery.of(context).size.height * .80,
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: MediaQuery.of(context).viewInsets,
//                   child: Container(
//                     width: MediaQuery.of(context).size.width,
//                     padding: const EdgeInsets.all(15),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               "Review Template",
//                               style: TextStyle(
//                                 fontSize: 17,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             InkWell(
//                               onTap: () => Navigator.pop(context),
//                               child: const Icon(
//                                 Icons.highlight_remove_outlined,
//                                 color: AppColor.navBarIconColor,
//                                 size: 25,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const Divider(thickness: 1),
//                         const SizedBox(height: 5),
//                         Column(
//                           children: List.generate(count, (index) {
//                             return Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 8.0),
//                               child: TextField(
//                                 controller: controllers[index],
//                                 decoration: InputDecoration(
//                                   labelText:
//                                       "Enter value for placeholder ${index + 1}",
//                                   border: OutlineInputBorder(),
//                                 ),
//                               ),
//                             );
//                           }),
//                         ),
//                         Card(
//                           elevation: 5,
//                           color: Color(0xffE3FFC9).withOpacity(0.5),
//                           shadowColor: Colors.black38,
//                           child: Padding(
//                             padding: const EdgeInsets.all(10.0),
//                             child: Column(
//                               children: [
//                                 if (selectedHeader != null &&
//                                     selectedHeader.format == "IMAGE")
//                                   imgToShow.isEmpty
//                                       ? Container(
//                                           height: 80,
//                                           width: 80,
//                                           child: Image.asset(
//                                               "assets/images/img_placeholder.png"))
//                                       : Image.network(imgToShow),
//                                 if (selectedHeader == null ||
//                                     selectedHeader.format != "IMAGE")
//                                   SizedBox(),
//                                 selectedBody != null
//                                     ? Text("${selectedBody.text}")
//                                     : SizedBox(),
//                                 SizedBox(
//                                   height: 10,
//                                 ),
//                                 selectedButtons != null
//                                     ? Wrap(
//                                         spacing: 10,
//                                         children: List.generate(
//                                             selectedButtons.buttons.length,
//                                             (index) {
//                                           return ElevatedButton(
//                                             onPressed: () {
//                                               print(
//                                                   "Button ${index + 1} clicked");
//                                             },
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor: Colors.grey[400],
//                                               shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(4),
//                                                   side: BorderSide(
//                                                       color: AppColor
//                                                           .navBarIconColor)),
//                                             ),
//                                             child: Text(
//                                               selectedButtons
//                                                   .buttons[index].text,
//                                               style: TextStyle(
//                                                   color:
//                                                       AppColor.navBarIconColor),
//                                             ),
//                                           );
//                                         }),
//                                       )
//                                     : SizedBox(),
//                                 SizedBox(height: 15),
//                                 selectedFooter != null
//                                     ? Text(
//                                         selectedFooter.text,
//                                         style: TextStyle(color: Colors.grey),
//                                         textAlign: TextAlign.left,
//                                       )
//                                     : SizedBox(),
//                                 SizedBox(height: 15),
//                                 Row(
//                                   children: [
//                                     Checkbox(
//                                       value: isChecked,
//                                       onChanged: (bool? value) {
//                                         setState(() {
//                                           isChecked = value!;
//                                         });
//                                       },
//                                     ),
//                                     Expanded(
//                                       child: Text(
//                                         "Send on login user WhatsApp number also",
//                                         maxLines: 2,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     )
//                                   ],
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Center(
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 10),
//                               backgroundColor: AppColor.navBarIconColor,
//                             ),
//                             onPressed: () async {
//                               Map<String, String> bodyTextParams = {};
//                               List compoTextParams = [];
//                               List numberedCampParam = [];

//                               bool anyEmpty = controllers
//                                   .any((controller) => controller.text.isEmpty);

//                               if (anyEmpty) {
//                                 return;
//                               } else {
//                                 print("All fields are filled");
//                               }
//                               File? imageFile;
//                               if (imgToShow.isNotEmpty) {}
//                               image = await urlToFile(imgToShow);

//                               String docId = await getDocId();

//                               for (int i = 0; i < controllers.length; i++) {
//                                 bodyTextParams[(i + 1).toString()] =
//                                     controllers[i].text;
//                                 Map body = {
//                                   "type": "text",
//                                   "text": controllers[i].text
//                                 };
//                                 compoTextParams.add(body);
//                                 numberedCampParam.add(bodyTextParams);
//                               }

//                               String templateToSend = selectedTemplateName ??
//                                   _templateController.text;
//                               print(
//                                   "Template to send: $templateToSend           ${selectedFooter.text}");

//                               if (docId.isNotEmpty) {
//                                 List parameter = [
//                                   {
//                                     "type": "image",
//                                     "image": {"id": docId}
//                                   }
//                                 ];

//                                 sendParamsApiCall(
//                                     templateToSend,
//                                     compoTextParams,
//                                     isChecked,
//                                     parameter,
//                                     bodyTextParams);
//                               }
//                             },
//                             child: const Text(
//                               "Send Template",
//                               style:
//                                   TextStyle(fontSize: 13, color: Colors.white),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//     ;
//   }

//   Future<void> _getBootmSheet() {
//     TextEditingController _templateController = TextEditingController();
//     int selectedBtnIdx = 0;
//     return showModalBottomSheet<void>(
//       context: context,
//       useSafeArea: true,
//       isScrollControlled: true,
//       enableDrag: false,
//       elevation: 1,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return SingleChildScrollView(
//               child: Container(
//                 width: MediaQuery.of(context).size.width,
//                 padding: const EdgeInsets.all(15),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           "Category And Templete",
//                           style: TextStyle(
//                             fontSize: 17,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         InkWell(
//                           onTap: () => Navigator.pop(context),
//                           child: const Icon(
//                             Icons.highlight_remove_outlined,
//                             color: AppColor.navBarIconColor,
//                             size: 25,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Divider(thickness: 1),
//                     const SizedBox(height: 5),
//                     AppUtils.getDropdown(
//                       'Select Category',
//                       data: tempateCategory,
//                       onChanged: (String? selectedCategory) {
//                         setState(() {
//                           SelectedTemplateCategory = selectedCategory;
//                           selectedTemplateName = null;
//                           templateNames = [];

//                           if (selectedCategory != null) {
//                             String categoryKey = selectedCategory.toLowerCase();

//                             templateNames = (allTemplatesMap[categoryKey]
//                                         ?.values
//                                         .toList() ??
//                                     [])
//                                 .cast<String>();

//                             debug("Selected Category: $categoryKey");
//                             debug("Filtered Templates: $templateNames");
//                           }
//                         });
//                       },
//                       value: SelectedTemplateCategory,
//                     ),
//                     const SizedBox(height: 12),
//                     AppUtils.getDropdown(
//                       'Select Template Name',
//                       data: templateNames,
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           selectedTemplateName = newValue;
//                           _templateController.text = newValue ?? '';
//                           if (newValue != null) {
//                             int selectedIndex = templateNames.indexOf(newValue);

//                             if (selectedIndex >= 0 &&
//                                 selectedIndex < templateIds.length) {
//                               String selectedTemplateId =
//                                   templateIds[selectedIndex];

//                               print(
//                                   "Selected Template ID: $selectedTemplateId");
//                             } else {
//                               print("Invalid index for the selected template.");
//                             }
//                           }
//                         });

//                         _setSelectedTemplates();
//                       },
//                       value: selectedTemplateName,
//                     ),
//                     Center(
//                       child: ElevatedButton(
//                         style: ButtonStyle(
//                           minimumSize:
//                               WidgetStateProperty.all(const Size(10, 20)),
//                           padding: WidgetStateProperty.all(
//                               const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 10)),
//                           backgroundColor:
//                               WidgetStateProperty.all(AppColor.navBarIconColor),
//                         ),
//                         onPressed: () {
//                           log("all comp info >> >>  ${selectedHeader}  ${selectedBody} ${selectedFooter} ${selectedButtons}}");
//                           log("selectedBody['text']>>> ${selectedBody.text}  ");
//                           final regex = RegExp(r'\{\{\d+\}\}');

//                           if (regex.hasMatch(selectedBody.text)) {
//                             Navigator.of(context).pop();
//                             _sendTemplateSheet();
//                           } else {
//                             String templateToSend = selectedTemplateName ??
//                                 _templateController.text;
//                             print("Template to send: $templateToSend");
//                             templetesendd(templateToSend, []);

//                             Navigator.of(context).pop();
//                           }
//                         },
//                         child: const Text(
//                           "Send",
//                           style: TextStyle(fontSize: 13, color: Colors.white),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   String capitalize(String text) {
//     if (text.isEmpty) return text;
//     return text[0].toUpperCase() + text.substring(1).toLowerCase();
//   }

//   Future<void> sendParamsApiCall(String templateToSend, List compoTextParams,
//       bool sendOnLoginNum, List params, Map campaignParam) async {
//     final prefs = await SharedPreferences.getInstance();
//     String? number = prefs.getString('phoneNumber');

//     late MessageViewModel mstemp = MessageViewModel(context);
//     TempleteListViewModel templeteViewModel =
//         Provider.of<TempleteListViewModel>(context, listen: false);

//     Map<String, dynamic> createtemp = {
//       "id": null,
//       "name": templateToSend,
//       "language": "en",
//       "category": "MARKETING",
//       "header": "TEXT",
//       "header_body": "template header",
//       "message_body": templateToSend,
//       "example_body_text": {"sendToAdmin": sendOnLoginNum},
//       "footer": selectedFooter.text,
//       "buttons": [],
//       "business_number": number
//     };

//     mstemp.createmsgtemplete(msgmobilbody: createtemp).then((value) => {
//           templeteidmessage = value['id'],
//           print("temmplet msg id==========>$templeteidmessage"),
//           print("ccretae objetctt resposne= > $value")
//         });

//     var leadnumber = widget.wpnumber;
//     Map<String, dynamic> templateBody = {
//       "messaging_product": "whatsapp",
//       "to": leadnumber,
//       "type": "template",
//       "template": {
//         "name": templateToSend,
//         "language": {"code": "en_US"},
//         "components": [
//           {
//             "type": "header",
//             "parameters": [
//               {
//                 "type": "image",
//                 "image": {"id": "1516705009247219"}
//               }
//             ]
//           },
//           {"type": "body", "parameters": compoTextParams}
//         ]
//       }
//     };
//     print("templetete body=>$templateBody");
//     mstemp
//         .sendtemplete(number: number, msgmobilbody: templateBody)
//         .then((value) {
//       print("value=== templete>$value");
//       print("value=== template>${value['messages'][0]['id']}");
//       messageid = value['messages'][0]['id'];

//       Map<String, dynamic> msgmobilebody = {
//         "parent_id": widget.model.id,
//         "name": widget.leadName,
//         "message_template_id": templeteidmessage,
//         "whatsapp_number": leadnumber,
//         "message": "",
//         "status": "Outgoing",
//         "recordtypename": "recentlyMessage",
//         "file_id": null,
//         "is_read": true,
//         "business_number": number,
//         "message_id": messageid,
//         "interactive_id": null
//       };

//       mstemp.sendmsgmobile(msgmobilbody: msgmobilebody).then((value) {
//         print("valueee1=>$value");

//         String msgResId = value['id'];

//         Map<String, dynamic> paramBody = {
//           "campaign_id": null,
//           "body_text_params": campaignParam,
//           "msg_history_id": msgResId,
//           "file_id": null,
//           "whatsapp_number_admin": "7590889022"
//         };

//         mstemp.sendCampParam(campParambody: paramBody).then((value) {
//           print("sendCampParam>>> ${value}");
//         });
//       });
//     });
//   }

//   Future<File?> urlToFile(String imageUrl) async {
//     try {
//       final response = await http.get(Uri.parse(imageUrl));

//       if (response.statusCode == 200) {
//         final directory = await getTemporaryDirectory();

//         final filePath = '${directory.path}/downloaded_image.png';

//         File file = File(filePath);
//         await file.writeAsBytes(response.bodyBytes);

//         return file;
//       }
//     } catch (e) {
//       print("Error downloading image: $e");
//     }
//     return null;
//   }
// }
import 'dart:developer';

import 'package:flutter_html/flutter_html.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/models/approved_template_model/aprovedtempltemodel/component.dart';
import 'package:whatsapp/models/approved_template_model/aprovedtempltemodel/datum.dart';
import 'package:whatsapp/models/lead_model.dart';
import 'package:whatsapp/models/ms_model/message_model.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/function_lib.dart';
import 'package:whatsapp/view_models/templete_list_vm.dart';
import 'package:whatsapp/views/view/show_pdf.dart';
import 'package:whatsapp/views/view/show_video.dart';

import '../../models/template_model/template_model.dart';
import '../../models/user_model/user_model.dart';
import '../../utils/app_utils.dart';
import '../../view_models/message_list_vm.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChatScreen extends StatefulWidget {
  final String? leadName;
  final String? wpnumber;
  final LeadModel model;
  const ChatScreen({
    Key? key,
    this.leadName,
    this.wpnumber,
    required this.model,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<TextEditingController> controllers = [];

  List<String> templateNamesss = []; // Global list to store template names
  List<String> templateIds = []; // Global list to store template ids
  String msghistoryid = "";
  final ScrollController _scrollController = ScrollController();
  bool isImageSent = false;
  bool _isLoading = true;
  int lenOfRec = 0;
  String? globalParentId;
  XFile? selectedImage;
  String base64Image = '';
  String? SelectedTemplateCategory;
  Map<String, Map<String, dynamic>> allTemplatesMap = {};
  List<dynamic> templateName1 = [];
  String? templeteidmessage;
  List<String> templateNames = [];
  String? selectedTemplate;
  String templetmsgid = "";
  var templeteViewModel;
  String messageid = "";
  late MessageViewModel messageViewModel;
  final TextEditingController _controller = TextEditingController();
  TextEditingController fileNameController = TextEditingController();
  ImagePicker picker = ImagePicker();
  File? image;
  PlatformFile? file;
  bool isRefresh = false;
  UserModel? userModel;
  bool historyExists = false;
  List allMessages = [];
  String? fileid;
  List<dynamic> tempateCategory = ['UTILITY', 'MARKETING', 'AUTHENTICATION'];
  String? selectedTemplateName;

  var selectedHeader;
  var selectedBody;
  var selectedFooter;
  dynamic? selectedButtons;

  TempleteListViewModel? templateVM;
  final List<String> imageUrls = [
    'https://i.pinimg.com/564x/51/7b/07/517b07bfac2232980597368f36fc06c5.jpg',
    'https://www.w3schools.com/w3images/rocks.jpg',
    'https://www.w3schools.com/w3images/fjords.jpg',
    'https://www.w3schools.com/w3images/mountains.jpg',
    'https://www.w3schools.com/w3images/lights.jpg',
  ];
  bool showLoader = false;
  String userName = "";
  TextEditingController _templateController = TextEditingController();
  @override
  void initState() {
    _fetchTemplates();
    super.initState();
    _pullRefresh();
    showLoader = false;
    _getPhoneNumber();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    print("Lead Number =>${widget.wpnumber}    ");
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    log("is build method calling alwayss");
    messageViewModel = Provider.of<MessageViewModel>(context);

    allMessages = [];
    for (var viewModel in messageViewModel.viewModels) {
      final model = viewModel.model;
      if (model.records?.isNotEmpty ?? false) {
        allMessages.addAll(messageViewModel.viewModels[0].model.records);
      }
    }
    _scrollToBottom();
    setState(() {});
    print("all messages:: ${allMessages.length}  ${allMessages}");

    templateVM = Provider.of<TempleteListViewModel>(context);
    messageViewModel = Provider.of<MessageViewModel>(context);
    if (templateVM != null && templateVM?.viewModels != null)
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () {
            _showProfileDialog(context);
          },
          child: Row(
            children: [
              const CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://www.w3schools.com/w3images/avatar2.png',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.leadName ?? "",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onPressed: () {
              _showDeleteDialog();
            },
          ),
        ],
      ),
      body: Container(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _pullRefresh,
              child: _isLoading ? Container() : _pageBody(),
            ),
            if (_isLoading)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.white.withOpacity(0.2),
                    child: Center(
                      child: LoadingAnimationWidget.flickr(
                        leftDotColor: AppColor.cardsColor,
                        rightDotColor: AppColor.navBarIconColor,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://www.w3schools.com/w3images/avatar2.png',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    widget.leadName ?? "No Name Provided",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    widget.wpnumber ?? "No Name Provided",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColor.navBarIconColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void deletechat() async {
    print("delete function callin g working");
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');
    late MessageViewModel msgdelete = MessageViewModel(context);
    msgdelete
        .msghistorydelete(leadnumber: widget.wpnumber, number: number)
        .then((value) => {
              print("deeeelete sucefulyyy"),
            });
  }

  Future<void> _showDeleteDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to delete this Chat histoy?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),
              const Divider(),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'No',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColor.navBarIconColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Yes',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {
                      deletechat();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void messagesendd(String text) async {
    print("messagesendd called");

    late TempleteListViewModel tm = TempleteListViewModel(context);
    late MessageViewModel ms = MessageViewModel(context);
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    if (number == null || number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number not found'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    print("wpppp=>${widget.wpnumber}");
    var leadnumber = widget.wpnumber;
    Map<String, dynamic> addmsModel = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": leadnumber,
      "type": "text",
      "text": {"preview_url": false, "body": text}
    };

    Map<String, dynamic> msgmobilebody = {
      "parent_id": widget.model.id,
      "name": widget.leadName,
      "message_template_id": null,
      "whatsapp_number": leadnumber,
      "message": text,
      "status": "Outgoing",
      "recordtypename": "lead",
      "file_id": null,
      "is_read": true,
      "business_number": number,
      "message_id": messageid
    };

    ms.sendMessage(number: number, addmsModel: addmsModel).then((value) {
      print("valueee=>$value");
      if (value.isNotEmpty) {
        var messageId = value['messages'];
        print('Message ID: ${messageId[0]['id']}');
        messageid = messageId[0]['id'];
        msgmobilebody['message_id'] = messageid;

        ms.sendmsgmobile(msgmobilbody: msgmobilebody).then((value) {
          print("valueee1=>$value");
          if (value['delivery_status'] == "sent") {
            _controller.clear();

            setState(() {
              showLoader = false;
            });
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent successfully'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }).catchError((error) {
      Navigator.pop(context);
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void templetesendd(String templateToSend, List? compo) async {
    print("tempeeppeppepepeppep=>$templateToSend");
    late MessageViewModel mstemp = MessageViewModel(context);
    print("agyaaaaaaaaaa");
    TempleteListViewModel templeteViewModel =
        Provider.of<TempleteListViewModel>(context, listen: false);
    print("wpppp=>${widget.wpnumber}");
    var leadnumber = widget.wpnumber;
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    Map<String, dynamic> templateBody = {
      "messaging_product": "whatsapp",
      "to": leadnumber,
      "type": "template",
      "template": {
        "name": templateToSend,
        "language": {"code": "en_US"},
        "components": [
          {"type": "header", "parameters": []},
          {"type": "body", "parameters": []}
        ]
      }
    };
    print("templetete body=>$templateBody");

    Map<String, dynamic> createtemp = {
      "id": null,
      "name": templateToSend,
      "language": "en",
      "category": "MARKETING",
      "header": "TEXT",
      "header_body": "template header",
      "message_body": templateToSend,
      "example_body_text": {"sendToAdmin": false},
      "footer": selectedFooter.text,
      "buttons": [],
      "business_number": number
    };

    mstemp.createmsgtemplete(msgmobilbody: createtemp).then((value) => {
          templeteidmessage = value['id'],
          print("temmplet msg id==========>$templeteidmessage"),
          print("ccretae objetctt resposne= > $value")
        });

    mstemp
        .sendtemplete(number: number, msgmobilbody: templateBody)
        .then((value) {
      print("value=== templete>$value");
      print("value=== template>${value['messages'][0]['id']}");

      Map<String, dynamic> msghistorydata = {
        "parent_id": widget.model.id,
        "name": widget.leadName,
        "message_template_id": templeteidmessage,
        "whatsapp_number": leadnumber,
        "message": "",
        "status": "Outgoing",
        "recordtypename": "recentlyMessage",
        "file_id": null,
        "is_read": true,
        "business_number": number,
        "message_id": templetmsgid,
        "id": currentTemplate.id
      };

      print("body before sending::: ${msghistorydata}");
      mstemp.semdtempmsghistory(msghistorydata: msghistorydata).then(
          (value) => {print("semdtempmsghistorysemdtempmsghistory=>$value")});
    });

    print("temmplet msg::::: id==========>$templeteidmessage");
  }

  Future<void> _pullRefresh() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
    var leadnumber = widget.wpnumber;
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');
    print("number=>$number");
    await Provider.of<MessageViewModel>(context, listen: false)
        .Fetchmsghistorydata(leadnumber: leadnumber, number: number);
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName') ?? "Me";
    setState(() {});
    String? number = prefs.getString('phoneNumber');
    if (number != null) {
      messageViewModel.Fetchmsghistorydata(
        leadnumber: widget.wpnumber ?? "",
        number: number,
      );
    } else {
      print('Number not found in SharedPreferences');
    }
    _getProfileData();
  }

  Future<void> _getProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userModel = AppUtils.getSessionUser(prefs);
    });
  }

  void _showPicker() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.navBarIconColor,
      builder: (context) => Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.white),
            title: const Text(
              'Choose from Gallery',
              style: TextStyle(color: Colors.white),
            ),
            onTap: _pickImageFromGallery,
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.white),
            title: const Text(
              'Take a Photo',
              style: TextStyle(color: Colors.white),
            ),
            onTap: _pickImageFromCamera,
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ["jpg", 'png', 'pdf', 'html', 'mp4', 'mov', 'avi'],
    );
    if (pickedFile != null) {
      file = pickedFile.files.first;

      setState(() {
        image = File(file!.path!);
        print("image::: ${image}");
        fileNameController.text = file!.name;
      });
    }
    Navigator.of(context).pop();
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
        fileNameController.text = pickedFile.path.split('/').last;
      });
    }
    Navigator.of(context).pop();
  }

  void videosend(type) async {
    print("woking....");
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');
    if (image != null) {
      print("image=>$image");
      String? response = await messageViewModel.uploadvideo(image!, number);
      if (response != null) {
        print("type===>$type");
        debugPrint('video sedn video sendResponse: $response');
        var jsonResponse = jsonDecode(response);
        String? doucmentid = jsonResponse['id'];
        debugPrint('video sedn video send File ID: $doucmentid');
        Map<String, dynamic> imagebody = {
          "messaging_product": "whatsapp",
          "recipient_type": "individual",
          "to": widget.model.whatsapp_number,
          "type": type,
          type: {"id": doucmentid, "caption": "document"}
        };
        String? responseimage = await messageViewModel
            .uploadimagewithdoucmentid(bodyy: imagebody, number: number)
            .then((value) {
          print("video sedn video send send value----->$value");
          return null;
        });

        String? leadid = widget.model.id;
        print("video sedn video send sned lead id=>$leadid");

        String? sendimagedatabase = await messageViewModel
            .uploadFiledb(image!, number, leadid)
            .then((value) {
          print("video sedn video send send----upload dididi->$value");

          Map<String, dynamic> response = jsonDecode(value);

          fileid = response['records']?[0]['id'];

          print("ID: $fileid");
          return null;
        });
        debug("widget.leadNamewidget.leadName${widget.leadName}");
        Map<String, dynamic> imagehistorydata = {
          "parent_id": leadid,
          "name": widget.leadName,
          "message_template_id": null,
          "whatsapp_number": widget.wpnumber,
          "message": "",
          "status": "Outgoing",
          "recordtypename": "lead",
          "file_id": fileid,
          "business_number": number,
          "is_read": true
        };
        print("\x1B[33mdsdsfsdfsd$imagehistorydata\x1B[0m");

        print("fileidfileid$fileid");
        String? sendhistoryimage = await messageViewModel
            .sendimagehistory(
          msghistorydata: imagehistorydata,
        )
            .then((value) {
          print("\x1B[32msendhistoryimagesendhistoryimage$value\x1B[0m");
          return null;
        });
      } else {
        debugPrint('Image upload failed or response was null');
      }
    } else {
      debugPrint('No image selected');
    }
  }

  void filesend(String type) {
    print("typyp=>$type");
    if (type == "image") {
      imagesend(type);
    } else if (type == "document" || type == "pdf") {
      documetsend(type);
    } else if (type == "video") {
      print("SAdddddddddddddddddddddd");
      videosend(type);
    } else {
      debugPrint("Unsupported file type: $type");
    }
  }

  String docId = "";

  Future<String> getDocId() async {
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');
    String? response = await messageViewModel.uploadFile(image!, number);
    if (response != null) {
      var jsonResponse = jsonDecode(response);
      return jsonResponse['id'].toString();
    } else {
      return "";
    }
  }

  void imagesend(String type) async {
    print("woking....");
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    if (image != null) {
      print("type===> image  $type");
      String? response = await messageViewModel.uploadFile(image!, number);

      if (response != null) {
        debugPrint('Image uploaded successfully, Response: $response');

        var jsonResponse = jsonDecode(response);
        String? doucmentid = jsonResponse['id'];

        debugPrint('Uploaded File ID: $doucmentid');
        debugPrint(
            "widget.model.whatsapp_number${widget.model.whatsapp_number}");
        Map<String, dynamic> imagebody = {
          "messaging_product": "whatsapp",
          "recipient_type": "individual",
          "to": widget.model.whatsapp_number,
          "type": type,
          type: {"id": doucmentid, "caption": "Image caption"}
        };
        print("ississiis=>$imagebody");
        String? responseimage = await messageViewModel
            .uploadimagewithdoucmentid(bodyy: imagebody, number: number)
            .then((value) {
          print("value----->$value");
        });

        String? leadid = widget.model.id;
        print("leadid=>$leadid");

        String? sendimagedatabase = await messageViewModel
            .uploadFiledb(image!, number, leadid)
            .then((value) {
          print("value----upload dididi->${value}");

          Map<String, dynamic> response = jsonDecode(value);

          fileid = response['records']?[0]['id'];

          print("ID: $fileid");
        });

        Map<String, dynamic> imagehistorydata = {
          "parent_id": leadid,
          "name": widget.leadName,
          "message_template_id": null,
          "whatsapp_number": widget.wpnumber,
          "message": "",
          "status": "Outgoing",
          "recordtypename": "lead",
          "file_id": fileid,
          "business_number": number,
          "is_read": true
        };
        print("\x1B[33mdsdsfsdfsd${imagehistorydata}\x1B[0m");

        print("fileidfileid${fileid}");
        String? sendhistoryimage = await messageViewModel
            .sendimagehistory(
          msghistorydata: imagehistorydata,
        )
            .then((value) {
          print("\x1B[32msendhistoryimagesendhistoryimage${value}\x1B[0m");
        });
      } else {
        debugPrint('Image upload failed or response was null');
      }
    } else {
      debugPrint('No image selected');
    }
    print("after all functions arecalled::::");
    setState(() {
      isImageSent = true;
      showLoader = false;
    });
  }

  void documetsend(type) async {
    print("woking....");
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    if (image != null) {
      String? response = await messageViewModel.uploadFile(image!, number);

      if (response != null) {
        print("type===>$type");
        debugPrint('doucment uploaded successfully, Response: $response');

        var jsonResponse = jsonDecode(response);
        String? doucmentid = jsonResponse['id'];
        debugPrint('doument File ID: $doucmentid');
        Map<String, dynamic> imagebody = {
          "messaging_product": "whatsapp",
          "recipient_type": "individual",
          "to": widget.model.whatsapp_number,
          "type": type,
          type: {"id": doucmentid, "caption": "document"}
        };
        String? responseimage = await messageViewModel
            .uploadimagewithdoucmentid(bodyy: imagebody, number: number)
            .then((value) {
          print("document send value----->$value");
        });

        String? leadid = widget.model.id;
        print("document sned lead id=>$leadid");

        String? sendimagedatabase = await messageViewModel
            .uploadFiledb(image!, number, leadid)
            .then((value) {
          print("document send----upload dididi->${value}");

          Map<String, dynamic> response = jsonDecode(value);

          fileid = response['records']?[0]['id'];

          print("ID: $fileid");
        });
        debug("widget.leadNamewidget.leadName${widget.leadName}");
        Map<String, dynamic> imagehistorydata = {
          "parent_id": leadid,
          "name": widget.leadName,
          "message_template_id": null,
          "whatsapp_number": widget.wpnumber,
          "message": "",
          "status": "Outgoing",
          "recordtypename": "lead",
          "file_id": fileid,
          "business_number": number,
          "is_read": true
        };
        print("\x1B[33mdsdsfsdfsd${imagehistorydata}\x1B[0m");

        print("fileidfileid${fileid}");
        String? sendhistoryimage = await messageViewModel
            .sendimagehistory(
          msghistorydata: imagehistorydata,
        )
            .then((value) {
          print("\x1B[32msendhistoryimagesendhistoryimage${value}\x1B[0m");
        });
      } else {
        debugPrint('Image upload failed or response was null');
      }
    } else {
      debugPrint('No image selected');
    }

    setState(() {
      isImageSent = true;
      showLoader = false;
    });
  }

  Widget _pageBody() {
    print("all messages length::: ${allMessages.length}");
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
              controller: _scrollController,
              itemCount: allMessages.length,
              itemBuilder: (context, index) {
                // DateTime now = DateTime.now();
                // String formattedTime = DateFormat('hh:mm a').format(now);

                // DateTime utcTime = allMessages[index].createddate;
                // DateTime istTime =
                //     utcTime.add(const Duration(hours: 5, minutes: 30));
                // formattedTime = DateFormat('hh:mm a').format(istTime);
                // String title = allMessages[index].title ?? "";
                // String msghistoryid = allMessages[index].id;
                // print("sjdhjshdjas=>$msghistoryid");
                String imageUrl = "";

                DateTime now = DateTime.now();
                String formattedTime = DateFormat('hh:mm a').format(now);

                DateTime utcTime = allMessages[index].createddate;
                DateTime istTimee =
                    utcTime.add(const Duration(hours: 5, minutes: 30));
                formattedTime = DateFormat('hh:mm a').format(istTimee);
                bool isSameDay(DateTime? dateA, DateTime? dateB) {
                  return dateA?.year == dateB?.year &&
                      dateA?.month == dateB?.month &&
                      dateA?.day == dateB?.day;
                }

                // DateTime now = DateTime.now();

                String dayLabel = '';
                if (isSameDay(istTimee, now)) {
                  dayLabel = 'Today';
                } else if (isSameDay(
                    istTimee, now.subtract(const Duration(days: 1)))) {
                  dayLabel = 'Yesterday';
                } else {
                  dayLabel = DateFormat('EEEE').format(istTimee);
                }
                // String formattedTimee = DateFormat('hh:mm a').format(istTimee);

                // String finalFormattedTime = '$dayLabel, $formattedTimee';
                String finalFormattedTime = '$dayLabel';
                // print("finalFormattedTime=>$finalFormattedTime");

                // print(finalFormattedTime);
                String title = allMessages[index].title ?? "";
                String msghistoryid = allMessages[index].id;
                // print("sjdhjshdjas=>$msghistoryid");
                if (title.isNotEmpty) {
                  imageUrl =
                      "https://sandbox.watconnect.com/public/demo/attachment/$title";
                }

                return GestureDetector(
                  onLongPress: () => _showSimpleDialog(),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(8),
                    child: Align(
                      alignment: _getAlignment(allMessages[index].status),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (index == 0)
                              Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  finalFormattedTime,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                            Text(
                              allMessages[index].status == "Incoming"
                                  ? allMessages[index].name
                                  : userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            if (allMessages[index].message != null &&
                                allMessages[index].message!.isNotEmpty)
                              IntrinsicWidth(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.65,
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color:
                                        allMessages[index].status == "Outgoing"
                                            ? const Color(0xff594EBA)
                                            : const Color(0xff221B41),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(12),
                                      topRight: const Radius.circular(12),
                                      bottomLeft: allMessages[index].status ==
                                              "Outgoing"
                                          ? const Radius.circular(12)
                                          : const Radius.circular(0),
                                      bottomRight: allMessages[index].status ==
                                              "Outgoing"
                                          ? const Radius.circular(0)
                                          : const Radius.circular(12),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(2, 2),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        allMessages[index].message!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          height: 1.5,
                                        ),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      if (allMessages[index].status ==
                                          "Outgoing")
                                        if (allMessages[index].deliveryStatus !=
                                            null)
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Icon(
                                              Icons.done_all,
                                              color: allMessages[index]
                                                          .deliveryStatus ==
                                                      "read"
                                                  ? Colors.green
                                                  : Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                            if (allMessages[index].templateName != null ||
                                allMessages[index].headerBody != null)
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.65,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(0),
                                  ),
                                  color: allMessages[index].status == "Outgoing"
                                      ? const Color(0xff594EBA)
                                      : const Color(0xff221B41),
                                ),
                                child: Column(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                        children: [
                                          if (allMessages[index].headerBody !=
                                              null)
                                            TextSpan(
                                              text:
                                                  '${capitalize(allMessages[index].headerBody!)}\n',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          if (allMessages[index].templateName !=
                                              null)
                                            TextSpan(
                                              text:
                                                  '${allMessages[index].templateName}\n',
                                              style: const TextStyle(
                                                  // Slightly heavier for emphasis
                                                  ),
                                            ),
                                          if (allMessages[index].footer != null)
                                            TextSpan(
                                              text: allMessages[index].footer,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (allMessages[index].status == "Outgoing")
                                      if (allMessages[index].deliveryStatus ==
                                              "delivered" ||
                                          allMessages[index].deliveryStatus ==
                                              "sent")
                                        Row(
                                          mainAxisAlignment:
                                              allMessages[index].status ==
                                                      "Outgoing"
                                                  ? MainAxisAlignment.end
                                                  : MainAxisAlignment.start,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.done_all,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                              ),
                                              onPressed: () {},
                                            ),
                                          ],
                                        ),
                                    if (allMessages[index].deliveryStatus ==
                                        "read")
                                      IconButton(
                                        icon: const Icon(Icons.done_all,
                                            color: Colors.green),
                                        onPressed: () {},
                                      )
                                    else
                                      const SizedBox.shrink(),
                                  ],
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                            Text(
                              formattedTime,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            if (imageUrl.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: GestureDetector(
                                  onTap: () async {
                                    print(
                                        "imageurl before show::: ${imageUrl}");
                                    if (imageUrl
                                        .split('.')
                                        .last
                                        .contains('pdf')) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ViewPdf(
                                                    pdfUrl: imageUrl,
                                                  )));
                                    } else if (imageUrl
                                        .split('.')
                                        .last
                                        .contains('mp4')) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ViewVideo(
                                                    videoUrl: imageUrl,
                                                  )));
                                    } else if (imageUrl
                                            .split('.')
                                            .last
                                            .contains('png') ||
                                        imageUrl
                                            .split('.')
                                            .last
                                            .contains('jpg') ||
                                        imageUrl
                                            .split('.')
                                            .last
                                            .contains('jpeg')) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Image Details"),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.network(
                                                  imageUrl,
                                                  height: 300,
                                                  width: 300,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder:
                                                      (BuildContext context,
                                                          Widget child,
                                                          ImageChunkEvent?
                                                              loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    } else {
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          value: loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  (loadingProgress
                                                                          .expectedTotalBytes ??
                                                                      1)
                                                              : null,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const SizedBox
                                                        .shrink();
                                                  },
                                                ),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 8,
                                                      horizontal: 16),
                                                  decoration: BoxDecoration(
                                                    color: AppColor
                                                        .navBarIconColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: const Text(
                                                    "Close",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      print("it is supposed to be here");
                                      try {
                                        final dir =
                                            await getTemporaryDirectory();
                                        String fileName =
                                            imageUrl.split('/').last;
                                        final filePath =
                                            '${dir.path}/${fileName}';

                                        final response =
                                            await http.get(Uri.parse(imageUrl));

                                        if (response.statusCode == 200) {
                                          final file = File(filePath);
                                          await file
                                              .writeAsBytes(response.bodyBytes);

                                          print(
                                              "File downloaded to: $filePath");

                                          OpenFile.open(filePath);
                                        }
                                      } catch (e) {
                                        print("error in opening file:: ${e}");
                                      }
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      imageUrl.split('.').last.contains('pdf')
                                          ? IntrinsicWidth(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: allMessages[index]
                                                              .status ==
                                                          "Outgoing"
                                                      ? const Color(0xff594EBA)
                                                      : const Color(0xff221B41),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        const Radius.circular(
                                                            12),
                                                    topRight:
                                                        const Radius.circular(
                                                            12),
                                                    bottomLeft: allMessages[
                                                                    index]
                                                                .status ==
                                                            "Outgoing"
                                                        ? const Radius.circular(
                                                            12)
                                                        : const Radius.circular(
                                                            0),
                                                    bottomRight: allMessages[
                                                                    index]
                                                                .status ==
                                                            "Outgoing"
                                                        ? const Radius.circular(
                                                            0)
                                                        : const Radius.circular(
                                                            12),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(2, 2),
                                                    )
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  child: Column(
                                                    children: [
                                                      Image.asset(
                                                        "assets/images/pdf.png",
                                                        height: 120,
                                                        width: 120,
                                                      ),
                                                      if (allMessages[index]
                                                                  .deliveryStatus ==
                                                              "delivered" ||
                                                          allMessages[index]
                                                                  .deliveryStatus ==
                                                              "sent")
                                                        Row(
                                                          mainAxisAlignment: allMessages[
                                                                          index]
                                                                      .status ==
                                                                  "Outgoing"
                                                              ? MainAxisAlignment
                                                                  .end
                                                              : MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.done_all,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        255),
                                                              ),
                                                              onPressed: () {},
                                                            ),
                                                          ],
                                                        ),
                                                      if (allMessages[index]
                                                              .deliveryStatus ==
                                                          "read")
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(
                                                                  Icons
                                                                      .done_all,
                                                                  color: Colors
                                                                      .green),
                                                              onPressed: () {},
                                                            ),
                                                          ],
                                                        )
                                                      else
                                                        const SizedBox.shrink(),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          : imageUrl
                                                  .split('.')
                                                  .last
                                                  .contains('mp4')
                                              ? IntrinsicWidth(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: allMessages[index]
                                                                  .status ==
                                                              "Outgoing"
                                                          ? const Color(
                                                              0xff594EBA)
                                                          : const Color(
                                                              0xff221B41),
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft: const Radius
                                                            .circular(12),
                                                        topRight: const Radius
                                                            .circular(12),
                                                        bottomLeft: allMessages[
                                                                        index]
                                                                    .status ==
                                                                "Outgoing"
                                                            ? const Radius
                                                                .circular(12)
                                                            : const Radius
                                                                .circular(0),
                                                        bottomRight: allMessages[
                                                                        index]
                                                                    .status ==
                                                                "Outgoing"
                                                            ? const Radius
                                                                .circular(0)
                                                            : const Radius
                                                                .circular(12),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.2),
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                              2, 2),
                                                        )
                                                      ],
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8.0),
                                                      child: Column(
                                                        children: [
                                                          Image.asset(
                                                            "assets/images/video.png",
                                                            height: 120,
                                                            width: 120,
                                                          ),
                                                          if (allMessages[index]
                                                                  .status ==
                                                              "Outgoing")
                                                            if (allMessages[index]
                                                                        .deliveryStatus ==
                                                                    "delivered" ||
                                                                allMessages[index]
                                                                        .deliveryStatus ==
                                                                    "sent")
                                                              IconButton(
                                                                icon:
                                                                    const Icon(
                                                                  Icons
                                                                      .done_all,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          255),
                                                                ),
                                                                onPressed:
                                                                    () {},
                                                              ),
                                                          // if (allMessages[index]
                                                          //         .deliveryStatus ==
                                                          //     "sent")
                                                          //   Row(
                                                          //     mainAxisAlignment:
                                                          //         MainAxisAlignment
                                                          //             .end,
                                                          //     children: [
                                                          //       IconButton(
                                                          //         icon: const Icon(
                                                          //             Icons
                                                          //                 .check,
                                                          //             color: Colors
                                                          //                 .white),
                                                          //         onPressed:
                                                          //             () {},
                                                          //       ),
                                                          //     ],
                                                          //   ),
                                                          if (allMessages[index]
                                                                  .deliveryStatus ==
                                                              "read")
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                IconButton(
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .done_all,
                                                                      color: Colors
                                                                          .green),
                                                                  onPressed:
                                                                      () {},
                                                                ),
                                                              ],
                                                            )
                                                          else
                                                            const SizedBox
                                                                .shrink(),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : imageUrl
                                                          .split('.')
                                                          .last
                                                          .contains('png') ||
                                                      imageUrl
                                                          .split('.')
                                                          .last
                                                          .contains('jpg') ||
                                                      imageUrl
                                                          .split('.')
                                                          .last
                                                          .contains('jpeg')
                                                  ? IntrinsicWidth(
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: allMessages[
                                                                          index]
                                                                      .status ==
                                                                  "Outgoing"
                                                              ? const Color(
                                                                  0xff594EBA)
                                                              : const Color(
                                                                  0xff221B41),
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                const Radius
                                                                    .circular(
                                                                    12),
                                                            topRight:
                                                                const Radius
                                                                    .circular(
                                                                    12),
                                                            bottomLeft: allMessages[
                                                                            index]
                                                                        .status ==
                                                                    "Outgoing"
                                                                ? const Radius
                                                                    .circular(
                                                                    12)
                                                                : const Radius
                                                                    .circular(
                                                                    0),
                                                            bottomRight: allMessages[
                                                                            index]
                                                                        .status ==
                                                                    "Outgoing"
                                                                ? const Radius
                                                                    .circular(0)
                                                                : const Radius
                                                                    .circular(
                                                                    12),
                                                          ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.2),
                                                              blurRadius: 4,
                                                              offset:
                                                                  const Offset(
                                                                      2, 2),
                                                            )
                                                          ],
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 8.0,
                                                                  horizontal:
                                                                      4),
                                                          child: Column(
                                                            children: [
                                                              Image.network(
                                                                imageUrl,
                                                                height: 120,
                                                                width: 120,
                                                                fit: BoxFit
                                                                    .cover,
                                                                loadingBuilder: (BuildContext
                                                                        context,
                                                                    Widget
                                                                        child,
                                                                    ImageChunkEvent?
                                                                        loadingProgress) {
                                                                  if (loadingProgress ==
                                                                      null) {
                                                                    return child;
                                                                  } else {
                                                                    return Center(
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        color: Colors
                                                                            .black,
                                                                        value: loadingProgress.expectedTotalBytes !=
                                                                                null
                                                                            ? loadingProgress.cumulativeBytesLoaded /
                                                                                (loadingProgress.expectedTotalBytes ?? 1)
                                                                            : null,
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                                errorBuilder:
                                                                    (context,
                                                                        error,
                                                                        stackTrace) {
                                                                  return const SizedBox
                                                                      .shrink();
                                                                },
                                                              ),
                                                              if (allMessages[
                                                                          index]
                                                                      .status ==
                                                                  "Outgoing")
                                                                if (allMessages[index]
                                                                            .deliveryStatus ==
                                                                        "delivered" ||
                                                                    allMessages[index]
                                                                            .deliveryStatus ==
                                                                        "sent")
                                                                  Row(
                                                                    mainAxisAlignment: allMessages[index].status ==
                                                                            "Outgoing"
                                                                        ? MainAxisAlignment
                                                                            .end
                                                                        : MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      IconButton(
                                                                        icon:
                                                                            const Icon(
                                                                          Icons
                                                                              .done_all,
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              255,
                                                                              255,
                                                                              255),
                                                                        ),
                                                                        onPressed:
                                                                            () {},
                                                                      ),
                                                                    ],
                                                                  ),
                                                              if (allMessages[
                                                                          index]
                                                                      .deliveryStatus ==
                                                                  "read")
                                                                IconButton(
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .done_all,
                                                                      color: Colors
                                                                          .green),
                                                                  onPressed:
                                                                      () {},
                                                                )
                                                              else
                                                                const SizedBox
                                                                    .shrink(),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : IntrinsicWidth(
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: allMessages[
                                                                          index]
                                                                      .status ==
                                                                  "Outgoing"
                                                              ? const Color(
                                                                  0xff594EBA)
                                                              : const Color(
                                                                  0xff221B41),
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                const Radius
                                                                    .circular(
                                                                    12),
                                                            topRight:
                                                                const Radius
                                                                    .circular(
                                                                    12),
                                                            bottomLeft: allMessages[
                                                                            index]
                                                                        .status ==
                                                                    "Outgoing"
                                                                ? const Radius
                                                                    .circular(
                                                                    12)
                                                                : const Radius
                                                                    .circular(
                                                                    0),
                                                            bottomRight: allMessages[
                                                                            index]
                                                                        .status ==
                                                                    "Outgoing"
                                                                ? const Radius
                                                                    .circular(0)
                                                                : const Radius
                                                                    .circular(
                                                                    12),
                                                          ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.2),
                                                              blurRadius: 4,
                                                              offset:
                                                                  const Offset(
                                                                      2, 2),
                                                            )
                                                          ],
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical:
                                                                      8.0),
                                                          child: Column(
                                                            children: [
                                                              Image.asset(
                                                                "assets/images/doc.png",
                                                                height: 120,
                                                                width: 120,
                                                              ),
                                                              if (allMessages[
                                                                          index]
                                                                      .status ==
                                                                  "Outgoing")
                                                                if (allMessages[index]
                                                                            .deliveryStatus ==
                                                                        "delivered" ||
                                                                    allMessages[index]
                                                                            .deliveryStatus ==
                                                                        "sent")
                                                                  IconButton(
                                                                    icon:
                                                                        const Icon(
                                                                      Icons
                                                                          .done_all,
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          255),
                                                                    ),
                                                                    onPressed:
                                                                        () {},
                                                                  ),
                                                              if (allMessages[
                                                                          index]
                                                                      .deliveryStatus ==
                                                                  "read")
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    IconButton(
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .done_all,
                                                                          color:
                                                                              Colors.green),
                                                                      onPressed:
                                                                          () {},
                                                                    ),
                                                                  ],
                                                                )
                                                              else
                                                                const SizedBox
                                                                    .shrink(),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
        ),
        _buildMessageInputArea(),
      ],
    );
  }

  void singlemsgdelete(msghistoryid) async {
    print("Single delete attempt for message with ID: $msghistoryid");

    if (msghistoryid.isEmpty) {
      print("Invalid message ID. Cannot delete.");
      return;
    }
    var msghistoryidd = msghistoryid;
    print("sdhsdhjdhjsdhfdks=>$msghistoryidd");

    var bodyy = jsonEncode({
      "ids": [msghistoryidd]
    });

    print("Request hdshsd jhds body: $bodyy");
    MessageViewModel msgdelete = MessageViewModel(context);
    msgdelete.singlemsgdelete(bodyy).then((value) {
      // isdelete = true;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("deleted sucefully")));
      print("Delete single message successfully");
    }).catchError((error) {
      print("Error deleting message: $error");
    });
  }

  Alignment _getAlignment(String? status) {
    if (status == "Outgoing") {
      return Alignment.centerRight;
    } else if (status == "Incoming") {
      return Alignment.centerLeft;
    } else {
      return Alignment.center;
    }
  }

  Widget _buildMessageInputArea() {
    messageViewModel = Provider.of<MessageViewModel>(context);

    print(
        " messageViewModel.viewModels.length:::::: ${messageViewModel.viewModels}   ${showLoader} ");

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _showPicker,
          ),
          Expanded(
            child: Row(
              children: [
                image != null && isImageSent == false
                    ? image.toString().split('.').last.contains('pdf')
                        ? Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.only(right: 8.0),
                            decoration: BoxDecoration(
                              // color: Colors.blue,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                "assets/images/pdf.png",
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover, // Ensures full coverage
                              ),
                            ),
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.only(right: 8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              image: DecorationImage(
                                image: FileImage(image!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                    : const SizedBox.shrink(),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF1F1F1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 148, 188, 206),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.code, color: Colors.white),
              onPressed: () {
                _getBootmSheet();
              },
            ),
          ),
          allMessages.length == 0
              ? SizedBox()
              : Container(
                  decoration: BoxDecoration(
                    color: AppColor.cardsColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: showLoader
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () async {
                            print("image$image");
                            setState(() {
                              showLoader = true;
                            });

                            if (image != null) {
                              String fileExtension =
                                  path.extension(image!.path).toLowerCase();
                              print("File Extension: $fileExtension");

                              if (fileExtension == '.jpg' ||
                                  fileExtension == '.jpeg') {
                                print("🖼 Sending Image...");
                                filesend("image");
                              } else if (fileExtension == '.mp4' ||
                                  fileExtension == '.avi' ||
                                  fileExtension == '.mov') {
                                print("🎥 Sending Video...");
                                filesend("video");
                              } else if (fileExtension == '.html' ||
                                  fileExtension == '.txt') {
                                print("🎥 Sending text document...");
                                filesend("document");
                              } else {
                                print("📄 Sending Document...");
                                filesend("document");
                              }
                            } else if (_controller.text.trim().isNotEmpty) {
                              showLoader = false;
                              messagesendd(_controller.text);
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      content: Text(
                                "please Type Message",
                                selectionColor: Colors.amber,
                              )));
                              print(
                                  "⚠ No file or text entered. Doing nothing.");
                            }
                            _controller.clear();
                            setState(() {});
                          },
                        )),
        ],
      ),
    );
  }

  Future<void> _showSimpleDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: AppColor.cardsColor,
          title: const Text(
            'Are you sure want to Delete Message',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          children: <Widget>[
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        print("mmms=>${msghistoryid}");
                        singlemsgdelete(msghistoryid);
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "ok",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        minimumSize:
                            MaterialStateProperty.all(const Size(10, 20)),
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchTemplates() async {
    TempleteListViewModel templeteViewModel =
        Provider.of<TempleteListViewModel>(context, listen: false);

    // Check if templeteViewModel is not null and contains viewModels
    if (templeteViewModel != null && templeteViewModel.viewModels.isNotEmpty) {
      for (var viewModel in templeteViewModel.viewModels) {
        var campaignModel = viewModel.model;
        if (campaignModel?.data != null) {
          for (var record in campaignModel!.data!) {
            if (record.status != null) {
              print("Record template Status: ${record.name}");
              setState(() {
                templateNames.add(record.name);
                print("Templates => $templateNames");
              });
            }
          }
        }
      }
    }
  }

  var currentTemplate;
  List<Component> components = [];

  Future<void> _setSelectedTemplates() async {
    TempleteListViewModel templeteViewModel =
        Provider.of<TempleteListViewModel>(context, listen: false);

    if (templeteViewModel != null && templeteViewModel.viewModels.isNotEmpty) {
      for (var viewModel in templeteViewModel.viewModels) {
        var campaignModel = viewModel.model;
        if (campaignModel?.data != null) {
          for (var record in campaignModel!.data!) {
            if (record.status != null) {
              print("rec name ::${record.name}  ${selectedTemplateName}");
              if (selectedTemplateName == record.name) {
                currentTemplate = record;

                log("current template::::: ${currentTemplate}  ${currentTemplate.name}");
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

// Call setState once after processing all components
                setState(() {});

                log("components ::: ${selectedHeader}   ${selectedBody}  ${selectedButtons}");

                return;
              }
            }
          }
        }
      }
    }
  }

  void gtcategorybytemplate() {
    print(templateNames);
  }

  Future<void> _sendTemplateSheet() {
    bool isChecked = false;
    String text = selectedBody.text;
    String imgToShow = "";
    if (selectedHeader != null &&
        selectedHeader.example.headerHandle != null &&
        selectedHeader.example.headerHandle.isNotEmpty) {
      print("selectedHeader>>> ${selectedHeader.example.headerHandle}");
      imgToShow = selectedHeader.example.headerHandle[0];
    } else {
      imgToShow = "";
    }

    print("selectedHeader.format>>>> ${selectedHeader.format}");

    final regex = RegExp(r'\{\{\d+\}\}');

    int count = regex.allMatches(text).length;

    controllers = List.generate(count, (index) => TextEditingController());

    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      enableDrag: false,
      elevation: 1,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * .80,
              child: SingleChildScrollView(
                child: Padding(
                  padding: MediaQuery.of(context).viewInsets,
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
                              "Review Template",
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
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
                              children: [
                                if (selectedHeader != null &&
                                    selectedHeader.format == "IMAGE")
                                  imgToShow.isEmpty
                                      ? Container(
                                          height: 80,
                                          width: 80,
                                          child: Image.asset(
                                              "assets/images/img_placeholder.png"))
                                      : Image.network(imgToShow),
                                if (selectedHeader == null ||
                                    selectedHeader.format != "IMAGE")
                                  SizedBox(),
                                selectedBody != null
                                    ? Text("${selectedBody.text}")
                                    : SizedBox(),
                                SizedBox(
                                  height: 10,
                                ),
                                selectedButtons != null
                                    ? Wrap(
                                        spacing: 10,
                                        children: List.generate(
                                            selectedButtons.buttons.length,
                                            (index) {
                                          return ElevatedButton(
                                            onPressed: () {
                                              print(
                                                  "Button ${index + 1} clicked");
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey[400],
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  side: BorderSide(
                                                      color: AppColor
                                                          .navBarIconColor)),
                                            ),
                                            child: Text(
                                              selectedButtons
                                                  .buttons[index].text,
                                              style: TextStyle(
                                                  color:
                                                      AppColor.navBarIconColor),
                                            ),
                                          );
                                        }),
                                      )
                                    : SizedBox(),
                                SizedBox(height: 15),
                                selectedFooter != null
                                    ? Text(
                                        selectedFooter.text,
                                        style: TextStyle(color: Colors.grey),
                                        textAlign: TextAlign.left,
                                      )
                                    : SizedBox(),
                                SizedBox(height: 15),
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
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              backgroundColor: AppColor.navBarIconColor,
                            ),
                            onPressed: () async {
                              Map<String, String> bodyTextParams = {};
                              List compoTextParams = [];
                              List numberedCampParam = [];

                              bool anyEmpty = controllers
                                  .any((controller) => controller.text.isEmpty);

                              if (anyEmpty) {
                                return;
                              } else {
                                print("All fields are filled");
                              }
                              File? imageFile;
                              if (imgToShow.isNotEmpty) {}
                              image = await urlToFile(imgToShow);

                              String docId = await getDocId();

                              for (int i = 0; i < controllers.length; i++) {
                                bodyTextParams[(i + 1).toString()] =
                                    controllers[i].text;
                                Map body = {
                                  "type": "text",
                                  "text": controllers[i].text
                                };
                                compoTextParams.add(body);
                                numberedCampParam.add(bodyTextParams);
                              }

                              String templateToSend = selectedTemplateName ??
                                  _templateController.text;
                              print(
                                  "Template to send: $templateToSend           ${selectedFooter.text}");

                              if (docId.isNotEmpty) {
                                List parameter = [
                                  {
                                    "type": "image",
                                    "image": {"id": docId}
                                  }
                                ];

                                sendParamsApiCall(
                                    templateToSend,
                                    compoTextParams,
                                    isChecked,
                                    parameter,
                                    bodyTextParams);
                              }
                            },
                            child: const Text(
                              "Send Template",
                              style:
                                  TextStyle(fontSize: 13, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    ;
  }

  Future<void> _getBootmSheet() {
    TextEditingController _templateController = TextEditingController();
    int selectedBtnIdx = 0;
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

                            templateNames = (allTemplatesMap[categoryKey]
                                        ?.values
                                        .toList() ??
                                    [])
                                .cast<String>();

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

                        _setSelectedTemplates();
                      },
                      value: selectedTemplateName,
                    ),
                    Center(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          minimumSize:
                              MaterialStateProperty.all(const Size(10, 20)),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10)),
                          backgroundColor: MaterialStateProperty.all(
                              AppColor.navBarIconColor),
                        ),
                        onPressed: () {
                          log("all comp info >> >>  ${selectedHeader}  ${selectedBody} ${selectedFooter} ${selectedButtons}}");
                          log("selectedBody['text']>>> ${selectedBody.text}  ");
                          final regex = RegExp(r'\{\{\d+\}\}');

                          if (regex.hasMatch(selectedBody.text)) {
                            Navigator.of(context).pop();
                            _sendTemplateSheet();
                          } else {
                            String templateToSend = selectedTemplateName ??
                                _templateController.text;
                            print("Template to send: $templateToSend");
                            templetesendd(templateToSend, []);

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

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<void> sendParamsApiCall(String templateToSend, List compoTextParams,
      bool sendOnLoginNum, List params, Map campaignParam) async {
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    late MessageViewModel mstemp = MessageViewModel(context);
    TempleteListViewModel templeteViewModel =
        Provider.of<TempleteListViewModel>(context, listen: false);

    Map<String, dynamic> createtemp = {
      "id": null,
      "name": templateToSend,
      "language": "en",
      "category": "MARKETING",
      "header": "TEXT",
      "header_body": "template header",
      "message_body": templateToSend,
      "example_body_text": {"sendToAdmin": sendOnLoginNum},
      "footer": selectedFooter.text,
      "buttons": [],
      "business_number": number
    };

    mstemp.createmsgtemplete(msgmobilbody: createtemp).then((value) => {
          templeteidmessage = value['id'],
          print("temmplet msg id==========>$templeteidmessage"),
          print("ccretae objetctt resposne= > $value")
        });

    var leadnumber = widget.wpnumber;
    Map<String, dynamic> templateBody = {
      "messaging_product": "whatsapp",
      "to": leadnumber,
      "type": "template",
      "template": {
        "name": templateToSend,
        "language": {"code": "en_US"},
        "components": [
          {
            "type": "header",
            "parameters": [
              {
                "type": "image",
                "image": {"id": "1516705009247219"}
              }
            ]
          },
          {"type": "body", "parameters": compoTextParams}
        ]
      }
    };
    print("templetete body=>$templateBody");
    mstemp
        .sendtemplete(number: number, msgmobilbody: templateBody)
        .then((value) {
      print("value=== templete>$value");
      print("value=== template>${value['messages'][0]['id']}");
      messageid = value['messages'][0]['id'];

      Map<String, dynamic> msgmobilebody = {
        "parent_id": widget.model.id,
        "name": widget.leadName,
        "message_template_id": templeteidmessage,
        "whatsapp_number": leadnumber,
        "message": "",
        "status": "Outgoing",
        "recordtypename": "recentlyMessage",
        "file_id": null,
        "is_read": true,
        "business_number": number,
        "message_id": messageid,
        "interactive_id": null
      };

      mstemp.sendmsgmobile(msgmobilbody: msgmobilebody).then((value) {
        print("valueee1=>$value");

        String msgResId = value['id'];

        Map<String, dynamic> paramBody = {
          "campaign_id": null,
          "body_text_params": campaignParam,
          "msg_history_id": msgResId,
          "file_id": null,
          "whatsapp_number_admin": "7590889022"
        };

        mstemp.sendCampParam(campParambody: paramBody).then((value) {
          print("sendCampParam>>> ${value}");
        });
      });
    });
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
}
