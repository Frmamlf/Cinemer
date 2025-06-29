import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/providers/content_providers.dart';
import '../../core/models/tv_show_models.dart';
import '../../core/widgets/trailer_button.dart';

class TVShowDetailScreen extends ConsumerWidget {
  final int tvShowId;

  const TVShowDetailScreen({
    super.key,
    required this.tvShowId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tvShowAsync = ref.watch(tvShowDetailsProvider(tvShowId));

    return Scaffold(
      body: tvShowAsync.when(
        loading: () => _buildLoadingWidget(context),
        error: (error, stack) => _buildErrorWidget(context, error, ref),
        data: (tvShow) => _buildTVShowDetail(context, tvShow),
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          expandedHeight: 300,
          pinned: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 32, width: 200, color: Colors.white),
                    const SizedBox(height: 16),
                    Container(height: 16, width: 150, color: Colors.white),
                    const SizedBox(height: 24),
                    Container(height: 80, width: double.infinity, color: Colors.white),
                    const SizedBox(height: 24),
                    Container(height: 16, width: 100, color: Colors.white),
                    const SizedBox(height: 16),
                    Container(height: 100, width: double.infinity, color: Colors.white),
                  ],
                ),
              ),
            ]),
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
                'Failed to load TV show details',
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
                  ref.invalidate(tvShowDetailsProvider(tvShowId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTVShowDetail(BuildContext context, TVShowDetails tvShow) {
    return CustomScrollView(
      slivers: [
        // App Bar with Backdrop
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Backdrop Image
                if (tvShow.fullBackdropPath.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: tvShow.fullBackdropPath,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.tv,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.tv,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Content
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Poster and Basic Info Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster
                  Container(
                    width: 120,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: tvShow.fullPosterPath.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: tvShow.fullPosterPath,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.tv),
                              ),
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.tv),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Basic Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tvShow.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (tvShow.originalName != tvShow.name) ...[
                          const SizedBox(height: 4),
                          Text(
                            tvShow.originalName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        // Rating
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              tvShow.ratingText,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              ' (${tvShow.voteCount})',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // First Air Date
                        if (tvShow.firstAirDate.isNotEmpty)
                          _buildInfoChip(
                            context,
                            Icons.calendar_today,
                            'First Air Date',
                            tvShow.formattedFirstAirDate,
                          ),
                        const SizedBox(height: 4),
                        // Status
                        if (tvShow.status.isNotEmpty)
                          _buildInfoChip(
                            context,
                            Icons.info_outline,
                            'Status',
                            tvShow.status,
                          ),
                        const SizedBox(height: 4),
                        // Number of Seasons
                        if (tvShow.numberOfSeasons > 0)
                          _buildInfoChip(
                            context,
                            Icons.tv,
                            'Seasons',
                            '${tvShow.numberOfSeasons}',
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Genres
              if (tvShow.genres.isNotEmpty) ...[
                Text(
                  'Genres',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tvShow.genres
                      .map((genre) => Chip(
                            label: Text(genre.name),
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],
              // Overview
              if (tvShow.overview.isNotEmpty) ...[
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  tvShow.overview,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
              ],
              // Trailer Button
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: TrailerButton(
                  title: tvShow.name,
                  year: tvShow.firstAirDate.isNotEmpty 
                    ? tvShow.firstAirDate.substring(0, 4) 
                    : DateTime.now().year.toString(),
                  type: 'tv',
                ),
              ),
              // Additional Details
              _buildDetailsSection(context, tvShow),
              const SizedBox(height: 100), // Bottom padding
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context, TVShowDetails tvShow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (tvShow.numberOfSeasons > 0)
                  _buildDetailRow(context, 'Seasons', '${tvShow.numberOfSeasons}'),
                if (tvShow.numberOfEpisodes > 0)
                  _buildDetailRow(context, 'Episodes', '${tvShow.numberOfEpisodes}'),
                if (tvShow.episodeRunTime.isNotEmpty)
                  _buildDetailRow(context, 'Episode Runtime', '${tvShow.episodeRunTime.first} min'),
                if (tvShow.originCountry.isNotEmpty)
                  _buildDetailRow(context, 'Origin Country', tvShow.originCountry.join(', ')),
                if (tvShow.originalLanguage.isNotEmpty)
                  _buildDetailRow(context, 'Original Language', tvShow.originalLanguage.toUpperCase()),
                if (tvShow.popularity > 0)
                  _buildDetailRow(context, 'Popularity', tvShow.popularity.toStringAsFixed(1)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
