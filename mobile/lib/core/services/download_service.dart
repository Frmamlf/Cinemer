import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'storage_service.dart';

class DownloadService {
  static final Dio _dio = Dio();
  
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        return result == PermissionStatus.granted;
      }
      return true;
    }
    return true; // iOS doesn't need storage permission for app directory
  }
  
  static Future<String> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // Use external storage downloads directory on Android
      final Directory downloadsDirectory = Directory('/storage/emulated/0/Download/Cinemer');
      if (!await downloadsDirectory.exists()) {
        await downloadsDirectory.create(recursive: true);
      }
      return downloadsDirectory.path;
        }
    
    // Fallback to app documents directory
    final directory = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${directory.path}/downloads');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    return downloadsDir.path;
  }
  
  static Future<String?> downloadVideo({
    required String url,
    required String filename,
    Function(int, int)? onProgress,
  }) async {
    try {
      // Request permission
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }
      
      // Get download directory
      final downloadDir = await getDownloadDirectory();
      final filePath = '$downloadDir/$filename';
      
      // Check if file already exists
      if (await File(filePath).exists()) {
        return filePath;
      }
      
      // Download the file
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: onProgress,
        options: Options(
          headers: {
            'User-Agent': 'CinemerApp/1.0',
          },
        ),
      );
      
      // Save to storage service
      await StorageService.addDownload(filePath);
      
      return filePath;
    } catch (e) {
      throw Exception('Failed to download video: $e');
    }
  }
  
  static Future<List<String>> getDownloadedFiles() async {
    return StorageService.getDownloads();
  }
  
  static Future<void> deleteDownload(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      await StorageService.removeDownload(filePath);
    } catch (e) {
      throw Exception('Failed to delete download: $e');
    }
  }
  
  static Future<bool> isDownloaded(String url) async {
    final downloadDir = await getDownloadDirectory();
    final filename = _getFilenameFromUrl(url);
    final filePath = '$downloadDir/$filename';
    return StorageService.isDownloaded(filePath);
  }
  
  static String _getFilenameFromUrl(String url) {
    final uri = Uri.parse(url);
    String filename = uri.pathSegments.last;
    if (!filename.contains('.')) {
      filename = '${DateTime.now().millisecondsSinceEpoch}.mp4';
    }
    return filename;
  }
  
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (bytes.bitLength - 1) ~/ 10;
    if (i >= suffixes.length) i = suffixes.length - 1;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(1)} ${suffixes[i]}';
  }
}
