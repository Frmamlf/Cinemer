import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/content_providers.dart';
import '../../core/models/movie_models.dart';
import '../../core/widgets/animated_material_icon.dart';

class MovieListScreen extends ConsumerStatefulWidget {
  final String category;

  const MovieListScreen({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends ConsumerState<MovieListScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  List<Movie> _allMovies = [];
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreMovies();
    }
  }

  void _loadMoreMovies() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final newMovies = await _getMoviesForCategory(_currentPage);
      setState(() {
        _allMovies.addAll(newMovies.results);
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _currentPage--;
        _isLoadingMore = false;
      });
    }
  }

  Future<MovieResponse> _getMoviesForCategory(int page) async {
    final apiService = ref.read(apiServiceProvider);
    switch (widget.category) {
      case 'popular':
        return apiService.getPopularMovies(page: page);
      case 'top-rated':
        return apiService.getTopRatedMovies(page: page);
      case 'upcoming':
        return apiService.getUpcomingMovies(page: page);
      case 'now-playing':
        return apiService.getNowPlayingMovies(page: page);
      default:
        return apiService.getPopularMovies(page: page);
    }
  }

  String get _categoryTitle {
    switch (widget.category) {
      case 'popular':
        return 'Popular Movies';
      case 'top-rated':
        return 'Top Rated Movies';
      case 'upcoming':
        return 'Upcoming Movies';
      case 'now-playing':
        return 'Now Playing Movies';
      default:
        return 'Movies';
    }
  }

  @override
  Widget build(BuildContext context) {
    final moviesAsync = ref.watch(_getProviderForCategory(1));

    return Scaffold(
      appBar: AppBar(
        title: Text(_categoryTitle),
        actions: [
          IconButton(
            onPressed: () => context.go('/search'),
            icon: const AnimatedMaterialIcon(
              outlineIcon: MaterialSymbols.search,
              filledIcon: MaterialSymbols.searchFilled,
              isFilled: false,
            ),
          ),
        ],
      ),
      body: moviesAsync.when(
        loading: () => _buildLoadingGrid(),
        error: (error, stack) => _buildErrorWidget(error),
        data: (response) {
          if (_allMovies.isEmpty) {
            _allMovies = response.results;
          }
          return _buildMovieGrid();
        },
      ),
    );
  }

  FutureProvider<MovieResponse> _getProviderForCategory(int page) {
    switch (widget.category) {
      case 'popular':
        return popularMoviesProvider(page);
      case 'top-rated':
        return topRatedMoviesProvider(page);
      case 'upcoming':
        return upcomingMoviesProvider(page);
      case 'now-playing':
        return nowPlayingMoviesProvider(page);
      default:
        return popularMoviesProvider(page);
    }
  }

  Widget _buildMovieGrid() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            itemBuilder: (context, index) {
              if (index < _allMovies.length) {
                return _buildMovieCard(_allMovies[index]);
              } else if (_isLoadingMore) {
                return _buildLoadingCard();
              }
              return const SizedBox.shrink();
            },
            childCount: _allMovies.length + (_isLoadingMore ? 2 : 0),
          ),
        ),
      ],
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/movie/${movie.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Image
            AspectRatio(
              aspectRatio: 2 / 3,
              child: movie.fullPosterPath.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: movie.fullPosterPath,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildImagePlaceholder(),
                      errorWidget: (context, url, error) => _buildImageError(),
                    )
                  : _buildImageError(),
            ),
            // Movie Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        movie.ratingText,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Text(
                        movie.formattedReleaseDate,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (movie.overview.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      movie.overview,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: 10,
        itemBuilder: (context, index) => _buildLoadingCard(),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Container(
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 100,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        color: Colors.white,
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.movie,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load movies',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(_getProviderForCategory(1));
                setState(() {
                  _allMovies.clear();
                  _currentPage = 1;
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
