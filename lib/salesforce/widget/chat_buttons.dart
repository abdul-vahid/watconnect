import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp/salesforce/model/chat_history_model.dart';
import 'package:whatsapp/utils/app_color.dart';

class ChatButtons extends StatelessWidget {
  final List<ButtonItem> buttons;

  const ChatButtons({super.key, required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: buttons.map((button) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ElevatedButton(
            onPressed: () async {
              if (button.action == "phone") {
                final Uri phoneUri = Uri.parse("tel:${button.value}");
                if (await canLaunchUrl(phoneUri)) {
                  await launchUrl(phoneUri);
                }
              } else if (button.action == "website") {
                final fixedUrl = button.value!.startsWith('http')
                    ? button.value!
                    : 'https://${button.value}';
                final Uri url = Uri.parse(fixedUrl);
                if (!await launchUrl(url,
                    mode: LaunchMode.externalApplication)) {
                  throw Exception('Could not launch $url');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: const BorderSide(
                    color: AppColor.navBarIconColor, width: 1.5),
              ),
            ),
            child: Text(
              button.label ?? "",
              style: const TextStyle(
                color: AppColor.navBarIconColor,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
