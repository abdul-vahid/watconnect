import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:whatsapp/views/view/show_audio.dart';
import 'package:whatsapp/views/view/show_pdf.dart';
import 'package:whatsapp/views/view/show_video.dart';
import 'package:whatsapp/views/view/view_fullscreen_img.dart';
import 'package:whatsapp/views/widgets/whatsapp_chats_widgets.dart/build_attachment_widget.dart';

class AttachmentWidget extends StatelessWidget {
  final String url;
  final String? fileName;
  final String? fileSize;

  const AttachmentWidget({
    super.key,
    required this.url,
    this.fileName,
    this.fileSize,
  });

  @override
  Widget build(BuildContext context) {
    final fileType = url.split('.').last.toLowerCase();
    final double width = MediaQuery.of(context).size.width * 0.65;

    switch (fileType) {
      case 'pdf':
        return _buildDocumentCard(
          context: context,
          iconPath: "assets/images/pdf.png",
          width: width,
          title: fileName ?? 'Document.pdf',
          subtitle: fileSize ?? 'PDF File',
          color: Colors.red.shade50,
          iconColor: Colors.red,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ViewPdf(pdfUrl: url)),
            );
          },
        );

      case 'doc':
      case 'docx':
        return _buildDocumentCard(
          context: context,
          iconPath: "assets/images/doc.png",
          width: width,
          title: fileName ?? 'Document.doc',
          subtitle: fileSize ?? 'Word Document',
          color: Colors.blue.shade50,
          iconColor: Colors.blue,
          onTap: () {
            openDocument(context, url);
          },
        );

      case 'ppt':
      case 'pptx':
        return _buildDocumentCard(
          context: context,
          iconPath: "assets/images/powerpoint.png",
          width: width,
          title: fileName ?? 'Presentation.ppt',
          subtitle: fileSize ?? 'PowerPoint',
          color: Colors.orange.shade50,
          iconColor: Colors.orange,
          onTap: () {
            openDocument(context, url);
          },
        );

      case 'xls':
      case 'xlsx':
        return _buildDocumentCard(
          context: context,
          iconPath: "assets/images/excel.png",
          width: width,
          title: fileName ?? 'Spreadsheet.xls',
          subtitle: fileSize ?? 'Excel File',
          color: Colors.green.shade50,
          iconColor: Colors.green,
          onTap: () {
            openDocument(context, url);
          },
        );

      case 'mp4':
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ViewVideo(videoUrl: url)),
            );
          },
          child: _buildVideoPlaceholder(width),
        );

      case 'aac':
        return InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AudioDialog(audioUrl: url),
            );
          },
          child: Container(
            height: 60,
            width: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(
              color: Colors.deepOrangeAccent,
              borderRadius: BorderRadius.circular(12),
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
        );

      case 'jpg':
      case 'jpeg':
      case 'png':
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PreviewImage(imgUrl: url)),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: url,
                height: 120,
                width: width,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
        );

      default:
        return _buildDocumentCard(
          context: context,
          iconPath: "assets/images/file.png",
          width: width,
          title: fileName ?? 'Unknown File',
          subtitle: fileSize ?? 'File',
          color: Colors.grey.shade50,
          iconColor: Colors.grey,
          onTap: () {
            openDocument(context, url);
          },
        );
    }
  }

  Widget _buildDocumentCard({
    required BuildContext context,
    required String iconPath,
    required double width,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // File Icon with background
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  iconPath,
                  width: 28,
                  height: 28,
                  color: iconColor,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // File info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Download/Open indicator
                  Row(
                    children: [
                      Icon(
                        Icons.download_rounded,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap to open',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow indicator
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder(double width) {
    return Container(
      height: 120,
      width: width,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // You could add a thumbnail here if available
          Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                size: 32,
                color: Colors.grey.shade700,
              ),
            ),
          ),

          // Video duration indicator (optional)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'MP4',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
