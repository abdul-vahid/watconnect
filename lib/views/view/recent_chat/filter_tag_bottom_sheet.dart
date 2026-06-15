import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:whatsapp/utils/app_color.dart';

class FilterTagsBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> allTags;
  final List<Map<String, dynamic>> selectedTags;
  final Function(List<Map<String, dynamic>>) onFilterApplied;
  final VoidCallback onFilterCleared;

  const FilterTagsBottomSheet({
    super.key,
    required this.allTags,
    required this.selectedTags,
    required this.onFilterApplied,
    required this.onFilterCleared,
  });

  @override
  State<FilterTagsBottomSheet> createState() => _FilterTagsBottomSheetState();
}

class _FilterTagsBottomSheetState extends State<FilterTagsBottomSheet> {
  late List<Map<String, dynamic>> localSelectedTags;
  late List<String> selectedFilterTagIds;

  @override
  void initState() {
    super.initState();
    localSelectedTags = List.from(widget.selectedTags);
    selectedFilterTagIds = localSelectedTags.map((tag) => tag['id'] as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(height: 20),
          if (selectedFilterTagIds.isNotEmpty) _buildSelectedTagsSection(),
          if (selectedFilterTagIds.isEmpty) _buildEmptySelectionInfo(),
          const SizedBox(height: 12),
          const Text('Select Labels to Filter:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Expanded(child: _buildTagsList()),
          const SizedBox(height: 10),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Filter by Labels', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, size: 24),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildSelectedTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Selected for Filter:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedFilterTagIds.map<Widget>((tagId) {
            final tag = widget.allTags.firstWhere(
              (t) => t['id'] == tagId,
              orElse: () => {'id': tagId, 'name': 'Unknown', 'color': Colors.grey},
            );
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (tag['color'] as Color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: tag['color'] as Color, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(FontAwesomeIcons.tag, size: 12, color: tag['color'] as Color),
                  const SizedBox(width: 6),
                  Text(tag['name'], style: TextStyle(fontSize: 12, color: tag['color'] as Color, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => setState(() {
                      localSelectedTags.removeWhere((t) => t['id'] == tagId);
                      selectedFilterTagIds.remove(tagId);
                    }),
                    child: Icon(Icons.close, size: 14, color: tag['color'] as Color),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmptySelectionInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Select at least one label to enable Apply Filter', style: TextStyle(fontSize: 14, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsList() {
    if (widget.allTags.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.tags, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No labels available', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: widget.allTags.length,
      itemBuilder: (context, index) {
        final tag = widget.allTags[index];
        final isSelected = selectedFilterTagIds.contains(tag['id']);
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (tag['color'] as Color).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: FaIcon(FontAwesomeIcons.tag, size: 20, color: tag['color'] as Color),
          ),
          title: Text(tag['name'], style: const TextStyle(fontSize: 16)),
          trailing: Checkbox(
            value: isSelected,
            onChanged: (value) => setState(() {
              if (value == true) {
                if (!selectedFilterTagIds.contains(tag['id'])) {
                  selectedFilterTagIds.add(tag['id']);
                  localSelectedTags.add(tag);
                }
              } else {
                selectedFilterTagIds.remove(tag['id']);
                localSelectedTags.removeWhere((t) => t['id'] == tag['id']);
              }
            }),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget.onFilterCleared();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Clear Filter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: selectedFilterTagIds.isEmpty ? null : () => widget.onFilterApplied(localSelectedTags),
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedFilterTagIds.isEmpty ? Colors.grey.shade300 : AppColor.navBarIconColor,
              foregroundColor: selectedFilterTagIds.isEmpty ? Colors.grey.shade600 : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Apply Filter${selectedFilterTagIds.isNotEmpty ? ' (${selectedFilterTagIds.length})' : ''}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}