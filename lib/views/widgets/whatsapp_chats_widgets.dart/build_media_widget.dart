import 'package:flutter/material.dart';

Widget buildMediaWidget(String format, String content) {
  print("format:::::: ${format}  ${content}");
  switch (format) {
    case "IMAGE":
      return content.isEmpty
          ? Container(
              height: 80,
              width: 80,
              child: Image.asset("assets/images/img_placeholder.png"),
            )
          : Image.network(content, fit: BoxFit.cover);

    case "VIDEO":
      return content.isNotEmpty
          ? Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(8)),
              child: const Center(
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            )
          : Container(
              height: 150,
              width: double.infinity,
              color: Colors.black12,
              child: const Center(
                child: Icon(Icons.videocam_off, size: 40, color: Colors.grey),
              ),
            );

    case "DOCUMENT":
      return content.isNotEmpty
          ? GestureDetector(
              onTap: () {
                // openDocument(documentUrl); // Function to open the document
              },
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/doc.png",
                    height: 120,
                    width: 120,
                  ),
                ],
              ),
            )
          : const SizedBox(); // Empty if no document

    default:
      return const SizedBox(); // If format is unknown
  }
}
