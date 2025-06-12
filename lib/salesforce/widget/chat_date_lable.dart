import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatDateLabel extends StatelessWidget {
  final DateTime date;

  const ChatDateLabel({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 169, 215, 236),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            formatChatDate(date),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  String formatChatDate(DateTime dt) {
    final now =
        DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));

    if (isSameDay(dt, now)) {
      return "Today";
    } else if (isSameDay(dt, now.subtract(const Duration(days: 1)))) {
      return "Yesterday";
    } else {
      return DateFormat('d MMMM').format(dt);
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
