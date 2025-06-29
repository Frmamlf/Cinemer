class Anime {
  final int id;
  final String title;
  final String name;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final String firstAirDate;
  final double voteAverage;
  final int voteCount;
  final List<int> genreIds;
  final String originalLanguage;
  final String originalTitle;
  final String originalName;
  final double popularity;
  final String mediaType; // 'movie' or 'tv'

  Anime({
    required this.id,
    required this.title,
    required this.name,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.firstAirDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genreIds,
    required this.originalLanguage,
    required this.originalTitle,
    required this.originalName,
    required this.popularity,
    required this.mediaType,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      name: json['name'] ?? json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'] ?? '',
      firstAirDate: json['first_air_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      originalLanguage: json['original_language'] ?? '',
      originalTitle: json['original_title'] ?? '',
      originalName: json['original_name'] ?? '',
      popularity: (json['popularity'] ?? 0).toDouble(),
      mediaType: json['media_type'] ?? 'movie',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'name': name,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'first_air_date': firstAirDate,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'genre_ids': genreIds,
      'original_language': originalLanguage,
      'original_title': originalTitle,
      'original_name': originalName,
      'popularity': popularity,
      'media_type': mediaType,
    };
  }

  String get fullPosterPath =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';

  String get fullBackdropPath =>
      backdropPath != null ? 'https://image.tmdb.org/t/p/w1280$backdropPath' : '';

  String get displayTitle => title.isNotEmpty ? title : name;

  String get formattedDate {
    final date = releaseDate.isNotEmpty ? releaseDate : firstAirDate;
    if (date.isEmpty) return 'Unknown';
    try {
      final parsedDate = DateTime.parse(date);
      return '${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }

  String get ratingText => '${voteAverage.toStringAsFixed(1)}/10';

  bool get isMovie => mediaType == 'movie' || releaseDate.isNotEmpty;

  bool get isTVShow => mediaType == 'tv' || firstAirDate.isNotEmpty;
}

class AnimeResponse {
  final int page;
  final List<Anime> results;
  final int totalPages;
  final int totalResults;

  AnimeResponse({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory AnimeResponse.fromJson(Map<String, dynamic> json) {
    return AnimeResponse(
      page: json['page'] ?? 1,
      results: (json['results'] as List? ?? [])
          .map((anime) => Anime.fromJson(anime))
          .toList(),
      totalPages: json['total_pages'] ?? 0,
      totalResults: json['total_results'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'results': results.map((anime) => anime.toJson()).toList(),
      'total_pages': totalPages,
      'total_results': totalResults,
    };
  }
}
