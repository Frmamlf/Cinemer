class TMDBUser {
  final int id;
  final String username;
  final String name;
  final bool includeAdult;
  final String iso6391;
  final String iso31661;
  final TMDBAvatars? avatar;

  TMDBUser({
    required this.id,
    required this.username,
    required this.name,
    required this.includeAdult,
    required this.iso6391,
    required this.iso31661,
    this.avatar,
  });

  factory TMDBUser.fromJson(Map<String, dynamic> json) {
    return TMDBUser(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      includeAdult: json['include_adult'] ?? false,
      iso6391: json['iso_639_1'] ?? '',
      iso31661: json['iso_3166_1'] ?? '',
      avatar: json['avatar'] != null ? TMDBAvatars.fromJson(json['avatar']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'include_adult': includeAdult,
      'iso_639_1': iso6391,
      'iso_3166_1': iso31661,
      'avatar': avatar?.toJson(),
    };
  }
}

class TMDBAvatars {
  final TMDBGravatar? gravatar;
  final TMDBAvatar? tmdb;

  TMDBAvatars({this.gravatar, this.tmdb});

  factory TMDBAvatars.fromJson(Map<String, dynamic> json) {
    return TMDBAvatars(
      gravatar: json['gravatar'] != null ? TMDBGravatar.fromJson(json['gravatar']) : null,
      tmdb: json['tmdb'] != null ? TMDBAvatar.fromJson(json['tmdb']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gravatar': gravatar?.toJson(),
      'tmdb': tmdb?.toJson(),
    };
  }
}

class TMDBGravatar {
  final String hash;

  TMDBGravatar({required this.hash});

  factory TMDBGravatar.fromJson(Map<String, dynamic> json) {
    return TMDBGravatar(hash: json['hash']);
  }

  Map<String, dynamic> toJson() {
    return {'hash': hash};
  }
}

class TMDBAvatar {
  final String? avatarPath;

  TMDBAvatar({this.avatarPath});

  factory TMDBAvatar.fromJson(Map<String, dynamic> json) {
    return TMDBAvatar(avatarPath: json['avatar_path']);
  }

  Map<String, dynamic> toJson() {
    return {'avatar_path': avatarPath};
  }
}

class AuthSession {
  final String sessionId;
  final String apiKey;
  final TMDBUser user;

  AuthSession({
    required this.sessionId,
    required this.apiKey,
    required this.user,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      sessionId: json['session']['sessionId'],
      apiKey: json['session']['apiKey'],
      user: TMDBUser.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session': {
        'sessionId': sessionId,
        'apiKey': apiKey,
      },
      'user': user.toJson(),
    };
  }
}
