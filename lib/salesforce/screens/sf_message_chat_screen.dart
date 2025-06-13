import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/controller/template_controller.dart';
import 'package:whatsapp/salesforce/model/chat_history_model.dart';
import 'package:whatsapp/salesforce/widget/chat_bubble.dart';
import 'package:whatsapp/salesforce/widget/chat_buttons.dart';
import 'package:whatsapp/salesforce/widget/chat_date_lable.dart';
import 'package:whatsapp/salesforce/widget/custom_bottom_sheet.dart';
import 'package:whatsapp/salesforce/widget/custom_drop_down.dart';
import 'package:whatsapp/salesforce/widget/sf_chat_appbar.dart';
import 'package:whatsapp/utils/app_color.dart';

class SfMessageChatScreen extends StatefulWidget {
  const SfMessageChatScreen({super.key});

  @override
  State<SfMessageChatScreen> createState() => _SfMessageChatScreenState();
}

class _SfMessageChatScreenState extends State<SfMessageChatScreen> {
  TextEditingController msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String selectedCategory = "ALL";
  String userNumer = "";

  @override
  void initState() {
    super.initState();
    getUserNumer();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Future.delayed(const Duration(milliseconds: 500), () {
    //     _scrollToBottom();
    //   });
    // });
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

                        List<ButtonItem> buttons =
                            (item.button?.isNotEmpty ?? false)
                                ? item.getParsedButtons()
                                : [];

                        final hasContent =
                            (item.message?.isNotEmpty ?? false) ||
                                (item.templateName?.isNotEmpty ?? false) ||
                                (item.templateBody?.isNotEmpty ?? false) ||
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
        child: sendMsgRow());
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

  void bottomSheetShow() {
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
                selectedValue: selectedCategory,
                onChanged: (newVal) async {
                  if (newVal != null) {
                    setState(() {
                      selectedCategory = newVal;
                      tempc.setSelectedTempName("Select");
                    });
                    tempc.setSelectedTemp(null);
                    await tempc.getTemplateApiCall(category: selectedCategory);
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
                    setState(() {
                      tempc.setSelectedTempName(newVal);
                      print("NEW VAL::::: ${tempc.selectedTempName}");
                    });
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
                    reviewBottomSheetShow();
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
                  setState(() {
                    selectedCategory = "ALL";
                  });
                  await tempCtrl.getTemplateApiCall(category: selectedCategory);
                  bottomSheetShow();
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

  getUserNumer() {
    DashBoardController dbController = Provider.of(context, listen: false);
    ChatMessageController chatMsgController =
        Provider.of(context, listen: false);

    chatMsgController.resetMsgDeleteList();

    var usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
    var code = dbController.selectedContactInfo?.countryCode ?? "91";
    setState(() {
      userNumer = "${code}${usrNumber}";
    });
  }

  void reviewBottomSheetShow() {
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

          return Center(
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
                      child: TextField(
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
                      ],
                    ),
                  ),

                /// Send Button
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: InkWell(
                    onTap: () {
                      if (tempc.sendTempLoader) {
                      } else {
                        List<String> userInputs =
                            controllers.map((e) => e.text.trim()).toList();
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
          );
        },
      ),
    );
  }
}
