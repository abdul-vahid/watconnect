import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp/views/view/show_pdf.dart';
import 'package:whatsapp/views/view/show_video.dart';
import 'package:whatsapp/views/view/view_fullscreen_img.dart';

Widget buildAttachmentWidget(String url, BuildContext context) {
  String fileType = url.split('.').last.toLowerCase();
  print("printing:: file type::: ${fileType}");
  switch (fileType) {
    case 'pdf':
      return InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ViewPdf(
                          pdfUrl: url,
                        )));
          },
          child: Image.asset("assets/images/pdf.png",
              height: 120, width: MediaQuery.of(context).size.width * 0.65));

    case 'docx':
    case 'doc':
      return InkWell(
          onTap: () {
            openDocument(context, url);
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => OpenAllDocs(
            //               url: url,
            //             )));
          },
          child: Image.asset("assets/images/doc.png",
              height: 120, width: MediaQuery.of(context).size.width * 0.65));

    case 'pptx':
    case 'ppt':
      return InkWell(
          onTap: () {
            openDocument(context, url);
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => OpenAllDocs(
            //               url: url,
            //             )));
          },
          child: Image.asset("assets/images/powerpoint.png",
              height: 120, width: MediaQuery.of(context).size.width * 0.65));

    case 'xlsx':
    case 'xls':
      return InkWell(
          onTap: () {
            openDocument(context, url);
          },
          child: Image.asset("assets/images/excel.png",
              height: 120, width: MediaQuery.of(context).size.width * 0.65));

    case 'mp4':
      return InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ViewVideo(
                          videoUrl: url,
                        )));
          },
          child: buildVideoPlaceholder(context));
    case 'png':
    case 'jpg':
    case 'jpeg':
      return InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PreviewImage(
                          imgUrl: url,
                        )));
          },
          child: Image.network(url,
              height: 120,
              width: MediaQuery.of(context).size.width * 0.65,
              fit: BoxFit.cover));
    default:
      return InkWell(
          onTap: () {
            openDocument(context, url);
          },
          child: Image.asset("assets/images/file.png",
              height: 120, width: MediaQuery.of(context).size.width * 0.65));
  }
}

void openDocument(BuildContext context, String url) async {
  final filename = url.split('/').last;
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$filename');

  // Show loading dialog (optional)
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
  OpenFile.open(file.path); // open the file
}

Widget buildVideoPlaceholder(context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2.0),
    child: Container(
      height: 120,
      width: MediaQuery.of(context).size.width * 0.65,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
      ),
    ),
  );
}
