import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/view_models/unread_count_vm.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  UnreadCountVm? unreadcountvm;

  @override
  void initState() {
    super.initState();

    unreadcountvm = Provider.of<UnreadCountVm>(context, listen: false);
    unreadcountvm!.fetchunreadcount();
  }

  @override
  Widget build(BuildContext context) {
    unreadcountvm = Provider.of<UnreadCountVm>(context);

    Color getRandomColor() {
      final random = Random();
      return Color.fromARGB(
        255,
        random.nextInt(128),
        random.nextInt(128),
        random.nextInt(128),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColor.navBarIconColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: unreadcountvm!.viewModels.length,
          itemBuilder: (context, index) {
            var notification = unreadcountvm!.viewModels[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: getRandomColor(),
                      width: 5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notification_important,
                      color: Color.fromARGB(255, 0, 0, 0),
                      size: 30,
                    ),
                  ),
                ),
                // title: Text(notification.title ?? "No Title"),
                subtitle: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(notification.message ?? "No message available"),
                    // Text(
                    //     notification.whatsappNumber ?? "No number available"),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      // child: Text(
                      //   notification.unreadCount.toString(),
                      //   style: const TextStyle(
                      //     color: Colors.white,
                      //     fontSize: 12,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
