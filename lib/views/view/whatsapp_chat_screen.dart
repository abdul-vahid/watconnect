import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
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
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_fonts.dart';
import 'package:whatsapp/utils/function_lib.dart';
import 'package:whatsapp/views/view/lead_detail_view.dart';

import 'package:whatsapp/views/widgets/attachment_widget.dart';
import 'package:whatsapp/views/widgets/chat_socket_manager.dart';
import 'package:whatsapp/views/widgets/custom_chat_button.dart';
import 'package:whatsapp/views/widgets/delete_dialog.dart';
import 'package:whatsapp/views/widgets/delete_message_dialog.dart';
import 'package:whatsapp/views/widgets/file_preview.dart'
    show FilePreviewWidget;
import 'package:whatsapp/views/widgets/header_widget.dart';
import 'package:whatsapp/views/widgets/image_picker_sheet.dart';
import 'package:whatsapp/views/widgets/show_call_dialog.dart';
import 'package:path/path.dart' as path;

import 'package:whatsapp/views/widgets/whatsapp_chats_widgets.dart/whatsapp_chat_func.dart';

import '../../utils/app_color.dart';
import '../../utils/app_utils.dart';
import '../../view_models/wallet_controller.dart';
import '../../view_models/call_view_model.dart';
import '../../view_models/unread_count_vm.dart';
import '../../view_models/message_controller.dart';
import '../../view_models/templete_list_vm.dart';
import '../../view_models/message_list_vm.dart';
import '../../models/call_history_model.dart';
import '../../models/lead_model.dart';
import '../view/call_screen.dart';
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
  // final audioManager = AudioManager();
  final socketManager = SocketManager();
  Map<String, Map<String, dynamic>> allTemplatesMap = {};
  String userName = "";
  String TenetCode = "";
  // File? image;
  bool _isPlayingPreview = false;
  var currentTemplate;
  List<Component> components = [];
  String? selectedTemplateName;
  var selectedLanguage;
  var selectedHeader;
  var selectedBody;
  var selectedFooter;
  dynamic selectedButtons;
  String? _audioPath;
  File? _audioFile;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  StreamSubscription? _previewPlayerSubscription;
  final AudioPlayer audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  @override
  void initState() {
    super.initState();
    getWalletStatus();
    markUnread();
    _initializeAudio();
    // audioManager.initialize();
    fetchTemplates();
    loadChatHistory();
    scrollToBottom();
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
          onFocusGained: () =>
              socketManager.connectSocket(context, widget.wpnumber),
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

  Future<void> getWalletStatus() async {
    final prefs = await SharedPreferences.getInstance();
    hasCalls = prefs.getBool('hasCallsKey') ?? false;
    hasWallet = prefs.getBool('hasWalletKey') ?? false;
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

  Future<void> loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final number = prefs.getString('phoneNumber');
    final messageVM = Provider.of<MessageViewModel>(context, listen: false);
    messageVM.setFileToSend(null);
    messageVM.Fetchmsghistorydata(
        leadnumber: widget.wpnumber ?? '', number: number);
  }

  void scrollToBottom() {
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

  Future<void> fetchTemplates() async {
    TempleteListViewModel templeteViewModel =
        Provider.of<TempleteListViewModel>(context, listen: false);

    // Check if templeteViewModel is not null and contains viewModels
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
                templateNames.add(record.name);
                // print("Templates => $templateNames");
              });
            }
          }
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
        .Fetchmsghistorydata(leadnumber: leadnumber, number: number);
  }

  Widget _pageBody() {
    return Consumer2<MessageController, MessageViewModel>(
        builder: (context, msgController, mviewModel, child) {
      List allMessages = mviewModel.allMessages;
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
                                        // Navigator.pop(context);
                                        // var num = "";
                                        // num = "${model.full_number}";
                                        // print(
                                        //     "model  finalResult=>${model.full_number}");
                                        // if (model.full_number != null) {
                                        //   _marksread(num);
                                        //   final result = await Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //       builder: (context) => ChatScreen(
                                        //         pinnedLeads:
                                        //             widget.pinnedLeads!,
                                        //         leadName:
                                        //             model.contactname ?? "",
                                        //         wpnumber: model.full_number,
                                        //         id: model.id,
                                        //         model: widget.model == null
                                        //             ? null
                                        //             : model,
                                        //       ),
                                        //     ),
                                        //   ).then((onValue) {
                                        //     _marksread(num);
                                        //     _getUnreadCount();
                                        //   });
                                        //   if (result == true) {
                                        //     print(
                                        //         "is result getting true.........?");
                                        //     _getUnreadCount();

                                        //   }

                                        //   _getUnreadCount();
                                        //   final prefs = await SharedPreferences
                                        //       .getInstance();
                                        //   var number =
                                        //       prefs.getString('phoneNumber');
                                        //   Provider.of<UnreadCountVm>(context,
                                        //           listen: false)
                                        //       .fetchunreadcount(
                                        //           number: number ?? "");
                                        //   setState(() {

                                        //   });

                                        // } else {
                                        //   ScaffoldMessenger.of(context)
                                        //       .showSnackBar(
                                        //     const SnackBar(
                                        //       content: Text('No Phone Number '),
                                        //       duration: Duration(seconds: 3),
                                        //       backgroundColor:
                                        //           AppColor.motivationCar1Color,
                                        //     ),
                                        //   );
                                        // }
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
                                  SizedBox(
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
                            const Spacer(),
                            msgController.msgToDelete.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      _showSimpleDialog("");
                                    },
                                  )
                                : const SizedBox(),
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
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: allMessages.length,
                        itemBuilder: (context, index) {
                          final message = allMessages[index];
                          final previousMessage =
                              index > 0 ? allMessages[index - 1] : null;

                          // Determine message content
                          final regex = RegExp(r'\{\{\d+\}\}');
                          String result = message.messageBody ?? "";

                          if (regex.hasMatch(result)) {
                            result = replacePlaceholders(
                              result,
                              message.bodyTextParams?.toString() ??
                                  message.exampleBodyText ??
                                  "",
                            );
                          }

                          // Date & Time Handling
                          final now = DateTime.now();
                          final istTime = message.createddate
                              .add(const Duration(hours: 5, minutes: 30));
                          final formattedTime =
                              DateFormat('hh:mm a').format(istTime);
                          final isSameDay = (DateTime? a, DateTime? b) =>
                              a?.year == b?.year &&
                              a?.month == b?.month &&
                              a?.day == b?.day;

                          String dayLabel = isSameDay(istTime, now)
                              ? 'Today'
                              : isSameDay(istTime,
                                      now.subtract(const Duration(days: 1)))
                                  ? 'Yesterday'
                                  : DateFormat('d MMMM yyyy').format(istTime);

                          final showDateLabel = index == 0 ||
                              !isSameDay(
                                  istTime,
                                  previousMessage?.createddate.add(
                                      const Duration(hours: 5, minutes: 30)));

                          final buttons = message.buttons ?? [];
                          final imageUrl = message.title?.isNotEmpty == true
                              ? "${AppConstants.baseImgUrl}public/$TenetCode/attachment/${message.title}"
                              : "";

                          final isEmptyMessage = message.header == null &&
                              message.messageBody == null &&
                              imageUrl.isEmpty &&
                              (message.message?.isEmpty ?? true);

                          if (isEmptyMessage) return const SizedBox();

                          return Column(
                            children: [
                              if (showDateLabel)
                                Center(
                                  child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 169, 215, 236),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      dayLabel,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: GestureDetector(
                                  onTap: () {
                                    if (msgController.msgToDelete.isNotEmpty) {
                                      msgController.updateDeleteMsgList(
                                          message.id ?? "");
                                    }
                                  },
                                  onLongPress: () {
                                    msgController
                                        .updateDeleteMsgList(message.id ?? "");
                                  },
                                  child: Container(
                                    color: msgController.msgToDelete
                                            .contains(message.id)
                                        ? const Color(0xffAFAFAF)
                                        : Colors.transparent,
                                    child: Row(
                                      mainAxisAlignment:
                                          message.status == "Incoming"
                                              ? MainAxisAlignment.start
                                              : MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                message.status == "Outgoing"
                                                    ? CrossAxisAlignment.end
                                                    : CrossAxisAlignment.start,
                                            children: [
                                              if (index == 0 ||
                                                  message.status !=
                                                      previousMessage?.status ||
                                                  message.name !=
                                                      previousMessage?.name)
                                                Text(
                                                  message.status == "Incoming"
                                                      ? message.name
                                                      : userName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              IntrinsicWidth(
                                                child: Container(
                                                  constraints: BoxConstraints(
                                                    minWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.25,
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.65,
                                                  ),
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 4),
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: message.status ==
                                                            "Outgoing"
                                                        ? const Color(
                                                            0xffE3FFC9)
                                                        : const Color.fromARGB(
                                                            255, 179, 238, 243),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          const Radius.circular(
                                                              12),
                                                      topRight:
                                                          const Radius.circular(
                                                              12),
                                                      bottomLeft:
                                                          message.status ==
                                                                  "Outgoing"
                                                              ? const Radius
                                                                  .circular(12)
                                                              : Radius.zero,
                                                      bottomRight:
                                                          message.status ==
                                                                  "Outgoing"
                                                              ? Radius.zero
                                                              : const Radius
                                                                  .circular(12),
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        blurRadius: 4,
                                                        offset:
                                                            const Offset(2, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (imageUrl.isNotEmpty)
                                                        AttachmentWidget(
                                                            url: imageUrl),
                                                      if (message.header !=
                                                              null &&
                                                          imageUrl.isEmpty)
                                                        HeaderMediaWidget(
                                                          header:
                                                              message.header!,
                                                          headerBody: message
                                                              .headerBody,
                                                        ),
                                                      if (message.message
                                                              ?.isNotEmpty ??
                                                          false)
                                                        Text(
                                                          message.message!,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14,
                                                                  height: 1.5),
                                                          maxLines: 4,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      if (message.messageBody !=
                                                          null)
                                                        Text(result),
                                                      if (message.description !=
                                                          null)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 5),
                                                          child: Text(message
                                                              .description!),
                                                        ),
                                                      if (message.footer !=
                                                          null)
                                                        Text(
                                                          message.footer!,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .grey),
                                                        ),
                                                      if (message.erormessage !=
                                                          null)
                                                        Text(
                                                          message.erormessage!,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .red),
                                                        ),
                                                      if (buttons.isNotEmpty)
                                                        CustomButtonList(
                                                            buttons: buttons),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            formattedTime,
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black45),
                                                          ),
                                                          if (message.status ==
                                                              "Outgoing")
                                                            Icon(
                                                              Icons.done_all,
                                                              color:
                                                                  message.deliveryStatus ==
                                                                          "read"
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .grey,
                                                              size: 18,
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
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
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
      EasyLoading.showToast("Deleted Succeffuly");

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
        onConfirm: deletechat, // Your delete function
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
      // Step 1: Upload file to get document ID
      final uploadResponse = await messageVM.uploadFile(file, phoneNumber);
      if (uploadResponse == null) {
        debugPrint('Upload failed: No response');
        return;
      }

      final documentId = jsonDecode(uploadResponse)['id'];
      debugPrint('Uploaded File ID: $documentId');

      // Step 2: Send to WhatsApp using document ID
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

      // Step 3: Upload to your internal DB
      final leadId = widget.id;
      final dbResponse =
          await messageVM.uploadFiledb(file, phoneNumber, leadId);
      final fileId = jsonDecode(dbResponse)['records']?[0]?['id'];

      debugPrint("Uploaded to DB. File ID: $fileId");

      // Step 4: Add to message history
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

  List<dynamic> tempateCategory = [
    'All Categories',
    'UTILITY',
    'MARKETING',
  ];

  List<dynamic> tempateFilter = [
    'All Categories',
    'Template without-Params',
    'Template with-Params',
    'Template with Carousal',
    'Template with Image',
    'Template with Video',
    'Template with Document',
  ];

  Future<void> _getBootmSheet() {
    TextEditingController templateController = TextEditingController();
    // int selectedBtnIdx = 0;
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
                      'Select Filter',
                      data: tempateFilter,
                      onChanged: (String? selectedCategory) {},
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
                        : const SizedBox(),
                    // Center(
                    //   child: Consumer<WalletController>(
                    //       builder: (context, ref, child) {
                    //     return ElevatedButton(
                    //       style: ButtonStyle(
                    //         minimumSize:
                    //             WidgetStateProperty.all(const Size(10, 20)),
                    //         padding: WidgetStateProperty.all(
                    //             const EdgeInsets.symmetric(
                    //                 horizontal: 20, vertical: 10)),
                    //         backgroundColor: WidgetStateProperty.all(
                    //             AppColor.navBarIconColor),
                    //       ),
                    //       onPressed: () {
                    //         print(
                    //             "hasBalance::      ::: hasWallet    ::::::   :::::  ${ref.hasBalance}      $hasWallet");
                    //         if ((hasWallet && ref.hasBalance) ||
                    //             hasWallet == false) {
                    //           print(
                    //               "selectedTemplateName>>> $selectedTemplateName");
                    //           if (selectedTemplateName == null ||
                    //               selectedTemplateName ==
                    //                   "Select Template Name") {
                    //             EasyLoading.showToast("Select Template Name");
                    //             return;
                    //           }
                    //           log("all comp info >> >>  $selectedHeader  $selectedBody $selectedFooter $selectedButtons}");
                    //           log("selectedBody['text']>>> ${selectedBody.text}  ");
                    //           final regex = RegExp(r'\{\{\d+\}\}');

                    //           if (regex.hasMatch(selectedBody.text)) {
                    //             Navigator.of(context).pop();
                    //             // _sendTemplateSheet();
                    //           } else if (selectedHeader == null ||
                    //               selectedHeader.format == null) {
                    //             String templateToSend = selectedTemplateName ??
                    //                 templateController.text;
                    //             print("Template to send: $templateToSend");
                    //             // templetesendd(templateToSend, []);
                    //             Navigator.of(context).pop();
                    //           } else {
                    //             if (regex.hasMatch(selectedBody.text) ||
                    //                 selectedHeader.format != null ||
                    //                 selectedHeader.format != "TEXT") {
                    //               Navigator.of(context).pop();
                    //               // _sendTemplateSheet();
                    //             } else {
                    //               String templateToSend =
                    //                   selectedTemplateName ??
                    //                       templateController.text;
                    //               print("Template to send: $templateToSend");
                    //               // templetesendd(templateToSend, []);
                    //               if (hasWallet) {
                    //                 WalletController walletController =
                    //                     Provider.of(context, listen: false);
                    //                 walletController.debitWalletBalApiCall();
                    //               }
                    //               Navigator.of(context).pop();
                    //             }
                    //           }
                    //         } else {
                    //           EasyLoading.showToast("Insufficient Balance");
                    //         }
                    //       },
                    //       child: const Text(
                    //         "Send",
                    //         style: TextStyle(fontSize: 13, color: Colors.white),
                    //       ),
                    //     );
                    //   }),
                    // )
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

                log("current template:::  ${currentTemplate.category}   :: $currentTemplate  ${currentTemplate.name}");
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

// Call setState once after processing all components
                setState(() {});

                log("components ::: $selectedHeader   $selectedBody  $selectedButtons");

                return;
              }
            }
          }
        }
      }
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
}
