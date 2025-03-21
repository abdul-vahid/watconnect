import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImageScreen extends StatefulWidget {
  final File imageFile;

  const FullScreenImageScreen({super.key, required this.imageFile});

  @override
  _FullScreenImageScreenState createState() => _FullScreenImageScreenState();
}

class _FullScreenImageScreenState extends State<FullScreenImageScreen> {
  bool _showCloseButton = false;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showCloseButton = !_showCloseButton;
              });
              if (_showCloseButton) {
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    _showCloseButton = false;
                  });
                });
              }
            },
            child: Center(
              child: PhotoView(
                imageProvider: FileImage(widget.imageFile),
              ),
            ),
          ),
          Visibility(
            visible: _showCloseButton,
            child: Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Close full-screen view
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
