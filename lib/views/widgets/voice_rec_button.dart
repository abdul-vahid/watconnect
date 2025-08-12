// ignore_for_file: avoid_print, use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sound/flutter_sound.dart' as fs;
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class VoiceRecorderButton extends StatefulWidget {
  final Function(File) onSend;
  final Function(bool)? onRecordingStateChanged;

  const VoiceRecorderButton({
    super.key,
    required this.onSend,
    this.onRecordingStateChanged,
  });

  @override
  State<VoiceRecorderButton> createState() => _VoiceRecorderButtonState();
}

class _VoiceRecorderButtonState extends State<VoiceRecorderButton> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final AudioPlayer audioPlayer = AudioPlayer();

  StreamSubscription? _previewPlayerSubscription;
  String? _audioPath;
  File? _audioFile;
  bool _isRecording = false;
  bool _isPlayingPreview = false;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  Future<void> initialize() async {
    await _recorder.openRecorder();
    await _player.openPlayer();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    audioPlayer.dispose();
    _previewPlayerSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    _audioFile = null;
    var status = await Permission.microphone.status;

    if (status.isGranted) {
      await _beginRecording();
    } else {
      status = await Permission.microphone.request();
      if (status.isGranted) {
        await _beginRecording();
      } else if (status.isPermanentlyDenied) {
        _showPermissionDialog();
      } else {
        EasyLoading.showToast("Microphone permission denied.");
      }
    }
  }

  Future<void> _beginRecording() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath =
          '${tempDir.path}/voice_msg_${DateTime.now().millisecondsSinceEpoch}.aac';
      _audioPath = filePath;

      await _recorder.startRecorder(
        toFile: filePath,
        codec: fs.Codec.aacADTS,
      );

      setState(() => _isRecording = true);
    } catch (e) {
      debugPrint("Recording error: $e");
      EasyLoading.showToast("Failed to start recording");
    }
  }

  Future<void> _stopRecording() async {
    try {
      String? recordedPath = await _recorder.stopRecorder();
      if (recordedPath != null) {
        _audioFile = File(recordedPath);
        setState(() => _isRecording = false);
        await Future.delayed(const Duration(milliseconds: 300));
        _showPreviewDialog();
      }
    } catch (e) {
      debugPrint("Stop recording error: $e");
      EasyLoading.showToast("Failed to stop recording");
    }
  }

  void _showPermissionDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Microphone Access Needed"),
        content: const Text("Please enable microphone access in settings."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                openAppSettings();
              },
              child: const Text("Open Settings")),
        ],
      ),
    );
  }

  Future<void> _showPreviewDialog() async {
    if (_audioPath == null) return;

    final audioPlayer = AudioPlayer();
    Duration? duration;

    try {
      await audioPlayer.setFilePath(_audioPath!);
      duration = audioPlayer.duration;
    } catch (e) {
      print("Error getting duration: $e");
    } finally {
      await audioPlayer.dispose();
    }

    if (duration == null || duration.inSeconds < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Audio must be at least 3 seconds long.")),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> _startPlayer() async {
            await _player.startPlayer(
              fromURI: _audioPath!,
              codec: fs.Codec.aacADTS,
              whenFinished: () {
                setModalState(() => _isPlayingPreview = false);
              },
            );
            setModalState(() => _isPlayingPreview = true);
          }

          Future<void> _stopPlayer() async {
            await _player.stopPlayer();
            _previewPlayerSubscription?.cancel();
            setModalState(() => _isPlayingPreview = false);
          }

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Voice Message Preview"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _isPlayingPreview
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    size: 48,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    _isPlayingPreview ? _stopPlayer() : _startPlayer();
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _stopPlayer();
                  if (_audioFile != null) {
                    widget.onSend(_audioFile!);
                  }
                  Navigator.pop(context);
                },
                child: const Text("Send"),
              ),
              TextButton(
                onPressed: () {
                  _stopPlayer();
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _startRecording(),
      onPointerUp: (_) => _stopRecording(),
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 168, 205, 235),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(10),
        child: Icon(
          _isRecording ? Icons.stop : Icons.mic_none_sharp,
          color: _isRecording ? Colors.red : Colors.black,
        ),
      ),
    );
  }
}
