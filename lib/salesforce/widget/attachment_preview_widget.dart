// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:whatsapp/views/view/show_audio.dart';
import 'package:whatsapp/views/view/show_video.dart';
import 'package:whatsapp/views/view/view_fullscreen_img.dart';
import 'package:whatsapp/views/widgets/whatsapp_chats_widgets.dart/build_attachment_widget.dart';
import 'package:whatsapp/salesforce/screens/forward_message_screen.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AttachmentPreviewWidget extends StatelessWidget {
  final String? contentType;
  final String? attachmentUrl;
  final String? fileName;
  final String? fileSize;

  const AttachmentPreviewWidget({
    super.key,
    required this.contentType,
    required this.attachmentUrl,
    this.fileName,
    this.fileSize,
  });

  @override
  Widget build(BuildContext context) {
    final String type = contentType ?? "";
    final String displayName = fileName ?? _getDefaultFileName(type);

    if (type.contains("image")) {
      return _buildImagePreview(context);
    } else if (type.contains("video")) {
      return _buildVideoPreview(context);
    } else if (type.contains("application/pdf")) {
      return _buildPdfPreview(context, displayName);
    } else if (type.contains("audio")) {
      return _buildAudioPreview(context);
    } else if (type.contains("ms-excel") || type.contains("spreadsheetml")) {
      return _buildExcelPreview(context, displayName);
    } else if (type.contains("ms-powerpoint") ||
        type.contains("presentationml")) {
      return _buildPowerPointPreview(context, displayName);
    } else if (type.contains("application")) {
      return _buildDocumentPreview(context, displayName);
    }

    return const SizedBox.shrink();
  }

  Widget _buildImagePreview(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _showImageContextMenu(context);
      },
      child: InkWell(
        onTap: () {
          // Show the new send button sheet instead of just opening the image
          _showSendButtonSheet(context);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: attachmentUrl ?? '',
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Image.asset(
              "assets/images/img_place.png",
              height: 150,
              fit: BoxFit.cover,
            ),
            errorWidget: (context, url, error) => Image.asset(
              "assets/images/img_place.png",
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPreview(BuildContext context) {
    return InkWell(
      onTap: () {
        // Show the send button sheet for video
        _showSendButtonSheet(context);
      },
      child: Stack(
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black,
            ),
          ),
          const SizedBox(
            height: 150,
            child: Center(
              child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfPreview(BuildContext context, String fileName) {
    return _buildDocumentCard(
      context,
      icon: Icons.picture_as_pdf_rounded,
      iconColor: Colors.red,
      backgroundColor: Colors.red.shade50,
      fileName: fileName,
      fileType: "PDF Document",
    );
  }

  Widget _buildDocumentPreview(BuildContext context, String fileName) {
    return _buildDocumentCard(
      context,
      icon: Icons.description_rounded,
      iconColor: Colors.blue,
      backgroundColor: Colors.blue.shade50,
      fileName: fileName,
      fileType: "Document",
    );
  }

  Widget _buildExcelPreview(BuildContext context, String fileName) {
    return _buildDocumentCard(
      context,
      icon: Icons.table_chart_rounded,
      iconColor: Colors.green,
      backgroundColor: Colors.green.shade50,
      fileName: fileName,
      fileType: "Excel Spreadsheet",
    );
  }

  Widget _buildPowerPointPreview(BuildContext context, String fileName) {
    return _buildDocumentCard(
      context,
      icon: Icons.slideshow_rounded,
      iconColor: Colors.orange,
      backgroundColor: Colors.orange.shade50,
      fileName: fileName,
      fileType: "PowerPoint Presentation",
    );
  }

  Widget _buildDocumentCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String fileName,
    required String fileType,
  }) {
    return InkWell(
      onTap: () {
        // Show the send button sheet for documents
        _showSendButtonSheet(context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            // Document Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: iconColor.withOpacity(0.3)),
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),

            const SizedBox(width: 12),

            // File Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // File Name
                  Text(
                    _truncateFileName(fileName),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),

                  const SizedBox(height: 4),

                  // File Type and Size
                  Row(
                    children: [
                      Text(
                        fileType,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (fileSize != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade500,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          fileSize ?? "",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Open Icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_outward_rounded,
                size: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPreview(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _showAudioContextMenu(context);
      },
      child: InkWell(
        onTap: () {
          // Show the send button sheet for audio
          _showSendButtonSheet(context);
        },
        child: Container(
          height: 60,
          width: MediaQuery.of(context).size.width * 0.5,
          decoration: BoxDecoration(
            color: Colors.deepOrangeAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.headphones,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDefaultFileName(String contentType) {
    if (contentType.contains("pdf")) return "document.pdf";
    if (contentType.contains("excel") || contentType.contains("spreadsheet"))
      return "spreadsheet.xlsx";
    if (contentType.contains("powerpoint") ||
        contentType.contains("presentation")) return "presentation.pptx";
    if (contentType.contains("application")) return "document.doc";
    return "file";
  }

  String _truncateFileName(String fileName) {
    const maxLength = 20;
    if (fileName.length <= maxLength) return fileName;

    final extension = fileName.substring(fileName.lastIndexOf('.'));
    final nameWithoutExtension =
        fileName.substring(0, fileName.lastIndexOf('.'));
    final truncatedName =
        nameWithoutExtension.substring(0, maxLength - extension.length - 3);

    return '$truncatedName...$extension';
  }

  void _showImageContextMenu(BuildContext context) {
    // Temporarily keeping the old context menu as a fallback
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Text(
                'Image Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Forward Image Option
              ListTile(
                leading: const Icon(Icons.forward, color: Colors.green),
                title: const Text('Forward Image'),
                onTap: () {
                  Navigator.pop(context);
                  _forwardImage(context);
                },
              ),
              
              // Save Image Option
              ListTile(
                leading: const Icon(Icons.save, color: Colors.blue),
                title: const Text('Save Image'),
                onTap: () {
                  Navigator.pop(context);
                  _saveImage();
                },
              ),
              
              // Cancel Button
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAudioContextMenu(BuildContext context) {
    // Temporarily keeping the old context menu as a fallback
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Text(
                'Audio Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Forward Audio Option
              ListTile(
                leading: const Icon(Icons.forward, color: Colors.green),
                title: const Text('Forward Audio'),
                onTap: () {
                  Navigator.pop(context);
                  _forwardAudio(context);
                },
              ),
              
              // Cancel Button
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSendButtonSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white, // Set background color
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom
          ),
          decoration: const BoxDecoration(
            color: Colors.white, // Ensure background is white
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Send',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Action buttons in grid (with fixed height to prevent overflow)
              SizedBox(
                height: 150, // Fixed height to prevent overflow
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Disable scrolling inside grid
                  crossAxisCount: 3,
                  padding: const EdgeInsets.all(16),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildActionItem(
                      icon: Icons.forward,
                      label: 'Forward',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pop(context); // Close bottom sheet first
                        _forwardImage(context); // Then perform action
                      },
                    ),
                    _buildActionItem(
                      icon: Icons.save_alt,
                      label: 'Save',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(context); // Close bottom sheet first
                        _saveImage(); // Then perform action
                      },
                    ),
                    _buildActionItem(
                      icon: Icons.share,
                      label: 'Share',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pop(context); // Close bottom sheet first
                        // Share functionality would go here
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Share feature coming soon')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              // Cancel button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context), // Close bottom sheet
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
        );
      },
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
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 8),
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

  void _forwardImage(BuildContext context) {
    // Navigate to contact selection screen to forward the image
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForwardMessageScreen(
          message: null,
          attachmentUrl: attachmentUrl ?? '',
          contentType: contentType ?? '',
        ),
      ),
    );
  }

  void _forwardAudio(BuildContext context) {
    // Navigate to contact selection screen to forward the audio
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForwardMessageScreen(
          message: null,
          attachmentUrl: attachmentUrl ?? '',
          contentType: contentType ?? '',
        ),
      ),
    );
  }

  void _saveImage() {
    // For now, showing a snackbar indicating the action
    EasyLoading.showToast('Image saved to gallery');
  }
}