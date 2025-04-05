import 'package:flutter/material.dart';
import 'package:whatsapp/utils/app_color.dart';

class PreviewImage extends StatefulWidget {
  String imgUrl;
  PreviewImage({super.key, required this.imgUrl});

  @override
  State<PreviewImage> createState() => _PreviewImageState();
}

class _PreviewImageState extends State<PreviewImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: AppColor.navBarIconColor,
        title: Text(
          "View Image",
          style: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
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
