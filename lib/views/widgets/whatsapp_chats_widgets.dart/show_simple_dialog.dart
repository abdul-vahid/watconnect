import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/view_models/message_controller.dart';

Future<void> showSimpleDialog(
    String id, BuildContext context, VoidCallback singlemsgdelete) async {
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded corners
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
              MessageController msgController =
                  Provider.of<MessageController>(context, listen: false);

              msgController.clearDeleteList();
            },
            child: const Text(
              "Cancel",
              style: TextStyle(
                  fontSize: 14,
                  color: AppColor.navBarIconColor,
                  fontWeight: FontWeight.w600),
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
              MessageController msgController =
                  Provider.of<MessageController>(context, listen: false);
              // singlemsgdelete(msgController.msgToDelete);
              Navigator.of(context).pop(); // Close dialog after deletion
            },
            child: const Text(
              "Delete",
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    },
  );
}
