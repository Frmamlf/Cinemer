import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/animated_splash_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/theme_showcase_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/movies/movie_list_screen.dart';
import '../../features/movies/movie_detail_screen.dart';
import '../../features/tv_shows/tv_show_list_screen.dart';
import '../../features/tv_shows/tv_show_detail_screen.dart';
import '../../features/anime/anime_list_screen.dart';
import '../../features/anime/anime_detail_screen.dart';
import '../../features/downloads/download_manager_screen.dart';
import '../../features/search/search_screen.dart';
import '../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoginPage = state.uri.toString() == '/login';
      final isSplashPage = state.uri.toString() == '/splash';
      
      // Allow splash screen to show first
      if (isSplashPage) {
        return null;
      }
      
      // If not authenticated and not on login page, redirect to login
      if (!isAuthenticated && !isLoginPage) {
        return '/login';
      }
      
      // If authenticated and on login page, redirect to home
      if (isAuthenticated && isLoginPage) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const AnimatedSplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/showcase',
        builder: (context, state) => const ThemeShowcaseScreen(),
      ),
      GoRoute(
        path: '/movies',
        builder: (context, state) {
          final category = state.uri.queryParameters['category'] ?? 'popular';
          return MovieListScreen(category: category);
        },
      ),
      GoRoute(
        path: '/movie/:id',
        builder: (context, state) {
          final movieId = int.parse(state.pathParameters['id']!);
          return MovieDetailScreen(movieId: movieId);
        },
      ),
      GoRoute(
        path: '/tv-shows',
        builder: (context, state) {
          final category = state.uri.queryParameters['category'] ?? 'popular';
          return TVShowListScreen(category: category);
        },
      ),
      GoRoute(
        path: '/tv-show/:id',
        builder: (context, state) {
          final tvShowId = int.parse(state.pathParameters['id']!);
          return TVShowDetailScreen(tvShowId: tvShowId);
        },
      ),
      GoRoute(
        path: '/anime',
        builder: (context, state) {
          final category = state.uri.queryParameters['category'] ?? 'popular';
          return AnimeListScreen(category: category);
        },
      ),
      GoRoute(
        path: '/anime/:id',
        builder: (context, state) {
          final animeId = int.parse(state.pathParameters['id']!);
          final mediaType = state.uri.queryParameters['mediaType'] ?? 'movie';
          return AnimeDetailScreen(animeId: animeId, mediaType: mediaType);
        },
      ),
      GoRoute(
        path: '/downloads',
        builder: (context, state) => const DownloadManagerScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
    ],
  );
});
