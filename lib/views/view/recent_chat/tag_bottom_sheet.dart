import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:whatsapp/models/recent_chat_model.dart';
import 'package:whatsapp/utils/app_color.dart';

class TagsBottomSheet extends StatefulWidget {
  final Records lead;
  final List<Map<String, dynamic>> allTags;
  final Function(List<String>) onTagsSaved;
  final Future<Map<String, dynamic>?> Function(String) onTagCreated;

  const TagsBottomSheet({
    super.key,
    required this.lead,
    required this.allTags,
    required this.onTagsSaved,
    required this.onTagCreated,
  });

  @override
  State<TagsBottomSheet> createState() => _TagsBottomSheetState();
}

class _TagsBottomSheetState extends State<TagsBottomSheet> {
  late List<String> selectedTagIds;
  bool isCreatingNewLabel = false;
  final TextEditingController newTagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final currentTags = _safeGetTagNames(widget.lead);
    selectedTagIds = currentTags.map((tag) => tag['id'] as String).toList();
  }

  List<Map<String, dynamic>> _safeGetTagNames(Records lead) {
    // if (lead.tag_names == null) return [];
    // if (lead.tag_names is List) {
    //   return List<Map<String, dynamic>>.from(lead.tag_names as Iterable);
    // }
    return [];
  }

  @override
  void dispose() {
    newTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortedTags = List.from(widget.allTags)
      ..sort((a, b) {
        final aSelected = selectedTagIds.contains(a['id']);
        final bSelected = selectedTagIds.contains(b['id']);
        if (aSelected && !bSelected) return -1;
        if (!aSelected && bSelected) return 1;
        return 0;
      });

    final hasChanges = !_areListsEqual(
      _safeGetTagNames(widget.lead).map((tag) => tag['id'] as String).toList(),
      selectedTagIds,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(height: 20),
          _buildCreateNewLabelButton(),
          if (isCreatingNewLabel) _buildCreateNewLabelForm(),
          const SizedBox(height: 10),
          const Text('Available Labels', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Expanded(child: _buildTagsList(sortedTags)),
          const SizedBox(height: 10),
          _buildSaveButton(hasChanges),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Label chat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(widget.lead.contactName ?? 'Unknown Contact', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Text('Total: ${selectedTagIds.length} selected', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, size: 24),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildCreateNewLabelButton() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColor.cardsColor.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, size: 24, color: AppColor.navBarIconColor),
      ),
      title: const Text('Create new label', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => setState(() => isCreatingNewLabel = true),
    );
  }

  Widget _buildCreateNewLabelForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Create New Label', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: newTagController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter label name',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  suffixIcon: newTagController.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear), onPressed: () => newTagController.clear())
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => setState(() {
                isCreatingNewLabel = false;
                newTagController.clear();
              }),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: newTagController.text.trim().isNotEmpty ? _createTag : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: newTagController.text.trim().isNotEmpty ? AppColor.navBarIconColor : Colors.grey.shade300,
              ),
              child: const Text('Create Label'),
            ),
          ],
        ),
        const Divider(height: 20),
      ],
    );
  }

  Future<void> _createTag() async {
    final tagName = newTagController.text.trim();
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    final newTag = await widget.onTagCreated(tagName);
    if (context.mounted) Navigator.pop(context);

    if (newTag != null && context.mounted) {
      setState(() {
        selectedTagIds.add(newTag['id']);
        newTagController.clear();
        isCreatingNewLabel = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Label "$tagName" created successfully'), duration: const Duration(seconds: 2)),
      );
    }
  }

  Widget _buildTagsList(List<dynamic> tags) {
    if (tags.isEmpty && !isCreatingNewLabel) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.tags, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No labels available', style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Create your first label', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        final isSelected = selectedTagIds.contains(tag['id']);
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
                if (!selectedTagIds.contains(tag['id'])) selectedTagIds.add(tag['id']);
              } else {
                selectedTagIds.remove(tag['id']);
              }
            }),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton(bool hasChanges) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasChanges ? () => widget.onTagsSaved(selectedTagIds) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasChanges ? AppColor.navBarIconColor : Colors.grey.shade300,
          foregroundColor: hasChanges ? Colors.white : Colors.grey.shade600,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Save Labels', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }

  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (var i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}