import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isTagFilterActive;
  final String? selectedTagName;
  final VoidCallback onBackPressed;
  final VoidCallback onArchivePressed;

  const ChatAppBar({
    super.key,
    required this.isTagFilterActive,
    this.selectedTagName,
    required this.onBackPressed,
    required this.onArchivePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: isTagFilterActive
          ? Row(
              children: [
                GestureDetector(
                  onTap: onBackPressed,
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  selectedTagName ?? 'Tag',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : const Text(
              'Chats',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
      centerTitle: true,
      elevation: 5,
      actions: [
        IconButton(
          onPressed: onArchivePressed,
          icon: const Icon(Icons.archive),
          color: Colors.white,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}