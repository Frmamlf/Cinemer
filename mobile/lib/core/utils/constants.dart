class AppConstants {
  static const String appName = 'Cinemer';
  
  // API Configuration
  static const String _devApiUrl = 'http://localhost:3000/api';
  static const String _prodApiUrl = 'https://your-production-api.com/api'; // Update with your production URL
  
  static String get apiBaseUrl {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? _prodApiUrl : _devApiUrl;
  }
  
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
}
