import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/auth_models.dart';
import '../services/auth_api_service.dart';

// Auth state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final AuthSession? session;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.session,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    AuthSession? session,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      session: session ?? this.session,
      error: error,
    );
  }
}

// Auth provider
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApiService _apiService;
  static const String _sessionKey = 'auth_session';

  AuthNotifier(this._apiService) : super(const AuthState()) {
    _loadSavedSession();
  }

  Future<void> _loadSavedSession() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_sessionKey);
      
      if (sessionJson != null) {
        final sessionMap = jsonDecode(sessionJson);
        final session = AuthSession.fromJson(sessionMap);
        
        // Verify session is still valid
        await _apiService.getCurrentUser(
          apiKey: session.apiKey,
          sessionId: session.sessionId,
        );
        
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          session: session,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      // Session is invalid, clear it
      await _clearSession();
      state = state.copyWith(
        isLoading: false,
        error: 'Session expired',
      );
    }
  }

  Future<bool> validateApiKey(String apiKey) async {
    try {
      return await _apiService.validateApiKey(apiKey);
    } catch (e) {
      return false;
    }
  }

  Future<void> login({
    String? username,
    String? email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final session = await _apiService.login(
        username: username,
        email: email,
        password: password,
      );

      // Save session
      await _saveSession(session);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        session: session,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loginAsGuest() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final session = await _apiService.createGuestSession();

      // Save session
      await _saveSession(session);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        session: session,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      if (state.session != null) {
        await _apiService.logout(sessionId: state.session!.sessionId);
      }
    } catch (e) {
      // Ignore logout errors
    }

    await _clearSession();
    state = const AuthState();
  }

  Future<void> _saveSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(authApiServiceProvider);
  return AuthNotifier(apiService);
});

// Convenience providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<TMDBUser?>((ref) {
  return ref.watch(authProvider).session?.user;
});

final userApiKeyProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).session?.apiKey;
});

final isGuestSessionProvider = Provider<bool>((ref) {
  final session = ref.watch(authProvider).session;
  return session?.sessionId.startsWith('guest_session_') ?? false;
});
