import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/react_side/chat/controller/chat_controller.dart';
import 'package:whatsapp/react_side/chat/page/widget/chat_bubble.dart'
    show ChatBubble;
import 'package:whatsapp/react_side/chat/page/widget/chat_input_bar.dart';
import 'package:whatsapp/react_side/chat/page/widget/contact_header.dart';
import 'package:whatsapp/react_side/chat/page/widget/template_bottom_sheet.dart';
import 'package:whatsapp/react_side/lead/widget/pinned_lead_item.dart';
import 'package:whatsapp/react_side/template/controller/whatsapp_template_controller.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/views/widgets/chat_socket_manager.dart';
import 'package:whatsapp/views/widgets/image_picker_sheet.dart';

class WhatsappChatPage extends StatefulWidget {
  final String name;
  final String leadId;
  final String number;
  String? countryCode;

  WhatsappChatPage({
    super.key,
    required this.name,
    required this.leadId,
    this.countryCode,
    required this.number,
  });

  @override
  State<WhatsappChatPage> createState() => _WhatsappChatPageState();
}

class _WhatsappChatPageState extends State<WhatsappChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  String tenatCode = "";
  bool hasWallet = false;

  @override
  void initState() {
    super.initState();

    final ctrl = context.read<ChatController>();
    final templateCtrl = context.read<WhatsappTemplateController>();

    _init();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ctrl.setSelectedLeadNumber(widget.number);

      await ctrl.fetchInitialChat();
      templateCtrl.getApprovedTemplates();

      _scrollAfterBuild(animated: false);
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    socketManager.dispose();

    super.dispose();
  }

  final socketManager = SocketManager();
  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    hasWallet = prefs.getBool(SharedPrefsConstants.hasWalletKey) ?? false;
    tenatCode = prefs.getString(SharedPrefsConstants.usertenantcodeKey) ?? "";
    setState(() {});
  }

  void _scrollToBottom({bool animated = false}) {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position.maxScrollExtent;

    if (animated) {
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(position);
    }
  }

  void _scrollAfterBuild({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom(animated: animated);
      });
    });
  }

  void _onScroll() {
    final ctrl = context.read<ChatController>();

    if (!_scrollController.hasClients || ctrl.isLoading || !ctrl.hasMore)
      return;

    if (_scrollController.position.pixels <= 200) {
      final beforeOffset = _scrollController.offset;

      ctrl.fetchChatHistory().then((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.jumpTo(
            _scrollController.offset +
                (_scrollController.position.maxScrollExtent - beforeOffset),
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FocusDetector(
        onFocusGained: () {
          final ctrl = context.read<ChatController>();
          ctrl.fetchChatHistory();

          print(
              "itssss gaining focusssss>>>>>>>>>>>>>..>.----------------------------------");

          socketManager.connectSocket(context, widget.number);
        },
        onFocusLost: () => socketManager.disconnectSocket(),
        child: Scaffold(
          backgroundColor: AppColor.pageBgGrey,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text("Chat", style: TextStyle(color: Colors.white)),
          ),
          body: Column(
            children: [
              PinnedLeadsWidget(isFromChat: true),
              ChatContactHeader(
                name: widget.name,
                number: widget.number,
              ),
              Expanded(
                child: Consumer<ChatController>(
                  builder: (_, ctrl, __) {
                    _scrollAfterBuild();

                    return Stack(
                      children: [
                        ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(10),
                          itemCount: ctrl.chatHistoryList.length,
                          itemBuilder: (context, index) {
                            final previousMessage = index > 0
                                ? ctrl.chatHistoryList[index - 1]
                                : null;

                            final chat = ctrl.chatHistoryList[index];

                            return ChatBubble(
                              key: ValueKey(chat.id),
                              message: chat,
                              isMe: chat.status == "Outgoing",
                              tenetCode: tenatCode,
                              previousMessage: previousMessage,
                            );
                          },
                        ),
                        if (ctrl.isLoading)
                          const Positioned(
                            top: 10,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              ChatInputBar(
                controller: _messageController,
                onSend: _handleSendMessage,
                onAttach: _showPicker,
                onCodeClick: () {
                  TemplateBottomSheet.show(
                    context: context,
                    leadName: widget.name,
                    leadNumber: widget.number,
                    leadId: widget.leadId,
                  ).then(
                    (value) {
                      _scrollAfterBuild();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSendMessage() async {
    final ctrl = context.read<ChatController>();

    if (ctrl.isSending) return;

    final text = _messageController.text.trim();
    final file = ctrl.fileToSend;

    if (text.isEmpty && file == null) return;

    ctrl.setSending(true);

    try {
      if (file != null) {
        await sendFile("document", text);
        ctrl.clearFile();
      } else {
        await messagesendd(text);
      }

      _messageController.clear();

      await ctrl.refetchSamePage();

      _scrollAfterBuild();
    } finally {
      ctrl.setSending(false);
    }
  }

  void _showPicker() async {
    File? pickedFile = await ImagePickerBottomSheet.show(context);
    if (pickedFile != null) {
      context.read<ChatController>().setFileToSend(pickedFile);
    }
  }

  Future<void> sendFile(String type, String caption) async {
    final messageVM = context.read<ChatController>();
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');

    final file = messageVM.fileToSend;
    if (file == null) return;

    final uploadResponse = await messageVM.uploadFile(file, phoneNumber);
    final documentId = jsonDecode(uploadResponse)['id'];

    final payload = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": widget.number,
      "type": type,
      type: {"id": documentId, "caption": caption}
    };

    await messageVM.uploadimagewithdoucmentid(payload, phoneNumber);

    _scrollAfterBuild();
  }

  Future<void> messagesendd(String text) async {
    final ms = context.read<ChatController>();
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');

    var value = await ms.sendMessage(
      addmsModel: {
        "messaging_product": "whatsapp",
        "recipient_type": "individual",
        "to": widget.number,
        "type": "text",
        "text": {"preview_url": false, "body": text}
      },
    );

    var messageId = value['messages'];

    await ms.sendmsgmobile(
      msgmobilbody: {
        "parent_id": widget.leadId,
        "message": text,
        "status": "Outgoing",
        "business_number": number,
        "message_id": messageId[0]['id'],
        "name": widget.name,
        "message_template_id": null,
        "whatsapp_number": widget.number,
        "recordtypename": "recentlyMessage",
        "file_id": null,
        "is_read": true,
        "interactive_id": null
      },
    );

    _scrollAfterBuild();
  }
}
