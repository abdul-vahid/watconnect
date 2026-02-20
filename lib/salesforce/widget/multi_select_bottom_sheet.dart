import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/model/chat_history_model.dart';
import 'package:flutter/services.dart';
import 'package:whatsapp/salesforce/screens/forward_message_screen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class MultiSelectBottomSheet extends StatelessWidget {
  final List<SfChatHistoryModel> selectedMessages;
  final List<SfChatHistoryModel> allMessages;
  final String chatId;

  const MultiSelectBottomSheet({
    super.key,
    required this.selectedMessages,
    required this.allMessages,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context) {
   
    return KeyedSubtree(
      key: ValueKey('multi_select_$chatId'),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
          
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    '${selectedMessages.length} item${selectedMessages.length > 1 ? 's' : ''} selected',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
      
            SizedBox(
              height: 150,
              child: GridView.count(
                crossAxisCount: 4,
                padding: const EdgeInsets.all(16),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9, 
                children: [
                  _buildActionItem(
                    icon: Icons.content_copy,
                    label: 'Copy',
                    color: Colors.blue,
                    onTap: () => _copyMessages(context),
                  ),
                  _buildActionItem(
                    icon: Icons.forward,
                    label: 'Forward',
                    color: Colors.green,
                    onTap: () => _forwardMessages(context),
                  ),
                  // _buildActionItem(
                  //   icon: Icons.save_alt,
                  //   label: 'Save',
                  //   color: Colors.purple,
                  //   onTap: () => _saveMedia(context),
                  // ),
                  // _buildActionItem(
                  //   icon: Icons.delete,
                  //   label: 'Delete',
                  //   color: Colors.red,
                  //   onTap: () => _deleteMessages(context),
                  // ),
                  // _buildActionItem(
                  //   icon: Icons.download,
                  //   label: 'Download',
                  //   color: Colors.orange,
                  //   onTap: () => _downloadMedia(context),
                  // ),
                ],
              ),
            ),
            
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
          
                    final controller = Provider.of<ChatMessageController>(context, listen: false);
                    controller.clearSelection();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon button
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _copyMessages(BuildContext context) {
    final controller =
        Provider.of<ChatMessageController>(context, listen: false);

    // Combine all text from selected messages
    final textToCopy = selectedMessages
        .where((msg) => msg.message?.isNotEmpty ?? false)
        .map((msg) => msg.message ?? '')
        .join('\n\n');

    if (textToCopy.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: textToCopy));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Messages copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
      controller.clearSelection();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No text to copy'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _forwardMessages(BuildContext context) {
    final controller =
        Provider.of<ChatMessageController>(context, listen: false);

    // For now, we'll forward the first message
    // In a real implementation, you might want to create a multi-forward feature
    if (selectedMessages.isNotEmpty) {
      final firstMessage = selectedMessages.first;
      Navigator.pop(context);
      controller.clearSelection();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ForwardMessageScreen(
            message: firstMessage.message ?? '',
            attachmentUrl: firstMessage.attachmentUrl ?? '',
            contentType: firstMessage.contentType ?? '',
          ),
        ),
      );
    }
  }

  void _saveMedia(BuildContext context) async {
    final controller =
        Provider.of<ChatMessageController>(context, listen: false);

    // Filter image messages
    final imageMessages = selectedMessages
        .where((msg) =>
            (msg.contentType?.contains('image') ?? false) &&
            (msg.attachmentUrl?.isNotEmpty ?? false))
        .toList();

    if (imageMessages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No images to save'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    EasyLoading.show(status: 'Saving images...');

    int savedCount = 0;

    // Save each image
    for (var _ in imageMessages) {
      try {
        // In a real implementation, you would download and save the image
        // This is a placeholder for the save functionality
        await Future.delayed(
            const Duration(milliseconds: 500)); // Simulate save
        savedCount++;
      } catch (e) {
        debugPrint('Error saving image: $e');
      }
    }

    EasyLoading.dismiss();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          savedCount == imageMessages.length
              ? 'All images saved successfully'
              : '$savedCount of ${imageMessages.length} images saved',
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    controller.clearSelection();
    Navigator.pop(context);
  }

  void _deleteMessages(BuildContext context) {
    final controller =
        Provider.of<ChatMessageController>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Messages'),
          content: Text(
            'Are you sure you want to delete ${selectedMessages.length} message${selectedMessages.length > 1 ? 's' : ''}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close bottom sheet
                controller.clearSelection();
                // Call the delete API for each selected message
                _deleteSelectedMessages(context, controller);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedMessages(BuildContext context, ChatMessageController controller) async {
    try {
      EasyLoading.show(status: 'Deleting messages...');
      
      // For now, we'll just clear the selection and show a success message
      // In a real implementation, you would call the actual delete API
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      EasyLoading.dismiss();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Messages deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting messages: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _downloadMedia(BuildContext context) async {
    // Filter downloadable content (images, videos, documents)
    final downloadableMessages = selectedMessages
        .where((msg) =>
            (msg.attachmentUrl?.isNotEmpty ?? false) &&
            (msg.contentType?.isNotEmpty ?? false))
        .toList();

    if (downloadableMessages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No downloadable content selected'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    EasyLoading.show(status: 'Downloading files...');

    int downloadedCount = 0;

    // Download each file
    for (var _ in downloadableMessages) {
      try {
        // In a real implementation, you would download to a specific folder
        // This is a placeholder for the download functionality
        await Future.delayed(
            const Duration(milliseconds: 500)); // Simulate download
        downloadedCount++;
      } catch (e) {
        debugPrint('Error downloading file: $e');
      }
    }

    EasyLoading.dismiss();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          downloadedCount == downloadableMessages.length
              ? 'All files downloaded successfully'
              : '$downloadedCount of ${downloadableMessages.length} files downloaded',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}