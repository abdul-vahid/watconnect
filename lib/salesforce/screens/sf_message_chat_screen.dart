import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart' as fs;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_common/src/util/event_emitter.dart';
import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
import 'package:whatsapp/salesforce/controller/template_controller.dart';
import 'package:whatsapp/salesforce/model/chat_history_model.dart';
import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
import 'package:whatsapp/salesforce/widget/chat_bubble.dart';
import 'package:whatsapp/salesforce/widget/multi_select_bottom_sheet.dart';
import 'package:whatsapp/salesforce/widget/chat_buttons.dart';
import 'package:whatsapp/salesforce/widget/chat_date_lable.dart';
import 'package:whatsapp/salesforce/widget/custom_bottom_sheet.dart';
import 'package:whatsapp/salesforce/widget/custom_drop_down.dart';
import 'package:whatsapp/salesforce/widget/header_type_preview.dart';
import 'package:whatsapp/salesforce/widget/pick_media_buttons.dart';
import 'package:whatsapp/salesforce/widget/sf_chat_appbar.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/function_lib.dart';
import 'package:whatsapp/view_models/lead_controller.dart';
import 'package:whatsapp/view_models/user_list_vm.dart';

final GlobalKey<FormState> _addTemplateFormKey = GlobalKey<FormState>();

class SfMessageChatScreen extends StatefulWidget {
  List<SfDrawerItemModel>? pinnedLeadsList;
  bool isFromRecentChat;
  SfMessageChatScreen(
      {super.key, this.pinnedLeadsList, this.isFromRecentChat = false});

  @override
  State<SfMessageChatScreen> createState() => _SfMessageChatScreenState();
}

class _SfMessageChatScreenState extends State<SfMessageChatScreen> {
  TextEditingController msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _previousChatLength = 0;
  // File? _audioFile;
  IO.Socket? socket;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  StreamSubscription? _previewPlayerSubscription;

  String? _audioPath;

  String userNumer = "";

  @override
  void initState() {
    super.initState();
    ChatMessageController chatMsgController =
        Provider.of(context, listen: false);
    isCallAvailable();
    chatMsgController.setSelectedFile(null);
    _initializeAudio();
    // connectSocket();
    getUserNumer();
  }

  bool hasCalls = false;

  isCallAvailable() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";

    Map<String, dynamic> decodedToken = Map<String, dynamic>.from(
      JwtDecoder.decode(token),
    );

    var modulesList = decodedToken['modules'];
    List availableModule =
        modulesList.map((e) => e['name'].toString()).toList();

    List<String> stringList = List<String>.from(availableModule);

    hasCalls = stringList.contains("Calls");
    setState(() {});
  }

  Future<void> _initializeAudio() async {
    await _player.openPlayer();
    await _recorder.openRecorder();
  }

  @override
  void dispose() {
    disconnectSocket();
    _recorder.closeRecorder();
    _player.closePlayer();
    _previewPlayerSubscription?.cancel();
    msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColor.navBarIconColor,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Consumer<ChatMessageController>(builder: (context, ref, child) {
      final currentLength = ref.chatHistoryList.length;

      if (currentLength > _previousChatLength && ref.msgDeleteList.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }

      _previousChatLength = currentLength;
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: FocusDetector(
          onFocusGained: () async {
            final prefs = await SharedPreferences.getInstance();
            prefs.setBool("isOnSFChatPage", true);

            // print("Screen focused again");
            log('\x1B[95mFCM     Leads Screen focused again::::::::::::::::::::::::::::::::::::::::::::::::::');
            ChatMessageController cmProvider =
                Provider.of(context, listen: false);
            DashBoardController dbController =
                Provider.of(context, listen: false);

            final usrNumber =
                dbController.selectedContactInfo?.whatsappNumber ?? "";
            Future.delayed(const Duration(milliseconds: 1), () async {
              await cmProvider.messageHistoryApiCall(
                userNumber: usrNumber,
                isFirstTime: false,
              );
              _scrollToBottom();
            });
            connectSocket();

            Future.delayed(const Duration(milliseconds: 1500), () async {
              await cmProvider.messageHistoryApiCall(
                userNumber: usrNumber,
                isFirstTime: false,
              );
              _scrollToBottom();
            });
          },
          onFocusLost: () async {
            final prefs = await SharedPreferences.getInstance();
            prefs.setBool("isOnSFChatPage", false);
            disconnectSocket();
          },
          child: SafeArea(
            bottom: true,
            child: Scaffold(
              backgroundColor: Colors.white,
              resizeToAvoidBottomInset: true,
              appBar: SfChatAppBar(
                hasCalls: hasCalls,
              ),
              body: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/wp.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: _pullRefresh,
                      child: _pageBody(),
                    ),
                    // Multi-select bottom sheet overlay
                    Consumer<ChatMessageController>(
                      builder: (context, ref, child) {
                        if (ref.isMultiSelectMode &&
                            ref.selectedMessages.isNotEmpty) {
                          final selectedMessages = ref.chatHistoryList
                              .where((msg) =>
                                  ref.selectedMessages.contains(msg.id))
                              .toList();

                          return Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: MultiSelectBottomSheet(
                              selectedMessages: selectedMessages,
                              allMessages: ref.chatHistoryList, chatId: '',
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _pullRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        print("scrolling to the extreme bottom.............");
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  _pageBody() {
    return Consumer<ChatMessageController>(builder: (context, ref, child) {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   if (ref.msgDeleteList.isEmpty) {
      //     _scrollToBottom();
      //   }
      // });

      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              children: [
                if (widget.pinnedLeadsList != null &&
                    widget.pinnedLeadsList!.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 15.0, left: 15, right: 15),
                    child: SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.pinnedLeadsList!.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () async {
                              if (widget.isFromRecentChat) {
                                DashBoardController dashBoardController =
                                    Provider.of(context, listen: false);
                                String phNum =
                                    "${dashBoardController.sfPinnedRecentChatList[index].countryCode ?? ""}${dashBoardController.sfPinnedRecentChatList[index].whatsappNumber ?? ""}";

                                ChatMessageController cmProvider =
                                    Provider.of(context, listen: false);
                                DashBoardController dbProvider =
                                    Provider.of(context, listen: false);
                                dbProvider.setSelectedPinnedInfo(null);

                                dbProvider.setSelectedContaactInfo(
                                    dashBoardController
                                        .sfPinnedRecentChatList[index]);
                                await cmProvider
                                    .messageHistoryApiCall(
                                        userNumber: phNum, isFirstTime: true)
                                    .then((onValue) {});
                              } else {
                                String phNum =
                                    "${widget.pinnedLeadsList?[index].countryCode ?? ""}${widget.pinnedLeadsList?[index].whatsappNumber ?? ""}";

                                ChatMessageController cmProvider =
                                    Provider.of(context, listen: false);
                                DashBoardController dbProvider =
                                    Provider.of(context, listen: false);
                                dbProvider.setSelectedPinnedInfo(null);
                                dbProvider.setSelectedContaactInfo(
                                    widget.pinnedLeadsList?[index]);

                                await cmProvider
                                    .messageHistoryApiCall(
                                  userNumber: phNum,
                                )
                                    .then((onValue) {
                                  // Navigator.pop(navigatorKey.currentContext!);
                                });
                              }

                              // _scrollToBottom();
                            },
                            child: SizedBox(
                              width: 60,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColor.navBarIconColor,
                                    child: Text(
                                      widget.pinnedLeadsList?[index].name
                                                  ?.isNotEmpty ==
                                              true
                                          ? (widget.pinnedLeadsList?[index]
                                                  .name?[0]
                                                  ?.toUpperCase() ??
                                              '?')
                                          : '?',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    widget.pinnedLeadsList?[index].name ?? "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 5,
                          spreadRadius: 3,
                          offset: const Offset(2, 4),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundImage: NetworkImage(
                                  'https://www.w3schools.com/w3images/avatar2.png',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Consumer<DashBoardController>(
                                  builder: (context, dbRef, child) {
                                    return Text(
                                      dbRef.selectedContactInfo?.name ?? "",
                                      style:
                                          const TextStyle(color: Colors.black),
                                    );
                                  },
                                ),
                              ),
                              const Spacer(),
                              Consumer<ChatMessageController>(
                                  builder: (context, msgCtrol, child) {
                                return msgCtrol.msgDeleteList.isEmpty
                                    ? const SizedBox()
                                    : InkWell(
                                        onTap: () {
                                          DashBoardController dbController =
                                              Provider.of(context,
                                                  listen: false);

                                          String code = dbController
                                                  .selectedContactInfo
                                                  ?.countryCode ??
                                              "91";
                                          String num = dbController
                                                  .selectedContactInfo
                                                  ?.whatsappNumber ??
                                              "";
                                          String whatsappNum = "$code$num";
                                          msgCtrol.chatMsgDeleteApiCall(
                                              whatsappNum);
                                        },
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.black,
                                        ),
                                      );
                              }),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert,
                                    color: Colors.black),
                                onSelected: (String value) {
                                  if (value == 'Clear Chat') {
                                    ChatMessageController messageController =
                                        Provider.of(context, listen: false);
                                    DashBoardController dbController =
                                        Provider.of(context, listen: false);

                                    String usrNumber = dbController
                                            .selectedContactInfo
                                            ?.whatsappNumber ??
                                        "";
                                    String code = dbController
                                            .selectedContactInfo?.countryCode ??
                                        "91";
                                    var wpNum = "$code$usrNumber";
                                    messageController
                                        .deleteHistoryApiCall(wpNum);
                                  }
                                },
                                itemBuilder: (BuildContext context) => const [
                                  PopupMenuItem<String>(
                                    value: 'Clear Chat',
                                    child: Text('Clear Chat'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        ref.chatHistoryLoader
                            ? const Padding(
                                padding: EdgeInsets.only(top: 38.0),
                                child: CircularProgressIndicator(
                                  color: AppColor.navBarIconColor,
                                ),
                              )
                            : ref.chatHistoryList.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 28.0),
                                      child: Text(
                                        "No Chat Available..",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      ),
                                    ),
                                  )
                                : Expanded(
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      key: const PageStorageKey<String>(
                                          'chat_message_list'),
                                      itemCount: ref.chatHistoryList.length,
                                      itemBuilder: (context, index) {
                                        final item = ref.chatHistoryList[index];
                                        final currentRaw = item.createdDate;
                                        if (currentRaw == null ||
                                            currentRaw.isEmpty) {
                                          return const SizedBox();
                                        }

                                        final currentTime =
                                            DateTime.parse(currentRaw)
                                                .toUtc()
                                                .add(const Duration(
                                                    hours: 5, minutes: 30));

                                        bool showDateLabel = index == 0;
                                        if (!showDateLabel) {
                                          final prevRaw = ref
                                              .chatHistoryList[index - 1]
                                              .createdDate;
                                          if (prevRaw != null &&
                                              prevRaw.isNotEmpty) {
                                            final prevTime =
                                                DateTime.parse(prevRaw)
                                                    .toUtc()
                                                    .add(const Duration(
                                                        hours: 5, minutes: 30));
                                            showDateLabel = !isSameDay(
                                                currentTime, prevTime);
                                          }
                                          debug(
                                              "item.attachmentUrlitem.attachmentUrl ${item.attachmentUrl}");
                                        }

                                        String tempBody =
                                            item.templateParams!.isEmpty
                                                ? (item.templateBody ?? "")
                                                : replaceTemplateParams(
                                                    item.templateBody ?? "",
                                                    item.templateParams ?? "");

                                        List<ButtonItem> buttons =
                                            (item.button?.isNotEmpty ?? false)
                                                ? item.getParsedButtons()
                                                : [];
                                        final hasAttachment =
                                            item.attachmentUrl != null &&
                                                item.attachmentUrl!
                                                    .trim()
                                                    .isNotEmpty &&
                                                item.attachmentUrl != "null";

                                        final hasContent =
                                            (item.message?.trim().isNotEmpty ??
                                                    false) ||
                                                (item.templateName
                                                        ?.trim()
                                                        .isNotEmpty ??
                                                    false) ||
                                                tempBody.trim().isNotEmpty ||
                                                hasAttachment;
                                        // final hasContent =
                                        //     (item.message?.isNotEmpty ??
                                        //             false) ||
                                        //         (item.templateName
                                        //                 ?.isNotEmpty ??
                                        //             false) ||
                                        //         (tempBody.isNotEmpty) ||
                                        //         (item.attachmentUrl
                                        //                 ?.isNotEmpty ??
                                        //             false);
                                        debug(
                                            "hasContenthasContenthasContenthasContent $hasContent");
                                        if (!hasContent) {
                                          return const SizedBox();
                                        }

                                        return Column(
                                          children: [
                                            if (showDateLabel)
                                              ChatDateLabel(date: currentTime),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 15.0),
                                              child: Container(
                                                color: ref.msgDeleteList
                                                        .contains(
                                                            item.messageId ??
                                                                "")
                                                    ? const Color(0xffE6E6E6)
                                                    : Colors.transparent,
                                                child: ChatBubble(
                                                  tempBody: tempBody,
                                                  item: item,
                                                  buttons: buttons,
                                                  currentTime: currentTime,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                        if (ref.chatHistoryList.isEmpty ||
                            ref.chatHistoryLoader)
                          const Spacer(),
                        _buildMessageInputArea(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Future<void> _stopRecording() async {
    try {
      String? recordedPath = await _recorder.stopRecorder();
      if (recordedPath != null) {
        File audioFile = File(recordedPath);

        ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
        chatMsgCtrl.setSelectedFile(audioFile);

        chatMsgCtrl.setRecordingStatus(false);

        await Future.delayed(const Duration(milliseconds: 300));
        _showPreviewDialog();
      }
    } catch (e) {
      debugPrint("Stop recording error: $e");
      EasyLoading.showToast("Failed to stop recording");
    }
  }

  Future<void> _startRecording(BuildContext context) async {
    ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
    chatMsgCtrl.setSelectedFile(null);

    var status = await Permission.microphone.status;

    if (status.isGranted) {
      // Start recording immediately
      await _beginRecording();
      return;
    }

    PermissionStatus status1 = await Permission.microphone.status;
    print('Microphone permission status: $status1');

    if (status.isDenied) {
      // Request permission (system dialog may show)
      status = await Permission.microphone.request();

      if (status.isGranted) {
        await _beginRecording();
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
      ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
      chatMsgCtrl.setRecordingStatus(true);
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

  Future<void> _showPreviewDialog() async {
    if (_audioPath == null) return;
    // Get duration using just_audio
    final audioPlayerForDuration = AudioPlayer();
    Duration? audioDuration;

    try {
      await audioPlayerForDuration.setFilePath(_audioPath!);
      audioDuration = audioPlayerForDuration.duration;
    } catch (e) {
      print("catching errer in show audio preview dialog:::::::::   $e");
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
        return Consumer<ChatMessageController>(
          builder: (context, chatController, child) {
            Future<void> startPlayer() async {
              await _player.startPlayer(
                fromURI: _audioPath!,
                codec: fs.Codec.aacADTS,
                whenFinished: () {
                  chatController.setPlayPreviewStatus(false);
                },
              );

              chatController.setPlayPreviewStatus(true);

              _previewPlayerSubscription?.cancel();
              _previewPlayerSubscription =
                  _player.onProgress?.listen((event) {});
            }

            Future<void> stopPlayer() async {
              await _player.stopPlayer();
              _previewPlayerSubscription?.cancel();

              chatController.setPlayPreviewStatus(false);
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
                      chatController.isPlayingPreview
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                      size: 48,
                      color: AppColor.navBarIconColor,
                    ),
                    onPressed: () {
                      chatController.isPlayingPreview
                          ? stopPlayer()
                          : startPlayer();
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    stopPlayer();

                    if (chatController.selectedFile != null) {
                      await sendFile();
                    }
                    EasyLoading.showToast("Sending audio...");

                    Navigator.pop(context);
                  },
                  child: const Text('Send'),
                ),
                TextButton(
                  onPressed: () {
                    stopPlayer();
                    chatController.setPlayPreviewStatus(false);
                    chatController.setSelectedFile(null);
                    chatController.setRecordingStatus(false);
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

  _buildMessageInputArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: sendMsgRow(),
    );
  }

  Widget _buildFilePreview(ChatMessageController chatMsgController) {
    if (chatMsgController.selectedFile == null) {
      return const SizedBox();
    }

    File file = chatMsgController.selectedFile!;
    String fileName = file.path.split('/').last;
    String fileExtension = fileName.split('.').last.toLowerCase();

    // Check file type
    bool isImage = ['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension);
    bool isVideo = ['mp4', 'mov', 'avi', 'mkv'].contains(fileExtension);
    bool isAudio = ['mp3', 'aac', 'wav', 'm4a'].contains(fileExtension);

    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: Stack(
        children: [
          // Image Preview
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                file,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),

          // Video Preview
          if (isVideo)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

          // Audio Preview
          if (isAudio)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue[100],
              ),
              child: const Center(
                child: Icon(
                  Icons.audio_file,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
            ),

          // Document Preview
          if (!isImage && !isVideo && !isAudio)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
              child: Center(
                child: Text(
                  fileExtension.length > 3
                      ? fileExtension.substring(0, 3).toUpperCase()
                      : fileExtension.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

          // Close button to remove file
          // Positioned(
          //   top: -5,
          //   right: -5,
          //   child: InkWell(
          //     onTap: () {
          //       chatMsgController.setSelectedFile(null);
          //     },
          //     child: Container(
          //       decoration: const BoxDecoration(
          //         shape: BoxShape.circle,
          //         color: Colors.red,
          //       ),
          //       padding: const EdgeInsets.all(2),
          //       child: const Icon(
          //         Icons.close,
          //         size: 12,
          //         color: Colors.white,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  sendMsgRow() {
    return Consumer3<TemplateController, SfFileUploadController,
            ChatMessageController>(
        builder: (context, tempCtrl, fileUploadController, chatMsgController,
            child) {
      return Column(
        children: [
          const Divider(),
          if (chatMsgController.isRecording)
            const Row(
              children: [
                Icon(Icons.fiber_manual_record, color: Colors.red),
                SizedBox(width: 6),
                Text("Recording..."),
              ],
            ),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Attachment button
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: () {
                        showPicker(context);
                      },
                    ),

                    // File Preview (NEW) - shows actual file thumbnail
                    _buildFilePreview(chatMsgController),

                    // Text Field
                    Expanded(
                      child: TextField(
                        controller: msgController,
                        maxLines: 3,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintMaxLines: 1,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xffE6E6E6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Voice Message Button
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Listener(
                  onPointerDown: (_) => _startRecording(context),
                  onPointerUp: (_) => _stopRecording(),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 168, 205, 235),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      chatMsgController.isRecording
                          ? Icons.stop
                          : Icons.mic_none_sharp,
                      color: chatMsgController.isRecording
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                ),
              ),

              // Template Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: InkWell(
                  onTap: () async {
                    if (tempCtrl.getTempLoader) {
                      return;
                    } else {
                      tempCtrl.setSelectedTemp(null);
                      tempCtrl.setSelectedTempName("Select");
                      tempCtrl.setSeletcedTempCate("ALL");
                      await tempCtrl.getTemplateApiCall(
                        category: tempCtrl.selectedTempCategory,
                      );
                      TemplatebottomSheetShow(context);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff8BBCD0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: tempCtrl.getTempLoader
                            ? const SizedBox(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.code, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),

              // Send Button
              InkWell(
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  ChatMessageController chatMsgCtrl =
                      Provider.of(context, listen: false);

                  if (msgController.text.isNotEmpty &&
                      chatMsgCtrl.selectedFile == null) {
                    await sendMsg(msgController.text.trim());
                  } else if (chatMsgCtrl.selectedFile != null) {
                    await sendFile();
                  } else {
                    EasyLoading.showToast("Type a message or select a file");
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 76, 162, 189),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: chatMsgController.sendMsgLoader == true ||
                              fileUploadController.fileUploadLoader == true
                          ? const SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Future<void> sendMsg(String msg) async {
    if (msg.trim().isEmpty) {
      EasyLoading.showToast("Type something.....",
          toastPosition: EasyLoadingToastPosition.center);
      return;
    }

    ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);

    if (chatMsgCtrl.selectedFile != null) {
      debugPrint("📝 File selected - skipping sendMsg");
      return;
    }

    DashBoardController dbController = Provider.of(context, listen: false);
    ChatMessageController messageController =
        Provider.of(context, listen: false);

    await messageController.sendMessageApiCall(
      msg: msg,
      usrNumber: dbController.selectedContactInfo?.whatsappNumber ?? "",
      code: dbController.selectedContactInfo?.countryCode ?? "91",
    );

    msgController.clear();
    _scrollToBottom();
    FocusScope.of(context).unfocus();
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  getUserNumer() {
    SfFileUploadController sfFileUploadController =
        Provider.of(context, listen: false);

    sfFileUploadController.resetFileUpload();
    ChatMessageController chatMsgController =
        Provider.of(context, listen: false);

    chatMsgController.resetMsgDeleteList();
  }

  // Future<void> sendFile({bool isAudio = false}) async {
  //   SfFileUploadController sfFileController =
  //       Provider.of(context, listen: false);
  //   ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
  //   DashBoardController dbController = Provider.of(context, listen: false);
  //   var usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
  //   var code = dbController.selectedContactInfo?.countryCode ?? "91";

  //   if (chatMsgCtrl.selectedFile != null) {
  //     await sfFileController.uploadFiledb(chatMsgCtrl.selectedFile!, code,
  //         msgController.text.trim(), usrNumber);
  //   }
  //   msgController.clear();
  // }

  Future<void> sendFile({bool isAudio = false}) async {
    SfFileUploadController sfFileController =
        Provider.of(context, listen: false);
    ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
    DashBoardController dbController = Provider.of(context, listen: false);

    var usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
    var code = dbController.selectedContactInfo?.countryCode ?? "91";

    if (chatMsgCtrl.selectedFile != null) {
      EasyLoading.show(status: 'Sending file...', dismissOnTap: false);

      try {
        await sfFileController.uploadFiledb(chatMsgCtrl.selectedFile!, code,
            msgController.text.trim(), usrNumber);

        chatMsgCtrl.setSelectedFile(null);

        msgController.clear();

        EasyLoading.dismiss();
        EasyLoading.showSuccess('File sent!');

        if (mounted) {
          setState(() {});
        }

        Future.delayed(const Duration(seconds: 2), () {});
      } catch (e) {
        EasyLoading.dismiss();
        debugPrint("❌ Error sending file: $e");
        EasyLoading.showError('Failed to send file');
      }
    } else {
      EasyLoading.showToast("No file selected");
    }
  }

  Future<void> connectSocket() async {
    final prefs = await SharedPreferences.getInstance();

    String tkn = prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";
    final busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";

    if (tkn.isEmpty || busNum.isEmpty) {
      print("❌ Missing token or business number for socket connection");
      return;
    } else {
      log("tkn node>>>>>>>>>> $tkn");
    }

    Map<String, dynamic> decodedToken =
        Map<String, dynamic>.from(JwtDecoder.decode(tkn));
    String devId = await getDeviceId();
    // LeadController leadCtrl = Provider.of(context, listen: false);
    BusinessNumberController busNumCtrl = Provider.of(context, listen: false);
    final dbController =
        Provider.of<DashBoardController>(context, listen: false);
    decodedToken.addAll({
      "business_numbers": busNumCtrl.sfAllBusNums,
      "businessNumber": busNum,
      "userId": decodedToken['id'],
      "deviceId": devId
    });

    log("decodedToken>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  $decodedToken");

    print("🔌 Connecting WebSocket with token: ${tkn.substring(0, 20)}...");

    try {
      socket = IO.io(
        'https://admin.watconnect.com',
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setPath('/ibs/socket.io')
            .setExtraHeaders({
              'Authorization': 'Bearer $tkn',
              'Content-Type': 'application/json',
            })
            .setQuery({'token': tkn})
            .enableForceNew()
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .setTimeout(20000)
            .build(),
      );

      socket!.onConnect((_) {
        print('✅ Connected to WebSocket');
        print('🆔 Socket ID: ${socket!.id}');

        socket!.emitWithAck("setup", decodedToken, ack: (response) {
          print('✅ Setup acknowledged: $response');
        });
      });

      /// ❌ Connection error
      socket!.onConnectError((error) {
        print('❌ Connect Error: $error');
      });

      /// ⚠️ Socket error
      socket!.onError((error) {
        print('⚠️ Socket Error: $error');
      });

      /// 🔌 Disconnected
      socket!.onDisconnect((reason) {
        print('🔌 Disconnected: $reason');
      });

      /// 📢 Server confirms setup
      socket!.on("connected", (_) {
        print("🎉 WebSocket setup complete");
      });

      /// 📡 LISTEN TO ALL EVENTS (SAFE)
      socket!.onAny((event, [data]) {
        print("📡 Event: $event");
        print("📦 Data: $data");
      });

      socket!.on("receivedwhatsappmessage", (data) async {
        print("💬 New WhatsApp message received: $data");
        DashBoardController dbController = Provider.of(context, listen: false);

        final usrNumber =
            dbController.selectedContactInfo?.whatsappNumber ?? "";
        print("usrNumberLLLL >>>>>  $usrNumber");

        if (usrNumber.isNotEmpty) {
          print("trying to make api call");
          ChatMessageController cmProvider =
              Provider.of(context, listen: false);

          Future.delayed(const Duration(milliseconds: 1000), () async {
            await cmProvider.messageHistoryApiCall(
              userNumber: usrNumber,
              isFirstTime: false,
            );
            _scrollToBottom();
          });

          _scrollToBottom();
        }
      });

      /// 🔌 Explicit connectP
      socket!.connect();
    } catch (error, stackTrace) {
      print("❌ Error connecting to WebSocket");
      print("Error: $error");
      print("StackTrace: $stackTrace");
    }
  }

  void disconnectSocket() {
    if (socket != null) {
      socket!.disconnect();
      print(" WebSocket Disconnected  recent");
    }
  }
}

String replaceTemplateParams(String templateBody, String paramsJsonString) {
  // log("replacing template params:::   $templateBody   $paramsJsonString");
  try {
    final List<dynamic> paramsList = paramsJsonString.isNotEmpty
        ? List<Map<String, dynamic>>.from((jsonDecode(paramsJsonString) as List)
            .map((e) => e as Map<String, dynamic>))
        : [];

    for (var param in paramsList) {
      print(
          "param['label'] :::  ${param['name']}  param['value']::: ${param['value']} ");
      final name = param['name']?.toString() ?? '';
      final value = param['value']?.toString() ?? '';
      if (name.isNotEmpty) {
        templateBody = templateBody.replaceAll(name, value);
        log("templateBody after replace::::    $templateBody");
      }
    }
  } catch (e) {
    print('Error replacing template params: $e');
  }

  return templateBody;
}

void showPicker(BuildContext context) async {
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
          onTap: () {
            pickImageFromGallery(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.camera_alt, color: Colors.white),
          title: const Text(
            'Take a Photo',
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            pickImageFromCamera(context);
          },
        ),
      ],
    ),
  );
}

Future<void> pickImageFromGallery(context) async {
  final pickedFile = await FilePicker.platform.pickFiles(
    allowMultiple: false,
    type: FileType.custom,
    allowedExtensions: [
      "jpg",
      "jpeg",
      "png",
      "gif",
      "pdf",
      "html",
      "txt",
      "doc",
      "docx",
      "ppt",
      "pptx",
      "xls",
      "xlsx",
      "mp4",
      "mov",
      "avi",
      "mkv",
      "csv",
      "rtf",
      "odt",
      "zip",
      "rar",
    ],
  );
  if (pickedFile != null) {
    // EasyLoading.showToast("Picked Successfully");

    ChatMessageController chatMsgController =
        Provider.of(context, listen: false);
    var file = pickedFile.files.first;
    File image = File(file.path!);
    chatMsgController.setSelectedFile(image);
  }
  Navigator.pop(context);
}

Future<void> pickImageFromCamera(context) async {
  ImagePicker picker = ImagePicker();
  final pickedFile = await picker.pickImage(
    source: ImageSource.camera,
    imageQuality: 80,
  );
  if (pickedFile != null) {
    ChatMessageController chatMsgController =
        Provider.of(context, listen: false);
    File image = File(pickedFile.path);
    chatMsgController.setSelectedFile(image);
  }
  Navigator.pop(context);
}

void TemplatebottomSheetShow(context, {bool isFromCamp = false}) {
  return showCommonBottomSheet(
      context: context,
      title: "Category And Templete",
      col: Consumer<TemplateController>(builder: (context, tempc, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomDropdown(
              items: const [
                'ALL',
                'UTILITY',
                'MARKETING',
              ],
              selectedValue: tempc.selectedTempCategory,
              onChanged: (newVal) async {
                if (newVal != null) {
                  tempc.setSeletcedTempCate(newVal);
                  // selectedCategory = newVal;
                  tempc.setSelectedTempName("Select");

                  tempc.setSelectedTemp(null);
                  await tempc.getTemplateApiCall(
                    category: tempc.selectedTempCategory,
                  );
                }
              },
            ),
            const SizedBox(
              height: 12,
            ),
            CustomDropdown(
              items: tempc.templateNames,
              selectedValue: tempc.selectedTempName,
              enabled: !tempc.getTempLoader,
              onChanged: (newVal) {
                if (newVal != null) {
                  tempc.setSelectedTempName(newVal);
                }
              },
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                if (tempc.selectedTemplate == null) {
                  EasyLoading.showToast("Select Template to continue");
                } else {
                  Navigator.pop(context);
                  SfFileUploadController sfFileUploadController =
                      Provider.of(context, listen: false);

                  sfFileUploadController.resetFileUpload();
                  reviewBottomSheetShow(context, fromCamp: isFromCamp);
                }
              },
              child: IntrinsicWidth(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.navBarIconColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
                    child: Center(
                      child: Text(
                        "Review Template",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
          ],
        );
      }));
}

void reviewBottomSheetShow(BuildContext context, {bool fromCamp = false}) {
  final tempc = Provider.of<TemplateController>(context, listen: false);
  final chatMsgController =
      Provider.of<ChatMessageController>(context, listen: false);

  final templateData = tempc.selectedTemplate;
  final fieldCount = templateData?.storedParameterValues?.length ?? 0;

  tempc.setupControllers(fieldCount);
  chatMsgController.setSelectedFile(null);

  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final maxHeight = MediaQuery.of(context).size.height * 0.8;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            bottom: true,
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 12,
                right: 12,
                top: 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: maxHeight,
                ),
                child: Material(
                  // ensure proper styling
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Consumer2<TemplateController, ChatMessageController>(
                    builder: (context, tempc, chatMsgController, child) {
                      final templateData = tempc.selectedTemplate;
                      final headerType = templateData?.headerType ?? "";
                      List<ButtonItem> buttons =
                          (templateData?.button?.isNotEmpty ?? false)
                              ? templateData!.getParsedButtons()
                              : [];

                      return SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Form(
                          key: _addTemplateFormKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Title Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Review Template",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      ChatMessageController
                                          sfFileUploadController =
                                          Provider.of(context, listen: false);

                                      sfFileUploadController
                                          .setSelectedFile(null);

                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(Icons.cancel_outlined),
                                  )
                                ],
                              ),
                              const Divider(),

                              if (templateData?.name != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    templateData!.name!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),

                              /// Dynamic Text Fields
                              ...List.generate(tempc.textControllers.length,
                                  (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: TextFormField(
                                    controller: tempc.textControllers[index],
                                    cursorColor: AppColor.navBarIconColor,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      labelText: 'Placeholder ${index + 1}',
                                      border: const OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'All fields are required';
                                      }
                                      return null;
                                    },
                                  ),
                                );
                              }),

                              /// Template Preview
                              if ((templateData?.headerText?.isNotEmpty ??
                                      false) ||
                                  (templateData?.body?.isNotEmpty ?? false) ||
                                  (templateData?.footer?.isNotEmpty ?? false) ||
                                  (templateData?.messageBody?.isNotEmpty ??
                                      false) ||
                                  buttons.isNotEmpty)
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffE3FFC9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (["IMAGE", "VIDEO", "DOCUMENT"]
                                          .contains(headerType))
                                        chatMsgController.selectedFile == null
                                            ? HeaderTypePreview(
                                                headerType: headerType)
                                            : buildHeaderPreviewWidget(
                                                file: chatMsgController
                                                    .selectedFile!,
                                                type: headerType,
                                              ),
                                      if (templateData
                                              ?.headerText?.isNotEmpty ??
                                          false)
                                        Text(templateData!.headerText!),
                                      if (templateData?.body?.isNotEmpty ??
                                          false)
                                        Text(templateData!.body!),
                                      if (templateData
                                              ?.messageBody?.isNotEmpty ??
                                          false)
                                        Text(templateData!.messageBody!),
                                      if (templateData?.footer?.isNotEmpty ??
                                          false)
                                        Text(templateData!.footer!),
                                      if (buttons.isNotEmpty)
                                        ChatButtons(buttons: buttons),
                                      PickMediaButton(
                                        label: "Pick $headerType",
                                        onTap: () =>
                                            pickMedia(context, headerType),
                                      ),
                                    ],
                                  ),
                                ),

                              /// Send Button
                              Align(
                                alignment: Alignment.center,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.navBarIconColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (_addTemplateFormKey.currentState!
                                        .validate()) {
                                      if (tempc.sendTempLoader) return;
                                      if (["IMAGE", "VIDEO", "DOCUMENT"]
                                              .contains(headerType) &&
                                          chatMsgController.selectedFile ==
                                              null) {
                                        EasyLoading.showToast(
                                            "Select $headerType to continue");
                                        return;
                                      }

                                      if (fromCamp) {
                                        tempc.resetTempParamList();
                                        // sendCampTemp(
                                        //     context, tempc.textControllers);
                                      } else {
                                        sendChatTemp(
                                            context, tempc.textControllers);
                                      }
                                    }
                                  },
                                  child: tempc.sendTempLoader
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          "Send Template",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      });
}

// Future<void> sendChatTemp(
//     context, List<TextEditingController> controllers) async {
//   debug(" sending template to chat");
//   TemplateController tempc = Provider.of(context, listen: false);
//   var templateData = tempc.selectedTemplate;
//   debug("templateDatatemplateData$templateData");
//   DashBoardController dbController = Provider.of(context, listen: false);

//   var usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
//   var code = dbController.selectedContactInfo?.countryCode ?? "91";
//   var templateCategory = tempc.selectedTempCategory ?? "UTILITY";

//   String userNumer = "$code$usrNumber";
//   List<String> userInputs = controllers.map((e) => e.text.trim()).toList();
//   ChatMessageController chatMsgController = Provider.of(context, listen: false);
//   SfFileUploadController sfFileUploadController =
//       Provider.of(context, listen: false);
//   if (chatMsgController.selectedFile != null) {
//     await sfFileUploadController
//         .uploadFiledb(chatMsgController.selectedFile!, code, "", usrNumber,
//             isFromTemplate: true)
//         .then(
//       (value) {
//         print(
//             "sfFileUploadController.fileDocId::::: ${sfFileUploadController.fileDocId}");
//         print(
//             "sfFileUploadController.filePubUrl,${sfFileUploadController.filePubUrl}");
//         debug("sending template with file");
//         tempc
//             .sendTemplateApiCall(
//                 tempId: templateData?.templateId ?? "",
//                 usrNumber: userNumer,
//                 params: userInputs,
//                 docId: sfFileUploadController.fileDocId,
//                 url: sfFileUploadController.filePubUrl,
//                 mimetyp: sfFileUploadController.fileMimeType,
//                 category: templateCategory)
//             .then((onValue) {
//           Navigator.pop(context);
//         });
//       },
//     );
//   } else {
//     debug("sending template without file");
//     tempc
//         .sendTemplateApiCall(
//             tempId: templateData?.templateId ?? "",
//             usrNumber: userNumer,
//             params: userInputs,
//             category: templateCategory)
//         .then((onValue) {
//       Navigator.pop(context);
//     });
//   }
// }

Future<void> sendChatTemp(
    context, List<TextEditingController> controllers) async {
  debug(" sending template to chat");
  TemplateController tempc = Provider.of(context, listen: false);
  var templateData = tempc.selectedTemplate;
  debug("templateDatatemplateData$templateData");
  DashBoardController dbController = Provider.of(context, listen: false);

  var usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
  var code = dbController.selectedContactInfo?.countryCode ?? "91";
  var templateCategory = tempc.selectedTempCategory ?? "UTILITY";

  String userNumer = "$code$usrNumber";
  List<String> userInputs = controllers.map((e) => e.text.trim()).toList();
  ChatMessageController chatMsgController = Provider.of(context, listen: false);
  SfFileUploadController sfFileUploadController =
      Provider.of(context, listen: false);

  // Reset file upload controller before starting
  sfFileUploadController.resetFileUpload();

  try {
    if (chatMsgController.selectedFile != null) {
      // First upload the file
      await sfFileUploadController.uploadFiledb(
        chatMsgController.selectedFile!,
        code,
        "",
        usrNumber,
        isFromTemplate: true,
      );

      // Check if upload was successful
      if (sfFileUploadController.fileDocId == null ||
          sfFileUploadController.filePubUrl == null) {
        EasyLoading.showToast("File upload failed");
        return;
      }

      debug("sending template with file");

      // Send template with file information
      await tempc
          .sendTemplateApiCall(
        tempId: templateData?.templateId ?? "",
        usrNumber: userNumer,
        params: userInputs,
        docId: sfFileUploadController.fileDocId!,
        url: sfFileUploadController.filePubUrl!,
        mimetyp: sfFileUploadController.fileMimeType ?? "",
        // fileName: chatMsgController.selectedFile?.path.split('/').last ?? "",
        category: templateCategory,
      )
          .then((onValue) {
        // Clear file after successful send
        chatMsgController.setSelectedFile(null);
        Navigator.pop(context);
      });
    } else {
      debug("sending template without file");
      await tempc
          .sendTemplateApiCall(
        tempId: templateData?.templateId ?? "",
        usrNumber: userNumer,
        params: userInputs,
        category: templateCategory,
      )
          .then((onValue) {
        Navigator.pop(context);
      });
    }
  } catch (e) {
    debugPrint("Error sending template: $e");
    EasyLoading.showToast("Failed to send template");
  }
}

// void sendCampTemp(context, List<TextEditingController> controllers) {
//   debug("sending template to campaign");
//   Navigator.pop(context);
//   TemplateController tempc = Provider.of(context, listen: false);
//   List<String> userInputs = controllers.map((e) => e.text.trim()).toList();
//   tempc.setTempParams(userInputs);
//   tempc.setCampTempController(tempc.selectedTempName);

//   // TemplateController tempc = Provider.of(context, listen: false);
//   // var templateData = tempc.selectedTemplate;
//   // DashBoardController dbController = Provider.of(context, listen: false);

//   // var usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
//   // var code = dbController.selectedContactInfo?.countryCode ?? "91";
//   // String userNumer = "${code}${usrNumber}";
//   // List<String> userInputs = controllers.map((e) => e.text.trim()).toList();
//   // print("User Inputs: $userInputs");
// }

Future<void> pickMedia(BuildContext context, String type) async {
  final chatMsgController =
      Provider.of<ChatMessageController>(context, listen: false);

  if (type == "IMAGE") {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      EasyLoading.showToast("Image Picked Successfully");
      chatMsgController.setSelectedFile(File(pickedFile.path));
    }
  } else {
    final extensions = type == "VIDEO"
        ? ["mp4", "mov", "avi", "mkv", "webm"]
        : ["pdf", "txt", "doc", "docx", "ppt", "pptx", "xls", "xlsx", "csv"];

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
    );

    if (result != null) {
      EasyLoading.showToast("$type Picked Successfully");
      chatMsgController.setSelectedFile(File(result.files.first.path!));
    }
  }
}

Widget buildHeaderPreviewWidget({required File file, required String type}) {
  switch (type) {
    case 'IMAGE':
      return Image.file(file, height: 80);
    case 'VIDEO':
      return Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black,
        ),
        child: const Center(
          child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
        ),
      );
    case 'DOCUMENT':
    default:
      return Image.asset("assets/images/file.png", height: 80, width: 80);
  }
}
