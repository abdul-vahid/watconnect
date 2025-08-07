import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ImagePickerBottomSheet {
  static Future<File?> show(BuildContext context) async {
    return await showModalBottomSheet<File?>(
      context: context,
      backgroundColor: Colors.black87,
      builder: (context) => _PickerOptions(),
    );
  }
}

class _PickerOptions extends StatelessWidget {
  const _PickerOptions({super.key});

  Future<void> _handleGalleryPick(BuildContext context) async {
    final pickedFile = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: [
        "jpg",
        "jpeg",
        "png",
        "gif",
        "pdf",
        "txt",
        "doc",
        "docx",
        "ppt",
        "pptx",
        "xls",
        "xlsx",
        "mp4",
        "csv",
      ],
    );

    if (pickedFile != null) {
      EasyLoading.showToast("Picked Successfully");
      final file = File(pickedFile.files.first.path!);
      Navigator.of(context).pop(file);
    } else {
      Navigator.of(context).pop(null);
    }
  }

  Future<void> _handleCameraPick(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      Navigator.of(context).pop(file);
    } else {
      Navigator.of(context).pop(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        ListTile(
          leading: const Icon(Icons.photo_library, color: Colors.white),
          title: const Text("Choose from Gallery",
              style: TextStyle(color: Colors.white)),
          onTap: () => _handleGalleryPick(context),
        ),
        ListTile(
          leading: const Icon(Icons.camera_alt, color: Colors.white),
          title:
              const Text("Take a Photo", style: TextStyle(color: Colors.white)),
          onTap: () => _handleCameraPick(context),
        ),
      ],
    );
  }
}
