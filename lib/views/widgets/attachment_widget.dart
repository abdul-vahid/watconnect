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
    final width = MediaQuery.of(context).size.width * 0.68;

    switch (fileType) {
      case 'pdf':
        return _docCard(
          context,
          width,
          Icons.picture_as_pdf,
          Colors.red,
          'PDF',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ViewPdf(pdfUrl: url)),
          ),
        );

      case 'doc':
      case 'docx':
        return _docCard(context, width, Icons.description, Colors.blue, 'DOC',
            onTap: () => openDocument(context, url));

      case 'ppt':
      case 'pptx':
        return _docCard(context, width, Icons.slideshow, Colors.orange, 'PPT',
            onTap: () => openDocument(context, url));

      case 'xls':
      case 'xlsx':
        return _docCard(context, width, Icons.grid_on, Colors.green, 'XLS',
            onTap: () => openDocument(context, url));

      case 'mp4':
        return _videoCard(context, width);

      case 'aac':
        return _audioCard(context, width);

      case 'jpg':
      case 'jpeg':
      case 'png':
        return _imageCard(context, width);

      default:
        return _docCard(
          context,
          width,
          Icons.insert_drive_file,
          Colors.grey,
          'FILE',
          onTap: () => openDocument(context, url),
        );
    }
  }

  // ================= DOC CARD =================
  Widget _docCard(
    BuildContext context,
    double width,
    IconData icon,
    Color color,
    String type, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName ?? '$type File',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fileSize ?? 'Tap to view',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // ================= IMAGE =================
  Widget _imageCard(BuildContext context, double width) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PreviewImage(imgUrl: url)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CachedNetworkImage(
            imageUrl: url,
            height: 150,
            width: width,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: Colors.grey.shade200,
              height: 150,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              height: 150,
              child: const Icon(Icons.broken_image),
            ),
          ),
        ),
      ),
    );
  }

  // ================= VIDEO =================
  Widget _videoCard(BuildContext context, double width) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ViewVideo(videoUrl: url)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        height: 150,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.black12,
        ),
        child: const Center(
          child: Icon(Icons.play_circle_fill,
              size: 42, color: Colors.white70),
        ),
      ),
    );
  }

  // ================= AUDIO =================
  Widget _audioCard(BuildContext context, double width) {
    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (_) => AudioDialog(audioUrl: url),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        height: 55,
        width: width * 0.8,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.deepOrange.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.deepOrange.withOpacity(0.2)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.headphones, color: Colors.deepOrange),
            Text(
              "Audio message",
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}