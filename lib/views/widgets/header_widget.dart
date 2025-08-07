import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:whatsapp/views/view/show_pdf.dart';
import 'package:whatsapp/views/view/show_video.dart';
import 'package:whatsapp/views/view/view_fullscreen_img.dart';
import 'package:whatsapp/views/widgets/video_placeholder.dart';

class HeaderMediaWidget extends StatelessWidget {
  final String header;
  final String headerBody;

  const HeaderMediaWidget({
    Key? key,
    required this.header,
    required this.headerBody,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (header) {
      case "IMAGE":
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PreviewImage(imgUrl: headerBody),
              ),
            );
          },
          child: CachedNetworkImage(
            imageUrl: headerBody,
            height: 120,
            width: MediaQuery.of(context).size.width * 0.65,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                const Icon(Icons.broken_image),
          ),
        );

      case "VIDEO":
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewVideo(videoUrl: headerBody),
              ),
            );
          },
          child: const VideoPlaceholder(),
        );

      case "DOCUMENT":
        return InkWell(
          onTap: () {
            try {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewPdf(pdfUrl: headerBody),
                ),
              );
            } catch (e) {
              print("Error opening file: $e");
            }
          },
          child: Image.asset(
            "assets/images/doc.png",
            height: 120,
            width: 120,
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
