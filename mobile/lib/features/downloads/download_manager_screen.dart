import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Provider for download manager state
final downloadManagerProvider = StateNotifierProvider<DownloadManagerNotifier, DownloadManagerState>((ref) {
  return DownloadManagerNotifier();
});

class DownloadManagerState {
  final List<DownloadItem> downloads;
  final bool isLoading;

  const DownloadManagerState({
    this.downloads = const [],
    this.isLoading = false,
  });

  DownloadManagerState copyWith({
    List<DownloadItem>? downloads,
    bool? isLoading,
  }) {
    return DownloadManagerState(
      downloads: downloads ?? this.downloads,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DownloadItem {
  final String id;
  final String title;
  final String type; // 'trailer', 'teaser', 'clip'
  final String quality;
  final String thumbnailUrl;
  final String filePath;
  final int fileSize; // in bytes
  final DownloadStatus status;
  final double progress; // 0.0 to 1.0
  final DateTime createdAt;

  const DownloadItem({
    required this.id,
    required this.title,
    required this.type,
    required this.quality,
    required this.thumbnailUrl,
    required this.filePath,
    required this.fileSize,
    required this.status,
    required this.progress,
    required this.createdAt,
  });

  DownloadItem copyWith({
    String? id,
    String? title,
    String? type,
    String? quality,
    String? thumbnailUrl,
    String? filePath,
    int? fileSize,
    DownloadStatus? status,
    double? progress,
    DateTime? createdAt,
  }) {
    return DownloadItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      quality: quality ?? this.quality,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedFileSize {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

enum DownloadStatus {
  queued,
  downloading,
  completed,
  failed,
  paused,
  cancelled,
}

class DownloadManagerNotifier extends StateNotifier<DownloadManagerState> {
  DownloadManagerNotifier() : super(const DownloadManagerState());

  void addDownload(DownloadItem item) {
    state = state.copyWith(
      downloads: [...state.downloads, item],
    );
  }

  void updateDownload(String id, {DownloadStatus? status, double? progress}) {
    final downloads = state.downloads.map((download) {
      if (download.id == id) {
        return download.copyWith(
          status: status ?? download.status,
          progress: progress ?? download.progress,
        );
      }
      return download;
    }).toList();

    state = state.copyWith(downloads: downloads);
  }

  void removeDownload(String id) {
    final downloads = state.downloads.where((download) => download.id != id).toList();
    state = state.copyWith(downloads: downloads);
  }

  void pauseDownload(String id) {
    updateDownload(id, status: DownloadStatus.paused);
  }

  void resumeDownload(String id) {
    updateDownload(id, status: DownloadStatus.downloading);
  }

  void cancelDownload(String id) {
    updateDownload(id, status: DownloadStatus.cancelled);
  }

  void clearCompleted() {
    final downloads = state.downloads
        .where((download) => download.status != DownloadStatus.completed)
        .toList();
    state = state.copyWith(downloads: downloads);
  }

  void clearAll() {
    state = state.copyWith(downloads: []);
  }
}

class DownloadManagerScreen extends ConsumerStatefulWidget {
  const DownloadManagerScreen({super.key});

  @override
  ConsumerState<DownloadManagerScreen> createState() => _DownloadManagerScreenState();
}

class _DownloadManagerScreenState extends ConsumerState<DownloadManagerScreen> {
  bool _showActiveOnly = false;

  @override
  Widget build(BuildContext context) {
    final downloadState = ref.watch(downloadManagerProvider);
    final downloadNotifier = ref.read(downloadManagerProvider.notifier);

    final filteredDownloads = _showActiveOnly
        ? downloadState.downloads
            .where((d) => d.status == DownloadStatus.downloading || d.status == DownloadStatus.queued)
            .toList()
        : downloadState.downloads;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              'Downloads',
              style: GoogleFonts.rubik(fontWeight: FontWeight.bold),
            ),
            actions: [
              // Filter Toggle - Material 3 Connected Button Group
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFilterButton(
                      context,
                      icon: Icons.all_inclusive_rounded,
                      label: 'All',
                      isSelected: !_showActiveOnly,
                      onTap: () => setState(() => _showActiveOnly = false),
                    ),
                    _buildFilterButton(
                      context,
                      icon: Icons.download_rounded,
                      label: 'Active',
                      isSelected: _showActiveOnly,
                      onTap: () => setState(() => _showActiveOnly = true),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (value) {
                  switch (value) {
                    case 'clear_completed':
                      downloadNotifier.clearCompleted();
                      break;
                    case 'clear_all':
                      _showClearAllDialog(context, downloadNotifier);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear_completed',
                    child: Text('Clear Completed'),
                  ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Text('Clear All'),
                  ),
                ],
              ),
            ],
          ),
          
          // Download Statistics
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: _buildDownloadStats(context, downloadState.downloads),
            ),
          ),

          // Downloads List
          if (filteredDownloads.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.download_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _showActiveOnly ? 'No active downloads' : 'No downloads yet',
                      style: GoogleFonts.rubik(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _showActiveOnly 
                          ? 'Start downloading trailers to see them here'
                          : 'Downloaded trailers will appear here',
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final download = filteredDownloads[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildDownloadItem(context, download, downloadNotifier),
                    );
                  },
                  childCount: filteredDownloads.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected 
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.rubik(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadStats(BuildContext context, List<DownloadItem> downloads) {
    final completed = downloads.where((d) => d.status == DownloadStatus.completed).length;
    final downloading = downloads.where((d) => d.status == DownloadStatus.downloading).length;
    final failed = downloads.where((d) => d.status == DownloadStatus.failed).length;
    final totalSize = downloads
        .where((d) => d.status == DownloadStatus.completed)
        .fold(0, (sum, d) => sum + d.fileSize);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Completed',
            completed.toString(),
            Icons.check_circle_outline,
            Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Downloading',
            downloading.toString(),
            Icons.download_rounded,
            Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Failed',
            failed.toString(),
            Icons.error_outline,
            Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Total Size',
            _formatBytes(totalSize),
            Icons.storage_rounded,
            Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.rubik(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadItem(
    BuildContext context,
    DownloadItem download,
    DownloadManagerNotifier notifier,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status Icon
                _buildStatusIcon(context, download.status),
                const SizedBox(width: 12),
                
                // Title and Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        download.title,
                        style: GoogleFonts.rubik(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              download.type.toUpperCase(),
                              style: GoogleFonts.rubik(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            download.quality,
                            style: GoogleFonts.rubik(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            download.formattedFileSize,
                            style: GoogleFonts.rubik(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Actions
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (value) {
                    switch (value) {
                      case 'play':
                        _playDownload(context, download);
                        break;
                      case 'pause':
                        notifier.pauseDownload(download.id);
                        break;
                      case 'resume':
                        notifier.resumeDownload(download.id);
                        break;
                      case 'cancel':
                        notifier.cancelDownload(download.id);
                        break;
                      case 'delete':
                        _showDeleteDialog(context, download, notifier);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (download.status == DownloadStatus.completed)
                      const PopupMenuItem(
                        value: 'play',
                        child: Text('Play'),
                      ),
                    if (download.status == DownloadStatus.downloading)
                      const PopupMenuItem(
                        value: 'pause',
                        child: Text('Pause'),
                      ),
                    if (download.status == DownloadStatus.paused)
                      const PopupMenuItem(
                        value: 'resume',
                        child: Text('Resume'),
                      ),
                    if (download.status == DownloadStatus.downloading ||
                        download.status == DownloadStatus.queued ||
                        download.status == DownloadStatus.paused)
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Text('Cancel'),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            
            // Progress Bar (for downloading/paused items)
            if (download.status == DownloadStatus.downloading ||
                download.status == DownloadStatus.paused) ...[
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(download.progress * 100).toInt()}%',
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        download.status == DownloadStatus.paused ? 'Paused' : 'Downloading...',
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: download.progress,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      download.status == DownloadStatus.paused
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context, DownloadStatus status) {
    switch (status) {
      case DownloadStatus.completed:
        return Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        );
      case DownloadStatus.downloading:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      case DownloadStatus.paused:
        return Icon(
          Icons.pause_circle,
          color: Theme.of(context).colorScheme.secondary,
          size: 24,
        );
      case DownloadStatus.failed:
        return Icon(
          Icons.error,
          color: Theme.of(context).colorScheme.error,
          size: 24,
        );
      case DownloadStatus.cancelled:
        return Icon(
          Icons.cancel,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 24,
        );
      case DownloadStatus.queued:
        return Icon(
          Icons.schedule,
          color: Theme.of(context).colorScheme.tertiary,
          size: 24,
        );
    }
  }

  void _playDownload(BuildContext context, DownloadItem download) {
    // Navigate to video player with local file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing ${download.title}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    DownloadItem download,
    DownloadManagerNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Download'),
        content: Text('Are you sure you want to delete "${download.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              notifier.removeDownload(download.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(
    BuildContext context,
    DownloadManagerNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Downloads'),
        content: const Text('Are you sure you want to clear all downloads? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              notifier.clearAll();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}
