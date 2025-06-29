import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/providers/content_providers.dart';
import '../../core/models/movie_models.dart';
import '../../core/models/library_models.dart';
import '../../core/widgets/trailer_button.dart';

class MovieDetailScreen extends ConsumerWidget {
  final int movieId;

  const MovieDetailScreen({
    super.key,
    required this.movieId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieAsync = ref.watch(movieDetailsProvider(movieId));
    final favorites = ref.watch(favoritesProvider);
    final favoritesNotifier = ref.read(favoritesProvider.notifier);

    return Scaffold(
      body: movieAsync.when(
        loading: () => _buildLoadingWidget(context),
        error: (error, stack) => _buildErrorWidget(context, error, ref),
        data: (movie) => _buildMovieDetail(context, movie, favorites, favoritesNotifier),
      ),
    );
  }

  Widget _buildMovieDetail(BuildContext context, Movie movie, Set<int> favorites, FavoritesNotifier favoritesNotifier) {
    final isFavorite = favorites.contains(movie.id);

    return CustomScrollView(
      slivers: [
        // App Bar with backdrop image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: movie.fullBackdropPath.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: movie.fullBackdropPath,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildImagePlaceholder(),
                    errorWidget: (context, url, error) => _buildImageError(),
                  )
                : _buildImageError(),
          ),
          actions: [
            IconButton(
              onPressed: () => favoritesNotifier.toggleFavorite(movie.id),
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
            ),
          ],
        ),
        
        // Movie content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and basic info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Poster
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 120,
                        height: 180,
                        child: movie.fullPosterPath.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: movie.fullPosterPath,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => _buildImagePlaceholder(),
                                errorWidget: (context, url, error) => _buildImageError(),
                              )
                            : _buildImageError(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title and info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (movie.originalTitle != movie.title) ...[
                            const SizedBox(height: 4),
                            Text(
                              movie.originalTitle,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          // Rating
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                movie.ratingText,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${movie.voteCount} votes)',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Release date
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                movie.formattedReleaseDate,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Language
                          Row(
                            children: [
                              Icon(
                                Icons.language,
                                size: 16,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                movie.originalLanguage.toUpperCase(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TrailerButton(
                        title: movie.title,
                        year: movie.releaseDate.isNotEmpty 
                          ? movie.releaseDate.substring(0, 4)
                          : DateTime.now().year.toString(),
                        type: 'movie',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final watchlist = ref.watch(watchlistProvider);
                          final isInWatchlist = watchlist.any((item) => item.id == movie.id);
                          
                          return OutlinedButton.icon(
                            onPressed: () async {
                              final watchlistNotifier = ref.read(watchlistProvider.notifier);
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              final listItem = ListItem(
                                id: movie.id,
                                title: movie.title,
                                posterPath: movie.posterPath,
                                backdropPath: movie.backdropPath,
                                voteAverage: movie.voteAverage,
                                releaseDate: movie.releaseDate,
                                mediaType: 'movie',
                                overview: movie.overview,
                                name: null,
                                firstAirDate: null,
                              );
                              
                              await watchlistNotifier.toggleWatchlist(listItem);
                              
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isInWatchlist 
                                        ? 'Removed from watchlist' 
                                        : 'Added to watchlist'
                                  ),
                                ),
                              );
                            },
                            icon: Icon(isInWatchlist ? Icons.check : Icons.add),
                            label: Text(isInWatchlist ? 'In Watchlist' : 'Watchlist'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Overview
                if (movie.overview.isNotEmpty) ...[
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.overview,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Additional info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Details',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow('Release Date', movie.releaseDate.isNotEmpty ? movie.releaseDate : 'Unknown'),
                        _buildDetailRow('Original Language', movie.originalLanguage.toUpperCase()),
                        _buildDetailRow('Popularity', movie.popularity.toStringAsFixed(1)),
                        _buildDetailRow('Adult Content', movie.adult ? 'Yes' : 'No'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(color: Colors.white),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(height: 24, color: Colors.white),
                            const SizedBox(height: 8),
                            Container(height: 16, width: 150, color: Colors.white),
                            const SizedBox(height: 8),
                            Container(height: 16, width: 100, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(height: 20, width: 100, color: Colors.white),
                  const SizedBox(height: 8),
                  ...List.generate(3, (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(height: 16, color: Colors.white),
                  )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(BuildContext context, Object error, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
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
                'Failed to load movie details',
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
                onPressed: () => ref.invalidate(movieDetailsProvider(movieId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(color: Colors.white),
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
}
