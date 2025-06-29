import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import '../utils/constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}

class AuthApiService {
  static String get baseUrl => AppConstants.tmdbBaseUrl;
  static String get apiKey => AppConstants.tmdbApiKey;
  
  /// Validates TMDB API key by making a test request
  Future<bool> validateApiKey(String testApiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/configuration?api_key=$testApiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw ApiException('Failed to validate API key: $e');
    }
  }

  /// Creates a new guest session (no login required)
  Future<AuthSession> createGuestSession() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/authentication/guest_session/new?api_key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Create a guest user
        final guestUser = TMDBUser(
          id: 0,
          username: 'Guest',
          name: 'Guest User',
          includeAdult: false,
          iso6391: 'en',
          iso31661: 'US',
        );

        return AuthSession(
          sessionId: data['guest_session_id'],
          apiKey: apiKey,
          user: guestUser,
        );
      } else {
        throw ApiException(data['status_message'] ?? 'Failed to create guest session');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Creates a new request token for TMDB authentication
  Future<String> createRequestToken() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/authentication/token/new?api_key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['request_token'];
      } else {
        throw ApiException(data['status_message'] ?? 'Failed to create request token');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Validates request token with user credentials
  Future<String> validateTokenWithLogin({
    required String requestToken,
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/authentication/token/validate_with_login?api_key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'request_token': requestToken,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['request_token'];
      } else {
        throw ApiException(data['status_message'] ?? 'Invalid credentials');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Creates a session from validated request token
  Future<String> createSessionFromToken(String validatedToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/authentication/session/new?api_key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'request_token': validatedToken,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['session_id'];
      } else {
        throw ApiException(data['status_message'] ?? 'Failed to create session');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Full TMDB user authentication
  Future<AuthSession> login({
    String? username,
    String? email,
    required String password,
  }) async {
    if (username == null || username.isEmpty) {
      throw ApiException('Username is required for TMDB authentication');
    }

    try {
      // Step 1: Create request token
      final requestToken = await createRequestToken();
      
      // Step 2: Validate token with user credentials
      final validatedToken = await validateTokenWithLogin(
        requestToken: requestToken,
        username: username,
        password: password,
      );
      
      // Step 3: Create session from validated token
      final sessionId = await createSessionFromToken(validatedToken);
      
      // Step 4: Get user account details
      final user = await getAccountDetails(sessionId);
      
      return AuthSession(
        sessionId: sessionId,
        apiKey: apiKey,
        user: user,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Login failed: $e');
    }
  }

  /// Gets account details for authenticated user
  Future<TMDBUser> getAccountDetails(String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/account?api_key=$apiKey&session_id=$sessionId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return TMDBUser(
          id: data['id'],
          username: data['username'] ?? data['name'] ?? 'User',
          name: data['name'] ?? data['username'] ?? 'User',
          includeAdult: data['include_adult'] ?? false,
          iso6391: data['iso_639_1'] ?? 'en',
          iso31661: data['iso_3166_1'] ?? 'US',
          avatar: data['avatar'] != null ? TMDBAvatars.fromJson(data['avatar']) : null,
        );
      } else {
        throw ApiException(data['status_message'] ?? 'Failed to get account details');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Gets current user info
  Future<TMDBUser> getCurrentUser({
    required String apiKey,
    required String sessionId,
  }) async {
    try {
      // Check if this is a guest session (starts with 'guest_session_')
      if (sessionId.startsWith('guest_session_')) {
        return TMDBUser(
          id: 0,
          username: 'Guest',
          name: 'Guest User',
          includeAdult: false,
          iso6391: 'en',
          iso31661: 'US',
        );
      } else {
        // This is an authenticated session, get real account details
        return await getAccountDetails(sessionId);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<void> logout({String? sessionId}) async {
    if (sessionId != null && !sessionId.startsWith('guest_session_')) {
      // Delete authenticated session
      try {
        await http.delete(
          Uri.parse('$baseUrl/authentication/session?api_key=$apiKey'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'session_id': sessionId,
          }),
        );
      } catch (e) {
        debugPrint('Error deleting session: $e');
      }
    }
    
    debugPrint('Session ended');
  }
}
