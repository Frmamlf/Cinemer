import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import 'auth_api_service.dart';

/// Helper service for TMDB authentication that provides easy methods
/// for both guest sessions and full user authentication
class TMDBAuthHelper {
  static const String _sessionKey = 'tmdb_session';
  static const String _userKey = 'tmdb_user';
  
  final AuthApiService _authService = AuthApiService();
  
  /// Login with TMDB username and password
  /// Returns an authenticated session with user account access
  Future<AuthSession> loginWithCredentials({
    required String username,
    required String password,
  }) async {
    try {
      final session = await _authService.login(
        username: username,
        password: password,
      );
      
      // Save session locally
      await _saveSession(session);
      
      return session;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  /// Create a guest session (no credentials required)
  /// Guest sessions have limited access but don't require a TMDB account
  Future<AuthSession> loginAsGuest() async {
    try {
      final session = await _authService.createGuestSession();
      
      // Save session locally
      await _saveSession(session);
      
      return session;
    } catch (e) {
      throw Exception('Guest login failed: $e');
    }
  }
  
  /// Check if user is currently logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_sessionKey);
  }
  
  /// Get current session if exists
  Future<AuthSession?> getCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = prefs.getString(_sessionKey);
    final userData = prefs.getString(_userKey);
    
    if (sessionData != null && userData != null) {
      try {
        final sessionJson = jsonDecode(sessionData);
        final userJson = jsonDecode(userData);
        
        return AuthSession(
          sessionId: sessionJson['sessionId'],
          apiKey: sessionJson['apiKey'],
          user: TMDBUser.fromJson(userJson),
        );
      } catch (e) {
        debugPrint('Error loading saved session: $e');
        await logout(); // Clear corrupted data
        return null;
      }
    }
    
    return null;
  }
  
  /// Check if current session is a guest session
  Future<bool> isGuestSession() async {
    final session = await getCurrentSession();
    return session?.sessionId.startsWith('guest_session_') ?? false;
  }
  
  /// Logout and clear session data
  Future<void> logout() async {
    final session = await getCurrentSession();
    
    if (session != null) {
      try {
        await _authService.logout(sessionId: session.sessionId);
      } catch (e) {
        debugPrint('Error during logout: $e');
      }
    }
    
    // Clear local data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_userKey);
  }
  
  /// Refresh user data (for authenticated sessions)
  Future<AuthSession?> refreshUserData() async {
    final session = await getCurrentSession();
    
    if (session == null || session.sessionId.startsWith('guest_session_')) {
      return session; // Can't refresh guest sessions or no session
    }
    
    try {
      final updatedUser = await _authService.getCurrentUser(
        apiKey: session.apiKey,
        sessionId: session.sessionId,
      );
      
      final updatedSession = AuthSession(
        sessionId: session.sessionId,
        apiKey: session.apiKey,
        user: updatedUser,
      );
      
      await _saveSession(updatedSession);
      return updatedSession;
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
      return session; // Return original session if refresh fails
    }
  }
  
  /// Validate current API key
  Future<bool> validateApiKey() async {
    try {
      return await _authService.validateApiKey(AuthApiService.apiKey);
    } catch (e) {
      return false;
    }
  }
  
  /// Save session data locally
  Future<void> _saveSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    
    final sessionData = {
      'sessionId': session.sessionId,
      'apiKey': session.apiKey,
    };
    
    await prefs.setString(_sessionKey, jsonEncode(sessionData));
    await prefs.setString(_userKey, jsonEncode(session.user.toJson()));
  }
}
