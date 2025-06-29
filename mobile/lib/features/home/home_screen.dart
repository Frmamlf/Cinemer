import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/content_providers.dart';
import '../../core/widgets/expressive_movie_card.dart';
import '../../core/widgets/animated_material_icon.dart';
import '../../core/localization/app_localizations.dart';
import '../library/library_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  int _selectedContentType = 0; // 0: Trending, 1: Movies, 2: TV Shows

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(),
          const LibraryScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        // M3 Standard: Navigation bar styling
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
        shadowColor: Theme.of(context).colorScheme.shadow,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        elevation: 3, // M3 Standard: 3dp elevation for navigation bar
        height: 80, // M3 Standard: 80dp height
        destinations: [
          NavigationDestination(
            icon: AnimatedMaterialIcon(
              outlineIcon: MaterialSymbols.home,
              filledIcon: MaterialSymbols.homeFilled,
              isFilled: _selectedIndex == 0,
            ),
            label: AppLocalizations.of(context)?.home ?? 'Home',
          ),
          NavigationDestination(
            icon: AnimatedMaterialIcon(
              outlineIcon: MaterialSymbols.library,
              filledIcon: MaterialSymbols.libraryFilled,
              isFilled: _selectedIndex == 1,
            ),
            label: AppLocalizations.of(context)?.library ?? 'Library',
          ),
          NavigationDestination(
            icon: AnimatedMaterialIcon(
              outlineIcon: MaterialSymbols.person,
              filledIcon: MaterialSymbols.personFilled,
              isFilled: _selectedIndex == 2,
            ),
            label: AppLocalizations.of(context)?.profile ?? 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return CustomScrollView(
      slivers: [
        // M3 Standard: App Bar - Simplified
        SliverAppBar(
          pinned: true,
          title: Text(
            'Cinemer',
            style: GoogleFonts.rubik(
              fontWeight: FontWeight.w500, // M3 Standard: Medium weight
              fontSize: 22, // M3 Standard: 22sp for app bar titles
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => context.go('/search'),
              icon: const AnimatedMaterialIcon(
                outlineIcon: MaterialSymbols.search,
                filledIcon: MaterialSymbols.searchFilled,
                isFilled: false,
              ),
              style: IconButton.styleFrom(
                // M3 Standard: Icon button styling
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // M3 Standard: 20dp for icon buttons
                ),
                backgroundColor: Colors.transparent,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8), // M3 Standard: 8dp padding
          ],
          // M3 Standard: App bar colors
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          shadowColor: Theme.of(context).colorScheme.shadow,
          elevation: 0, // M3 Standard: 0dp elevation for pinned app bars
        ),
        
        // Floating Connected Button Group - Material 3 SegmentedButton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500, // M3 Standard: Medium weight
                  ),
                ),
                const SizedBox(height: 16),
                // M3 Standard: SegmentedButton component
                Center(
                  child: SegmentedButton<int>(
                    segments: [
                      ButtonSegment<int>(
                        value: 0,
                        label: Text(AppLocalizations.of(context)?.trending ?? 'Trending'),
                        icon: AnimatedMaterialIcon(
                          outlineIcon: MaterialSymbols.star,
                          filledIcon: MaterialSymbols.starFilled,
                          isFilled: _selectedContentType == 0,
                        ),
                      ),
                      ButtonSegment<int>(
                        value: 1,
                        label: Text(AppLocalizations.of(context)?.movies ?? 'Movies'),
                        icon: AnimatedMaterialIcon(
                          outlineIcon: MaterialSymbols.movie,
                          filledIcon: MaterialSymbols.movieFilled,
                          isFilled: _selectedContentType == 1,
                        ),
                      ),
                      ButtonSegment<int>(
                        value: 2,
                        label: Text(AppLocalizations.of(context)?.tvShows ?? 'TV Shows'),
                        icon: AnimatedMaterialIcon(
                          outlineIcon: MaterialSymbols.tv,
                          filledIcon: MaterialSymbols.tvFilled,
                          isFilled: _selectedContentType == 2,
                        ),
                      ),
                    ],
                    selected: {_selectedContentType},
                    onSelectionChanged: (Set<int> newSelection) {
                      setState(() {
                        _selectedContentType = newSelection.first;
                      });
                    },
                    // M3 Standard: Apply proper styling
                    style: SegmentedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      selectedBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      selectedForegroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // M3 Standard: 20dp for full height
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Content based on selected type
        _buildSelectedContent(),
      ],
    );
  }

  Widget _buildSelectedContent() {
    switch (_selectedContentType) {
      case 0: // Trending
        return _buildTrendingContent();
      case 1: // Movies
        return _buildMoviesContent();
      case 2: // TV Shows
        return _buildTVShowsContent();
      default:
        return _buildTrendingContent();
    }
  }

  Widget _buildTrendingContent() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Trending Now',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: Consumer(
                builder: (context, ref, child) {
                  final popularMovies = ref.watch(popularMoviesProvider(1));
                  return popularMovies.when(
                    loading: () => _buildHorizontalLoading(),
                    error: (error, stack) => _buildErrorWidget(error),
                    data: (response) => _buildHorizontalMovieList(response.results),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Popular TV Shows',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: Consumer(
                builder: (context, ref, child) {
                  final popularTVShows = ref.watch(popularTVShowsProvider(1));
                  return popularTVShows.when(
                    loading: () => _buildHorizontalLoading(),
                    error: (error, stack) => _buildErrorWidget(error),
                    data: (response) => _buildHorizontalTVShowList(response.results),
                  );
                },
              ),
            ),
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildMoviesContent() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildSectionCard('Popular Movies', popularMoviesProvider(1), true),
            const SizedBox(height: 24),
            _buildSectionCard('Top Rated Movies', topRatedMoviesProvider(1), true),
            const SizedBox(height: 24),
            _buildSectionCard('Upcoming Movies', upcomingMoviesProvider(1), true),
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildTVShowsContent() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildSectionCard('Popular TV Shows', popularTVShowsProvider(1), false),
            const SizedBox(height: 24),
            _buildSectionCard('Top Rated TV Shows', topRatedTVShowsProvider(1), false),
            const SizedBox(height: 24),
            _buildSectionCard('On The Air', onTheAirTVShowsProvider(1), false),
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, provider, bool isMovie) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full list
                    if (isMovie) {
                      context.go('/movies?category=${_getCategoryFromTitle(title)}');
                    } else {
                      context.go('/tv-shows?category=${_getCategoryFromTitle(title)}');
                    }
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: Consumer(
                builder: (context, ref, child) {
                  final content = ref.watch(provider);
                  return content.when(
                    loading: () => _buildHorizontalLoading(),
                    error: (error, stack) => _buildErrorWidget(error),
                    data: (response) => isMovie 
                        ? _buildHorizontalMovieList(response.results)
                        : _buildHorizontalTVShowList(response.results),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryFromTitle(String title) {
    if (title.contains('Popular')) return 'popular';
    if (title.contains('Top Rated')) return 'top-rated';
    if (title.contains('Upcoming')) return 'upcoming';
    if (title.contains('On The Air')) return 'on-the-air';
    return 'popular';
  }

  Widget _buildHorizontalMovieList(List<dynamic> movies) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return _buildMovieCard(movie);
      },
    );
  }

  Widget _buildHorizontalTVShowList(List<dynamic> tvShows) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: tvShows.length,
      itemBuilder: (context, index) {
        final tvShow = tvShows[index];
        return _buildTVShowCard(tvShow);
      },
    );
  }

  Widget _buildMovieCard(dynamic movie) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: ExpressiveMovieCard(
        title: movie.title ?? '',
        imageUrl: movie.fullPosterPath ?? '',
        subtitle: movie.releaseDate ?? '',
        rating: movie.voteAverage,
        width: 160,
        height: 280,
        onTap: () => context.go('/movie/${movie.id}'),
      ),
    );
  }

  Widget _buildTVShowCard(dynamic tvShow) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: ExpressiveMovieCard(
        title: tvShow.name ?? tvShow.title ?? '',
        imageUrl: tvShow.fullPosterPath ?? '',
        subtitle: tvShow.firstAirDate ?? tvShow.releaseDate ?? '',
        rating: tvShow.voteAverage,
        width: 160,
        height: 280,
        onTap: () => context.go('/tv-show/${tvShow.id}'),
      ),
    );
  }

  Widget _buildHorizontalLoading() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(right: 16),
          child: const ExpressiveMovieCard(
            title: '',
            imageUrl: '',
            width: 160,
            height: 280,
            isLoading: true,
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: ${error.toString()}',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
