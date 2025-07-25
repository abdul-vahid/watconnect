// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';

class HeaderTypePreview extends StatelessWidget {
  final String? headerType;

  const HeaderTypePreview({super.key, required this.headerType});

  @override
  Widget build(BuildContext context) {
    String imagePath = "assets/images/img_placeholder.png"; // default

    if (headerType == "DOCUMENT") {
      imagePath = "assets/images/doc.png";
    } else if (headerType == "VIDEO") {
      imagePath = "assets/images/video.png";
    } else if (headerType == "IMAGE") {
      imagePath = "assets/images/img_placeholder.png";
    }

    return Container(
      height: 80,
      width: 80,
      child: Image.asset(imagePath),
    );
  }
}
