import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/youtube_trailer_service.dart';

// Provider for YouTube Trailer Service
final youTubeTrailerServiceProvider = Provider<YouTubeTrailerService>((ref) {
  return YouTubeTrailerService();
});

// Provider for movie/TV show trailers
final trailersProvider = FutureProviderFamily<List<TrailerInfo>, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(youTubeTrailerServiceProvider);
  final title = params['title'] as String;
  final year = params['year'] as String? ?? '';
  final type = params['type'] as String? ?? 'movie';
  
  return await service.searchTrailers(title, year, type: type);
});

// Provider for downloaded trailers
final downloadedTrailersProvider = FutureProvider<List<TrailerInfo>>((ref) async {
  final service = ref.watch(youTubeTrailerServiceProvider);
  return await service.getDownloadedTrailers();
});

// State notifier for trailer downloads
class TrailerDownloadNotifier extends StateNotifier<Map<String, double>> {
  final YouTubeTrailerService _service;

  TrailerDownloadNotifier(this._service) : super({});

  Future<String?> downloadTrailer(TrailerInfo trailer) async {
    try {
      state = {...state, trailer.id: 0.0};
      
      final path = await _service.downloadTrailer(
        trailer,
        onProgress: (progress) {
          state = {...state, trailer.id: progress};
        },
      );
      
      // Remove from download state when complete
      final newState = Map<String, double>.from(state);
      newState.remove(trailer.id);
      state = newState;
      
      return path;
    } catch (e) {
      // Remove from download state on error
      final newState = Map<String, double>.from(state);
      newState.remove(trailer.id);
      state = newState;
      
      rethrow;
    }
  }

  Future<bool> deleteTrailer(String trailerId) async {
    return await _service.deleteDownloadedTrailer(trailerId);
  }

  bool isDownloading(String trailerId) {
    return state.containsKey(trailerId);
  }

  double getDownloadProgress(String trailerId) {
    return state[trailerId] ?? 0.0;
  }
}

final trailerDownloadProvider = StateNotifierProvider<TrailerDownloadNotifier, Map<String, double>>((ref) {
  final service = ref.watch(youTubeTrailerServiceProvider);
  return TrailerDownloadNotifier(service);
});
