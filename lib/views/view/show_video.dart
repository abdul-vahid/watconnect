import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:whatsapp/utils/app_color.dart';

class ViewVideo extends StatefulWidget {
  String videoUrl;
  ViewVideo({super.key, required this.videoUrl});

  @override
  State<ViewVideo> createState() => _ViewVideoState();
}

class _ViewVideoState extends State<ViewVideo> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.setVolume(0);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "Video",
            style: TextStyle(color: Colors.white),
          )),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.navBarIconColor,
        onPressed: () {
          setState(() {
            _controller.play();
          });
        },
        child: Icon(
          Icons.replay,
          color: Colors.white,
        ),
      ),
    );
  }
}
