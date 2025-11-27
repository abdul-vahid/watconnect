// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp/views/view/show_pdf.dart';
import 'package:whatsapp/views/view/show_video.dart';
import 'package:whatsapp/views/view/view_fullscreen_img.dart';
import 'package:cached_network_image/cached_network_image.dart';

Widget buildAttachmentWidget(String url, BuildContext context,
    {String? fileName, String? fileSize}) {
  String fileType = url.split('.').last.toLowerCase();
  String displayName = fileName ?? _getDefaultFileName(fileType);

  print("printing:: file type::: $fileType");

  switch (fileType) {
    case 'pdf':
      return _buildDocumentCard(
        context,
        url: url,
        icon: Icons.picture_as_pdf_rounded,
        iconColor: Colors.red,
        backgroundColor: Colors.red.shade50,
        fileName: displayName,
        fileType: "PDF Document",
        fileSize: fileSize,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewPdf(pdfUrl: url),
            ),
          );
        },
      );

    case 'docx':
    case 'doc':
      return _buildDocumentCard(
        context,
        url: url,
        icon: Icons.description_rounded,
        iconColor: Colors.blue,
        backgroundColor: Colors.blue.shade50,
        fileName: displayName,
        fileType: "Word Document",
        fileSize: fileSize,
        onTap: () => openDocument(context, url),
      );

    case 'pptx':
    case 'ppt':
      return _buildDocumentCard(
        context,
        url: url,
        icon: Icons.slideshow_rounded,
        iconColor: Colors.orange,
        backgroundColor: Colors.orange.shade50,
        fileName: displayName,
        fileType: "PowerPoint Presentation",
        fileSize: fileSize,
        onTap: () => openDocument(context, url),
      );

    case 'xlsx':
    case 'xls':
      return _buildDocumentCard(
        context,
        url: url,
        icon: Icons.table_chart_rounded,
        iconColor: Colors.green,
        backgroundColor: Colors.green.shade50,
        fileName: displayName,
        fileType: "Excel Spreadsheet",
        fileSize: fileSize,
        onTap: () => openDocument(context, url),
      );

    case 'mp4':
    case 'mov':
    case 'avi':
      return _buildVideoPreview(context, url);

    case 'png':
    case 'jpg':
    case 'jpeg':
    case 'gif':
      return _buildImagePreview(context, url);

    default:
      return _buildDocumentCard(
        context,
        url: url,
        icon: Icons.insert_drive_file_rounded,
        iconColor: Colors.grey,
        backgroundColor: Colors.grey.shade50,
        fileName: displayName,
        fileType: "File",
        fileSize: fileSize,
        onTap: () => openDocument(context, url),
      );
  }
}

Widget _buildDocumentCard(
  BuildContext context, {
  required String url,
  required IconData icon,
  required Color iconColor,
  required Color backgroundColor,
  required String fileName,
  required String fileType,
  required String? fileSize,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
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
                        fileSize,
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

Widget _buildImagePreview(BuildContext context, String url) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewImage(imgUrl: url),
        ),
      );
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: url,
        width: MediaQuery.of(context).size.width * 0.65,
        height: 150,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 150,
          width: MediaQuery.of(context).size.width * 0.65,
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          height: 150,
          width: MediaQuery.of(context).size.width * 0.65,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
        ),
      ),
    ),
  );
}

Widget _buildVideoPreview(BuildContext context, String url) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewVideo(videoUrl: url),
        ),
      );
    },
    child: Stack(
      children: [
        Container(
          height: 150,
          width: MediaQuery.of(context).size.width * 0.65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
          ),
          child: CachedNetworkImage(
            imageUrl: _getVideoThumbnailUrl(url),
            width: MediaQuery.of(context).size.width * 0.65,
            height: 150,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey.shade800,
              child: const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey.shade800,
              child: const Icon(Icons.videocam_rounded,
                  color: Colors.white, size: 40),
            ),
          ),
        ),
        SizedBox(
          height: 150,
          width: MediaQuery.of(context).size.width * 0.65,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 30),
            ),
          ),
        ),
      ],
    ),
  );
}

void openDocument(BuildContext context, String url) async {
  final filename = url.split('/').last;
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$filename');
  print("filename:::: $filename   $dir");

  // Show loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  // Check and download
  if (!await file.exists()) {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
    } else {
      Navigator.pop(context); // remove loader
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to download file')),
      );
      return;
    }
  }

  Navigator.pop(context); // remove loader
  OpenFilex.open(file.path); // open the file
}

String _getDefaultFileName(String fileType) {
  switch (fileType) {
    case 'pdf':
      return "document.pdf";
    case 'docx':
    case 'doc':
      return "document.docx";
    case 'pptx':
    case 'ppt':
      return "presentation.pptx";
    case 'xlsx':
    case 'xls':
      return "spreadsheet.xlsx";
    case 'mp4':
      return "video.mp4";
    case 'png':
    case 'jpg':
    case 'jpeg':
      return "image.$fileType";
    default:
      return "file.$fileType";
  }
}

String _truncateFileName(String fileName) {
  const maxLength = 20;
  if (fileName.length <= maxLength) return fileName;

  final extension = fileName.substring(fileName.lastIndexOf('.'));
  final nameWithoutExtension = fileName.substring(0, fileName.lastIndexOf('.'));
  final truncatedName =
      nameWithoutExtension.substring(0, maxLength - extension.length - 3);

  return '$truncatedName...$extension';
}

String _getVideoThumbnailUrl(String videoUrl) {
  // This is a placeholder - you might want to generate actual thumbnails
  // For now, return a placeholder image or the video URL itself if your backend provides thumbnails
  return videoUrl;
}
