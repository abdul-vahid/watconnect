import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class ViewVideo extends StatefulWidget {
  final String videoUrl;
  ViewVideo({super.key, required this.videoUrl});

  @override
  State<ViewVideo> createState() => _ViewVideoState();
}

class _ViewVideoState extends State<ViewVideo> {
  late VideoPlayerController _controller;
  bool _isPlaying = false; // Track play/pause state

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {}); // Update UI when video is ready
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = _controller.value.isPlaying;
    });
  }

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
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Video", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            tooltip: "Download PDF",
            onPressed: () {
              final filename = widget.videoUrl.split('/').last;
              downloadFile(widget.videoUrl, filename);
            },
            icon: const Icon(Icons.download, color: Colors.white),
          ),
        ],
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  if (!_controller.value.isPlaying)
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black45,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: IconButton(
                          icon: const Icon(Icons.play_arrow,
                              size: 30, color: Colors.white),
                          onPressed: _togglePlayPause,
                        ),
                      ),
                    ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
