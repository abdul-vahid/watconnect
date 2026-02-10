// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
// import 'package:whatsapp/salesforce/model/chat_history_model.dart';
// import 'package:whatsapp/salesforce/widget/attachment_preview_widget.dart';
// import 'package:whatsapp/salesforce/widget/chat_buttons.dart';
// import 'package:whatsapp/salesforce/widget/chat_sender_lable.dart';

// // ignore: must_be_immutable
// class ChatBubble extends StatelessWidget {
//   final SfChatHistoryModel item;
//   final List<ButtonItem> buttons;
//   final DateTime currentTime;
//   String tempBody;

//   ChatBubble({
//     super.key,
//     required this.item,
//     required this.tempBody,
//     required this.buttons,
//     required this.currentTime,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ChatMessageController>(builder: (context, ref, child) {
//       return InkWell(
//         splashColor: Colors.transparent,
//         highlightColor: Colors.transparent,
//         hoverColor: Colors.transparent,
//         focusColor: Colors.transparent,
//         onLongPress: () {
//           // ChatMessageController ref = Provider.of(context, listen: false);
//           ref.setMsgDeleteList(item.id ?? "");
//         },
//         onTap: () {
//           // ChatMessageController ref = Provider.of(context, listen: false);
//           if (ref.msgDeleteList.isNotEmpty) {
//             ref.setMsgDeleteList(item.id ?? "");
//           }
//         },
//         child: Container(
//           color: ref.msgDeleteList.contains(item.id)
//               ? Colors.grey.shade300
//               : Colors.transparent,
//           child: Row(
//             mainAxisAlignment: item.messageType == "Incoming"
//                 ? MainAxisAlignment.start
//                 : MainAxisAlignment.end,
//             children: [
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
//                 child: Column(
//                   crossAxisAlignment: item.messageType == "Incoming"
//                       ? CrossAxisAlignment.start
//                       : CrossAxisAlignment.end,
//                   children: [
//                     ChatSenderLabel(item: item),
//                     const SizedBox(height: 4),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 14, vertical: 10),
//                       constraints: BoxConstraints(
//                         minWidth: MediaQuery.of(context).size.width * 0.10,
//                         maxWidth: MediaQuery.of(context).size.width * 0.75,
//                       ),
//                       decoration: BoxDecoration(
//                         color: item.messageType == "Outgoing"
//                             ? const Color(0xffE3FFC9)
//                             : const Color(0xffD9F3FF),
//                         borderRadius: BorderRadius.only(
//                           topLeft: const Radius.circular(12),
//                           topRight: const Radius.circular(12),
//                           bottomLeft: item.messageType == "Outgoing"
//                               ? const Radius.circular(12)
//                               : Radius.zero,
//                           bottomRight: item.messageType == "Outgoing"
//                               ? Radius.zero
//                               : const Radius.circular(12),
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 3,
//                             offset: const Offset(1, 2),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: item.messageType == "Outgoing"
//                             ? CrossAxisAlignment.start
//                             : CrossAxisAlignment.start,
//                         children: [
//                           AttachmentPreviewWidget(
//                             contentType: item.contentType,
//                             attachmentUrl: item.attachmentUrl,
//                           ),
//                           if (tempBody.isNotEmpty)
//                             RichText(
//                               text: TextSpan(
//                                 style: DefaultTextStyle.of(context)
//                                     .style
//                                     .copyWith(fontSize: 16, height: 1.4),
//                                 children: [
//                                   TextSpan(
//                                     text: tempBody,
//                                     style: const TextStyle(
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           if (item.message?.isNotEmpty ?? false)
//                             RichText(
//                               text: TextSpan(
//                                 style: DefaultTextStyle.of(context)
//                                     .style
//                                     .copyWith(fontSize: 16, height: 1.4),
//                                 children: [
//                                   TextSpan(
//                                     text: item.message!,
//                                     style: const TextStyle(
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           if (buttons.isNotEmpty) ChatButtons(buttons: buttons),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     // Time and Delivery Status Row
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         // Time
//                         // Text(
//                         //   formatTime(currentTime),
//                         //   style:
//                         //       const TextStyle(fontSize: 12, color: Colors.grey),
//                         // ),

//                         const SizedBox(width: 4),

//                         // Show delivery status only for outgoing messages
//                         if (item.messageType == "Outgoing")
//                           _buildDeliveryStatus(),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       formatTime(currentTime),
//                       style: const TextStyle(fontSize: 12, color: Colors.grey),
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }

// Widget _buildDeliveryStatus() {
//   // Get the delivery status from the item
//   final deliveryStatus = item.Delivery_Status?.toLowerCase();

//   // If status is null or empty, show single grey tick (pending)
//   if (deliveryStatus == null || deliveryStatus.isEmpty) {
//     return const Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(
//           Icons.check,
//           size: 12,
//           color: Colors.grey,
//         ),
//       ],
//     );
//   }

//   // Check for specific status values
//   switch (deliveryStatus) {
//     case 'read':
//       // Double blue ticks for read
//       return const Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.check,
//             size: 12,
//             color: Colors.blue,
//           ),
//           SizedBox(width: -3), // Negative spacing for overlapping effect
//           Icon(
//             Icons.check,
//             size: 12,
//             color: Colors.blue,
//           ),
//         ],
//       );

//     case 'delivered':
//       // Double grey ticks for delivered
//       return const Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.check,
//             size: 12,
//             color: Colors.grey,
//           ),
//           SizedBox(width: -3),
//           Icon(
//             Icons.check,
//             size: 12,
//             color: Colors.grey,
//           ),
//         ],
//       );

//     case 'sent':
//       // Single grey tick for sent
//       return const Icon(
//         Icons.check,
//         size: 12,
//         color: Colors.grey,
//       );

//     case 'failed':
//       // Red X for failed messages
//       return const Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.error_outline,
//             size: 12,
//             color: Colors.red,
//           ),
//           SizedBox(width: 2),
//           Text(
//             'Failed',
//             style: TextStyle(
//               fontSize: 10,
//               color: Colors.red,
//             ),
//           ),
//         ],
//       );

//     default:
//       // Default to single grey tick for any other status
//       return const Icon(
//         Icons.check,
//         size: 12,
//         color: Colors.grey,
//       );
//   }
// }

// String formatTime(DateTime dt) {
//   return DateFormat.Hm().format(dt);
// }

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/model/chat_history_model.dart';
import 'package:whatsapp/salesforce/widget/attachment_preview_widget.dart';
import 'package:whatsapp/salesforce/widget/chat_buttons.dart';
import 'package:whatsapp/salesforce/widget/chat_sender_lable.dart';
import 'package:html_unescape/html_unescape.dart';

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
      return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        onLongPress: () {
          ref.setMsgDeleteList(item.id ?? "");
        },
        onTap: () {
          if (ref.msgDeleteList.isNotEmpty) {
            ref.setMsgDeleteList(item.id ?? "");
          }
        },
        child: Container(
          color: ref.msgDeleteList.contains(item.id)
              ? Colors.grey.shade300
              : Colors.transparent,
          child: Row(
            mainAxisAlignment: item.messageType == "Incoming"
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            // children: [
            //   Padding(
            //     padding:
            //         const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            //     child: Column(
            //       crossAxisAlignment: item.messageType == "Incoming"
            //           ? CrossAxisAlignment.start
            //           : CrossAxisAlignment.end,
            //       children: [
            //         ChatSenderLabel(item: item),
            //         const SizedBox(height: 4),
            //         Container(
            //           padding: const EdgeInsets.symmetric(
            //               horizontal: 14, vertical: 10),
            //           constraints: BoxConstraints(
            //             minWidth: MediaQuery.of(context).size.width * 0.10,
            //             maxWidth: MediaQuery.of(context).size.width * 0.75,
            //           ),
            //           decoration: BoxDecoration(
            //             color: item.messageType == "Outgoing"
            //                 ? const Color(0xffE3FFC9)
            //                 : const Color(0xffD9F3FF),
            //             borderRadius: BorderRadius.only(
            //               topLeft: const Radius.circular(12),
            //               topRight: const Radius.circular(12),
            //               bottomLeft: item.messageType == "Outgoing"
            //                   ? const Radius.circular(12)
            //                   : Radius.zero,
            //               bottomRight: item.messageType == "Outgoing"
            //                   ? Radius.zero
            //                   : const Radius.circular(12),
            //             ),
            //             boxShadow: [
            //               BoxShadow(
            //                 color: Colors.black.withOpacity(0.1),
            //                 blurRadius: 3,
            //                 offset: const Offset(1, 2),
            //               ),
            //             ],
            //           ),
            //           child: Column(
            //             crossAxisAlignment: item.messageType == "Outgoing"
            //                 ? CrossAxisAlignment.start
            //                 : CrossAxisAlignment.start,
            //             children: [
            //               if (item.contentType?.isNotEmpty == true ||
            //                   item.attachmentUrl?.isNotEmpty == true)
            //                 AttachmentPreviewWidget(
            //                   contentType: item.contentType,
            //                   attachmentUrl: item.attachmentUrl,
            //                 ),
            //               if (tempBody.isNotEmpty &&
            //                   (item.message?.isEmpty ?? true))
            //                 RichText(
            //                   text: TextSpan(
            //                     style: DefaultTextStyle.of(context)
            //                         .style
            //                         .copyWith(fontSize: 16, height: 1.4),
            //                     children: [
            //                       TextSpan(
            //                         text: tempBody,
            //                         style: const TextStyle(
            //                           color: Colors.black,
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                 ),
            //               if (item.message?.isNotEmpty ?? false)
            //                 RichText(
            //                   text: TextSpan(
            //                     style: DefaultTextStyle.of(context)
            //                         .style
            //                         .copyWith(fontSize: 16, height: 1.4),
            //                     children: [
            //                       TextSpan(
            //                         text: item.message!,
            //                         style: const TextStyle(
            //                           color: Colors.black,
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                 ),
            //               if (buttons.isNotEmpty) ChatButtons(buttons: buttons),
            //             ],
            //           ),
            //         ),
            //         const SizedBox(height: 4),

            //         Row(
            //           mainAxisSize: MainAxisSize.min,
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             // Show delivery status only for outgoing messages
            //             if (item.messageType == "Outgoing")
            //               _buildDeliveryStatus(item),

            //             const SizedBox(width: 4),

            //             // Time
            //             Text(
            //               formatTime(currentTime),
            //               style:
            //                   const TextStyle(fontSize: 12, color: Colors.grey),
            //             ),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ],
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
                        crossAxisAlignment: item.messageType == "Outgoing"
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.start,
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
                              const SizedBox(width: 6),
                              if (item.messageType == "Outgoing")
                                _buildDeliveryStatusWithTime(item, currentTime),
                            ],
                          ),
                        ],
                      ),
                    ), /*
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (item.messageType == "Outgoing")
              _buildDeliveryStatus(item),

            const SizedBox(width: 4),

            Text(
              formatTime(currentTime),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        */
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDeliveryStatusWithTime(
      SfChatHistoryModel item, DateTime currentTime) {
    // Get the delivery status from the item
    final deliveryStatus = item.Delivery_Status?.toLowerCase();

    // Default single tick
    Widget statusWidget = const Icon(
      Icons.check,
      size: 14, // ✅ थोड़ा बड़ा size (12 से 14)
      color: Colors.grey,
    );

    // Check for specific status values
    if (deliveryStatus != null && deliveryStatus.isNotEmpty) {
      switch (deliveryStatus) {
        case 'read':
          statusWidget = SizedBox(
            width: 20, // Fixed width for overlapping icons
            child: Stack(
              children: [
                const Icon(
                  Icons.check,
                  size: 14, // ✅ बड़ा size
                  color: Colors.blue,
                ),
                Positioned(
                  left: 8, // Overlap position
                  child: const Icon(
                    Icons.check,
                    size: 14, // ✅ बड़ा size
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
                  size: 14, // ✅ बड़ा size
                  color: Colors.grey,
                ),
                Positioned(
                  left: 8,
                  child: const Icon(
                    Icons.check,
                    size: 14, // ✅ बड़ा size
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
            size: 14, // ✅ बड़ा size
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
