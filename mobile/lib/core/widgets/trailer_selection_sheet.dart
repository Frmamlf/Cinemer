import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/youtube_trailer_service.dart';
import '../localization/app_localizations.dart';
import 'video_player.dart';

class TrailerSelectionSheet extends ConsumerStatefulWidget {
  final String movieTitle;
  final String year;
  final String type; // 'movie', 'tv', 'anime'

  const TrailerSelectionSheet({
    super.key,
    required this.movieTitle,
    required this.year,
    this.type = 'movie',
  });

  @override
  ConsumerState<TrailerSelectionSheet> createState() => _TrailerSelectionSheetState();
}

class _TrailerSelectionSheetState extends ConsumerState<TrailerSelectionSheet> {
  final YouTubeTrailerService _trailerService = YouTubeTrailerService();
  List<TrailerInfo> _trailers = [];
  bool _isLoading = true;
  String? _error;
  String _selectedType = TrailerType.trailer;

  final List<String> _trailerTypes = [
    TrailerType.trailer,
    TrailerType.trailer1,
    TrailerType.trailer2,
    TrailerType.teaser,
    TrailerType.featurette,
    TrailerType.behindScenes,
    TrailerType.clip,
    TrailerType.interview,
  ];

  @override
  void initState() {
    super.initState();
    _loadTrailers();
  }

  @override
  void dispose() {
    _trailerService.dispose();
    super.dispose();
  }

  Future<void> _loadTrailers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final trailers = await _trailerService.searchTrailers(
        widget.movieTitle,
        widget.year,
        type: widget.type,
      );

      setState(() {
        _trailers = trailers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<TrailerInfo> get _filteredTrailers {
    return _trailers.where((trailer) => trailer.type == _selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trailers & Videos',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.movieTitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Trailer Type Selection - Material 3 Connected Button Group
                _buildTrailerTypeSelection(),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailerTypeSelection() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _trailerTypes.length,
        itemBuilder: (context, index) {
          final type = _trailerTypes[index];
          final isSelected = _selectedType == type;
          final hasTrailers = _trailers.any((trailer) => trailer.type == type);
          
          return Container(
            margin: EdgeInsets.only(right: index < _trailerTypes.length - 1 ? 8 : 0),
            child: Material(
              color: isSelected 
                  ? Theme.of(context).colorScheme.primaryContainer
                  : hasTrailers 
                      ? Theme.of(context).colorScheme.surfaceContainerHigh
                      : Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: hasTrailers ? () {
                  setState(() {
                    _selectedType = type;
                  });
                } : null,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    type.replaceAll('_', ' ').toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : hasTrailers
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Searching for trailers...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                'Failed to load trailers',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadTrailers,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)?.tryAgain ?? 'Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final filteredTrailers = _filteredTrailers;
    
    if (filteredTrailers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No ${_selectedType}s found',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Try selecting a different trailer type.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: filteredTrailers.length,
      itemBuilder: (context, index) {
        final trailer = filteredTrailers[index];
        return _buildTrailerCard(trailer);
      },
    );
  }

  Widget _buildTrailerCard(TrailerInfo trailer) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _playTrailer(trailer),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail and play button
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        trailer.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHigh,
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.play_circle_filled,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  // Duration badge
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatDuration(trailer.duration),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Title and details
              Text(
                trailer.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Action buttons
              Row(
                children: [
                  Chip(
                    label: Text(
                      trailer.quality,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  const Spacer(),
                  IconButton.outlined(
                    onPressed: () => _downloadTrailer(trailer),
                    icon: const Icon(Icons.download),
                    tooltip: 'Download',
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => _playTrailer(trailer),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play'),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _playTrailer(TrailerInfo trailer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TrailerPlayerScreen(trailer: trailer),
      ),
    );
  }

  void _downloadTrailer(TrailerInfo trailer) async {
    try {
      // Show download progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => TrailerDownloadDialog(trailer: trailer),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

class TrailerPlayerScreen extends StatelessWidget {
  final TrailerInfo trailer;

  const TrailerPlayerScreen({super.key, required this.trailer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          trailer.title,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Share functionality
            },
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () {
              // Download functionality
            },
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: Center(
        child: CineMaterialVideoPlayer(
          videoUrl: trailer.url,
          trailerInfo: trailer,
          autoPlay: true,
          allowFullScreen: true,
        ),
      ),
    );
  }
}

class TrailerDownloadDialog extends StatefulWidget {
  final TrailerInfo trailer;

  const TrailerDownloadDialog({super.key, required this.trailer});

  @override
  State<TrailerDownloadDialog> createState() => _TrailerDownloadDialogState();
}

class _TrailerDownloadDialogState extends State<TrailerDownloadDialog> {
  double _progress = 0.0;
  bool _isCompleted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      final trailerService = YouTubeTrailerService();
      await trailerService.downloadTrailer(
        widget.trailer,
        onProgress: (progress) {
          setState(() {
            _progress = progress;
          });
        },
      );
      
      setState(() {
        _isCompleted = true;
      });
      
      // Auto close after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pop();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isCompleted 
        ? AppLocalizations.of(context)?.downloadComplete ?? 'Download Complete'
        : AppLocalizations.of(context)?.downloadingTrailer ?? 'Downloading Trailer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null) ...[
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Download failed: $_error',
              textAlign: TextAlign.center,
            ),
          ] else if (_isCompleted) ...[
            Icon(
              Icons.check_circle,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text('Trailer downloaded successfully!'),
          ] else ...[
            CircularProgressIndicator(value: _progress),
            const SizedBox(height: 16),
            Text('${(_progress * 100).toInt()}%'),
            const SizedBox(height: 8),
            Text(
              widget.trailer.title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      actions: [
        if (_error != null || _isCompleted)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        if (!_isCompleted && _error == null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
      ],
    );
  }
}
