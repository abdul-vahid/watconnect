import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/views/widgets/attachment_widget.dart';
import 'package:whatsapp/views/widgets/custom_chat_button.dart';
import 'package:whatsapp/views/widgets/header_widget.dart';
import 'package:whatsapp/views/widgets/whatsapp_chats_widgets.dart/whatsapp_chat_func.dart';

class ChatMessageTile extends StatelessWidget {
  final message;
  final previousMessage;
  final String userName;
  final String tenetCode;
  final Function(String messageId) onTap;
  final List selectedMessages;

  const ChatMessageTile({
    Key? key,
    required this.message,
    this.previousMessage,
    required this.userName,
    required this.tenetCode,
    required this.onTap,
    required this.selectedMessages,
  }) : super(key: key);

  bool _isSameDay(DateTime? a, DateTime? b) {
    return a?.year == b?.year && a?.month == b?.month && a?.day == b?.day;
  }

  String _getDayLabel(DateTime istTime, DateTime now) {
    if (_isSameDay(istTime, now)) {
      return 'Today';
    } else if (_isSameDay(istTime, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      return DateFormat('d MMMM yyyy').format(istTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final istTime =
        message.createddate.add(const Duration(hours: 5, minutes: 30));
    final formattedTime = DateFormat('hh:mm a').format(istTime);
    final showDateLabel = previousMessage == null ||
        !_isSameDay(
          istTime,
          previousMessage!.createddate
              .add(const Duration(hours: 5, minutes: 30)),
        );

    final imageUrl = (message.title?.isNotEmpty ?? false)
        ? "${AppConstants.baseImgUrl}public/$tenetCode/attachment/${message.title}"
        : "";

    final isEmptyMessage = message.header == null &&
        message.messageBody == null &&
        imageUrl.isEmpty &&
        (message.message?.isEmpty ?? true);

    if (isEmptyMessage) return const SizedBox();

    final regex = RegExp(r'\{\{\d+\}\}');
    String result = message.messageBody ?? "";
    if (regex.hasMatch(result)) {
      result = replacePlaceholders(
        result,
        message.bodyTextParams?.toString() ?? message.exampleBodyText ?? "",
      );
    }

    return Column(
      children: [
        if (showDateLabel)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 169, 215, 236),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getDayLabel(istTime, now),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        GestureDetector(
          onTap: () {
            if (selectedMessages.isNotEmpty) onTap(message.id ?? "");
          },
          onLongPress: () => onTap(message.id ?? ""),
          child: Container(
            color: selectedMessages.contains(message.id)
                ? const Color(0xffAFAFAF)
                : Colors.transparent,
            child: Row(
              mainAxisAlignment: message.status == "Incoming"
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: message.status == "Outgoing"
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (previousMessage == null ||
                          message.status != previousMessage?.status ||
                          message.name != previousMessage?.name)
                        Text(
                          message.status == "Incoming"
                              ? message.name
                              : userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      IntrinsicWidth(
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width * 0.25,
                            maxWidth: MediaQuery.of(context).size.width * 0.65,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: message.status == "Outgoing"
                                ? const Color(0xffE3FFC9)
                                : const Color.fromARGB(255, 179, 238, 243),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: message.status == "Outgoing"
                                  ? const Radius.circular(12)
                                  : Radius.zero,
                              bottomRight: message.status == "Outgoing"
                                  ? Radius.zero
                                  : const Radius.circular(12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (imageUrl.isNotEmpty)
                                AttachmentWidget(url: imageUrl),
                              if (message.header != null && imageUrl.isEmpty)
                                HeaderMediaWidget(
                                  header: message.header!,
                                  headerBody: message.headerBody,
                                ),
                              if (message.message?.isNotEmpty ?? false)
                                Text(
                                  message.message!,
                                  style: const TextStyle(
                                      fontSize: 14, height: 1.5),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (message.messageBody != null) Text(result),
                              if (message.description != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(message.description!),
                                ),
                              if (message.footer != null)
                                Text(
                                  message.footer!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              if (message.erormessage != null)
                                Text(
                                  message.erormessage!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                              if (message.buttons?.isNotEmpty ?? false)
                                CustomButtonList(buttons: message.buttons!),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    formattedTime,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  if (message.status == "Outgoing")
                                    Icon(
                                      Icons.done_all,
                                      color: message.deliveryStatus == "read"
                                          ? Colors.green
                                          : Colors.grey,
                                      size: 18,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
