// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart' show EasyLoading;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ViewPdf extends StatefulWidget {
  final String pdfUrl;

  const ViewPdf({super.key, required this.pdfUrl});

  @override
  State<ViewPdf> createState() => _ViewPdfState();
}

class _ViewPdfState extends State<ViewPdf> {
  // final Completer<PDFViewController> _controller =
  //     Completer<PDFViewController>();

  Future<void> downloadFile(String url, String fileName) async {
    try {
      EasyLoading.showToast("Downloading...");

      Directory directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        throw Exception("Unsupported platform");
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      String filePath = '${directory.path}/$fileName';

      Dio dio = Dio();
      await dio.download(url, filePath, onReceiveProgress: (received, total) {
        if (total != -1) {
          print(
              'Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
        }
      });
      EasyLoading.showToast("File downloaded to: $filePath");
    } catch (e) {
      EasyLoading.showToast("Download Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Document",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: "Download PDF",
            onPressed: () {
              final filename = widget.pdfUrl.split('/').last;
              downloadFile(widget.pdfUrl, filename);
            },
            icon: const Icon(Icons.download, color: Colors.white),
          ),
        ],
      ),
      body: SfPdfViewer.network(widget.pdfUrl),
    );
  }
}
