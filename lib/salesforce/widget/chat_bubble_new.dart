// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/model/chat_history_model.dart';
import 'package:whatsapp/salesforce/widget/attachment_preview_widget.dart';
import 'package:whatsapp/salesforce/widget/chat_buttons.dart';
import 'package:whatsapp/salesforce/widget/chat_sender_lable.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:whatsapp/salesforce/screens/forward_message_screen.dart';

import 'package:flutter_emoji/flutter_emoji.dart';

// ignore: must_be_immutable
class ChatBubble extends StatelessWidget {
  final EmojiParser parser = EmojiParser();
  final HtmlUnescape unescape = HtmlUnescape();

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
    return Consumer<ChatMessageController>(builder: (context, ref, child) {
      final isSelected = ref.isMessageSelected(item.id ?? "");
      final isMultiSelectMode = ref.isMultiSelectMode;
      
      return Container(
        color: isSelected ? Colors.grey.shade300 : Colors.transparent,
        child: Row(
          mainAxisAlignment: item.messageType == "Incoming"
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            // Checkbox for multi-select mode
            if (isMultiSelectMode)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ),
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                onLongPress: () {
                  if (!isMultiSelectMode) {
                    ref.toggleMultiSelectMode();
                    ref.selectMessage(item.id ?? "");
                  } else {
                    ref.toggleMessageSelection(item.id ?? "");
                  }
                },
                onTap: () {
                  if (isMultiSelectMode) {
                    ref.toggleMessageSelection(item.id ?? "");
                  } else if (ref.msgDeleteList.isNotEmpty) {
                    ref.setMsgDeleteList(item.id ?? "");
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: item.messageType == "Incoming"
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      ChatSenderLabel(item: item),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
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
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            if (item.contentType?.isNotEmpty == true ||
                                item.attachmentUrl?.isNotEmpty == true)
                              AttachmentPreviewWidget(
                                contentType: item.contentType,
                                attachmentUrl: item.attachmentUrl,
                              ),
                            if (tempBody.isNotEmpty &&
                                (item.message?.isEmpty ?? true))
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
                                      text: parser.emojify(
                                        unescape.convert(item.message ?? ""),
                                      ),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (buttons.isNotEmpty)
                              Column(
                                children: [
                                  const SizedBox(height: 8),
                                  ChatButtons(buttons: buttons),
                                ],
                              ),
                            const SizedBox(height: 4),

                            // Row for Time & Delivery Status ONLY
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  formatTime(currentTime),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: item.messageType == "Outgoing"
                                        ? Colors.grey[700]
                                        : Colors.grey[600],
                                  ),
                                ),
                                if (item.messageType == "Outgoing")
                                  _buildDeliveryStatusWithTime(item, currentTime),
                                const SizedBox(width: 6),
                              ],
                            ),

                            // Error Message BELOW the Row
                            if (item.Error_Msg != null)
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                    maxWidth: 200),
                                child: Text(
                                  item.Error_Msg ?? "",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.red,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDeliveryStatusWithTime(
      SfChatHistoryModel item, DateTime currentTime) {
    final deliveryStatus = item.Delivery_Status?.toLowerCase();

    Widget statusWidget = const Icon(
      Icons.check,
      size: 14,
      color: Colors.grey,
    );

    if (deliveryStatus != null && deliveryStatus.isNotEmpty) {
      switch (deliveryStatus) {
        case 'read':
          statusWidget = SizedBox(
            width: 20,
            child: Stack(
              children: [
                const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.blue,
                ),
                Positioned(
                  left: 8,
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          );
          break;

        case 'delivered':
          statusWidget = SizedBox(
            width: 20,
            child: Stack(
              children: [
                const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.grey,
                ),
                Positioned(
                  left: 8,
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
          break;

        case 'sent':
          statusWidget = const Icon(
            Icons.check,
            size: 14,
            color: Colors.grey,
          );
          break;

        case 'failed':
          statusWidget = const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 19,
                color: Colors.red,
              ),
            ],
          );
          break;
      }
    }

    return statusWidget;
  }

  String formatTime(DateTime dt) {
    return DateFormat.jm().format(dt);
  }
}