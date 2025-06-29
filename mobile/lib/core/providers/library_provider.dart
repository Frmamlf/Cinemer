import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/library_models.dart';
import '../services/api_service.dart';

class LibraryNotifier extends StateNotifier<LibraryState> {
  final ApiService _apiService;

  LibraryNotifier(this._apiService) : super(const LibraryState()) {
    _loadLibraryData();
  }

  Future<void> _loadLibraryData() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Load all library data in parallel
      final results = await Future.wait([
        _loadWatchlist(),
        _loadFavorites(),
        _loadCustomLists(),
      ]);
      
      state = state.copyWith(
        isLoading: false,
        watchlist: results[0] as List<ListItem>,
        favorites: results[1] as List<ListItem>,
        customLists: results[2] as List<UserList>,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<List<ListItem>> _loadWatchlist() async {
    try {
      final response = await _apiService.get('/account/watchlist');
      final List<dynamic> results = response['results'] ?? [];
      return results.map((item) => ListItem.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ListItem>> _loadFavorites() async {
    try {
      final response = await _apiService.get('/account/favorite');
      final List<dynamic> results = response['results'] ?? [];
      return results.map((item) => ListItem.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<UserList>> _loadCustomLists() async {
    try {
      final response = await _apiService.get('/account/lists');
      final List<dynamic> results = response['results'] ?? [];
      return results.map((list) => UserList.fromJson(list)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addToWatchlist(int mediaId, String mediaType) async {
    try {
      await _apiService.post('/account/watchlist', {
        'media_type': mediaType,
        'media_id': mediaId,
        'watchlist': true,
      });
      
      // Refresh watchlist
      final watchlist = await _loadWatchlist();
      state = state.copyWith(watchlist: watchlist);
    } catch (e) {
      state = state.copyWith(error: 'Failed to add to watchlist: ${e.toString()}');
    }
  }

  Future<void> removeFromWatchlist(int mediaId, String mediaType) async {
    try {
      await _apiService.post('/account/watchlist', {
        'media_type': mediaType,
        'media_id': mediaId,
        'watchlist': false,
      });
      
      // Refresh watchlist
      final watchlist = await _loadWatchlist();
      state = state.copyWith(watchlist: watchlist);
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove from watchlist: ${e.toString()}');
    }
  }

  Future<void> addToFavorites(int mediaId, String mediaType) async {
    try {
      await _apiService.post('/account/favorite', {
        'media_type': mediaType,
        'media_id': mediaId,
        'favorite': true,
      });
      
      // Refresh favorites
      final favorites = await _loadFavorites();
      state = state.copyWith(favorites: favorites);
    } catch (e) {
      state = state.copyWith(error: 'Failed to add to favorites: ${e.toString()}');
    }
  }

  Future<void> removeFromFavorites(int mediaId, String mediaType) async {
    try {
      await _apiService.post('/account/favorite', {
        'media_type': mediaType,
        'media_id': mediaId,
        'favorite': false,
      });
      
      // Refresh favorites
      final favorites = await _loadFavorites();
      state = state.copyWith(favorites: favorites);
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove from favorites: ${e.toString()}');
    }
  }

  Future<UserList?> createCustomList(CreateListRequest request) async {
    try {
      final response = await _apiService.post('/list', request.toJson());
      final newList = UserList.fromJson(response);
      
      // Add to custom lists
      final updatedLists = [...state.customLists, newList];
      state = state.copyWith(customLists: updatedLists);
      
      return newList;
    } catch (e) {
      state = state.copyWith(error: 'Failed to create list: ${e.toString()}');
      return null;
    }
  }

  Future<void> deleteCustomList(int listId) async {
    try {
      await _apiService.delete('/list/$listId');
      
      // Remove from custom lists
      final updatedLists = state.customLists.where((list) => list.id != listId).toList();
      state = state.copyWith(customLists: updatedLists);
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete list: ${e.toString()}');
    }
  }

  Future<void> addToCustomList(int listId, int mediaId, String mediaType) async {
    try {
      await _apiService.post('/list/$listId/add_item', {
        'media_type': mediaType,
        'media_id': mediaId,
      });
      
      // Refresh custom lists
      final customLists = await _loadCustomLists();
      state = state.copyWith(customLists: customLists);
    } catch (e) {
      state = state.copyWith(error: 'Failed to add to list: ${e.toString()}');
    }
  }

  Future<void> removeFromCustomList(int listId, int mediaId, String mediaType) async {
    try {
      await _apiService.post('/list/$listId/remove_item', {
        'media_type': mediaType,
        'media_id': mediaId,
      });
      
      // Refresh custom lists
      final customLists = await _loadCustomLists();
      state = state.copyWith(customLists: customLists);
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove from list: ${e.toString()}');
    }
  }

  bool isInWatchlist(int mediaId) {
    return state.watchlist.any((item) => item.id == mediaId);
  }

  bool isInFavorites(int mediaId) {
    return state.favorites.any((item) => item.id == mediaId);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> refresh() async {
    await _loadLibraryData();
  }

  // Fast sync method for immediate data loading after login
  Future<void> syncAllData() async {
    // Don't set loading state to avoid blocking UI
    try {
      // Load all library data in parallel for fast sync
      final results = await Future.wait([
        _loadWatchlist(),
        _loadFavorites(),
        _loadCustomLists(),
      ]);
      
      state = state.copyWith(
        watchlist: results[0] as List<ListItem>,
        favorites: results[1] as List<ListItem>,
        customLists: results[2] as List<UserList>,
        error: null,
      );
    } catch (e) {
      // Silently fail for background sync
      state = state.copyWith(error: e.toString());
    }
  }
}

// Providers
final libraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return LibraryNotifier(apiService);
});

final watchlistProvider = Provider<List<ListItem>>((ref) {
  return ref.watch(libraryProvider).watchlist;
});

final favoritesProvider = Provider<List<ListItem>>((ref) {
  return ref.watch(libraryProvider).favorites;
});

final customListsProvider = Provider<List<UserList>>((ref) {
  return ref.watch(libraryProvider).customLists;
});

final libraryLoadingProvider = Provider<bool>((ref) {
  return ref.watch(libraryProvider).isLoading;
});

final libraryErrorProvider = Provider<String?>((ref) {
  return ref.watch(libraryProvider).error;
});
