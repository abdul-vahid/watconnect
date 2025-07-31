import 'package:flutter/material.dart';

class WhatsAppCallGuidelines extends StatelessWidget {
  const WhatsAppCallGuidelines({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "WhatsApp Calling Guidelines:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            bulletPoint(
                "Users must grant call permission before you can place a call."),
            bulletPoint(
                "Permission is temporary – valid for 7 days after approval."),
            bulletPoint(
                "You can only make 5 connected calls per user per 24 hours."),
            bulletPoint("Permission can be granted via:"),
            subBulletPoint("Interactive call request message"),
            subBulletPoint("User calling you first (callback)"),
          ],
        ));
  }
}

Widget bulletPoint(String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(top: 4),
        child: Icon(Icons.circle, size: 6, color: Colors.black54),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ),
    ],
  );
}

Widget subBulletPoint(String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(width: 16),
      const Padding(
        padding: EdgeInsets.only(top: 4),
        child: Icon(Icons.circle, size: 4, color: Colors.black45),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ),
    ],
  );
}
