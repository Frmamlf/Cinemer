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
  static String get baseUrl => AppConstants.apiBaseUrl;
  
  Future<bool> validateApiKey(String apiKey) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/validate-api-key'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'apiKey': apiKey,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['valid'] == true;
      } else {
        return false;
      }
    } catch (e) {
      throw ApiException('Failed to validate API key: $e');
    }
  }

  Future<AuthSession> login({
    String? username,
    String? email,
    required String password,
  }) async {
    try {
      // Support both username and email
      final loginIdentifier = username ?? email;
      if (loginIdentifier == null) {
        throw ApiException('Username or email is required');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (username != null) 'username': username,
          if (email != null) 'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          return AuthSession.fromJson(data);
        } else {
          throw ApiException(data['error'] ?? 'Login failed');
        }
      } else {
        throw ApiException(
          data['error'] ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<TMDBUser> getCurrentUser({
    required String apiKey,
    required String sessionId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/user'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'X-Session-ID': sessionId,
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return TMDBUser.fromJson(data['user']);
      } else {
        throw ApiException(
          data['error'] ?? 'Failed to get user data',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      // Logout failure is not critical, just log it
      debugPrint('Logout request failed: $e');
    }
  }
}
