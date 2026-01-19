import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/model/chat_history_model.dart';

class ChatSenderLabel extends StatelessWidget {
  final SfChatHistoryModel item;

  const ChatSenderLabel({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashBoardController>(
      builder: (context, dbRef, child) {
        final name = item.messageType == "Incoming"
            ? dbRef.selectedContactInfo?.name ?? ""
            : "You";

        return Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      },
    );
  }
}
