import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../../providers/download_provider.dart';
import '../../../../core/services/encryption_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final int lessonId;
  final String onlineUrl;
  final bool isOffline;

  const VideoPlayerScreen({
    super.key,
    required this.lessonId,
    required this.onlineUrl,
    this.isOffline = false,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  File? _tempFile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      String videoPath;

      if (widget.isOffline) {
        // Offline mode: decrypt the encrypted file to a temporary file
        final appDir = await getApplicationDocumentsDirectory();
        final encryptedFile = File('${appDir.path}/lesson_${widget.lessonId}.mp4.enc');

        if (!await encryptedFile.exists()) {
          throw Exception('Encrypted video file not found');
        }

        final encryptedBytes = await encryptedFile.readAsBytes();
        final decryptedBytes = EncryptionService.decryptBytes(encryptedBytes);

        // Create temp file in cache directory
        final cacheDir = await getTemporaryDirectory();
        _tempFile = File('${cacheDir.path}/temp_${widget.lessonId}.mp4');
        await _tempFile!.writeAsBytes(decryptedBytes);

        videoPath = _tempFile!.path;
      } else {
        // Online mode
        videoPath = widget.onlineUrl;
      }

      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoPath));
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading video: $e')),
      );
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();

    // Crucial: Delete the temporary decrypted file
    if (_tempFile != null && _tempFile!.existsSync()) {
      _tempFile!.deleteSync();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Video Player'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chewieController != null
              ? Chewie(controller: _chewieController!)
              : const Center(
                  child: Text(
                    'Failed to load video',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
    );
  }
}