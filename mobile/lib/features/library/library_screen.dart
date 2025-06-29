import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/providers/library_provider.dart';
import '../../core/providers/content_providers.dart';
import '../../core/models/library_models.dart';
import '../../core/widgets/expressive_movie_card.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _selectedSection = 0; // 0: Watchlist, 1: Favorites, 2: Upcoming
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // M3 Standard: App Bar - Simplified
          SliverAppBar(
            pinned: true,
            title: Text(
              'Library',
              style: GoogleFonts.rubik(
                fontWeight: FontWeight.w500, // M3 Standard: Medium weight
                fontSize: 22, // M3 Standard: 22sp for app bar titles
              ),
            ),
            actions: [
              IconButton.filled(
                onPressed: () => _showCreateListDialog(context),
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(
                  // M3 Standard: Filled icon button
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // M3 Standard: 20dp for icon buttons
                  ),
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
          
          // Section Selector
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // M3 Standard: SegmentedButton component
                  Center(
                    child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment<int>(
                          value: 0,
                          label: Text('Watchlist'),
                          icon: Icon(Icons.bookmark_rounded),
                        ),
                        ButtonSegment<int>(
                          value: 1,
                          label: Text('Favorites'),
                          icon: Icon(Icons.favorite_rounded),
                        ),
                        ButtonSegment<int>(
                          value: 2,
                          label: Text('Upcoming'),
                          icon: Icon(Icons.schedule_rounded),
                        ),
                      ],
                      selected: {_selectedSection},
                      onSelectionChanged: (Set<int> newSelection) {
                        setState(() {
                          _selectedSection = newSelection.first;
                        });
                        _animationController.reset();
                        _animationController.forward();
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
                  const SizedBox(height: 24),
                  
                  // View Toggle (Grid/List) - M3 Standard: ToggleButtons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(
                            value: true,
                            icon: Icon(Icons.grid_view_rounded),
                            tooltip: 'Grid View',
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            icon: Icon(Icons.view_list_rounded),
                            tooltip: 'List View',
                          ),
                        ],
                        selected: {_isGridView},
                        onSelectionChanged: (Set<bool> newSelection) {
                          setState(() {
                            _isGridView = newSelection.first;
                          });
                        },
                        style: SegmentedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          foregroundColor: Theme.of(context).colorScheme.onSurface,
                          selectedBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          selectedForegroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Content Section with Animation
          SliverFillRemaining(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildSelectedSectionContent(libraryState),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedSectionContent(dynamic libraryState) {
    switch (_selectedSection) {
      case 0: // Watchlist
        return _buildWatchlistTab(libraryState.watchlist);
      case 1: // Favorites
        return _buildFavoritesTab(libraryState.favorites);
      case 2: // Upcoming
        return _buildUpcomingTab();
      default:
        return _buildWatchlistTab(libraryState.watchlist);
    }
  }

  Widget _buildWatchlistTab(List<ListItem> watchlist) {
    if (watchlist.isEmpty) {
      return _buildEmptyState(
        'Your Watchlist is Empty',
        'Add movies and TV shows to your watchlist to keep track of what you want to watch.',
        Icons.bookmark_outline,
      );
    }
    return _buildMediaGrid(watchlist);
  }

  Widget _buildFavoritesTab(List<ListItem> favorites) {
    if (favorites.isEmpty) {
      return _buildEmptyState(
        'No Favorites Yet',
        'Mark movies and TV shows as favorites to see them here.',
        Icons.favorite_outline,
      );
    }
    return _buildMediaGrid(favorites);
  }

  Widget _buildMediaGrid(List<ListItem> items) {
    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildMediaCard(item);
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildMediaListTile(item);
        },
      );
    }
  }

  Widget _buildMediaCard(ListItem item) {
    return ExpressiveMovieCard(
      title: item.displayTitle,
      imageUrl: item.fullPosterPath,
      subtitle: item.displayDate,
      rating: item.voteAverage,
      onTap: () {
        final route = item.mediaType == 'movie' 
            ? '/movie/${item.id}' 
            : '/tv-show/${item.id}';
        context.go(route);
      },
    );
  }

  Widget _buildMediaListTile(ListItem item) {
    return Card(
      // M3 Standard: Card styling
      elevation: 1, // M3 Standard: 1dp elevation for filled cards
      margin: const EdgeInsets.only(bottom: 8), // M3 Standard: 8dp margin
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // M3 Standard: 12dp corner radius
      ),
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      shadowColor: Theme.of(context).colorScheme.shadow,
      child: ListTile(
        // M3 Standard: ListTile padding
        contentPadding: const EdgeInsets.all(16), // M3 Standard: 16dp padding
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8), // M3 Standard: 8dp for images
          child: SizedBox(
            width: 56, // M3 Standard: 56dp for list item leading
            height: 80,
            child: ExpressiveMovieCard(
              title: '',
              imageUrl: item.fullPosterPath,
              width: 56,
              height: 80,
              showRating: false,
            ),
          ),
        ),
        title: Text(
          item.displayTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500, // M3 Standard: Medium weight for titles
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4), // M3 Standard: 4dp spacing
            Text(
              item.displayDate,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber[600],
                ),
                const SizedBox(width: 4),
                Text(
                  item.voteAverage.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 12),
                Chip(
                  label: Text(
                    item.mediaType.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () {
            // Add more options (remove from list, etc.)
          },
          icon: const Icon(Icons.more_vert),
        ),
        onTap: () {
          final route = item.mediaType == 'movie' 
              ? '/movie/${item.id}' 
              : '/tv-show/${item.id}';
          context.go(route);
        },
      ),
    );
  }

  Widget _buildEmptyState(
    String title,
    String description,
    IconData icon, {
    bool showCreateButton = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (showCreateButton) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _showCreateListDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Create List'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCreateListDialog(BuildContext context) {
    // Implementation for creating lists
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New List'),
        content: const Text('Create list functionality would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTab() {
    return Consumer(
      builder: (context, ref, child) {
        final upcomingMovies = ref.watch(upcomingMoviesProvider(1));
        
        return upcomingMovies.when(
          data: (movieResponse) {
            if (movieResponse.results.isEmpty) {
              return _buildEmptyState(
                'No Upcoming Releases',
                'Check back later for upcoming movies and shows.',
                Icons.schedule_outlined,
              );
            }
            
            // Filter movies that are actually upcoming (release date > today)
            final now = DateTime.now();
            final upcomingItems = movieResponse.results.where((movie) {
              if (movie.releaseDate.isNotEmpty) {
                final releaseDate = DateTime.tryParse(movie.releaseDate);
                return releaseDate != null && releaseDate.isAfter(now);
              }
              return false;
            }).toList();
            
            if (upcomingItems.isEmpty) {
              return _buildEmptyState(
                'No Upcoming Releases',
                'All movies in the database have already been released.',
                Icons.schedule_outlined,
              );
            }
            
            return _buildUpcomingGrid(upcomingItems);
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => _buildEmptyState(
            'Error Loading Upcoming',
            'Failed to load upcoming releases. Please try again.',
            Icons.error_outline,
          ),
        );
      },
    );
  }
  
  Widget _buildUpcomingGrid(List movies) {
    if (_isGridView) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return _buildUpcomingMovieCard(movie);
          },
        ),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return _buildUpcomingMovieListTile(movie);
        },
      );
    }
  }
  
  Widget _buildUpcomingMovieCard(dynamic movie) {
    final releaseDate = movie.releaseDate.isNotEmpty 
        ? DateTime.tryParse(movie.releaseDate) 
        : null;
    final daysUntilRelease = releaseDate?.difference(DateTime.now()).inDays;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: movie.posterPath != null 
                    ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
                    : '',
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  child: const Icon(Icons.movie),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title ?? 'Unknown Title',
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (daysUntilRelease != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      daysUntilRelease > 0 
                          ? '$daysUntilRelease days'
                          : 'Released',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUpcomingMovieListTile(dynamic movie) {
    final releaseDate = movie.releaseDate.isNotEmpty 
        ? DateTime.tryParse(movie.releaseDate) 
        : null;
    final daysUntilRelease = releaseDate?.difference(DateTime.now()).inDays;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: movie.posterPath != null 
                ? 'https://image.tmdb.org/t/p/w200${movie.posterPath}'
                : '',
            width: 60,
            height: 80,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 60,
              height: 80,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: const Icon(Icons.movie),
            ),
            errorWidget: (context, url, error) => Container(
              width: 60,
              height: 80,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: const Icon(Icons.movie),
            ),
          ),
        ),
        title: Text(
          movie.title ?? 'Unknown Title',
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (movie.overview?.isNotEmpty == true)
              Text(
                movie.overview!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 4),
            if (daysUntilRelease != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  daysUntilRelease > 0 
                      ? 'In $daysUntilRelease days'
                      : 'Released',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          // Navigate to movie details
          context.go('/movie/${movie.id}');
        },
      ),
    );
  }
}
