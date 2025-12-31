import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import '../core/services/encryption_service.dart';

class DownloadProvider with ChangeNotifier {
  final Dio _dio = Dio();
  Map<int, bool> _downloadStates = {};
  Map<int, double> _downloadProgress = {};

  DownloadProvider() {
    _loadDownloadStates();
  }

  bool isDownloaded(int courseId) => _downloadStates[courseId] ?? false;
  double getDownloadProgress(int courseId) => _downloadProgress[courseId] ?? 0.0;

  Future<void> _loadDownloadStates() async {
    final box = await Hive.openBox('downloads');
    _downloadStates = Map<int, bool>.from(box.get('states', defaultValue: {}));
    notifyListeners();
  }

  Future<void> _saveDownloadState(int courseId, bool isDownloaded) async {
    final box = await Hive.openBox('downloads');
    _downloadStates[courseId] = isDownloaded;
    await box.put('states', _downloadStates);
    notifyListeners();
  }

  Future<void> downloadCourse(int courseId, String videoUrl, String pdfUrl) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();

      // Download and encrypt video
      if (videoUrl.isNotEmpty) {
        final videoResponse = await _dio.get(videoUrl, options: Options(responseType: ResponseType.bytes));
        final encryptedVideo = EncryptionService.encryptBytes(videoResponse.data);
        final videoFile = File('${appDir.path}/course_$courseId.mp4.enc');
        await videoFile.writeAsBytes(encryptedVideo);
      }

      // Download and encrypt PDF
      if (pdfUrl.isNotEmpty) {
        final pdfResponse = await _dio.get(pdfUrl, options: Options(responseType: ResponseType.bytes));
        final encryptedPdf = EncryptionService.encryptBytes(pdfResponse.data);
        final pdfFile = File('${appDir.path}/course_$courseId.pdf.enc');
        await pdfFile.writeAsBytes(encryptedPdf);
      }

      await _saveDownloadState(courseId, true);
    } catch (e) {
      // Handle error
      print('Download failed: $e');
    }
  }

  Future<void> deleteDownloadedCourse(int courseId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final videoFile = File('${appDir.path}/course_$courseId.mp4.enc');
      final pdfFile = File('${appDir.path}/course_$courseId.pdf.enc');

      if (await videoFile.exists()) await videoFile.delete();
      if (await pdfFile.exists()) await pdfFile.delete();

      await _saveDownloadState(courseId, false);
    } catch (e) {
      print('Delete failed: $e');
    }
  }
}