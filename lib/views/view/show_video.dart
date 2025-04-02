import 'package:flutter/material.dart';
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
                    IconButton(
                      icon: const Icon(Icons.play_arrow,
                          size: 60, color: Colors.white),
                      onPressed: _togglePlayPause,
                    ),
                ],
              )
            : const CircularProgressIndicator(), // Show loader while video loads
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _togglePlayPause,
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
      ),
    );
  }
}
