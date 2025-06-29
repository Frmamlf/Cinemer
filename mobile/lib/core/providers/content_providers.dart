import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/movie_models.dart';
import '../models/tv_show_models.dart';
import '../models/anime_models.dart';
import '../models/library_models.dart';

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Movie Providers
final popularMoviesProvider = FutureProvider.family<MovieResponse, int>((ref, page) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getPopularMovies(page: page);
});

final topRatedMoviesProvider = FutureProvider.family<MovieResponse, int>((ref, page) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getTopRatedMovies(page: page);
});

final upcomingMoviesProvider = FutureProvider.family<MovieResponse, int>((ref, page) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getUpcomingMovies(page: page);
});

final nowPlayingMoviesProvider = FutureProvider.family<MovieResponse, int>((ref, page) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getNowPlayingMovies(page: page);
});

final movieDetailsProvider = FutureProvider.family<Movie, int>((ref, movieId) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getMovieDetails(movieId);
});

// TV Show Providers
final popularTVShowsProvider = FutureProvider.family<TVShowResponse, int>((ref, page) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getPopularTVShows(page: page);
});

final topRatedTVShowsProvider = FutureProvider.family<TVShowResponse, int>((ref, page) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getTopRatedTVShows(page: page);
});

final onTheAirTVShowsProvider = FutureProvider.family<TVShowResponse, int>((ref, page) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getOnTheAirTVShows(page: page);
});

final airingTodayTVShowsProvider = FutureProvider.family<TVShowResponse, int>((ref, page) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getAiringTodayTVShows(page: page);
});

final tvShowDetailsProvider = FutureProvider.family<TVShowDetails, int>((ref, tvShowId) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getTVShowDetails(tvShowId);
});

// Anime Providers
final animeMoviesProvider = FutureProvider.family<AnimeResponse, int>((ref, page) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getAnimeMovies(page: page);
});

final animeTVShowsProvider = FutureProvider.family<AnimeResponse, int>((ref, page) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getAnimeTVShows(page: page);
});

final popularAnimeProvider = FutureProvider.family<AnimeResponse, int>((ref, page) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getPopularAnime(page: page);
});

// Helper classes for provider parameters
class SearchParams {
  final String query;
  final int page;

  SearchParams({required this.query, this.page = 1});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchParams &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          page == other.page;

  @override
  int get hashCode => query.hashCode ^ page.hashCode;
}

// Search Providers
final searchMoviesProvider = FutureProvider.family<MovieResponse, SearchParams>((ref, params) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.searchMovies(params.query, page: params.page);
});

final searchTVShowsProvider = FutureProvider.family<TVShowResponse, SearchParams>((ref, params) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.searchTVShows(params.query, page: params.page);
});

final searchAllProvider = FutureProvider.family<Map<String, dynamic>, SearchParams>((ref, params) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.searchAll(params.query, page: params.page);
});

// Discover Providers
final discoverMoviesProvider = FutureProvider.family<MovieResponse, ({int page, String? genre, String? year, String? sortBy})>((ref, params) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.discoverMovies(
    page: params.page,
    genre: params.genre,
    year: params.year,
    sortBy: params.sortBy,
  );
});

final discoverTVShowsProvider = FutureProvider.family<TVShowResponse, ({int page, String? genre, String? year, String? sortBy})>((ref, params) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.discoverTVShows(
    page: params.page,
    genre: params.genre,
    year: params.year,
    sortBy: params.sortBy,
  );
});

// UI State Providers
final selectedCategoryProvider = StateProvider<String>((ref) => 'movies');
final selectedSortProvider = StateProvider<String>((ref) => 'popular');
final searchQueryProvider = StateProvider<String>((ref) => '');
final currentPageProvider = StateProvider<int>((ref) => 1);

// Favorites Provider (local storage)
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<int>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<Set<int>> {
  FavoritesNotifier() : super(<int>{}) {
    _loadFavorites();
  }

  void _loadFavorites() {
    state = StorageService.getFavorites();
  }

  Future<void> toggleFavorite(int id) async {
    if (state.contains(id)) {
      state = Set.from(state)..remove(id);
      await StorageService.removeFavorite(id);
    } else {
      state = Set.from(state)..add(id);
      await StorageService.addFavorite(id);
    }
  }

  bool isFavorite(int id) => state.contains(id);
}

// Watchlist Provider (local storage)
final watchlistProvider = StateNotifierProvider<WatchlistNotifier, List<ListItem>>((ref) {
  return WatchlistNotifier();
});

class WatchlistNotifier extends StateNotifier<List<ListItem>> {
  WatchlistNotifier() : super([]) {
    _loadWatchlist();
  }

  void _loadWatchlist() {
    state = StorageService.getWatchlist();
  }

  Future<void> addToWatchlist(ListItem item) async {
    if (!state.any((element) => element.id == item.id)) {
      state = [...state, item];
      await StorageService.addToWatchlist(item);
    }
  }

  Future<void> removeFromWatchlist(int id) async {
    state = state.where((item) => item.id != id).toList();
    await StorageService.removeFromWatchlist(id);
  }

  Future<void> toggleWatchlist(ListItem item) async {
    if (isInWatchlist(item.id)) {
      await removeFromWatchlist(item.id);
    } else {
      await addToWatchlist(item);
    }
  }

  bool isInWatchlist(int id) => state.any((item) => item.id == id);
}
