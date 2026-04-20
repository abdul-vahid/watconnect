import 'package:flutter/material.dart';

class ChatContactHeader extends StatelessWidget {
  final String name;
  final String number;
  final VoidCallback? onViewProfile;
  final VoidCallback? onClearChat;

  const ChatContactHeader({
    super.key,
    required this.name,
    required this.number,
    this.onViewProfile,
    this.onClearChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              /// 👤 PROFILE
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(width: 10),

              /// 📛 NAME + NUMBER
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      number,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              /// ⋮ MENU
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == "view_profile") {
                    onViewProfile?.call();
                  } else if (value == "clear_chat") {
                    onClearChat?.call();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: "view_profile",
                    child: Text("View Profile"),
                  ),
                  PopupMenuItem(
                    value: "clear_chat",
                    child: Text("Clear Chat"),
                  ),
                ],
              ),
            ],
          ),

      
        ],
      ),
    );
  }
}