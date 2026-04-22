import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/react_side/chat/controller/chat_controller.dart';
import 'package:whatsapp/react_side/chat/page/widget/chat_bubble.dart'
    show ChatBubble;
import 'package:whatsapp/react_side/chat/page/widget/chat_input_bar.dart';
import 'package:whatsapp/react_side/chat/page/widget/contact_header.dart';
import 'package:whatsapp/react_side/lead/widget/pinned_lead_item.dart';
import 'package:whatsapp/react_side/template/controller/whatsapp_template_controller.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/utils/app_utils.dart';
import 'package:whatsapp/view_models/wallet_controller.dart';
import 'package:whatsapp/views/widgets/image_picker_sheet.dart';
import 'package:whatsapp/views/widgets/review_edit_temp_sheet.dart';
import 'package:path/path.dart' as path;

class WhatsappChatPage extends StatefulWidget {
  final String name;
  final String leadId;
  final String number;
  final String countryCode;

  const WhatsappChatPage({
    super.key,
    required this.name,
    required this.leadId,
    required this.countryCode,
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

  Map<String, Map<String, dynamic>> allTemplatesMap = {};
  List<dynamic> tempateCategory = [
    'All Categories',
    'UTILITY',
    'MARKETING',
  ];
  File? _audioFile;
  List<TextEditingController> controllers = [];
  String? SelectedTemplateCategory;
  String? selectedTemplateName;
  List<String> templateNames = [];

  @override
  void initState() {
    super.initState();

    final ctrl = context.read<ChatController>();
    final ctrl2 = context.read<WhatsappTemplateController>();

    _init();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ctrl.setSelectedLeadNumber(widget.number);
      await ctrl.fetchInitialChat();
      ctrl2.getApprovedTemplates();
      _scrollToBottom();
    });

    _scrollController.addListener(_onScroll);
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    hasWallet = prefs.getBool(SharedPrefsConstants.hasWalletKey) ?? false;
    tenatCode = prefs.getString(SharedPrefsConstants.usertenantcodeKey) ?? "";
    setState(() {});
  }

  void _onScroll() {
    final ctrl = context.read<ChatController>();

    if (!_scrollController.hasClients || ctrl.isLoading || !ctrl.hasMore)
      return;

    if (_scrollController.position.extentAfter < 200) {
      ctrl.fetchChatHistory();
    }
  }

  void _scrollToBottom() {
    print("screolling to bottom");
    if (!_scrollController.hasClients) return;

    _scrollController.jumpTo(
      _scrollController.position.maxScrollExtent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColor.pageBgGrey,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Chat",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            const PinnedLeadsWidget(),
            ChatContactHeader(
              name: widget.name,
              number: widget.number,
            ),

            /// CHAT LIST
            Expanded(
              child: Consumer<ChatController>(
                builder: (_, ctrl, __) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    itemCount:
                        ctrl.chatHistoryList.length + (ctrl.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == ctrl.chatHistoryList.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final chat = ctrl.chatHistoryList[index];

                      return ChatBubble(
                        key: ValueKey(chat.id),
                        message: chat,
                        isMe: chat.status == "Outgoing",
                        tenetCode: tenatCode,
                        previousMessage:
                            index > 0 ? ctrl.chatHistoryList[index - 1] : null,
                      );
                    },
                  );
                },
              ),
            ),

            /// ✅ NEW INPUT BAR
            ChatInputBar(
              controller: _messageController,
              onSend: _handleSendMessage,
              onAttach: _showPicker,
              onCodeClick: _getBootmSheet,
            ),
          ],
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
        final ext = path.extension(file.path).toLowerCase();

        if (['.jpg', '.jpeg', '.png'].contains(ext)) {
          await sendFile("image", text);
        } else if (['.mp4', '.mov'].contains(ext)) {
          await sendFile("video", text);
        } else {
          await sendFile("document", text);
        }

        ctrl.clearFile();
      } else {
        await messagesendd(text);
      }

      _messageController.clear();

      await ctrl.refetchSamePage();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      debugPrint("Send error: $e");
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

  Future<void> _getBootmSheet() {
    TextEditingController templateController = TextEditingController();

    SelectedTemplateCategory = null;
    selectedTemplateName = null;
    final ctrl2 = context.read<WhatsappTemplateController>();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Category And Template"),
                  AppUtils.getDropdown(
                    'Select Category',
                    data: tempateCategory,
                    onChanged: (val) {
                      setState(() {
                        SelectedTemplateCategory = val;
                        selectedTemplateName = null;
                        templateNames = [];

                        if (SelectedTemplateCategory != null) {
                          String categoryKey =
                              SelectedTemplateCategory!.toLowerCase();

                          if (SelectedTemplateCategory != 'All Categories') {
                          
                           templateNames = ctrl2.approvedTemplatedList
    .map((e) => e.name ?? '')
    .toSet()
    .toList();

                           
                          } else {
                            final ctrl =
                                context.read<WhatsappTemplateController>();

                            ctrl.getApprovedTemplates();
                          }
                        }
                      });
                    },
                    value: SelectedTemplateCategory,
                  ),

                 const SizedBox(height: 15,),
                  AppUtils.getDropdown(
                    'Select Template Name',
                    data: templateNames,
                    onChanged: (val) {
                      setState(() {
                        selectedTemplateName = val;
                      });
                      _setSelectedTemplates(); 
                    },
                    value: selectedTemplateName,
                  ),
                   const SizedBox(height: 15,),
                  ElevatedButton(
                    
                    onPressed: () {
                      final msgViewModel =
                                context.read<ChatController>();
                      if (selectedTemplateName == null) {
                           EasyLoading.showToast("Select Template Name");
                        return;}

                      Navigator.pop(context);
                        msgViewModel.setMainBodyParams({});
                      _sendTemplateSheet(); // kept
                    },
                    child: const Text("Send",),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _sendTemplateSheet() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TemplateSheetHelper(
        controllers: controllers,
        leadName: widget.name,
        leadNum: widget.number,
        ledid: widget.leadId,
      ),
    );
  }

  Future<void> _setSelectedTemplates() async {
    final templeteCtrl = context.read<WhatsappTemplateController>();
    final msgViewModel = context.read<ChatController>();

    for (var record in templeteCtrl.approvedTemplatedList) {
      if (record.status == "APPROVED" && selectedTemplateName == record.name) {
        msgViewModel.setSelectedTempId(record.id);
        msgViewModel.setSelectedTempName(record.name);

        for (var e in record.components ?? []) {
          switch (e.type) {
            case "HEADER":
              msgViewModel.setSelectedHeader(e);
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

  Future<void> sendFile(String type, String caption) async {
    debugPrint("Sending file...");

    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');
    final messageVM = Provider.of<ChatController>(context, listen: false);
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
              "to": widget.number,
              "type": type,
              type: {
                "id": documentId,
              },
            }
          : {
              "messaging_product": "whatsapp",
              "recipient_type": "individual",
              "to": widget.number,
              "type": type,
              type: {
                "id": documentId,
                "caption": caption,
              },
            };
      debugPrint("Sending to WhatsApp => $whatsappPayload");

      await messageVM.uploadimagewithdoucmentid(
        whatsappPayload,
        phoneNumber,
      );

      final leadId = widget.leadId;
      final dbResponse =
          await messageVM.uploadFiledb(file, phoneNumber, leadId);
      final fileId = jsonDecode(dbResponse)['records']?[0]?['id'];

      debugPrint("Uploaded to DB. File ID: $fileId");

      final messageHistoryData = {
        "parent_id": leadId,
        "name": widget.name,
        "message_template_id": null,
        "whatsapp_number": widget.number,
        "message": caption,
        "status": "Outgoing",
        "recordtypename": "lead",
        "file_id": fileId,
        "business_number": phoneNumber,
        "is_read": true,
      };

      await messageVM.sendImageHistory(messageHistoryData);
      debugPrint("✅ Message history updated successfully.");
    } catch (e) {
      debugPrint("❌ Error in sendFile: $e");
    } finally {
      debugPrint("📤 File sending process complete.");
    }
  }

  Future<void> messagesendd(String text) async {
    try {
      final ms = Provider.of<ChatController>(context, listen: false);
      // MessageViewModel ms = MessageViewModel(context);
      final prefs = await SharedPreferences.getInstance();
      String? number = prefs.getString('phoneNumber');

      var leadnumber = widget.number;
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
        "parent_id": widget.leadId,
        "name": widget.name,
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
        _scrollToBottom();
      }
    } catch (error) {
      print("errore in sending message::::  $error");
    }
  }
}
