import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/view_models/unread_count_vm.dart';
import '../../models/unread_msg_model/record.dart';
import '../../models/unread_msg_model/unread_msg_model.dart'
    show UnreadMsgModel;

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  UnreadCountVm? unreadcountvm;
  List<Record> data = [];

  void fetchcount() async {
    unreadcountvm = Provider.of<UnreadCountVm>(context, listen: false);
    await unreadcountvm!.fetchunreadcount(number: "919530444240").then((_) {
      unreadcountvm!.viewModels.length;
      print("djjdjdjdjdjj${unreadcountvm!.viewModels.length}");

      for (var i in unreadcountvm!.viewModels) {
        UnreadMsgModel datanread = i.model;

        if (datanread.records != null) {
          for (var record in datanread.records!) {
            if (!data.any((r) => r.whatsappNumber == record.whatsappNumber)) {
              data.add(record);
            }
          }
        }
      }
      print("dattaaa=>${data}");
    });
  }

  @override
  void initState() {
    super.initState();
    fetchcount();
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
            itemCount: data.length,
            itemBuilder: (context, index) {
              final record = data[index];
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
                  title: Text(record.whatsappNumber ?? "No Number"),
                  subtitle:
                      Text("Unread Count: ${record.unreadMsgCount ?? "0"}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          record.unreadMsgCount ?? "0",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )),
    );
  }
}
