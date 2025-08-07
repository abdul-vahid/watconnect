import 'package:flutter/material.dart';

class VideoPlaceholder extends StatelessWidget {
  const VideoPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
