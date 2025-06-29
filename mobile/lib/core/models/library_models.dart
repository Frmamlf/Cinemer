import 'package:hive/hive.dart';

part 'library_models.g.dart';

@HiveType(typeId: 0)
class UserList {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final int itemCount;
  @HiveField(4)
  final String language;
  @HiveField(5)
  final String listType;
  @HiveField(6)
  final String? posterPath;
  @HiveField(7)
  final List<ListItem> items;

  const UserList({
    required this.id,
    required this.name,
    required this.description,
    required this.itemCount,
    required this.language,
    required this.listType,
    this.posterPath,
    required this.items,
  });

  factory UserList.fromJson(Map<String, dynamic> json) {
    return UserList(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      itemCount: json['item_count'] ?? 0,
      language: json['iso_639_1'] ?? 'en',
      listType: json['list_type'] ?? 'movie',
      posterPath: json['poster_path'],
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => ListItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'item_count': itemCount,
      'iso_639_1': language,
      'list_type': listType,
      'poster_path': posterPath,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 1)
class ListItem {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? posterPath;
  @HiveField(3)
  final String? backdropPath;
  @HiveField(4)
  final double voteAverage;
  @HiveField(5)
  final String? releaseDate;
  @HiveField(6)
  final String? firstAirDate;
  @HiveField(7)
  final String mediaType;
  @HiveField(8)
  final String? overview;
  @HiveField(9)
  final String? name; // For TV shows

  const ListItem({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    this.releaseDate,
    this.firstAirDate,
    required this.mediaType,
    this.overview,
    this.name,
  });

  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      releaseDate: json['release_date'],
      firstAirDate: json['first_air_date'],
      mediaType: json['media_type'] ?? 'movie',
      overview: json['overview'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'release_date': releaseDate,
      'first_air_date': firstAirDate,
      'media_type': mediaType,
      'overview': overview,
      'name': name,
    };
  }
}

class LibraryState {
  final List<UserList> customLists;
  final List<ListItem> watchlist;
  final List<ListItem> favorites;
  final bool isLoading;
  final String? error;

  const LibraryState({
    this.customLists = const [],
    this.watchlist = const [],
    this.favorites = const [],
    this.isLoading = false,
    this.error,
  });

  LibraryState copyWith({
    List<UserList>? customLists,
    List<ListItem>? watchlist,
    List<ListItem>? favorites,
    bool? isLoading,
    String? error,
  }) {
    return LibraryState(
      customLists: customLists ?? this.customLists,
      watchlist: watchlist ?? this.watchlist,
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CreateListRequest {
  final String name;
  final String description;
  final bool isPublic;

  const CreateListRequest({
    required this.name,
    required this.description,
    this.isPublic = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'public': isPublic,
    };
  }
}

extension ListItemExtensions on ListItem {
  String get displayTitle => title.isNotEmpty ? title : (name ?? 'Unknown');
  
  String get displayDate {
    final date = releaseDate?.isNotEmpty == true ? releaseDate : firstAirDate;
    if (date?.isNotEmpty == true) {
      try {
        final parsedDate = DateTime.parse(date!);
        return '${parsedDate.year}';
      } catch (e) {
        return '';
      }
    }
    return '';
  }
  
  String get fullPosterPath => posterPath != null 
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';
      
  String get fullBackdropPath => backdropPath != null 
      ? 'https://image.tmdb.org/t/p/w1280$backdropPath'
      : '';
      
  String get ratingText => voteAverage > 0 ? voteAverage.toStringAsFixed(1) : 'N/A';
}
