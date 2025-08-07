import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:whatsapp/views/view/show_audio.dart';
import 'package:whatsapp/views/view/show_pdf.dart';
import 'package:whatsapp/views/view/show_video.dart';
import 'package:whatsapp/views/view/view_fullscreen_img.dart';
import 'package:whatsapp/views/widgets/whatsapp_chats_widgets.dart/build_attachment_widget.dart';

class AttachmentWidget extends StatelessWidget {
  final String url;
  // final bool isPlaying;

  const AttachmentWidget({
    super.key,
    required this.url,
    // this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    final fileType = url.split('.').last.toLowerCase();
    final double width = MediaQuery.of(context).size.width * 0.65;

    switch (fileType) {
      case 'pdf':
        return _buildIcon(context, "assets/images/pdf.png", width, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ViewPdf(pdfUrl: url)),
          );
        });

      case 'doc':
      case 'docx':
        return _buildIcon(context, "assets/images/doc.png", width, () {
          openDocument(context, url);
        });

      case 'ppt':
      case 'pptx':
        return _buildIcon(context, "assets/images/powerpoint.png", width, () {
          openDocument(context, url);
        });

      case 'xls':
      case 'xlsx':
        return _buildIcon(context, "assets/images/excel.png", width, () {
          openDocument(context, url);
        });

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
                    child: Icon(
                      // isPlaying
                      //     ? Icons.spatial_audio_off_rounded
                      //     :
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
          child: CachedNetworkImage(
            imageUrl: url,
            height: 120,
            width: width,
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
          ),
        );

      default:
        return _buildIcon(context, "assets/images/file.png", width, () {
          openDocument(context, url);
        });
    }
  }

  Widget _buildIcon(BuildContext context, String assetPath, double width,
      VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Image.asset(
        assetPath,
        height: 120,
        width: width,
      ),
    );
  }

  Widget _buildVideoPlaceholder(double width) {
    return Container(
      height: 120,
      width: width,
      color: Colors.black12,
      child: const Icon(Icons.play_circle_filled, size: 48),
    );
  }
}
