import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/react_side/chat/controller/chat_controller.dart';
import 'package:whatsapp/react_side/chat/page/widget/chat_bubble.dart';
import 'package:whatsapp/react_side/chat/page/widget/chat_input_bar.dart';
import 'package:whatsapp/react_side/chat/page/widget/contact_header.dart';
import 'package:whatsapp/react_side/chat/page/widget/template_bottom_sheet.dart';
import 'package:whatsapp/react_side/lead/controller/lead_list_controller.dart';
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

  final socketManager = SocketManager();

  String tenatCode = "";
  bool hasWallet = false;

  @override
  void initState() {
    super.initState();
print("widget.name>>>>>${widget.name}");
    final ctrl = context.read<ChatController>();
        final leadCtrl = context.read<LeadListController>();
    final templateCtrl = context.read<WhatsappTemplateController>();
    socketManager.connectSocket(context, widget.number);
    _init();

    WidgetsBinding.instance.addPostFrameCallback((_) async {

             
      await ctrl.fetchInitialChat();
      templateCtrl.getApprovedTemplates();
                       ChatController chatCtrl=Provider.of(context,listen: false);

                      chatCtrl.markChatAsRead(widget.number);


      // ✅ scroll after first load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    socketManager.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    hasWallet = prefs.getBool(SharedPrefsConstants.hasWalletKey) ?? false;
    tenatCode =
        prefs.getString(SharedPrefsConstants.usertenantcodeKey) ?? "";
    setState(() {});
  }

  // ✅ simple and stable scroll
void _scrollToBottom({bool animated = false, int retry = 0}) {
  if (!_scrollController.hasClients) return;

  final bottom = _scrollController.position.maxScrollExtent;

  if (animated) {
    _scrollController.animateTo(
      bottom,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  } else {
    _scrollController.jumpTo(bottom);
  }

  // ✅ CRITICAL: Retry if not fully reached
  if (retry < 5) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_scrollController.hasClients) return;

      final newBottom = _scrollController.position.maxScrollExtent;

      if ((_scrollController.offset - newBottom).abs() > 20) {
        _scrollToBottom(animated: animated, retry: retry + 1);
      }
    });
  }
}
  bool get _isNearBottom {
    if (!_scrollController.hasClients) return true;
    return _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;
  }

  // ✅ pagination
  void _onScroll() {
    final ctrl = context.read<ChatController>();

    if (!_scrollController.hasClients ||
        ctrl.isLoading ||
        !ctrl.hasMore) return;

    if (_scrollController.position.pixels <= 100) {
      final oldMax = _scrollController.position.maxScrollExtent;

      ctrl.fetchChatHistory().then((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final newMax = _scrollController.position.maxScrollExtent;
          final diff = newMax - oldMax;

          _scrollController.jumpTo(_scrollController.offset + diff);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FocusDetector(
        onFocusGained: () {
          // socketManager.connectSocket(context, widget.number);
        },
        onFocusLost: () => socketManager.disconnectSocket(),
        child: Scaffold(
          backgroundColor: AppColor.pageBgGrey,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text("Chat", style: TextStyle(color: Colors.white)),
          ),
          body: Consumer2<ChatController,LeadListController>(
                      builder: (_, ctrl,leadCtrl, __) {
              return Column(
                children: [
                  PinnedLeadsWidget(isFromChat: true),
              
                  ChatContactHeader(
                    name: widget.name.isNotEmpty? widget.name:leadCtrl.leadDetail?.contactname??"",
                    number: widget.number,
                  ),
              
                  Expanded(
                    child: 
                         Stack(
                          children: [
                            ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(10),
                              physics: const BouncingScrollPhysics(),
                              itemCount: ctrl.chatHistoryList.length,
                              itemBuilder: (context, index) {
                                final chat = ctrl.chatHistoryList[index];
              
                                final previousMessage =
                                    index > 0
                                        ? ctrl.chatHistoryList[index - 1]
                                        : null;
              
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
                        )
                      
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
                      ).then((_) async {
                        final ctrl = context.read<ChatController>();
              
                        await ctrl.fetchInitialChat();
              
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottom(animated: true);
                        });
                      });
                    },
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  // ✅ SINGLE SOURCE OF TRUTH
Future<void> _handleSendMessage() async {
  final ctrl = context.read<ChatController>();

  if (ctrl.isSending) return;

  final text = _messageController.text.trim();
  final file = ctrl.fileToSend;

  if (text.isEmpty && file == null) return;

  ctrl.setSending(true);

  try {
    if (file != null) {
      final fileType = _getFileType(file.path);

      await sendFile(fileType, text);
      ctrl.clearFile();
    } else {
      await messagesendd(text);
    }

    _messageController.clear();

    await ctrl.fetchInitialChat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animated: true);
    });

  } finally {
    ctrl.setSending(false);
  }
}

String _getFileType(String path) {
  final extension = path.split('.').last.toLowerCase();

  const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

  if (imageExtensions.contains(extension)) {
    return "image";
  }

  return "document";
}

  void _showPicker() async {
    File? pickedFile = await ImagePickerBottomSheet.show(context);
    if (pickedFile != null) {
      context.read<ChatController>().setFileToSend(null);
      context.read<ChatController>().setFileToSend(pickedFile);
    }
  }

  Future<void> sendFile(String type, String caption) async {
    final messageVM = context.read<ChatController>();
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');

    final file = messageVM.fileToSend;
    if (file == null) return;

    final uploadResponse =
        await messageVM.uploadFile(file, phoneNumber);

    final documentId = jsonDecode(uploadResponse)['id'];

    final payload = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": widget.number,
      "type": type,
      type: {"id": documentId, "caption": caption}
    };

    await messageVM.uploadimagewithdoucmentid(payload, phoneNumber);
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
  }
}