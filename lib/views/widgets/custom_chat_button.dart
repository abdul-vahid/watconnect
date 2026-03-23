import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp/utils/app_color.dart';

class CustomButtonList extends StatelessWidget {
  final List<dynamic> buttons;
  final Map<String, dynamic>? buttonVariables;

  const CustomButtonList({
    super.key,
    required this.buttons,
    this.buttonVariables,
  });

  String _getLabel(int index, String original) {
    final key = "${index + 1}";
    if (buttonVariables != null && buttonVariables!.containsKey(key)) {
      final value = buttonVariables![key];
      if (value is String && value.isNotEmpty) return value;
    }
    return original;
  }

  String _resolveDynamicUrl(int index, dynamic originalUrl) {
    final url = originalUrl?.toString() ?? "";
    if (url.isEmpty) return url;

    final key = "${index + 1}";
    final value = buttonVariables?[key];
    if (value is String && value.isNotEmpty) {
      return url.replaceAll(RegExp(r'\{\{\d+\}\}'), value);
    }

    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: buttons.asMap().entries.map((entry) {
        final index = entry.key;
        final button = entry.value;
        final label = _getLabel(index, button['text'] ?? "");
        final resolvedUrl = _resolveDynamicUrl(index, button['url']);

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
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    }
                  } else if (button['type'] == "URL") {
                    final Uri url = Uri.parse(resolvedUrl);
                    if (!await launchUrl(url,
                        mode: LaunchMode.externalApplication)) {
                      throw Exception('Could not launch $url');
                    }
                  }

                  debugPrint("Button clicked: $label");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: const BorderSide(
                      color: AppColor.navBarIconColor,
                      width: 1.5,
                    ),
                  ),
                ),
                child: Text(
                  label,
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
}
