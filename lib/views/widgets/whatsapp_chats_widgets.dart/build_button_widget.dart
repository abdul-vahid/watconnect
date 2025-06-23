import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp/utils/app_color.dart';

Widget buildButtons(List<dynamic> buttons) {
  return Wrap(
    spacing: 10,
    children: buttons.map((button) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                if (button['type'] == "PHONE_NUMBER") {
                  final Uri phoneUri =
                      Uri.parse("tel:${button['phone_number']}");
                  if (await canLaunchUrl(phoneUri)) await launchUrl(phoneUri);
                } else if (button['type'] == "URL") {
                  final Uri url = Uri.parse(button['url']);

                  if (!await launchUrl(url,
                      mode: LaunchMode.externalApplication)) {
                    throw Exception('Could not launch $url');
                  }
                }
                print("Button clicked: ${button['text']}");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: AppColor.navBarIconColor, width: 1.5),
                ),
              ),
              child: Text(
                button['text'] ?? "",
                style: const TextStyle(
                  color: AppColor.navBarIconColor,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}
