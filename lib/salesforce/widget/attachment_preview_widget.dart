import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:whatsapp/views/view/show_audio.dart';
import 'package:whatsapp/views/view/show_pdf.dart';
import 'package:whatsapp/views/view/show_video.dart';
import 'package:whatsapp/views/view/view_fullscreen_img.dart';
import 'package:whatsapp/views/widgets/whatsapp_chats_widgets.dart/build_attachment_widget.dart';

class AttachmentPreviewWidget extends StatelessWidget {
  final String? contentType;
  final String? attachmentUrl;

  const AttachmentPreviewWidget({
    super.key,
    required this.contentType,
    required this.attachmentUrl,
  });

  @override
  Widget build(BuildContext context) {
    final String type = contentType ?? "";

    if (type.contains("image")) {
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreviewImage(imgUrl: attachmentUrl ?? ""),
            ),
          );
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
      );
    } else if (type.contains("video")) {
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewVideo(videoUrl: attachmentUrl ?? ''),
            ),
          );
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
    } else if (type.contains("application/pdf")) {
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewPdf(pdfUrl: attachmentUrl ?? ""),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset("assets/images/pdf.png", height: 150),
        ),
      );
    } else if (type.contains("audio")) {
      return InkWell(
        onTap: () async {
          showDialog(
            context: context,
            builder: (context) => AudioDialog(audioUrl: attachmentUrl ?? ""),
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
    } else if (type.contains("ms-excel") || type.contains("spreadsheetml")) {
      return _genericDocumentPreview(
        context,
        imageAsset: "assets/images/excel.png",
      );
    } else if (type.contains("ms-powerpoint") ||
        type.contains("presentationml")) {
      return _genericDocumentPreview(
        context,
        imageAsset: "assets/images/powerpoint.png",
      );
    } else if (type.contains("application")) {
      return _genericDocumentPreview(
        context,
        imageAsset: "assets/images/doc.png",
      );
    }

    return const SizedBox.shrink();
  }

  Widget _genericDocumentPreview(BuildContext context,
      {required String imageAsset}) {
    return InkWell(
      onTap: () {
        print("before opening doc:::: ${attachmentUrl}");
        openDocument(context, attachmentUrl ?? "");
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(imageAsset, height: 150),
      ),
    );
  }
}
