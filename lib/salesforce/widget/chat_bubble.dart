import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/model/chat_history_model.dart';
import 'package:whatsapp/salesforce/widget/attachment_preview_widget.dart';
import 'package:whatsapp/salesforce/widget/chat_buttons.dart';
import 'package:whatsapp/salesforce/widget/chat_sender_lable.dart';

class ChatBubble extends StatelessWidget {
  final SfChatHistoryModel item;
  final List<ButtonItem> buttons;
  final DateTime currentTime;
  String tempBody;

  ChatBubble({
    super.key,
    required this.item,
    required this.tempBody,
    required this.buttons,
    required this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onLongPress: () {
        ChatMessageController ref = Provider.of(context, listen: false);
        ref.setMsgDeleteList(item.id ?? "");
      },
      onTap: () {
        ChatMessageController ref = Provider.of(context, listen: false);
        if (ref.msgDeleteList.isNotEmpty) {
          ref.setMsgDeleteList(item.id ?? "");
        }
      },
      child: Row(
        mainAxisAlignment: item.messageType == "Incoming"
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Column(
              crossAxisAlignment: item.messageType == "Incoming"
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                ChatSenderLabel(item: item),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width * 0.10,
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: item.messageType == "Outgoing"
                        ? const Color(0xffE3FFC9)
                        : const Color(0xffD9F3FF),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: item.messageType == "Outgoing"
                          ? const Radius.circular(12)
                          : Radius.zero,
                      bottomRight: item.messageType == "Outgoing"
                          ? Radius.zero
                          : const Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 3,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: item.messageType == "Outgoing"
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.start,
                    children: [
                      AttachmentPreviewWidget(
                        contentType: item.contentType,
                        attachmentUrl: item.attachmentUrl,
                      ),
                      if (tempBody.isNotEmpty)
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context)
                                .style
                                .copyWith(fontSize: 16, height: 1.4),
                            children: [
                              TextSpan(
                                text: tempBody,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (item.message?.isNotEmpty ?? false)
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context)
                                .style
                                .copyWith(fontSize: 16, height: 1.4),
                            children: [
                              TextSpan(
                                text: item.message!,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (buttons.isNotEmpty) ChatButtons(buttons: buttons),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatTime(currentTime),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String formatTime(DateTime dt) {
  return DateFormat.Hm().format(dt);
}
