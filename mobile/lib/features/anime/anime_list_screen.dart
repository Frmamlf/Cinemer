import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/content_providers.dart';
import '../../core/models/movie_models.dart';
import '../../core/models/tv_show_models.dart';
import '../../core/widgets/animated_material_icon.dart';

class AnimeListScreen extends ConsumerStatefulWidget {
  final String category;

  const AnimeListScreen({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<AnimeListScreen> createState() => _AnimeListScreenState();
}

class _AnimeListScreenState extends ConsumerState<AnimeListScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  List<dynamic> _allAnime = [];
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
      _loadMoreAnime();
    }
  }

  void _loadMoreAnime() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final newAnime = await _getAnimeForCategory(_currentPage);
      setState(() {
        if (newAnime is MovieResponse) {
          _allAnime.addAll(newAnime.results);
        } else if (newAnime is TVShowResponse) {
          _allAnime.addAll(newAnime.results);
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _currentPage--;
        _isLoadingMore = false;
      });
    }
  }

  Future<dynamic> _getAnimeForCategory(int page) async {
    final apiService = ref.read(apiServiceProvider);
    switch (widget.category) {
      case 'movies':
        return apiService.getAnimeMovies(page: page);
      case 'tv-shows':
        return apiService.getAnimeTVShows(page: page);
      case 'popular':
      default:
        return apiService.getPopularAnime(page: page);
    }
  }

  String get _categoryTitle {
    switch (widget.category) {
      case 'movies':
        return 'Anime Movies';
      case 'tv-shows':
        return 'Anime TV Shows';
      case 'popular':
        return 'Popular Anime';
      default:
        return 'Anime';
    }
  }

  @override
  Widget build(BuildContext context) {
    final animeAsync = ref.watch(_getProviderForCategory(1));

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
      body: animeAsync.when(
        loading: () => _buildLoadingGrid(),
        error: (error, stack) => _buildErrorWidget(error),
        data: (response) {
          if (_allAnime.isEmpty) {
            if (response is MovieResponse) {
              _allAnime = response.results;
            } else if (response is TVShowResponse) {
              _allAnime = response.results;
            }
          }
          return _buildAnimeGrid();
        },
      ),
    );
  }

  FutureProvider<dynamic> _getProviderForCategory(int page) {
    switch (widget.category) {
      case 'movies':
        return animeMoviesProvider(page);
      case 'tv-shows':
        return animeTVShowsProvider(page);
      case 'popular':
      default:
        return popularAnimeProvider(page);
    }
  }

  Widget _buildAnimeGrid() {
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
              if (index < _allAnime.length) {
                return _buildAnimeCard(_allAnime[index]);
              } else if (_isLoadingMore) {
                return _buildLoadingCard();
              }
              return const SizedBox.shrink();
            },
            childCount: _allAnime.length + (_isLoadingMore ? 2 : 0),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimeCard(dynamic anime) {
    final String title = anime is Movie ? anime.title : (anime as TVShow).name;
    final String posterPath = anime is Movie ? anime.fullPosterPath : (anime as TVShow).fullPosterPath;
    final String overview = anime.overview;
    final String rating = anime is Movie ? anime.ratingText : (anime as TVShow).ratingText;
    final String date = anime is Movie ? anime.formattedReleaseDate : (anime as TVShow).formattedFirstAirDate;
    final int id = anime.id;
    final String routePath = anime is Movie ? '/movie/$id' : '/tv-show/$id';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(routePath),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Image
            AspectRatio(
              aspectRatio: 2 / 3,
              child: posterPath.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: posterPath,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildImagePlaceholder(),
                      errorWidget: (context, url, error) => _buildImageError(),
                    )
                  : _buildImageError(),
            ),
            // Anime Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                        rating,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Text(
                        date,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (overview.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      overview,
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
          Icons.movie_outlined,
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
              'Failed to load anime',
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
                  _allAnime.clear();
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
