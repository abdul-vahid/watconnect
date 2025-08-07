import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class FilePreviewWidget extends StatelessWidget {
  final File file;

  const FilePreviewWidget({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ext = path.extension(file.path).toLowerCase();

    if (ext.contains('pdf')) {
      return _buildAssetPreview("assets/images/pdf.png");
    } else if (ext.contains('mp4')) {
      return const Icon(Icons.play_arrow, color: Colors.black, size: 30);
    } else if (['.jpg', '.jpeg', '.png'].contains(ext)) {
      return SizedBox(
        height: 50,
        width: 50,
        child: Image.file(file, fit: BoxFit.cover),
      );
    } else {
      return _buildAssetPreview("assets/images/file.png");
    }
  }

  Widget _buildAssetPreview(String assetPath) {
    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.only(right: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.asset(assetPath, fit: BoxFit.cover),
      ),
    );
  }
}
