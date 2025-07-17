import 'dart:async';
import 'dart:developer';
// import 'dart:io' as IO;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_sound/flutter_sound.dart' as fs;

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart' show Consumer, Provider;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:whatsapp/main.dart';
import 'package:whatsapp/models/approved_template_model/aprovedtempltemodel/component.dart';
import 'package:whatsapp/models/lead_model.dart';
import 'package:whatsapp/models/unread_msg_model/unread_msg_model.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_fonts.dart';
import 'package:whatsapp/utils/function_lib.dart';
import 'package:whatsapp/view_models/lead_list_vm.dart';
import 'package:whatsapp/view_models/message_controller.dart';
import 'package:whatsapp/view_models/templete_list_vm.dart';
import 'package:whatsapp/view_models/unread_count_vm.dart';
import 'package:whatsapp/view_models/wallet_controller.dart';
import 'package:whatsapp/views/view/lead_detail_view.dart';
import 'package:whatsapp/views/view/show_audio.dart';
import 'package:whatsapp/views/view/show_pdf.dart';
import 'package:whatsapp/views/view/show_video.dart';
import 'package:whatsapp/views/view/view_fullscreen_img.dart';

import '../../models/template_model/template_model.dart';
import '../../models/user_model/user_model.dart';
import '../../utils/app_utils.dart';
import '../../view_models/message_list_vm.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChatScreen extends StatefulWidget {
  final String? leadName;
  final String? wpnumber;
  final List? pinnedLeads;
  LeadModel? model;
  final String? contryCode;
  String? id;
  // final LeadModel model;
  ChatScreen(
      {Key? key,
      this.leadName,
      this.wpnumber,
      this.pinnedLeads,
      this.id,
      this.model,
      this.contryCode
      // required this.model,
      })
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<TextEditingController> controllers = [];

  List<String> templateNamesss = [];
  List<String> templateIds = [];
  String msghistoryid = "";
  final ScrollController _scrollController = ScrollController();
  bool isImageSent = false;
  bool _isLoading = true;
  int lenOfRec = 0;
  bool hasWallet = false;
  String? globalParentId;
  XFile? selectedImage;
  String base64Image = '';
  String? SelectedTemplateCategory;
  Map<String, Map<String, dynamic>> allTemplatesMap = {};
  List<dynamic> templateName1 = [];
  String? templeteidmessage;
  List<String> templateNames = [];
  String? selectedTemplate;
  String? selectedTemplateId;
  String templetmsgid = "";
  var templeteViewModel;
  List deleteMgs = [];
  String messageid = "";

  File? _audioFile;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  StreamSubscription? _previewPlayerSubscription;
  final AudioPlayer audioPlayer = AudioPlayer();

  bool _isPlaying = false;

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
  List<dynamic> tempateCategory = [
    'All Categories',
    'UTILITY',
    'MARKETING',
    'AUTHENTICATION',
  ];
  String? selectedTemplateName;
  var selectedLanguage;
  var selectedHeader;
  var selectedBody;
  var selectedFooter;
  dynamic selectedButtons;
  late VideoPlayerController _Vcontroller;
  TempleteListViewModel? templateVM;

  bool showLoader = false;
  String userName = "";
  TextEditingController _templateController = TextEditingController();

  IO.Socket? socket;
  String token = "your_token_here";
  var userId;
  String leadId = "lead_456";
  String phNum = "+919876543210";

  // bool _listenerAdded = false;

  markUnread() async {
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    Map<String, String>? bodydata = {"whatsapp_number": widget.wpnumber ?? ""};

    var response = await Provider.of<UnreadCountVm>(context, listen: false)
        .marksreadcountmsg(
      leadnumber: widget.wpnumber ?? "",
      number: number,
      bodydata: bodydata,
    );
  }

  @override
  void initState() {
    markUnread();
    WalletController walletController = Provider.of(context, listen: false);
    getWalletStatus();
    walletController.templateRatesApiCall();
    leadId = widget.wpnumber ?? "";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MessageController msgController =
          Provider.of<MessageController>(context, listen: false);
      msgController.clearDeleteList();
    });

    // connectSocket();
    _initializeAudio();
    templateNames.add("Select Template Name");
    // connectSocket();

    _fetchTemplates();
    super.initState();
    _pullRefresh();
    showLoader = false;
    _getPhoneNumber();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    print("Lead Number =>${widget.wpnumber} ");
  }

  getWalletStatus() async {
    print("is thi func even getting called:::::  ");
    final prefs = await SharedPreferences.getInstance();
    hasWallet = await prefs.getBool(SharedPrefsConstants.hasWalletKey) ?? false;
    print("hasWallet:::::::::::::::::   ${hasWallet}");
    setState(() {});
  }

  Future<void> _initializeAudio() async {
    await _player.openPlayer();
    await _recorder.openRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    audioPlayer.dispose();
    _previewPlayerSubscription?.cancel();
    // disconnectSocket();

    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    log("is build method calling alwayss");
    messageViewModel = Provider.of<MessageViewModel>(context);
    print("messageViewModel in the build :: ${messageViewModel.viewModels}");
    allMessages = [];
    for (var viewModel in messageViewModel.viewModels) {
      final model = viewModel.model;
      if (model.records?.isNotEmpty ?? false) {
        allMessages.addAll(messageViewModel.viewModels[0].model.records);
      }
    }
    _scrollToBottom();
    setState(() {});

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

    return Consumer<MessageController>(
        builder: (context, msgController, child) {
      return FocusDetector(
        onFocusGained: () {
          log('\x1B[95mFCM     Chat Screen focused again::::::::::::::::::::::::::::::::::::::::::::::::::');

          // print("Screen focused again");
          connectSocket();
        },
        onFocusLost: () {
          disconnectSocket();
        },
        child: SafeArea(
          bottom: true,
          top: false,
          child: Scaffold(
            backgroundColor: AppColor.pageBgGrey,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                "Chat",
                style: TextStyle(color: Colors.white),
              ),
              centerTitle: true,
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
          ),
        ),
      );
    });
  }

  void deletechat() async {
    print("delete function callin g working");
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');
    late MessageViewModel msgdelete = MessageViewModel(context);
    msgdelete
        .msghistorydelete(leadnumber: widget.wpnumber, number: number)
        .then((value) => {
              _pullRefresh(),
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

  Future<void> messagesendd(String text) async {
    print("messagesendd called");

    TempleteListViewModel tm = TempleteListViewModel(context);
    MessageViewModel ms = MessageViewModel(context);

    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    if (number!.isEmpty) {
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
      "parent_id": widget.id,
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
    print("leadnumberleadnumberleadnumber${leadnumber}");
    try {
      var value = await ms.sendMessage(number: number, addmsModel: addmsModel);
      print("valueee=>$value");

      if (value.isNotEmpty) {
        var messageId = value['messages'];
        print('Message ID: ${messageId[0]['id']}');
        messageid = messageId[0]['id'];
        msgmobilebody['message_id'] = messageid;

        var msgValue = await ms.sendmsgmobile(msgmobilbody: msgmobilebody);
        print("valueee1=>$msgValue");

        if (msgValue['delivery_status'] == "sent") {
          _controller.clear();
          setState(() {
            showLoader = false;
            image = null;
            getHistory();
          });

          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text('Message sent successfully'),
          //     duration: Duration(seconds: 3),
          //     backgroundColor: Colors.green,
          //   ),
          // );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        "language": {"code": selectedLanguage},
        "components": [
          {"type": "header", "parameters": []},
          {"type": "body", "parameters": []}
        ]
      }
    };
    if (SelectedTemplateCategory == "AUTHENTICATION") {
      List cp = templateBody["template"]["components"];
      cp.add({
        "type": "button",
        "sub_type": "url",
        "index": "0",
        "parameters": []
      });
    }
    ;
    print("templetete body=>$templateBody");

    Map<String, dynamic> createtemp = {
      "id": selectedTemplateId,
      "name": templateToSend,
      "language": selectedLanguage,
      "category": SelectedTemplateCategory ?? "MARKETING",
      "header": "TEXT",
      "header_body": selectedHeader == null ? "" : selectedHeader.text,
      "message_body": selectedBody == null ? "" : selectedBody.text,
      "example_body_text": {"sendToAdmin": false},
      "footer": selectedFooter == null ? "" : selectedFooter.text,
      "buttons": [],
      "business_number": number
    };

    mstemp.createmsgtemplete(msgmobilbody: createtemp).then((value) => {
          templeteidmessage = value['id'],
          print("temmplet msg id==========>$templeteidmessage"),
          print("ccretae objetctt resposne= > $value"),
          mstemp
              .sendtemplete(
                  number: number,
                  msgmobilbody: templateBody,
                  tempCate: SelectedTemplateCategory)
              .then((value) {
            print("value=== templete>$value");
            print("value=== template>${value['messages'][0]['id']}");
            messageid = value['messages'][0]['id'];
            Map<String, dynamic> msghistorydata = {
              "parent_id": widget.id,
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

            print("body before sending::: ${msghistorydata}");
            mstemp.semdtempmsghistory(msghistorydata: msghistorydata).then(
                (value) =>
                    {print("semdtempmsghistorysemdtempmsghistory=>$value")});
          })
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
    print("leadnumber${leadnumber}");
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');
    print("number=>$number");
    await Provider.of<MessageViewModel>(context, listen: false)
        .Fetchmsghistorydata(leadnumber: leadnumber, number: number);
    await Future.delayed(const Duration(seconds: 1));
  }

  String tenatCode = "";
  Future<void> _getPhoneNumber() async {
    print("widget.wpnumber${widget.wpnumber}");
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName') ?? "Me";
    tenatCode = prefs.getString(SharedPrefsConstants.usertenantcodeKey) ?? "";
    setState(() {});
    String? number = prefs.getString('phoneNumber');
    print("widget.wpnumber${widget.wpnumber}");
    messageViewModel.Fetchmsghistorydata(
      leadnumber: widget.wpnumber ?? "",
      number: number,
    );
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
      allowedExtensions: [
        "jpg",
        "jpeg",
        "png",
        "gif",
        "pdf",
        "txt",
        "doc",
        "docx",
        "ppt",
        "pptx",
        "xls",
        "xlsx",
        "mp4",
        "csv",
      ],
    );
    if (pickedFile != null) {
      EasyLoading.showToast("Picked Successfully");
      setState(() {
        file = pickedFile.files.first;
        image = File(file!.path!);
        isImageSent = false;
        print("image::: ${image}");
        fileNameController.text = file!.name;
      });
    }
    Navigator.of(context).pop();
  }

  Future<File?> _pickImaFromGallery() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: [
        "jpg",
        'png',
      ],
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

  Future<void> _pickVideoFromGallery() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: [
        "mp4",
        'mov',
      ],
    );
    if (pickedFile != null) {
      setState(() {
        file = pickedFile.files.first;
        image = File(file!.path!);
        _Vcontroller = VideoPlayerController.file(image!);
        print("image::: ${image}");
        fileNameController.text = file!.name;
      });
    }
  }

  Future<void> _pickDocFromGallery() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: [
        "pdf",
      ],
    );
    if (pickedFile != null) {
      setState(() {
        file = pickedFile.files.first;
        image = File(file!.path!);
        // _Vcontroller = VideoPlayerController.file(image!);
        print("image::: ${image}");
        fileNameController.text = file!.name;
      });
    }
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

  void videosend(type, String? caps) async {
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
          "to": widget.wpnumber,
          "type": type,
          type: {"id": doucmentid, "caption": caps ?? "Caption"}
        };
        String? responseimage = await messageViewModel
            .uploadimagewithdoucmentid(bodyy: imagebody, number: number)
            .then((value) {
          print("video sedn video send send value----->$value");
          return null;
        });

        String? leadid = widget.id;
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
          "message": caps ?? "",
          "status": "Outgoing",
          "recordtypename": "lead",
          "file_id": fileid,
          // "caption": caps ?? "",
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
          setState(() {
            showLoader = false;
            image = null;
            getHistory();
          });
          print("\x1B[32msendhistoryimagesendhistoryimage$value\x1B[0m");
          return null;
        });
      } else {
        setState(() {
          showLoader = false;
          image = null;
          getHistory();
        });
        debugPrint('Image upload failed or response was null');
      }
    } else {
      setState(() {
        showLoader = false;
        image = null;
        getHistory();
      });
      debugPrint('No image selected');
    }
  }

  void filesend(String type) {
    print("typyp=>$type");
    if (type == "image") {
      imagesend(type, _controller.text.trim());
    } else if (type == "document" || type == "pdf") {
      documetsend(type, _controller.text.trim());
    } else if (type == "video") {
      print("SAdddddddddddddddddddddd");
      videosend(type, _controller.text.trim());
    } else {
      debugPrint("Unsupported file type: $type");
    }
  }

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

  void imagesend(String type, String? caps) async {
    print("woking....");
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    print("image:::::::::::::::::::::::::::    ${image}");
    if (image != null) {
      print("type===> image  $type");
      String? response = await messageViewModel.uploadFile(image!, number);

      if (response != null) {
        debugPrint('Image uploaded successfully, Response: $response');

        var jsonResponse = jsonDecode(response);
        String? doucmentid = jsonResponse['id'];

        debugPrint('Uploaded File ID: $doucmentid');
        debugPrint("widget.model.whatsapp_number${widget.wpnumber}");
        Map<String, dynamic> imagebody = {
          "messaging_product": "whatsapp",
          "recipient_type": "individual",
          "to": widget.wpnumber,
          "type": type,
          type: {"id": doucmentid, "caption": caps ?? "Image caption"}
        };
        print("ississiis=>$imagebody");
        String? responseimage = await messageViewModel
            .uploadimagewithdoucmentid(bodyy: imagebody, number: number)
            .then((value) {
          print("value----->$value");
          return null;
        });

        String? leadid = widget.id;
        print("leadid=>$leadid");

        String? sendimagedatabase = await messageViewModel
            .uploadFiledb(image!, number, leadid)
            .then((value) {
          print("value----upload dididi->${value}");

          Map<String, dynamic> response = jsonDecode(value);

          fileid = response['records']?[0]['id'];

          print("ID: $fileid");
          return null;
        });

        Map<String, dynamic> imagehistorydata = {
          "parent_id": leadid,
          "name": widget.leadName,
          "message_template_id": null,
          "whatsapp_number": widget.wpnumber,
          "message": caps ?? "",
          "status": "Outgoing",
          "recordtypename": "lead",
          "file_id": fileid,
          // "caption": caps ?? "",
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
          return null;
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
      getHistory();
      showLoader = false;
      image = null;
    });
  }

  void sendAudio(String type, String? caps) async {
    print("woking....");
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    print("image:::::::::::::::::::::::::::    ${_audioFile}");
    if (_audioFile != null) {
      print("type===> image  $type");
      String? response = await messageViewModel.uploadFile(_audioFile!, number);

      if (response != null) {
        debugPrint('Image uploaded successfully, Response: $response');

        var jsonResponse = jsonDecode(response);
        String? doucmentid = jsonResponse['id'];

        debugPrint('Uploaded File ID: $doucmentid');
        debugPrint("widget.model.whatsapp_number${widget.wpnumber}");
        Map<String, dynamic> imagebody = {
          "messaging_product": "whatsapp",
          "recipient_type": "individual",
          "to": widget.wpnumber,
          "type": type,
          type: {
            "id": doucmentid,
          }
        };
        print("ississiis=>$imagebody");
        String? responseimage = await messageViewModel
            .uploadimagewithdoucmentid(bodyy: imagebody, number: number)
            .then((value) {
          print("value----->$value");
          return null;
        });

        String? leadid = widget.id;
        print("leadid=>$leadid");

        String? sendimagedatabase = await messageViewModel
            .uploadFiledb(_audioFile!, number, leadid)
            .then((value) {
          print("value----upload dididi->${value}");

          Map<String, dynamic> response = jsonDecode(value);

          fileid = response['records']?[0]['id'];

          print("ID: $fileid");
          return null;
        });

        Map<String, dynamic> imagehistorydata = {
          "parent_id": leadid,
          "name": widget.leadName,
          "message_template_id": null,
          "whatsapp_number": widget.wpnumber,
          "message": caps ?? "",
          "status": "Outgoing",
          "recordtypename": "lead",
          "file_id": fileid,
          // "caption": caps ?? "",
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
          return null;
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
      getHistory();
      showLoader = false;
      image = null;
    });
  }

  void documetsend(type, String? caps) async {
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
          "to": widget.wpnumber,
          "type": type,
          type: {"id": doucmentid, "caption": caps ?? "Caption"}
        };
        String? responseimage = await messageViewModel
            .uploadimagewithdoucmentid(bodyy: imagebody, number: number)
            .then((value) {
          print("document send value----->$value");
          return null;
        });

        String? leadid = widget.id;
        print("document sned lead id=>$leadid");

        String? sendimagedatabase = await messageViewModel
            .uploadFiledb(image!, number, leadid)
            .then((value) {
          print("document send----upload dididi->${value}");

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
          "message": caps ?? "",
          "status": "Outgoing",
          "recordtypename": "lead",
          "file_id": fileid,
          // "caption": caps ?? "",
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
          return null;
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
      image = null;
      getHistory();
    });
  }

  Widget _pageBody() {
    print("all messages length::: ${allMessages.length}");
    return Consumer<MessageController>(
        builder: (context, msgController, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.pinnedLeads!.isEmpty
                      ? const SizedBox()
                      : const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8),
                          child: Text(
                            "Pinned Leads",
                            style: TextStyle(fontFamily: AppFonts.medium),
                          ),
                        ),
                  widget.pinnedLeads!.isEmpty
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Container(
                            height: 70,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.pinnedLeads!.length,
                                itemBuilder: (context, index) {
                                  var model = widget.pinnedLeads![index];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: InkWell(
                                      onTap: () async {
                                        Navigator.pop(context);
                                        var num = "";

                                        num = "${model.full_number}";

                                        print(
                                            "model  finalResult=>${model.full_number}");
                                        if (model.full_number != null) {
                                          _marksread(num);

                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ChatScreen(
                                                pinnedLeads:
                                                    widget.pinnedLeads!,
                                                leadName:
                                                    model.contactname ?? "",
                                                wpnumber: model.full_number,
                                                id: model.id,
                                                model: widget.model == null
                                                    ? null
                                                    : model,
                                              ),
                                            ),
                                          ).then((onValue) {
                                            _marksread(num);
                                            _getUnreadCount();
                                          });
                                          if (result == true) {
                                            print(
                                                "is result getting true.........?");
                                            _getUnreadCount();
                                            // getLeadList();
                                          }

                                          _getUnreadCount();
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          var number =
                                              prefs.getString('phoneNumber');
                                          Provider.of<UnreadCountVm>(context,
                                                  listen: false)
                                              .fetchunreadcount(
                                                  number: number ?? "");
                                          setState(() {
                                            // unreadMsgCount = "0";
                                            // unreadMsgCount = "";
                                          });

                                          // Provider.of<LeadListViewModel>(
                                          //         context,
                                          //         listen: false)
                                          //     .fetch();
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('No Phone Number '),
                                              duration: Duration(seconds: 3),
                                              backgroundColor:
                                                  AppColor.motivationCar1Color,
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        width: 60,
                                        child: Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor:
                                                  AppColor.navBarIconColor,
                                              child: Text(
                                                "${widget.pinnedLeads![index].contactname?.isNotEmpty == true ? widget.pinnedLeads![index].contactname![0].toUpperCase() : '?'}",
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              widget.pinnedLeads![index]
                                                  .contactname,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontFamily:
                                                      AppFonts.semiBold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      // color: Colors.amber,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (widget.model == null) {
                                  return;
                                }
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LeadDetailView(
                                      model: widget.model,
                                    ),
                                  ),
                                );

                                if (result == true) {
                                  print("result on detailesss:::: ");
                                  Navigator.pop(context, true);
                                }
                              },
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      'https://www.w3schools.com/w3images/avatar2.png',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * .5,
                                    child: Text(
                                      widget.leadName ?? "",
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontFamily: AppFonts.medium,
                                          color:
                                              Color.fromARGB(255, 59, 52, 52)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            msgController.msgToDelete.length > 0
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      _showSimpleDialog("");
                                    },
                                  )
                                : SizedBox(),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.black,
                              ),
                              onSelected: (String value) {
                                if (value == 'Clear Chat') {
                                  _showDeleteDialog();
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'Clear Chat',
                                  child: Text('Clear Chat'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(),
                    Expanded(
                      child: ListView.builder(
                          controller: _scrollController,
                          itemCount: allMessages.length,
                          itemBuilder: (context, index) {
                            log("allMessages[index].buttons:::::: ${allMessages[index].buttons}");
                            List butttons = [];
                            if (allMessages[index].buttons == null) {
                              butttons = [];
                            } else {
                              butttons = allMessages[index].buttons ?? [];
                            }
                            String result = "";
                            final regex = RegExp(r'\{\{\d+\}\}');
                            if (allMessages[index].messageBody != null &&
                                allMessages[index].bodyTextParams != null &&
                                regex
                                    .hasMatch(allMessages[index].messageBody)) {
                              result = replacePlaceholders(
                                  allMessages[index].messageBody ?? "",
                                  allMessages[index].bodyTextParams.toString());
                            } else if (allMessages[index].messageBody != null &&
                                allMessages[index].exampleBodyText != null &&
                                regex
                                    .hasMatch(allMessages[index].messageBody)) {
                              result = replacePlaceholders(
                                  allMessages[index].messageBody ?? "",
                                  allMessages[index].exampleBodyText ?? "");
                            } else {
                              result = allMessages[index].messageBody ?? "";
                            }

                            String imageUrl = "";

                            DateTime now = DateTime.now();
                            String formattedTime =
                                DateFormat('hh:mm a').format(now);

                            DateTime utcTime = allMessages[index].createddate;
                            DateTime istTimee = utcTime
                                .add(const Duration(hours: 5, minutes: 30));
                            formattedTime =
                                DateFormat('hh:mm a').format(istTimee);
                            bool isSameDay(DateTime? dateA, DateTime? dateB) {
                              return dateA?.year == dateB?.year &&
                                  dateA?.month == dateB?.month &&
                                  dateA?.day == dateB?.day;
                            }

                            String dayLabel = '';
                            if (isSameDay(istTimee, now)) {
                              dayLabel = 'Today';
                            } else if (isSameDay(istTimee,
                                now.subtract(const Duration(days: 1)))) {
                              dayLabel = 'Yesterday';
                            } else {
                              dayLabel =
                                  DateFormat('d MMMM yyyy').format(istTimee);
                            }

                            String finalFormattedTime = '$dayLabel';
                            // print(
                            //     "finalFormattedTime::: ${finalFormattedTime}  ${isSameDay}");
                            String title = allMessages[index].title ?? "";
                            String msghistoryid = allMessages[index].id;

                            if (title.isNotEmpty) {
                              imageUrl =
                                  "${AppConstants.baseImgUrl}public/${tenatCode}/attachment/$title";
                            }

                            bool showDateLabel = false;
                            if (index == 0) {
                              showDateLabel = true;
                            } else {
                              DateTime prevTime = allMessages[index - 1]
                                  .createddate
                                  .add(const Duration(hours: 5, minutes: 30));
                              if (!isSameDay(istTimee, prevTime)) {
                                showDateLabel = true;
                              }
                            }

                            return (allMessages[index].header == null &&
                                    allMessages[index].messageBody == null &&
                                    imageUrl.isEmpty &&
                                    (allMessages[index].message == null ||
                                        allMessages[index]
                                            .message
                                            .toString()
                                            .isEmpty))
                                ? SizedBox()
                                : Column(
                                    children: [
                                      if (showDateLabel)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 0),
                                          child: Center(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: const Color.fromARGB(
                                                      255, 169, 215, 236),
                                                  borderRadius:
                                                      BorderRadius.circular(6)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(6.0),
                                                child: Text(
                                                  finalFormattedTime,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              if (msgController
                                                  .msgToDelete.isNotEmpty) {
                                                msgController
                                                    .updateDeleteMsgList(
                                                        allMessages[index].id ??
                                                            "");
                                              }
                                            },
                                            onLongPress: () {
                                              msgController.updateDeleteMsgList(
                                                  allMessages[index].id ?? "");
                                            },
                                            child: Container(
                                              color: msgController.msgToDelete
                                                      .contains(
                                                          allMessages[index].id)
                                                  ? Color(0xffAFAFAF)
                                                  : Colors.transparent,
                                              child: Row(
                                                mainAxisAlignment:
                                                    allMessages[index].status ==
                                                            "Incoming"
                                                        ? MainAxisAlignment
                                                            .start
                                                        : MainAxisAlignment.end,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 2.0),
                                                    child: Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 5),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8),
                                                      child: Align(
                                                        alignment:
                                                            _getAlignment(
                                                                allMessages[
                                                                        index]
                                                                    .status),
                                                        child: Column(
                                                          crossAxisAlignment: allMessages[
                                                                          index]
                                                                      .status ==
                                                                  "Outgoing"
                                                              ? CrossAxisAlignment
                                                                  .end
                                                              : CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            if (index == 0 ||
                                                                allMessages[index]
                                                                        .status !=
                                                                    allMessages[
                                                                            index -
                                                                                1]
                                                                        .status ||
                                                                allMessages[index]
                                                                        .name !=
                                                                    allMessages[
                                                                            index -
                                                                                1]
                                                                        .name)
                                                              Text(
                                                                allMessages[index]
                                                                            .status ==
                                                                        "Incoming"
                                                                    ? allMessages[
                                                                            index]
                                                                        .name
                                                                    : userName,
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                              ),
                                                            IntrinsicWidth(
                                                              child: Container(
                                                                constraints:
                                                                    BoxConstraints(
                                                                  minWidth: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.25,
                                                                  maxWidth: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.65,
                                                                ),
                                                                margin: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        4),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: allMessages[index]
                                                                              .status ==
                                                                          "Outgoing"
                                                                      ? const Color(
                                                                          0xffE3FFC9)
                                                                      : const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          179,
                                                                          238,
                                                                          243),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(
                                                                    topLeft:
                                                                        const Radius
                                                                            .circular(
                                                                            12),
                                                                    topRight:
                                                                        const Radius
                                                                            .circular(
                                                                            12),
                                                                    bottomLeft: allMessages[index].status ==
                                                                            "Outgoing"
                                                                        ? const Radius
                                                                            .circular(
                                                                            12)
                                                                        : Radius
                                                                            .zero,
                                                                    bottomRight: allMessages[index].status ==
                                                                            "Outgoing"
                                                                        ? Radius
                                                                            .zero
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
                                                                      blurRadius:
                                                                          4,
                                                                      offset:
                                                                          const Offset(
                                                                              2,
                                                                              2),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    if (imageUrl
                                                                        .isNotEmpty)
                                                                      _buildAttachmentWidget(
                                                                          imageUrl),
                                                                    if (allMessages[index].header !=
                                                                            null &&
                                                                        imageUrl
                                                                            .isEmpty)
                                                                      _buildHeaderMedia(
                                                                          allMessages[index]
                                                                              .header!,
                                                                          allMessages[index]
                                                                              .headerBody),
                                                                    if (allMessages[index].message !=
                                                                            null &&
                                                                        allMessages[index]
                                                                            .message!
                                                                            .isNotEmpty)
                                                                      Text(
                                                                        allMessages[index]
                                                                            .message!,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            height:
                                                                                1.5),
                                                                        maxLines:
                                                                            4,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    if (allMessages[index]
                                                                            .messageBody !=
                                                                        null)
                                                                      Text(
                                                                          '${result}'),
                                                                    // const SizedBox(
                                                                    //     height: 5),
                                                                    if (allMessages[index]
                                                                            .description !=
                                                                        null)
                                                                      Text(allMessages[
                                                                              index]
                                                                          .description),
                                                                    SizedBox(
                                                                        height: allMessages[index].description !=
                                                                                null
                                                                            ? 5
                                                                            : 0),
                                                                    if (allMessages[index]
                                                                            .footer !=
                                                                        null)
                                                                      Text(
                                                                        allMessages[index]
                                                                            .footer!,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.grey),
                                                                      ),
                                                                    if (allMessages[index]
                                                                            .erormessage !=
                                                                        null)
                                                                      Text(
                                                                        allMessages[index]
                                                                            .erormessage!,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.red),
                                                                      ),
                                                                    if (butttons
                                                                        .isNotEmpty)
                                                                      _buildButtons(
                                                                          butttons),
                                                                    (allMessages[index].status ==
                                                                            "Outgoing")
                                                                        ? Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              Text(
                                                                                formattedTime,
                                                                                style: const TextStyle(
                                                                                  // fontWeight:
                                                                                  //     FontWeight.bold,
                                                                                  fontSize: 12,
                                                                                  color: Colors.black45,
                                                                                ),
                                                                              ),
                                                                              Icon(
                                                                                Icons.done_all,
                                                                                color: allMessages[index].deliveryStatus == "read" ? Colors.green : Colors.grey,
                                                                                size: 18,
                                                                              ),
                                                                            ],
                                                                          )
                                                                        : Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              Text(
                                                                                formattedTime,
                                                                                style: const TextStyle(
                                                                                  // fontWeight:
                                                                                  //     FontWeight.bold,
                                                                                  fontSize: 12,
                                                                                  color: Colors.black45,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )),
                                    ],
                                  );
                          }),
                    ),
                  ],
                ),
              ),
            ),
            _buildMessageInputArea(),
          ],
        ),
      );
    });
  }

  void singlemsgdelete(List idsToDelete) async {
    print("Single delete attempt for message with ID: $idsToDelete");

    // if (msghistoryid.isEmpty) {
    //   print("Invalid message ID. Cannot delete.");
    //   return;
    // }
    // var msghistoryidd = msghistoryid;
    // print("sdhsdhjdhjsdhfdks=>$msghistoryidd");

    var bodyy = jsonEncode({"ids": idsToDelete});

    print("Request hdshsd jhds body: $bodyy");
    MessageViewModel msgdelete = MessageViewModel(context);
    msgdelete.singlemsgdelete(bodyy).then((value) async {
      var leadnumber = widget.wpnumber;
      final prefs = await SharedPreferences.getInstance();
      String? number = prefs.getString('phoneNumber');
      print("number=>$number");
      await Provider.of<MessageViewModel>(context, listen: false)
          .Fetchmsghistorydata(leadnumber: leadnumber, number: number);
      // Navigator.of(context).pop();
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text("deleted sucefully"),
      //   backgroundColor: Colors.green,
      // )
      // );
      EasyLoading.showToast("Deleted Succeffuly");

      MessageController msgController =
          Provider.of<MessageController>(context, listen: false);
      msgController.clearDeleteList();

      print("Delete single message successfully");
    }).catchError((error) {
      print("Error deleting message: $error");
    });
  }

  Alignment _getAlignment(String? status) {
    return status == "Outgoing" ? Alignment.centerRight : Alignment.centerLeft;
  }

  Widget _buildMessageInputArea() {
    messageViewModel = Provider.of<MessageViewModel>(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 0.0, left: 0, right: 0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            if (_isRecording)
              const Row(
                children: [
                  Icon(Icons.fiber_manual_record, color: Colors.red),
                  SizedBox(width: 6),
                  Text("Recording..."),
                ],
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: _showPicker,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        if (image != null && !isImageSent)
                          _buildFilePreview(image!),
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
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Listener(
                      onPointerDown: (_) => _startRecording(setState, context),
                      onPointerUp: (_) => _stopRecording(setState),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 168, 205, 235),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic_none_sharp,
                          color: _isRecording ? Colors.red : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff8BBCD0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.code, color: Colors.white),
                        onPressed: () {
                          WalletController wc =
                              Provider.of(context, listen: false);
                          wc.setFinalAmt("");
                          _getBootmSheet();
                        },
                      ),
                    ),
                  ),
                  if (allMessages.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 76, 162, 189),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: showLoader
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send_rounded,
                                  color: Colors.white),
                              onPressed: _handleSendMessage,
                            ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSimpleDialog(String id) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
          backgroundColor: Colors.white,
          title: const Text(
            'Delete Message?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this message?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                MessageController msgController =
                    Provider.of<MessageController>(context, listen: false);

                msgController.clearDeleteList();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                    fontSize: 14,
                    color: AppColor.navBarIconColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                print("mmms=>${msghistoryid}");
                MessageController msgController =
                    Provider.of<MessageController>(context, listen: false);
                singlemsgdelete(msgController.msgToDelete);
                Navigator.of(context).pop(); // Close dialog after deletion
              },
              child: const Text(
                "Delete",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
    ;
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
              // print("Record template Status: ${record.name}");
              setState(() {
                templateNames.add(record.name);
                // print("Templates => $templateNames");
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

    if (templeteViewModel.viewModels.isNotEmpty) {
      for (var viewModel in templeteViewModel.viewModels) {
        var campaignModel = viewModel.model;
        if (campaignModel?.data != null) {
          for (var record in campaignModel!.data!) {
            if (record.status != null) {
              // print("rec name ::${record.name}  ${selectedTemplateName}");
              if (selectedTemplateName == record.name) {
                currentTemplate = record;
                selectedTemplateId = currentTemplate.id;
                selectedLanguage = currentTemplate.language;

                if (hasWallet) {
                  WalletController walletController =
                      Provider.of(context, listen: false);

                  if (widget.model == null) {
                    walletController.calculateAmount(
                        currentTemplate.category, widget.contryCode ?? "+91");
                  } else {
                    walletController.calculateAmount(currentTemplate.category,
                        widget.model?.countryCode ?? "");
                  }
                }

                log("current template:::  ${currentTemplate.category}   :: ${currentTemplate}  ${currentTemplate.name}");
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
        selectedHeader.example != null &&
        selectedHeader.example.headerHandle != null &&
        selectedHeader.example.headerHandle.isNotEmpty) {
      print("selectedHeader>>> ${selectedHeader.example.headerHandle}");
      imgToShow = selectedHeader.example.headerHandle[0];
    } else {
      imgToShow = "";
    }

    // print("selectedHeader.format>>>> ${selectedHeader.format}");

    final regex = RegExp(r'\{\{\d+\}\}');
    final matches = regex.allMatches(text).map((e) => e.group(0)).toSet();
    int count = matches.length;
    // int count = regex.allMatches(text).length;
    file = null;
    fileid = null;
    controllers = List.generate(count, (index) => TextEditingController());
    bool isOtherFileSelected = false;
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      enableDrag: false,
      elevation: 1,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _isLoading = false;
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
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Align content properly
                              children: [
                                // Handle different formats (IMAGE, VIDEO, DOCUMENT)
                                if (selectedHeader != null &&
                                    selectedHeader.format != null)
                                  file != null &&
                                          selectedHeader.format == 'IMAGE'
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
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
                                            print(
                                                "Button ${index + 1} clicked");
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
                                                color:
                                                    AppColor.navBarIconColor),
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
                                      : const SizedBox(),
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
                        const SizedBox(height: 10),
                        Center(
                          child: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
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

                                  try {
                                    Map<String, String> bodyTextParams = {};
                                    List compoTextParams = [];
                                    List numberedCampParam = [];

                                    bool anyEmpty = controllers.any(
                                        (controller) =>
                                            controller.text.isEmpty);
                                    if (anyEmpty) {
                                      EasyLoading.showToast(
                                          'All fields are required');
                                      return;
                                    }

                                    File? imageFile;
                                    String docId = "";

                                    for (int i = 0;
                                        i < controllers.length;
                                        i++) {
                                      bodyTextParams[(i + 1).toString()] =
                                          controllers[i].text;
                                      Map body = {
                                        "type": "text",
                                        "text": controllers[i].text,
                                      };
                                      compoTextParams.add(body);
                                      numberedCampParam.add(bodyTextParams);
                                    }

                                    String templateToSend =
                                        selectedTemplateName ??
                                            _templateController.text;

                                    if (selectedHeader == null) {
                                      await sendTextTemplate(
                                        templateToSend,
                                        compoTextParams,
                                        isChecked,
                                        bodyTextParams,
                                      );
                                      return;
                                    }

                                    if (selectedHeader.format == "IMAGE" ||
                                        selectedHeader.format == "VIDEO") {
                                      if (!isOtherFileSelected) {
                                        EasyLoading.showToast(
                                            "Choose File To Continue");
                                        return;
                                      }

                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      String? number =
                                          prefs.getString('phoneNumber');
                                      String? leadid = widget.id;

                                      await messageViewModel
                                          .uploadFiledb(image!, number, leadid)
                                          .then((value) async {
                                        Map<String, dynamic> response =
                                            jsonDecode(value);
                                        fileid = response['records']?[0]['id'];
                                      });

                                      await sendParamsApiCall(
                                        templateToSend,
                                        compoTextParams,
                                        isChecked,
                                        bodyTextParams,
                                        imgToShow,
                                      );

                                      String? numberr =
                                          prefs.getString('phoneNumber');
                                      String? leadnumber = widget.wpnumber;

                                      await Provider.of<MessageViewModel>(
                                              context,
                                              listen: false)
                                          .Fetchmsghistorydata(
                                              leadnumber: leadnumber,
                                              number: number);
                                    } else if (selectedHeader.format ==
                                        "DOCUMENT") {
                                      if (isOtherFileSelected == true) {
                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        String? number =
                                            prefs.getString('phoneNumber');
                                        String? leadid = widget.id;

                                        await messageViewModel
                                            .uploadFiledb(
                                                image!, number, leadid)
                                            .then((value) {
                                          Map<String, dynamic> response =
                                              jsonDecode(value);
                                          fileid =
                                              response['records']?[0]['id'];
                                        });
                                      }

                                      await sendDocTemp(
                                        templateToSend,
                                        isChecked,
                                        imgToShow,
                                        bodyTextParams,
                                        compoTextParams,
                                        isOtherFileSelected,
                                        fileid,
                                      );

                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      String? number =
                                          prefs.getString('phoneNumber');
                                      String? leadnumber = widget.wpnumber;

                                      await Provider.of<MessageViewModel>(
                                              context,
                                              listen: false)
                                          .Fetchmsghistorydata(
                                              leadnumber: leadnumber,
                                              number: number);
                                    } else if (selectedHeader.format ==
                                        "TEXT") {
                                      await sendTextTemplate(
                                        templateToSend,
                                        compoTextParams,
                                        isChecked,
                                        bodyTextParams,
                                      );

                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      String? number =
                                          prefs.getString('phoneNumber');
                                      String? leadnumber = widget.wpnumber;

                                      await Provider.of<MessageViewModel>(
                                              context,
                                              listen: false)
                                          .Fetchmsghistorydata(
                                              leadnumber: leadnumber,
                                              number: number);
                                    }
                                  } finally {
                                    if (hasWallet) {
                                      WalletController walletController =
                                          Provider.of(context, listen: false);
                                      walletController.debitWalletBalApiCall();
                                    }

                                    getHistory();

                                    setState(() {
                                      image = null;
                                      _isLoading = false;
                                    });

                                    Navigator.pop(context);
                                  }
                                },
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        "Send Template",
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.white),
                                      ),
                              );
                            },
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
    SelectedTemplateCategory = null;
    selectedTemplateName = null;
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

                        _setSelectedTemplates();
                      },
                      value: selectedTemplateName,
                    ),
                    hasWallet
                        ? Consumer<WalletController>(
                            builder: (context, wltController, child) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Cost : ${wltController.finalAmount}"),
                                ],
                              ),
                            );
                          })
                        : SizedBox(),
                    Center(
                      child: Consumer<WalletController>(
                          builder: (context, ref, child) {
                        return ElevatedButton(
                          style: ButtonStyle(
                            minimumSize:
                                WidgetStateProperty.all(const Size(10, 20)),
                            padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10)),
                            backgroundColor: WidgetStateProperty.all(
                                AppColor.navBarIconColor),
                          ),
                          onPressed: () {
                            print(
                                "hasBalance::      ::: hasWallet    ::::::   :::::  ${ref.hasBalance}      ${hasWallet}");
                            if ((hasWallet && ref.hasBalance) ||
                                hasWallet == false) {
                              print(
                                  "selectedTemplateName>>> ${selectedTemplateName}");
                              if (selectedTemplateName == null ||
                                  selectedTemplateName ==
                                      "Select Template Name") {
                                EasyLoading.showToast("Select Template Name");
                                return;
                              }
                              log("all comp info >> >>  ${selectedHeader}  ${selectedBody} ${selectedFooter} ${selectedButtons}}");
                              log("selectedBody['text']>>> ${selectedBody.text}  ");
                              final regex = RegExp(r'\{\{\d+\}\}');

                              if (regex.hasMatch(selectedBody.text)) {
                                Navigator.of(context).pop();
                                _sendTemplateSheet();
                              } else if (selectedHeader == null ||
                                  selectedHeader.format == null) {
                                String templateToSend = selectedTemplateName ??
                                    _templateController.text;
                                print("Template to send: $templateToSend");
                                templetesendd(templateToSend, []);
                                Navigator.of(context).pop();
                              } else {
                                if (regex.hasMatch(selectedBody.text) ||
                                    selectedHeader.format != null ||
                                    selectedHeader.format != "TEXT") {
                                  Navigator.of(context).pop();
                                  _sendTemplateSheet();
                                } else {
                                  String templateToSend =
                                      selectedTemplateName ??
                                          _templateController.text;
                                  print("Template to send: $templateToSend");
                                  templetesendd(templateToSend, []);
                                  if (hasWallet) {
                                    WalletController walletController =
                                        Provider.of(context, listen: false);
                                    walletController.debitWalletBalApiCall();
                                  }
                                  Navigator.of(context).pop();
                                }
                              }
                            } else {
                              EasyLoading.showToast("Insufficient Balance");
                            }
                          },
                          child: const Text(
                            "Send",
                            style: TextStyle(fontSize: 13, color: Colors.white),
                          ),
                        );
                      }),
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

  Future<void> sendParamsApiCall(
    String templateToSend,
    List compoTextParams,
    bool sendOnLoginNum,
    Map campaignParam,
    String imgToShow,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    Map<String, dynamic> exBodyText = {
      if (campaignParam.isNotEmpty) ...campaignParam,
      "sendToAdmin": sendOnLoginNum
    };

    MessageViewModel mstemp = MessageViewModel(context);
    TempleteListViewModel templeteViewModel =
        Provider.of<TempleteListViewModel>(context, listen: false);
    print(
        "selectedButtons?       ${selectedButtons} .buttons>>${selectedButtons?.buttons}");
    List ba =
        selectedButtons?.buttons.map((button) => button.toMap()).toList() ?? [];
    String footer = selectedFooter?.text ?? "";

    Map<String, dynamic> createtemp = {
      "id": selectedTemplateId,
      "name": templateToSend,
      "language": selectedLanguage,
      "header": selectedHeader == null ? "" : selectedHeader.format,
      "header_body": imgToShow.isNotEmpty ? imgToShow : selectedHeader.text,
      "message_body": selectedBody == null ? "" : selectedBody.text,
      "example_body_text": exBodyText,
      "footer": footer,
      "buttons": ba,
      "business_number": number
    };

    print("create map>>> $createtemp");

    // Await template creation
    var templateResponse =
        await mstemp.createmsgtemplete(msgmobilbody: createtemp);
    String templeteidmessage = templateResponse['id'];

    print("temmplet msg id==========> $templeteidmessage");
    print("create object response=> $templateResponse");
    var docId = await getDocId();

    List params = [
      {
        "type": selectedHeader.format == "IMAGE" ? "image" : "video",
        if (selectedHeader.format == "IMAGE")
          "image": {"id": docId}
        else
          "video": {"id": docId},
      }
    ];
    var leadnumber = widget.wpnumber;
    Map<String, dynamic> templateBody = {
      "messaging_product": "whatsapp",
      "to": leadnumber,
      "type": "template",
      "template": {
        "name": templateToSend,
        "language": {"code": selectedLanguage},
        "components": [
          {"type": "header", "parameters": params},
          {"type": "body", "parameters": compoTextParams}
        ]
      }
    };

    if (SelectedTemplateCategory == "AUTHENTICATION") {
      List cp = templateBody["template"]["components"];
      cp.add({
        "type": "button",
        "sub_type": "url",
        "index": "0",
        "parameters": compoTextParams
      });
    }
    ;

    print("template body=>$templateBody");

    // Await template sending
    var sendTemplateResponse = await mstemp.sendtemplete(
        number: number,
        msgmobilbody: templateBody,
        tempCate: SelectedTemplateCategory);
    print("sendTemplateResponse>>>>>>> ${sendTemplateResponse}");
    String messageid = sendTemplateResponse['messages'][0]["id"] ?? "";

    print("value=== template>$sendTemplateResponse");

    Map<String, dynamic> msgmobilebody = {
      "parent_id": widget.id,
      "name": widget.leadName,
      "message_template_id": templeteidmessage,
      "whatsapp_number": leadnumber,
      "message": "",
      "status": "Outgoing",
      "recordtypename": "recentlyMessage",
      "file_id": fileid,
      "is_read": true,
      "business_number": number,
      "message_id": messageid,
      "interactive_id": null
    };

    // Await message sending
    var msgMobileResponse =
        await mstemp.sendmsgmobile(msgmobilbody: msgmobilebody);
    print("valueee1=>$msgMobileResponse");

    String msgResId = msgMobileResponse['id'];

    Map<String, dynamic> paramBody = {
      "campaign_id": null,
      "body_text_params": campaignParam,
      "msg_history_id": msgResId,
      "file_id": fileid,
      "whatsapp_number_admin": "7590889022"
    };

    // Await campaign parameter sending
    var campaignResponse = await mstemp.sendCampParam(campParambody: paramBody);
    print("sendCampParam>>> $campaignResponse");
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
                    borderRadius: BorderRadius.circular(8)),
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
                    Image.asset(
                      "assets/images/doc.png",
                      height: 120,
                      width: 120,
                    ),
                  ],
                ),
              )
            : const SizedBox();

      default:
        return const SizedBox();
    }
  }

  Future<void> sendDocTemp(
      String tempToSend,
      bool isChecked,
      String docUrl,
      Map campaignParam,
      List compoTextParams,
      bool otherFileSeletect,
      var fileId) async {
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    MessageViewModel mstemp = MessageViewModel(context);
    TempleteListViewModel templeteViewModel =
        Provider.of<TempleteListViewModel>(context, listen: false);

    List ba = [];
    if (selectedButtons != null) {
      print("list:::: ${selectedButtons.buttons} ");
      ba = selectedButtons.buttons.map((button) => button.toMap()).toList();
    }

    Map exBodyText = {};
    Map a = {"sendToAdmin": isChecked};
    Map b = campaignParam;
    if (campaignParam.isNotEmpty) {
      exBodyText = {...b, ...a};
    } else {
      exBodyText = a;
    }
    Map<String, dynamic> createtemp = {
      "id": selectedTemplateId,
      "name": tempToSend,
      "language": selectedLanguage,
      "header": selectedHeader == null ? "" : selectedHeader.format,
      "header_body": docUrl,
      "message_body": selectedBody == null ? "" : selectedBody.text,
      "example_body_text": exBodyText,
      "footer": selectedFooter == null ? "" : selectedFooter.text,
      "buttons": ba,
      "business_number": number
    };

    try {
      var templateResponse =
          await mstemp.createmsgtemplete(msgmobilbody: createtemp);
      templeteidmessage = templateResponse['id'];
      print("Template message ID: $templeteidmessage");
      String fileId = "";
      if (otherFileSeletect == false) {
        Map<String, dynamic> url = {"url": docUrl};
        fileId = await mstemp.sendProxy(fileProxyBody: url, number: number);
        print("Proxy response: $fileId");
      } else {
        var res = await messageViewModel.uploadFile(image!, number);
        print("res>>>>> ${res}   ${res.runtimeType}  ${jsonDecode(res)} }");
        var rs = jsonDecode(res);
        print("rs:::: ${rs}   ${rs["id"]}");
        // fileId = res["id"].toString();
        fileId = rs["id"];
      }
      print("fileId>>> ${fileId}");

      var leadnumber = widget.wpnumber;
      Map<String, dynamic> templateBody = {
        "messaging_product": "whatsapp",
        "to": leadnumber,
        "type": "template",
        "template": {
          "name": tempToSend,
          "language": {"code": selectedLanguage},
          "components": [
            {
              "type": "header",
              "parameters": [
                {
                  "type": "document",
                  "document": {"id": fileId}
                }
              ],
            },
            {"type": "body", "parameters": compoTextParams}
          ]
        }
      };
      if (SelectedTemplateCategory == "AUTHENTICATION") {
        List cp = templateBody["template"]["components"];
        cp.add({
          "type": "button",
          "sub_type": "url",
          "index": "0",
          "parameters": []
        });
      }
      ;

      var templateSendResponse = await mstemp.sendtemplete(
          number: number,
          msgmobilbody: templateBody,
          tempCate: SelectedTemplateCategory);
      print("Template send response: $templateSendResponse");

      messageid = templateSendResponse['messages'][0]['id'];

      Map<String, dynamic> msgmobilebody = {
        "parent_id": widget.id,
        "name": widget.leadName,
        "message_template_id": templeteidmessage,
        "whatsapp_number": leadnumber,
        "message": "",
        "status": "Outgoing",
        "recordtypename": "recentlyMessage",
        "file_id": fileid,
        "is_read": true,
        "business_number": number,
        "message_id": messageid,
        "interactive_id": null
      };

      var msgMobileResponse =
          await mstemp.sendmsgmobile(msgmobilbody: msgmobilebody);
      print("Message mobile response: $msgMobileResponse");

      String msgResId = msgMobileResponse['id'];

      Map<String, dynamic> paramBody = {
        "campaign_id": null,
        "msg_history_id": msgResId,
        "file_id": null,
        "whatsapp_number_admin": "7590889022"
      };

      var campParamResponse =
          await mstemp.sendCampParam(campParambody: paramBody);
      print("Campaign Param Response: $campParamResponse");
    } catch (e) {
      print("Error in sendDocTemp: $e");
    }
  }

  Future<void> sendTextTemplate(
    String templateToSend,
    List compoTextParams,
    bool sendOnLoginNum,
    Map campaignParam,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    late MessageViewModel mstemp = MessageViewModel(context);

    List ba = [];
    if (selectedButtons != null) {
      print("list:::: ${selectedButtons.buttons} ");
      ba = selectedButtons.buttons.map((button) => button.toMap()).toList();
    }
    var footer;
    if (selectedFooter != null) {
      footer = selectedFooter.text;
    } else {
      footer = "";
    }
    List cp = [];
    Map exBodyText = {};
    Map a = {"sendToAdmin": sendOnLoginNum};
    Map b = campaignParam;
    if (campaignParam.isNotEmpty) {
      exBodyText = {...b, ...a};
    } else {
      exBodyText = a;
    }

    Map<String, dynamic> createtemp = {
      "id": selectedTemplateId,
      "name": templateToSend,
      "language": selectedLanguage,
      "header": selectedHeader == null ? "" : selectedHeader.format,
      "header_body": selectedHeader == null ? "" : selectedHeader.text,
      "message_body": selectedBody == null ? "" : selectedBody.text,
      "example_body_text": exBodyText,
      "footer": footer,
      "buttons": ba,
      "business_number": number
    };

    print("create map>>> ${createtemp}");
    Map<String, dynamic> templateBody = {};
    var leadnumber = widget.wpnumber;
    mstemp.createmsgtemplete(msgmobilbody: createtemp).then((value) => {
          templeteidmessage = value['id'],
          print("temmplet msg id==========>$templeteidmessage"),
          print("ccretae objetctt resposne= > $value"),
          templateBody = {
            "messaging_product": "whatsapp",
            "to": leadnumber,
            "type": "template",
            "template": {
              "name": templateToSend,
              "language": {"code": selectedLanguage},
              "components": [
                {
                  "type": "header",
                  "parameters": [],
                },
                {"type": "body", "parameters": compoTextParams}
              ]
            }
          },
          if (SelectedTemplateCategory == "AUTHENTICATION")
            {
              cp = templateBody["template"]["components"],
              cp.add({
                "type": "button",
                "sub_type": "url",
                "index": "0",
                "parameters": compoTextParams
              }),
            },
          mstemp
              .sendtemplete(
                  number: number,
                  msgmobilbody: templateBody,
                  tempCate: SelectedTemplateCategory)
              .then((value) {
            print("value=== templete>$value");
            // print("value=== template>${value['messages'][0]['id']}");
            messageid = value['messages'][0]['id'];

            Map<String, dynamic> msgmobilebody = {
              "parent_id": widget.id,
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
            mstemp.sendmsgmobile(msgmobilbody: msgmobilebody);
          })
        });
  }

  String replacePlaceholders(String messageBody, String? bodyTextParamsString) {
    print("bodyTextParamsString:::::::::::::: $bodyTextParamsString");

    if (bodyTextParamsString == null || bodyTextParamsString.isEmpty) {
      return messageBody;
    }

    try {
      // Convert Dart-style map string to JSON-style string
      final fixedString = bodyTextParamsString
          .replaceAllMapped(RegExp(r'(\w+):'), (match) => '"${match[1]}":')
          .replaceAllMapped(RegExp(r':\s*([^,}]+)'), (match) {
        final value = match[1]!.trim();
        // If it's already quoted, number, or boolean/null, keep as is
        if (value.startsWith('"') ||
            value == 'null' ||
            value == 'true' ||
            value == 'false' ||
            num.tryParse(value) != null) {
          return ': $value';
        }
        return ': "$value"'; // wrap in quotes if plain word
      });

      final Map<String, dynamic> params = jsonDecode(fixedString);

      params.forEach((key, value) {
        messageBody = messageBody.replaceAll('{{$key}}', value.toString());
      });
    } catch (e) {
      print('Error decoding or replacing placeholders: $e');
    }

    return messageBody;
  }

  Widget _buildAttachmentWidget(String url) {
    String fileType = url.split('.').last.toLowerCase();
    print("printing:: file type::: ${fileType}");
    switch (fileType) {
      case 'pdf':
        return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewPdf(
                            pdfUrl: url,
                          )));
            },
            child: Image.asset("assets/images/pdf.png",
                height: 120, width: MediaQuery.of(context).size.width * 0.65));

      case 'docx':
      case 'doc':
        return InkWell(
            onTap: () {
              openDocument(context, url);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => OpenAllDocs(
              //               url: url,
              //             )));
            },
            child: Image.asset("assets/images/doc.png",
                height: 120, width: MediaQuery.of(context).size.width * 0.65));

      case 'pptx':
      case 'ppt':
        return InkWell(
            onTap: () {
              openDocument(context, url);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => OpenAllDocs(
              //               url: url,
              //             )));
            },
            child: Image.asset("assets/images/powerpoint.png",
                height: 120, width: MediaQuery.of(context).size.width * 0.65));

      case 'xlsx':
      case 'xls':
        return InkWell(
            onTap: () {
              openDocument(context, url);
            },
            child: Image.asset("assets/images/excel.png",
                height: 120, width: MediaQuery.of(context).size.width * 0.65));

      case 'mp4':
        return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewVideo(
                            videoUrl: url,
                          )));
            },
            child: _buildVideoPlaceholder());

      case 'aac':
        return InkWell(
          onTap: () async {
            showDialog(
              context: context,
              builder: (context) => AudioDialog(audioUrl: url),
            );
          },
          child: Container(
            height: 60,
            width: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(
              color: Colors.deepOrangeAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      _isPlaying
                          ? Icons.spatial_audio_off_rounded
                          : Icons.headphones,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case 'png':
      case 'jpg':
      case 'jpeg':
        return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PreviewImage(
                            imgUrl: url,
                          )));
            },
            child: CachedNetworkImage(
              imageUrl: url,
              height: 120,
              width: MediaQuery.of(context).size.width * 0.65,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image),
            )

            //  Image.network(url,
            //     height: 120,
            //     width: MediaQuery.of(context).size.width * 0.65,
            //     fit: BoxFit.cover)

            );
      default:
        return InkWell(
            onTap: () {
              openDocument(context, url);
            },
            child: Image.asset("assets/images/file.png",
                height: 120, width: MediaQuery.of(context).size.width * 0.65));
    }
  }

// Video placeholder widget
  Widget _buildVideoPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Container(
        height: 120,
        width: MediaQuery.of(context).size.width * 0.65,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildHeaderMedia(String header, String headerBody) {
    switch (header) {
      case "IMAGE":
        return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PreviewImage(
                            imgUrl: headerBody,
                          )));
              // showDialog(
              //   context: context,
              //   builder: (BuildContext context) {
              //     return AlertDialog(
              //       title: const Text("Image Details"),
              //       content: Column(
              //         mainAxisSize: MainAxisSize.min,
              //         children: [
              //           Image.network(
              //             headerBody,
              //             height: 300,
              //             width: 300,
              //             fit: BoxFit.cover,
              //             loadingBuilder: (BuildContext context, Widget child,
              //                 ImageChunkEvent? loadingProgress) {
              //               if (loadingProgress == null) {
              //                 return child;
              //               } else {
              //                 return Center(
              //                   child: CircularProgressIndicator(
              //                     value: loadingProgress.expectedTotalBytes !=
              //                             null
              //                         ? loadingProgress.cumulativeBytesLoaded /
              //                             (loadingProgress.expectedTotalBytes ??
              //                                 1)
              //                         : null,
              //                   ),
              //                 );
              //               }
              //             },
              //             errorBuilder: (context, error, stackTrace) {
              //               return const SizedBox.shrink();
              //             },
              //           ),
              //         ],
              //       ),
              //       actions: <Widget>[
              //         TextButton(
              //           onPressed: () {
              //             Navigator.of(context).pop();
              //           },
              //           child: Container(
              //             padding: const EdgeInsets.symmetric(
              //                 vertical: 8, horizontal: 16),
              //             decoration: BoxDecoration(
              //               color: AppColor.navBarIconColor,
              //               borderRadius: BorderRadius.circular(8),
              //             ),
              //             child: const Text(
              //               "Close",
              //               style: TextStyle(
              //                 color: Colors.white,
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     );
              //   },
              // );
            },
            child: CachedNetworkImage(
              imageUrl: headerBody,
              height: 120,
              width: MediaQuery.of(context).size.width * 0.65,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image),
            ));
      case "VIDEO":
        return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewVideo(
                            videoUrl: headerBody,
                          )));
            },
            child: _buildVideoPlaceholder());

      case "DOCUMENT":
        return InkWell(
          onTap: () {
            try {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewPdf(
                            pdfUrl: headerBody,
                          )));
            } catch (e) {
              print("erorore opening file>>> ${e}");
            }
          },
          child: Image.asset(
            "assets/images/doc.png",
            height: 120,
            width: 120,
          ),
        );
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildButtons(List<dynamic> buttons) {
    return Wrap(
      spacing: 10,
      children: buttons.map((button) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  if (button['type'] == "PHONE_NUMBER") {
                    final Uri phoneUri =
                        Uri.parse("tel:${button['phone_number']}");
                    if (await canLaunchUrl(phoneUri)) await launchUrl(phoneUri);
                  } else if (button['type'] == "URL") {
                    final Uri url = Uri.parse(button['url']);

                    if (!await launchUrl(url,
                        mode: LaunchMode.externalApplication)) {
                      throw Exception('Could not launch $url');
                    }
                  }
                  print("Button clicked: ${button['text']}");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side:
                        BorderSide(color: AppColor.navBarIconColor, width: 1.5),
                  ),
                ),
                child: Text(
                  button['text'] ?? "",
                  style: TextStyle(
                    color: AppColor.navBarIconColor,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> getHistory() async {
    var leadnumber = widget.wpnumber;
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');
    print("number=>$number");
    if (!mounted) return;
    await Provider.of<MessageViewModel>(context, listen: false)
        .Fetchmsghistorydata(leadnumber: leadnumber, number: number);
  }

  Future<void> connectSocket() async {
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    String tkn = await AppUtils.getToken() ?? "";
    Map<String, dynamic> decodedToken = JwtDecoder.decode(tkn);

    token = tkn;
    phNum = number ?? "";
    userId = decodedToken;

    try {
      // print("Token: $token");

      socket = IO.io(
        'https://admin.watconnect.com',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setPath('/ibs/socket.io')
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .build(),
      );

      socket!.connect();

      socket!.onConnect((_) {
        print('Connected to WebSocket chat msg');
        socket!.emit("setup", userId);
      });

      socket!.on("connected", (_) {
        print(" WebSocket setup complete");
      });

      socket!.on("receivedwhatsappmessage", (data) {
        print("New WhatsApp message: $data");
        print("call the history apisssssssssssss");
        getHistory();
        _marksread(widget.wpnumber ?? "");
      });

      socket!.onDisconnect((_) {
        print(" WebSocket Disconnected");
      });

      socket!.onError((error) {
        print(" WebSocket Error: $error");
      });
    } catch (error) {
      print("Error connecting to WebSocket: $error");
    }
  }

  void disconnectSocket() {
    if (socket != null) {
      socket!.disconnect();
      print(" WebSocket Disconnected");
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void openDocument(BuildContext context, String url) async {
    final filename = url.split('/').last;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');

    // Show loading dialog (optional)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Check and download
    if (!await file.exists()) {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
      } else {
        Navigator.pop(context); // remove loader
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download file')),
        );
        return;
      }
    }

    Navigator.pop(context);
    OpenFilex.open(file.path);
  }

  Future<String?> _marksread(String whatsappNumber) async {
    print("sajdjsahdjsah jhsjhkjdhakj${whatsappNumber}");

    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    if (number != null) {
      Map<String, String>? bodydata = {"whatsapp_number": whatsappNumber};

      var response = await Provider.of<UnreadCountVm>(
              navigatorKey.currentContext!,
              listen: false)
          .marksreadcountmsg(
        leadnumber: whatsappNumber,
        number: number,
        bodydata: bodydata,
      );
    }
    return null;
  }

  Future<void> _startRecording(
      StateSetter setState, BuildContext context) async {
    _audioFile = null;

    var status = await Permission.microphone.status;

    if (status.isGranted) {
      // Start recording immediately
      await _beginRecording(setState);
      return;
    }
    print("status:::::   ${status}");
    PermissionStatus status1 = await Permission.microphone.status;
    print('Microphone permission status: $status1');

    if (status.isDenied) {
      // Request permission (system dialog may show)
      status = await Permission.microphone.request();

      if (status.isGranted) {
        await _beginRecording(setState);
        return;
      }
      // If still denied or permanently denied, show dialog
      if (status.isPermanentlyDenied || status.isDenied) {
        _showPermissionDialog(context);
        return;
      }
    }

    if (status.isPermanentlyDenied) {
      // User permanently denied permission, must open settings manually
      _showPermissionDialog(context);
      return;
    }

    if (status.isRestricted || status.isLimited) {
      EasyLoading.showToast("Microphone access is restricted or limited.");
      return;
    }
  }

  Future<void> _beginRecording(StateSetter setState) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath =
          '${tempDir.path}/voice_msg_${DateTime.now().millisecondsSinceEpoch}.aac';
      _audioPath = filePath;

      await _recorder.startRecorder(
        toFile: filePath,
        codec: fs.Codec.aacADTS,
      );

      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      debugPrint("Recording error: $e");
      EasyLoading.showToast("Failed to start recording");
    }
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Microphone Access Needed"),
        content: Platform.isIOS
            ? const Text(
                "Microphone access is disabled. Please enable it from Settings > Privacy > Microphone.")
            : const Text(
                "Permission permanently denied. Please enable it in Settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> _stopRecording(StateSetter setState) async {
    try {
      String? recordedPath = await _recorder.stopRecorder();
      if (recordedPath != null) {
        _audioFile = File(recordedPath);
        setState(() {
          _isRecording = false;
        });
        await Future.delayed(const Duration(milliseconds: 300));
        _showPreviewDialog();
      }
    } catch (e) {
      debugPrint("Stop recording error: $e");
      EasyLoading.showToast("Failed to stop recording");
    }
  }

  Future<void> _showPreviewDialog() async {
    if (_audioPath == null) return;
    // Get duration using just_audio
    final audioPlayerForDuration = AudioPlayer();
    Duration? audioDuration;

    try {
      await audioPlayerForDuration.setFilePath(_audioPath!);
      audioDuration = audioPlayerForDuration.duration;
    } catch (e) {
      print("Error getting audio duration: $e");
    } finally {
      await audioPlayerForDuration.dispose();
    }
    if (audioDuration == null || audioDuration.inSeconds < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Audio must be at least 3 seconds long."),
        ),
      );
      return;
    }
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> startPlayer() async {
              await _player.startPlayer(
                fromURI: _audioPath!,
                codec: fs.Codec.aacADTS,
                whenFinished: () {
                  setState(() {
                    _isPlayingPreview = false;
                  });
                },
              );

              setState(() {
                _isPlayingPreview = true;
              });

              _previewPlayerSubscription?.cancel();
              _previewPlayerSubscription = _player.onProgress?.listen((event) {
                setState(() {});
              });
            }

            Future<void> stopPlayer() async {
              await _player.stopPlayer();
              _previewPlayerSubscription?.cancel();
              setState(() {
                _isPlayingPreview = false;
              });
            }

            return AlertDialog(
              title: const Text('Voice Message Preview'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _isPlayingPreview
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                      size: 48,
                      color: AppColor.navBarIconColor,
                    ),
                    onPressed: () {
                      _isPlayingPreview ? stopPlayer() : startPlayer();
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    stopPlayer();
                    EasyLoading.showToast("Sending audio...");
                    sendAudio("audio", "");
                    Navigator.pop(context);
                  },
                  child: const Text('Send'),
                ),
                TextButton(
                  onPressed: () {
                    stopPlayer();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _isPlayingPreview = false;
  bool _isRecording = false;
  String? _audioPath;

  Future<void> _handleSendMessage() async {
    setState(() {
      showLoader = true;
    });

    if (image != null) {
      String fileExtension = path.extension(image!.path).toLowerCase();
      print("File Extension: $fileExtension");

      if (['.jpg', '.jpeg', '.png'].contains(fileExtension)) {
        EasyLoading.showToast("Sending Image...");
        print("📤 Sending Image...");
        filesend("image");
      } else if (['.mp4', '.avi', '.mov'].contains(fileExtension)) {
        EasyLoading.showToast("Sending Video...");

        print("📤 Sending Video...");
        filesend("video");
      } else if (['.html', '.txt'].contains(fileExtension)) {
        EasyLoading.showToast("Sending File...");
        print("📤 Sending Text Document...");
        filesend("document");
      } else {
        EasyLoading.showToast("Sending File...");

        print("📤 Sending Document...");
        filesend("document");
      }
    } else if (_controller.text.trim().isNotEmpty) {
      await messagesendd(_controller.text.trim());

      final prefs = await SharedPreferences.getInstance();
      final leadnumber = widget.wpnumber;
      final number = prefs.getString('phoneNumber');

      if (number != null) {
        await Provider.of<MessageViewModel>(context, listen: false)
            .Fetchmsghistorydata(leadnumber: leadnumber, number: number);
      }

      _controller.clear();
      getHistory();
    } else {
      EasyLoading.showToast("Please type a message or attach a file");
      print("⚠ No file or text entered.");
    }

    setState(() {
      // image = null;

      showLoader = false;
    });
  }

  UnreadCountVm? unreadCountVm;
  List unreadList = [];
  Future<void> _getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    var number = prefs.getString('phoneNumber');

    if (!mounted) return;
    Provider.of<LeadListViewModel>(context, listen: false).fetch();
    await Provider.of<UnreadCountVm>(context, listen: false)
        .fetchunreadcount(number: number ?? "");

    var unreadMsgModel;
    for (var unreadModel in unreadCountVm?.viewModels ?? []) {
      unreadMsgModel = unreadModel.model as UnreadMsgModel;
    }
    unreadList = unreadMsgModel.records ?? [];
    setState(() {});
  }
}

Widget _buildFilePreview(File image) {
  final ext = path.extension(image.path).toLowerCase();

  if (ext.contains('pdf')) {
    return _previewAsset("assets/images/pdf.png");
  } else if (ext.contains('mp4')) {
    return const Icon(Icons.play_arrow, color: Colors.black);
  } else if (['.jpg', '.jpeg', '.png'].contains(ext)) {
    return Container(
      height: 50,
      width: 50,
      child: Image.file(image, fit: BoxFit.cover),
    );
  } else {
    return _previewAsset("assets/images/file.png");
  }
}

Widget _previewAsset(String asset) {
  return Container(
    width: 50,
    height: 50,
    margin: const EdgeInsets.only(right: 8.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.asset(asset, fit: BoxFit.cover),
    ),
  );
}
