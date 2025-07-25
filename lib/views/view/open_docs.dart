// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:open_file/open_file.dart';

class OpenAllDocs extends StatefulWidget {
  final String url;

  const OpenAllDocs({super.key, required this.url});

  @override
  State<OpenAllDocs> createState() => _OpenAllDocsState();
}

class _OpenAllDocsState extends State<OpenAllDocs> {
  bool _isLoading = true;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _checkOrDownloadFile(widget.url);
  }

  Future<void> _checkOrDownloadFile(String url) async {
    try {
      final filename = url.split('/').last;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');

      if (await file.exists()) {
        // Already downloaded
        _filePath = file.path;
        setState(() => _isLoading = false);
      } else {
        // Download and save permanently
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          _filePath = file.path;
          setState(() => _isLoading = false);
        } else {
          throw Exception("Failed to download file");
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void _openFile() {
    if (_filePath != null) {
      OpenFilex.open(_filePath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Document", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                icon: const Icon(
                  Icons.file_open,
                ),
                label: const Text("Open File"),
                onPressed: _openFile,
              ),
      ),
    );
  }
}
