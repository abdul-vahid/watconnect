import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/react_side/lead/controller/lead_list_controller.dart';
import 'package:whatsapp/utils/app_color.dart';

class TagFilterBottomSheet extends StatefulWidget {
  final List<String> selectedTagIds;
  final FilterMode filterMode;

  const TagFilterBottomSheet({
    super.key,
    required this.selectedTagIds,
    required this.filterMode,
  });

  @override
  State<TagFilterBottomSheet> createState() =>
      _TagFilterBottomSheetState();
}

class _TagFilterBottomSheetState
    extends State<TagFilterBottomSheet> {
  late List<String> selectedIds;
  late FilterMode mode;

  @override
  void initState() {
    selectedIds = List.from(widget.selectedTagIds);
    mode = widget.filterMode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<LeadListController>();
    final primaryColor = AppColor.navBarIconColor;

    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
         
            Center(
              child: Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Filter Leads",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (selectedIds.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() => selectedIds.clear());
                    },
                    child: Text(
                      "Reset",
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

      
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildModeButton(
                      title: "OR",
                      isSelected: mode == FilterMode.or,
                      onTap: () => setState(() => mode = FilterMode.or),
                      color: primaryColor,
                    ),
                  ),
                  Expanded(
                    child: _buildModeButton(
                      title: "AND",
                      isSelected: mode == FilterMode.and,
                      onTap: () => setState(() => mode = FilterMode.and),
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

           
            const Text(
              "Select Tags",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

       
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ctrl.allTagList.map((tag) {
                    final isSelected = selectedIds.contains(tag.id);

                    return FilterChip(
                      label: Text(tag.name),
                      selected: isSelected,
                      selectedColor: primaryColor.withOpacity(0.15),
                      backgroundColor: Colors.grey.shade100,
                      checkmarkColor: primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? primaryColor
                            : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? primaryColor
                            : Colors.grey.shade300,
                      ),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            selectedIds.add(tag.id);
                          } else {
                            selectedIds.remove(tag.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 12),

           
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<LeadListController>().clearFilter();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor),
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Clear"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<LeadListController>().updateFilter(
                            tagIds: selectedIds,
                            mode: mode,
                          );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Apply",style: TextStyle(color: Colors.white),),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildModeButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}