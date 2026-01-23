// ignore_for_file: avoid_print, await_only_futures, use_build_context_synchronously, unnecessary_brace_in_string_interps, no_leading_underscores_for_local_identifiers, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:whatsapp/main.dart';
import 'package:whatsapp/models/approved_template_model/aprovedtempltemodel/component.dart';
import 'package:whatsapp/models/call_history_model.dart';
import 'package:whatsapp/models/lead_model.dart';
import 'package:whatsapp/models/unread_msg_model/unread_msg_model.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_fonts.dart';
import 'package:whatsapp/utils/app_utils.dart';
import 'package:whatsapp/utils/function_lib.dart';
import 'package:whatsapp/view_models/call_view_model.dart';
import 'package:whatsapp/view_models/lead_list_vm.dart';
import 'package:whatsapp/view_models/message_controller.dart';
import 'package:whatsapp/view_models/message_list_vm.dart';
import 'package:whatsapp/view_models/templete_list_vm.dart';
import 'package:whatsapp/view_models/unread_count_vm.dart';
import 'package:whatsapp/view_models/wallet_controller.dart';
import 'package:whatsapp/views/view/call/call_screen.dart';
import 'package:whatsapp/views/view/lead_detail_view.dart';

import 'package:whatsapp/views/widgets/chat_msg_tile.dart';
import 'package:whatsapp/views/widgets/chat_socket_manager.dart';
import 'package:whatsapp/views/widgets/delete_dialog.dart';
import 'package:whatsapp/views/widgets/delete_message_dialog.dart';
import 'package:whatsapp/views/widgets/file_preview.dart'
    show FilePreviewWidget;
import 'package:whatsapp/views/widgets/image_picker_sheet.dart';
import 'package:whatsapp/views/widgets/review_edit_temp_sheet.dart';
import 'package:whatsapp/views/widgets/show_call_dialog.dart';
import 'package:path/path.dart' as path;

import 'package:flutter_sound/flutter_sound.dart' as fs;

class WhatsappChatScreen extends StatefulWidget {
  final String? leadName;
  final String? wpnumber;
  final List? pinnedLeads;
  final LeadModel? model;
  final String? contryCode;
  final String? id;

  const WhatsappChatScreen({
    super.key,
    this.leadName,
    this.wpnumber,
    this.pinnedLeads,
    this.id,
    this.model,
    this.contryCode,
  });

  @override
  State<WhatsappChatScreen> createState() => _WhatsappChatScreenState();
}

class _WhatsappChatScreenState extends State<WhatsappChatScreen> {
  bool hasWallet = false;
  bool hasCalls = false;
  bool showLoader = false;
  bool isPlaying = false;
  bool _isRecording = false;
  List<String> templateNames = [];
  List<String> templateIds = [];

  List<CallHistoryData> callHistoryList = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController sendMsgController = TextEditingController();

  final socketManager = SocketManager();
  Map<String, Map<String, dynamic>> allTemplatesMap = {};
  String userName = "";
  String TenetCode = "";
  bool _isPlayingPreview = false;
  var currentTemplate;
  List<Component> components = [];
  String? selectedTemplateName;

  String? _audioPath;
  File? _audioFile;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  StreamSubscription? _previewPlayerSubscription;
  final AudioPlayer audioPlayer = AudioPlayer();
  List<TextEditingController> controllers = [];

  int _lastMessageCount = 0;
  // bool _shouldScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    loadChatHistory(showLoaing: true);
    getWalletStatus();
    MessageController msgController = Provider.of(context, listen: false);
    msgController.clearDeleteList();
    markUnread();
    setTemplteEmpty();
    _initializeAudio();
    fetchTemplates();
  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scheduleScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });
  }

  setTemplteEmpty() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MessageViewModel messageViewModel = Provider.of(context, listen: false);
      messageViewModel.setSelectedBody(null);
      messageViewModel.setSelectedHeader(null);
      messageViewModel.setSelectedFooter(null);
      messageViewModel.setSelectedButton(null);
      messageViewModel.setSelectedTempId(null);
      messageViewModel.setSelectedTempName(null);
    });
  }

  Future<void> _initializeAudio() async {
    await _player.openPlayer();
    await _recorder.openRecorder();
  }

  @override
  void dispose() {
    socketManager.dispose();
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageController>(
      builder: (context, msgController, child) {
        return FocusDetector(
          onFocusGained: () {

print("itssss gaining focusssss>>>>>>>>>>>>>..>.----------------------------------");
              loadChatHistory(showLoaing: false,clearFile: false);

              socketManager.connectSocket(context, widget.wpnumber);
          },

          onFocusLost: () => socketManager.disconnectSocket(),
          child: SafeArea(
            child: Scaffold(
              backgroundColor: AppColor.pageBgGrey,
              appBar: AppBar(
                leading: const BackButton(color: Colors.white),
                title:
                    const Text("Chat", style: TextStyle(color: Colors.white)),
                actions: [
                  if (hasCalls)
                    IconButton(
                      icon: const Icon(Icons.call, color: Colors.white),
                      onPressed: () => initiateCall(),
                    ),
                ],
                centerTitle: true,
              ),
              body: RefreshIndicator(
                onRefresh: _pullRefresh,
                child: _pageBody(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _pageBody() {
    return Consumer2<MessageController, MessageViewModel>(
        builder: (context, msgController, mviewModel, child) {
      List allMessages = mviewModel.allMessages;

      if (allMessages.length > _lastMessageCount) {
        _lastMessageCount = allMessages.length;
        _scheduleScrollToBottom();
      }

      print("all msg in the main screen::::::::::   ${allMessages.length}");
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
                          child: SizedBox(
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
                                              builder: (context) =>
                                                  WhatsappChatScreen(
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
                                          setState(() {});
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
                                      child: SizedBox(
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
  
SizedBox(
  width: double.infinity,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Row(
      children: [
      
        Expanded(
          child: InkWell(
            onTap: () async {
              if (widget.model == null) return;

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LeadDetailView(
                    model: widget.model,
                  ),
                ),
              );

              if (result == true) {
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
                Expanded(
                  child: Text(
                    widget.leadName ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppFonts.medium,
                      color: Color.fromARGB(255, 59, 52, 52),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

      
        if (msgController.msgToDelete.isNotEmpty) ...[
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.black),
            onPressed: () {
            _copyMultipleMessages();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () {
              _showSimpleDialog("");
            },
          ),
        ],

       
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onSelected: (value) {
            if (value == 'Clear Chat') {
              _showDeleteDialog();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(
              value: 'Clear Chat',
              child: Text('Clear Chat'),
            ),
          ],
        ),
      ],
    ),
  ),
),


                    const Divider(),
                    chatLoader
                        ? const Expanded(
                            child: Center(child: CircularProgressIndicator()))
                        : allMessages.isEmpty
                            ? const Expanded(
                                child: Center(
                                child: Text(
                                  "No Chats Available...",
                                  style: TextStyle(
                                      fontFamily: AppFonts.medium,
                                      fontSize: 16),
                                ),
                              ))
                            : Expanded(
                                child: NotificationListener<ScrollNotification>(
                                  onNotification: (scrollNotification) {
                                    if (scrollNotification
                                        is ScrollEndNotification) {
                                      _lastMessageCount = allMessages.length;
                                    }
                                    return false;
                                  },
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    itemCount: allMessages.length,
                                    itemBuilder: (context, index) {
                                      final message = allMessages[index];
                                      final previousMessage = index > 0
                                          ? allMessages[index - 1]
                                          : null;

                                      return message.category ==
                                              "AUTHENTICATION"
                                          ? const SizedBox()
                                          : ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                  minHeight: 0),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Container(
                                                  color: msgController
                                                          .msgToDelete
                                                          .contains(
                                                              allMessages[index]
                                                                  .id)
                                                      ? Colors.grey.shade300
                                                      : Colors.transparent,
                                                  child: ChatMessageTile(
                                                    message: message,
                                                    previousMessage:
                                                        previousMessage,
                                                    userName: userName,
                                                    tenetCode: TenetCode,
                                                    onTap: msgController
                                                        .updateDeleteMsgList,
                                                    selectedMessages:
                                                        msgController
                                                            .msgToDelete,
                                                  ),
                                                ),
                                              ),
                                            );
                                    },
                                  ),
                                ),
                              )
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

  Future<void> getWalletStatus() async {
    final prefs = await SharedPreferences.getInstance();
    hasCalls = await prefs.getBool(SharedPrefsConstants.hasCallsKey) ?? false;
    print(
        "prefs.getBool('hasCallsKey'):::::  ${prefs.getBool(SharedPrefsConstants.hasCallsKey)}");
    hasWallet = prefs.getBool(SharedPrefsConstants.hasWalletKey) ?? false;
    Provider.of<WalletController>(context, listen: false)
        .templateRatesApiCall();

    userName = prefs.getString('userName') ?? "Me";
    TenetCode = prefs.getString(SharedPrefsConstants.usertenantcodeKey) ?? "";
    setState(() {});
  }

  Future<void> markUnread() async {
    final prefs = await SharedPreferences.getInstance();
    final number = prefs.getString('phoneNumber');
    final bodydata = {"whatsapp_number": widget.wpnumber ?? ""};
    await Provider.of<UnreadCountVm>(context, listen: false).marksreadcountmsg(
        leadnumber: widget.wpnumber ?? "", number: number, bodydata: bodydata);
  }

  bool chatLoader = false;

  setChatLoader(val) {
    setState(() {
      chatLoader = val;
    });
  }

  Future<void> loadChatHistory({bool showLoaing = false, bool clearFile=true}) async {
    final prefs = await SharedPreferences.getInstance();
    final number = prefs.getString('phoneNumber');
    final messageVM = Provider.of<MessageViewModel>(context, listen: false);
    if(clearFile){
 messageVM.setFileToSend(null);
    }
   
    if (showLoaing) {
      setChatLoader(true);
    }

    await messageVM.Fetchmsghistorydata(
            leadnumber: widget.wpnumber ?? '', number: number)
        .then((onValue) {
      setChatLoader(false);
      _scheduleScrollToBottom();
    });
  }

  Future<void> fetchTemplates() async {
    TempleteListViewModel templeteViewModel =
        Provider.of<TempleteListViewModel>(context, listen: false);

    if (templeteViewModel.viewModels.isNotEmpty) {
      for (var viewModel in templeteViewModel.viewModels) {
        var campaignModel = viewModel.model;
        if (campaignModel?.data != null) {
          for (var record in campaignModel!.data!) {
            if (record.status != null) {
              if (record.name != null && record.category != null) {
                String categoryKey = record.category!.toLowerCase();

                allTemplatesMap.putIfAbsent(categoryKey, () => {});
                allTemplatesMap[categoryKey]?[record.id] = (record.name!);
              }
              setState(() {
                log("record.status:::::::::  ${record.status}   ${record.name} ");
                if (record.status == "APPROVED") {
                  templateNames.add(record.name);
                } else if (record.status == "REJECTED") {
                  log("REJECTED:::::::::   ${record.name} ");
                  templateNames.remove(record.name);
                }
              });
            }
          }
          log("templateNames:::::::::: $templateNames");
        }
      }
    }
  }

  Future<void> initiateCall() async {
    final prefs = await SharedPreferences.getInstance();
    final number = prefs.getString('phoneNumber');
    final callVM = Provider.of<CallsViewModel>(context, listen: false);

    await callVM.startCallApi(number!, widget.wpnumber ?? "");
    callHistoryList = callVM.viewModels
        .expand((vm) => (vm.model?.records ?? []) as List<CallHistoryData>)
        .toList();

    if (!mounted) return;
    showCallDialog(context, callHistoryList, () => _startCall());
  }

  Future<void> _startCall() async {
    final token = await AppUtils.getToken() ?? "";
    final decoded = JwtDecoder.decode(token);
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          token: token,
          userData: decoded,
          parentId: widget.id ?? "",
          wpNumber: widget.wpnumber ?? "",
          leadName: widget.leadName ?? "",
        ),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    var leadnumber = widget.wpnumber;
    print("leadnumber$leadnumber");
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');
    await Provider.of<MessageViewModel>(context, listen: false)
        .Fetchmsghistorydata(leadnumber: leadnumber, number: number)
        .then((_) {
      _scheduleScrollToBottom();
    });
  }

  Widget _buildMessageInputArea() {
    MessageViewModel messageViewModel = Provider.of(context, listen: false);

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
                        if (messageViewModel.fileToSend != null)
                          FilePreviewWidget(file: messageViewModel.fileToSend!),
                        Expanded(
                          child: TextField(
                            controller: sendMsgController,
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintMaxLines: 1,
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
                      onPointerDown: (_) => _startRecording(),
                      onPointerUp: (_) => _stopRecording(),
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
                          messageViewModel.setCarousalListEmpty();
                          WalletController wc =
                              Provider.of(context, listen: false);
                          wc.setFinalAmt("");
                          _getBootmSheet();
                        },
                      ),
                    ),
                  ),
                  if (messageViewModel.allMessages.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 76, 162, 189),
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
      builder: (context) => DeleteMessageDialog(
        id: id,
        onConfirm: singlemsgdelete,
      ),
    );
  }

  void singlemsgdelete() async {
    MessageController msgController = Provider.of(context, listen: false);
    List idsToDelete = msgController.msgToDelete;
    print("Single delete attempt for message with ID: $idsToDelete");
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
      EasyLoading.showToast("Deleted Successfully");

      msgController.clearDeleteList();

      print("Delete single message successfully");
    }).catchError((error) {
      print("Error deleting message: $error");
    });
  }

  Future<void> _showDeleteDialog() async {
    await showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        onConfirm: deletechat,
      ),
    );
  }

  Future<String?> _marksread(String whatsappNumber) async {
    print("sajdjsahdjsah jhsjhkjdhakj$whatsappNumber");

    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    if (number != null) {
      Map<String, String>? bodydata = {"whatsapp_number": whatsappNumber};

      await Provider.of<UnreadCountVm>(navigatorKey.currentContext!,
              listen: false)
          .marksreadcountmsg(
        leadnumber: whatsappNumber,
        number: number,
        bodydata: bodydata,
      );
    }
    return null;
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

  Future<void> _handleSendMessage() async {
    final messageViewModel =
        Provider.of<MessageViewModel>(context, listen: false);

    setState(() {
      showLoader = true;
    });

    try {
      final file = messageViewModel.fileToSend;
      final text = sendMsgController.text.trim();

      if (file != null) {
        final fileExtension = path.extension(file.path).toLowerCase();
        print("File Extension: $fileExtension");

        if (['.jpg', '.jpeg', '.png'].contains(fileExtension)) {
          EasyLoading.showToast("Sending Image...");
          await sendFile("image", text);
        } else if (['.mp4', '.avi', '.mov'].contains(fileExtension)) {
          EasyLoading.showToast("Sending Video...");
          await sendFile("video", text);
        } else {
          EasyLoading.showToast("Sending File...");
          await sendFile("document", text);
        }
      } else if (text.isNotEmpty) {
        await messagesendd(text);

        final prefs = await SharedPreferences.getInstance();
        final leadnumber = widget.wpnumber;
        final number = prefs.getString('phoneNumber');

        if (number != null) {
          await messageViewModel.Fetchmsghistorydata(
            leadnumber: leadnumber,
            number: number,
          );
        }

        sendMsgController.clear();
      } else {
        EasyLoading.showToast("Please type a message or attach a file");
        print("⚠ No file or text entered.");
      }
    } catch (e) {
      print("❌ Error sending message: $e");
      EasyLoading.showToast("Failed to send message.");
    } finally {
      await loadChatHistory();
      setState(() {
        showLoader = false;
      });
    }
  }

  Future<void> messagesendd(String text) async {
    try {
      MessageViewModel ms = MessageViewModel(context);
      final prefs = await SharedPreferences.getInstance();
      String? number = prefs.getString('phoneNumber');

      var leadnumber = widget.wpnumber;
      Map<String, dynamic> addmsModel = {
        "messaging_product": "whatsapp",
        "recipient_type": "individual",
        "to": leadnumber,
        "type": "text",
        "text": {"preview_url": false, "body": text}
      };

      var value = await ms.sendMessage(number: number, addmsModel: addmsModel);
      var messageId = value['messages'];
      print('Message ID: ${messageId[0]['id']}');
      print("value of the api:::;${value}");

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
        "message_id": messageId[0]['id']
      };

      var msgValue = await ms.sendmsgmobile(msgmobilbody: msgmobilebody);
      print("valueee1 delivery_status=>$msgValue");

      if (msgValue['delivery_status'] == "sent") {
        loadChatHistory();
      }
    } catch (error) {
      print("errore in sending message::::  $error");
    }
  }

  void _showPicker() async {
    File? pickedFile = await ImagePickerBottomSheet.show(context);
    if (pickedFile != null) {
      MessageViewModel msgVM = Provider.of(context, listen: false);

      print('Picked: ${pickedFile.path}');
      msgVM.setFileToSend(pickedFile);
    }
  }

  Future<void> sendFile(String type, String caption) async {
    debugPrint("Sending file...");

    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');
    final messageVM = Provider.of<MessageViewModel>(context, listen: false);
    final file = type == "audio" ? _audioFile : messageVM.fileToSend;

    if (file == null) {
      debugPrint('No file selected');
      return;
    }

    try {
      final uploadResponse = await messageVM.uploadFile(file, phoneNumber);
      if (uploadResponse == null) {
        debugPrint('Upload failed: No response');
        return;
      }

      final documentId = jsonDecode(uploadResponse)['id'];
      debugPrint('Uploaded File ID: $documentId');

      final whatsappPayload = type == "audio"
          ? {
              "messaging_product": "whatsapp",
              "recipient_type": "individual",
              "to": widget.wpnumber,
              "type": type,
              type: {
                "id": documentId,
              },
            }
          : {
              "messaging_product": "whatsapp",
              "recipient_type": "individual",
              "to": widget.wpnumber,
              "type": type,
              type: {
                "id": documentId,
                "caption": caption,
              },
            };
      debugPrint("Sending to WhatsApp => $whatsappPayload");

      await messageVM.uploadimagewithdoucmentid(
        bodyy: whatsappPayload,
        number: phoneNumber,
      );

      final leadId = widget.id;
      final dbResponse =
          await messageVM.uploadFiledb(file, phoneNumber, leadId);
      final fileId = jsonDecode(dbResponse)['records']?[0]?['id'];

      debugPrint("Uploaded to DB. File ID: $fileId");

      final messageHistoryData = {
        "parent_id": leadId,
        "name": widget.leadName,
        "message_template_id": null,
        "whatsapp_number": widget.wpnumber,
        "message": caption,
        "status": "Outgoing",
        "recordtypename": "lead",
        "file_id": fileId,
        "business_number": phoneNumber,
        "is_read": true,
      };

      await messageVM.sendimagehistory(msghistorydata: messageHistoryData);
      debugPrint("✅ Message history updated successfully.");
    } catch (e) {
      debugPrint("❌ Error in sendFile: $e");
    } finally {
      debugPrint("📤 File sending process complete.");
    }
  }

  String? SelectedTemplateCategory;
  String? SelectedTemplateFilters;

  List<dynamic> tempateCategory = [
    'All Categories',
    'UTILITY',
    'MARKETING',
  ];

  List<dynamic> tempateFilter = [
    'All Templates',
    'Template without-Params',
    'Template with-Params',
    'Template with Carousal',
    'Template with Image',
    'Template with Video',
    'Template with Document',
  ];

  Future<void> _getBootmSheet() {
    TextEditingController templateController = TextEditingController();
    SelectedTemplateCategory = null;
    SelectedTemplateFilters = null;

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

                            if (SelectedTemplateCategory != 'All Categories') {
                              templateNames = (allTemplatesMap[categoryKey]
                                          ?.values
                                          .toSet()
                                          .toList() ??
                                      [])
                                  .map((e) => e.toString())
                                  .toSet()
                                  .toList();
                            } else {
                              fetchTemplates();
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
                          templateController.text = newValue ?? '';
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
                        : const SizedBox(),
                    Center(
                      child: Consumer2<WalletController, MessageViewModel>(
                          builder: (context, ref, msgViewModel, child) {
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
                                "hasBalance::      ::: hasWallet    ::::::   :::::  ${ref.hasBalance}      $hasWallet");
                            if ((hasWallet && ref.hasBalance) ||
                                hasWallet == false) {
                              print(
                                  "selectedTemplateName>>> $selectedTemplateName");
                              if (selectedTemplateName == null ||
                                  selectedTemplateName ==
                                      "Select Template Name") {
                                EasyLoading.showToast("Select Template Name");
                                return;
                              }
                              log("all comp info >> >>  ${msgViewModel.selectedHeader}  ${msgViewModel.selectedBody} ${msgViewModel.selectedFooter} ${msgViewModel.selectedButtons}}");
                              log("selectedBody['text']>>> ${msgViewModel.selectedBody?.text}  ");

                              {
                                {
                                  Navigator.of(context).pop();
                                  msgViewModel.setMainBodyParams({});
                                  _sendTemplateSheet();
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

  String? selectedTemplateId;

  Future<void> _setSelectedTemplates() async {
    try {
      final templeteViewModel = context.read<TempleteListViewModel>();
      final msgViewModel = context.read<MessageViewModel>();

      print(
          "templeteViewModel.viewModels is empty ${templeteViewModel.viewModels.isEmpty}");
      if (templeteViewModel.viewModels.isEmpty) return;

      for (var viewModel in templeteViewModel.viewModels) {
        final campaignModel = viewModel.model;

        for (var record in campaignModel!.data!) {
          print(
              "record.status?:::::::::  ${record.status}  rec name ${record.name}  ");
          if (record.status == "APPROVED" &&
              selectedTemplateName == record.name) {
            currentTemplate = record;
            selectedTemplateId = currentTemplate.id;
            msgViewModel.selectedLanguage = currentTemplate.language;
            print("hasWallet while seketing temp ${hasWallet}");
            if (hasWallet) {
              final walletController = context.read<WalletController>();

              final countryCode =
                  widget.model?.countryCode ?? widget.contryCode ?? "+91";

              walletController.calculateAmount(
                currentTemplate.category,
                countryCode,
              );
            }

            log("Selected template category: ${currentTemplate.category}");
            msgViewModel.setSelectedTempId(currentTemplate.id);
            msgViewModel.setSelectedTempName(currentTemplate.name);

            components = currentTemplate.components ?? [];
            debugPrint("Component count: ${components.length} -> $components");

            for (var e in components) {
              debugPrint("Component type: ${e.type}");

              switch (e.type) {
                case "HEADER":
                  msgViewModel.setSelectedHeader(e);
                  break;
                case "CAROUSEL":
                  debugPrint(
                      "Carousel detected: ${e.cards?.length ?? 0} cards");
                  msgViewModel.setCarousalList(e.cards);
                  break;
                case "BODY":
                  msgViewModel.setSelectedBody(e);
                  break;
                case "FOOTER":
                  msgViewModel.setSelectedFooter(e);
                  break;
                case "BUTTONS":
                  msgViewModel.setSelectedButton(e);
                  break;
              }
            }

            return;
          }
        }
      }
    } catch (e, stackTrace) {
      print("some error in seletcing temp ::::::::     $e   $stackTrace");
    }
  }

  Future<void> _startRecording() async {
    _audioFile = null;
    var status = await Permission.microphone.status;

    if (status.isGranted) {
      await _beginRecording();
    } else {
      status = await Permission.microphone.request();
      if (status.isGranted) {
        await _beginRecording();
      } else if (status.isPermanentlyDenied) {
        _showPermissionDialog();
      } else {
        EasyLoading.showToast("Microphone permission denied.");
      }
    }
  }

  void _showPermissionDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Microphone Access Needed"),
        content: const Text("Please enable microphone access in settings."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                openAppSettings();
              },
              child: const Text("Open Settings")),
        ],
      ),
    );
  }

  Future<void> _beginRecording() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath =
          '${tempDir.path}/voice_msg_${DateTime.now().millisecondsSinceEpoch}.aac';
      _audioPath = filePath;

      await _recorder.startRecorder(
        toFile: filePath,
        codec: fs.Codec.aacADTS,
      );

      setState(() => _isRecording = true);
    } catch (e) {
      debugPrint("Recording error: $e");
      EasyLoading.showToast("Failed to start recording");
    }
  }

  Future<void> _stopRecording() async {
    try {
      String? recordedPath = await _recorder.stopRecorder();
      if (recordedPath != null) {
        _audioFile = File(recordedPath);
        setState(() => _isRecording = false);
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

    final audioPlayer = AudioPlayer();
    Duration? duration;

    try {
      await audioPlayer.setFilePath(_audioPath!);
      duration = audioPlayer.duration;
    } catch (e) {
      print("Error getting duration: $e");
    } finally {
      await audioPlayer.dispose();
    }

    if (duration == null || duration.inSeconds < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Audio must be at least 3 seconds long.")),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> _startPlayer() async {
            await _player.startPlayer(
              fromURI: _audioPath!,
              codec: fs.Codec.aacADTS,
              whenFinished: () {
                setModalState(() => _isPlayingPreview = false);
              },
            );
            setModalState(() => _isPlayingPreview = true);
          }

          Future<void> _stopPlayer() async {
            await _player.stopPlayer();
            _previewPlayerSubscription?.cancel();
            setModalState(() => _isPlayingPreview = false);
          }

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Voice Message Preview"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _isPlayingPreview
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    size: 48,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    _isPlayingPreview ? _stopPlayer() : _startPlayer();
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  _stopPlayer();
                  if (_audioFile != null) {
                    await sendFile("audio", "");
                    // widget.onSend(_audioFile!);
                  }
                  Navigator.pop(context);
                },
                child: const Text("Send"),
              ),
              TextButton(
                onPressed: () {
                  _stopPlayer();
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _sendTemplateSheet() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: TemplateSheetHelper(
            controllers: controllers,
            leadName: widget.leadName ?? "",
            leadNum: widget.wpnumber ?? "",
            ledid: widget.id ?? "",
          ),
        ),
      ),
    );
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
  
Future<void> _copyMultipleMessages() async {
      MessageController msgController = Provider.of(context, listen: false);
            MessageViewModel mviewModel = Provider.of(context, listen: false);

      List allMessages = mviewModel.allMessages;

  if (msgController.msgToDelete.isEmpty) return;
  
  String allText = "";
  
  for (var messageId in msgController.msgToDelete) {
    var message = allMessages.firstWhere(
      (msg) => msg.id == messageId,
      orElse: () => null,
    );
    
    if (message != null) {
      String messageText = "";
      
      if (message.message?.isNotEmpty ?? false) {
        messageText = message.message!;
      } else if (message.bodyText?.isNotEmpty ?? false) {
        messageText = message.bodyText!;
      } else if (message.messageBody != null) {
        messageText = message.messageBody!;
      } else if (message.adHeadline?.isNotEmpty ?? false) {
        messageText = "${message.adHeadline}\n${message.adBody ?? ''}";
      }
      
      if (messageText.isNotEmpty) {
      
        final time = DateFormat('hh:mm a').format(
          message.createddate.add(const Duration(hours: 5, minutes: 30))
        );
        final sender = message.status == "Outgoing" ? "You" : widget.leadName ?? "";
        allText += "[$time] $sender: $messageText\n\n";
      }
    }
  }
  
  if (allText.isNotEmpty) {
    await Clipboard.setData(ClipboardData(text: allText.trim()));
    
   
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${msgController.msgToDelete.length} messages copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

      msgController.clearDeleteList();
  }


}
}
