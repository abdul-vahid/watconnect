import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:whatsapp/utils/app_color.dart';

class PreviewImage extends StatefulWidget {
  final String imgUrl;
  const PreviewImage({super.key, required this.imgUrl});

  @override
  State<PreviewImage> createState() => _PreviewImageState();
}

class _PreviewImageState extends State<PreviewImage> {
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
      // ScaffoldMessenger.of(context).showSnackBar(
      //     // SnackBar(content: Text("File downloaded to: $filePath")),
      //     );
    } catch (e) {
      EasyLoading.showToast("Download Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: AppColor.navBarIconColor,
        title: const Text(
          "Image",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: "Download Image",
            onPressed: () {
              final filename = widget.imgUrl.split('/').last;
              downloadFile(widget.imgUrl, filename);
            },
            icon: const Icon(Icons.download, color: Colors.white),
          ),
        ],
      ),
      body: Center(
        child: Image.network(
          widget.imgUrl,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
