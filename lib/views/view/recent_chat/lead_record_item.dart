import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp/models/recent_chat_model.dart';
import 'package:whatsapp/utils/app_color.dart';

class LeadRecordItem extends StatelessWidget {
  final Records model;
  final String unreadMsgCount;
  final bool shouldHideNumber;
  final List<Map<String, dynamic>> allUniqueTags;
  final bool isSelectedForPin;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onPinToggle;
  final VoidCallback onArchiveToggle;
  final VoidCallback onManageTags;

  const LeadRecordItem({
    super.key,
    required this.model,
    required this.unreadMsgCount,
    required this.shouldHideNumber,
    required this.allUniqueTags,
    required this.isSelectedForPin,
    required this.onTap,
    required this.onLongPress,
    required this.onPinToggle,
    required this.onArchiveToggle,
    required this.onManageTags,
  });

  String _formatPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return '';
    if (shouldHideNumber && phoneNumber.length > 5) {
      final lastFiveDigits = phoneNumber.substring(phoneNumber.length - 5);
      final maskedPart = 'X' * (phoneNumber.length - 5);
      return '$maskedPart$lastFiveDigits';
    }
    return phoneNumber;
  }

  String _formatMessageTime(String isoString) {
    try {
      final inputDate = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDate = DateTime(inputDate.year, inputDate.month, inputDate.day);
      final time = DateFormat('h:mm a').format(inputDate);

      if (messageDate == today) return time;
      if (messageDate == yesterday) return 'Yesterday, $time';
      return DateFormat('dd/MM/yy').format(inputDate);
    } catch (e) {
      return '';
    }
  }

  Color _getTagIconColor() {
    final safeTags = _safeGetTagNames(model);
    if (safeTags.isNotEmpty) {
      final tagIndex = allUniqueTags.indexWhere((t) => t['id'] == safeTags[0]['id']);
      if (tagIndex != -1) return allUniqueTags[tagIndex]['color'] as Color;
    }
    return Colors.grey[600]!;
  }

  List<Map<String, dynamic>> _safeGetTagNames(Records lead) {
    // if (lead.tag_names == null) return [];
    // if (lead.tag_names is List) {
    //   return List<Map<String, dynamic>>.from(lead.tag_names as Iterable);
    // }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final safeTags = _safeGetTagNames(model);
    final hasUnread = unreadMsgCount != "0" && unreadMsgCount.isNotEmpty;
    final tagIconColor = _getTagIconColor();

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: isSelectedForPin ? AppColor.pageBgGrey : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border(left: BorderSide(color: AppColor.navBarIconColor, width: 5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 3,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(child: _buildLeadInfo(context, tagIconColor, safeTags)),
              _buildRightSection(hasUnread, tagIconColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: AppColor.navBarIconColor,
            child: Text(
              model.contactName?.isNotEmpty == true ? model.contactName![0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (model.pinned ?? false)
          const Positioned(
            top: 0,
            right: 0,
            child: CircleAvatar(
              radius: 8,
              backgroundColor: Colors.white,
              child: Icon(Icons.push_pin, size: 12, color: Colors.orange),
            ),
          ),
      ],
    );
  }

  Widget _buildLeadInfo(BuildContext context, Color tagIconColor, List<Map<String, dynamic>> safeTags) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        model.contactName ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (safeTags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: InkWell(
                          onTap: onManageTags,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(FontAwesomeIcons.tag, size: 20, color: tagIconColor),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text(
                                    '+${safeTags.length}',
                                    style: TextStyle(fontSize: 12, color: tagIconColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(_formatPhoneNumber(model.fullNumber), style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            model.message ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildRightSection(bool hasUnread, Color tagIconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (hasUnread)
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            child: Center(
              child: Text(unreadMsgCount, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.more_vert, size: 18, color: Colors.black54),
          onSelected: (value) {
            if (value == 'pin') onPinToggle();
            if (value == 'tags') onManageTags();
            if (value == 'archive') onArchiveToggle();
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'archive',
              child: Row(
                children: [
                  Icon(model.isArchived ?? false ? Icons.archive : Icons.unarchive, color: Colors.black87, size: 18),
                  const SizedBox(width: 8),
                  Text(model.isArchived ?? false ? 'Un-Archive' : 'Archive', style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'pin',
              child: Row(
                children: [
                  Icon(model.pinned ?? false ? Icons.push_pin : Icons.push_pin_outlined, color: Colors.black87, size: 18),
                  const SizedBox(width: 8),
                  Text(model.pinned ?? false ? 'Unpin' : 'Pin', style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'tags',
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.tags, color: tagIconColor, size: 14),
                  const SizedBox(width: 8),
                  const Text('Manage Tags', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(_formatMessageTime(model.createdDate.toString()), style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}