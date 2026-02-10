// // // // ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, avoid_print, must_be_immutable, deprecated_member_use
// // // // ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, avoid_print, must_be_immutable, deprecated_member_use

// // // import 'dart:async';
// // // import 'dart:convert';
// // // import 'dart:developer';
// // // import 'dart:io';
// // // import 'dart:math';
// // // import 'package:file_picker/file_picker.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:flutter_easyloading/flutter_easyloading.dart';
// // // import 'package:focus_detector/focus_detector.dart';
// // // import 'package:image_picker/image_picker.dart';
// // // import 'package:just_audio/just_audio.dart';
// // // import 'package:jwt_decoder/jwt_decoder.dart';
// // // import 'package:provider/provider.dart';
// // // import 'package:flutter_sound/flutter_sound.dart' as fs;
// // // import 'package:flutter_sound/flutter_sound.dart';
// // // import 'package:path_provider/path_provider.dart';
// // // import 'package:permission_handler/permission_handler.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import 'package:socket_io_client/socket_io_client.dart' as IO;
// // // import 'package:socket_io_common/src/util/event_emitter.dart';
// // // import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
// // // import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
// // // import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
// // // import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
// // // import 'package:whatsapp/salesforce/controller/template_controller.dart';
// // // import 'package:whatsapp/salesforce/model/chat_history_model.dart';
// // // import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
// // // import 'package:whatsapp/salesforce/widget/chat_bubble.dart';
// // // import 'package:whatsapp/salesforce/widget/chat_buttons.dart';
// // // import 'package:whatsapp/salesforce/widget/chat_date_lable.dart';
// // // import 'package:whatsapp/salesforce/widget/custom_bottom_sheet.dart';
// // // import 'package:whatsapp/salesforce/widget/custom_drop_down.dart';
// // // import 'package:whatsapp/salesforce/widget/header_type_preview.dart';
// // // import 'package:whatsapp/salesforce/widget/pick_media_buttons.dart';
// // // import 'package:whatsapp/salesforce/widget/sf_chat_appbar.dart';
// // // import 'package:whatsapp/utils/app_color.dart';
// // // import 'package:whatsapp/utils/app_constants.dart';
// // // import 'package:whatsapp/utils/function_lib.dart';
// // // import 'package:whatsapp/view_models/lead_controller.dart';
// // // import 'package:whatsapp/view_models/user_list_vm.dart';

// // // final GlobalKey<FormState> _addTemplateFormKey = GlobalKey<FormState>();

// // // class SfMessageChatScreen extends StatefulWidget {
// // //   List<SfDrawerItemModel>? pinnedLeadsList;
// // //   bool isFromRecentChat;
// // //   SfMessageChatScreen(
// // //       {super.key, this.pinnedLeadsList, this.isFromRecentChat = false});

// // //   @override
// // //   State<SfMessageChatScreen> createState() => _SfMessageChatScreenState();
// // // }

// // // class _SfMessageChatScreenState extends State<SfMessageChatScreen> {
// // //   TextEditingController msgController = TextEditingController();
// // //   final ScrollController _scrollController = ScrollController();
// // //   int _previousChatLength = 0;
// // //   IO.Socket? socket;
// // //   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
// // //   final FlutterSoundPlayer _player = FlutterSoundPlayer();

// // //   StreamSubscription? _previewPlayerSubscription;
// // //   String? _audioPath;
// // //   String userNumer = "";
// // //   bool _isSocketConnected = false;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // //       _initializeChat();
// // //     });
// // //   }

// // //   Future<void> _initializeChat() async {
// // //     try {
// // //       ChatMessageController chatMsgController =
// // //           Provider.of(context, listen: false);
// // //       isCallAvailable();
// // //       chatMsgController.setSelectedFile(null);
// // //       await _initializeAudio();
// // //       getUserNumer();

// // //       // ✅ Load initial chat messages
// // //       await _loadInitialMessages();

// // //       // ✅ Connect socket after messages are loaded
// // //       await connectSocket();
// // //     } catch (e) {
// // //       debugPrint("❌ Error initializing chat: $e");
// // //     }
// // //   }

// // //   Future<void> _loadInitialMessages() async {
// // //     try {
// // //       DashBoardController dbController = Provider.of(context, listen: false);
// // //       ChatMessageController chatMsgController =
// // //           Provider.of(context, listen: false);

// // //       final usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
// // //       final countryCode = dbController.selectedContactInfo?.countryCode ?? "91";
// // //       final fullNumber = "$countryCode$usrNumber";

// // //       debugPrint("📱 Loading messages for: $fullNumber");

// // //       if (usrNumber.isNotEmpty) {
// // //         await chatMsgController.messageHistoryApiCall(
// // //           userNumber: usrNumber,
// // //           isFirstTime: true,
// // //         );

// // //         // ✅ Scroll to bottom after messages load
// // //         _scrollToBottom();
// // //       } else {
// // //         debugPrint("❌ No user number found for loading messages");
// // //       }
// // //     } catch (e) {
// // //       debugPrint("❌ Error loading initial messages: $e");
// // //     }
// // //   }

// // //   bool hasCalls = false;

// // //   Future<void> isCallAvailable() async {
// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();
// // //       final token = prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";

// // //       if (token.isEmpty) {
// // //         debugPrint("❌ No Salesforce token found");
// // //         return;
// // //       }

// // //       Map<String, dynamic> decodedToken = Map<String, dynamic>.from(
// // //         JwtDecoder.decode(token),
// // //       );

// // //       var modulesList = decodedToken['modules'] ?? [];
// // //       List availableModule =
// // //           modulesList.map((e) => e['name'].toString()).toList();

// // //       List<String> stringList = List<String>.from(availableModule);
// // //       hasCalls = stringList.contains("Calls");

// // //       if (mounted) {
// // //         setState(() {});
// // //       }
// // //     } catch (e) {
// // //       debugPrint("❌ Error checking call availability: $e");
// // //     }
// // //   }

// // //   Future<void> _initializeAudio() async {
// // //     try {
// // //       await _player.openPlayer();
// // //       await _recorder.openRecorder();
// // //       debugPrint("✅ Audio initialized successfully");
// // //     } catch (e) {
// // //       debugPrint("❌ Error initializing audio: $e");
// // //     }
// // //   }

// // //   @override
// // //   void dispose() {
// // //     disconnectSocket();
// // //     _recorder.closeRecorder();
// // //     _player.closePlayer();
// // //     _previewPlayerSubscription?.cancel();
// // //     msgController.dispose();
// // //     _scrollController.dispose();
// // //     super.dispose();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     SystemChrome.setSystemUIOverlayStyle(
// // //       const SystemUiOverlayStyle(
// // //         statusBarColor: AppColor.navBarIconColor,
// // //         statusBarIconBrightness: Brightness.dark,
// // //         statusBarBrightness: Brightness.light,
// // //       ),
// // //     );

// // //     return Consumer<ChatMessageController>(builder: (context, ref, child) {
// // //       // ✅ Debug chat history
// // //       debugPrint("📊 Chat History Count: ${ref.chatHistoryList.length}");
// // //       debugPrint("📊 Chat Loader Status: ${ref.chatHistoryLoader}");

// // //       if (ref.chatHistoryList.isNotEmpty) {
// // //         debugPrint("📊 First message: ${ref.chatHistoryList.first.message}");
// // //         debugPrint(
// // //             "📊 First message ID: ${ref.chatHistoryList.first.messageId}");
// // //       }

// // //       final currentLength = ref.chatHistoryList.length;
// // //       if (currentLength > _previousChatLength && ref.msgDeleteList.isEmpty) {
// // //         WidgetsBinding.instance.addPostFrameCallback((_) {
// // //           _scrollToBottom();
// // //         });
// // //       }
// // //       _previousChatLength = currentLength;

// // //       return GestureDetector(
// // //         onTap: () => FocusScope.of(context).unfocus(),
// // //         child: FocusDetector(
// // //           onFocusGained: () async {
// // //             debugPrint("📱 Chat Screen focused");
// // //             final prefs = await SharedPreferences.getInstance();
// // //             prefs.setBool("isOnSFChatPage", true);

// // //             // ✅ Refresh messages when screen gains focus
// // //             await _refreshMessages();

// // //             // ✅ Reconnect socket if disconnected
// // //             if (!_isSocketConnected) {
// // //               await connectSocket();
// // //             }
// // //           },
// // //           onFocusLost: () async {
// // //             debugPrint("📱 Chat Screen lost focus");
// // //             final prefs = await SharedPreferences.getInstance();
// // //             prefs.setBool("isOnSFChatPage", false);
// // //             disconnectSocket();
// // //           },
// // //           child: SafeArea(
// // //             bottom: true,
// // //             child: Scaffold(
// // //               backgroundColor: Colors.white,
// // //               resizeToAvoidBottomInset: true,
// // //               appBar: SfChatAppBar(hasCalls: hasCalls),
// // //               body: Stack(
// // //                 children: [
// // //                   RefreshIndicator(
// // //                     onRefresh: _pullRefresh,
// // //                     child: _pageBody(),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),
// // //         ),
// // //       );
// // //     });
// // //   }

// // //   Future<void> _refreshMessages() async {
// // //     try {
// // //       DashBoardController dbController = Provider.of(context, listen: false);
// // //       ChatMessageController cmProvider = Provider.of(context, listen: false);

// // //       final usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
// // //       if (usrNumber.isNotEmpty) {
// // //         await cmProvider.messageHistoryApiCall(
// // //           userNumber: usrNumber,
// // //           isFirstTime: false,
// // //         );
// // //         _scrollToBottom();
// // //       }
// // //     } catch (e) {
// // //       debugPrint("❌ Error refreshing messages: $e");
// // //     }
// // //   }

// // //   Future<void> _pullRefresh() async {
// // //     await _refreshMessages();
// // //   }

// // //   void _scrollToBottom() {
// // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // //       if (_scrollController.hasClients && mounted) {
// // //         final maxScroll = _scrollController.position.maxScrollExtent;
// // //         if (maxScroll > 0) {
// // //           _scrollController.animateTo(
// // //             maxScroll,
// // //             duration: const Duration(milliseconds: 300),
// // //             curve: Curves.easeOut,
// // //           );
// // //         }
// // //       }
// // //     });
// // //   }

// // //   Widget _pageBody() {
// // //     return Consumer<ChatMessageController>(
// // //       builder: (context, ref, child) {
// // //         // ✅ Debug info
// // //         debugPrint(
// // //             "🔄 Building page body - Chat count: ${ref.chatHistoryList.length}");

// // //         return Column(
// // //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //           children: [
// // //             Expanded(
// // //               child: Column(
// // //                 children: [
// // //                   // Pinned leads section (only if available)
// // //                   if (widget.pinnedLeadsList != null &&
// // //                       widget.pinnedLeadsList!.isNotEmpty)
// // //                     _buildPinnedLeadsSection(),

// // //                   const SizedBox(height: 10),

// // //                   // Main chat area
// // //                   Expanded(
// // //                     child: Container(
// // //                       decoration: BoxDecoration(
// // //                         boxShadow: [
// // //                           BoxShadow(
// // //                             color: Colors.black.withOpacity(0.1),
// // //                             blurRadius: 5,
// // //                             spreadRadius: 1,
// // //                             offset: const Offset(0, 2),
// // //                           ),
// // //                         ],
// // //                         color: Colors.white,
// // //                         borderRadius: const BorderRadius.only(
// // //                           topLeft: Radius.circular(30),
// // //                           topRight: Radius.circular(30),
// // //                         ),
// // //                       ),
// // //                       child: Column(
// // //                         children: [
// // //                           // Contact info header
// // //                           _buildContactHeader(),
// // //                           const Divider(height: 1),

// // //                           // Chat messages list
// // //                           _buildChatMessagesList(ref),

// // //                           // Message input area
// // //                           _buildMessageInputArea(),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ],
// // //         );
// // //       },
// // //     );
// // //   }

// // //   Widget _buildPinnedLeadsSection() {
// // //     return Padding(
// // //       padding: const EdgeInsets.only(top: 15.0, left: 15, right: 15),
// // //       child: SizedBox(
// // //         height: 90,
// // //         child: ListView.builder(
// // //           scrollDirection: Axis.horizontal,
// // //           itemCount: widget.pinnedLeadsList!.length,
// // //           itemBuilder: (context, index) {
// // //             final lead = widget.pinnedLeadsList![index];
// // //             return GestureDetector(
// // //               onTap: () => _onPinnedLeadTap(lead, index),
// // //               child: SizedBox(
// // //                 width: 60,
// // //                 child: Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                   children: [
// // //                     CircleAvatar(
// // //                       radius: 20,
// // //                       backgroundColor: AppColor.navBarIconColor,
// // //                       child: Text(
// // //                         lead.name!.isNotEmpty
// // //                             ? lead.name![0].toUpperCase()
// // //                             : '?',
// // //                         style: const TextStyle(
// // //                           fontSize: 20,
// // //                           color: Colors.white,
// // //                           fontWeight: FontWeight.bold,
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     const SizedBox(height: 5),
// // //                     Text(
// // //                       lead.name ?? "",
// // //                       maxLines: 1,
// // //                       overflow: TextOverflow.ellipsis,
// // //                       style: const TextStyle(fontSize: 12),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //             );
// // //           },
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Future<void> _onPinnedLeadTap(SfDrawerItemModel lead, int index) async {
// // //     try {
// // //       String phNum = "${lead.countryCode ?? ""}${lead.whatsappNumber ?? ""}";

// // //       ChatMessageController cmProvider = Provider.of(context, listen: false);
// // //       DashBoardController dbProvider = Provider.of(context, listen: false);

// // //       dbProvider.setSelectedPinnedInfo(null);
// // //       dbProvider.setSelectedContaactInfo(lead);

// // //       debugPrint("📱 Switching to chat with: $phNum");

// // //       await cmProvider.messageHistoryApiCall(
// // //         userNumber: lead.whatsappNumber ?? "",
// // //         isFirstTime: true,
// // //       );

// // //       _scrollToBottom();
// // //     } catch (e) {
// // //       debugPrint("❌ Error switching pinned lead: $e");
// // //       EasyLoading.showToast("Failed to switch chat");
// // //     }
// // //   }

// // //   Widget _buildContactHeader() {
// // //     return Padding(
// // //       padding: const EdgeInsets.all(12.0),
// // //       child: Row(
// // //         children: [
// // //           const CircleAvatar(
// // //             backgroundImage: NetworkImage(
// // //               'https://www.w3schools.com/w3images/avatar2.png',
// // //             ),
// // //           ),
// // //           const SizedBox(width: 10),
// // //           Expanded(
// // //             child: Consumer<DashBoardController>(
// // //               builder: (context, dbRef, child) {
// // //                 return Text(
// // //                   dbRef.selectedContactInfo?.name ?? "Unknown Contact",
// // //                   style: const TextStyle(
// // //                     color: Colors.black,
// // //                     fontWeight: FontWeight.bold,
// // //                     fontSize: 16,
// // //                   ),
// // //                 );
// // //               },
// // //             ),
// // //           ),
// // //           Consumer<ChatMessageController>(
// // //             builder: (context, msgCtrl, child) {
// // //               return msgCtrl.msgDeleteList.isNotEmpty
// // //                   ? InkWell(
// // //                       onTap: () => _onDeleteMessages(msgCtrl),
// // //                       child: const Icon(
// // //                         Icons.delete,
// // //                         color: Colors.black,
// // //                       ),
// // //                     )
// // //                   : const SizedBox();
// // //             },
// // //           ),
// // //           PopupMenuButton<String>(
// // //             icon: const Icon(Icons.more_vert, color: Colors.black),
// // //             onSelected: (String value) {
// // //               if (value == 'Clear Chat') {
// // //                 _onClearChat();
// // //               }
// // //             },
// // //             itemBuilder: (BuildContext context) => const [
// // //               PopupMenuItem<String>(
// // //                 value: 'Clear Chat',
// // //                 child: Text('Clear Chat'),
// // //               ),
// // //             ],
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   void _onDeleteMessages(ChatMessageController msgCtrl) {
// // //     DashBoardController dbController = Provider.of(context, listen: false);
// // //     String code = dbController.selectedContactInfo?.countryCode ?? "91";
// // //     String num = dbController.selectedContactInfo?.whatsappNumber ?? "";
// // //     String whatsappNum = "$code$num";

// // //     if (whatsappNum.length > 3) {
// // //       msgCtrl.chatMsgDeleteApiCall(whatsappNum);
// // //     } else {
// // //       EasyLoading.showToast("Invalid contact number");
// // //     }
// // //   }

// // //   void _onClearChat() {
// // //     ChatMessageController messageController =
// // //         Provider.of(context, listen: false);
// // //     DashBoardController dbController = Provider.of(context, listen: false);

// // //     String usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
// // //     String code = dbController.selectedContactInfo?.countryCode ?? "91";
// // //     var wpNum = "$code$usrNumber";

// // //     if (wpNum.length > 3) {
// // //       messageController.deleteHistoryApiCall(wpNum);
// // //     } else {
// // //       EasyLoading.showToast("Invalid contact number");
// // //     }
// // //   }

// // //   Widget _buildChatMessagesList(ChatMessageController ref) {
// // //     if (ref.chatHistoryLoader) {
// // //       return const Expanded(
// // //         child: Center(
// // //           child: Padding(
// // //             padding: EdgeInsets.only(top: 38.0),
// // //             child: CircularProgressIndicator(
// // //               color: AppColor.navBarIconColor,
// // //             ),
// // //           ),
// // //         ),
// // //       );
// // //     }

// // //     if (ref.chatHistoryList.isEmpty) {
// // //       return const Expanded(
// // //         child: Center(
// // //           child: Padding(
// // //             padding: EdgeInsets.only(top: 28.0),
// // //             child: Text(
// // //               "No messages yet. Start a conversation!",
// // //               style: TextStyle(color: Colors.grey, fontSize: 16),
// // //             ),
// // //           ),
// // //         ),
// // //       );
// // //     }

// // //     return Expanded(
// // //       child: ListView.builder(
// // //         controller: _scrollController,
// // //         physics: const ClampingScrollPhysics(),
// // //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
// // //         itemCount: ref.chatHistoryList.length,
// // //         itemBuilder: (context, index) {
// // //           final item = ref.chatHistoryList[index];

// // //           // ✅ Debug each message
// // //           debugPrint("📨 Message $index: ${item.message}");
// // //           debugPrint("📨 Message ID: ${item.messageId}");
// // //           debugPrint("📨 Created Date: ${item.createdDate}");

// // //           if (item.createdDate == null || item.createdDate!.isEmpty) {
// // //             return const SizedBox();
// // //           }

// // //           DateTime? currentTime;
// // //           try {
// // //             currentTime = DateTime.parse(item.createdDate!)
// // //                 .toUtc()
// // //                 .add(const Duration(hours: 5, minutes: 30));
// // //           } catch (e) {
// // //             debugPrint("❌ Error parsing date: $e");
// // //             return const SizedBox();
// // //           }

// // //           bool showDateLabel = index == 0;
// // //           if (!showDateLabel && index > 0) {
// // //             final prevItem = ref.chatHistoryList[index - 1];
// // //             if (prevItem.createdDate != null &&
// // //                 prevItem.createdDate!.isNotEmpty) {
// // //               try {
// // //                 final prevTime = DateTime.parse(prevItem.createdDate!)
// // //                     .toUtc()
// // //                     .add(const Duration(hours: 5, minutes: 30));
// // //                 showDateLabel = !isSameDay(currentTime, prevTime);
// // //               } catch (e) {
// // //                 debugPrint("❌ Error parsing previous date: $e");
// // //               }
// // //             }
// // //           }

// // //           String tempBody = item.templateParams?.isEmpty ?? true
// // //               ? (item.templateBody ?? "")
// // //               : replaceTemplateParams(
// // //                   item.templateBody ?? "",
// // //                   item.templateParams ?? "",
// // //                 );

// // //           List<ButtonItem> buttons =
// // //               (item.button?.isNotEmpty ?? false) ? item.getParsedButtons() : [];

// // //           final hasContent = (item.message?.isNotEmpty ?? false) ||
// // //               (item.templateName?.isNotEmpty ?? false) ||
// // //               (tempBody.isNotEmpty) ||
// // //               (item.attachmentUrl?.isNotEmpty ?? false);

// // //           if (!hasContent) {
// // //             return const SizedBox();
// // //           }

// // //           return Column(
// // //             children: [
// // //               if (showDateLabel) ChatDateLabel(date: currentTime),
// // //               Padding(
// // //                 padding: const EdgeInsets.only(bottom: 15.0),
// // //                 child: Container(
// // //                   color: ref.msgDeleteList.contains(item.messageId ?? "")
// // //                       ? const Color(0xffE6E6E6)
// // //                       : Colors.transparent,
// // //                   child: ChatBubble(
// // //                     tempBody: tempBody,
// // //                     item: item,
// // //                     buttons: buttons,
// // //                     currentTime: currentTime,
// // //                   ),
// // //                 ),
// // //               ),
// // //             ],
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildMessageInputArea() {
// // //     return Padding(
// // //       padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
// // //       child: Consumer3<TemplateController, SfFileUploadController,
// // //           ChatMessageController>(
// // //         builder: (context, tempCtrl, fileUploadController, chatMsgController,
// // //             child) {
// // //           return Column(
// // //             children: [
// // //               const Divider(),
// // //               if (chatMsgController.isRecording)
// // //                 const Row(
// // //                   children: [
// // //                     Icon(Icons.fiber_manual_record,
// // //                         color: Colors.red, size: 14),
// // //                     SizedBox(width: 6),
// // //                     Text("Recording...", style: TextStyle(fontSize: 12)),
// // //                   ],
// // //                 ),
// // //               Row(
// // //                 children: [
// // //                   // Attachment button
// // //                   IconButton(
// // //                     icon: const Icon(Icons.attach_file),
// // //                     onPressed: () => showPicker(context),
// // //                   ),

// // //                   // File type indicator
// // //                   _buildFileTypeIndicator(chatMsgController),

// // //                   // Text input field
// // //                   Expanded(
// // //                     child: TextField(
// // //                       controller: msgController,
// // //                       maxLines: 3,
// // //                       minLines: 1,
// // //                       keyboardType: TextInputType.multiline,
// // //                       decoration: InputDecoration(
// // //                         hintText: 'Type a message...',
// // //                         hintMaxLines: 1,
// // //                         border: OutlineInputBorder(
// // //                           borderRadius: BorderRadius.circular(20),
// // //                           borderSide: BorderSide.none,
// // //                         ),
// // //                         filled: true,
// // //                         fillColor: const Color(0xffE6E6E6),
// // //                         contentPadding: const EdgeInsets.symmetric(
// // //                           horizontal: 16,
// // //                           vertical: 12,
// // //                         ),
// // //                       ),
// // //                       onChanged: (value) {
// // //                         // Optional: Handle text changes
// // //                       },
// // //                     ),
// // //                   ),

// // //                   // Voice message button
// // //                   _buildVoiceMessageButton(chatMsgController),

// // //                   // Template button
// // //                   _buildTemplateButton(tempCtrl),

// // //                   // Send button
// // //                   _buildSendButton(chatMsgController, fileUploadController),
// // //                 ],
// // //               ),
// // //             ],
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildFileTypeIndicator(ChatMessageController chatMsgController) {
// // //     if (chatMsgController.isDoc) {
// // //       return const Icon(Icons.edit_document, size: 20);
// // //     } else if (chatMsgController.isImage) {
// // //       return const Icon(Icons.image, size: 20);
// // //     } else if (chatMsgController.isVideo) {
// // //       return const Icon(Icons.videocam_rounded, size: 20);
// // //     } else if (chatMsgController.isAudio) {
// // //       return const Icon(Icons.mic, size: 20);
// // //     }
// // //     return const SizedBox(width: 0);
// // //   }

// // //   Widget _buildVoiceMessageButton(ChatMessageController chatMsgController) {
// // //     return Padding(
// // //       padding: const EdgeInsets.only(left: 4.0),
// // //       child: Listener(
// // //         onPointerDown: (_) => _startRecording(context),
// // //         onPointerUp: (_) => _stopRecording(),
// // //         child: Container(
// // //           decoration: const BoxDecoration(
// // //             color: Color.fromARGB(255, 168, 205, 235),
// // //             shape: BoxShape.circle,
// // //           ),
// // //           padding: const EdgeInsets.all(10),
// // //           child: Icon(
// // //             chatMsgController.isRecording ? Icons.stop : Icons.mic_none_sharp,
// // //             color: chatMsgController.isRecording ? Colors.red : Colors.black,
// // //             size: 20,
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildTemplateButton(TemplateController tempCtrl) {
// // //     return Padding(
// // //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
// // //       child: InkWell(
// // //         onTap: () async {
// // //           if (tempCtrl.getTempLoader) return;

// // //           tempCtrl.setSelectedTemp(null);
// // //           tempCtrl.setSelectedTempName("Select");
// // //           tempCtrl.setSeletcedTempCate("ALL");

// // //           try {
// // //             await tempCtrl.getTemplateApiCall(
// // //               category: tempCtrl.selectedTempCategory,
// // //             );
// // //             TemplatebottomSheetShow(context);
// // //           } catch (e) {
// // //             debugPrint("❌ Error loading templates: $e");
// // //             EasyLoading.showToast("Failed to load templates");
// // //           }
// // //         },
// // //         child: Container(
// // //           decoration: BoxDecoration(
// // //             color: const Color(0xff8BBCD0),
// // //             borderRadius: BorderRadius.circular(12),
// // //           ),
// // //           child: Center(
// // //             child: Padding(
// // //               padding: const EdgeInsets.all(10.0),
// // //               child: tempCtrl.getTempLoader
// // //                   ? const SizedBox(
// // //                       height: 25,
// // //                       width: 25,
// // //                       child: CircularProgressIndicator(
// // //                         color: Colors.white,
// // //                       ),
// // //                     )
// // //                   : const Icon(Icons.code, color: Colors.white, size: 20),
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildSendButton(
// // //     ChatMessageController chatMsgController,
// // //     SfFileUploadController fileUploadController,
// // //   ) {
// // //     return InkWell(
// // //       onTap: () async {
// // //         FocusScope.of(context).unfocus();

// // //         if (msgController.text.isNotEmpty &&
// // //             chatMsgController.selectedFile == null) {
// // //           await sendMsg(msgController.text.trim());
// // //         } else if (chatMsgController.selectedFile != null) {
// // //           await sendFile();
// // //         }
// // //       },
// // //       child: Container(
// // //         decoration: BoxDecoration(
// // //           color: const Color.fromARGB(255, 76, 162, 189),
// // //           borderRadius: BorderRadius.circular(12),
// // //         ),
// // //         child: Center(
// // //           child: Padding(
// // //             padding: const EdgeInsets.all(10.0),
// // //             child: chatMsgController.sendMsgLoader == true ||
// // //                     fileUploadController.fileUploadLoader == true
// // //                 ? const SizedBox(
// // //                     height: 25,
// // //                     width: 25,
// // //                     child: CircularProgressIndicator(
// // //                       color: Colors.white,
// // //                     ),
// // //                   )
// // //                 : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Future<void> sendMsg(String msg) async {
// // //     if (msg.trim().isEmpty) {
// // //       EasyLoading.showToast(
// // //         "Type something...",
// // //         toastPosition: EasyLoadingToastPosition.center,
// // //       );
// // //       return;
// // //     }

// // //     try {
// // //       DashBoardController dbController = Provider.of(context, listen: false);
// // //       ChatMessageController messageController =
// // //           Provider.of(context, listen: false);

// // //       final usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
// // //       final code = dbController.selectedContactInfo?.countryCode ?? "91";

// // //       if (usrNumber.isEmpty) {
// // //         EasyLoading.showToast("No contact selected");
// // //         return;
// // //       }

// // //       debugPrint("📤 Sending message: $msg to $usrNumber");

// // //       await messageController.sendMessageApiCall(
// // //         msg: msg,
// // //         usrNumber: usrNumber,
// // //         code: code,
// // //       );

// // //       msgController.clear();

// // //       // ✅ Refresh messages after sending
// // //       Future.delayed(const Duration(milliseconds: 500), () {
// // //         _refreshMessages();
// // //       });

// // //       _scrollToBottom();
// // //       FocusScope.of(context).unfocus();
// // //     } catch (e) {
// // //       debugPrint("❌ Error sending message: $e");
// // //       EasyLoading.showToast("Failed to send message");
// // //     }
// // //   }

// // //   bool isSameDay(DateTime a, DateTime b) {
// // //     return a.year == b.year && a.month == b.month && a.day == b.day;
// // //   }

// // //   Future<void> getUserNumer() {
// // //     SfFileUploadController sfFileUploadController =
// // //         Provider.of(context, listen: false);
// // //     sfFileUploadController.resetFileUpload();

// // //     ChatMessageController chatMsgController =
// // //         Provider.of(context, listen: false);
// // //     chatMsgController.resetMsgDeleteList();

// // //     return Future.value();
// // //   }

// // //   // Future<void> sendFile({bool isAudio = false}) async {
// // //   //   try {
// // //   //     SfFileUploadController sfFileController =
// // //   //         Provider.of(context, listen: false);
// // //   //     ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
// // //   //     DashBoardController dbController = Provider.of(context, listen: false);

// // //   //     var usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
// // //   //     log(" usrNumber in send file: $usrNumber");
// // //   //     var code = dbController.selectedContactInfo?.countryCode ?? "91";
// // //   //     debug("code in send file: $code");
// // //   //     if (usrNumber.isEmpty) {
// // //   //       EasyLoading.showToast("No contact selected");
// // //   //       return;
// // //   //     }

// // //   //     if (chatMsgCtrl.selectedFile != null) {
// // //   //       debugPrint("📤 Sending file to: $usrNumber");
// // //   //       await sfFileController.uploadFiledb(
// // //   //         chatMsgCtrl.selectedFile!,
// // //   //         code,
// // //   //         msgController.text.trim(),
// // //   //         usrNumber,
// // //   //       );

// // //   //       msgController.clear();

// // //   //       // ✅ Refresh messages after sending file
// // //   //       Future.delayed(const Duration(milliseconds: 500), () {
// // //   //         _refreshMessages();
// // //   //       });

// // //   //       _scrollToBottom();
// // //   //     }
// // //   //   } catch (e) {
// // //   //     debugPrint("❌ Error sending file: $e");
// // //   //     EasyLoading.showToast("Failed to send file");
// // //   //   }
// // //   // }

// // //   Future<void> _refreshMessagesWithDebug() async {
// // //   debugPrint("🔍 DEBUG: _refreshMessagesWithDebug() STARTED");

// // //   try {
// // //     DashBoardController dbController = Provider.of(context, listen: false);
// // //     ChatMessageController cmProvider = Provider.of(context, listen: false);

// // //     final usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
// // //     debugPrint("🔍 DEBUG: Refresh for user: $usrNumber");

// // //     if (usrNumber.isEmpty) {
// // //       debugPrint("❌ DEBUG: No user number for refresh");
// // //       return;
// // //     }

// // //     debugPrint("🔄 DEBUG: Calling messageHistoryApiCall...");

// // //     // Store previous count
// // //     final previousCount = cmProvider.chatHistoryList.length;
// // //     debugPrint("📊 DEBUG: Previous message count: $previousCount");

// // //     // Call API
// // //     await cmProvider.messageHistoryApiCall(
// // //       userNumber: usrNumber,
// // //       isFirstTime: false,
// // //     );

// // //     // Check new count
// // //     final newCount = cmProvider.chatHistoryList.length;
// // //     debugPrint("📊 DEBUG: New message count: $newCount");
// // //     debugPrint("📊 DEBUG: Difference: ${newCount - previousCount} messages");

// // //     if (newCount > previousCount) {
// // //       debugPrint("✅ DEBUG: New messages found!");

// // //       // Debug latest messages
// // //       if (cmProvider.chatHistoryList.isNotEmpty) {
// // //         final lastMessages = cmProvider.chatHistoryList.sublist(
// // //           cmProvider.chatHistoryList.length - min(3, cmProvider.chatHistoryList.length)
// // //         );

// // //         debugPrint("📨 DEBUG: Last ${lastMessages.length} messages:");
// // //         for (var i = 0; i < lastMessages.length; i++) {
// // //           final msg = lastMessages[i];
// // //           debugPrint("   ${i+1}. ID: ${msg.messageId}");
// // //           debugPrint("      Text: ${msg.message}");
// // //           // debugPrint("      Type: ${msg.type}");
// // //           debugPrint("      Has Attachment: ${msg.attachmentUrl != null}");
// // //           debugPrint("      Attachment: ${msg.attachmentUrl}");
// // //           debugPrint("      Time: ${msg.createdDate}");
// // //         }
// // //       }
// // //     } else {
// // //       debugPrint("⚠️ DEBUG: No new messages found");
// // //     }

// // //     _scrollToBottom();

// // //     debugPrint("✅ DEBUG: _refreshMessagesWithDebug() COMPLETED");

// // //   } catch (e, stackTrace) {
// // //     debugPrint("❌ DEBUG: Error in _refreshMessagesWithDebug: $e");
// // //     debugPrint("❌ DEBUG: Stack: $stackTrace");
// // //   }
// // // }
// // //   Future<void> sendFile({bool isAudio = false}) async {
// // //     debugPrint("🔍 DEBUG: sendFile() STARTED");
// // //     debugPrint("🔍 DEBUG: isAudio = $isAudio");

// // //     try {
// // //       SfFileUploadController sfFileController =
// // //           Provider.of(context, listen: false);
// // //       ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
// // //       DashBoardController dbController = Provider.of(context, listen: false);

// // //       var usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
// // //       var code = dbController.selectedContactInfo?.countryCode ?? "91";

// // //       debugPrint("🔍 DEBUG: User Number = $usrNumber");
// // //       debugPrint("🔍 DEBUG: Country Code = $code");
// // //       debugPrint("🔍 DEBUG: Full Number = $code$usrNumber");

// // //       if (usrNumber.isEmpty) {
// // //         debugPrint("❌ DEBUG: No user number found");
// // //         EasyLoading.showToast("No contact selected");
// // //         return;
// // //       }

// // //       if (chatMsgCtrl.selectedFile == null) {
// // //         debugPrint("❌ DEBUG: selectedFile is NULL");
// // //         EasyLoading.showToast("No file selected");
// // //         return;
// // //       }

// // //       debugPrint("✅ DEBUG: File found, starting upload process");

// // //       // File details debug
// // //       debugPrint("📎 DEBUG: File Path = ${chatMsgCtrl.selectedFile!.path}");
// // //       debugPrint(
// // //           "📎 DEBUG: File Name = ${chatMsgCtrl.selectedFile!.path.split('/').last}");

// // //       try {
// // //         final fileSize = await chatMsgCtrl.selectedFile!.length();
// // //         debugPrint("📎 DEBUG: File Size = ${fileSize} bytes");
// // //         debugPrint(
// // //             "📎 DEBUG: File Size = ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB");

// // //         if (fileSize > 10 * 1024 * 1024) {
// // //           debugPrint(
// // //               "❌ DEBUG: File too large (${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB > 10 MB)");
// // //           EasyLoading.showToast("File too large (max 10MB)");
// // //           return;
// // //         }
// // //       } catch (e) {
// // //         debugPrint("⚠️ DEBUG: Could not get file size: $e");
// // //       }

// // //       // Show loading with detailed status
// // //       EasyLoading.show(
// // //         status:
// // //             'Uploading file...\nPath: ${chatMsgCtrl.selectedFile!.path.split('/').last}',
// // //         maskType: EasyLoadingMaskType.black,
// // //         dismissOnTap: false,
// // //       );

// // //       debugPrint("🔄 DEBUG: Calling uploadFiledb()...");
// // //       debugPrint("🔄 DEBUG: Parameters:");
// // //       debugPrint("   - File: ${chatMsgCtrl.selectedFile!.path}");
// // //       debugPrint("   - Caption: ${msgController.text.trim()}");
// // //       debugPrint("   - WhatsApp Number: $usrNumber");
// // //       debugPrint("   - Country Code: $code");

// // //       // Start timer for upload
// // //       final stopwatch = Stopwatch()..start();

// // //       // Upload file
// // //       bool uploadSuccess = await sfFileController.uploadFiledb(
// // //         chatMsgCtrl.selectedFile!,
// // //         code,
// // //         msgController.text.trim(),
// // //         usrNumber,
// // //       );

// // //       stopwatch.stop();
// // //       debugPrint("⏱️ DEBUG: Upload took ${stopwatch.elapsedMilliseconds}ms");

// // //       EasyLoading.dismiss();

// // //       if (uploadSuccess) {
// // //         debugPrint("✅✅✅ DEBUG: FILE UPLOAD SUCCESSFUL!");

// // //         // Get upload controller details
// // //         debugPrint("📊 DEBUG: Upload Controller Details:");
// // //         debugPrint("   - fileDocId: ${sfFileController.fileDocId}");
// // //         debugPrint("   - filePubUrl: ${sfFileController.filePubUrl}");
// // //         debugPrint("   - fileMimeType: ${sfFileController.fileMimeType}");

// // //         EasyLoading.showSuccess(
// // //           '✅ File uploaded!\nRefreshing messages...',
// // //           duration: Duration(seconds: 2),
// // //         );

// // //         // Clear input
// // //         final oldFile = chatMsgCtrl.selectedFile;
// // //         msgController.clear();
// // //         chatMsgCtrl.setSelectedFile(null);

// // //         debugPrint("🧹 DEBUG: Cleared file: ${oldFile?.path}");

// // //         // Wait before refresh
// // //         debugPrint("⏳ DEBUG: Waiting 2 seconds for backend processing...");
// // //         await Future.delayed(const Duration(seconds: 2));

// // //         // Manual refresh
// // //         debugPrint("🔄 DEBUG: Starting manual refresh...");
// // //         await _refreshMessagesWithDebug();

// // //         debugPrint("✅ DEBUG: Scroll to bottom");
// // //         _scrollToBottom();

// // //         debugPrint("🎉 DEBUG: sendFile() COMPLETED SUCCESSFULLY");
// // //       } else {
// // //         debugPrint("❌❌❌ DEBUG: FILE UPLOAD FAILED!");
// // //         debugPrint("❌ DEBUG: uploadFiledb() returned false");

// // //         EasyLoading.showError(
// // //           '❌ Upload failed!\nPlease try again',
// // //           duration: Duration(seconds: 3),
// // //         );

// // //         // Keep file selected for retry
// // //         debugPrint("🔄 DEBUG: Keeping file selected for retry");
// // //       }
// // //     } catch (e, stackTrace) {
// // //       debugPrint("🔥🔥🔥 DEBUG: EXCEPTION in sendFile()!");
// // //       debugPrint("🔥 DEBUG: Error: $e");
// // //       debugPrint("🔥 DEBUG: Stack Trace: $stackTrace");

// // //       EasyLoading.dismiss();

// // //       EasyLoading.showError(
// // //         '🔥 Error!\n${e.toString().split(':').first}',
// // //         duration: Duration(seconds: 3),
// // //       );

// // //       // Log detailed error
// // //       if (e is SocketException) {
// // //         debugPrint("🌐 DEBUG: Network connection error");
// // //       } else if (e is HttpException) {
// // //         debugPrint("🌐 DEBUG: HTTP error");
// // //       } else if (e is FormatException) {
// // //         debugPrint("📄 DEBUG: Data format error");
// // //       }
// // //     }

// // //     debugPrint("🔍 DEBUG: sendFile() ENDED");
// // //   }

// // //   // Future<void> connectSocket() async {
// // //   //   try {
// // //   //     final prefs = await SharedPreferences.getInstance();
// // //   //     String tkn = prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";
// // //   //     final busNum =
// // //   //         prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";

// // //   //     if (tkn.isEmpty || busNum.isEmpty) {
// // //   //       debugPrint("❌ Missing token or business number for socket connection");
// // //   //       return;
// // //   //     }

// // //   //     Map<String, dynamic> decodedToken =
// // //   //         Map<String, dynamic>.from(JwtDecoder.decode(tkn));
// // //   //     String devId = await getDeviceId();

// // //   //     BusinessNumberController busNumCtrl = Provider.of(context, listen: false);
// // //   //     decodedToken.addAll({
// // //   //       "business_numbers": busNumCtrl.sfAllBusNums,
// // //   //       "businessNumber": busNum,
// // //   //       "userId": decodedToken['id'],
// // //   //       "deviceId": devId
// // //   //     });

// // //   //     debugPrint("🔌 Connecting WebSocket...");

// // //   //     socket = IO.io(
// // //   //       'https://admin.watconnect.com',
// // //   //       IO.OptionBuilder()
// // //   //           .setTransports(['websocket', 'polling'])
// // //   //           .setPath('/ibs/socket.io')
// // //   //           .setExtraHeaders({
// // //   //             'Authorization': 'Bearer $tkn',
// // //   //             'Content-Type': 'application/json',
// // //   //           })
// // //   //           .setQuery({'token': tkn})
// // //   //           .enableForceNew()
// // //   //           .enableReconnection()
// // //   //           .setReconnectionAttempts(5)
// // //   //           .setReconnectionDelay(1000)
// // //   //           .setTimeout(20000)
// // //   //           .build(),
// // //   //     );

// // //   //     // Socket event handlers
// // //   //     socket!.onConnect((_) {
// // //   //       debugPrint('✅ Connected to WebSocket');
// // //   //       debugPrint('🆔 Socket ID: ${socket!.id}');
// // //   //       _isSocketConnected = true;

// // //   //       socket!.emitWithAck("setup", decodedToken, ack: (response) {
// // //   //         debugPrint('✅ Setup acknowledged: $response');
// // //   //       });
// // //   //     });

// // //   //     socket!.onConnectError((error) {
// // //   //       debugPrint('❌ Connect Error: $error');
// // //   //       _isSocketConnected = false;
// // //   //     });

// // //   //     socket!.onError((error) {
// // //   //       debugPrint('⚠️ Socket Error: $error');
// // //   //     });

// // //   //     socket!.onDisconnect((reason) {
// // //   //       debugPrint('🔌 Disconnected: $reason');
// // //   //       _isSocketConnected = false;
// // //   //     });

// // //   //     socket!.on("connected", (_) {
// // //   //       debugPrint("🎉 WebSocket setup complete");
// // //   //     });

// // //   //     // Listen for new messages
// // //   //     socket!.on("receivedwhatsappmessage", (data) async {
// // //   //       debugPrint("💬 New WhatsApp message received: $data");

// // //   //       DashBoardController dbController = Provider.of(context, listen: false);
// // //   //       final usrNumber =
// // //   //           dbController.selectedContactInfo?.whatsappNumber ?? "";

// // //   //       if (usrNumber.isNotEmpty) {
// // //   //         debugPrint("🔄 Refreshing messages for: $usrNumber");

// // //   //         ChatMessageController cmProvider =
// // //   //             Provider.of(context, listen: false);
// // //   //         await cmProvider.messageHistoryApiCall(
// // //   //           userNumber: usrNumber,
// // //   //           isFirstTime: false,
// // //   //         );

// // //   //         _scrollToBottom();
// // //   //       }
// // //   //     });

// // //   //     // Connect socket
// // //   //     socket!.connect();
// // //   //   } catch (error, stackTrace) {
// // //   //     debugPrint("❌ Error connecting to WebSocket");
// // //   //     debugPrint("Error: $error");
// // //   //     debugPrint("StackTrace: $stackTrace");
// // //   //     _isSocketConnected = false;
// // //   //   }
// // //   // }
// // //   Future<void> connectSocket() async {
// // //   debugPrint("🔌 DEBUG: connectSocket() STARTED");

// // //   try {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     String tkn = prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";
// // //     final busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";

// // //     debugPrint("🔑 DEBUG: Token length: ${tkn.length}");
// // //     debugPrint("🔑 DEBUG: Business Number: $busNum");

// // //     if (tkn.isEmpty || busNum.isEmpty) {
// // //       debugPrint("❌❌❌ DEBUG: MISSING TOKEN OR BUSINESS NUMBER!");
// // //       debugPrint("❌ Token empty: ${tkn.isEmpty}");
// // //       debugPrint("❌ Business number empty: ${busNum.isEmpty}");
// // //       return;
// // //     }

// // //     // Decode token for debug
// // //     try {
// // //       Map<String, dynamic> decodedToken =
// // //           Map<String, dynamic>.from(JwtDecoder.decode(tkn));
// // //       debugPrint("👤 DEBUG: User ID: ${decodedToken['id']}");
// // //       debugPrint("👤 DEBUG: User Name: ${decodedToken['name']}");
// // //     } catch (e) {
// // //       debugPrint("⚠️ DEBUG: Could not decode token: $e");
// // //     }

// // //     debugPrint("🔌 DEBUG: Creating socket connection...");
// // //     debugPrint("🔌 DEBUG: URL: https://admin.watconnect.com");
// // //     debugPrint("🔌 DEBUG: Path: /ibs/socket.io");

// // //     socket = IO.io(
// // //       'https://admin.watconnect.com',
// // //       IO.OptionBuilder()
// // //           .setTransports(['websocket', 'polling'])
// // //           .setPath('/ibs/socket.io')
// // //           .setExtraHeaders({
// // //             'Authorization': 'Bearer $tkn',
// // //             'Content-Type': 'application/json',
// // //           })
// // //           .setQuery({'token': tkn})
// // //           .enableForceNew()
// // //           .enableReconnection()
// // //           .setReconnectionAttempts(5)
// // //           .setReconnectionDelay(1000)
// // //           .setTimeout(20000)
// // //           .build(),
// // //     );

// // //     // ==================== SOCKET EVENT LISTENERS ====================

// // //     socket!.onConnect((_) {
// // //       debugPrint('✅✅✅ DEBUG: SOCKET CONNECTED!');
// // //       debugPrint('🆔 DEBUG: Socket ID: ${socket!.id}');
// // //       _isSocketConnected = true;

// // //       socket!.emitWithAck("setup", {}, ack: (response) {
// // //         debugPrint('✅ DEBUG: Setup ACK: $response');
// // //       });
// // //     });

// // //     socket!.onConnectError((error) {
// // //       debugPrint('❌❌❌ DEBUG: SOCKET CONNECT ERROR: $error');
// // //       _isSocketConnected = false;
// // //     });

// // //     socket!.onError((error) {
// // //       debugPrint('⚠️ DEBUG: Socket Error: $error');
// // //     });

// // //     socket!.onDisconnect((reason) {
// // //       debugPrint('🔌 DEBUG: Socket Disconnected: $reason');
// // //       _isSocketConnected = false;
// // //     });

// // //     socket!.on("connected", (data) {
// // //       debugPrint("🎉 DEBUG: WebSocket 'connected' event: $data");
// // //     });

// // //     // =============== MOST IMPORTANT - MESSAGE EVENTS ===============

// // //     socket!.on("receivedwhatsappmessage", (data) async {
// // //       debugPrint("💬💬💬 DEBUG: 'receivedwhatsappmessage' EVENT!");
// // //       debugPrint("💬 DEBUG: Data: $data");

// // //       DashBoardController dbController = Provider.of(context, listen: false);
// // //       final usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";

// // //       debugPrint("💬 DEBUG: Current user: $usrNumber");

// // //       if (usrNumber.isNotEmpty) {
// // //         debugPrint("🔄 DEBUG: Auto-refreshing for received message");
// // //         await _refreshMessagesWithDebug();
// // //       }
// // //     });

// // //     // =============== CRITICAL FOR FILE UPLOAD ===============
// // //     socket!.on("sentwhatsappmessage", (data) async {
// // //       debugPrint("📤📤📤 DEBUG: 'sentwhatsappmessage' EVENT!");
// // //       debugPrint("📤 DEBUG: Data type: ${data.runtimeType}");
// // //       debugPrint("📤 DEBUG: Data: $data");

// // //       // Try to parse the data
// // //       try {
// // //         if (data is Map) {
// // //           debugPrint("📤 DEBUG: Message ID: ${data['messageId']}");
// // //           debugPrint("📤 DEBUG: Status: ${data['status']}");
// // //           debugPrint("📤 DEBUG: Type: ${data['type']}");
// // //           debugPrint("📤 DEBUG: Has attachment: ${data['attachmentUrl'] != null}");
// // //         }
// // //       } catch (e) {
// // //         debugPrint("⚠️ DEBUG: Could not parse sent message data: $e");
// // //       }

// // //       DashBoardController dbController = Provider.of(context, listen: false);
// // //       final usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";

// // //       if (usrNumber.isNotEmpty) {
// // //         debugPrint("🔄 DEBUG: Auto-refreshing after SENT message");
// // //         await Future.delayed(const Duration(milliseconds: 1500));
// // //         await _refreshMessagesWithDebug();
// // //       }
// // //     });

// // //     socket!.on("fileuploadcomplete", (data) {
// // //       debugPrint("✅✅✅ DEBUG: 'fileuploadcomplete' EVENT!");
// // //       debugPrint("✅ DEBUG: File upload complete: $data");
// // //     });

// // //     socket!.on("message", (data) {
// // //       debugPrint("📨 DEBUG: Generic 'message' event: $data");
// // //     });

// // //     socket!.onAny((event, data) {
// // //       debugPrint("🌐 DEBUG: Socket event '$event': $data");
// // //     });

// // //     debugPrint("🔌 DEBUG: Attempting socket connection...");
// // //     socket!.connect();

// // //     debugPrint("✅ DEBUG: connectSocket() COMPLETED");

// // //   } catch (error, stackTrace) {
// // //     debugPrint("🔥🔥🔥 DEBUG: EXCEPTION in connectSocket()!");
// // //     debugPrint("🔥 Error: $error");
// // //     debugPrint("🔥 Stack Trace: $stackTrace");
// // //     _isSocketConnected = false;
// // //   }
// // // }

// // //   void disconnectSocket() {
// // //     if (socket != null && _isSocketConnected) {
// // //       socket!.disconnect();
// // //       _isSocketConnected = false;
// // //       debugPrint("🔌 WebSocket Disconnected");
// // //     }
// // //   }

// // //   // Audio recording methods remain the same...
// // //   Future<void> _stopRecording() async {
// // //     try {
// // //       String? recordedPath = await _recorder.stopRecorder();
// // //       if (recordedPath != null) {
// // //         File audioFile = File(recordedPath);
// // //         ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
// // //         chatMsgCtrl.setSelectedFile(audioFile);
// // //         chatMsgCtrl.setRecordingStatus(false);
// // //         await Future.delayed(const Duration(milliseconds: 300));
// // //         _showPreviewDialog();
// // //       }
// // //     } catch (e) {
// // //       debugPrint("Stop recording error: $e");
// // //       EasyLoading.showToast("Failed to stop recording");
// // //     }
// // //   }

// // //   Future<void> _startRecording(BuildContext context) async {
// // //     ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
// // //     chatMsgCtrl.setSelectedFile(null);

// // //     var status = await Permission.microphone.status;
// // //     if (status.isGranted) {
// // //       await _beginRecording();
// // //       return;
// // //     }

// // //     if (status.isDenied) {
// // //       status = await Permission.microphone.request();
// // //       if (status.isGranted) {
// // //         await _beginRecording();
// // //         return;
// // //       }
// // //     }

// // //     if (status.isPermanentlyDenied || status.isDenied) {
// // //       _showPermissionDialog(context);
// // //     }
// // //   }

// // //   Future<void> _beginRecording() async {
// // //     try {
// // //       final Directory tempDir = await getTemporaryDirectory();
// // //       final String filePath =
// // //           '${tempDir.path}/voice_msg_${DateTime.now().millisecondsSinceEpoch}.aac';
// // //       _audioPath = filePath;

// // //       await _recorder.startRecorder(
// // //         toFile: filePath,
// // //         codec: fs.Codec.aacADTS,
// // //       );
// // //       ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
// // //       chatMsgCtrl.setRecordingStatus(true);
// // //     } catch (e) {
// // //       debugPrint("Recording error: $e");
// // //       EasyLoading.showToast("Failed to start recording");
// // //     }
// // //   }

// // //   void _showPermissionDialog(BuildContext context) {
// // //     showDialog<void>(
// // //       context: context,
// // //       builder: (ctx) => AlertDialog(
// // //         title: const Text("Microphone Access Needed"),
// // //         content: Platform.isIOS
// // //             ? const Text(
// // //                 "Microphone access is disabled. Please enable it from Settings > Privacy > Microphone.")
// // //             : const Text(
// // //                 "Permission permanently denied. Please enable it in Settings."),
// // //         actions: [
// // //           TextButton(
// // //             onPressed: () => Navigator.pop(ctx),
// // //             child: const Text("Cancel"),
// // //           ),
// // //           TextButton(
// // //             onPressed: () {
// // //               Navigator.pop(ctx);
// // //               openAppSettings();
// // //             },
// // //             child: const Text("Open Settings"),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   Future<void> _showPreviewDialog() async {
// // //     if (_audioPath == null) return;

// // //     final audioPlayerForDuration = AudioPlayer();
// // //     Duration? audioDuration;

// // //     try {
// // //       await audioPlayerForDuration.setFilePath(_audioPath!);
// // //       audioDuration = audioPlayerForDuration.duration;
// // //     } catch (e) {
// // //       debugPrint("Error getting audio duration: $e");
// // //     } finally {
// // //       await audioPlayerForDuration.dispose();
// // //     }

// // //     if (audioDuration == null || audioDuration.inSeconds < 3) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(
// // //           content: Text("Audio must be at least 3 seconds long."),
// // //         ),
// // //       );
// // //       return;
// // //     }

// // //     await showDialog(
// // //       context: context,
// // //       builder: (context) {
// // //         return Consumer<ChatMessageController>(
// // //           builder: (context, chatController, child) {
// // //             Future<void> startPlayer() async {
// // //               await _player.startPlayer(
// // //                 fromURI: _audioPath!,
// // //                 codec: fs.Codec.aacADTS,
// // //                 whenFinished: () {
// // //                   chatController.setPlayPreviewStatus(false);
// // //                 },
// // //               );
// // //               chatController.setPlayPreviewStatus(true);
// // //               _previewPlayerSubscription?.cancel();
// // //               _previewPlayerSubscription =
// // //                   _player.onProgress?.listen((event) {});
// // //             }

// // //             Future<void> stopPlayer() async {
// // //               await _player.stopPlayer();
// // //               _previewPlayerSubscription?.cancel();
// // //               chatController.setPlayPreviewStatus(false);
// // //             }

// // //             return AlertDialog(
// // //               title: const Text('Voice Message Preview'),
// // //               shape: RoundedRectangleBorder(
// // //                 borderRadius: BorderRadius.circular(16),
// // //               ),
// // //               content: Column(
// // //                 mainAxisSize: MainAxisSize.min,
// // //                 children: [
// // //                   IconButton(
// // //                     icon: Icon(
// // //                       chatController.isPlayingPreview
// // //                           ? Icons.pause_circle_filled
// // //                           : Icons.play_circle_fill,
// // //                       size: 48,
// // //                       color: AppColor.navBarIconColor,
// // //                     ),
// // //                     onPressed: () {
// // //                       chatController.isPlayingPreview
// // //                           ? stopPlayer()
// // //                           : startPlayer();
// // //                     },
// // //                   ),
// // //                 ],
// // //               ),
// // //               actions: [
// // //                 TextButton(
// // //                   onPressed: () async {
// // //                     stopPlayer();
// // //                     if (chatController.selectedFile != null) {
// // //                       await sendFile();
// // //                     }
// // //                     EasyLoading.showToast("Sending audio...");
// // //                     Navigator.pop(context);
// // //                   },
// // //                   child: const Text('Send'),
// // //                 ),
// // //                 TextButton(
// // //                   onPressed: () {
// // //                     stopPlayer();
// // //                     chatController.setPlayPreviewStatus(false);
// // //                     chatController.setSelectedFile(null);
// // //                     chatController.setRecordingStatus(false);
// // //                     Navigator.pop(context);
// // //                   },
// // //                   child: const Text('Cancel'),
// // //                 ),
// // //               ],
// // //             );
// // //           },
// // //         );
// // //       },
// // //     );
// // //   }
// // // }

// // // // Helper functions remain the same...
// // // String replaceTemplateParams(String templateBody, String paramsJsonString) {
// // //   try {
// // //     final List<dynamic> paramsList = paramsJsonString.isNotEmpty
// // //         ? List<Map<String, dynamic>>.from((jsonDecode(paramsJsonString) as List)
// // //             .map((e) => e as Map<String, dynamic>))
// // //         : [];

// // //     for (var param in paramsList) {
// // //       final name = param['name']?.toString() ?? '';
// // //       final value = param['value']?.toString() ?? '';
// // //       if (name.isNotEmpty) {
// // //         templateBody = templateBody.replaceAll(name, value);
// // //       }
// // //     }
// // //   } catch (e) {
// // //     debugPrint('Error replacing template params: $e');
// // //   }
// // //   return templateBody;
// // // }

// // // void showPicker(BuildContext context) async {
// // //   await showModalBottomSheet(
// // //     context: context,
// // //     backgroundColor: AppColor.navBarIconColor,
// // //     builder: (context) => Wrap(
// // //       children: <Widget>[
// // //         ListTile(
// // //           leading: const Icon(Icons.photo_library, color: Colors.white),
// // //           title: const Text(
// // //             'Choose from Gallery',
// // //             style: TextStyle(color: Colors.white),
// // //           ),
// // //           onTap: () {
// // //             pickImageFromGallery(context);
// // //           },
// // //         ),
// // //         ListTile(
// // //           leading: const Icon(Icons.camera_alt, color: Colors.white),
// // //           title: const Text(
// // //             'Take a Photo',
// // //             style: TextStyle(color: Colors.white),
// // //           ),
// // //           onTap: () {
// // //             pickImageFromCamera(context);
// // //           },
// // //         ),
// // //       ],
// // //     ),
// // //   );
// // // }

// // // // Future<void> pickImageFromGallery(context) async {
// // // //   final pickedFile = await FilePicker.platform.pickFiles(
// // // //     allowMultiple: false,
// // // //     type: FileType.custom,
// // // //     allowedExtensions: [
// // // //       "jpg",
// // // //       "jpeg",
// // // //       "png",
// // // //       "gif",
// // // //       "pdf",
// // // //       "html",
// // // //       "txt",
// // // //       "doc",
// // // //       "docx",
// // // //       "ppt",
// // // //       "pptx",
// // // //       "xls",
// // // //       "xlsx",
// // // //       "mp4",
// // // //       "mov",
// // // //       "avi",
// // // //       "mkv",
// // // //       "csv",
// // // //       "rtf",
// // // //       "odt",
// // // //       "zip",
// // // //       "rar",
// // // //     ],
// // // //   );
// // // //   if (pickedFile != null) {
// // // //     ChatMessageController chatMsgController =
// // // //         Provider.of(context, listen: false);
// // // //     var file = pickedFile.files.first;
// // // //     File image = File(file.path!);
// // // //     chatMsgController.setSelectedFile(image);
// // // //   }
// // // //   Navigator.pop(context);
// // // // }
// // // Future<void> pickImageFromGallery(context) async {
// // //   debugPrint("🖼️ DEBUG: pickImageFromGallery() STARTED");

// // //   try {
// // //     debugPrint("🔒 DEBUG: Checking permissions...");
// // //     var status = await Permission.photos.status;
// // //     debugPrint("🔒 DEBUG: Current permission status: $status");

// // //     if (status.isDenied) {
// // //       debugPrint("🔒 DEBUG: Requesting permission...");
// // //       status = await Permission.photos.request();
// // //       debugPrint("🔒 DEBUG: New permission status: $status");
// // //     }

// // //     if (status.isGranted) {
// // //       debugPrint("📁 DEBUG: Opening file picker...");

// // //       final pickedFile = await FilePicker.platform.pickFiles(
// // //         allowMultiple: false,
// // //         type: FileType.image,
// // //         allowedExtensions: ["jpg", "jpeg", "png", "gif"],
// // //       );

// // //       debugPrint("📁 DEBUG: File picker returned: ${pickedFile != null}");

// // //       if (pickedFile != null && pickedFile.files.isNotEmpty) {
// // //         var file = pickedFile.files.first;

// // //         debugPrint("📁 DEBUG: Selected file details:");
// // //         debugPrint("   - Name: ${file.name}");
// // //         debugPrint("   - Size: ${file.size} bytes");
// // //         debugPrint("   - Path: ${file.path}");
// // //         debugPrint("   - Extension: ${file.extension}");

// // //         if (file.path == null || file.path!.isEmpty) {
// // //           debugPrint("❌ DEBUG: File path is null or empty");
// // //           EasyLoading.showToast("Could not access file");
// // //           Navigator.pop(context);
// // //           return;
// // //         }

// // //         File image = File(file.path!);

// // //         debugPrint("🔍 DEBUG: Checking if file exists...");
// // //         bool fileExists = await image.exists();
// // //         debugPrint("🔍 DEBUG: File exists: $fileExists");

// // //         if (!fileExists) {
// // //           debugPrint("❌ DEBUG: File does not exist on disk");
// // //           EasyLoading.showToast("File not found");
// // //           Navigator.pop(context);
// // //           return;
// // //         }

// // //         ChatMessageController chatMsgController =
// // //             Provider.of(context, listen: false);

// // //         debugPrint("💾 DEBUG: Setting selected file in controller");
// // //         chatMsgController.setSelectedFile(image);
// // //         // chatMsgController.setIsImage(true);

// // //         debugPrint("✅ DEBUG: File successfully selected");
// // //         EasyLoading.showSuccess("✅ Image selected", duration: Duration(seconds: 1));

// // //         // Debug controller state
// // //         debugPrint("🎛️ DEBUG: Controller state after selection:");
// // //         debugPrint("   - selectedFile: ${chatMsgController.selectedFile?.path}");
// // //         debugPrint("   - isImage: ${chatMsgController.isImage}");
// // //         debugPrint("   - isVideo: ${chatMsgController.isVideo}");
// // //         debugPrint("   - isDoc: ${chatMsgController.isDoc}");

// // //       } else {
// // //         debugPrint("⚠️ DEBUG: No file selected or empty file list");
// // //       }
// // //     } else {
// // //       debugPrint("❌ DEBUG: Permission denied");
// // //       EasyLoading.showToast("Permission denied");
// // //     }
// // //   } catch (e, stackTrace) {
// // //     debugPrint("🔥 DEBUG: Error in pickImageFromGallery: $e");
// // //     debugPrint("🔥 DEBUG: Stack: $stackTrace");
// // //     EasyLoading.showToast("Error selecting image");
// // //   }

// // //   debugPrint("🖼️ DEBUG: pickImageFromGallery() ENDED");
// // //   Navigator.pop(context);
// // // }
// // // Future<void> pickImageFromCamera(context) async {
// // //   ImagePicker picker = ImagePicker();
// // //   final pickedFile = await picker.pickImage(
// // //     source: ImageSource.camera,
// // //     imageQuality: 80,
// // //   );
// // //   if (pickedFile != null) {
// // //     ChatMessageController chatMsgController =
// // //         Provider.of(context, listen: false);
// // //     File image = File(pickedFile.path);
// // //     chatMsgController.setSelectedFile(image);
// // //   }
// // //   Navigator.pop(context);
// // // }

// // // // Other helper functions remain the same...
// // // // import 'dart:async';
// // // // import 'dart:convert';
// // // // import 'dart:developer';
// // // // import 'dart:io';
// // // // import 'package:file_picker/file_picker.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:flutter_easyloading/flutter_easyloading.dart';
// // // // import 'package:focus_detector/focus_detector.dart';
// // // // import 'package:image_picker/image_picker.dart';
// // // // import 'package:just_audio/just_audio.dart';
// // // // import 'package:jwt_decoder/jwt_decoder.dart';
// // // // import 'package:provider/provider.dart';
// // // // import 'package:flutter_sound/flutter_sound.dart' as fs;
// // // // import 'package:flutter_sound/flutter_sound.dart';
// // // // import 'package:path_provider/path_provider.dart';
// // // // import 'package:permission_handler/permission_handler.dart';
// // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // import 'package:socket_io_client/socket_io_client.dart' as IO;
// // // // import 'package:socket_io_common/src/util/event_emitter.dart';
// // // // import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
// // // // import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
// // // // import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
// // // // import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
// // // // import 'package:whatsapp/salesforce/controller/template_controller.dart';
// // // // import 'package:whatsapp/salesforce/model/chat_history_model.dart';
// // // // import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
// // // // import 'package:whatsapp/salesforce/widget/chat_bubble.dart';
// // // // import 'package:whatsapp/salesforce/widget/chat_buttons.dart';
// // // // import 'package:whatsapp/salesforce/widget/chat_date_lable.dart';
// // // // import 'package:whatsapp/salesforce/widget/custom_bottom_sheet.dart';
// // // // import 'package:whatsapp/salesforce/widget/custom_drop_down.dart';
// // // // import 'package:whatsapp/salesforce/widget/header_type_preview.dart';
// // // // import 'package:whatsapp/salesforce/widget/pick_media_buttons.dart';
// // // // import 'package:whatsapp/salesforce/widget/sf_chat_appbar.dart';
// // // // import 'package:whatsapp/utils/app_color.dart';
// // // // import 'package:whatsapp/utils/app_constants.dart';
// // // // import 'package:whatsapp/view_models/lead_controller.dart';
// // // // import 'package:whatsapp/view_models/user_list_vm.dart';

// // // // final GlobalKey<FormState> _addTemplateFormKey = GlobalKey<FormState>();

// // // // class SfMessageChatScreen extends StatefulWidget {
// // // //   List<SfDrawerItemModel>? pinnedLeadsList;
// // // //   bool isFromRecentChat;
// // // //   SfMessageChatScreen(
// // // //       {super.key, this.pinnedLeadsList, this.isFromRecentChat = false});

// // // //   @override
// // // //   State<SfMessageChatScreen> createState() => _SfMessageChatScreenState();
// // // // }

// // // // class _SfMessageChatScreenState extends State<SfMessageChatScreen> {
// // // //   TextEditingController msgController = TextEditingController();
// // // //   final ScrollController _scrollController = ScrollController();
// // // //   int _previousChatLength = 0;
// // // //   // File? _audioFile;
// // // //   IO.Socket? socket;
// // // //   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
// // // //   final FlutterSoundPlayer _player = FlutterSoundPlayer();

// // // //   StreamSubscription? _previewPlayerSubscription;

// // // //   String? _audioPath;

// // // //   String userNumer = "";

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     ChatMessageController chatMsgController =
// // // //         Provider.of(context, listen: false);
// // // //     isCallAvailable();
// // // //     chatMsgController.setSelectedFile(null);
// // // //     _initializeAudio();
// // // //     // connectSocket();
// // // //     getUserNumer();
// // // //   }

// // // //   bool hasCalls = false;

// // // //   isCallAvailable() async {
// // // //     final prefs = await SharedPreferences.getInstance();
// // // //     final token = prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";

// // // //     Map<String, dynamic> decodedToken = Map<String, dynamic>.from(
// // // //       JwtDecoder.decode(token),
// // // //     );

// // // //     var modulesList = decodedToken['modules'];
// // // //     List availableModule =
// // // //         modulesList.map((e) => e['name'].toString()).toList();

// // // //     List<String> stringList = List<String>.from(availableModule);

// // // //     hasCalls = stringList.contains("Calls");
// // // //     setState(() {});
// // // //   }

// // // //   Future<void> _initializeAudio() async {
// // // //     await _player.openPlayer();
// // // //     await _recorder.openRecorder();
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     disconnectSocket();
// // // //     _recorder.closeRecorder();
// // // //     _player.closePlayer();
// // // //     _previewPlayerSubscription?.cancel();
// // // //     msgController.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     SystemChrome.setSystemUIOverlayStyle(
// // // //       const SystemUiOverlayStyle(
// // // //         statusBarColor: AppColor.navBarIconColor,
// // // //         statusBarIconBrightness: Brightness.dark,
// // // //         statusBarBrightness: Brightness.light,
// // // //       ),
// // // //     );

// // // //     return Consumer<ChatMessageController>(builder: (context, ref, child) {
// // // //       final currentLength = ref.chatHistoryList.length;

// // // //       if (currentLength > _previousChatLength && ref.msgDeleteList.isEmpty) {
// // // //         WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //           _scrollToBottom();
// // // //         });
// // // //       }

// // // //       _previousChatLength = currentLength;
// // // //       return GestureDetector(
// // // //         onTap: () {
// // // //           FocusScope.of(context).unfocus();
// // // //         },
// // // //         child: FocusDetector(
// // // //           onFocusGained: () async {
// // // //             final prefs = await SharedPreferences.getInstance();
// // // //             prefs.setBool("isOnSFChatPage", true);

// // // //             // print("Screen focused again");
// // // //             log('\x1B[95mFCM     Leads Screen focused again::::::::::::::::::::::::::::::::::::::::::::::::::');
// // // //             ChatMessageController cmProvider =
// // // //                 Provider.of(context, listen: false);
// // // //             DashBoardController dbController =
// // // //                 Provider.of(context, listen: false);

// // // //             final usrNumber =
// // // //                 dbController.selectedContactInfo?.whatsappNumber ?? "";
// // // //             Future.delayed(const Duration(milliseconds: 1), () async {
// // // //               await cmProvider.messageHistoryApiCall(
// // // //                 userNumber: usrNumber,
// // // //                 isFirstTime: false,
// // // //               );
// // // //               _scrollToBottom();
// // // //             });
// // // //             connectSocket();

// // // //             Future.delayed(const Duration(milliseconds: 1500), () async {
// // // //               await cmProvider.messageHistoryApiCall(
// // // //                 userNumber: usrNumber,
// // // //                 isFirstTime: false,
// // // //               );
// // // //               _scrollToBottom();
// // // //             });
// // // //           },
// // // //           onFocusLost: () async {
// // // //             final prefs = await SharedPreferences.getInstance();
// // // //             prefs.setBool("isOnSFChatPage", false);
// // // //             disconnectSocket();
// // // //           },
// // // //           child: SafeArea(
// // // //             bottom: true,
// // // //             child: Scaffold(
// // // //               backgroundColor: Colors.white,
// // // //               resizeToAvoidBottomInset: true,
// // // //               appBar: SfChatAppBar(
// // // //                 hasCalls: hasCalls,
// // // //               ),
// // // //               body: Stack(
// // // //                 children: [
// // // //                   RefreshIndicator(
// // // //                     onRefresh: _pullRefresh,
// // // //                     child: _pageBody(),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       );
// // // //     });
// // // //   }

// // // //   Future<void> _pullRefresh() async {
// // // //     await Future.delayed(const Duration(seconds: 1));
// // // //   }

// // // //   void _scrollToBottom() {
// // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //       if (_scrollController.hasClients) {
// // // //         print("scrolling to the extreme bottom.............");
// // // //         _scrollController.animateTo(
// // // //           _scrollController.position.maxScrollExtent,
// // // //           duration: const Duration(milliseconds: 300),
// // // //           curve: Curves.easeOut,
// // // //         );
// // // //       }
// // // //     });
// // // //   }

// // // //   _pageBody() {
// // // //     return Consumer<ChatMessageController>(builder: (context, ref, child) {
// // // //       // WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //       //   if (ref.msgDeleteList.isEmpty) {
// // // //       //     _scrollToBottom();
// // // //       //   }
// // // //       // });

// // // //       return Column(
// // // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //         children: [
// // // //           Expanded(
// // // //             child: Column(
// // // //               children: [
// // // //                 // if (widget.pinnedLeadsList!.isNotEmpty)
// // // //                 if (widget.pinnedLeadsList != null && widget.pinnedLeadsList!.isNotEmpty)

// // // //                   Padding(
// // // //                     padding:
// // // //                         const EdgeInsets.only(top: 15.0, left: 15, right: 15),
// // // //                     child: SizedBox(
// // // //                       height: 90,
// // // //                       child: ListView.builder(
// // // //                         scrollDirection: Axis.horizontal,
// // // //                         itemCount: widget.pinnedLeadsList!.length,
// // // //                         itemBuilder: (context, index) {
// // // //                           return GestureDetector(
// // // //                             onTap: () async {
// // // //                               if (widget.isFromRecentChat) {
// // // //                                 DashBoardController dashBoardController =
// // // //                                     Provider.of(context, listen: false);
// // // //                                 String phNum =
// // // //                                     "${dashBoardController.sfPinnedRecentChatList[index].countryCode ?? ""}${dashBoardController.sfPinnedRecentChatList[index].whatsappNumber ?? ""}";

// // // //                                 ChatMessageController cmProvider =
// // // //                                     Provider.of(context, listen: false);
// // // //                                 DashBoardController dbProvider =
// // // //                                     Provider.of(context, listen: false);
// // // //                                 dbProvider.setSelectedPinnedInfo(null);

// // // //                                 dbProvider.setSelectedContaactInfo(
// // // //                                     dashBoardController
// // // //                                         .sfPinnedRecentChatList[index]);
// // // //                                 await cmProvider
// // // //                                     .messageHistoryApiCall(
// // // //                                         userNumber: phNum, isFirstTime: true)
// // // //                                     .then((onValue) {});
// // // //                               } else {
// // // //                                 String phNum =
// // // //                                     "${widget.pinnedLeadsList![index].countryCode ?? ""}${widget.pinnedLeadsList![index].whatsappNumber ?? ""}";

// // // //                                 ChatMessageController cmProvider =
// // // //                                     Provider.of(context, listen: false);
// // // //                                 DashBoardController dbProvider =
// // // //                                     Provider.of(context, listen: false);
// // // //                                 dbProvider.setSelectedPinnedInfo(null);
// // // //                                 dbProvider.setSelectedContaactInfo(
// // // //                                     widget.pinnedLeadsList![index]);

// // // //                                 await cmProvider
// // // //                                     .messageHistoryApiCall(
// // // //                                   userNumber: phNum,
// // // //                                 )
// // // //                                     .then((onValue) {
// // // //                                   // Navigator.pop(navigatorKey.currentContext!);
// // // //                                 });
// // // //                               }

// // // //                               // _scrollToBottom();
// // // //                             },
// // // //                             child: SizedBox(
// // // //                               width: 60,
// // // //                               child: Column(
// // // //                                 crossAxisAlignment: CrossAxisAlignment.start,
// // // //                                 children: [
// // // //                                   CircleAvatar(
// // // //                                     radius: 20,
// // // //                                     backgroundColor: AppColor.navBarIconColor,
// // // //                                     child: Text(
// // // //                                       widget.pinnedLeadsList![index].name!
// // // //                                               .isNotEmpty
// // // //                                           ? widget
// // // //                                               .pinnedLeadsList![index].name![0]
// // // //                                               .toUpperCase()
// // // //                                           : '?',
// // // //                                       style: const TextStyle(
// // // //                                         fontSize: 20,
// // // //                                         color: Colors.white,
// // // //                                         fontWeight: FontWeight.bold,
// // // //                                       ),
// // // //                                     ),
// // // //                                   ),
// // // //                                   const SizedBox(height: 5),
// // // //                                   Text(
// // // //                                     widget.pinnedLeadsList![index].name ?? "",
// // // //                                     maxLines: 1,
// // // //                                     overflow: TextOverflow.ellipsis,
// // // //                                   ),
// // // //                                 ],
// // // //                               ),
// // // //                             ),
// // // //                           );
// // // //                         },
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 const SizedBox(height: 10),
// // // //                 Expanded(
// // // //                   child: Container(
// // // //                     decoration: BoxDecoration(
// // // //                       boxShadow: [
// // // //                         BoxShadow(
// // // //                           color: Colors.black.withOpacity(0.5),
// // // //                           blurRadius: 5,
// // // //                           spreadRadius: 3,
// // // //                           offset: const Offset(2, 4),
// // // //                         ),
// // // //                       ],
// // // //                       color: Colors.white,
// // // //                       borderRadius: const BorderRadius.only(
// // // //                         topLeft: Radius.circular(30),
// // // //                         topRight: Radius.circular(30),
// // // //                       ),
// // // //                     ),
// // // //                     child: Column(
// // // //                       children: [
// // // //                         Padding(
// // // //                           padding: const EdgeInsets.all(12.0),
// // // //                           child: Row(
// // // //                             children: [
// // // //                               const CircleAvatar(
// // // //                                 backgroundImage: NetworkImage(
// // // //                                   'https://www.w3schools.com/w3images/avatar2.png',
// // // //                                 ),
// // // //                               ),
// // // //                               const SizedBox(width: 10),
// // // //                               Expanded(
// // // //                                 child: Consumer<DashBoardController>(
// // // //                                   builder: (context, dbRef, child) {
// // // //                                     return Text(
// // // //                                       dbRef.selectedContactInfo?.name ?? "",
// // // //                                       style:
// // // //                                           const TextStyle(color: Colors.black),
// // // //                                     );
// // // //                                   },
// // // //                                 ),
// // // //                               ),
// // // //                               const Spacer(),
// // // //                               Consumer<ChatMessageController>(
// // // //                                   builder: (context, msgCtrol, child) {
// // // //                                 return msgCtrol.msgDeleteList.isEmpty
// // // //                                     ? const SizedBox()
// // // //                                     : InkWell(
// // // //                                         onTap: () {
// // // //                                           DashBoardController dbController =
// // // //                                               Provider.of(context,
// // // //                                                   listen: false);

// // // //                                           String code = dbController
// // // //                                                   .selectedContactInfo
// // // //                                                   ?.countryCode ??
// // // //                                               "91";
// // // //                                           String num = dbController
// // // //                                                   .selectedContactInfo
// // // //                                                   ?.whatsappNumber ??
// // // //                                               "";
// // // //                                           String whatsappNum = "$code$num";
// // // //                                           msgCtrol.chatMsgDeleteApiCall(
// // // //                                               whatsappNum);
// // // //                                         },
// // // //                                         child: const Icon(
// // // //                                           Icons.delete,
// // // //                                           color: Colors.black,
// // // //                                         ),
// // // //                                       );
// // // //                               }),
// // // //                               PopupMenuButton<String>(
// // // //                                 icon: const Icon(Icons.more_vert,
// // // //                                     color: Colors.black),
// // // //                                 onSelected: (String value) {
// // // //                                   if (value == 'Clear Chat') {
// // // //                                     ChatMessageController messageController =
// // // //                                         Provider.of(context, listen: false);
// // // //                                     DashBoardController dbController =
// // // //                                         Provider.of(context, listen: false);

// // // //                                     String usrNumber = dbController
// // // //                                             .selectedContactInfo
// // // //                                             ?.whatsappNumber ??
// // // //                                         "";
// // // //                                     String code = dbController
// // // //                                             .selectedContactInfo?.countryCode ??
// // // //                                         "91";
// // // //                                     var wpNum = "$code$usrNumber";
// // // //                                     messageController
// // // //                                         .deleteHistoryApiCall(wpNum);
// // // //                                   }
// // // //                                 },
// // // //                                 itemBuilder: (BuildContext context) => const [
// // // //                                   PopupMenuItem<String>(
// // // //                                     value: 'Clear Chat',
// // // //                                     child: Text('Clear Chat'),
// // // //                                   ),
// // // //                                 ],
// // // //                               ),
// // // //                             ],
// // // //                           ),
// // // //                         ),
// // // //                         const Divider(height: 1),
// // // //                         ref.chatHistoryLoader
// // // //                             ? const Padding(
// // // //                                 padding: EdgeInsets.only(top: 38.0),
// // // //                                 child: CircularProgressIndicator(
// // // //                                   color: AppColor.navBarIconColor,
// // // //                                 ),
// // // //                               )
// // // //                             : ref.chatHistoryList.isEmpty
// // // //                                 ? const Center(
// // // //                                     child: Padding(
// // // //                                       padding: EdgeInsets.only(top: 28.0),
// // // //                                       child: Text(
// // // //                                         "No Chat Available..",
// // // //                                         style: TextStyle(
// // // //                                             color: Colors.black, fontSize: 16),
// // // //                                       ),
// // // //                                     ),
// // // //                                   )
// // // //                                 : Expanded(
// // // //                                     child: ListView.builder(
// // // //                                       controller: _scrollController,
// // // //                                       itemCount: ref.chatHistoryList.length,
// // // //                                       itemBuilder: (context, index) {
// // // //                                         final item = ref.chatHistoryList[index];
// // // //                                         final currentRaw = item.createdDate;
// // // //                                         if (currentRaw == null ||
// // // //                                             currentRaw.isEmpty) {
// // // //                                           return const SizedBox();
// // // //                                         }

// // // //                                         final currentTime =
// // // //                                             DateTime.parse(currentRaw)
// // // //                                                 .toUtc()
// // // //                                                 .add(const Duration(
// // // //                                                     hours: 5, minutes: 30));

// // // //                                         bool showDateLabel = index == 0;
// // // //                                         if (!showDateLabel) {
// // // //                                           final prevRaw = ref
// // // //                                               .chatHistoryList[index - 1]
// // // //                                               .createdDate;
// // // //                                           if (prevRaw != null &&
// // // //                                               prevRaw.isNotEmpty) {
// // // //                                             final prevTime =
// // // //                                                 DateTime.parse(prevRaw)
// // // //                                                     .toUtc()
// // // //                                                     .add(const Duration(
// // // //                                                         hours: 5, minutes: 30));
// // // //                                             showDateLabel = !isSameDay(
// // // //                                                 currentTime, prevTime);
// // // //                                           }
// // // //                                         }

// // // //                                         String tempBody =
// // // //                                             item.templateParams!.isEmpty
// // // //                                                 ? (item.templateBody ?? "")
// // // //                                                 : replaceTemplateParams(
// // // //                                                     item.templateBody ?? "",
// // // //                                                     item.templateParams ?? "");

// // // //                                         List<ButtonItem> buttons =
// // // //                                             (item.button?.isNotEmpty ?? false)
// // // //                                                 ? item.getParsedButtons()
// // // //                                                 : [];

// // // //                                         final hasContent =
// // // //                                             (item.message?.isNotEmpty ??
// // // //                                                     false) ||
// // // //                                                 (item.templateName
// // // //                                                         ?.isNotEmpty ??
// // // //                                                     false) ||
// // // //                                                 (tempBody.isNotEmpty) ||
// // // //                                                 (item.attachmentUrl
// // // //                                                         ?.isNotEmpty ??
// // // //                                                     false);

// // // //                                         if (!hasContent) {
// // // //                                           return const SizedBox();
// // // //                                         }

// // // //                                         return Column(
// // // //                                           children: [
// // // //                                             if (showDateLabel)
// // // //                                               ChatDateLabel(date: currentTime),
// // // //                                             Padding(
// // // //                                               padding: const EdgeInsets.only(
// // // //                                                   bottom: 15.0),
// // // //                                               child: Container(
// // // //                                                 color: ref.msgDeleteList
// // // //                                                         .contains(
// // // //                                                             item.messageId ??
// // // //                                                                 "")
// // // //                                                     ? const Color(0xffE6E6E6)
// // // //                                                     : Colors.transparent,
// // // //                                                 child: ChatBubble(
// // // //                                                   tempBody: tempBody,
// // // //                                                   item: item,
// // // //                                                   buttons: buttons,
// // // //                                                   currentTime: currentTime,
// // // //                                                 ),
// // // //                                               ),
// // // //                                             ),
// // // //                                           ],
// // // //                                         );
// // // //                                       },
// // // //                                     ),
// // // //                                   ),
// // // //                         if (ref.chatHistoryList.isEmpty ||
// // // //                             ref.chatHistoryLoader)
// // // //                           const Spacer(),
// // // //                         _buildMessageInputArea(),
// // // //                       ],
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       );
// // // //     });
// // // //   }

// // // //   Future<void> _stopRecording() async {
// // // //     try {
// // // //       String? recordedPath = await _recorder.stopRecorder();
// // // //       if (recordedPath != null) {
// // // //         File audioFile = File(recordedPath);

// // // //         ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
// // // //         chatMsgCtrl.setSelectedFile(audioFile);

// // // //         chatMsgCtrl.setRecordingStatus(false);

// // // //         await Future.delayed(const Duration(milliseconds: 300));
// // // //         _showPreviewDialog();
// // // //       }
// // // //     } catch (e) {
// // // //       debugPrint("Stop recording error: $e");
// // // //       EasyLoading.showToast("Failed to stop recording");
// // // //     }
// // // //   }

// // // //   Future<void> _startRecording(BuildContext context) async {
// // // //     ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
// // // //     chatMsgCtrl.setSelectedFile(null);

// // // //     var status = await Permission.microphone.status;

// // // //     if (status.isGranted) {
// // // //       // Start recording immediately
// // // //       await _beginRecording();
// // // //       return;
// // // //     }

// // // //     PermissionStatus status1 = await Permission.microphone.status;
// // // //     print('Microphone permission status: $status1');

// // // //     if (status.isDenied) {
// // // //       // Request permission (system dialog may show)
// // // //       status = await Permission.microphone.request();

// // // //       if (status.isGranted) {
// // // //         await _beginRecording();
// // // //         return;
// // // //       }
// // // //       // If still denied or permanently denied, show dialog
// // // //       if (status.isPermanentlyDenied || status.isDenied) {
// // // //         _showPermissionDialog(context);
// // // //         return;
// // // //       }
// // // //     }

// // // //     if (status.isPermanentlyDenied) {
// // // //       // User permanently denied permission, must open settings manually
// // // //       _showPermissionDialog(context);
// // // //       return;
// // // //     }

// // // //     if (status.isRestricted || status.isLimited) {
// // // //       EasyLoading.showToast("Microphone access is restricted or limited.");
// // // //       return;
// // // //     }
// // // //   }

// // // //   Future<void> _beginRecording() async {
// // // //     try {
// // // //       final Directory tempDir = await getTemporaryDirectory();
// // // //       final String filePath =
// // // //           '${tempDir.path}/voice_msg_${DateTime.now().millisecondsSinceEpoch}.aac';
// // // //       _audioPath = filePath;

// // // //       await _recorder.startRecorder(
// // // //         toFile: filePath,
// // // //         codec: fs.Codec.aacADTS,
// // // //       );
// // // //       ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
// // // //       chatMsgCtrl.setRecordingStatus(true);
// // // //     } catch (e) {
// // // //       debugPrint("Recording error: $e");
// // // //       EasyLoading.showToast("Failed to start recording");
// // // //     }
// // // //   }

// // // //   void _showPermissionDialog(BuildContext context) {
// // // //     showDialog<void>(
// // // //       context: context,
// // // //       builder: (ctx) => AlertDialog(
// // // //         title: const Text("Microphone Access Needed"),
// // // //         content: Platform.isIOS
// // // //             ? const Text(
// // // //                 "Microphone access is disabled. Please enable it from Settings > Privacy > Microphone.")
// // // //             : const Text(
// // // //                 "Permission permanently denied. Please enable it in Settings."),
// // // //         actions: [
// // // //           TextButton(
// // // //             onPressed: () => Navigator.pop(ctx),
// // // //             child: const Text("Cancel"),
// // // //           ),
// // // //           TextButton(
// // // //             onPressed: () {
// // // //               Navigator.pop(ctx);
// // // //               openAppSettings();
// // // //             },
// // // //             child: const Text("Open Settings"),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   Future<void> _showPreviewDialog() async {
// // // //     if (_audioPath == null) return;
// // // //     // Get duration using just_audio
// // // //     final audioPlayerForDuration = AudioPlayer();
// // // //     Duration? audioDuration;

// // // //     try {
// // // //       await audioPlayerForDuration.setFilePath(_audioPath!);
// // // //       audioDuration = audioPlayerForDuration.duration;
// // // //     } catch (e) {
// // // //       print("catching errer in show audio preview dialog:::::::::   $e");
// // // //     } finally {
// // // //       await audioPlayerForDuration.dispose();
// // // //     }
// // // //     if (audioDuration == null || audioDuration.inSeconds < 3) {
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         const SnackBar(
// // // //           content: Text("Audio must be at least 3 seconds long."),
// // // //         ),
// // // //       );
// // // //       return;
// // // //     }
// // // //     await showDialog(
// // // //       context: context,
// // // //       builder: (context) {
// // // //         return Consumer<ChatMessageController>(
// // // //           builder: (context, chatController, child) {
// // // //             Future<void> startPlayer() async {
// // // //               await _player.startPlayer(
// // // //                 fromURI: _audioPath!,
// // // //                 codec: fs.Codec.aacADTS,
// // // //                 whenFinished: () {
// // // //                   chatController.setPlayPreviewStatus(false);
// // // //                 },
// // // //               );

// // // //               chatController.setPlayPreviewStatus(true);

// // // //               _previewPlayerSubscription?.cancel();
// // // //               _previewPlayerSubscription =
// // // //                   _player.onProgress?.listen((event) {});
// // // //             }

// // // //             Future<void> stopPlayer() async {
// // // //               await _player.stopPlayer();
// // // //               _previewPlayerSubscription?.cancel();

// // // //               chatController.setPlayPreviewStatus(false);
// // // //             }

// // // //             return AlertDialog(
// // // //               title: const Text('Voice Message Preview'),
// // // //               shape: RoundedRectangleBorder(
// // // //                 borderRadius: BorderRadius.circular(16),
// // // //               ),
// // // //               content: Column(
// // // //                 mainAxisSize: MainAxisSize.min,
// // // //                 children: [
// // // //                   IconButton(
// // // //                     icon: Icon(
// // // //                       chatController.isPlayingPreview
// // // //                           ? Icons.pause_circle_filled
// // // //                           : Icons.play_circle_fill,
// // // //                       size: 48,
// // // //                       color: AppColor.navBarIconColor,
// // // //                     ),
// // // //                     onPressed: () {
// // // //                       chatController.isPlayingPreview
// // // //                           ? stopPlayer()
// // // //                           : startPlayer();
// // // //                     },
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //               actions: [
// // // //                 TextButton(
// // // //                   onPressed: () async {
// // // //                     stopPlayer();

// // // //                     if (chatController.selectedFile != null) {
// // // //                       await sendFile();
// // // //                     }
// // // //                     EasyLoading.showToast("Sending audio...");

// // // //                     Navigator.pop(context);
// // // //                   },
// // // //                   child: const Text('Send'),
// // // //                 ),
// // // //                 TextButton(
// // // //                   onPressed: () {
// // // //                     stopPlayer();
// // // //                     chatController.setPlayPreviewStatus(false);
// // // //                     chatController.setSelectedFile(null);
// // // //                     chatController.setRecordingStatus(false);
// // // //                     Navigator.pop(context);
// // // //                   },
// // // //                   child: const Text('Cancel'),
// // // //                 ),
// // // //               ],
// // // //             );
// // // //           },
// // // //         );
// // // //       },
// // // //     );
// // // //   }

// // // //   _buildMessageInputArea() {
// // // //     return Padding(
// // // //       padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
// // // //       child: sendMsgRow(),
// // // //     );
// // // //   }

// // // //   sendMsgRow() {
// // // //     return Consumer3<TemplateController, SfFileUploadController,
// // // //             ChatMessageController>(
// // // //         builder: (context, tempCtrl, fileUploadController, chatMsgController,
// // // //             child) {
// // // //       return Column(
// // // //         children: [
// // // //           const Divider(),
// // // //           if (chatMsgController.isRecording)
// // // //             const Row(
// // // //               children: [
// // // //                 Icon(Icons.fiber_manual_record, color: Colors.red),
// // // //                 SizedBox(width: 6),
// // // //                 Text("Recording..."),
// // // //               ],
// // // //             ),
// // // //           Row(
// // // //             children: [
// // // //               Expanded(
// // // //                 child: Row(
// // // //                   children: [
// // // //                     IconButton(
// // // //                         icon: const Icon(Icons.attach_file),
// // // //                         onPressed: () {
// // // //                           showPicker(context);
// // // //                         }),
// // // //                     chatMsgController.isDoc
// // // //                         ? const Icon(Icons.edit_document)
// // // //                         : chatMsgController.isImage
// // // //                             ? const Icon(Icons.image)
// // // //                             : chatMsgController.isVideo
// // // //                                 ? const Icon(Icons.videocam_rounded)
// // // //                                 : chatMsgController.isAudio
// // // //                                     ? const Icon(Icons.mic)
// // // //                                     : const SizedBox(),
// // // //                     Expanded(
// // // //                       child: TextField(
// // // //                         controller: msgController,
// // // //                         maxLines: 3,
// // // //                         minLines: 1,
// // // //                         keyboardType: TextInputType.multiline,
// // // //                         decoration: InputDecoration(
// // // //                             hintText: 'Type a message...',
// // // //                             hintMaxLines: 1,
// // // //                             border: OutlineInputBorder(
// // // //                               borderRadius: BorderRadius.circular(20),
// // // //                               borderSide: BorderSide.none,
// // // //                             ),
// // // //                             filled: true,
// // // //                             fillColor: const Color(0xffE6E6E6)),
// // // //                       ),
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //               Padding(
// // // //                 padding: const EdgeInsets.only(left: 4.0),
// // // //                 child: Listener(
// // // //                   onPointerDown: (_) => _startRecording(context),
// // // //                   onPointerUp: (_) => _stopRecording(),
// // // //                   child: Container(
// // // //                     decoration: const BoxDecoration(
// // // //                       color: Color.fromARGB(255, 168, 205, 235),
// // // //                       shape: BoxShape.circle,
// // // //                     ),
// // // //                     padding: const EdgeInsets.all(10),
// // // //                     child: Icon(
// // // //                       chatMsgController.isRecording
// // // //                           ? Icons.stop
// // // //                           : Icons.mic_none_sharp,
// // // //                       color: chatMsgController.isRecording
// // // //                           ? Colors.red
// // // //                           : Colors.black,
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //               Padding(
// // // //                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
// // // //                 child: InkWell(
// // // //                   onTap: () async {
// // // //                     if (tempCtrl.getTempLoader) {
// // // //                     } else {
// // // //                       tempCtrl.setSelectedTemp(null);
// // // //                       tempCtrl.setSelectedTempName("Select");

// // // //                       tempCtrl.setSeletcedTempCate("ALL");
// // // //                       await tempCtrl.getTemplateApiCall(
// // // //                           category: tempCtrl.selectedTempCategory);
// // // //                       TemplatebottomSheetShow(context);
// // // //                     }
// // // //                   },
// // // //                   child: Container(
// // // //                     decoration: BoxDecoration(
// // // //                       color: const Color(0xff8BBCD0),
// // // //                       borderRadius: BorderRadius.circular(12),
// // // //                     ),
// // // //                     child: Center(
// // // //                         child: Padding(
// // // //                       padding: const EdgeInsets.all(10.0),
// // // //                       child: tempCtrl.getTempLoader
// // // //                           ? const SizedBox(
// // // //                               height: 25,
// // // //                               width: 25,
// // // //                               child: CircularProgressIndicator(
// // // //                                 color: Colors.white,
// // // //                               ),
// // // //                             )
// // // //                           : const Icon(Icons.code, color: Colors.white),
// // // //                     )),
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //               InkWell(
// // // //                 onTap: () async {
// // // //                   Future.delayed(const Duration(milliseconds: 1000), () async {
// // // //                     FocusScope.of(context).unfocus();
// // // //                   });
// // // //                   ChatMessageController chatMsgCtrl =
// // // //                       Provider.of(context, listen: false);
// // // //                   if (msgController.text.isNotEmpty &&
// // // //                       chatMsgCtrl.selectedFile == null) {
// // // //                     await sendMsg(msgController.text.trim());
// // // //                   }
// // // //                   if (chatMsgCtrl.selectedFile != null) {
// // // //                     sendFile();
// // // //                   }
// // // //                 },
// // // //                 child: Container(
// // // //                   decoration: BoxDecoration(
// // // //                     color: const Color.fromARGB(255, 76, 162, 189),
// // // //                     borderRadius: BorderRadius.circular(12),
// // // //                   ),
// // // //                   child: Center(
// // // //                       child: Padding(
// // // //                     padding: const EdgeInsets.all(10.0),
// // // //                     child: chatMsgController.sendMsgLoader == true ||
// // // //                             fileUploadController.fileUploadLoader == true
// // // //                         ? const SizedBox(
// // // //                             height: 25,
// // // //                             width: 25,
// // // //                             child: CircularProgressIndicator(
// // // //                               color: Colors.white,
// // // //                             ),
// // // //                           )
// // // //                         : const Icon(Icons.send_rounded, color: Colors.white),
// // // //                   )),
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ],
// // // //       );
// // // //     });
// // // //   }

// // // //   sendMsg(String msg) {
// // // //     print("we are calling this:::  $msg");
// // // //     if (msg.trim().isEmpty) {
// // // //       EasyLoading.showToast("Type something.....",
// // // //           toastPosition: EasyLoadingToastPosition.center);
// // // //     } else {
// // // //       DashBoardController dbController = Provider.of(context, listen: false);

// // // //       ChatMessageController messageController =
// // // //           Provider.of(context, listen: false);
// // // //       messageController.sendMessageApiCall(
// // // //         msg: msg,
// // // //         usrNumber: dbController.selectedContactInfo?.whatsappNumber ?? "",
// // // //         code: dbController.selectedContactInfo?.countryCode ?? "91",
// // // //       );
// // // //       msgController.clear();

// // // //       Future.delayed(const Duration(milliseconds: 100), () async {
// // // //         _scrollToBottom();
// // // //         FocusScope.of(context).unfocus();
// // // //       });

// // // //       // Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
// // // //     }
// // // //   }

// // // //   bool isSameDay(DateTime a, DateTime b) {
// // // //     return a.year == b.year && a.month == b.month && a.day == b.day;
// // // //   }

// // // //   getUserNumer() {
// // // //     SfFileUploadController sfFileUploadController =
// // // //         Provider.of(context, listen: false);

// // // //     sfFileUploadController.resetFileUpload();
// // // //     ChatMessageController chatMsgController =
// // // //         Provider.of(context, listen: false);

// // // //     chatMsgController.resetMsgDeleteList();
// // // //   }

// // // //   Future<void> sendFile({bool isAudio = false}) async {
// // // //     SfFileUploadController sfFileController =
// // // //         Provider.of(context, listen: false);
// // // //     ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
// // // //     DashBoardController dbController = Provider.of(context, listen: false);
// // // //     var usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
// // // //     var code = dbController.selectedContactInfo?.countryCode ?? "91";

// // // //     if (chatMsgCtrl.selectedFile != null) {
// // // //       await sfFileController.uploadFiledb(chatMsgCtrl.selectedFile!, code,
// // // //           msgController.text.trim(), usrNumber);
// // // //     }
// // // //     msgController.clear();
// // // //   }

// // // //   Future<void> connectSocket() async {
// // // //     final prefs = await SharedPreferences.getInstance();

// // // //     String tkn = prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";
// // // //     final busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";

// // // //     if (tkn.isEmpty || busNum.isEmpty) {
// // // //       print("❌ Missing token or business number for socket connection");
// // // //       return;
// // // //     } else {
// // // //       log("tkn node>>>>>>>>>> $tkn");
// // // //     }

// // // //     Map<String, dynamic> decodedToken =
// // // //         Map<String, dynamic>.from(JwtDecoder.decode(tkn));
// // // //     String devId = await getDeviceId();
// // // //     // LeadController leadCtrl = Provider.of(context, listen: false);
// // // //     BusinessNumberController busNumCtrl = Provider.of(context, listen: false);
// // // //     final dbController =
// // // //         Provider.of<DashBoardController>(context, listen: false);
// // // //     decodedToken.addAll({
// // // //       "business_numbers": busNumCtrl.sfAllBusNums,
// // // //       "businessNumber": busNum,
// // // //       "userId": decodedToken['id'],
// // // //       "deviceId": devId
// // // //     });

// // // //     log("decodedToken>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  $decodedToken");

// // // //     print("🔌 Connecting WebSocket with token: ${tkn.substring(0, 20)}...");

// // // //     try {
// // // //       socket = IO.io(
// // // //         'https://admin.watconnect.com',
// // // //         IO.OptionBuilder()
// // // //             .setTransports(['websocket', 'polling'])
// // // //             .setPath('/ibs/socket.io')
// // // //             .setExtraHeaders({
// // // //               'Authorization': 'Bearer $tkn',
// // // //               'Content-Type': 'application/json',
// // // //             })
// // // //             .setQuery({'token': tkn})
// // // //             .enableForceNew()
// // // //             .enableReconnection()
// // // //             .setReconnectionAttempts(5)
// // // //             .setReconnectionDelay(1000)
// // // //             .setTimeout(20000)
// // // //             .build(),
// // // //       );

// // // //       /// ✅ Connected
// // // //       socket!.onConnect((_) {
// // // //         print('✅ Connected to WebSocket');
// // // //         print('🆔 Socket ID: ${socket!.id}');

// // // //         socket!.emitWithAck("setup", decodedToken, ack: (response) {
// // // //           print('✅ Setup acknowledged: $response');
// // // //         });
// // // //       });

// // // //       /// ❌ Connection error
// // // //       socket!.onConnectError((error) {
// // // //         print('❌ Connect Error: $error');
// // // //       });

// // // //       /// ⚠️ Socket error
// // // //       socket!.onError((error) {
// // // //         print('⚠️ Socket Error: $error');
// // // //       });

// // // //       /// 🔌 Disconnected
// // // //       socket!.onDisconnect((reason) {
// // // //         print('🔌 Disconnected: $reason');
// // // //       });

// // // //       /// 📢 Server confirms setup
// // // //       socket!.on("connected", (_) {
// // // //         print("🎉 WebSocket setup complete");
// // // //       });

// // // //       socket!.onAny((event, [data]) {
// // // //         print("📡 Event: $event");
// // // //         print("📦 Data: $data");
// // // //       });

// // // //       socket!.on("receivedwhatsappmessage", (data) async {
// // // //         print("💬 New WhatsApp message received: $data");
// // // //         DashBoardController dbController = Provider.of(context, listen: false);

// // // //         final usrNumber =
// // // //             dbController.selectedContactInfo?.whatsappNumber ?? "";
// // // //         print("usrNumberLLLL >>>>>  $usrNumber");

// // // //         if (usrNumber.isNotEmpty) {
// // // //           print("trying to make api call");
// // // //           ChatMessageController cmProvider =
// // // //               Provider.of(context, listen: false);

// // // //           Future.delayed(const Duration(milliseconds: 1000), () async {
// // // //             await cmProvider.messageHistoryApiCall(
// // // //               userNumber: usrNumber,
// // // //               isFirstTime: false,
// // // //             );
// // // //             _scrollToBottom();
// // // //           });

// // // //           _scrollToBottom();
// // // //         }
// // // //       });

// // // //       /// 🔌 Explicit connectP
// // // //       socket!.connect();
// // // //     } catch (error, stackTrace) {
// // // //       print("❌ Error connecting to WebSocket");
// // // //       print("Error: $error");
// // // //       print("StackTrace: $stackTrace");
// // // //     }
// // // //   }

// // // //   void disconnectSocket() {
// // // //     if (socket != null) {
// // // //       socket!.disconnect();
// // // //       print(" WebSocket Disconnected  recent");
// // // //     }
// // // //   }
// // // // }

// // // // String replaceTemplateParams(String templateBody, String paramsJsonString) {
// // // //   // log("replacing template params:::   $templateBody   $paramsJsonString");
// // // //   try {
// // // //     final List<dynamic> paramsList = paramsJsonString.isNotEmpty
// // // //         ? List<Map<String, dynamic>>.from((jsonDecode(paramsJsonString) as List)
// // // //             .map((e) => e as Map<String, dynamic>))
// // // //         : [];

// // // //     for (var param in paramsList) {
// // // //       print(
// // // //           "param['label'] :::  ${param['name']}  param['value']::: ${param['value']} ");
// // // //       final name = param['name']?.toString() ?? '';
// // // //       final value = param['value']?.toString() ?? '';
// // // //       if (name.isNotEmpty) {
// // // //         templateBody = templateBody.replaceAll(name, value);
// // // //         log("templateBody after replace::::    $templateBody");
// // // //       }
// // // //     }
// // // //   } catch (e) {
// // // //     print('Error replacing template params: $e');
// // // //   }

// // // //   return templateBody;
// // // // }

// // // // void showPicker(BuildContext context) async {
// // // //   await showModalBottomSheet(
// // // //     context: context,
// // // //     backgroundColor: AppColor.navBarIconColor,
// // // //     builder: (context) => Wrap(
// // // //       children: <Widget>[
// // // //         ListTile(
// // // //           leading: const Icon(Icons.photo_library, color: Colors.white),
// // // //           title: const Text(
// // // //             'Choose from Gallery',
// // // //             style: TextStyle(color: Colors.white),
// // // //           ),
// // // //           onTap: () {
// // // //             pickImageFromGallery(context);
// // // //           },
// // // //         ),
// // // //         ListTile(
// // // //           leading: const Icon(Icons.camera_alt, color: Colors.white),
// // // //           title: const Text(
// // // //             'Take a Photo',
// // // //             style: TextStyle(color: Colors.white),
// // // //           ),
// // // //           onTap: () {
// // // //             pickImageFromCamera(context);
// // // //           },
// // // //         ),
// // // //       ],
// // // //     ),
// // // //   );
// // // // }

// // // // Future<void> pickImageFromGallery(context) async {
// // // //   final pickedFile = await FilePicker.platform.pickFiles(
// // // //     allowMultiple: false,
// // // //     type: FileType.custom,
// // // //     allowedExtensions: [
// // // //       "jpg",
// // // //       "jpeg",
// // // //       "png",
// // // //       "gif",
// // // //       "pdf",
// // // //       "html",
// // // //       "txt",
// // // //       "doc",
// // // //       "docx",
// // // //       "ppt",
// // // //       "pptx",
// // // //       "xls",
// // // //       "xlsx",
// // // //       "mp4",
// // // //       "mov",
// // // //       "avi",
// // // //       "mkv",
// // // //       "csv",
// // // //       "rtf",
// // // //       "odt",
// // // //       "zip",
// // // //       "rar",
// // // //     ],
// // // //   );
// // // //   if (pickedFile != null) {
// // // //     // EasyLoading.showToast("Picked Successfully");

// // // //     ChatMessageController chatMsgController =
// // // //         Provider.of(context, listen: false);
// // // //     var file = pickedFile.files.first;
// // // //     File image = File(file.path!);
// // // //     chatMsgController.setSelectedFile(image);
// // // //   }
// // // //   Navigator.pop(context);
// // // // }

// // // // Future<void> pickImageFromCamera(context) async {
// // // //   ImagePicker picker = ImagePicker();
// // // //   final pickedFile = await picker.pickImage(
// // // //     source: ImageSource.camera,
// // // //     imageQuality: 80,
// // // //   );
// // // //   if (pickedFile != null) {
// // // //     ChatMessageController chatMsgController =
// // // //         Provider.of(context, listen: false);
// // // //     File image = File(pickedFile.path);
// // // //     chatMsgController.setSelectedFile(image);
// // // //   }
// // // //   Navigator.pop(context);
// // // // }

// // // void TemplatebottomSheetShow(context, {bool isFromCamp = false}) {
// // //   return showCommonBottomSheet(
// // //       context: context,
// // //       title: "Category And Templete",
// // //       col: Consumer<TemplateController>(builder: (context, tempc, child) {
// // //         return Column(
// // //           crossAxisAlignment: CrossAxisAlignment.center,
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             CustomDropdown(
// // //               items: const [
// // //                 'ALL',
// // //                 'UTILITY',
// // //                 'MARKETING',
// // //               ],
// // //               selectedValue: tempc.selectedTempCategory,
// // //               onChanged: (newVal) async {
// // //                 if (newVal != null) {
// // //                   tempc.setSeletcedTempCate(newVal);
// // //                   // selectedCategory = newVal;
// // //                   tempc.setSelectedTempName("Select");

// // //                   tempc.setSelectedTemp(null);
// // //                   await tempc.getTemplateApiCall(
// // //                     category: tempc.selectedTempCategory,
// // //                   );
// // //                 }
// // //               },
// // //             ),
// // //             const SizedBox(
// // //               height: 12,
// // //             ),
// // //             CustomDropdown(
// // //               items: tempc.templateNames,
// // //               selectedValue: tempc.selectedTempName,
// // //               enabled: !tempc.getTempLoader,
// // //               onChanged: (newVal) {
// // //                 if (newVal != null) {
// // //                   tempc.setSelectedTempName(newVal);
// // //                 }
// // //               },
// // //             ),
// // //             const SizedBox(
// // //               height: 20,
// // //             ),
// // //             InkWell(
// // //               onTap: () {
// // //                 if (tempc.selectedTemplate == null) {
// // //                   EasyLoading.showToast("Select Template to continue");
// // //                 } else {
// // //                   Navigator.pop(context);
// // //                   SfFileUploadController sfFileUploadController =
// // //                       Provider.of(context, listen: false);

// // //                   sfFileUploadController.resetFileUpload();
// // //                   reviewBottomSheetShow(context, fromCamp: isFromCamp);
// // //                 }
// // //               },
// // //               child: IntrinsicWidth(
// // //                 child: Container(
// // //                   decoration: BoxDecoration(
// // //                     color: AppColor.navBarIconColor,
// // //                     borderRadius: BorderRadius.circular(10),
// // //                   ),
// // //                   child: const Padding(
// // //                     padding:
// // //                         EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
// // //                     child: Center(
// // //                       child: Text(
// // //                         "Review Template",
// // //                         style: TextStyle(color: Colors.white),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),
// // //             const SizedBox(
// // //               height: 40,
// // //             ),
// // //           ],
// // //         );
// // //       }));
// // // }

// // // void reviewBottomSheetShow(BuildContext context, {bool fromCamp = false}) {
// // //   final tempc = Provider.of<TemplateController>(context, listen: false);
// // //   final chatMsgController =
// // //       Provider.of<ChatMessageController>(context, listen: false);

// // //   final templateData = tempc.selectedTemplate;
// // //   final fieldCount = templateData?.storedParameterValues?.length ?? 0;

// // //   tempc.setupControllers(fieldCount);
// // //   chatMsgController.setSelectedFile(null);

// // //   showModalBottomSheet(
// // //       context: context,
// // //       isScrollControlled: true,
// // //       backgroundColor: Colors.white,
// // //       shape: const RoundedRectangleBorder(
// // //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// // //       ),
// // //       builder: (context) {
// // //         final maxHeight = MediaQuery.of(context).size.height * 0.8;

// // //         return GestureDetector(
// // //           behavior: HitTestBehavior.opaque,
// // //           onTap: () => FocusScope.of(context).unfocus(),
// // //           child: SafeArea(
// // //             bottom: true,
// // //             top: false,
// // //             child: Padding(
// // //               padding: EdgeInsets.only(
// // //                 bottom: MediaQuery.of(context).viewInsets.bottom,
// // //                 left: 12,
// // //                 right: 12,
// // //                 top: 20,
// // //               ),
// // //               child: ConstrainedBox(
// // //                 constraints: BoxConstraints(
// // //                   maxHeight: maxHeight,
// // //                 ),
// // //                 child: Material(
// // //                   // ensure proper styling
// // //                   color: Colors.white,
// // //                   borderRadius:
// // //                       const BorderRadius.vertical(top: Radius.circular(20)),
// // //                   child: Consumer2<TemplateController, ChatMessageController>(
// // //                     builder: (context, tempc, chatMsgController, child) {
// // //                       final templateData = tempc.selectedTemplate;
// // //                       final headerType = templateData?.headerType ?? "";
// // //                       List<ButtonItem> buttons =
// // //                           (templateData?.button?.isNotEmpty ?? false)
// // //                               ? templateData!.getParsedButtons()
// // //                               : [];

// // //                       return SingleChildScrollView(
// // //                         physics: const ClampingScrollPhysics(),
// // //                         child: Form(
// // //                           key: _addTemplateFormKey,
// // //                           child: Column(
// // //                             mainAxisSize: MainAxisSize.min,
// // //                             crossAxisAlignment: CrossAxisAlignment.start,
// // //                             children: [
// // //                               /// Title Row
// // //                               Row(
// // //                                 mainAxisAlignment:
// // //                                     MainAxisAlignment.spaceBetween,
// // //                                 children: [
// // //                                   const Text(
// // //                                     "Review Template",
// // //                                     style: TextStyle(
// // //                                         fontSize: 20,
// // //                                         fontWeight: FontWeight.bold),
// // //                                   ),
// // //                                   IconButton(
// // //                                     onPressed: () => Navigator.pop(context),
// // //                                     icon: const Icon(Icons.cancel_outlined),
// // //                                   )
// // //                                 ],
// // //                               ),
// // //                               const Divider(),

// // //                               if (templateData?.name != null)
// // //                                 Padding(
// // //                                   padding:
// // //                                       const EdgeInsets.symmetric(vertical: 10),
// // //                                   child: Text(
// // //                                     templateData!.name!,
// // //                                     style: const TextStyle(
// // //                                         fontWeight: FontWeight.bold,
// // //                                         fontSize: 18),
// // //                                   ),
// // //                                 ),

// // //                               /// Dynamic Text Fields
// // //                               ...List.generate(tempc.textControllers.length,
// // //                                   (index) {
// // //                                 return Padding(
// // //                                   padding: const EdgeInsets.only(bottom: 12.0),
// // //                                   child: TextFormField(
// // //                                     controller: tempc.textControllers[index],
// // //                                     cursorColor: AppColor.navBarIconColor,
// // //                                     keyboardType: TextInputType.text,
// // //                                     textInputAction: TextInputAction.next,
// // //                                     decoration: InputDecoration(
// // //                                       labelText: 'Placeholder ${index + 1}',
// // //                                       border: const OutlineInputBorder(),
// // //                                     ),
// // //                                     validator: (value) {
// // //                                       if (value!.isEmpty) {
// // //                                         return 'All fields are required';
// // //                                       }
// // //                                       return null;
// // //                                     },
// // //                                   ),
// // //                                 );
// // //                               }),

// // //                               /// Template Preview
// // //                               if ((templateData?.headerText?.isNotEmpty ??
// // //                                       false) ||
// // //                                   (templateData?.body?.isNotEmpty ?? false) ||
// // //                                   (templateData?.footer?.isNotEmpty ?? false) ||
// // //                                   (templateData?.messageBody?.isNotEmpty ??
// // //                                       false) ||
// // //                                   buttons.isNotEmpty)
// // //                                 Container(
// // //                                   margin:
// // //                                       const EdgeInsets.symmetric(vertical: 10),
// // //                                   padding: const EdgeInsets.all(8),
// // //                                   decoration: BoxDecoration(
// // //                                     color: const Color(0xffE3FFC9),
// // //                                     borderRadius: BorderRadius.circular(10),
// // //                                   ),
// // //                                   child: Column(
// // //                                     crossAxisAlignment:
// // //                                         CrossAxisAlignment.start,
// // //                                     children: [
// // //                                       if (["IMAGE", "VIDEO", "DOCUMENT"]
// // //                                           .contains(headerType))
// // //                                         chatMsgController.selectedFile == null
// // //                                             ? HeaderTypePreview(
// // //                                                 headerType: headerType)
// // //                                             : buildHeaderPreviewWidget(
// // //                                                 file: chatMsgController
// // //                                                     .selectedFile!,
// // //                                                 type: headerType,
// // //                                               ),
// // //                                       if (templateData
// // //                                               ?.headerText?.isNotEmpty ??
// // //                                           false)
// // //                                         Text(templateData!.headerText!),
// // //                                       if (templateData?.body?.isNotEmpty ??
// // //                                           false)
// // //                                         Text(templateData!.body!),
// // //                                       if (templateData
// // //                                               ?.messageBody?.isNotEmpty ??
// // //                                           false)
// // //                                         Text(templateData!.messageBody!),
// // //                                       if (templateData?.footer?.isNotEmpty ??
// // //                                           false)
// // //                                         Text(templateData!.footer!),
// // //                                       if (buttons.isNotEmpty)
// // //                                         ChatButtons(buttons: buttons),
// // //                                       PickMediaButton(
// // //                                         label: "Pick $headerType",
// // //                                         onTap: () =>
// // //                                             pickMedia(context, headerType),
// // //                                       ),
// // //                                     ],
// // //                                   ),
// // //                                 ),

// // //                               /// Send Button
// // //                               Align(
// // //                                 alignment: Alignment.center,
// // //                                 child: ElevatedButton(
// // //                                   style: ElevatedButton.styleFrom(
// // //                                     backgroundColor: AppColor.navBarIconColor,
// // //                                     shape: RoundedRectangleBorder(
// // //                                       borderRadius: BorderRadius.circular(10),
// // //                                     ),
// // //                                   ),
// // //                                   onPressed: () {
// // //                                     if (_addTemplateFormKey.currentState!
// // //                                         .validate()) {
// // //                                       if (tempc.sendTempLoader) return;
// // //                                       if (["IMAGE", "VIDEO", "DOCUMENT"]
// // //                                               .contains(headerType) &&
// // //                                           chatMsgController.selectedFile ==
// // //                                               null) {
// // //                                         EasyLoading.showToast(
// // //                                             "Select $headerType to continue");
// // //                                         return;
// // //                                       }

// // //                                       if (fromCamp) {
// // //                                         tempc.resetTempParamList();
// // //                                         sendCampTemp(
// // //                                             context, tempc.textControllers);
// // //                                       } else {
// // //                                         sendChatTemp(
// // //                                             context, tempc.textControllers);
// // //                                       }
// // //                                     }
// // //                                   },
// // //                                   child: tempc.sendTempLoader
// // //                                       ? const SizedBox(
// // //                                           height: 18,
// // //                                           width: 18,
// // //                                           child: CircularProgressIndicator(
// // //                                             strokeWidth: 2,
// // //                                             color: Colors.white,
// // //                                           ),
// // //                                         )
// // //                                       : const Text(
// // //                                           "Send Template",
// // //                                           style: TextStyle(color: Colors.white),
// // //                                         ),
// // //                                 ),
// // //                               ),
// // //                               const SizedBox(height: 20),
// // //                             ],
// // //                           ),
// // //                         ),
// // //                       );
// // //                     },
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //         );
// // //       });
// // // }

// // // Future<void> sendChatTemp(
// // //     context, List<TextEditingController> controllers) async {
// // //   TemplateController tempc = Provider.of(context, listen: false);
// // //   var templateData = tempc.selectedTemplate;
// // //   DashBoardController dbController = Provider.of(context, listen: false);

// // //   var usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
// // //   var code = dbController.selectedContactInfo?.countryCode ?? "91";
// // //   String userNumer = "$code$usrNumber";
// // //   List<String> userInputs = controllers.map((e) => e.text.trim()).toList();
// // //   ChatMessageController chatMsgController = Provider.of(context, listen: false);
// // //   SfFileUploadController sfFileUploadController =
// // //       Provider.of(context, listen: false);
// // //   if (chatMsgController.selectedFile != null) {
// // //     await sfFileUploadController
// // //         .uploadFiledb(chatMsgController.selectedFile!, code, "", usrNumber,
// // //             isFromTemplate: true)
// // //         .then(
// // //       (value) {
// // //         print(
// // //             "sfFileUploadController.fileDocId::::: ${sfFileUploadController.fileDocId}");

// // //         tempc
// // //             .sendTemplateApiCall(
// // //                 tempId: templateData?.templateId ?? "",
// // //                 usrNumber: userNumer,
// // //                 params: userInputs,
// // //                 docId: sfFileUploadController.fileDocId,
// // //                 url: sfFileUploadController.filePubUrl,
// // //                 mimetyp: sfFileUploadController.fileMimeType)
// // //             .then((onValue) {
// // //           Navigator.pop(context);
// // //         });
// // //       },
// // //     );
// // //   } else {
// // //     tempc
// // //         .sendTemplateApiCall(
// // //             tempId: templateData?.templateId ?? "",
// // //             usrNumber: userNumer,
// // //             params: userInputs)
// // //         .then((onValue) {
// // //       Navigator.pop(context);
// // //     });
// // //   }
// // // }

// // // void sendCampTemp(context, List<TextEditingController> controllers) {
// // //   Navigator.pop(context);
// // //   TemplateController tempc = Provider.of(context, listen: false);
// // //   List<String> userInputs = controllers.map((e) => e.text.trim()).toList();
// // //   tempc.setTempParams(userInputs);
// // //   tempc.setCampTempController(tempc.selectedTempName);

// // //   // TemplateController tempc = Provider.of(context, listen: false);
// // //   // var templateData = tempc.selectedTemplate;
// // //   // DashBoardController dbController = Provider.of(context, listen: false);

// // //   // var usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
// // //   // var code = dbController.selectedContactInfo?.countryCode ?? "91";
// // //   // String userNumer = "${code}${usrNumber}";
// // //   // List<String> userInputs = controllers.map((e) => e.text.trim()).toList();
// // //   // print("User Inputs: $userInputs");
// // // }

// // // Future<void> pickMedia(BuildContext context, String type) async {
// // //   final chatMsgController =
// // //       Provider.of<ChatMessageController>(context, listen: false);

// // //   if (type == "IMAGE") {
// // //     final pickedFile = await ImagePicker().pickImage(
// // //       source: ImageSource.gallery,
// // //       imageQuality: 80,
// // //     );
// // //     if (pickedFile != null) {
// // //       EasyLoading.showToast("Image Picked Successfully");
// // //       chatMsgController.setSelectedFile(File(pickedFile.path));
// // //     }
// // //   } else {
// // //     final extensions = type == "VIDEO"
// // //         ? ["mp4", "mov", "avi", "mkv", "webm"]
// // //         : ["pdf", "txt", "doc", "docx", "ppt", "pptx", "xls", "xlsx", "csv"];

// // //     final result = await FilePicker.platform.pickFiles(
// // //       type: FileType.custom,
// // //       allowedExtensions: extensions,
// // //     );

// // //     if (result != null) {
// // //       EasyLoading.showToast("$type Picked Successfully");
// // //       chatMsgController.setSelectedFile(File(result.files.first.path!));
// // //     }
// // //   }
// // // }

// // // Widget buildHeaderPreviewWidget({required File file, required String type}) {
// // //   switch (type) {
// // //     case 'IMAGE':
// // //       return Image.file(file, height: 80);
// // //     case 'VIDEO':
// // //       return Container(
// // //         height: 80,
// // //         decoration: BoxDecoration(
// // //           borderRadius: BorderRadius.circular(10),
// // //           color: Colors.black,
// // //         ),
// // //         child: const Center(
// // //           child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
// // //         ),
// // //       );
// // //     case 'DOCUMENT':
// // //     default:
// // //       return Image.asset("assets/images/file.png", height: 80, width: 80);
// // //   }
// // // }

// // // ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, avoid_print, must_be_immutable, deprecated_member_use
// // // ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, avoid_print, must_be_immutable, deprecated_member_use

// // import 'dart:async';
// // import 'dart:convert';
// // import 'dart:developer';
// // import 'dart:io';
// // import 'dart:math';
// // import 'package:file_picker/file_picker.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_easyloading/flutter_easyloading.dart';
// // import 'package:focus_detector/focus_detector.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:just_audio/just_audio.dart';
// // import 'package:jwt_decoder/jwt_decoder.dart';
// // import 'package:provider/provider.dart';
// // import 'package:flutter_sound/flutter_sound.dart' as fs;
// // import 'package:flutter_sound/flutter_sound.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'package:permission_handler/permission_handler.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:socket_io_client/socket_io_client.dart' as IO;
// // import 'package:socket_io_common/src/util/event_emitter.dart';
// // import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
// // import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
// // import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
// // import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
// // import 'package:whatsapp/salesforce/controller/template_controller.dart';
// // import 'package:whatsapp/salesforce/model/chat_history_model.dart';
// // import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
// // import 'package:whatsapp/salesforce/widget/chat_bubble.dart';
// // import 'package:whatsapp/salesforce/widget/chat_buttons.dart';
// // import 'package:whatsapp/salesforce/widget/chat_date_lable.dart';
// // import 'package:whatsapp/salesforce/widget/custom_bottom_sheet.dart';
// // import 'package:whatsapp/salesforce/widget/custom_drop_down.dart';
// // import 'package:whatsapp/salesforce/widget/header_type_preview.dart';
// // import 'package:whatsapp/salesforce/widget/pick_media_buttons.dart';
// // import 'package:whatsapp/salesforce/widget/sf_chat_appbar.dart';
// // import 'package:whatsapp/utils/app_color.dart';
// // import 'package:whatsapp/utils/app_constants.dart';
// // import 'package:whatsapp/utils/function_lib.dart';
// // import 'package:whatsapp/view_models/lead_controller.dart';
// // import 'package:whatsapp/view_models/user_list_vm.dart';

// // final GlobalKey<FormState> _addTemplateFormKey = GlobalKey<FormState>();

// // class SfMessageChatScreen extends StatefulWidget {
// //   List<SfDrawerItemModel>? pinnedLeadsList;
// //   bool isFromRecentChat;
// //   SfMessageChatScreen({
// //     super.key,
// //     this.pinnedLeadsList,
// //     this.isFromRecentChat = false,
// //   });

// //   @override
// //   State<SfMessageChatScreen> createState() => _SfMessageChatScreenState();
// // }

// // class _SfMessageChatScreenState extends State<SfMessageChatScreen> {
// //   TextEditingController msgController = TextEditingController();
// //   final ScrollController _scrollController = ScrollController();
// //   int _previousChatLength = 0;
// //   IO.Socket? socket;
// //   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
// //   final FlutterSoundPlayer _player = FlutterSoundPlayer();

// //   StreamSubscription? _previewPlayerSubscription;
// //   String? _audioPath;
// //   String userNumer = "";
// //   bool _isSocketConnected = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _initializeChat();
// //     });
// //   }

// //   Future<void> _initializeChat() async {
// //     try {
// //       debugPrint("🚀 DEBUG: Chat initialization started");
// //       ChatMessageController chatMsgController =
// //           Provider.of(context, listen: false);

// //       await isCallAvailable();
// //       chatMsgController.setSelectedFile(null);
// //       await _initializeAudio();
// //       await getUserNumer();

// //       // Load initial chat messages
// //       await _loadInitialMessages();

// //       // Connect socket after messages are loaded
// //       await connectSocket();

// //       debugPrint("✅ DEBUG: Chat initialization completed");
// //     } catch (e) {
// //       debugPrint("❌ DEBUG: Error initializing chat: $e");
// //     }
// //   }

// //   Future<void> _loadInitialMessages() async {
// //     try {
// //       DashBoardController dbController = Provider.of(context, listen: false);
// //       ChatMessageController chatMsgController =
// //           Provider.of(context, listen: false);

// //       final usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
// //       final countryCode = dbController.selectedContactInfo?.countryCode ?? "91";
// //       final fullNumber = "$countryCode$usrNumber";

// //       debugPrint("📱 DEBUG: Loading messages for: $fullNumber");

// //       if (usrNumber.isNotEmpty) {
// //         await chatMsgController.messageHistoryApiCall(
// //           userNumber: usrNumber,
// //           isFirstTime: true,
// //         );

// //         _scrollToBottom();
// //       } else {
// //         debugPrint("❌ DEBUG: No user number found for loading messages");
// //       }
// //     } catch (e) {
// //       debugPrint("❌ DEBUG: Error loading initial messages: $e");
// //     }
// //   }

// //   bool hasCalls = false;

// //   Future<void> isCallAvailable() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final token = prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";

// //       if (token.isEmpty) {
// //         debugPrint("❌ DEBUG: No Salesforce token found");
// //         return;
// //       }

// //       Map<String, dynamic> decodedToken =
// //           Map<String, dynamic>.from(JwtDecoder.decode(token));

// //       var modulesList = decodedToken['modules'] ?? [];
// //       List availableModule =
// //           modulesList.map((e) => e['name'].toString()).toList();

// //       List<String> stringList = List<String>.from(availableModule);
// //       hasCalls = stringList.contains("Calls");

// //       if (mounted) {
// //         setState(() {});
// //       }
// //     } catch (e) {
// //       debugPrint("❌ DEBUG: Error checking call availability: $e");
// //     }
// //   }

// //   Future<void> _initializeAudio() async {
// //     try {
// //       await _player.openPlayer();
// //       await _recorder.openRecorder();
// //       debugPrint("✅ DEBUG: Audio initialized successfully");
// //     } catch (e) {
// //       debugPrint("❌ DEBUG: Error initializing audio: $e");
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     disconnectSocket();
// //     _recorder.closeRecorder();
// //     _player.closePlayer();
// //     _previewPlayerSubscription?.cancel();
// //     msgController.dispose();
// //     _scrollController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     SystemChrome.setSystemUIOverlayStyle(
// //       const SystemUiOverlayStyle(
// //         statusBarColor: AppColor.navBarIconColor,
// //         statusBarIconBrightness: Brightness.dark,
// //         statusBarBrightness: Brightness.light,
// //       ),
// //     );

// //     return Consumer<ChatMessageController>(builder: (context, ref, child) {
// //       final currentLength = ref.chatHistoryList.length;
// //       if (currentLength > _previousChatLength && ref.msgDeleteList.isEmpty) {
// //         WidgetsBinding.instance.addPostFrameCallback((_) {
// //           _scrollToBottom();
// //         });
// //       }
// //       _previousChatLength = currentLength;

// //       return GestureDetector(
// //         onTap: () => FocusScope.of(context).unfocus(),
// //         child: FocusDetector(
// //           onFocusGained: () async {
// //             debugPrint("📱 DEBUG: Chat Screen focused");
// //             final prefs = await SharedPreferences.getInstance();
// //             prefs.setBool("isOnSFChatPage", true);

// //             await _refreshMessages();

// //             if (!_isSocketConnected) {
// //               await connectSocket();
// //             }
// //           },
// //           onFocusLost: () async {
// //             debugPrint("📱 DEBUG: Chat Screen lost focus");
// //             final prefs = await SharedPreferences.getInstance();
// //             prefs.setBool("isOnSFChatPage", false);
// //             disconnectSocket();
// //           },
// //           child: SafeArea(
// //             bottom: true,
// //             child: Scaffold(
// //               backgroundColor: Colors.white,
// //               resizeToAvoidBottomInset: true,
// //               appBar: SfChatAppBar(hasCalls: hasCalls),
// //               body: Stack(
// //                 children: [
// //                   RefreshIndicator(
// //                     onRefresh: _pullRefresh,
// //                     child: _pageBody(),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       );
// //     });
// //   }

// //   Future<void> _refreshMessages() async {
// //     try {
// //       DashBoardController dbController = Provider.of(context, listen: false);
// //       ChatMessageController cmProvider = Provider.of(context, listen: false);

// //       final usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
// //       if (usrNumber.isNotEmpty) {
// //         debugPrint("🔄 DEBUG: Refreshing messages for: $usrNumber");
// //         await cmProvider.messageHistoryApiCall(
// //           userNumber: usrNumber,
// //           isFirstTime: false,
// //         );
// //         _scrollToBottom();
// //       }
// //     } catch (e) {
// //       debugPrint("❌ DEBUG: Error refreshing messages: $e");
// //     }
// //   }

// //   Future<void> _pullRefresh() async {
// //     await _refreshMessages();
// //   }

// //   void _scrollToBottom() {
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (_scrollController.hasClients && mounted) {
// //         final maxScroll = _scrollController.position.maxScrollExtent;
// //         if (maxScroll > 0) {
// //           _scrollController.animateTo(
// //             maxScroll,
// //             duration: const Duration(milliseconds: 300),
// //             curve: Curves.easeOut,
// //           );
// //         }
// //       }
// //     });
// //   }

// //   Widget _pageBody() {
// //     return Consumer<ChatMessageController>(
// //       builder: (context, ref, child) {
// //         return Column(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             Expanded(
// //               child: Column(
// //                 children: [
// //                   if (widget.pinnedLeadsList != null &&
// //                       widget.pinnedLeadsList!.isNotEmpty)
// //                     _buildPinnedLeadsSection(),
// //                   const SizedBox(height: 10),
// //                   Expanded(
// //                     child: Container(
// //                       decoration: BoxDecoration(
// //                         boxShadow: [
// //                           BoxShadow(
// //                             color: Colors.black.withOpacity(0.1),
// //                             blurRadius: 5,
// //                             spreadRadius: 1,
// //                             offset: const Offset(0, 2),
// //                           ),
// //                         ],
// //                         color: Colors.white,
// //                         borderRadius: const BorderRadius.only(
// //                           topLeft: Radius.circular(30),
// //                           topRight: Radius.circular(30),
// //                         ),
// //                       ),
// //                       child: Column(
// //                         children: [
// //                           _buildContactHeader(),
// //                           const Divider(height: 1),
// //                           _buildChatMessagesList(ref),
// //                           _buildMessageInputArea(),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildPinnedLeadsSection() {
// //     return Padding(
// //       padding: const EdgeInsets.only(top: 15.0, left: 15, right: 15),
// //       child: SizedBox(
// //         height: 90,
// //         child: ListView.builder(
// //           scrollDirection: Axis.horizontal,
// //           itemCount: widget.pinnedLeadsList!.length,
// //           itemBuilder: (context, index) {
// //             final lead = widget.pinnedLeadsList![index];
// //             return GestureDetector(
// //               onTap: () => _onPinnedLeadTap(lead, index),
// //               child: SizedBox(
// //                 width: 60,
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     CircleAvatar(
// //                       radius: 20,
// //                       backgroundColor: AppColor.navBarIconColor,
// //                       child: Text(
// //                         lead.name!.isNotEmpty
// //                             ? lead.name![0].toUpperCase()
// //                             : '?',
// //                         style: const TextStyle(
// //                           fontSize: 20,
// //                           color: Colors.white,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 5),
// //                     Text(
// //                       lead.name ?? "",
// //                       maxLines: 1,
// //                       overflow: TextOverflow.ellipsis,
// //                       style: const TextStyle(fontSize: 12),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   Future<void> _onPinnedLeadTap(SfDrawerItemModel lead, int index) async {
// //     try {
// //       String phNum = "${lead.countryCode ?? ""}${lead.whatsappNumber ?? ""}";

// //       ChatMessageController cmProvider = Provider.of(context, listen: false);
// //       DashBoardController dbProvider = Provider.of(context, listen: false);

// //       dbProvider.setSelectedPinnedInfo(null);
// //       dbProvider.setSelectedContaactInfo(lead);

// //       debugPrint("📱 DEBUG: Switching to chat with: $phNum");

// //       await cmProvider.messageHistoryApiCall(
// //         userNumber: lead.whatsappNumber ?? "",
// //         isFirstTime: true,
// //       );

// //       _scrollToBottom();
// //     } catch (e) {
// //       debugPrint("❌ DEBUG: Error switching pinned lead: $e");
// //       EasyLoading.showToast("Failed to switch chat");
// //     }
// //   }

// //   Widget _buildContactHeader() {
// //     return Padding(
// //       padding: const EdgeInsets.all(12.0),
// //       child: Row(
// //         children: [
// //           const CircleAvatar(
// //             backgroundImage: NetworkImage(
// //               'https://www.w3schools.com/w3images/avatar2.png',
// //             ),
// //           ),
// //           const SizedBox(width: 10),
// //           Expanded(
// //             child: Consumer<DashBoardController>(
// //               builder: (context, dbRef, child) {
// //                 return Text(
// //                   dbRef.selectedContactInfo?.name ?? "Unknown Contact",
// //                   style: const TextStyle(
// //                     color: Colors.black,
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 16,
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //           // DEBUG REFRESH BUTTON
// //           // IconButton(
// //           //   icon: Icon(Icons.refresh, color: Colors.blue),
// //           //   onPressed: () async {
// //           //     debugPrint("🔄 DEBUG: Manual refresh triggered");
// //           //     await _refreshMessages();
// //           //   },
// //           // ),
// //           Consumer<ChatMessageController>(
// //             builder: (context, msgCtrl, child) {
// //               return msgCtrl.msgDeleteList.isNotEmpty
// //                   ? InkWell(
// //                       onTap: () => _onDeleteMessages(msgCtrl),
// //                       child: const Icon(
// //                         Icons.delete,
// //                         color: Colors.black,
// //                       ),
// //                     )
// //                   : const SizedBox();
// //             },
// //           ),
// //           PopupMenuButton<String>(
// //             icon: const Icon(Icons.more_vert, color: Colors.black),
// //             onSelected: (String value) {
// //               if (value == 'Clear Chat') {
// //                 _onClearChat();
// //               }
// //             },
// //             itemBuilder: (BuildContext context) => const [
// //               PopupMenuItem<String>(
// //                 value: 'Clear Chat',
// //                 child: Text('Clear Chat'),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   void _onDeleteMessages(ChatMessageController msgCtrl) {
// //     DashBoardController dbController = Provider.of(context, listen: false);
// //     String code = dbController.selectedContactInfo?.countryCode ?? "91";
// //     String num = dbController.selectedContactInfo?.whatsappNumber ?? "";
// //     String whatsappNum = "$code$num";

// //     if (whatsappNum.length > 3) {
// //       msgCtrl.chatMsgDeleteApiCall(whatsappNum);
// //     } else {
// //       EasyLoading.showToast("Invalid contact number");
// //     }
// //   }

// //   void _onClearChat() {
// //     ChatMessageController messageController =
// //         Provider.of(context, listen: false);
// //     DashBoardController dbController = Provider.of(context, listen: false);

// //     String usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
// //     String code = dbController.selectedContactInfo?.countryCode ?? "91";
// //     var wpNum = "$code$usrNumber";

// //     if (wpNum.length > 3) {
// //       messageController.deleteHistoryApiCall(wpNum);
// //     } else {
// //       EasyLoading.showToast("Invalid contact number");
// //     }
// //   }

// //   Widget _buildChatMessagesList(ChatMessageController ref) {
// //     if (ref.chatHistoryLoader) {
// //       return const Expanded(
// //         child: Center(
// //           child: Padding(
// //             padding: EdgeInsets.only(top: 38.0),
// //             child: CircularProgressIndicator(
// //               color: AppColor.navBarIconColor,
// //             ),
// //           ),
// //         ),
// //       );
// //     }

// //     if (ref.chatHistoryList.isEmpty) {
// //       return const Expanded(
// //         child: Center(
// //           child: Padding(
// //             padding: EdgeInsets.only(top: 28.0),
// //             child: Text(
// //               "No messages yet. Start a conversation!",
// //               style: TextStyle(color: Colors.grey, fontSize: 16),
// //             ),
// //           ),
// //         ),
// //       );
// //     }

// //     return Expanded(
// //       child: ListView.builder(
// //         controller: _scrollController,
// //         physics: const ClampingScrollPhysics(),
// //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
// //         itemCount: ref.chatHistoryList.length,
// //         itemBuilder: (context, index) {
// //           final item = ref.chatHistoryList[index];

// //           if (item.createdDate == null || item.createdDate!.isEmpty) {
// //             return const SizedBox();
// //           }

// //           DateTime? currentTime;
// //           try {
// //             currentTime = DateTime.parse(item.createdDate!)
// //                 .toUtc()
// //                 .add(const Duration(hours: 5, minutes: 30));
// //           } catch (e) {
// //             debugPrint("❌ DEBUG: Error parsing date: $e");
// //             return const SizedBox();
// //           }

// //           bool showDateLabel = index == 0;
// //           if (!showDateLabel && index > 0) {
// //             final prevItem = ref.chatHistoryList[index - 1];
// //             if (prevItem.createdDate != null &&
// //                 prevItem.createdDate!.isNotEmpty) {
// //               try {
// //                 final prevTime = DateTime.parse(prevItem.createdDate!)
// //                     .toUtc()
// //                     .add(const Duration(hours: 5, minutes: 30));
// //                 showDateLabel = !isSameDay(currentTime, prevTime);
// //               } catch (e) {
// //                 debugPrint("❌ DEBUG: Error parsing previous date: $e");
// //               }
// //             }
// //           }

// //           String tempBody = item.templateParams?.isEmpty ?? true
// //               ? (item.templateBody ?? "")
// //               : replaceTemplateParams(
// //                   item.templateBody ?? "",
// //                   item.templateParams ?? "",
// //                 );

// //           List<ButtonItem> buttons =
// //               (item.button?.isNotEmpty ?? false) ? item.getParsedButtons() : [];

// //           final hasContent = (item.message?.isNotEmpty ?? false) ||
// //               (item.templateName?.isNotEmpty ?? false) ||
// //               (tempBody.isNotEmpty) ||
// //               (item.attachmentUrl?.isNotEmpty ?? false);

// //           if (!hasContent) {
// //             return const SizedBox();
// //           }

// //           return Column(
// //             children: [
// //               if (showDateLabel) ChatDateLabel(date: currentTime),
// //               Padding(
// //                 padding: const EdgeInsets.only(bottom: 15.0),
// //                 child: Container(
// //                   color: ref.msgDeleteList.contains(item.messageId ?? "")
// //                       ? const Color(0xffE6E6E6)
// //                       : Colors.transparent,
// //                   child: ChatBubble(
// //                     tempBody: tempBody,
// //                     item: item,
// //                     buttons: buttons,
// //                     currentTime: currentTime,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildMessageInputArea() {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
// //       child: Consumer3<TemplateController, SfFileUploadController,
// //           ChatMessageController>(
// //         builder: (context, tempCtrl, fileUploadController, chatMsgController,
// //             child) {
// //           return Column(
// //             children: [
// //               const Divider(),
// //               if (chatMsgController.isRecording)
// //                 const Row(
// //                   children: [
// //                     Icon(Icons.fiber_manual_record,
// //                         color: Colors.red, size: 14),
// //                     SizedBox(width: 6),
// //                     Text("Recording...", style: TextStyle(fontSize: 12)),
// //                   ],
// //                 ),
// //               Row(
// //                 children: [
// //                   IconButton(
// //                     icon: const Icon(Icons.attach_file),
// //                     onPressed: () => showPicker(context),
// //                   ),
// //                   _buildFileTypeIndicator(chatMsgController),
// //                   Expanded(
// //                     child: TextField(
// //                       controller: msgController,
// //                       maxLines: 3,
// //                       minLines: 1,
// //                       keyboardType: TextInputType.multiline,
// //                       decoration: InputDecoration(
// //                         hintText: 'Type a message...',
// //                         hintMaxLines: 1,
// //                         border: OutlineInputBorder(
// //                           borderRadius: BorderRadius.circular(20),
// //                           borderSide: BorderSide.none,
// //                         ),
// //                         filled: true,
// //                         fillColor: const Color(0xffE6E6E6),
// //                         contentPadding: const EdgeInsets.symmetric(
// //                           horizontal: 16,
// //                           vertical: 12,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   _buildVoiceMessageButton(chatMsgController),
// //                   _buildTemplateButton(tempCtrl),
// //                   _buildSendButton(chatMsgController, fileUploadController),
// //                 ],
// //               ),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildFileTypeIndicator(ChatMessageController chatMsgController) {
// //     if (chatMsgController.isDoc) {
// //       return const Icon(Icons.edit_document, size: 20);
// //     } else if (chatMsgController.isImage) {
// //       return const Icon(Icons.image, size: 10);
// //     } else if (chatMsgController.isVideo) {
// //       return const Icon(Icons.videocam_rounded, size: 20);
// //     } else if (chatMsgController.isAudio) {
// //       return const Icon(Icons.mic, size: 20);
// //     }
// //     return const SizedBox(width: 0);
// //   }

// //   Widget _buildVoiceMessageButton(ChatMessageController chatMsgController) {
// //     return Padding(
// //       padding: const EdgeInsets.only(left: 4.0),
// //       child: Listener(
// //         onPointerDown: (_) => _startRecording(context),
// //         onPointerUp: (_) => _stopRecording(),
// //         child: Container(
// //           decoration: const BoxDecoration(
// //             color: Color.fromARGB(255, 168, 205, 235),
// //             shape: BoxShape.circle,
// //           ),
// //           padding: const EdgeInsets.all(10),
// //           child: Icon(
// //             chatMsgController.isRecording ? Icons.stop : Icons.mic_none_sharp,
// //             color: chatMsgController.isRecording ? Colors.red : Colors.black,
// //             size: 20,
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildTemplateButton(TemplateController tempCtrl) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
// //       child: InkWell(
// //         onTap: () async {
// //           if (tempCtrl.getTempLoader) return;

// //           tempCtrl.setSelectedTemp(null);
// //           tempCtrl.setSelectedTempName("Select");
// //           tempCtrl.setSeletcedTempCate("ALL");

// //           try {
// //             await tempCtrl.getTemplateApiCall(
// //               category: tempCtrl.selectedTempCategory,
// //             );
// //             TemplatebottomSheetShow(context);
// //           } catch (e) {
// //             debugPrint("❌ DEBUG: Error loading templates: $e");
// //             EasyLoading.showToast("Failed to load templates");
// //           }
// //         },
// //         child: Container(
// //           decoration: BoxDecoration(
// //             color: const Color(0xff8BBCD0),
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           child: Center(
// //             child: Padding(
// //               padding: const EdgeInsets.all(10.0),
// //               child: tempCtrl.getTempLoader
// //                   ? const SizedBox(
// //                       height: 25,
// //                       width: 25,
// //                       child: CircularProgressIndicator(
// //                         color: Colors.white,
// //                       ),
// //                     )
// //                   : const Icon(Icons.code, color: Colors.white, size: 20),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildSendButton(
// //     ChatMessageController chatMsgController,
// //     SfFileUploadController fileUploadController,
// //   ) {
// //     return InkWell(
// //       onTap: () async {
// //         FocusScope.of(context).unfocus();

// //         if (msgController.text.isNotEmpty &&
// //             chatMsgController.selectedFile == null) {
// //           await sendMsg(msgController.text.trim());
// //         } else if (chatMsgController.selectedFile != null) {
// //           await sendFile();
// //         }
// //       },
// //       child: Container(
// //         decoration: BoxDecoration(
// //           color: const Color.fromARGB(255, 76, 162, 189),
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //         child: Center(
// //           child: Padding(
// //             padding: const EdgeInsets.all(10.0),
// //             child: chatMsgController.sendMsgLoader == true ||
// //                     fileUploadController.fileUploadLoader == true
// //                 ? const SizedBox(
// //                     height: 25,
// //                     width: 25,
// //                     child: CircularProgressIndicator(
// //                       color: Colors.white,
// //                     ),
// //                   )
// //                 : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Future<void> sendMsg(String msg) async {
// //     if (msg.trim().isEmpty) {
// //       EasyLoading.showToast(
// //         "Type something...",
// //         toastPosition: EasyLoadingToastPosition.center,
// //       );
// //       return;
// //     }

// //     try {
// //       DashBoardController dbController = Provider.of(context, listen: false);
// //       ChatMessageController messageController =
// //           Provider.of(context, listen: false);

// //       final usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
// //       final code = dbController.selectedContactInfo?.countryCode ?? "91";

// //       if (usrNumber.isEmpty) {
// //         EasyLoading.showToast("No contact selected");
// //         return;
// //       }

// //       debugPrint("📤 DEBUG: Sending message: $msg to $usrNumber");

// //       await messageController.sendMessageApiCall(
// //         msg: msg,
// //         usrNumber: usrNumber,
// //         code: code,
// //       );

// //       msgController.clear();

// //       // Wait and refresh
// //       await Future.delayed(const Duration(milliseconds: 1500));
// //       await _refreshMessages();

// //       _scrollToBottom();
// //       FocusScope.of(context).unfocus();
// //     } catch (e) {
// //       debugPrint("❌ DEBUG: Error sending message: $e");
// //       EasyLoading.showToast("Failed to send message");
// //     }
// //   }

// //   bool isSameDay(DateTime a, DateTime b) {
// //     return a.year == b.year && a.month == b.month && a.day == b.day;
// //   }

// //   Future<void> getUserNumer() async {
// //     try {
// //       SfFileUploadController sfFileUploadController =
// //           Provider.of(context, listen: false);
// //       sfFileUploadController.resetFileUpload();

// //       ChatMessageController chatMsgController =
// //           Provider.of(context, listen: false);
// //       chatMsgController.resetMsgDeleteList();
// //     } catch (e) {
// //       debugPrint("❌ DEBUG: Error in getUserNumer: $e");
// //     }
// //   }

// //   Future<void> _refreshMessagesWithDebug() async {
// //     debugPrint("🔍 DEBUG: _refreshMessagesWithDebug() STARTED");

// //     try {
// //       DashBoardController dbController = Provider.of(context, listen: false);
// //       ChatMessageController cmProvider = Provider.of(context, listen: false);

// //       final usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
// //       debugPrint("🔍 DEBUG: Refresh for user: $usrNumber");

// //       if (usrNumber.isEmpty) {
// //         debugPrint("❌ DEBUG: No user number for refresh");
// //         return;
// //       }

// //       debugPrint("🔄 DEBUG: Calling messageHistoryApiCall...");

// //       final previousCount = cmProvider.chatHistoryList.length;
// //       debugPrint("📊 DEBUG: Previous message count: $previousCount");

// //       await cmProvider.messageHistoryApiCall(
// //         userNumber: usrNumber,
// //         isFirstTime: false,
// //       );

// //       final newCount = cmProvider.chatHistoryList.length;
// //       debugPrint("📊 DEBUG: New message count: $newCount");
// //       debugPrint("📊 DEBUG: Difference: ${newCount - previousCount} messages");

// //       if (newCount > previousCount) {
// //         debugPrint("✅ DEBUG: New messages found!");
// //       } else {
// //         debugPrint("⚠️ DEBUG: No new messages found");
// //       }

// //       _scrollToBottom();
// //       debugPrint("✅ DEBUG: _refreshMessagesWithDebug() COMPLETED");
// //     } catch (e, stackTrace) {
// //       debugPrint("❌ DEBUG: Error in _refreshMessagesWithDebug: $e");
// //       debugPrint("❌ DEBUG: Stack: $stackTrace");
// //     }
// //   }

// //   Future<void> sendFile({bool isAudio = false}) async {
// //     debugPrint("🔍 DEBUG: sendFile() STARTED");

// //     try {
// //       final sfFileController =
// //           Provider.of<SfFileUploadController>(context, listen: false);
// //       final chatMsgCtrl =
// //           Provider.of<ChatMessageController>(context, listen: false);
// //       final dbController =
// //           Provider.of<DashBoardController>(context, listen: false);

// //       final usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
// //       final code = dbController.selectedContactInfo?.countryCode ?? "91";

// //       debugPrint("🔍 DEBUG: User Number = $usrNumber");
// //       debugPrint("🔍 DEBUG: Country Code = $code");

// //       if (usrNumber.isEmpty) {
// //         debugPrint("❌ DEBUG: No user number found");
// //         EasyLoading.showToast("No contact selected");
// //         return;
// //       }

// //       if (chatMsgCtrl.selectedFile == null) {
// //         debugPrint("❌ DEBUG: selectedFile is NULL");
// //         EasyLoading.showToast("No file selected");
// //         return;
// //       }

// //       debugPrint("✅ DEBUG: File found, starting upload process");
// //       debugPrint("📎 DEBUG: File Path = ${chatMsgCtrl.selectedFile!.path}");

// //       try {
// //         final fileSize = await chatMsgCtrl.selectedFile!.length();
// //         debugPrint(
// //             "📎 DEBUG: File Size = ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB");

// //         if (fileSize > 10 * 1024 * 1024) {
// //           debugPrint("❌ DEBUG: File too large");
// //           EasyLoading.showToast("File too large (max 10MB)");
// //           return;
// //         }
// //       } catch (e) {
// //         debugPrint("⚠️ DEBUG: Could not get file size: $e");
// //       }

// //       // Show loading
// //       EasyLoading.show(
// //         status: 'Uploading file...',
// //         maskType: EasyLoadingMaskType.black,
// //         dismissOnTap: false,
// //       );

// //       debugPrint("🔄 DEBUG: Calling uploadFiledb()...");

// //       final stopwatch = Stopwatch()..start();

// //       // UPLOAD FILE - CRITICAL STEP
// //       bool uploadSuccess = await sfFileController.uploadFiledb(
// //         chatMsgCtrl.selectedFile!,
// //         code,
// //         msgController.text.trim(),
// //         usrNumber,
// //       );

// //       stopwatch.stop();
// //       debugPrint("⏱️ DEBUG: Upload took ${stopwatch.elapsedMilliseconds}ms");

// //       EasyLoading.dismiss();

// //       if (uploadSuccess) {
// //         debugPrint("✅✅✅ DEBUG: FILE UPLOAD SUCCESSFUL!");

// //         // Get upload details for debugging
// //         debugPrint("📊 DEBUG: Upload details:");
// //         debugPrint("   - fileDocId: ${sfFileController.fileDocId}");
// //         debugPrint("   - filePubUrl: ${sfFileController.filePubUrl}");
// //         debugPrint("   - fileMimeType: ${sfFileController.fileMimeType}");

// //         EasyLoading.showSuccess(
// //           '✅ File uploaded!',
// //           duration: Duration(seconds: 1),
// //         );

// //         // Clear input
// //         msgController.clear();
// //         chatMsgCtrl.setSelectedFile(null);

// //         // CRITICAL: Wait for backend to process and save
// //         debugPrint("⏳ DEBUG: Waiting for backend processing...");
// //         await Future.delayed(const Duration(seconds: 2));

// //         // Force refresh messages
// //         debugPrint("🔄 DEBUG: Force refreshing messages...");
// //         await _refreshMessagesWithDebug();

// //         _scrollToBottom();
// //         debugPrint("🎉 DEBUG: sendFile() COMPLETED SUCCESSFULLY");
// //       } else {
// //         debugPrint("❌❌❌ DEBUG: FILE UPLOAD FAILED!");
// //         EasyLoading.showError(
// //           '❌ Upload failed! Please try again',
// //           duration: Duration(seconds: 2),
// //         );
// //       }
// //     } catch (e, stackTrace) {
// //       EasyLoading.dismiss();
// //       debugPrint("🔥🔥🔥 DEBUG: EXCEPTION in sendFile()!");
// //       debugPrint("🔥 Error: $e");
// //       debugPrint("🔥 Stack Trace: $stackTrace");
// //       EasyLoading.showError(
// //         'Error: ${e.toString().split(':').first}',
// //         duration: Duration(seconds: 2),
// //       );
// //     }
// //   }

// //   Future<void> connectSocket() async {
// //     debugPrint("🔌 DEBUG: connectSocket() STARTED");

// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       String tkn = prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";
// //       final busNum =
// //           prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";

// //       debugPrint("🔑 DEBUG: Token length: ${tkn.length}");
// //       debugPrint("🔑 DEBUG: Business Number: $busNum");

// //       if (tkn.isEmpty || busNum.isEmpty) {
// //         debugPrint("❌❌❌ DEBUG: MISSING TOKEN OR BUSINESS NUMBER!");
// //         return;
// //       }

// //       debugPrint("🔌 DEBUG: Creating socket connection...");

// //       socket = IO.io(
// //         'https://admin.watconnect.com',
// //         IO.OptionBuilder()
// //             .setTransports(['websocket', 'polling'])
// //             .setPath('/ibs/socket.io')
// //             .setExtraHeaders({
// //               'Authorization': 'Bearer $tkn',
// //               'Content-Type': 'application/json',
// //             })
// //             .setQuery({'token': tkn})
// //             .enableForceNew()
// //             .enableReconnection()
// //             .setReconnectionAttempts(5)
// //             .setReconnectionDelay(1000)
// //             .setTimeout(20000)
// //             .build(),
// //       );

// //       socket!.onConnect((_) {
// //         debugPrint('✅✅✅ DEBUG: SOCKET CONNECTED!');
// //         debugPrint('🆔 DEBUG: Socket ID: ${socket!.id}');
// //         _isSocketConnected = true;
// //       });

// //       socket!.onConnectError((error) {
// //         debugPrint('❌❌❌ DEBUG: SOCKET CONNECT ERROR: $error');
// //         _isSocketConnected = false;
// //       });

// //       socket!.onDisconnect((reason) {
// //         debugPrint('🔌 DEBUG: Socket Disconnected: $reason');
// //         _isSocketConnected = false;
// //       });

// //       socket!.on("connected", (data) {
// //         debugPrint("🎉 DEBUG: WebSocket 'connected' event: $data");
// //       });

// //       // MOST IMPORTANT EVENT FOR SENT MESSAGES
// //       socket!.on("sentwhatsappmessage", (data) async {
// //         debugPrint("📤📤📤 DEBUG: 'sentwhatsappmessage' EVENT!");
// //         debugPrint("📤 DEBUG: Data: $data");

// //         // Try to extract message info
// //         try {
// //           if (data is Map) {
// //             debugPrint("📤 DEBUG: Message ID: ${data['messageId']}");
// //             debugPrint("📤 DEBUG: Type: ${data['type']}");
// //             debugPrint(
// //                 "📤 DEBUG: Has attachment: ${data['attachmentUrl'] != null}");
// //           }
// //         } catch (e) {
// //           debugPrint("⚠️ DEBUG: Could not parse sent message: $e");
// //         }

// //         // Refresh messages after file is sent
// //         await Future.delayed(const Duration(seconds: 1));
// //         await _refreshMessages();
// //       });

// //       socket!.on("receivedwhatsappmessage", (data) async {
// //         debugPrint("💬💬💬 DEBUG: 'receivedwhatsappmessage' EVENT!");
// //         debugPrint("💬 DEBUG: Data: $data");
// //         await _refreshMessages();
// //       });

// //       socket!.on("fileuploadcomplete", (data) {
// //         debugPrint("✅✅✅ DEBUG: 'fileuploadcomplete' EVENT!");
// //         debugPrint("✅ DEBUG: File upload complete: $data");
// //       });

// //       debugPrint("🔌 DEBUG: Attempting socket connection...");
// //       socket!.connect();
// //       debugPrint("✅ DEBUG: connectSocket() COMPLETED");
// //     } catch (error, stackTrace) {
// //       debugPrint("🔥🔥🔥 DEBUG: EXCEPTION in connectSocket()!");
// //       debugPrint("🔥 Error: $error");
// //       debugPrint("🔥 Stack Trace: $stackTrace");
// //       _isSocketConnected = false;
// //     }
// //   }

// //   void disconnectSocket() {
// //     if (socket != null && _isSocketConnected) {
// //       socket!.disconnect();
// //       _isSocketConnected = false;
// //       debugPrint("🔌 DEBUG: WebSocket Disconnected");
// //     }
// //   }

// //   Future<void> _stopRecording() async {
// //     try {
// //       String? recordedPath = await _recorder.stopRecorder();
// //       if (recordedPath != null) {
// //         File audioFile = File(recordedPath);
// //         ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
// //         chatMsgCtrl.setSelectedFile(audioFile);
// //         chatMsgCtrl.setRecordingStatus(false);
// //         await Future.delayed(const Duration(milliseconds: 300));
// //         _showPreviewDialog();
// //       }
// //     } catch (e) {
// //       debugPrint("❌ DEBUG: Stop recording error: $e");
// //       EasyLoading.showToast("Failed to stop recording");
// //     }
// //   }

// //   Future<void> _startRecording(BuildContext context) async {
// //     ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
// //     chatMsgCtrl.setSelectedFile(null);

// //     var status = await Permission.microphone.status;
// //     if (status.isGranted) {
// //       await _beginRecording();
// //       return;
// //     }

// //     if (status.isDenied) {
// //       status = await Permission.microphone.request();
// //       if (status.isGranted) {
// //         await _beginRecording();
// //         return;
// //       }
// //     }

// //     if (status.isPermanentlyDenied || status.isDenied) {
// //       _showPermissionDialog(context);
// //     }
// //   }

// //   Future<void> _beginRecording() async {
// //     try {
// //       final Directory tempDir = await getTemporaryDirectory();
// //       final String filePath =
// //           '${tempDir.path}/voice_msg_${DateTime.now().millisecondsSinceEpoch}.aac';
// //       _audioPath = filePath;

// //       await _recorder.startRecorder(
// //         toFile: filePath,
// //         codec: fs.Codec.aacADTS,
// //       );
// //       ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
// //       chatMsgCtrl.setRecordingStatus(true);
// //     } catch (e) {
// //       debugPrint("❌ DEBUG: Recording error: $e");
// //       EasyLoading.showToast("Failed to start recording");
// //     }
// //   }

// //   void _showPermissionDialog(BuildContext context) {
// //     showDialog<void>(
// //       context: context,
// //       builder: (ctx) => AlertDialog(
// //         title: const Text("Microphone Access Needed"),
// //         content: Platform.isIOS
// //             ? const Text(
// //                 "Microphone access is disabled. Please enable it from Settings > Privacy > Microphone.")
// //             : const Text(
// //                 "Permission permanently denied. Please enable it in Settings."),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(ctx),
// //             child: const Text("Cancel"),
// //           ),
// //           TextButton(
// //             onPressed: () {
// //               Navigator.pop(ctx);
// //               openAppSettings();
// //             },
// //             child: const Text("Open Settings"),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Future<void> _showPreviewDialog() async {
// //     if (_audioPath == null) return;

// //     final audioPlayerForDuration = AudioPlayer();
// //     Duration? audioDuration;

// //     try {
// //       await audioPlayerForDuration.setFilePath(_audioPath!);
// //       audioDuration = audioPlayerForDuration.duration;
// //     } catch (e) {
// //       debugPrint("❌ DEBUG: Error getting audio duration: $e");
// //     } finally {
// //       await audioPlayerForDuration.dispose();
// //     }

// //     if (audioDuration == null || audioDuration.inSeconds < 3) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text("Audio must be at least 3 seconds long."),
// //         ),
// //       );
// //       return;
// //     }

// //     await showDialog(
// //       context: context,
// //       builder: (context) {
// //         return Consumer<ChatMessageController>(
// //           builder: (context, chatController, child) {
// //             Future<void> startPlayer() async {
// //               await _player.startPlayer(
// //                 fromURI: _audioPath!,
// //                 codec: fs.Codec.aacADTS,
// //                 whenFinished: () {
// //                   chatController.setPlayPreviewStatus(false);
// //                 },
// //               );
// //               chatController.setPlayPreviewStatus(true);
// //               _previewPlayerSubscription?.cancel();
// //               _previewPlayerSubscription =
// //                   _player.onProgress?.listen((event) {});
// //             }

// //             Future<void> stopPlayer() async {
// //               await _player.stopPlayer();
// //               _previewPlayerSubscription?.cancel();
// //               chatController.setPlayPreviewStatus(false);
// //             }

// //             return AlertDialog(
// //               title: const Text('Voice Message Preview'),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(16),
// //               ),
// //               content: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   IconButton(
// //                     icon: Icon(
// //                       chatController.isPlayingPreview
// //                           ? Icons.pause_circle_filled
// //                           : Icons.play_circle_fill,
// //                       size: 48,
// //                       color: AppColor.navBarIconColor,
// //                     ),
// //                     onPressed: () {
// //                       chatController.isPlayingPreview
// //                           ? stopPlayer()
// //                           : startPlayer();
// //                     },
// //                   ),
// //                 ],
// //               ),
// //               actions: [
// //                 TextButton(
// //                   onPressed: () async {
// //                     stopPlayer();
// //                     if (chatController.selectedFile != null) {
// //                       await sendFile();
// //                     }
// //                     EasyLoading.showToast("Sending audio...");
// //                     Navigator.pop(context);
// //                   },
// //                   child: const Text('Send'),
// //                 ),
// //                 TextButton(
// //                   onPressed: () {
// //                     stopPlayer();
// //                     chatController.setPlayPreviewStatus(false);
// //                     chatController.setSelectedFile(null);
// //                     chatController.setRecordingStatus(false);
// //                     Navigator.pop(context);
// //                   },
// //                   child: const Text('Cancel'),
// //                 ),
// //               ],
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// // }

// // String replaceTemplateParams(String templateBody, String paramsJsonString) {
// //   try {
// //     final List<dynamic> paramsList = paramsJsonString.isNotEmpty
// //         ? List<Map<String, dynamic>>.from((jsonDecode(paramsJsonString) as List)
// //             .map((e) => e as Map<String, dynamic>))
// //         : [];

// //     for (var param in paramsList) {
// //       final name = param['name']?.toString() ?? '';
// //       final value = param['value']?.toString() ?? '';
// //       if (name.isNotEmpty) {
// //         templateBody = templateBody.replaceAll(name, value);
// //       }
// //     }
// //   } catch (e) {
// //     debugPrint('❌ DEBUG: Error replacing template params: $e');
// //   }
// //   return templateBody;
// // }

// // void showPicker(BuildContext context) async {
// //   await showModalBottomSheet(
// //     context: context,
// //     backgroundColor: AppColor.navBarIconColor,
// //     builder: (context) => Wrap(
// //       children: <Widget>[
// //         ListTile(
// //           leading: const Icon(Icons.photo_library, color: Colors.white),
// //           title: const Text(
// //             'Choose from Gallery',
// //             style: TextStyle(color: Colors.white),
// //           ),
// //           onTap: () {
// //             pickImageFromGallery(context);
// //           },
// //         ),
// //         ListTile(
// //           leading: const Icon(Icons.camera_alt, color: Colors.white),
// //           title: const Text(
// //             'Take a Photo',
// //             style: TextStyle(color: Colors.white),
// //           ),
// //           onTap: () {
// //             pickImageFromCamera(context);
// //           },
// //         ),
// //       ],
// //     ),
// //   );
// // }

// // Future<void> pickImageFromGallery(context) async {
// //   debugPrint("🖼️ DEBUG: pickImageFromGallery() STARTED");

// //   try {
// //     debugPrint("🔒 DEBUG: Checking permissions...");
// //     var status = await Permission.photos.status;
// //     debugPrint("🔒 DEBUG: Current permission status: $status");

// //     if (status.isDenied) {
// //       debugPrint("🔒 DEBUG: Requesting permission...");
// //       status = await Permission.photos.request();
// //       debugPrint("🔒 DEBUG: New permission status: $status");
// //     }

// //     if (status.isGranted) {
// //       debugPrint("📁 DEBUG: Opening file picker...");

// //       // FIX: Use FileType.image WITHOUT allowedExtensions
// //       // OR use FileType.custom WITH allowedExtensions
// //       final pickedFile = await FilePicker.platform.pickFiles(
// //         allowMultiple: false,
// //         type: FileType.image, // Changed from FileType.custom
// //         // REMOVED: allowedExtensions: ["jpg", "jpeg", "png", "gif"],
// //       );

// //       debugPrint("📁 DEBUG: File picker returned: ${pickedFile != null}");

// //       if (pickedFile != null && pickedFile.files.isNotEmpty) {
// //         var file = pickedFile.files.first;

// //         debugPrint("📁 DEBUG: Selected file details:");
// //         debugPrint("   - Name: ${file.name}");
// //         debugPrint("   - Size: ${file.size} bytes");
// //         debugPrint("   - Path: ${file.path}");
// //         debugPrint("   - Extension: ${file.extension}");
// //         debugPrint("   - Mime Type: ${file.extension}");

// //         if (file.path == null || file.path!.isEmpty) {
// //           debugPrint("❌ DEBUG: File path is null or empty");
// //           EasyLoading.showToast("Could not access file");
// //           Navigator.pop(context);
// //           return;
// //         }

// //         File image = File(file.path!);

// //         debugPrint("🔍 DEBUG: Checking if file exists...");
// //         bool fileExists = await image.exists();
// //         debugPrint("🔍 DEBUG: File exists: $fileExists");

// //         if (!fileExists) {
// //           debugPrint("❌ DEBUG: File does not exist on disk");
// //           EasyLoading.showToast("File not found");
// //           Navigator.pop(context);
// //           return;
// //         }

// //         ChatMessageController chatMsgController =
// //             Provider.of(context, listen: false);

// //         debugPrint("💾 DEBUG: Setting selected file in controller");
// //         chatMsgController.setSelectedFile(image);
// //         // chatMsgController.setIsImage(true); // IMPORTANT: Set this flag

// //         debugPrint("✅ DEBUG: File successfully selected");
// //         EasyLoading.showSuccess("✅ Image selected",
// //             duration: Duration(seconds: 1));

// //         debugPrint("🎛️ DEBUG: Controller state after selection:");
// //         debugPrint(
// //             "   - selectedFile: ${chatMsgController.selectedFile?.path}");
// //         debugPrint("   - isImage: ${chatMsgController.isImage}");
// //         debugPrint("   - isVideo: ${chatMsgController.isVideo}");
// //         debugPrint("   - isDoc: ${chatMsgController.isDoc}");
// //         debugPrint("   - isAudio: ${chatMsgController.isAudio}");
// //       } else {
// //         debugPrint("⚠️ DEBUG: No file selected or empty file list");
// //       }
// //     } else {
// //       debugPrint("❌ DEBUG: Permission denied");
// //       EasyLoading.showToast("Permission denied");
// //     }
// //   } catch (e, stackTrace) {
// //     debugPrint("🔥 DEBUG: Error in pickImageFromGallery: $e");
// //     debugPrint("🔥 DEBUG: Stack: $stackTrace");
// //     EasyLoading.showToast("Error selecting image");
// //   }

// //   debugPrint("🖼️ DEBUG: pickImageFromGallery() ENDED");
// //   if (Navigator.canPop(context)) {
// //     Navigator.pop(context);
// //   }
// // }

// // Future<void> pickImageFromCamera(context) async {
// //   debugPrint("📸 DEBUG: pickImageFromCamera() STARTED");

// //   try {
// //     var status = await Permission.camera.status;
// //     if (status.isDenied) {
// //       status = await Permission.camera.request();
// //     }

// //     if (status.isGranted) {
// //       ImagePicker picker = ImagePicker();
// //       final pickedFile = await picker.pickImage(
// //         source: ImageSource.camera,
// //         imageQuality: 80,
// //       );

// //       if (pickedFile != null) {
// //         ChatMessageController chatMsgController =
// //             Provider.of(context, listen: false);
// //         File image = File(pickedFile.path);
// //         chatMsgController.setSelectedFile(image);
// //         EasyLoading.showSuccess("✅ Photo taken",
// //             duration: Duration(seconds: 1));
// //       }
// //     } else {
// //       EasyLoading.showToast("Camera permission denied");
// //     }
// //   } catch (e) {
// //     debugPrint("❌ DEBUG: Error taking photo: $e");
// //     EasyLoading.showToast("Error taking photo");
// //   }

// //   Navigator.pop(context);
// // }

// // // Template related functions (keep them as is)
// // void TemplatebottomSheetShow(BuildContext context, {bool isFromCamp = false}) {
// //   showCommonBottomSheet(
// //     context: context,
// //     title: "Category And Template",
// //     col: Consumer<TemplateController>(builder: (context, tempc, child) {
// //       return Column(
// //         crossAxisAlignment: CrossAxisAlignment.center,
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           CustomDropdown(
// //             items: const ['ALL', 'UTILITY', 'MARKETING'],
// //             selectedValue: tempc.selectedTempCategory,
// //             onChanged: (newVal) async {
// //               if (newVal != null) {
// //                 tempc.setSeletcedTempCate(newVal);
// //                 tempc.setSelectedTempName("Select");
// //                 tempc.setSelectedTemp(null);
// //                 await tempc.getTemplateApiCall(
// //                   category: tempc.selectedTempCategory,
// //                 );
// //               }
// //             },
// //           ),
// //           const SizedBox(height: 12),
// //           CustomDropdown(
// //             items: tempc.templateNames,
// //             selectedValue: tempc.selectedTempName,
// //             enabled: !tempc.getTempLoader,
// //             onChanged: (newVal) {
// //               if (newVal != null) {
// //                 tempc.setSelectedTempName(newVal);
// //               }
// //             },
// //           ),
// //           const SizedBox(height: 20),
// //           InkWell(
// //             onTap: () {
// //               if (tempc.selectedTemplate == null) {
// //                 EasyLoading.showToast("Select Template to continue");
// //               } else {
// //                 Navigator.pop(context);
// //                 SfFileUploadController sfFileUploadController =
// //                     Provider.of(context, listen: false);
// //                 sfFileUploadController.resetFileUpload();
// //                 reviewBottomSheetShow(context, fromCamp: isFromCamp);
// //               }
// //             },
// //             child: Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
// //               decoration: BoxDecoration(
// //                 color: AppColor.navBarIconColor,
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               child: const Text(
// //                 "Review Template",
// //                 style: TextStyle(color: Colors.white),
// //               ),
// //             ),
// //           ),
// //           const SizedBox(height: 40),
// //         ],
// //       );
// //     }),
// //   );
// // }

// // void reviewBottomSheetShow(BuildContext context, {bool fromCamp = false}) {
// //   final tempc = Provider.of<TemplateController>(context, listen: false);
// //   final chatMsgController =
// //       Provider.of<ChatMessageController>(context, listen: false);

// //   final templateData = tempc.selectedTemplate;
// //   final fieldCount = templateData?.storedParameterValues?.length ?? 0;

// //   tempc.setupControllers(fieldCount);
// //   chatMsgController.setSelectedFile(null);

// //   showModalBottomSheet(
// //     context: context,
// //     isScrollControlled: true,
// //     backgroundColor: Colors.white,
// //     shape: const RoundedRectangleBorder(
// //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //     ),
// //     builder: (context) {
// //       return GestureDetector(
// //         behavior: HitTestBehavior.opaque,
// //         onTap: () => FocusScope.of(context).unfocus(),
// //         child: SafeArea(
// //           child: Padding(
// //             padding: EdgeInsets.only(
// //               bottom: MediaQuery.of(context).viewInsets.bottom,
// //               left: 12,
// //               right: 12,
// //               top: 20,
// //             ),
// //             child: Consumer2<TemplateController, ChatMessageController>(
// //               builder: (context, tempc, chatMsgController, child) {
// //                 final templateData = tempc.selectedTemplate;
// //                 final headerType = templateData?.headerType ?? "";
// //                 List<ButtonItem> buttons =
// //                     (templateData?.button?.isNotEmpty ?? false)
// //                         ? templateData!.getParsedButtons()
// //                         : [];

// //                 return SingleChildScrollView(
// //                   child: Form(
// //                     key: _addTemplateFormKey,
// //                     child: Column(
// //                       mainAxisSize: MainAxisSize.min,
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             const Text(
// //                               "Review Template",
// //                               style: TextStyle(
// //                                 fontSize: 20,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                             IconButton(
// //                               onPressed: () => Navigator.pop(context),
// //                               icon: const Icon(Icons.cancel_outlined),
// //                             ),
// //                           ],
// //                         ),
// //                         const Divider(),
// //                         if (templateData?.name != null)
// //                           Padding(
// //                             padding: const EdgeInsets.symmetric(vertical: 10),
// //                             child: Text(
// //                               templateData!.name!,
// //                               style: const TextStyle(
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: 18,
// //                               ),
// //                             ),
// //                           ),
// //                         ...List.generate(
// //                           tempc.textControllers.length,
// //                           (index) => Padding(
// //                             padding: const EdgeInsets.only(bottom: 12.0),
// //                             child: TextFormField(
// //                               controller: tempc.textControllers[index],
// //                               cursorColor: AppColor.navBarIconColor,
// //                               keyboardType: TextInputType.text,
// //                               textInputAction: TextInputAction.next,
// //                               decoration: InputDecoration(
// //                                 labelText: 'Placeholder ${index + 1}',
// //                                 border: const OutlineInputBorder(),
// //                               ),
// //                               validator: (value) {
// //                                 if (value!.isEmpty) return 'Required';
// //                                 return null;
// //                               },
// //                             ),
// //                           ),
// //                         ),
// //                         if ((templateData?.headerText?.isNotEmpty ?? false) ||
// //                             (templateData?.body?.isNotEmpty ?? false) ||
// //                             (templateData?.footer?.isNotEmpty ?? false) ||
// //                             (templateData?.messageBody?.isNotEmpty ?? false) ||
// //                             buttons.isNotEmpty)
// //                           Container(
// //                             margin: const EdgeInsets.symmetric(vertical: 10),
// //                             padding: const EdgeInsets.all(8),
// //                             decoration: BoxDecoration(
// //                               color: const Color(0xffE3FFC9),
// //                               borderRadius: BorderRadius.circular(10),
// //                             ),
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 if (["IMAGE", "VIDEO", "DOCUMENT"]
// //                                     .contains(headerType))
// //                                   chatMsgController.selectedFile == null
// //                                       ? HeaderTypePreview(
// //                                           headerType: headerType)
// //                                       : buildHeaderPreviewWidget(
// //                                           file: chatMsgController.selectedFile!,
// //                                           type: headerType,
// //                                         ),
// //                                 if (templateData?.headerText?.isNotEmpty ??
// //                                     false)
// //                                   Text(templateData!.headerText!),
// //                                 if (templateData?.body?.isNotEmpty ?? false)
// //                                   Text(templateData!.body!),
// //                                 if (templateData?.messageBody?.isNotEmpty ??
// //                                     false)
// //                                   Text(templateData!.messageBody!),
// //                                 if (templateData?.footer?.isNotEmpty ?? false)
// //                                   Text(templateData!.footer!),
// //                                 if (buttons.isNotEmpty)
// //                                   ChatButtons(buttons: buttons),
// //                                 PickMediaButton(
// //                                   label: "Pick $headerType",
// //                                   onTap: () => pickMedia(context, headerType),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         Center(
// //                           child: ElevatedButton(
// //                             style: ElevatedButton.styleFrom(
// //                               backgroundColor: AppColor.navBarIconColor,
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(10),
// //                               ),
// //                             ),
// //                             onPressed: () {
// //                               if (_addTemplateFormKey.currentState!
// //                                   .validate()) {
// //                                 if (tempc.sendTempLoader) return;
// //                                 if (["IMAGE", "VIDEO", "DOCUMENT"]
// //                                         .contains(headerType) &&
// //                                     chatMsgController.selectedFile == null) {
// //                                   EasyLoading.showToast(
// //                                       "Select $headerType to continue");
// //                                   return;
// //                                 }
// //                                 if (fromCamp) {
// //                                   tempc.resetTempParamList();
// //                                   sendCampTemp(context, tempc.textControllers);
// //                                 } else {
// //                                   sendChatTemp(context, tempc.textControllers);
// //                                 }
// //                               }
// //                             },
// //                             child: tempc.sendTempLoader
// //                                 ? const SizedBox(
// //                                     height: 18,
// //                                     width: 18,
// //                                     child: CircularProgressIndicator(
// //                                       strokeWidth: 2,
// //                                       color: Colors.white,
// //                                     ),
// //                                   )
// //                                 : const Text(
// //                                     "Send Template",
// //                                     style: TextStyle(color: Colors.white),
// //                                   ),
// //                           ),
// //                         ),
// //                         const SizedBox(height: 20),
// //                       ],
// //                     ),
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //         ),
// //       );
// //     },
// //   );
// // }

// // Future<void> sendChatTemp(
// //     BuildContext context, List<TextEditingController> controllers) async {
// //   final tempc = Provider.of<TemplateController>(context, listen: false);
// //   final templateData = tempc.selectedTemplate;
// //   final dbController = Provider.of<DashBoardController>(context, listen: false);
// //   final chatMsgController =
// //       Provider.of<ChatMessageController>(context, listen: false);
// //   final sfFileUploadController =
// //       Provider.of<SfFileUploadController>(context, listen: false);

// //   final usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
// //   final code = dbController.selectedContactInfo?.countryCode ?? "91";
// //   final userNumer = "$code$usrNumber";
// //   final userInputs = controllers.map((e) => e.text.trim()).toList();

// //   try {
// //     if (chatMsgController.selectedFile != null) {
// //       await sfFileUploadController.uploadFiledb(
// //         chatMsgController.selectedFile!,
// //         code,
// //         "",
// //         usrNumber,
// //         isFromTemplate: true,
// //       );

// //       await tempc.sendTemplateApiCall(
// //         tempId: templateData?.templateId ?? "",
// //         usrNumber: userNumer,
// //         params: userInputs,
// //         docId: sfFileUploadController.fileDocId,
// //         url: sfFileUploadController.filePubUrl,
// //         mimetyp: sfFileUploadController.fileMimeType,
// //       );
// //     } else {
// //       await tempc.sendTemplateApiCall(
// //         tempId: templateData?.templateId ?? "",
// //         usrNumber: userNumer,
// //         params: userInputs,
// //       );
// //     }
// //     Navigator.pop(context);
// //   } catch (e) {
// //     debugPrint("❌ DEBUG: Error sending template: $e");
// //     EasyLoading.showToast("Failed to send template");
// //   }
// // }

// // void sendCampTemp(
// //     BuildContext context, List<TextEditingController> controllers) {
// //   Navigator.pop(context);
// //   final tempc = Provider.of<TemplateController>(context, listen: false);
// //   final userInputs = controllers.map((e) => e.text.trim()).toList();
// //   tempc.setTempParams(userInputs);
// //   tempc.setCampTempController(tempc.selectedTempName);
// // }

// // Future<void> pickMedia(BuildContext context, String type) async {
// //   final chatMsgController =
// //       Provider.of<ChatMessageController>(context, listen: false);

// //   try {
// //     if (type == "IMAGE") {
// //       final pickedFile = await ImagePicker().pickImage(
// //         source: ImageSource.gallery,
// //         imageQuality: 80,
// //       );
// //       if (pickedFile != null) {
// //         chatMsgController.setSelectedFile(File(pickedFile.path));
// //         EasyLoading.showToast("Image Picked Successfully");
// //       }
// //     } else {
// //       final extensions = type == "VIDEO"
// //           ? ["mp4", "mov", "avi", "mkv", "webm"]
// //           : ["pdf", "txt", "doc", "docx", "ppt", "pptx", "xls", "xlsx", "csv"];

// //       final result = await FilePicker.platform.pickFiles(
// //         type: FileType.custom,
// //         allowedExtensions: extensions,
// //       );

// //       if (result != null) {
// //         chatMsgController.setSelectedFile(File(result.files.first.path!));
// //         EasyLoading.showToast("$type Picked Successfully");
// //       }
// //     }
// //   } catch (e) {
// //     debugPrint("❌ DEBUG: Error picking media: $e");
// //     EasyLoading.showToast("Error picking file");
// //   }
// // }

// // Widget buildHeaderPreviewWidget({required File file, required String type}) {
// //   switch (type) {
// //     case 'IMAGE':
// //       return Image.file(file,
// //           height: 80, width: double.infinity, fit: BoxFit.cover);
// //     case 'VIDEO':
// //       return Container(
// //         height: 80,
// //         width: double.infinity,
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(10),
// //           color: Colors.black,
// //         ),
// //         child: const Center(
// //           child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
// //         ),
// //       );
// //     case 'DOCUMENT':
// //     default:
// //       return Container(
// //         height: 80,
// //         width: double.infinity,
// //         decoration: BoxDecoration(
// //           color: Colors.grey[200],
// //           borderRadius: BorderRadius.circular(10),
// //         ),
// //         child: const Center(
// //           child: Icon(Icons.insert_drive_file, size: 40, color: Colors.grey),
// //         ),
// //       );
// //   }
// // }

// // ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, avoid_print, must_be_immutable, deprecated_member_use

// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:focus_detector/focus_detector.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_sound/flutter_sound.dart' as fs;
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:socket_io_common/src/util/event_emitter.dart';
// import 'package:whatsapp/salesforce/controller/business_number_controller.dart';
// import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
// import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
// import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
// import 'package:whatsapp/salesforce/controller/template_controller.dart';
// import 'package:whatsapp/salesforce/model/chat_history_model.dart';
// import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
// import 'package:whatsapp/salesforce/widget/chat_bubble.dart';
// import 'package:whatsapp/salesforce/widget/chat_buttons.dart';
// import 'package:whatsapp/salesforce/widget/chat_date_lable.dart';
// import 'package:whatsapp/salesforce/widget/custom_bottom_sheet.dart';
// import 'package:whatsapp/salesforce/widget/custom_drop_down.dart';
// import 'package:whatsapp/salesforce/widget/header_type_preview.dart';
// import 'package:whatsapp/salesforce/widget/pick_media_buttons.dart';
// import 'package:whatsapp/salesforce/widget/sf_chat_appbar.dart';
// import 'package:whatsapp/utils/app_color.dart';
// import 'package:whatsapp/utils/app_constants.dart';
// import 'package:whatsapp/utils/function_lib.dart';
// import 'package:whatsapp/view_models/lead_controller.dart';
// import 'package:whatsapp/view_models/user_list_vm.dart';

// final GlobalKey<FormState> _addTemplateFormKey = GlobalKey<FormState>();

// class SfMessageChatScreen extends StatefulWidget {
//   List<SfDrawerItemModel>? pinnedLeadsList;
//   bool isFromRecentChat;
//   SfMessageChatScreen(
//       {super.key, this.pinnedLeadsList, this.isFromRecentChat = false});

//   @override
//   State<SfMessageChatScreen> createState() => _SfMessageChatScreenState();
// }

// class _SfMessageChatScreenState extends State<SfMessageChatScreen> {
//   TextEditingController msgController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   int _previousChatLength = 0;
//   // File? _audioFile;
//   IO.Socket? socket;
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
//   final FlutterSoundPlayer _player = FlutterSoundPlayer();

//   StreamSubscription? _previewPlayerSubscription;

//   String? _audioPath;

//   String userNumer = "";

//   @override
//   void initState() {
//     super.initState();
//     ChatMessageController chatMsgController =
//         Provider.of(context, listen: false);
//     isCallAvailable();
//     // chatMsgController.setSelectedFile(null);
//     _initializeAudio();
//     // connectSocket();
//     getUserNumer();
//   }

//   bool hasCalls = false;

//   isCallAvailable() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";

//     Map<String, dynamic> decodedToken = Map<String, dynamic>.from(
//       JwtDecoder.decode(token),
//     );

//     var modulesList = decodedToken['modules'];
//     List availableModule =
//         modulesList.map((e) => e['name'].toString()).toList();

//     List<String> stringList = List<String>.from(availableModule);

//     hasCalls = stringList.contains("Calls");
//     setState(() {});
//   }

//   Future<void> _initializeAudio() async {
//     await _player.openPlayer();
//     await _recorder.openRecorder();
//   }

//   @override
//   void dispose() {
//     disconnectSocket();
//     _recorder.closeRecorder();
//     _player.closePlayer();
//     _previewPlayerSubscription?.cancel();
//     msgController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: AppColor.navBarIconColor,
//         statusBarIconBrightness: Brightness.dark,
//         statusBarBrightness: Brightness.light,
//       ),
//     );

//     return Consumer<ChatMessageController>(builder: (context, ref, child) {
//       final currentLength = ref.chatHistoryList.length;

//       if (currentLength > _previousChatLength && ref.msgDeleteList.isEmpty) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _scrollToBottom();
//         });
//       }

//       _previousChatLength = currentLength;
//       return GestureDetector(
//         onTap: () {
//           FocusScope.of(context).unfocus();
//         },
//         child: FocusDetector(
//           onFocusGained: () async {
//             final prefs = await SharedPreferences.getInstance();
//             prefs.setBool("isOnSFChatPage", true);

//             // print("Screen focused again");
//             log('\x1B[95mFCM     Leads Screen focused again::::::::::::::::::::::::::::::::::::::::::::::::::');
//             ChatMessageController cmProvider =
//                 Provider.of(context, listen: false);
//             DashBoardController dbController =
//                 Provider.of(context, listen: false);

//             final usrNumber =
//                 dbController.selectedContactInfo?.whatsappNumber ?? "";
//             Future.delayed(const Duration(milliseconds: 1), () async {
//               await cmProvider.messageHistoryApiCall(
//                 userNumber: usrNumber,
//                 isFirstTime: false,
//               );
//               _scrollToBottom();
//             });
//             connectSocket();

//             Future.delayed(const Duration(milliseconds: 1500), () async {
//               await cmProvider.messageHistoryApiCall(
//                 userNumber: usrNumber,
//                 isFirstTime: false,
//               );
//               _scrollToBottom();
//             });
//           },
//           onFocusLost: () async {
//             final prefs = await SharedPreferences.getInstance();
//             prefs.setBool("isOnSFChatPage", false);
//             disconnectSocket();
//           },
//           child: SafeArea(
//             bottom: true,
//             child: Scaffold(
//               backgroundColor: Colors.white,
//               resizeToAvoidBottomInset: true,
//               appBar: SfChatAppBar(
//                 hasCalls: hasCalls,
//               ),
//               body: Stack(
//                 children: [
//                   RefreshIndicator(
//                     onRefresh: _pullRefresh,
//                     child: _pageBody(),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }

//   Future<void> _pullRefresh() async {
//     await Future.delayed(const Duration(seconds: 1));
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         print("scrolling to the extreme bottom.............");
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   _pageBody() {
//     return Consumer<ChatMessageController>(builder: (context, ref, child) {
//       // WidgetsBinding.instance.addPostFrameCallback((_) {
//       //   if (ref.msgDeleteList.isEmpty) {
//       //     _scrollToBottom();
//       //   }
//       // });

//       return Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Column(
//               children: [
//                 if (widget.pinnedLeadsList!.isNotEmpty)
//                   Padding(
//                     padding:
//                         const EdgeInsets.only(top: 15.0, left: 15, right: 15),
//                     child: SizedBox(
//                       height: 90,
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: widget.pinnedLeadsList!.length,
//                         itemBuilder: (context, index) {
//                           return GestureDetector(
//                             onTap: () async {
//                               if (widget.isFromRecentChat) {
//                                 DashBoardController dashBoardController =
//                                     Provider.of(context, listen: false);
//                                 String phNum =
//                                     "${dashBoardController.sfPinnedRecentChatList[index].countryCode ?? ""}${dashBoardController.sfPinnedRecentChatList[index].whatsappNumber ?? ""}";

//                                 ChatMessageController cmProvider =
//                                     Provider.of(context, listen: false);
//                                 DashBoardController dbProvider =
//                                     Provider.of(context, listen: false);
//                                 dbProvider.setSelectedPinnedInfo(null);

//                                 dbProvider.setSelectedContaactInfo(
//                                     dashBoardController
//                                         .sfPinnedRecentChatList[index]);
//                                 await cmProvider
//                                     .messageHistoryApiCall(
//                                         userNumber: phNum, isFirstTime: true)
//                                     .then((onValue) {});
//                               } else {
//                                 String phNum =
//                                     "${widget.pinnedLeadsList![index].countryCode ?? ""}${widget.pinnedLeadsList![index].whatsappNumber ?? ""}";

//                                 ChatMessageController cmProvider =
//                                     Provider.of(context, listen: false);
//                                 DashBoardController dbProvider =
//                                     Provider.of(context, listen: false);
//                                 dbProvider.setSelectedPinnedInfo(null);
//                                 dbProvider.setSelectedContaactInfo(
//                                     widget.pinnedLeadsList![index]);

//                                 await cmProvider
//                                     .messageHistoryApiCall(
//                                   userNumber: phNum,
//                                 )
//                                     .then((onValue) {
//                                   // Navigator.pop(navigatorKey.currentContext!);
//                                 });
//                               }

//                               // _scrollToBottom();
//                             },
//                             child: SizedBox(
//                               width: 60,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   CircleAvatar(
//                                     radius: 20,
//                                     backgroundColor: AppColor.navBarIconColor,
//                                     child: Text(
//                                       widget.pinnedLeadsList![index].name!
//                                               .isNotEmpty
//                                           ? widget
//                                               .pinnedLeadsList![index].name![0]
//                                               .toUpperCase()
//                                           : '?',
//                                       style: const TextStyle(
//                                         fontSize: 20,
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 5),
//                                   Text(
//                                     widget.pinnedLeadsList![index].name ?? "",
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 const SizedBox(height: 10),
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.5),
//                           blurRadius: 5,
//                           spreadRadius: 3,
//                           offset: const Offset(2, 4),
//                         ),
//                       ],
//                       color: Colors.white,
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(30),
//                         topRight: Radius.circular(30),
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(12.0),
//                           child: Row(
//                             children: [
//                               const CircleAvatar(
//                                 backgroundImage: NetworkImage(
//                                   'https://www.w3schools.com/w3images/avatar2.png',
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: Consumer<DashBoardController>(
//                                   builder: (context, dbRef, child) {
//                                     return Text(
//                                       dbRef.selectedContactInfo?.name ?? "",
//                                       style:
//                                           const TextStyle(color: Colors.black),
//                                     );
//                                   },
//                                 ),
//                               ),
//                               const Spacer(),
//                               Consumer<ChatMessageController>(
//                                   builder: (context, msgCtrol, child) {
//                                 return msgCtrol.msgDeleteList.isEmpty
//                                     ? const SizedBox()
//                                     : InkWell(
//                                         onTap: () {
//                                           DashBoardController dbController =
//                                               Provider.of(context,
//                                                   listen: false);

//                                           String code = dbController
//                                                   .selectedContactInfo
//                                                   ?.countryCode ??
//                                               "91";
//                                           String num = dbController
//                                                   .selectedContactInfo
//                                                   ?.whatsappNumber ??
//                                               "";
//                                           String whatsappNum = "$code$num";
//                                           msgCtrol.chatMsgDeleteApiCall(
//                                               whatsappNum);
//                                         },
//                                         child: const Icon(
//                                           Icons.delete,
//                                           color: Colors.black,
//                                         ),
//                                       );
//                               }),
//                               PopupMenuButton<String>(
//                                 icon: const Icon(Icons.more_vert,
//                                     color: Colors.black),
//                                 onSelected: (String value) {
//                                   if (value == 'Clear Chat') {
//                                     ChatMessageController messageController =
//                                         Provider.of(context, listen: false);
//                                     DashBoardController dbController =
//                                         Provider.of(context, listen: false);

//                                     String usrNumber = dbController
//                                             .selectedContactInfo
//                                             ?.whatsappNumber ??
//                                         "";
//                                     String code = dbController
//                                             .selectedContactInfo?.countryCode ??
//                                         "91";
//                                     var wpNum = "$code$usrNumber";
//                                     messageController
//                                         .deleteHistoryApiCall(wpNum);
//                                   }
//                                 },
//                                 itemBuilder: (BuildContext context) => const [
//                                   PopupMenuItem<String>(
//                                     value: 'Clear Chat',
//                                     child: Text('Clear Chat'),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         const Divider(height: 1),
//                         ref.chatHistoryLoader
//                             ? const Padding(
//                                 padding: EdgeInsets.only(top: 38.0),
//                                 child: CircularProgressIndicator(
//                                   color: AppColor.navBarIconColor,
//                                 ),
//                               )
//                             : ref.chatHistoryList.isEmpty
//                                 ? const Center(
//                                     child: Padding(
//                                       padding: EdgeInsets.only(top: 28.0),
//                                       child: Text(
//                                         "No Chat Available..",
//                                         style: TextStyle(
//                                             color: Colors.black, fontSize: 16),
//                                       ),
//                                     ),
//                                   )
//                                 : Expanded(
//                                     child: ListView.builder(
//                                       controller: _scrollController,
//                                       itemCount: ref.chatHistoryList.length,
//                                       itemBuilder: (context, index) {
//                                         final item = ref.chatHistoryList[index];
//                                         final currentRaw = item.createdDate;
//                                         if (currentRaw == null ||
//                                             currentRaw.isEmpty) {
//                                           return const SizedBox();
//                                         }

//                                         final currentTime =
//                                             DateTime.parse(currentRaw)
//                                                 .toUtc()
//                                                 .add(const Duration(
//                                                     hours: 5, minutes: 30));

//                                         bool showDateLabel = index == 0;
//                                         if (!showDateLabel) {
//                                           final prevRaw = ref
//                                               .chatHistoryList[index - 1]
//                                               .createdDate;
//                                           if (prevRaw != null &&
//                                               prevRaw.isNotEmpty) {
//                                             final prevTime =
//                                                 DateTime.parse(prevRaw)
//                                                     .toUtc()
//                                                     .add(const Duration(
//                                                         hours: 5, minutes: 30));
//                                             showDateLabel = !isSameDay(
//                                                 currentTime, prevTime);
//                                           }
//                                         }

//                                         String tempBody =
//                                             item.templateParams!.isEmpty
//                                                 ? (item.templateBody ?? "")
//                                                 : replaceTemplateParams(
//                                                     item.templateBody ?? "",
//                                                     item.templateParams ?? "");

//                                         List<ButtonItem> buttons =
//                                             (item.button?.isNotEmpty ?? false)
//                                                 ? item.getParsedButtons()
//                                                 : [];

//                                         final hasContent =
//                                             (item.message?.isNotEmpty ??
//                                                     false) ||
//                                                 (item.templateName
//                                                         ?.isNotEmpty ??
//                                                     false) ||
//                                                 (tempBody.isNotEmpty) ||
//                                                 (item.attachmentUrl
//                                                         ?.isNotEmpty ??
//                                                     false);

//                                         if (!hasContent) {
//                                           return const SizedBox();
//                                         }

//                                         return Column(
//                                           children: [
//                                             if (showDateLabel)
//                                               ChatDateLabel(date: currentTime),
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   bottom: 15.0),
//                                               child: Container(
//                                                 color: ref.msgDeleteList
//                                                         .contains(
//                                                             item.messageId ??
//                                                                 "")
//                                                     ? const Color(0xffE6E6E6)
//                                                     : Colors.transparent,
//                                                 child: ChatBubble(
//                                                   tempBody: tempBody,
//                                                   item: item,
//                                                   buttons: buttons,
//                                                   currentTime: currentTime,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         );
//                                       },
//                                     ),
//                                   ),
//                         if (ref.chatHistoryList.isEmpty ||
//                             ref.chatHistoryLoader)
//                           const Spacer(),
//                         _buildMessageInputArea(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       );
//     });
//   }

//   Future<void> _stopRecording() async {
//     try {
//       String? recordedPath = await _recorder.stopRecorder();
//       if (recordedPath != null) {
//         File audioFile = File(recordedPath);

//         ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
//         chatMsgCtrl.setSelectedFile(audioFile);

//         chatMsgCtrl.setRecordingStatus(false);

//         await Future.delayed(const Duration(milliseconds: 300));
//         _showPreviewDialog();
//       }
//     } catch (e) {
//       debugPrint("Stop recording error: $e");
//       EasyLoading.showToast("Failed to stop recording");
//     }
//   }

//   Future<void> _startRecording(BuildContext context) async {
//     ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
//     chatMsgCtrl.setSelectedFile(null);

//     var status = await Permission.microphone.status;

//     if (status.isGranted) {
//       // Start recording immediately
//       await _beginRecording();
//       return;
//     }

//     PermissionStatus status1 = await Permission.microphone.status;
//     print('Microphone permission status: $status1');

//     if (status.isDenied) {
//       // Request permission (system dialog may show)
//       status = await Permission.microphone.request();

//       if (status.isGranted) {
//         await _beginRecording();
//         return;
//       }
//       // If still denied or permanently denied, show dialog
//       if (status.isPermanentlyDenied || status.isDenied) {
//         _showPermissionDialog(context);
//         return;
//       }
//     }

//     if (status.isPermanentlyDenied) {
//       // User permanently denied permission, must open settings manually
//       _showPermissionDialog(context);
//       return;
//     }

//     if (status.isRestricted || status.isLimited) {
//       EasyLoading.showToast("Microphone access is restricted or limited.");
//       return;
//     }
//   }

//   Future<void> _beginRecording() async {
//     try {
//       final Directory tempDir = await getTemporaryDirectory();
//       final String filePath =
//           '${tempDir.path}/voice_msg_${DateTime.now().millisecondsSinceEpoch}.aac';
//       _audioPath = filePath;

//       await _recorder.startRecorder(
//         toFile: filePath,
//         codec: fs.Codec.aacADTS,
//       );
//       ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
//       chatMsgCtrl.setRecordingStatus(true);
//     } catch (e) {
//       debugPrint("Recording error: $e");
//       EasyLoading.showToast("Failed to start recording");
//     }
//   }

//   void _showPermissionDialog(BuildContext context) {
//     showDialog<void>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("Microphone Access Needed"),
//         content: Platform.isIOS
//             ? const Text(
//                 "Microphone access is disabled. Please enable it from Settings > Privacy > Microphone.")
//             : const Text(
//                 "Permission permanently denied. Please enable it in Settings."),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(ctx);
//               openAppSettings();
//             },
//             child: const Text("Open Settings"),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _showPreviewDialog() async {
//     if (_audioPath == null) return;
//     // Get duration using just_audio
//     final audioPlayerForDuration = AudioPlayer();
//     Duration? audioDuration;

//     try {
//       await audioPlayerForDuration.setFilePath(_audioPath!);
//       audioDuration = audioPlayerForDuration.duration;
//     } catch (e) {
//       print("catching errer in show audio preview dialog:::::::::   $e");
//     } finally {
//       await audioPlayerForDuration.dispose();
//     }
//     if (audioDuration == null || audioDuration.inSeconds < 3) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Audio must be at least 3 seconds long."),
//         ),
//       );
//       return;
//     }
//     await showDialog(
//       context: context,
//       builder: (context) {
//         return Consumer<ChatMessageController>(
//           builder: (context, chatController, child) {
//             Future<void> startPlayer() async {
//               await _player.startPlayer(
//                 fromURI: _audioPath!,
//                 codec: fs.Codec.aacADTS,
//                 whenFinished: () {
//                   chatController.setPlayPreviewStatus(false);
//                 },
//               );

//               chatController.setPlayPreviewStatus(true);

//               _previewPlayerSubscription?.cancel();
//               _previewPlayerSubscription =
//                   _player.onProgress?.listen((event) {});
//             }

//             Future<void> stopPlayer() async {
//               await _player.stopPlayer();
//               _previewPlayerSubscription?.cancel();

//               chatController.setPlayPreviewStatus(false);
//             }

//             return AlertDialog(
//               title: const Text('Voice Message Preview'),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   IconButton(
//                     icon: Icon(
//                       chatController.isPlayingPreview
//                           ? Icons.pause_circle_filled
//                           : Icons.play_circle_fill,
//                       size: 48,
//                       color: AppColor.navBarIconColor,
//                     ),
//                     onPressed: () {
//                       chatController.isPlayingPreview
//                           ? stopPlayer()
//                           : startPlayer();
//                     },
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () async {
//                     stopPlayer();

//                     if (chatController.selectedFile != null) {
//                       await sendFile();
//                     }
//                     EasyLoading.showToast("Sending audio...");

//                     Navigator.pop(context);
//                   },
//                   child: const Text('Send'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     stopPlayer();
//                     chatController.setPlayPreviewStatus(false);
//                     chatController.setSelectedFile(null);
//                     chatController.setRecordingStatus(false);
//                     Navigator.pop(context);
//                   },
//                   child: const Text('Cancel'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   _buildMessageInputArea() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
//       child: sendMsgRow(),
//     );
//   }

//   sendMsgRow() {
//     return Consumer3<TemplateController, SfFileUploadController,
//             ChatMessageController>(
//         builder: (context, tempCtrl, fileUploadController, chatMsgController,
//             child) {
//       return Column(
//         children: [
//           const Divider(),
//           if (chatMsgController.isRecording)
//             const Row(
//               children: [
//                 Icon(Icons.fiber_manual_record, color: Colors.red),
//                 SizedBox(width: 6),
//                 Text("Recording..."),
//               ],
//             ),
//           Row(
//             children: [
//               Expanded(
//                 child: Row(
//                   children: [
//                     IconButton(
//                         icon: const Icon(Icons.attach_file),
//                         onPressed: () {
//                           showPicker(context);
//                         }),
//                     chatMsgController.isDoc
//                         ? const Icon(Icons.edit_document)
//                         : chatMsgController.isImage
//                             ? const Icon(Icons.image)
//                             : chatMsgController.isVideo
//                                 ? const Icon(Icons.videocam_rounded)
//                                 : chatMsgController.isAudio
//                                     ? const Icon(Icons.mic)
//                                     : const SizedBox(),
//                     Expanded(
//                       child: TextField(
//                         controller: msgController,
//                         maxLines: 3,
//                         minLines: 1,
//                         keyboardType: TextInputType.multiline,
//                         decoration: InputDecoration(
//                             hintText: 'Type a message...',
//                             hintMaxLines: 1,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(20),
//                               borderSide: BorderSide.none,
//                             ),
//                             filled: true,
//                             fillColor: const Color(0xffE6E6E6)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(left: 4.0),
//                 child: Listener(
//                   onPointerDown: (_) => _startRecording(context),
//                   onPointerUp: (_) => _stopRecording(),
//                   child: Container(
//                     decoration: const BoxDecoration(
//                       color: Color.fromARGB(255, 168, 205, 235),
//                       shape: BoxShape.circle,
//                     ),
//                     padding: const EdgeInsets.all(10),
//                     child: Icon(
//                       chatMsgController.isRecording
//                           ? Icons.stop
//                           : Icons.mic_none_sharp,
//                       color: chatMsgController.isRecording
//                           ? Colors.red
//                           : Colors.black,
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: InkWell(
//                   onTap: () async {
//                     if (tempCtrl.getTempLoader) {
//                     } else {
//                       tempCtrl.setSelectedTemp(null);
//                       tempCtrl.setSelectedTempName("Select");

//                       tempCtrl.setSeletcedTempCate("ALL");
//                       await tempCtrl.getTemplateApiCall(
//                           category: tempCtrl.selectedTempCategory);
//                       TemplatebottomSheetShow(context);
//                     }
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: const Color(0xff8BBCD0),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Center(
//                         child: Padding(
//                       padding: const EdgeInsets.all(10.0),
//                       child: tempCtrl.getTempLoader
//                           ? const SizedBox(
//                               height: 25,
//                               width: 25,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                               ),
//                             )
//                           : const Icon(Icons.code, color: Colors.white),
//                     )),
//                   ),
//                 ),
//               ),
//               InkWell(
//                 onTap: () async {
//                   Future.delayed(const Duration(milliseconds: 1000), () async {
//                     FocusScope.of(context).unfocus();
//                   });
//                   ChatMessageController chatMsgCtrl =
//                       Provider.of(context, listen: false);
//                   if (msgController.text.isNotEmpty &&
//                       chatMsgCtrl.selectedFile == null) {
//                     await sendMsg(msgController.text.trim());
//                   }
//                   if (chatMsgCtrl.selectedFile != null) {
//                     sendFile();
//                   }
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: const Color.fromARGB(255, 76, 162, 189),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Center(
//                       child: Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: chatMsgController.sendMsgLoader == true ||
//                             fileUploadController.fileUploadLoader == true
//                         ? const SizedBox(
//                             height: 25,
//                             width: 25,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                             ),
//                           )
//                         : const Icon(Icons.send_rounded, color: Colors.white),
//                   )),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       );
//     });
//   }

//   sendMsg(String msg) {
//     print("we are calling this:::  $msg");
//     if (msg.trim().isEmpty) {
//       EasyLoading.showToast("Type something.....",
//           toastPosition: EasyLoadingToastPosition.center);
//     } else {
//       DashBoardController dbController = Provider.of(context, listen: false);

//       ChatMessageController messageController =
//           Provider.of(context, listen: false);
//       messageController.sendMessageApiCall(
//         msg: msg,
//         usrNumber: dbController.selectedContactInfo?.whatsappNumber ?? "",
//         code: dbController.selectedContactInfo?.countryCode ?? "91",
//       );
//       msgController.clear();

//       Future.delayed(const Duration(milliseconds: 100), () async {
//         _scrollToBottom();
//         FocusScope.of(context).unfocus();
//       });

//       // Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
//     }
//   }

//   bool isSameDay(DateTime a, DateTime b) {
//     return a.year == b.year && a.month == b.month && a.day == b.day;
//   }

//   getUserNumer() {
//     SfFileUploadController sfFileUploadController =
//         Provider.of(context, listen: false);

//     sfFileUploadController.resetFileUpload();
//     ChatMessageController chatMsgController =
//         Provider.of(context, listen: false);

//     chatMsgController.resetMsgDeleteList();
//   }

//   Future<void> sendFile({bool isAudio = false}) async {
//     SfFileUploadController sfFileController =
//         Provider.of(context, listen: false);
//     ChatMessageController chatMsgCtrl = Provider.of(context, listen: false);
//     DashBoardController dbController = Provider.of(context, listen: false);
//     var usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
//     var code = dbController.selectedContactInfo?.countryCode ?? "91";

//     // if (chatMsgCtrl.selectedFile != null) {
//     //   await sfFileController.uploadFiledb(chatMsgCtrl.selectedFile!, code,
//     //       msgController.text.trim(), usrNumber);
//     // }
//     // msgController.clear();
//   }

//   Future<void> connectSocket() async {
//     final prefs = await SharedPreferences.getInstance();

//     String tkn = prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";
//     final busNum = prefs.getString(SharedPrefsConstants.sfBusinessNumber) ?? "";

//     if (tkn.isEmpty || busNum.isEmpty) {
//       print("❌ Missing token or business number for socket connection");
//       return;
//     } else {
//       log("tkn node>>>>>>>>>> $tkn");
//     }

//     Map<String, dynamic> decodedToken =
//         Map<String, dynamic>.from(JwtDecoder.decode(tkn));
//     String devId = await getDeviceId();
//     // LeadController leadCtrl = Provider.of(context, listen: false);
//     BusinessNumberController busNumCtrl = Provider.of(context, listen: false);
//     final dbController =
//         Provider.of<DashBoardController>(context, listen: false);
//     decodedToken.addAll({
//       "business_numbers": busNumCtrl.sfAllBusNums,
//       "businessNumber": busNum,
//       "userId": decodedToken['id'],
//       "deviceId": devId
//     });

//     log("decodedToken>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  $decodedToken");

//     print("🔌 Connecting WebSocket with token: ${tkn.substring(0, 20)}...");

//     try {
//       socket = IO.io(
//         'https://admin.watconnect.com',
//         IO.OptionBuilder()
//             .setTransports(['websocket', 'polling'])
//             .setPath('/ibs/socket.io')
//             .setExtraHeaders({
//               'Authorization': 'Bearer $tkn',
//               'Content-Type': 'application/json',
//             })
//             .setQuery({'token': tkn})
//             .enableForceNew()
//             .enableReconnection()
//             .setReconnectionAttempts(5)
//             .setReconnectionDelay(1000)
//             .setTimeout(20000)
//             .build(),
//       );

//       /// ✅ Connected
//       socket!.onConnect((_) {
//         print('✅ Connected to WebSocket');
//         print('🆔 Socket ID: ${socket!.id}');

//         socket!.emitWithAck("setup", decodedToken, ack: (response) {
//           print('✅ Setup acknowledged: $response');
//         });
//       });

//       /// ❌ Connection error
//       socket!.onConnectError((error) {
//         print('❌ Connect Error: $error');
//       });

//       /// ⚠️ Socket error
//       socket!.onError((error) {
//         print('⚠️ Socket Error: $error');
//       });

//       /// 🔌 Disconnected
//       socket!.onDisconnect((reason) {
//         print('🔌 Disconnected: $reason');
//       });

//       /// 📢 Server confirms setup
//       socket!.on("connected", (_) {
//         print("🎉 WebSocket setup complete");
//       });

//       /// 📡 LISTEN TO ALL EVENTS (SAFE)
//       socket!.onAny((event, [data]) {
//         print("📡 Event: $event");
//         print("📦 Data: $data");
//       });

//       socket!.on("receivedwhatsappmessage", (data) async {
//         print("💬 New WhatsApp message received: $data");
//         DashBoardController dbController = Provider.of(context, listen: false);

//         final usrNumber =
//             dbController.selectedContactInfo?.whatsappNumber ?? "";
//         print("usrNumberLLLL >>>>>  $usrNumber");

//         if (usrNumber.isNotEmpty) {
//           print("trying to make api call");
//           ChatMessageController cmProvider =
//               Provider.of(context, listen: false);

//           Future.delayed(const Duration(milliseconds: 1000), () async {
//             await cmProvider.messageHistoryApiCall(
//               userNumber: usrNumber,
//               isFirstTime: false,
//             );
//             _scrollToBottom();
//           });

//           _scrollToBottom();
//         }
//       });

//       /// 🔌 Explicit connectP
//       socket!.connect();
//     } catch (error, stackTrace) {
//       print("❌ Error connecting to WebSocket");
//       print("Error: $error");
//       print("StackTrace: $stackTrace");
//     }
//   }

//   void disconnectSocket() {
//     if (socket != null) {
//       socket!.disconnect();
//       print(" WebSocket Disconnected  recent");
//     }
//   }
// }

// String replaceTemplateParams(String templateBody, String paramsJsonString) {
//   // log("replacing template params:::   $templateBody   $paramsJsonString");
//   try {
//     final List<dynamic> paramsList = paramsJsonString.isNotEmpty
//         ? List<Map<String, dynamic>>.from((jsonDecode(paramsJsonString) as List)
//             .map((e) => e as Map<String, dynamic>))
//         : [];

//     for (var param in paramsList) {
//       print(
//           "param['label'] :::  ${param['name']}  param['value']::: ${param['value']} ");
//       final name = param['name']?.toString() ?? '';
//       final value = param['value']?.toString() ?? '';
//       if (name.isNotEmpty) {
//         templateBody = templateBody.replaceAll(name, value);
//         log("templateBody after replace::::    $templateBody");
//       }
//     }
//   } catch (e) {
//     print('Error replacing template params: $e');
//   }

//   return templateBody;
// }

// // void showPicker(BuildContext context) async {
// //   await showModalBottomSheet(
// //     context: context,
// //     backgroundColor: AppColor.navBarIconColor,
// //     builder: (context) => Wrap(
// //       children: <Widget>[
// //         ListTile(
// //           leading: const Icon(Icons.photo_library, color: Colors.white),
// //           title: const Text(
// //             'Choose from Gallery',
// //             style: TextStyle(color: Colors.white),
// //           ),
// //           onTap: () {
// //             pickImageFromGallery(context);
// //           },
// //         ),
// //         ListTile(
// //           leading: const Icon(Icons.camera_alt, color: Colors.white),
// //           title: const Text(
// //             'Take a Photo',
// //             style: TextStyle(color: Colors.white),
// //           ),
// //           onTap: () {
// //             pickImageFromCamera(context);
// //           },
// //         ),
// //       ],
// //     ),
// //   );
// // }
// void showPicker(BuildContext context) async {
//   debug(" Showing media picker bottom sheet...");
//   await showModalBottomSheet(
//     context: context,
//     backgroundColor: AppColor.navBarIconColor,
//     builder: (context) => Wrap(
//       children: <Widget>[
//         ListTile(
//           leading: const Icon(Icons.photo_library, color: Colors.white),
//           title: const Text(
//             'Choose from Gallery',
//             style: TextStyle(color: Colors.white),
//           ),
//           onTap: () async {
//             Navigator.pop(context);
//             await pickImageFromGallery(context);
//           },
//         ),
//         ListTile(
//           leading: const Icon(Icons.camera_alt, color: Colors.white),
//           title: const Text(
//             'Take a Photo',
//             style: TextStyle(color: Colors.white),
//           ),
//           onTap: () async {
//             Navigator.pop(context);
//             await pickImageFromCamera(context);
//           },
//         ),
//       ],
//     ),
//   );
// }
// Future<void> pickImageFromGallery(BuildContext context) async {
//   debug("Picking file from gallery...");

//   // 🔥 Provider reference BEFORE await
//   final chatMsgController =
//       Provider.of<ChatMessageController>(context, listen: false);

//   final pickedFile = await FilePicker.platform.pickFiles(
//     allowMultiple: false,
//     type: FileType.custom,
//     allowedExtensions: [
//       "jpg","jpeg","png","gif","pdf","html","txt","doc","docx",
//       "ppt","pptx","xls","xlsx","mp4","mov","avi","mkv",
//       "csv","rtf","odt","zip","rar",
//     ],
//   );

//   if (pickedFile != null) {
//     debug("File picked: ${pickedFile.files.first.name}");

//     var file = pickedFile.files.first;
//     File image = File(file.path!);

//     chatMsgController.setSelectedFile(image);
//   }

//   if (context.mounted) {
//     Navigator.pop(context);
//   }
// }

// Future<void> pickImageFromCamera(context) async {
//   ImagePicker picker = ImagePicker();
//   final pickedFile = await picker.pickImage(
//     source: ImageSource.camera,
//     imageQuality: 80,
//   );
//   if (pickedFile != null) {
//     ChatMessageController chatMsgController =
//         Provider.of(context, listen: false);
//     File image = File(pickedFile.path);
//     chatMsgController.setSelectedFile(image);
//   }
//   Navigator.pop(context);
// }

// void TemplatebottomSheetShow(context, {bool isFromCamp = false}) {
//   return showCommonBottomSheet(
//       context: context,
//       title: "Category And Templete",
//       col: Consumer<TemplateController>(builder: (context, tempc, child) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CustomDropdown(
//               items: const [
//                 'ALL',
//                 'UTILITY',
//                 'MARKETING',
//               ],
//               selectedValue: tempc.selectedTempCategory,
//               onChanged: (newVal) async {
//                 if (newVal != null) {
//                   tempc.setSeletcedTempCate(newVal);
//                   // selectedCategory = newVal;
//                   tempc.setSelectedTempName("Select");

//                   tempc.setSelectedTemp(null);
//                   await tempc.getTemplateApiCall(
//                     category: tempc.selectedTempCategory,
//                   );
//                 }
//               },
//             ),
//             const SizedBox(
//               height: 12,
//             ),
//             CustomDropdown(
//               items: tempc.templateNames,
//               selectedValue: tempc.selectedTempName,
//               enabled: !tempc.getTempLoader,
//               onChanged: (newVal) {
//                 if (newVal != null) {
//                   tempc.setSelectedTempName(newVal);
//                 }
//               },
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             InkWell(
//               onTap: () {
//                 if (tempc.selectedTemplate == null) {
//                   EasyLoading.showToast("Select Template to continue");
//                 } else {
//                   Navigator.pop(context);
//                   SfFileUploadController sfFileUploadController =
//                       Provider.of(context, listen: false);

//                   sfFileUploadController.resetFileUpload();
//                   reviewBottomSheetShow(context, fromCamp: isFromCamp);
//                 }
//               },
//               child: IntrinsicWidth(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: AppColor.navBarIconColor,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Padding(
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
//                     child: Center(
//                       child: Text(
//                         "Review Template",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 40,
//             ),
//           ],
//         );
//       }));
// }

// void reviewBottomSheetShow(BuildContext context, {bool fromCamp = false}) {
//   final tempc = Provider.of<TemplateController>(context, listen: false);
//   final chatMsgController =
//       Provider.of<ChatMessageController>(context, listen: false);

//   final templateData = tempc.selectedTemplate;
//   final fieldCount = templateData?.storedParameterValues?.length ?? 0;

//   tempc.setupControllers(fieldCount);
//   // chatMsgController.setSelectedFile(null);

//   showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         final maxHeight = MediaQuery.of(context).size.height * 0.8;

//         return GestureDetector(
//           behavior: HitTestBehavior.opaque,
//           onTap: () => FocusScope.of(context).unfocus(),
//           child: SafeArea(
//             bottom: true,
//             top: false,
//             child: Padding(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//                 left: 12,
//                 right: 12,
//                 top: 20,
//               ),
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   maxHeight: maxHeight,
//                 ),
//                 child: Material(
//                   // ensure proper styling
//                   color: Colors.white,
//                   borderRadius:
//                       const BorderRadius.vertical(top: Radius.circular(20)),
//                   child: Consumer2<TemplateController, ChatMessageController>(
//                     builder: (context, tempc, chatMsgController, child) {
//                       final templateData = tempc.selectedTemplate;
//                       final headerType = templateData?.headerType ?? "";
//                       List<ButtonItem> buttons =
//                           (templateData?.button?.isNotEmpty ?? false)
//                               ? templateData!.getParsedButtons()
//                               : [];

//                       return SingleChildScrollView(
//                         physics: const ClampingScrollPhysics(),
//                         child: Form(
//                           key: _addTemplateFormKey,
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               /// Title Row
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   const Text(
//                                     "Review Template",
//                                     style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                   IconButton(
//                                     onPressed: () => Navigator.pop(context),
//                                     icon: const Icon(Icons.cancel_outlined),
//                                   )
//                                 ],
//                               ),
//                               const Divider(),

//                               if (templateData?.name != null)
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 10),
//                                   child: Text(
//                                     templateData!.name!,
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 18),
//                                   ),
//                                 ),

//                               /// Dynamic Text Fields
//                               ...List.generate(tempc.textControllers.length,
//                                   (index) {
//                                 return Padding(
//                                   padding: const EdgeInsets.only(bottom: 12.0),
//                                   child: TextFormField(
//                                     controller: tempc.textControllers[index],
//                                     cursorColor: AppColor.navBarIconColor,
//                                     keyboardType: TextInputType.text,
//                                     textInputAction: TextInputAction.next,
//                                     decoration: InputDecoration(
//                                       labelText: 'Placeholder ${index + 1}',
//                                       border: const OutlineInputBorder(),
//                                     ),
//                                     validator: (value) {
//                                       if (value!.isEmpty) {
//                                         return 'All fields are required';
//                                       }
//                                       return null;
//                                     },
//                                   ),
//                                 );
//                               }),

//                               /// Template Preview
//                               if ((templateData?.headerText?.isNotEmpty ??
//                                       false) ||
//                                   (templateData?.body?.isNotEmpty ?? false) ||
//                                   (templateData?.footer?.isNotEmpty ?? false) ||
//                                   (templateData?.messageBody?.isNotEmpty ??
//                                       false) ||
//                                   buttons.isNotEmpty)
//                                 Container(
//                                   margin:
//                                       const EdgeInsets.symmetric(vertical: 10),
//                                   padding: const EdgeInsets.all(8),
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xffE3FFC9),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       if (["IMAGE", "VIDEO", "DOCUMENT"]
//                                           .contains(headerType))
//                                         chatMsgController.selectedFile == null
//                                             ? HeaderTypePreview(
//                                                 headerType: headerType)
//                                             : buildHeaderPreviewWidget(
//                                                 file: chatMsgController
//                                                     .selectedFile!,
//                                                 type: headerType,
//                                               ),
//                                       if (templateData
//                                               ?.headerText?.isNotEmpty ??
//                                           false)
//                                         Text(templateData!.headerText!),
//                                       if (templateData?.body?.isNotEmpty ??
//                                           false)
//                                         Text(templateData!.body!),
//                                       if (templateData
//                                               ?.messageBody?.isNotEmpty ??
//                                           false)
//                                         Text(templateData!.messageBody!),
//                                       if (templateData?.footer?.isNotEmpty ??
//                                           false)
//                                         Text(templateData!.footer!),
//                                       if (buttons.isNotEmpty)
//                                         ChatButtons(buttons: buttons),
//                                       PickMediaButton(
//                                         label: "Pick $headerType",
//                                         onTap: () =>
//                                             pickMedia(context, headerType),
//                                       ),
//                                     ],
//                                   ),
//                                 ),

//                               /// Send Button
//                               Align(
//                                 alignment: Alignment.center,
//                                 child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: AppColor.navBarIconColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                   onPressed: () {
//                                     if (_addTemplateFormKey.currentState!
//                                         .validate()) {
//                                       if (tempc.sendTempLoader) return;
//                                       if (["IMAGE", "VIDEO", "DOCUMENT"]
//                                               .contains(headerType) &&
//                                           chatMsgController.selectedFile ==
//                                               null) {
//                                         EasyLoading.showToast(
//                                             "Select $headerType to continue");
//                                         return;
//                                       }

//                                       if (fromCamp) {
//                                         tempc.resetTempParamList();
//                                         sendCampTemp(
//                                             context, tempc.textControllers);
//                                       } else {
//                                         sendChatTemp(
//                                             context, tempc.textControllers);
//                                       }
//                                     }
//                                   },
//                                   child: tempc.sendTempLoader
//                                       ? const SizedBox(
//                                           height: 18,
//                                           width: 18,
//                                           child: CircularProgressIndicator(
//                                             strokeWidth: 2,
//                                             color: Colors.white,
//                                           ),
//                                         )
//                                       : const Text(
//                                           "Send Template",
//                                           style: TextStyle(color: Colors.white),
//                                         ),
//                                 ),
//                               ),
//                               const SizedBox(height: 20),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       });
// }

// Future<void> sendChatTemp(
//     context, List<TextEditingController> controllers) async {
//   TemplateController tempc = Provider.of(context, listen: false);
//   var templateData = tempc.selectedTemplate;
//   DashBoardController dbController = Provider.of(context, listen: false);

//   var usrNumber = dbController.selectedContactInfo?.whatsappNumber ?? "";
//   var code = dbController.selectedContactInfo?.countryCode ?? "91";
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

//         tempc
//             .sendTemplateApiCall(
//                 tempId: templateData?.templateId ?? "",
//                 usrNumber: userNumer,
//                 params: userInputs,
//                 docId: sfFileUploadController.fileDocId,
//                 url: sfFileUploadController.filePubUrl,
//                 mimetyp: sfFileUploadController.fileMimeType)
//             .then((onValue) {
//           Navigator.pop(context);
//         });
//       },
//     );
//   } else {
//     tempc
//         .sendTemplateApiCall(
//             tempId: templateData?.templateId ?? "",
//             usrNumber: userNumer,
//             params: userInputs)
//         .then((onValue) {
//       Navigator.pop(context);
//     });
//   }
// }

// void sendCampTemp(context, List<TextEditingController> controllers) {
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

// Future<void> pickMedia(BuildContext context, String type) async {
//   final chatMsgController =
//       Provider.of<ChatMessageController>(context, listen: false);

//   if (type == "IMAGE") {
//     final pickedFile = await ImagePicker().pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 80,
//     );
//     if (pickedFile != null) {
//       EasyLoading.showToast("Image Picked Successfully");
//       chatMsgController.setSelectedFile(File(pickedFile.path));
//     }
//   } else {
//     final extensions = type == "VIDEO"
//         ? ["mp4", "mov", "avi", "mkv", "webm"]
//         : ["pdf", "txt", "doc", "docx", "ppt", "pptx", "xls", "xlsx", "csv"];

//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: extensions,
//     );

//     if (result != null) {
//       EasyLoading.showToast("$type Picked Successfully");
//       chatMsgController.setSelectedFile(File(result.files.first.path!));
//     }
//   }
// }

// Widget buildHeaderPreviewWidget({required File file, required String type}) {
//   switch (type) {
//     case 'IMAGE':
//       return Image.file(file, height: 80);
//     case 'VIDEO':
//       return Container(
//         height: 80,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           color: Colors.black,
//         ),
//         child: const Center(
//           child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
//         ),
//       );
//     case 'DOCUMENT':
//     default:
//       return Image.asset("assets/images/file.png", height: 80, width: 80);
//   }
// }

// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, avoid_print, must_be_immutable, deprecated_member_use

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
              body: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: _pullRefresh,
                    child: _pageBody(),
                  ),
                ],
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
                if (widget.pinnedLeadsList!.isNotEmpty)
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
                                    "${widget.pinnedLeadsList![index].countryCode ?? ""}${widget.pinnedLeadsList![index].whatsappNumber ?? ""}";

                                ChatMessageController cmProvider =
                                    Provider.of(context, listen: false);
                                DashBoardController dbProvider =
                                    Provider.of(context, listen: false);
                                dbProvider.setSelectedPinnedInfo(null);
                                dbProvider.setSelectedContaactInfo(
                                    widget.pinnedLeadsList![index]);

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
                                      widget.pinnedLeadsList![index].name!
                                              .isNotEmpty
                                          ? widget
                                              .pinnedLeadsList![index].name![0]
                                              .toUpperCase()
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
                                    widget.pinnedLeadsList![index].name ?? "",
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
                                      key : const PageStorageKey<String>('chat_message_list'),
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

  sendMsg(String msg) {
    print("we are calling this:::  $msg");
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

      Future.delayed(const Duration(milliseconds: 100), () async {
        _scrollToBottom();
        FocusScope.of(context).unfocus();
      });

      // Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
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
                                    onPressed: () => Navigator.pop(context),
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
