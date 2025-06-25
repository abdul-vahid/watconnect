import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart' as fs;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/controller/template_controller.dart';
import 'package:whatsapp/salesforce/model/chat_history_model.dart';
import 'package:whatsapp/salesforce/widget/chat_bubble.dart';
import 'package:whatsapp/salesforce/widget/chat_buttons.dart';
import 'package:whatsapp/salesforce/widget/chat_date_lable.dart';
import 'package:whatsapp/salesforce/widget/custom_bottom_sheet.dart';
import 'package:whatsapp/salesforce/widget/custom_drop_down.dart';
import 'package:whatsapp/salesforce/widget/header_type_preview.dart';
import 'package:whatsapp/salesforce/widget/pick_media_buttons.dart';
import 'package:whatsapp/salesforce/widget/sf_chat_appbar.dart';
import 'package:whatsapp/utils/app_color.dart';

final GlobalKey<FormState> _addTemplateFormKey = GlobalKey<FormState>();

class SfMessageChatScreen extends StatefulWidget {
  const SfMessageChatScreen({super.key});

  @override
  State<SfMessageChatScreen> createState() => _SfMessageChatScreenState();
}

class _SfMessageChatScreenState extends State<SfMessageChatScreen> {
  TextEditingController msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  File? _audioFile;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  StreamSubscription? _previewPlayerSubscription;

  Duration _totalDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  bool _isPlayingPreview = false;
  bool _isRecording = false;
  String? _audioPath;

  String userNumer = "";

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    getUserNumer();
  }

  Future<void> _initializeAudio() async {
    await _player.openPlayer();
    await _recorder.openRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    _previewPlayerSubscription?.cancel();
    msgController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) return;

    Directory tempDir = await getTemporaryDirectory();
    _audioPath = '${tempDir.path}/voice_msg.aac';

    await _recorder.startRecorder(
      toFile: _audioPath,
      codec: fs.Codec.aacADTS,
    );

    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecordingAndPreview() async {
    // await _recorder.stopRecorder();
    String? recordedPath = await _recorder.stopRecorder();

    setState(() {
      _audioFile = File(recordedPath!);
      _isRecording = false;
    });

    print("_audioFile::::::::::::::    ${_audioFile}");

    await Future.delayed(Duration(milliseconds: 300));
    _showPreviewDialog();
  }

  void _showPreviewDialog() async {
    if (_audioPath == null) return;

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
                    _currentPosition = Duration.zero;
                  });
                },
              );

              setState(() {
                _isPlayingPreview = true;
              });

              _previewPlayerSubscription?.cancel();
              _previewPlayerSubscription = _player.onProgress?.listen((event) {
                setState(() {
                  _currentPosition = event.position;
                  _totalDuration = event.duration;
                });
              });
            }

            Future<void> stopPlayer() async {
              await _player.stopPlayer();
              _previewPlayerSubscription?.cancel();
              setState(() {
                _isPlayingPreview = false;
                _currentPosition = Duration.zero;
              });
            }

            return AlertDialog(
              title: const Text('Voice Message Preview'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
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
                  // Slider(
                  //   value: _currentPosition.inMilliseconds.toDouble(),
                  //   max: _totalDuration.inMilliseconds.toDouble() > 0
                  //       ? _totalDuration.inMilliseconds.toDouble()
                  //       : 1,
                  //   onChanged: (value) async {
                  //     final seekTo = Duration(milliseconds: value.toInt());
                  //     await _player.seekToPlayer(seekTo);
                  //     setState(() {
                  //       _currentPosition = seekTo;
                  //     });
                  //   },
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(_formatDuration(_currentPosition)),
                  //     Text(_formatDuration(_totalDuration)),
                  //   ],
                  // ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    stopPlayer();
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatMessageController>(builder: (context, ref, child) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: const SfChatAppBar(),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _pullRefresh,
              child: ref.chatHistoryLoader ? Container() : _pageBody(),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _pullRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 2800,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  _pageBody() {
    return Consumer<ChatMessageController>(builder: (context, ref, child) {
      print("ref.chatHistoryList:::::: ${ref.chatHistoryList.length}");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.msgDeleteList.isEmpty) {
          _scrollToBottom();
        }
      });

      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: ref.chatHistoryList.isEmpty
                  ? const Center(
                      child: Text(
                        "No Chat Available..",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: ref.chatHistoryList.length,
                      itemBuilder: (context, index) {
                        final item = ref.chatHistoryList[index];
                        final currentRaw = item.createdDate;

                        if (currentRaw == null || currentRaw.isEmpty) {
                          return const SizedBox();
                        }

                        final DateTime currentTime = DateTime.parse(currentRaw)
                            .toUtc()
                            .add(const Duration(hours: 5, minutes: 30));

                        bool showDateLabel = index == 0;
                        if (!showDateLabel) {
                          final prevRaw =
                              ref.chatHistoryList[index - 1].createdDate;
                          if (prevRaw != null && prevRaw.isNotEmpty) {
                            final prevTime = DateTime.parse(prevRaw)
                                .toUtc()
                                .add(const Duration(hours: 5, minutes: 30));
                            showDateLabel = !isSameDay(currentTime, prevTime);
                          }
                        }

                        String tempBody = "";

                        if (item.templateParams!.isEmpty) {
                          tempBody = item.templateBody ?? "";
                        } else {
                          tempBody = replaceTemplateParams(
                              item.templateBody ?? "",
                              item.templateParams ?? "");
                        }

                        List<ButtonItem> buttons =
                            (item.button?.isNotEmpty ?? false)
                                ? item.getParsedButtons()
                                : [];

                        final hasContent =
                            (item.message?.isNotEmpty ?? false) ||
                                (item.templateName?.isNotEmpty ?? false) ||
                                (tempBody.isNotEmpty) ||
                                (item.publicUrl?.isNotEmpty ?? false);

                        if (!hasContent) return const SizedBox();

                        return Column(
                          children: [
                            if (showDateLabel) ChatDateLabel(date: currentTime),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: Container(
                                color: ref.msgDeleteList
                                        .contains(item.messageId ?? "")
                                    ? Color(0xffE6E6E6)
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
                    )),
          _buildMessageInputArea(),
        ],
      );
    });
  }

  _buildMessageInputArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isRecording)
            const Row(
              children: [
                Icon(Icons.fiber_manual_record, color: Colors.red),
                SizedBox(width: 6),
                Text("Recording..."),
              ],
            ),
          sendMsgRow(),
        ],
      ),
    );
  }

  sendMsgRow() {
    ChatMessageController chatMsgController =
        Provider.of(context, listen: false);
    return Consumer<TemplateController>(builder: (context, tempCtrl, child) {
      return Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msgController,
                    decoration: InputDecoration(
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: GestureDetector(
                            onLongPress: _startRecording,
                            onLongPressUp: _stopRecordingAndPreview,
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 168, 205, 235),
                                  shape: BoxShape.circle),
                              padding: const EdgeInsets.all(10),
                              child: Icon(
                                _isRecording
                                    ? Icons.stop
                                    : Icons.mic_none_sharp,
                                color: _isRecording ? Colors.red : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color(0xffE6E6E6)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
              onTap: () async {
                if (tempCtrl.getTempLoader) {
                } else {
                  tempCtrl.setSelectedTemp(null);
                  tempCtrl.setSelectedTempName("Select");

                  // selectedCategory = "ALL";
                  tempCtrl.setSeletcedTempCate("ALL");
                  await tempCtrl.getTemplateApiCall(
                      category: tempCtrl.selectedTempCategory);
                  TemplatebottomSheetShow(context);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.navBarIconColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                    child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: tempCtrl.getTempLoader
                      ? Container(
                          height: 25,
                          width: 25,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.code, color: Colors.white),
                )),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              sendMsg(msgController.text);
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.navBarIconColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: chatMsgController.sendMsgLoader == true
                    ? Container(
                        height: 25,
                        width: 25,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
              )),
            ),
          ),
        ],
      );
    });
  }

  sendMsg(String msg) {
    print("we are calling this:::  ${msg}");
    if (msg.trim().isEmpty) {
      EasyLoading.showToast("Type something.....",
          toastPosition: EasyLoadingToastPosition.center);
    } else {
      DashBoardController dbController = Provider.of(context, listen: false);

      ChatMessageController messageController =
          Provider.of(context, listen: false);
      messageController.sendMessageApiCall(
        msg: msg,
        usrNumber: dbController.selectedContactInfo?.whatsappNumber ?? "",
        code: dbController.selectedContactInfo?.countryCode ?? "91",
      );
      msgController.clear();
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  getUserNumer() {
    ChatMessageController chatMsgController =
        Provider.of(context, listen: false);

    chatMsgController.resetMsgDeleteList();
    DashBoardController dbController = Provider.of(context, listen: false);
  }
}

String replaceTemplateParams(String templateBody, String paramsJsonString) {
  try {
    final List<dynamic> paramsList = paramsJsonString.isNotEmpty
        ? List<Map<String, dynamic>>.from((jsonDecode(paramsJsonString) as List)
            .map((e) => e as Map<String, dynamic>))
        : [];

    for (var param in paramsList) {
      final name = param['name']?.toString() ?? '';
      final value = param['value']?.toString() ?? '';
      if (name.isNotEmpty) {
        templateBody = templateBody.replaceAll(name, value);
      }
    }
  } catch (e) {
    print('Error replacing template params: $e');
  }

  return templateBody;
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
                  print("NEW VAL::::: ${tempc.selectedTempName}");
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

void reviewBottomSheetShow(context, {bool fromCamp = false}) {
  return showCommonBottomSheet(
    context: context,
    title: "Review Template",
    col: Consumer<TemplateController>(
      builder: (context, tempc, child) {
        var templateData = tempc.selectedTemplate;

        // Fresh list of controllers every time
        List<TextEditingController> controllers = List.generate(
          templateData?.storedParameterValues?.length ?? 0,
          (_) => TextEditingController(),
        );

        List<ButtonItem> buttons = (templateData?.button?.isNotEmpty ?? false)
            ? templateData!.getParsedButtons()
            : [];

        String headerType = templateData?.headerType ?? "";

        return Center(
          child: Form(
            key: _addTemplateFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Template name
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    templateData?.name ?? "",
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),

                /// Dynamic TextFields
                Column(
                  children: List.generate(
                    controllers.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please provide Placeholder value';
                          }
                          return null;
                        },
                        controller: controllers[index],
                        decoration: InputDecoration(
                          labelText: 'Placeholder ${index + 1}',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ),

                /// Template preview box
                if ((templateData?.headerText?.isNotEmpty ?? false) ||
                    (templateData?.body?.isNotEmpty ?? false) ||
                    (templateData?.footer?.isNotEmpty ?? false) ||
                    (templateData?.messageBody?.isNotEmpty ?? false) ||
                    buttons.isNotEmpty)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xffE3FFC9),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (headerType == "VIDEO" ||
                            headerType == "IMAGE" ||
                            headerType == "DOCUMENT")
                          HeaderTypePreview(
                            headerType: headerType,
                          ),
                        if (templateData?.headerText?.isNotEmpty ?? false)
                          Text(templateData!.headerText!),
                        const SizedBox(height: 5),
                        if (templateData?.body?.isNotEmpty ?? false)
                          Text(templateData!.body!),
                        const SizedBox(height: 5),
                        if (templateData?.messageBody?.isNotEmpty ?? false)
                          Text(templateData!.messageBody!),
                        const SizedBox(height: 5),
                        if (templateData?.footer?.isNotEmpty ?? false)
                          Text(templateData!.footer!),
                        if (buttons.isNotEmpty) ChatButtons(buttons: buttons),
                        if (headerType == "IMAGE")
                          PickMediaButton(
                            label: "Pick Image",
                            onTap: () {},
                          )
                        else if (headerType == "VIDEO")
                          PickMediaButton(
                            label: "Pick Video",
                            onTap: () {},
                          )
                        else if (headerType == "DOCUMENT")
                          PickMediaButton(
                            label: "Pick Document",
                            onTap: () {},
                          )
                      ],
                    ),
                  ),

                /// Send Button
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: InkWell(
                    onTap: () {
                      if (_addTemplateFormKey.currentState!.validate()) {
                        if (tempc.sendTempLoader) {
                        } else {
                          if (fromCamp) {
                            tempc.resetTempParamList();
                            sendCampTemp(context, controllers);
                          } else {
                            sendChatTemp(context, controllers);
                          }
                        }
                      }
                    },
                    child: IntrinsicWidth(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.navBarIconColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 12),
                        child: Center(
                          child: SizedBox(
                            height: 20,
                            width: 120,
                            child: Center(
                              child: tempc.sendTempLoader
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Send Template",
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    ),
  );
}

void sendChatTemp(context, List<TextEditingController> controllers) {
  TemplateController tempc = Provider.of(context, listen: false);
  var templateData = tempc.selectedTemplate;
  print("templateData:::::::::     ${templateData?.templateId ?? ""}");
  DashBoardController dbController = Provider.of(context, listen: false);

  var usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
  var code = dbController.selectedContactInfo?.countryCode ?? "91";
  String userNumer = "${code}${usrNumber}";
  List<String> userInputs = controllers.map((e) => e.text.trim()).toList();
  print("User Inputs: $userInputs");

  tempc
      .sendTemplateApiCall(
          tempId: templateData?.templateId ?? "",
          usrNumber: userNumer,
          params: userInputs)
      .then((onValue) {
    Navigator.pop(context);
  });
}

void sendCampTemp(context, List<TextEditingController> controllers) {
  Navigator.pop(context);
  TemplateController tempc = Provider.of(context, listen: false);
  List<String> userInputs = controllers.map((e) => e.text.trim()).toList();
  tempc.setTempParams(userInputs);
  tempc.setCampTempController(tempc.selectedTempName);

  // TemplateController tempc = Provider.of(context, listen: false);
  // var templateData = tempc.selectedTemplate;
  // DashBoardController dbController = Provider.of(context, listen: false);

  // var usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
  // var code = dbController.selectedContactInfo?.countryCode ?? "91";
  // String userNumer = "${code}${usrNumber}";
  // List<String> userInputs = controllers.map((e) => e.text.trim()).toList();
  // print("User Inputs: $userInputs");
}
