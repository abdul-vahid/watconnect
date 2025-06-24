import 'package:flutter/material.dart';

class ChatMessageTile extends StatelessWidget {
  final String? id;
  final String status;
  final String senderName;
  final String currentUserName;
  final String formattedTime;
  final String finalFormattedDate;
  final bool showDateLabel;
  final bool isSelected;
  final bool isSelectedMode;
  final String? message;
  final String? messageBody;
  final String? description;
  final String? footer;
  final String? errorMessage;
  final String? imageUrl;
  final Widget? headerWidget;
  final Widget? attachmentWidget;
  final List<Widget>? buttons;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final String deliveryStatus;

  const ChatMessageTile({
    super.key,
    required this.id,
    required this.status,
    required this.senderName,
    required this.currentUserName,
    required this.formattedTime,
    required this.finalFormattedDate,
    required this.showDateLabel,
    required this.isSelected,
    required this.isSelectedMode,
    this.message,
    this.messageBody,
    this.description,
    this.footer,
    this.errorMessage,
    this.imageUrl,
    this.headerWidget,
    this.attachmentWidget,
    this.buttons,
    required this.onTap,
    required this.onLongPress,
    required this.deliveryStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDateLabel)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 169, 215, 236),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    finalFormattedDate,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: GestureDetector(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Container(
              color: isSelected ? const Color(0xffAFAFAF) : Colors.transparent,
              child: Row(
                mainAxisAlignment: status == "Incoming"
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(8),
                      child: Align(
                        alignment: status == "Outgoing"
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: status == "Outgoing"
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              status == "Incoming"
                                  ? senderName
                                  : currentUserName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            IntrinsicWidth(
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.65,
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: status == "Outgoing"
                                      ? const Color(0xffE3FFC9)
                                      : const Color.fromARGB(
                                          255, 179, 238, 243),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(12),
                                    topRight: const Radius.circular(12),
                                    bottomLeft: status == "Outgoing"
                                        ? const Radius.circular(12)
                                        : Radius.zero,
                                    bottomRight: status == "Outgoing"
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
                                    if (imageUrl?.isNotEmpty ?? false)
                                      attachmentWidget ?? const SizedBox(),
                                    if (headerWidget != null &&
                                        (imageUrl?.isEmpty ?? true))
                                      headerWidget!,
                                    if (message?.isNotEmpty ?? false)
                                      Text(
                                        message!,
                                        style: const TextStyle(
                                            fontSize: 14, height: 1.5),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    if (messageBody != null)
                                      Text('$messageBody'),
                                    if (description != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(description!),
                                      ),
                                    if (footer != null)
                                      Text(
                                        footer!,
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    if (errorMessage != null)
                                      Text(
                                        errorMessage!,
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.red),
                                      ),
                                    if (buttons?.isNotEmpty ?? false)
                                      Column(children: buttons!),
                                    if (status == "Outgoing")
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Icon(
                                          Icons.done_all,
                                          color: deliveryStatus == "read"
                                              ? Colors.green
                                              : Colors.grey,
                                          size: 18,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Text(
                              formattedTime,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
