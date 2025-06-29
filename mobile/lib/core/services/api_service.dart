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

    // Add API key interceptor for TMDB requests
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add TMDB API key to all requests
        options.queryParameters['api_key'] = AppConstants.tmdbApiKey;
        handler.next(options);
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
      final response = await _dio.get('/movie/popular', queryParameters: {'page': page});
      return MovieResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MovieResponse> getTopRatedMovies({int page = 1}) async {
    try {
      final response = await _dio.get('/movie/top_rated', queryParameters: {'page': page});
      return MovieResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MovieResponse> getUpcomingMovies({int page = 1}) async {
    try {
      final response = await _dio.get('/movie/upcoming', queryParameters: {'page': page});
      return MovieResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MovieResponse> getNowPlayingMovies({int page = 1}) async {
    try {
      final response = await _dio.get('/movie/now_playing', queryParameters: {'page': page});
      return MovieResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Movie> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get('/movie/$movieId');
      return Movie.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // TV Shows
  Future<TVShowResponse> getPopularTVShows({int page = 1}) async {
    try {
      final response = await _dio.get('/tv/popular', queryParameters: {'page': page});
      return TVShowResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TVShowResponse> getTopRatedTVShows({int page = 1}) async {
    try {
      final response = await _dio.get('/tv/top_rated', queryParameters: {'page': page});
      return TVShowResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TVShowResponse> getOnTheAirTVShows({int page = 1}) async {
    try {
      final response = await _dio.get('/tv/on_the_air', queryParameters: {'page': page});
      return TVShowResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TVShowResponse> getAiringTodayTVShows({int page = 1}) async {
    try {
      final response = await _dio.get('/tv/airing_today', queryParameters: {'page': page});
      return TVShowResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TVShowDetails> getTVShowDetails(int tvShowId) async {
    try {
      final response = await _dio.get('/tv/$tvShowId');
      return TVShowDetails.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Anime
  Future<AnimeResponse> getAnimeMovies({int page = 1}) async {
    try {
      final response = await _dio.get('/discover/movie', queryParameters: {
        'page': page,
        'with_genres': '16', // Animation genre
        'with_origin_country': 'JP', // Japanese origin
      });
      return AnimeResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AnimeResponse> getAnimeTVShows({int page = 1}) async {
    try {
      final response = await _dio.get('/discover/tv', queryParameters: {
        'page': page,
        'with_genres': '16', // Animation genre
        'with_origin_country': 'JP', // Japanese origin
      });
      return AnimeResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AnimeResponse> getPopularAnime({int page = 1}) async {
    try {
      final response = await _dio.get('/discover/movie', queryParameters: {
        'page': page,
        'with_genres': '16', // Animation genre
        'with_origin_country': 'JP', // Japanese origin
        'sort_by': 'popularity.desc',
      });
      return AnimeResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Search
  Future<MovieResponse> searchMovies(String query, {int page = 1}) async {
    try {
      final response = await _dio.get('/search/movie', queryParameters: {
        'query': query,
        'page': page,
      });
      return MovieResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TVShowResponse> searchTVShows(String query, {int page = 1}) async {
    try {
      final response = await _dio.get('/search/tv', queryParameters: {
        'query': query,
        'page': page,
      });
      return TVShowResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> searchAll(String query, {int page = 1}) async {
    try {
      final response = await _dio.get('/search/multi', queryParameters: {
        'query': query,
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
      if (genre != null) queryParams['with_genres'] = genre;
      if (year != null) queryParams['primary_release_year'] = year;
      if (sortBy != null) queryParams['sort_by'] = sortBy;

      final response = await _dio.get('/discover/movie', queryParameters: queryParams);
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
      if (genre != null) queryParams['with_genres'] = genre;
      if (year != null) queryParams['first_air_date_year'] = year;
      if (sortBy != null) queryParams['sort_by'] = sortBy;

      final response = await _dio.get('/discover/tv', queryParameters: queryParams);
      return TVShowResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic HTTP methods for library functionality (placeholder - would need TMDB account endpoints)
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      // For now, return empty results for library functions
      // In a real implementation, these would use TMDB's account endpoints with session authentication
      return {'results': []};
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data) async {
    try {
      // For now, return success for library functions
      // In a real implementation, these would use TMDB's account endpoints with session authentication
      return {'success': true};
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      // For now, do nothing for delete operations
      // In a real implementation, this would use TMDB's account endpoints with session authentication
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
