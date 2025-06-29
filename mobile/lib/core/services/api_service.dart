import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/movie_models.dart';
import '../models/tv_show_models.dart';
import '../models/anime_models.dart';
import '../utils/constants.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptors for logging and error handling
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint('[API] $obj'),
    ));
  }

  // Movies
  Future<MovieResponse> getPopularMovies({int page = 1}) async {
    try {
      final response = await _dio.get('/movies/popular', queryParameters: {'page': page});
      return MovieResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MovieResponse> getTopRatedMovies({int page = 1}) async {
    try {
      final response = await _dio.get('/movies/top-rated', queryParameters: {'page': page});
      return MovieResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MovieResponse> getUpcomingMovies({int page = 1}) async {
    try {
      final response = await _dio.get('/movies/upcoming', queryParameters: {'page': page});
      return MovieResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MovieResponse> getNowPlayingMovies({int page = 1}) async {
    try {
      final response = await _dio.get('/movies/now-playing', queryParameters: {'page': page});
      return MovieResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Movie> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get('/movies/$movieId');
      return Movie.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // TV Shows
  Future<TVShowResponse> getPopularTVShows({int page = 1}) async {
    try {
      final response = await _dio.get('/tv-shows/popular', queryParameters: {'page': page});
      return TVShowResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TVShowResponse> getTopRatedTVShows({int page = 1}) async {
    try {
      final response = await _dio.get('/tv-shows/top-rated', queryParameters: {'page': page});
      return TVShowResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TVShowResponse> getOnTheAirTVShows({int page = 1}) async {
    try {
      final response = await _dio.get('/tv-shows/on-the-air', queryParameters: {'page': page});
      return TVShowResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TVShowResponse> getAiringTodayTVShows({int page = 1}) async {
    try {
      final response = await _dio.get('/tv-shows/airing-today', queryParameters: {'page': page});
      return TVShowResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TVShowDetails> getTVShowDetails(int tvShowId) async {
    try {
      final response = await _dio.get('/tv-shows/$tvShowId');
      return TVShowDetails.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Anime
  Future<AnimeResponse> getAnimeMovies({int page = 1}) async {
    try {
      final response = await _dio.get('/anime/movies', queryParameters: {'page': page});
      return AnimeResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AnimeResponse> getAnimeTVShows({int page = 1}) async {
    try {
      final response = await _dio.get('/anime/tv-shows', queryParameters: {'page': page});
      return AnimeResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AnimeResponse> getPopularAnime({int page = 1}) async {
    try {
      final response = await _dio.get('/anime/popular', queryParameters: {'page': page});
      return AnimeResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Search
  Future<MovieResponse> searchMovies(String query, {int page = 1}) async {
    try {
      final response = await _dio.get('/search/movies', queryParameters: {
        'q': query,
        'page': page,
      });
      return MovieResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TVShowResponse> searchTVShows(String query, {int page = 1}) async {
    try {
      final response = await _dio.get('/search/tv-shows', queryParameters: {
        'q': query,
        'page': page,
      });
      return TVShowResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> searchAll(String query, {int page = 1}) async {
    try {
      final response = await _dio.get('/search/all', queryParameters: {
        'q': query,
        'page': page,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Discover
  Future<MovieResponse> discoverMovies({
    int page = 1,
    String? genre,
    String? year,
    String? sortBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (genre != null) queryParams['genre'] = genre;
      if (year != null) queryParams['year'] = year;
      if (sortBy != null) queryParams['sort_by'] = sortBy;

      final response = await _dio.get('/discover/movies', queryParameters: queryParams);
      return MovieResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TVShowResponse> discoverTVShows({
    int page = 1,
    String? genre,
    String? year,
    String? sortBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (genre != null) queryParams['genre'] = genre;
      if (year != null) queryParams['year'] = year;
      if (sortBy != null) queryParams['sort_by'] = sortBy;

      final response = await _dio.get('/discover/tv-shows', queryParameters: queryParams);
      return TVShowResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic HTTP methods for library functionality
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return Exception('Connection timeout. Please check your internet connection.');
        case DioExceptionType.connectionError:
          return Exception('Unable to connect to server. Please check your internet connection.');
        case DioExceptionType.badResponse:
          if (error.response?.statusCode == 404) {
            return Exception('Content not found.');
          } else if (error.response?.statusCode == 500) {
            return Exception('Server error. Please try again later.');
          }
          return Exception('Request failed: ${error.response?.statusMessage}');
        default:
          return Exception('An unexpected error occurred.');
      }
    }
    return Exception('An unexpected error occurred: $error');
  }
}

// Provider for ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
