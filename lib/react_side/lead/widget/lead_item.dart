import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/react_side/lead/controller/lead_list_controller.dart';
import 'package:whatsapp/react_side/lead/model/lead_list_model.dart';
import 'package:whatsapp/react_side/lead/widget/tag_bottom_sheet.dart';
import 'package:whatsapp/utils/app_color.dart';

class LeadItem extends StatelessWidget {
  final LeadRecord data;
  final VoidCallback? onTap;
  final ValueChanged<String>? onMenuSelected;

  const LeadItem({
    super.key,
    required this.data,
    this.onTap,
    this.onMenuSelected,
  });

  String getInitial(String name) {
    if (name.isEmpty) return "?";
    return name[0].toUpperCase();
  }

  String formatTime(String time) {
    try {
      DateTime dateTime = DateTime.parse(time).toLocal();
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = data.contactName ?? "";
    final phone = data.fullNumber ?? "";
    final message = data.message ?? "";
    final time = data.lastMessageTime ?? "";
    final unread = int.tryParse(data.unreadCount ?? "0") ?? 0;
    final isPinned = data.pinned ?? false;
    final isArchived = data.isArchived ?? false;

    return InkWell(
      onTap: onTap ??
          () {
            
          },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.15),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 14),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColor.navBarIconColor.withOpacity(0.9),
                    child: Text(
                      getInitial(name),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (isPinned)
                  Positioned(
                    bottom: -4,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.push_pin,
                        size: 14,
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),

           
            Expanded(
              child: Consumer<LeadListController>(
                  builder: (context, leadCtrl, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontWeight: unread > 0
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatTime(time),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: unread > 0
                                ? AppColor.navBarIconColor
                                : Colors.grey.shade500,
                            fontWeight:
                                unread > 0 ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            phone,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await leadCtrl.fetchAllTags();

                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => TagBottomSheet(
                                leadId: data.leadId ?? "",
                                selectedTagIds: data.tagNames
                                        ?.map((e) => e.id ?? "")
                                        .toList() ??
                                    [],
                              ),
                            );
                          },
                          icon: const Icon(Icons.tag, color: Colors.amber),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message.isEmpty ? "No message" : message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: unread > 0
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                              color: unread > 0
                                  ? Colors.black87
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        if (unread > 0) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColor.navBarIconColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              unread.toString(),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                     
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (onMenuSelected != null) {
                              onMenuSelected!(value);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: isPinned ? "unpin" : "pin",
                              onTap: () {
                                print("calouing pinned::: $isPinned");
                                if (isPinned) {
                                  leadCtrl.unPinLead(data.leadId ?? "");
                                } else {
                                  leadCtrl.pinLead(data.leadId ?? "");
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    isPinned
                                        ? Icons.push_pin_outlined
                                        : Icons.push_pin,
                                    color: AppColor.navBarIconColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(isPinned ? "Unpin" : "Pin"),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: isArchived ? "unarchive" : "archive",
                              onTap: () {
                                leadCtrl.archieveUnarchieveLead(
                                    data.leadId ?? "", !isArchived);
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    isArchived
                                        ? Icons.unarchive_outlined
                                        : Icons.archive_outlined,
                                    color: AppColor.navBarIconColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(isArchived ? "Unarchive" : "Archive"),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              onTap: () async {
                                await leadCtrl.fetchAllTags();

                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) => TagBottomSheet(
                                    leadId: data.leadId ?? "",
                                    selectedTagIds: data.tagNames
                                            ?.map((e) => e.id ?? "")
                                            .toList() ??
                                        [],
                                  ),
                                );
                              },
                              value: "manage_tags",
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.local_offer_outlined,
                                    color: AppColor.navBarIconColor,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text("Manage Tags"),
                                ],
                              ),
                            ),
                          ],
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.more_vert,
                              size: 18,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
