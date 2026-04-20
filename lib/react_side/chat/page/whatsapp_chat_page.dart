import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/react_side/chat/controller/chat_controller.dart';
import 'package:whatsapp/react_side/chat/model/chat_history_model.dart';
import 'package:whatsapp/react_side/chat/page/widget/chat_bubble.dart' show ChatBubble;
import 'package:whatsapp/react_side/chat/page/widget/contact_header.dart';
import 'package:whatsapp/react_side/lead/widget/pinned_lead_item.dart';
import 'package:whatsapp/utils/app_color.dart';

class WhatsappChatPage extends StatefulWidget {
  String name;
   String leadId;
    String number;
   WhatsappChatPage({super.key,required this.name,required this.leadId,required this.number});

  @override
  State<WhatsappChatPage> createState() => _WhatsappChatPageState();
}

class _WhatsappChatPageState extends State<WhatsappChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final ctrl = Provider.of<ChatController>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.fetchInitialChat();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        ctrl.fetchChatHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<ChatController>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.pageBgGrey,
        appBar: AppBar(
          leading: const BackButton(color: Colors.white),
          title: const Text("Chat", style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
     body: Column(
  children: [
    const PinnedLeadsWidget(),

   
    ChatContactHeader(name: widget.name,number: widget.number,),

    Expanded(
      child: ListView.builder(
        controller: _scrollController,
        // reverse: true,
        padding: const EdgeInsets.all(10),
        itemCount: ctrl.chatHistoryList.length + 1,
        
        itemBuilder: (context, index) {
          if (index == ctrl.chatHistoryList.length) {
            return ctrl.isLoading
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox();
          }

          final ChatRecord chat = ctrl.chatHistoryList[index];

          final isMe = chat.status == "Outgoing";

          return ChatBubble(chat: chat, isMe: isMe);
        },
      ),
    ),

    _chatInputBar(),
  ],
),
      ),
    );
  }



  /// INPUT BAR UI
  Widget _chatInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Colors.white,
      child: Row(
        children: [
          /// ATTACH BUTTON
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {},
          ),

          /// TEXT FIELD
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message",
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),

          /// CODE BUTTON
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () {},
          ),

          /// AUDIO BUTTON
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {},
          ),

          /// SEND BUTTON
          IconButton(
            icon: const Icon(Icons.send, color: Colors.green),
            onPressed: () {
              final text = _messageController.text.trim();
              if (text.isEmpty) return;

              // TODO: call send message API
              _messageController.clear();
            },
          ),
        ],
      ),
    );
  }
  

}