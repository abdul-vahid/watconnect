import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/view_models/message_controller.dart';

class DeleteMessageDialog extends StatelessWidget {
  final String id;
  final VoidCallback onConfirm;

  const DeleteMessageDialog(
      {super.key, required this.id, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      title: const Text(
        'Delete Message?',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      content: const Text(
        'Are you sure you want to delete this message?',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Provider.of<MessageController>(context, listen: false)
                .clearDeleteList();
          },
          child: const Text(
            "Cancel",
            style: TextStyle(
              fontSize: 14,
              color: AppColor.navBarIconColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: const Text(
            "Delete",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
