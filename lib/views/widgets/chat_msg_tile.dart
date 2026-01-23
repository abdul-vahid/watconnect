// ignore_for_file: deprecated_member_use, prefer_typing_uninitialized_variables, avoid_print

import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/views/view/view_fullscreen_img.dart';
import 'package:whatsapp/views/widgets/attachment_widget.dart';
import 'package:whatsapp/views/widgets/custom_chat_button.dart';
import 'package:whatsapp/views/widgets/custom_intractive_button.dart';
import 'package:whatsapp/views/widgets/header_widget.dart';
import 'package:whatsapp/views/widgets/whatsapp_chats_widgets.dart/whatsapp_chat_func.dart';

class ChatMessageTile extends StatefulWidget {
  final message;
  final previousMessage;
  final String userName;
  final String tenetCode;
  final Function(String messageId) onTap;
  final List selectedMessages;
  final VoidCallback? onCopyMessage; 

  const ChatMessageTile({
    Key? key,
    required this.message,
    this.previousMessage,
    required this.userName,
    required this.tenetCode,
    required this.onTap,
    required this.selectedMessages,
    this.onCopyMessage,
  }) : super(key: key);

  @override
  State<ChatMessageTile> createState() => _ChatMessageTileState();
}

class _ChatMessageTileState extends State<ChatMessageTile> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentCarouselIndex = 0;
  bool _showCopyButton = false;

  bool _isSameDay(DateTime? a, DateTime? b) {
    return a?.year == b?.year && a?.month == b?.month && a?.day == b?.day;
  }

  String _getDayLabel(DateTime istTime, DateTime now) {
    if (_isSameDay(istTime, now)) return 'Today';
    if (_isSameDay(istTime, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return DateFormat('d MMMM yyyy').format(istTime);
  }

  // Method to copy message to clipboard
  Future<void> _copyMessageToClipboard() async {
    String textToCopy = "";
    
    // Get the main message text
    if (widget.message.message?.isNotEmpty ?? false) {
      textToCopy = widget.message.message!;
    } else if (widget.message.bodyText?.isNotEmpty ?? false) {
      textToCopy = widget.message.bodyText!;
    } else if (widget.message.messageBody != null) {
      // Handle templated messages
      textToCopy = widget.message.messageBody!;
    } else if (widget.message.adHeadline?.isNotEmpty ?? false) {
      textToCopy = "${widget.message.adHeadline}\n${widget.message.adBody ?? ''}";
    }
    
    if (textToCopy.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: textToCopy));
      
      // Show a snackbar or toast to indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Message copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Get message text content
  String _getMessageText() {
    if (widget.message.message?.isNotEmpty ?? false) {
      return widget.message.message!;
    } else if (widget.message.bodyText?.isNotEmpty ?? false) {
      return widget.message.bodyText!;
    } else if (widget.message.messageBody != null) {
      return widget.message.messageBody!;
    } else if (widget.message.adHeadline?.isNotEmpty ?? false) {
      return "${widget.message.adHeadline}\n${widget.message.adBody ?? ''}";
    } else if (widget.message.templateType == 'carousel') {
      return widget.message.templateCards
          .map<String>((card) => card['body']?['text'] ?? "")
          .where((text) => text.isNotEmpty)
          .join("\n\n");
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    print(" widget.message.bodyText!::::::::::: ${widget.message.bodyText}");
    final now = DateTime.now();
    final istTime =
        widget.message.createddate.add(const Duration(hours: 5, minutes: 30));
    final formattedTime = DateFormat('hh:mm a').format(istTime);
    final showDateLabel = widget.previousMessage == null ||
        !_isSameDay(
          istTime,
          widget.previousMessage!.createddate
              .add(const Duration(hours: 5, minutes: 30)),
        );

    final imageUrl = ((widget.message.bodyTextParams != null &&
                widget.message.bodyTextParams.containsKey('file_title') &&
                (widget.message.bodyTextParams['file_title']?.isNotEmpty ??
                    false)) ||
            widget.message.filetype != null)
        ? "${AppConstants.baseImgUrl}public/${widget.tenetCode}/attachment/"
            "${widget.message.filetype != null ? widget.message.title : widget.message.bodyTextParams['file_title']}"
        : "";

    final isEmptyMessage = widget.message.header == null &&
        widget.message.messageBody == null &&
        imageUrl.isEmpty &&
        widget.message.bodyText == null &&
        widget.message.filetype == null &&
        (widget.message.message?.isEmpty ?? true) &&
        (widget.message.adHeadline?.isEmpty ?? true) &&
        (widget.message.adBody?.isEmpty ?? true) &&
        (widget.message.adMediaUrl?.isEmpty ?? true);

    if (isEmptyMessage) return const SizedBox();

    final regex = RegExp(r'\{\{\d+\}\}');
    String result = "";

    String headline = widget.message.adHeadline ?? "";
    String adbody = widget.message.adBody ?? "";
    String adMediaUrl = widget.message.adMediaUrl ?? "";
    String adMediaType = widget.message.adMediaType ?? "";
    String adUrl = widget.message.adUrl ?? "";
    String adPlatform = widget.message.adPlatform ?? "";

    final bool isAdMessage =
        headline.isNotEmpty || adbody.isNotEmpty || adMediaUrl.isNotEmpty;

    if (widget.message.templateType == 'carousel') {
      var carousalPams =
          jsonEncode(widget.message.bodyTextParams['main'] ?? "");
      result = widget.message.messageBody ?? "";
      if (regex.hasMatch(result)) {
        result = replacePlaceholders(result, carousalPams);
      }
    } else {
      result = widget.message.messageBody ?? "";
      if (regex.hasMatch(result)) {
        result = replacePlaceholders(
            result,
            jsonEncode(widget.message.bodyTextParams ??
                widget.message.exampleBodyText ??
                ""));
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
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
            if (widget.selectedMessages.isNotEmpty) {
              widget.onTap(widget.message.id ?? "");
              setState(() {
                _showCopyButton = false;
              });
            } else {
              setState(() {
                _showCopyButton = false;
              });
            }
          },
          onLongPress: () {
            if (widget.selectedMessages.isEmpty) {
              // Show context menu for single message
              _showContextMenu(context);
            } else {
              // Add to selection when in selection mode
              widget.onTap(widget.message.id ?? "");
            }
          },
          child: Align(
            alignment: widget.message.status == "Incoming"
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.all(10),
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width * 0.25,
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              decoration: BoxDecoration(
                color: widget.message.status == "Outgoing"
                    ? const Color(0xffE3FFC9)
                    : const Color.fromARGB(255, 179, 238, 243),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: widget.message.status == "Outgoing"
                      ? const Radius.circular(12)
                      : Radius.zero,
                  bottomRight: widget.message.status == "Outgoing"
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
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Copy button (small, top-right corner)
                      if (_showCopyButton && widget.selectedMessages.isEmpty)
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(Icons.content_copy, size: 18),
                              padding: EdgeInsets.all(4),
                              onPressed: () {
                                _copyMessageToClipboard();
                                setState(() {
                                  _showCopyButton = false;
                                });
                              },
                            ),
                          ),
                        ),
                      
                      if (isAdMessage) ...[
                        if (adMediaUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: adMediaType == "video"
                                ? InkWell(
                                    onTap: () async {
                                      print("adMediaUrl::::::    $adMediaUrl");

                                      final Uri url = Uri.parse(adMediaUrl);
                                      if (await launchUrl(url,
                                          mode: LaunchMode.externalApplication)) {
                                        throw Exception('Could not launch $url');
                                      }
                                      print("Ad URL tapped: $adUrl");
                                    },
                                    child: Container(
                                      height: 120,
                                      width:
                                          MediaQuery.of(context).size.width * 0.65,
                                      color: Colors.black12,
                                      child: const Icon(Icons.play_circle_filled,
                                          size: 48),
                                    ))
                                : InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                PreviewImage(imgUrl: adMediaUrl)),
                                      );
                                    },
                                    child: CachedNetworkImage(
                                      imageUrl: adMediaUrl,
                                      height: 120,
                                      width:
                                          MediaQuery.of(context).size.width * 0.65,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => const Center(
                                          child: CircularProgressIndicator()),
                                      errorWidget: (_, __, ___) =>
                                          const Icon(Icons.broken_image),
                                    ),
                                  ),
                          ),
                        if (headline.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              headline,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        if (adbody.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              adbody,
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        if (adPlatform.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "via $adPlatform",
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        if (adUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: GestureDetector(
                              onTap: () async {
                                final Uri url = Uri.parse(adUrl);
                                if (await launchUrl(url,
                                    mode: LaunchMode.externalApplication)) {
                                  throw Exception('Could not launch $url');
                                }
                                print("Ad URL tapped: $adUrl");
                              },
                              child: Text(
                                adUrl,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        const Divider(color: Colors.grey),
                      ],
                      if (imageUrl.isNotEmpty && !isAdMessage)
                        AttachmentWidget(url: imageUrl),
                      if (widget.message.header != null && imageUrl.isEmpty)
                        HeaderMediaWidget(
                          header: widget.message.header!,
                          headerBody: widget.message?.headerBody ?? "",
                        ),
                      if (widget.message.message?.isNotEmpty ?? false)
                        Text(
                          widget.message.message!,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      if (widget.message.bodyText?.isNotEmpty ?? false)
                        Text(
                          widget.message.bodyText!,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (widget.message.messageBody != null) Text(result),
                      if (widget.message.description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(widget.message.description!),
                        ),
                      if (widget.message.footer != null)
                        Text(
                          widget.message.footer!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      if (widget.message.erormessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            "Error: ${widget.message.erormessage!}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade400,
                            ),
                          ),
                        ),
                      if (widget.message.interactiveButtons != null &&
                          widget.message.interactiveButtons?.isNotEmpty == true)
                        CustomInteractiveButtonList(
                            buttons: widget.message.interactiveButtons!),
                      if (widget.message.buttons != null &&
                          widget.message.buttons?.isNotEmpty == true)
                        CustomButtonList(buttons: widget.message.buttons!),
                      if (widget.message.templateType == 'carousel') ...[
                        CarouselSlider(
                          items: widget.message.templateCards
                              .asMap()
                              .entries
                              .map<Widget>((entry) {
                            final index = entry.key;
                            final card = entry.value;

                            final regex = RegExp(r'\{\{\d+\}\}');
                            log("card::::  $card");
                            log("card body::::  ${card['body']}");

                            String result = "";

                            if (card['body'] == null ||
                                card['body']['text'] == null) {
                              result = "";
                            } else {
                              result = card['body']['text'] ?? "";
                            }

                            var carousalPams =
                                jsonEncode(widget.message.bodyTextParams['$index']);
                            if (regex.hasMatch(result)) {
                              result = replacePlaceholders(result, carousalPams);
                            }

                            Map<String, dynamic>? bodyParams;
                            if (widget.message.bodyTextParams != null &&
                                widget.message.bodyTextParams
                                    .containsKey('$index')) {
                              bodyParams = widget.message.bodyTextParams['$index'];
                            }

                            String carImageUrl = "";
                            if (bodyParams != null &&
                                bodyParams['file_title'] != null &&
                                bodyParams['file_title'].toString().isNotEmpty) {
                              carImageUrl =
                                  "${AppConstants.baseImgUrl}public/${widget.tenetCode}/attachment/${bodyParams['file_title']}";
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 8),
                              child: SingleChildScrollView(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (card['body']?['text'] != null)
                                        Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Text(
                                            result,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      if (carImageUrl.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6.0, vertical: 10),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: InkWell(
                                              onTap: () {
                                                print(
                                                    "printing the url of attachment:::  $carImageUrl");
                                              },
                                              child: AttachmentWidget(
                                                url: carImageUrl,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (card['buttons'] != null &&
                                          card['buttons'].isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: CustomButtonList(
                                              buttons: card['buttons']),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          carouselController: _carouselController,
                          options: CarouselOptions(
                            autoPlay: false,
                            enableInfiniteScroll: false,
                            viewportFraction: 0.98,
                            enlargeCenterPage: true,
                            height: 300,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentCarouselIndex = index;
                              });
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: widget.message.templateCards
                              .asMap()
                              .entries
                              .map<Widget>((entry) {
                            int index = entry.key;
                            return GestureDetector(
                              onTap: () => _carouselController.animateToPage(index),
                              child: Container(
                                width: 8.0,
                                height: 8.0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentCarouselIndex == index
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            formattedTime,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black45),
                          ),
                          if (widget.message.status == "Outgoing")
                            Icon(
                              Icons.done_all,
                              color: widget.message.deliveryStatus == "read"
                                  ? Colors.green
                                  : Colors.grey,
                              size: 18,
                            ),
                        ],
                      ),
                    ],
                  ),
                  // Selection overlay
                  if (widget.selectedMessages.contains(widget.message.id))
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: widget.message.status == "Outgoing"
                              ? const Radius.circular(12)
                              : Radius.zero,
                          bottomRight: widget.message.status == "Outgoing"
                              ? Radius.zero
                              : const Radius.circular(12),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.blue,
                            size: 20,
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

  // Show context menu on long press
  void _showContextMenu(BuildContext context) {
    final messageText = _getMessageText();
    if (messageText.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.content_copy, color: Colors.blue),
                  title: Text('Copy message'),
                  onTap: () {
                    Navigator.pop(context);
                    _copyMessageToClipboard();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.select_all, color: Colors.blue),
                  title: Text('Select message'),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onTap(widget.message.id ?? "");
                  },
                ),
                ListTile(
                  leading: Icon(Icons.cancel, color: Colors.grey),
                  title: Text('Cancel'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}




