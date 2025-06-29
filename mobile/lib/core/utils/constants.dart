class AppConstants {
  static const String appName = 'Cinemer';
  
  // TMDB API Configuration
  static const String tmdbApiKey = '8e9c7e67d47a5eb566632d281ffbcfe1'; // TMDB API key
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  
  // Backend API Configuration (not used - using TMDB directly)
  static const String backendBaseUrl = 'http://localhost:3000/api';
  
  static String get apiBaseUrl {
    return tmdbBaseUrl; // Use TMDB API directly
  }
}
