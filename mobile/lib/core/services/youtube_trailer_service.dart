import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';

class TrailerType {
  static const String teaser = 'teaser';
  static const String trailer = 'trailer';
  static const String trailer1 = 'trailer 1';
  static const String trailer2 = 'trailer 2';
  static const String behindScenes = 'behind the scenes';
  static const String featurette = 'featurette';
  static const String clip = 'clip';
  static const String interview = 'interview';
}

class TrailerInfo {
  final String id;
  final String title;
  final String url;
  final String type;
  final String quality;
  final Duration duration;
  final String thumbnailUrl;

  TrailerInfo({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
    required this.quality,
    required this.duration,
    required this.thumbnailUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'url': url,
    'type': type,
    'quality': quality,
    'duration': duration.inSeconds,
    'thumbnailUrl': thumbnailUrl,
  };

  factory TrailerInfo.fromJson(Map<String, dynamic> json) => TrailerInfo(
    id: json['id'],
    title: json['title'],
    url: json['url'],
    type: json['type'],
    quality: json['quality'],
    duration: Duration(seconds: json['duration']),
    thumbnailUrl: json['thumbnailUrl'],
  );
}

class YouTubeTrailerService {
  final YoutubeExplode _youtubeExplode = YoutubeExplode();
  final Dio _dio = Dio();

  /// Search for trailers on YouTube for a movie or TV show
  Future<List<TrailerInfo>> searchTrailers(String title, String year, {String type = 'movie'}) async {
    try {
      final searchQuery = '$title $year trailer teaser';
      final searchResults = await _youtubeExplode.search.search(searchQuery);
      
      List<TrailerInfo> trailers = [];
      
      for (var video in searchResults.take(10)) {
        try {
          final streamManifest = await _youtubeExplode.videos.streamsClient.getManifest(video.id);
          
          // Get the best quality video stream
          final videoStreams = streamManifest.videoOnly.sortByVideoQuality();
          if (videoStreams.isEmpty) continue;
          
          final bestStream = videoStreams.first;
          
          // Determine trailer type from title
          final trailerType = _determineTrailerType(video.title.toLowerCase());
          
          trailers.add(TrailerInfo(
            id: video.id.value,
            title: video.title,
            url: bestStream.url.toString(),
            type: trailerType,
            quality: '${bestStream.videoQuality}',
            duration: video.duration ?? Duration.zero,
            thumbnailUrl: video.thumbnails.mediumResUrl,
          ));
        } catch (e) {
          // Skip this video if there's an error
          continue;
        }
      }
      
      // Sort by trailer type preference
      trailers.sort((a, b) => _getTrailerTypePriority(a.type).compareTo(_getTrailerTypePriority(b.type)));
      
      return trailers;
    } catch (e) {
      throw Exception('Failed to search trailers: $e');
    }
  }

  /// Get direct stream URL for a specific trailer
  Future<String> getStreamUrl(String videoId, {String quality = 'medium'}) async {
    try {
      final streamManifest = await _youtubeExplode.videos.streamsClient.getManifest(videoId);
      
      // Try to get the requested quality, fallback to best available
      final videoStreams = streamManifest.videoOnly.sortByVideoQuality();
      
      if (videoStreams.isEmpty) {
        throw Exception('No video streams available');
      }
      
      return videoStreams.first.url.toString();
    } catch (e) {
      throw Exception('Failed to get stream URL: $e');
    }
  }

  /// Download trailer to local storage
  Future<String> downloadTrailer(TrailerInfo trailer, {Function(double)? onProgress}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final trailersDir = Directory('${directory.path}/trailers');
      if (!await trailersDir.exists()) {
        await trailersDir.create(recursive: true);
      }
      
      final fileName = '${trailer.id}_${trailer.type.replaceAll(' ', '_')}.mp4';
      final filePath = '${trailersDir.path}/$fileName';
      
      // Check if already downloaded
      if (await File(filePath).exists()) {
        return filePath;
      }
      
      // Download the video
      await _dio.download(
        trailer.url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );
      
      // Save metadata
      final metadataPath = '${trailersDir.path}/${trailer.id}_metadata.json';
      await File(metadataPath).writeAsString(jsonEncode(trailer.toJson()));
      
      return filePath;
    } catch (e) {
      throw Exception('Failed to download trailer: $e');
    }
  }

  /// Get list of downloaded trailers
  Future<List<TrailerInfo>> getDownloadedTrailers() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final trailersDir = Directory('${directory.path}/trailers');
      
      if (!await trailersDir.exists()) {
        return [];
      }
      
      final metadataFiles = trailersDir
          .listSync()
          .where((file) => file.path.endsWith('_metadata.json'))
          .cast<File>();
      
      List<TrailerInfo> trailers = [];
      
      for (var file in metadataFiles) {
        try {
          final content = await file.readAsString();
          final json = jsonDecode(content);
          trailers.add(TrailerInfo.fromJson(json));
        } catch (e) {
          // Skip corrupted metadata files
          continue;
        }
      }
      
      return trailers;
    } catch (e) {
      return [];
    }
  }

  /// Delete downloaded trailer
  Future<bool> deleteDownloadedTrailer(String trailerId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final trailersDir = Directory('${directory.path}/trailers');
      
      final files = trailersDir
          .listSync()
          .where((file) => file.path.contains(trailerId))
          .cast<File>();
      
      for (var file in files) {
        await file.delete();
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  String _determineTrailerType(String title) {
    if (title.contains('teaser')) return TrailerType.teaser;
    if (title.contains('trailer 2') || title.contains('trailer #2')) return TrailerType.trailer2;
    if (title.contains('trailer 1') || title.contains('trailer #1')) return TrailerType.trailer1;
    if (title.contains('behind the scenes') || title.contains('making of')) return TrailerType.behindScenes;
    if (title.contains('featurette')) return TrailerType.featurette;
    if (title.contains('trailer')) return TrailerType.trailer;
    return TrailerType.trailer; // Default
  }

  int _getTrailerTypePriority(String type) {
    switch (type) {
      case TrailerType.trailer: return 1;
      case TrailerType.trailer1: return 2;
      case TrailerType.trailer2: return 3;
      case TrailerType.teaser: return 4;
      case TrailerType.featurette: return 5;
      case TrailerType.behindScenes: return 6;
      default: return 7;
    }
  }

  void dispose() {
    _youtubeExplode.close();
  }
}
