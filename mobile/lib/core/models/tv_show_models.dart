class TVShow {
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String firstAirDate;
  final double voteAverage;
  final int voteCount;
  final List<int> genreIds;
  final List<String> originCountry;
  final String originalLanguage;
  final String originalName;
  final double popularity;

  TVShow({
    required this.id,
    required this.name,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.firstAirDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genreIds,
    required this.originCountry,
    required this.originalLanguage,
    required this.originalName,
    required this.popularity,
  });

  factory TVShow.fromJson(Map<String, dynamic> json) {
    return TVShow(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      firstAirDate: json['first_air_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      originCountry: List<String>.from(json['origin_country'] ?? []),
      originalLanguage: json['original_language'] ?? '',
      originalName: json['original_name'] ?? '',
      popularity: (json['popularity'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'first_air_date': firstAirDate,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'genre_ids': genreIds,
      'origin_country': originCountry,
      'original_language': originalLanguage,
      'original_name': originalName,
      'popularity': popularity,
    };
  }

  String get fullPosterPath =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';

  String get fullBackdropPath =>
      backdropPath != null ? 'https://image.tmdb.org/t/p/w1280$backdropPath' : '';

  String get formattedFirstAirDate {
    if (firstAirDate.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(firstAirDate);
      return '${date.year}';
    } catch (e) {
      return firstAirDate;
    }
  }

  String get ratingText => '${voteAverage.toStringAsFixed(1)}/10';
}

class TVShowResponse {
  final int page;
  final List<TVShow> results;
  final int totalPages;
  final int totalResults;

  TVShowResponse({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory TVShowResponse.fromJson(Map<String, dynamic> json) {
    return TVShowResponse(
      page: json['page'] ?? 1,
      results: (json['results'] as List? ?? [])
          .map((tvShow) => TVShow.fromJson(tvShow))
          .toList(),
      totalPages: json['total_pages'] ?? 0,
      totalResults: json['total_results'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'results': results.map((tvShow) => tvShow.toJson()).toList(),
      'total_pages': totalPages,
      'total_results': totalResults,
    };
  }
}

class TVShowDetails extends TVShow {
  final List<Genre> genres;
  final String? homepage;
  final bool inProduction;
  final List<String> languages;
  final String? lastAirDate;
  final int numberOfEpisodes;
  final int numberOfSeasons;
  final List<ProductionCompany> productionCompanies;
  final String status;
  final String? tagline;
  final String type;
  final List<int> episodeRunTime;

  TVShowDetails({
    required super.id,
    required super.name,
    required super.overview,
    super.posterPath,
    super.backdropPath,
    required super.firstAirDate,
    required super.voteAverage,
    required super.voteCount,
    required super.genreIds,
    required super.originCountry,
    required super.originalLanguage,
    required super.originalName,
    required super.popularity,
    required this.genres,
    this.homepage,
    required this.inProduction,
    required this.languages,
    this.lastAirDate,
    required this.numberOfEpisodes,
    required this.numberOfSeasons,
    required this.productionCompanies,
    required this.status,
    this.tagline,
    required this.type,
    required this.episodeRunTime,
  });

  factory TVShowDetails.fromJson(Map<String, dynamic> json) {
    return TVShowDetails(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      firstAirDate: json['first_air_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      originCountry: List<String>.from(json['origin_country'] ?? []),
      originalLanguage: json['original_language'] ?? '',
      originalName: json['original_name'] ?? '',
      popularity: (json['popularity'] ?? 0).toDouble(),
      genres: (json['genres'] as List<dynamic>?)
              ?.map((genre) => Genre.fromJson(genre))
              .toList() ??
          [],
      homepage: json['homepage'],
      inProduction: json['in_production'] ?? false,
      languages: List<String>.from(json['languages'] ?? []),
      lastAirDate: json['last_air_date'],
      numberOfEpisodes: json['number_of_episodes'] ?? 0,
      numberOfSeasons: json['number_of_seasons'] ?? 0,
      productionCompanies: (json['production_companies'] as List<dynamic>?)
              ?.map((company) => ProductionCompany.fromJson(company))
              .toList() ??
          [],
      status: json['status'] ?? '',
      tagline: json['tagline'],
      type: json['type'] ?? '',
      episodeRunTime: List<int>.from(json['episode_run_time'] ?? []),
    );
  }

  String get genreText {
    return genres.map((genre) => genre.name).join(', ');
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class ProductionCompany {
  final int id;
  final String? logoPath;
  final String name;
  final String originCountry;

  ProductionCompany({
    required this.id,
    this.logoPath,
    required this.name,
    required this.originCountry,
  });

  factory ProductionCompany.fromJson(Map<String, dynamic> json) {
    return ProductionCompany(
      id: json['id'] ?? 0,
      logoPath: json['logo_path'],
      name: json['name'] ?? '',
      originCountry: json['origin_country'] ?? '',
    );
  }
}
