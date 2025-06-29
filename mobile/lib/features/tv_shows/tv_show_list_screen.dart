import 'package:flutter/material.dart';
import '../../core/widgets/animated_material_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/content_providers.dart';
import '../../core/models/tv_show_models.dart';

class TVShowListScreen extends ConsumerStatefulWidget {
  final String category;

  const TVShowListScreen({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<TVShowListScreen> createState() => _TVShowListScreenState();
}

class _TVShowListScreenState extends ConsumerState<TVShowListScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  List<TVShow> _allTVShows = [];
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
      _loadMoreTVShows();
    }
  }

  void _loadMoreTVShows() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final newTVShows = await _getTVShowsForCategory(_currentPage);
      setState(() {
        _allTVShows.addAll(newTVShows.results);
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _currentPage--;
        _isLoadingMore = false;
      });
    }
  }

  Future<TVShowResponse> _getTVShowsForCategory(int page) async {
    final apiService = ref.read(apiServiceProvider);
    switch (widget.category) {
      case 'popular':
        return apiService.getPopularTVShows(page: page);
      case 'top-rated':
        return apiService.getTopRatedTVShows(page: page);
      case 'on-the-air':
        return apiService.getOnTheAirTVShows(page: page);
      case 'airing-today':
        return apiService.getAiringTodayTVShows(page: page);
      default:
        return apiService.getPopularTVShows(page: page);
    }
  }

  String get _categoryTitle {
    switch (widget.category) {
      case 'popular':
        return 'Popular TV Shows';
      case 'top-rated':
        return 'Top Rated TV Shows';
      case 'on-the-air':
        return 'On The Air';
      case 'airing-today':
        return 'Airing Today';
      default:
        return 'TV Shows';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tvShowsAsync = ref.watch(_getProviderForCategory(1));

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
      body: tvShowsAsync.when(
        loading: () => _buildLoadingGrid(),
        error: (error, stack) => _buildErrorWidget(error),
        data: (response) {
          if (_allTVShows.isEmpty) {
            _allTVShows = response.results;
          }
          return _buildTVShowGrid();
        },
      ),
    );
  }

  FutureProvider<TVShowResponse> _getProviderForCategory(int page) {
    switch (widget.category) {
      case 'popular':
        return popularTVShowsProvider(page);
      case 'top-rated':
        return topRatedTVShowsProvider(page);
      case 'on-the-air':
        return onTheAirTVShowsProvider(page);
      case 'airing-today':
        return airingTodayTVShowsProvider(page);
      default:
        return popularTVShowsProvider(page);
    }
  }

  Widget _buildTVShowGrid() {
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
              if (index < _allTVShows.length) {
                return _buildTVShowCard(_allTVShows[index]);
              } else if (_isLoadingMore) {
                return _buildLoadingCard();
              }
              return const SizedBox.shrink();
            },
            childCount: _allTVShows.length + (_isLoadingMore ? 2 : 0),
          ),
        ),
      ],
    );
  }

  Widget _buildTVShowCard(TVShow tvShow) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/tv-show/${tvShow.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Image
            AspectRatio(
              aspectRatio: 2 / 3,
              child: tvShow.fullPosterPath.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: tvShow.fullPosterPath,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildImagePlaceholder(),
                      errorWidget: (context, url, error) => _buildImageError(),
                    )
                  : _buildImageError(),
            ),
            // TV Show Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tvShow.name,
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
                        tvShow.ratingText,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Text(
                        tvShow.formattedFirstAirDate,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (tvShow.overview.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      tvShow.overview,
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
          Icons.tv,
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
              'Failed to load TV shows',
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
                  _allTVShows.clear();
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
