import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/react_side/chat/controller/chat_controller.dart';
import 'package:whatsapp/utils/app_color.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onCodeClick;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onAttach,
    required this.onCodeClick,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (_, ctrl, __) {
        return Container(
          color:   AppColor.pageBgGrey,
          child: Column(
            children: [
          
              if (ctrl.fileToSend != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey.shade200,
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ctrl.fileToSend!.path.split('/').last,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => ctrl.clearFile(),
                      )
                    ],
                  ),
                ),
          
             
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: onAttach,
                    ),
          
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: "Type a message",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
          
                    IconButton(
                      icon: const Icon(Icons.code),
                      onPressed: onCodeClick,
                    ),
          
                   
                    ctrl.isSending
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.green),
                            onPressed: onSend,
                          ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}