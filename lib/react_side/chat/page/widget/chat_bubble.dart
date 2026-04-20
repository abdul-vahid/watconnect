import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp/react_side/chat/model/chat_history_model.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/views/view/view_fullscreen_img.dart';
import 'package:whatsapp/views/widgets/attachment_widget.dart';
import 'package:whatsapp/views/widgets/custom_chat_button.dart';
import 'package:whatsapp/views/widgets/custom_intractive_button.dart';

class ChatBubble extends StatefulWidget {
  final ChatRecord chat;
  final bool isMe;
  final bool isSelected;
  final Function(String id)? onSelect;

  const ChatBubble({
    super.key,
    required this.chat,
    required this.isMe,
    this.isSelected = false,
    this.onSelect,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool showCopy = false;



  /// ✅ TEXT RESOLVER
  String get messageText {
    final c = widget.chat;

    if (c.message?.isNotEmpty == true) return c.message!;
    if (c.bodyText?.isNotEmpty == true) return c.bodyText!;
    if (c.messageBody?.isNotEmpty == true) return c.messageBody!;
    if (c.chatMsg?.isNotEmpty == true) return c.chatMsg!;
    if (c.adHeadline?.isNotEmpty == true) {
      return "${c.adHeadline}\n${c.adBody ?? ""}";
    }

    return "";
  }

  /// ✅ TIME FORMAT
  String get formattedTime {
    if (widget.chat.createdDate == null) return "";

    try {
      final dt = DateTime.parse(widget.chat.createdDate!);
      return DateFormat('hh:mm a').format(dt);
    } catch (e) {
      return "";
    }
  }

  /// ✅ OPEN URL
  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $url");
    }
  }

 String TenetCode="";
@override
  void initState() {
  getCode();
    super.initState();
  }

  getCode() async {
 final prefs = await SharedPreferences.getInstance();
  

    TenetCode = prefs.getString(SharedPrefsConstants.usertenantcodeKey) ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.chat;
   
        final imageUrl = ((c.bodyTextParams != null &&
                c.bodyTextParams!.containsKey('file_title') &&
                (c.bodyTextParams!['file_title']?.isNotEmpty ??
                    false)) ||
           c.fileType != null)
        ? "${AppConstants.baseImgUrl}public/${TenetCode}/attachment/"
            "${c.fileType != null ? c.title : c.bodyTextParams!['file_title']}"
        : "";

    final isAd = (c.adHeadline?.isNotEmpty == true ||
        c.adBody?.isNotEmpty == true ||
        c.adMediaUrl?.isNotEmpty == true);

    final hasAttachment = c.fileId?.isNotEmpty == true;

    if (messageText.isEmpty && !isAd && !hasAttachment) {
      return const SizedBox();

      
    }


    String headline = c.adHeadline ?? "";
    String adbody = c.adBody ?? "";
    String adMediaUrl = c.adMediaUrl ?? "";
    String adMediaType = c.adMediaType ?? "";
    String adUrl = c.adUrl ?? "";
    String adPlatform = c.adPlatform ?? "";
       final bool isAdMessage =
        headline.isNotEmpty || adbody.isNotEmpty || adMediaUrl.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (widget.isSelected) {
          widget.onSelect?.call(c.id ?? "");
        }
      },
      onLongPress: () {
        setState(() => showCopy = true);

        if (messageText.isNotEmpty) {
          Clipboard.setData(ClipboardData(text: messageText));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Message copied")),
          );
        }
      },
      child: Align(
        alignment:
            widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: widget.isMe
                ? const Color(0xffE3FFC9)
                : const Color(0xffF1F1F1),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft:
                  widget.isMe ? const Radius.circular(12) : Radius.zero,
              bottomRight:
                  widget.isMe ? Radius.zero : const Radius.circular(12),
            ),
          ),
          child: Stack(
            children: [
              Column(
                
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ✅ HEADER (BOLD TITLE)
                  if (c.headerBody?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        c.headerBody!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
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
                                          mode:
                                              LaunchMode.externalApplication)) {
                                        throw Exception(
                                            'Could not launch $url');
                                      }
                                      print("Ad URL tapped: $adUrl");
                                    },
                                    child: Container(
                                      height: 120,
                                      width: MediaQuery.of(context).size.width *
                                          0.65,
                                      color: Colors.black12,
                                      child: const Icon(
                                          Icons.play_circle_filled,
                                          size: 48),
                                    ))
                                : InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => PreviewImage(
                                                imgUrl: adMediaUrl)),
                                      );
                                    },
                                    child: CachedNetworkImage(
                                      imageUrl: adMediaUrl,
                                      height: 120,
                                      width: MediaQuery.of(context).size.width *
                                          0.65,
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

                  /// ✅ AD MEDIA
                  if (isAd && c.adMediaUrl?.isNotEmpty == true)
                    GestureDetector(
                      onTap: () => openUrl(c.adMediaUrl!),
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.black12,
                        child: const Icon(Icons.play_circle_fill),
                      ),
                    ),

                  /// ✅ AD TEXT
                  if (isAd) ...[
                    if (c.adHeadline?.isNotEmpty == true)
                      Text(
                        c.adHeadline!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                    if (c.adBody?.isNotEmpty == true)
                      Text(c.adBody!),
                    if (c.adUrl?.isNotEmpty == true)
                      GestureDetector(
                        onTap: () => openUrl(c.adUrl!),
                        child: Text(
                          c.adUrl!,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    const Divider(),
                  ],

                  /// ✅ MESSAGE TEXT
                  if (messageText.isNotEmpty)
                    Text(
                      messageText,
                      style: const TextStyle(fontSize: 14),
                    ),


       if (c.errMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            "Error: ${c.errMessage??"s"}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade400,
                            ),
                          ),
                        ),
                      if (c.interactiveButtons != null &&
                          c.interactiveButtons?.isNotEmpty == true)
                        CustomInteractiveButtonList(
                            buttons: c.interactiveButtons!),
                      if (c.buttons != null &&
                          c.buttons?.isNotEmpty == true)
                        CustomButtonList(
                          buttons: c.buttons!,
                          // buttonVariables:
                          //     c.bodyTextParams != null &&
                          //             c.bodyTextParams is Map &&
                          //             c
                          //                 .!containsKey('button_variables')
                          //         ? Map<String, dynamic>.from(widget.message
                          //             .bodyTextParams['button_variables'])
                          //         : null,
                        ),

             
               if (imageUrl.isNotEmpty && !isAdMessage)
                                           AttachmentWidget(url: imageUrl),


                  /// ✅ FOOTER (SMALL TEXT)
                  if (c.footer?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        c.footer!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),

               const SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        formattedTime,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                      if (widget.isMe)
                        Icon(
                          Icons.done_all,
                          size: 16,
                          color: c.deliveryStatus == "read"
                              ? Colors.blue
                              : Colors.grey,
                        ),
                    ],
                  ),
                ],
              ),

              /// ✅ SELECTION OVERLAY
              if (widget.isSelected)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.check_circle,
                          color: Colors.blue),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}