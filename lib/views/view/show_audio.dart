// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:whatsapp/utils/app_color.dart';

class AudioDialog extends StatefulWidget {
  final String audioUrl;

  const AudioDialog({Key? key, required this.audioUrl}) : super(key: key);

  @override
  State<AudioDialog> createState() => _AudioDialogState();
}

class _AudioDialogState extends State<AudioDialog> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _audioPlayer.setUrl(widget.audioUrl);

      _audioPlayer.durationStream.listen((d) {
        setState(() => _duration = d ?? Duration.zero);
      });

      _audioPlayer.positionStream.listen((p) {
        setState(() => _position = p);
      });

      _audioPlayer.playerStateStream.listen((state) {
        setState(() {
          _isPlaying = state.playing;
        });
      });
      
    } catch (e) {
      print("Audio error: $e");
    }
  }


bool get _isReady => _duration.inMilliseconds > 0;
  Future<void> _toggle() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Audio Message",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _audioPlayer.stop();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// ICON
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: AppColor.navBarIconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.graphic_eq : Icons.audiotrack,
                size: 40,
                color: AppColor.navBarIconColor,
              ),
            ),

            const SizedBox(height: 20),

            /// PROGRESS BAR
            Column(
              children: [
                Slider(
                  min: 0,
                  max: _duration.inMilliseconds.toDouble(),
                  value: _position.inMilliseconds
                          .clamp(0, _duration.inMilliseconds)
                          .toDouble(),
                  activeColor: AppColor.navBarIconColor,
                  onChanged: (value) async {
                    await _audioPlayer.seek(
                      Duration(milliseconds: value.toInt()),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_format(_position),
                          style: const TextStyle(fontSize: 12)),
                      Text(_format(_duration),
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

           /// PLAY BUTTON
GestureDetector(
  onTap: _isReady ? _toggle : null,
  child: Container(
    height: 56,
    width: 56,
    decoration: BoxDecoration(
      color: _isReady
          ? AppColor.navBarIconColor
          : Colors.grey.shade300,
      shape: BoxShape.circle,
      boxShadow: _isReady
          ? [
              BoxShadow(
                color: AppColor.navBarIconColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
          : [],
    ),
    child: Icon(
      _isPlaying ? Icons.pause : Icons.play_arrow,
      color: _isReady ? Colors.white : Colors.grey,
      size: 30,
    ),
  ),
),
            const SizedBox(height: 12),

            const Text(
              "Tap to play / pause audio",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}