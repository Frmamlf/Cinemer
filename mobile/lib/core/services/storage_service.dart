import 'package:hive_flutter/hive_flutter.dart';
import '../models/library_models.dart';

class StorageService {
  static const String _favoritesBoxName = 'favorites';
  static const String _watchlistBoxName = 'watchlist';
  static const String _watchHistoryBoxName = 'watch_history';
  static const String _downloadsBoxName = 'downloads';

  static late Box<int> _favoritesBox;
  static late Box<ListItem> _watchlistBox;
  static late Box<ListItem> _watchHistoryBox;
  static late Box<String> _downloadsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ListItemAdapter());
    }
    
    // Open boxes
    _favoritesBox = await Hive.openBox<int>(_favoritesBoxName);
    _watchlistBox = await Hive.openBox<ListItem>(_watchlistBoxName);
    _watchHistoryBox = await Hive.openBox<ListItem>(_watchHistoryBoxName);
    _downloadsBox = await Hive.openBox<String>(_downloadsBoxName);
  }

  // Favorites
  static Set<int> getFavorites() {
    return _favoritesBox.values.toSet();
  }

  static Future<void> addFavorite(int id) async {
    await _favoritesBox.put(id, id);
  }

  static Future<void> removeFavorite(int id) async {
    await _favoritesBox.delete(id);
  }

  static bool isFavorite(int id) {
    return _favoritesBox.containsKey(id);
  }

  // Watchlist
  static List<ListItem> getWatchlist() {
    return _watchlistBox.values.toList();
  }

  static Future<void> addToWatchlist(ListItem item) async {
    await _watchlistBox.put(item.id, item);
  }

  static Future<void> removeFromWatchlist(int id) async {
    await _watchlistBox.delete(id);
  }

  static bool isInWatchlist(int id) {
    return _watchlistBox.containsKey(id);
  }

  // Watch History
  static List<ListItem> getWatchHistory() {
    return _watchHistoryBox.values.toList();
  }

  static Future<void> addToWatchHistory(ListItem item) async {
    await _watchHistoryBox.put(item.id, item);
  }

  static Future<void> removeFromWatchHistory(int id) async {
    await _watchHistoryBox.delete(id);
  }

  static Future<void> clearWatchHistory() async {
    await _watchHistoryBox.clear();
  }

  // Downloads
  static List<String> getDownloads() {
    return _downloadsBox.values.toList();
  }

  static Future<void> addDownload(String path) async {
    final id = path.hashCode;
    await _downloadsBox.put(id, path);
  }

  static Future<void> removeDownload(String path) async {
    final id = path.hashCode;
    await _downloadsBox.delete(id);
  }

  static bool isDownloaded(String path) {
    final id = path.hashCode;
    return _downloadsBox.containsKey(id);
  }

  // Cleanup
  static Future<void> close() async {
    await _favoritesBox.close();
    await _watchlistBox.close();
    await _watchHistoryBox.close();
    await _downloadsBox.close();
  }
}
