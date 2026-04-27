// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp/react_side/chat/controller/chat_controller.dart';
import 'package:whatsapp/react_side/lead/controller/lead_list_controller.dart';
import 'package:whatsapp/views/widgets/delete_dialog.dart';

class ChatContactHeader extends StatelessWidget {
  final String name;
  final String number;
  final VoidCallback? onViewProfile;
  final VoidCallback? onClearChat;

  const ChatContactHeader({
    super.key,
    required this.name,
    required this.number,
    this.onViewProfile,
    this.onClearChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              /// 👤 PROFILE
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      number,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Consumer2<LeadListController, ChatController>(
                  builder: (context, leadCtrl, chatCtrl, child) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onSelected: (value) async {
                    print("value>>>>>$value");
                    final phoneNumber = number;

                    if (value == 'Clear Chat') {
                      _showDeleteDialog(context);
                    } else if (value == 'Archive Chat' ||
                        value == 'Unarchive Chat') {
                      await leadCtrl.archieveUnarchieveLead(
                        leadCtrl.leadDetail?.id ?? "",
                        !(leadCtrl.leadDetail?.isArchived ?? false),
                      );
                    } else if (value == 'Open in WhatsApp') {
                      if (phoneNumber.isNotEmpty) {
                        _launchWhatsApp(phoneNumber);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Phone number is empty')),
                        );
                      }
                    } else if (value == 'Call') {
                      if (phoneNumber.isNotEmpty) {
                        _makePhoneCall(phoneNumber);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Phone number is empty')),
                        );
                      }
                    }
                  },
                  itemBuilder: (context) {
                    final phoneNumber = number;
                    final hasPhoneNumber =
                        phoneNumber.isNotEmpty;

                    return [
                      PopupMenuItem<String>(
                        value: leadCtrl.leadDetail?.isArchived ?? false
                            ? 'Unarchive Chat'
                            : 'Archive Chat',
                        child: Text(leadCtrl.leadDetail?.isArchived ?? false
                            ? 'Unarchive Chat'
                            : 'Archive Chat'),
                      ),
                      if (chatCtrl.chatHistoryList.isNotEmpty)
                        const PopupMenuItem<String>(
                          value: 'Clear Chat',
                          child: Text('Clear Chat'),
                        ),
                      PopupMenuItem<String>(
                        value: 'Open in WhatsApp',
                        enabled: hasPhoneNumber,
                        child: Row(
                          children: [
                            FaIcon(FontAwesomeIcons.whatsapp,
                                color: hasPhoneNumber
                                    ? Colors.green
                                    : Colors.grey),
                            const SizedBox(width: 8),
                            Text(hasPhoneNumber
                                ? 'Open in WhatsApp'
                                : 'No phone number'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Call',
                        enabled: hasPhoneNumber,
                        child: Row(
                          children: [
                            Icon(Icons.phone,
                                color:
                                    hasPhoneNumber ? Colors.blue : Colors.grey),
                            const SizedBox(width: 8),
                            Text(hasPhoneNumber ? 'Call' : 'No phone number'),
                          ],
                        ),
                      ),
                    ];
                  },
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final url = 'https://wa.me/$phoneNumber';

    final cleanedPhoneNumber =
        phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(' WhatsApp: $phoneNumber')),
      // );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanedPhoneNumber =
        phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final telUrl = 'tel:$cleanedPhoneNumber';
    final wtaiUrl = 'wtai://wp/mc;$cleanedPhoneNumber';

    if (await canLaunch(telUrl)) {
      await launch(telUrl);
    } else if (await canLaunch(wtaiUrl)) {
      await launch(wtaiUrl);
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('PHONE: $phoneNumber')),
      // );
    }
  }

  Future<void> _showDeleteDialog(context) async {
    final msgViewModel = Provider.of<ChatController>(context, listen: false);
    await showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        onConfirm: () {
          msgViewModel.deleteChat();
        },
      ),
    );
  }
}
