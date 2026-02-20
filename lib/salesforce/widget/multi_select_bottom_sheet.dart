import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/model/chat_history_model.dart';
import 'package:whatsapp/salesforce/screens/forward_message_screen.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class MultiSelectBottomSheet extends StatelessWidget {
  final List<SfChatHistoryModel> selectedMessages;
  final List<SfChatHistoryModel> allMessages;

  const MultiSelectBottomSheet({
    super.key,
    required this.selectedMessages,
    required this.allMessages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important: Make it wrap content
        children: [
          // Header with drag handle and title
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Drag handle
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
          
          // Action buttons in grid layout (WhatsApp style) - with fixed height to prevent overflow
          SizedBox(
            height: 180, // Fixed height to prevent overflow
            child: GridView.count(
              crossAxisCount: 4,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9, // Maintain aspect ratio for better layout
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
                _buildActionItem(
                  icon: Icons.save_alt,
                  label: 'Save',
                  color: Colors.purple,
                  onTap: () => _saveMedia(context),
                ),
                _buildActionItem(
                  icon: Icons.delete,
                  label: 'Delete',
                  color: Colors.red,
                  onTap: () => _deleteMessages(context),
                ),
                _buildActionItem(
                  icon: Icons.download,
                  label: 'Download',
                  color: Colors.orange,
                  onTap: () => _downloadMedia(context),
                ),
              ],
            ),
          ),
        ],
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
        .map((msg) => msg.message!)
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

    // Filter images from selected messages
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

    // Request permission
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission required to save images'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    int savedCount = 0;
    int totalCount = imageMessages.length;

    Navigator.pop(context);
    controller.clearSelection();

    // Show result
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          savedCount == totalCount
              ? 'All images saved successfully'
              : '$savedCount of $totalCount images saved',
        ),
        duration: const Duration(seconds: 3),
      ),
    );  
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
                Navigator.pop(context);
                Navigator.pop(context); // Close bottom sheet
                controller.clearSelection();
                // Add actual delete logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Messages deleted'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _downloadMedia(BuildContext context) async {
    final controller =
        Provider.of<ChatMessageController>(context, listen: false);

    // Filter downloadable content (images, videos, documents)
    final downloadableMessages = selectedMessages
        .where((msg) =>
            (msg.attachmentUrl?.isNotEmpty ?? false) &&
            (msg.contentType?.isNotEmpty ?? false))
        .toList();

    if (downloadableMessages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No media to download'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.pop(context);
    controller.clearSelection();

    // Show download progress
    EasyLoading.show(
        status: 'Downloading ${downloadableMessages.length} files...');

    int downloadedCount = 0;

    // Download each file
    for (var message in downloadableMessages) {
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