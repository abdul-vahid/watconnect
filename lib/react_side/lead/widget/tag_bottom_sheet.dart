import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp/react_side/lead/controller/lead_list_controller.dart';
import 'package:whatsapp/utils/app_color.dart';

class TagBottomSheet extends StatefulWidget {
  final String leadId;
  final List<String> selectedTagIds;

  const TagBottomSheet({
    super.key,
    required this.leadId,
    required this.selectedTagIds,
  });

  @override
  State<TagBottomSheet> createState() => _TagBottomSheetState();
}

class _TagBottomSheetState extends State<TagBottomSheet> {
  late Set<String> selectedTags;

  @override
  void initState() {
    super.initState();
    selectedTags = widget.selectedTagIds.toSet();
  }

  void toggleTag(String tagId) {
    setState(() {
      if (selectedTags.contains(tagId)) {
        selectedTags.remove(tagId); 
      } else {
        selectedTags.add(tagId); 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final leadCtrl = context.watch<LeadListController>();
    final tags = leadCtrl.allTagList;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
     
            Text(
              "Manage Tags",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),


            Expanded(
              child: tags.isEmpty
                  ? const Center(child: Text("No tags found"))
                  : ListView.builder(
                      itemCount: tags.length,
                      itemBuilder: (context, index) {
                        final tag = tags[index];
                        final tagId = tag.id ?? "";
                        final isSelected = selectedTags.contains(tagId);

                        return ListTile(
                          onTap: () => toggleTag(tagId),
                          leading: Icon(
                            isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: isSelected
                                ? AppColor.navBarIconColor
                                : Colors.grey,
                          ),
                          title: Text(
                            tag.name ?? "",
                            style: GoogleFonts.poppins(),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 12),

           
            Row(
              children: [
             
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Close"),
                  ),
                ),

                const SizedBox(width: 12),

               
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.navBarIconColor,
                    ),
                    onPressed: () async {
                     
                      final updatedTags = tags
                          .where((tag) =>
                              selectedTags.contains(tag.id))
                          .map((tag) => {
                                "id": tag.id,
                                "name": tag.name,
                              })
                          .toList();

                      await leadCtrl.updateTag(
                        widget.leadId,
                        updatedTags,
                      );

                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Apply",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}