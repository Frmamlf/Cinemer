import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../services/youtube_trailer_service.dart';
import '../services/download_service.dart';
import '../services/share_service.dart';
import '../localization/app_localizations.dart';

// NextPlayer-inspired video zoom options
enum VideoZoom {
  bestFit,
  stretch,
  crop,
  hundredPercent,
}

// Gesture exclusion area (in dp, like NextPlayer)
const double kGestureExclusionArea = 20.0;

// NextPlayer-inspired enhanced video player with Material 3 design
class CineMaterialVideoPlayer extends StatefulWidget {
  final String? videoUrl;
  final String? localPath;
  final TrailerInfo? trailerInfo;
  final bool autoPlay;
  final bool showControls;
  final bool allowFullScreen;
  final bool enableGestures;
  final bool enablePictureInPicture;

  const CineMaterialVideoPlayer({
    super.key,
    this.videoUrl,
    this.localPath,
    this.trailerInfo,
    this.autoPlay = false,
    this.showControls = true,
    this.allowFullScreen = true,
    this.enableGestures = true,
    this.enablePictureInPicture = false,
  });

  @override
  State<CineMaterialVideoPlayer> createState() => _CineMaterialVideoPlayerState();
}

class _CineMaterialVideoPlayerState extends State<CineMaterialVideoPlayer>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _error;

  // NextPlayer-inspired advanced controls
  bool _showControls = true;
  bool _isControlsLocked = false;
  double _currentVolume = 1.0;
  double _currentBrightness = 1.0;
  double _playbackSpeed = 1.0;
  VideoZoom _videoZoom = VideoZoom.bestFit;
  double _videoScale = 1.0;
  
  // Gesture detection
  late AnimationController _volumeAnimationController;
  late AnimationController _brightnessAnimationController;
  late AnimationController _seekAnimationController;
  late AnimationController _controlsAnimationController;
  
  Timer? _hideControlsTimer;
  Offset? _panStartPosition;
  bool _isSeekGesture = false;
  bool _isVolumeGesture = false;
  bool _isBrightnessGesture = false;
  
  // NextPlayer gesture settings (configurable like NextPlayer)
  final bool _useSwipeControls = true;
  final bool _useZoomControls = true;
  final bool _useDoubleTapGesture = true;
  final bool _useLongPressControls = true;
  final double _longPressSpeed = 2.0;
  final int _controllerAutoHideTimeout = 3; // seconds

  // Gesture overlay values
  double _seekValue = 0.0;
  String _seekInfo = '';
  bool _isLongPressing = false;
  double _originalPlaybackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializePlayer();
  }

  void _initializeAnimations() {
    _volumeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _brightnessAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _seekAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controlsAnimationController.forward();
  }

  Future<void> _initializePlayer() async {
    try {
      // Capture theme data before async operations
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final textTheme = theme.textTheme;

      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Determine video source
      if (widget.localPath != null) {
        _videoController = VideoPlayerController.file(
          File(widget.localPath!),
        );
      } else if (widget.videoUrl != null) {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl!),
        );
      } else {
        throw Exception('No video source provided');
      }

      await _videoController!.initialize();

      // Create Chewie controller with Material 3 styling
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: widget.autoPlay,
        looping: false,
        showControls: widget.showControls,
        allowFullScreen: widget.allowFullScreen,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        showControlsOnInitialize: false,
        // M3 Standard: Progress indicator colors
        materialProgressColors: ChewieProgressColors(
          playedColor: colorScheme.primary, // M3: Primary for played content
          handleColor: colorScheme.primary, // M3: Primary for handle
          backgroundColor: colorScheme.outline.withOpacity(0.38), // M3: Outline at 38% opacity for track
          bufferedColor: colorScheme.primaryContainer.withOpacity(0.5), // M3: Primary container for buffered
        ),
        placeholder: Container(
          color: colorScheme.surfaceContainerHighest,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.movie_rounded,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                if (widget.trailerInfo != null) ...[
                  Text(
                    widget.trailerInfo!.title,
                    style: textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(widget.trailerInfo!.type.toUpperCase()),
                    backgroundColor: colorScheme.secondaryContainer,
                  ),
                ],
              ],
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) => Container(
          color: colorScheme.errorContainer,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: colorScheme.onErrorContainer,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)?.videoError ?? 'Video Error',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _chewieController?.dispose();
    _videoController?.dispose();
    _volumeAnimationController.dispose();
    _brightnessAnimationController.dispose();
    _seekAnimationController.dispose();
    _controlsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading video...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load video',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _initializePlayer,
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_chewieController == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            // Video Player
            Positioned.fill(
              child: Transform.scale(
                scale: _videoScale,
                child: Chewie(controller: _chewieController!),
              ),
            ),
            
            // Gesture Detection Overlay
            if (widget.enableGestures)
              Positioned.fill(
                child: _buildGestureOverlay(),
              ),
              
            // Custom Controls Overlay
            if (_showControls && !_isControlsLocked)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controlsAnimationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _controlsAnimationController.value,
                      child: _buildCustomControls(),
                    );
                  },
                ),
              ),
              
            // Gesture Feedback Overlays
            _buildVolumeOverlay(),
            _buildBrightnessOverlay(),
            _buildSeekOverlay(),
            _buildSpeedOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildGestureOverlay() {
    return GestureDetector(
      onDoubleTap: _useDoubleTapGesture ? _handleDoubleTap : null,
      onLongPressStart: _useLongPressControls ? _handleLongPressStart : null,
      onLongPressEnd: _useLongPressControls ? _handleLongPressEnd : null,
      onPanStart: _useSwipeControls ? _handlePanStart : null,
      onPanUpdate: _useSwipeControls ? _handlePanUpdate : null,
      onPanEnd: _useSwipeControls ? _handlePanEnd : null,
      onTap: _handleTap,
      child: Container(
        color: Colors.transparent,
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildCustomControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.6),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.6),
          ],
          stops: const [0, 0.15, 0.85, 1],
        ),
      ),
      child: Column(
        children: [
          // Top Controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (widget.trailerInfo != null) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.trailerInfo!.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.trailerInfo!.type.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                // Settings Button
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: _showVideoSettings,
                    icon: const Icon(Icons.settings, color: Colors.white),
                    tooltip: AppLocalizations.of(context)?.videoSettings ?? 'Video Settings',
                  ),
                ),
                // Lock Controls Button
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: _toggleControlsLock,
                    icon: Icon(
                      _isControlsLocked ? Icons.lock : Icons.lock_open,
                      color: Colors.white,
                    ),
                    tooltip: _isControlsLocked 
                      ? AppLocalizations.of(context)?.unlockControls ?? 'Unlock Controls' 
                      : AppLocalizations.of(context)?.lockControls ?? 'Lock Controls',
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Bottom Controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Play/Pause Button
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: _togglePlayPause,
                    icon: Icon(
                      _videoController?.value.isPlaying == true
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Speed Button
                Material(
                  color: Colors.transparent,
                  child: TextButton(
                    onPressed: _showSpeedOptions,
                    child: Text(
                      '${_playbackSpeed}x',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Zoom Button
                if (_useZoomControls)
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: _toggleZoom,
                      icon: Icon(
                        _videoZoom == VideoZoom.crop
                            ? Icons.crop_free
                            : Icons.crop,
                        color: Colors.white,
                      ),
                      tooltip: AppLocalizations.of(context)?.toggleZoom ?? 'Toggle Zoom',
                    ),
                  ),
                
                // Picture-in-Picture Button
                if (widget.enablePictureInPicture)
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: _togglePictureInPicture,
                      icon: const Icon(Icons.picture_in_picture_alt, color: Colors.white),
                      tooltip: 'Picture in Picture',
                    ),
                  ),
                
                // Fullscreen Button
                if (widget.allowFullScreen)
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: _toggleFullscreen,
                      icon: const Icon(Icons.fullscreen, color: Colors.white),
                      tooltip: 'Fullscreen',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Gesture Handling Methods
  void _handleTap() {
    setState(() {
      _showControls = !_showControls;
    });
    
    if (_showControls) {
      _showControlsWithTimeout();
    }
  }

  void _handleDoubleTap() {
    if (_videoController?.value.isPlaying == true) {
      _videoController?.pause();
    } else {
      _videoController?.play();
    }
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    if (_videoController?.value.isPlaying == true) {
      _originalPlaybackSpeed = _playbackSpeed;
      _setPlaybackSpeed(_longPressSpeed);
      setState(() {
        _isLongPressing = true;
      });
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    if (_isLongPressing) {
      _setPlaybackSpeed(_originalPlaybackSpeed);
      setState(() {
        _isLongPressing = false;
      });
    }
  }

  void _handlePanStart(DragStartDetails details) {
    _panStartPosition = details.localPosition;
    final screenSize = MediaQuery.of(context).size;
    final leftSide = details.localPosition.dx < screenSize.width / 2;
    
    // Determine gesture type based on position
    if (details.localPosition.dy < kGestureExclusionArea || 
        details.localPosition.dy > screenSize.height - kGestureExclusionArea) {
      return; // Ignore gestures in exclusion areas
    }
    
    if (leftSide) {
      _isBrightnessGesture = true;
    } else {
      _isVolumeGesture = true;
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_panStartPosition == null) return;
    
    final delta = details.localPosition.dy - _panStartPosition!.dy;
    final screenHeight = MediaQuery.of(context).size.height;
    final sensitivity = 2.0 / screenHeight;
    
    if (_isVolumeGesture) {
      final volumeChange = -delta * sensitivity;
      _currentVolume = (_currentVolume + volumeChange).clamp(0.0, 1.0);
      _videoController?.setVolume(_currentVolume);
      _volumeAnimationController.forward();
      
      Timer(const Duration(milliseconds: 1000), () {
        _volumeAnimationController.reverse();
      });
    } else if (_isBrightnessGesture) {
      final brightnessChange = -delta * sensitivity;
      _currentBrightness = (_currentBrightness + brightnessChange).clamp(0.0, 1.0);
      _brightnessAnimationController.forward();
      
      Timer(const Duration(milliseconds: 1000), () {
        _brightnessAnimationController.reverse();
      });
    } else if (_isSeekGesture) {
      final position = _videoController?.value.position ?? Duration.zero;
      final duration = _videoController?.value.duration ?? Duration.zero;
      final seekChange = delta * 0.5; // Adjust sensitivity
      final newPosition = position + Duration(milliseconds: seekChange.round());
      _seekValue = (newPosition.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
      _seekInfo = '${_formatDuration(newPosition)} / ${_formatDuration(duration)}';
      _seekAnimationController.forward();
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_isSeekGesture) {
      final duration = _videoController?.value.duration ?? Duration.zero;
      final seekPosition = Duration(milliseconds: (_seekValue * duration.inMilliseconds).round());
      _videoController?.seekTo(seekPosition);
      
      Timer(const Duration(milliseconds: 1000), () {
        _seekAnimationController.reverse();
      });
    }
    
    // Reset gesture states
    _isVolumeGesture = false;
    _isBrightnessGesture = false;
    _isSeekGesture = false;
    _panStartPosition = null;
  }

  // Control Methods
  void _togglePlayPause() {
    if (_videoController?.value.isPlaying == true) {
      _videoController?.pause();
    } else {
      _videoController?.play();
    }
    _showControlsWithTimeout();
  }

  void _toggleControlsLock() {
    setState(() {
      _isControlsLocked = !_isControlsLocked;
    });
  }

  void _toggleZoom() {
    setState(() {
      switch (_videoZoom) {
        case VideoZoom.bestFit:
          _videoZoom = VideoZoom.crop;
          _videoScale = 1.2;
          break;
        case VideoZoom.crop:
          _videoZoom = VideoZoom.stretch;
          _videoScale = 1.0;
          break;
        case VideoZoom.stretch:
          _videoZoom = VideoZoom.hundredPercent;
          _videoScale = 1.5;
          break;
        case VideoZoom.hundredPercent:
          _videoZoom = VideoZoom.bestFit;
          _videoScale = 1.0;
          break;
      }
    });
    _showControlsWithTimeout();
  }

  void _toggleFullscreen() {
    try {
      // For now, we'll use a fullscreen dialog
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: Colors.black,
              body: SafeArea(
                child: Stack(
                  children: [
                    Center(
                      child: AspectRatio(
                        aspectRatio: _videoController?.value.aspectRatio ?? 16 / 9,
                        child: Chewie(controller: _chewieController!),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            fullscreenDialog: true,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fullscreen error: $e')),
      );
    }
  }

  void _togglePictureInPicture() {
    try {
      // Check if PiP is supported (this would need platform channels for real implementation)
      if (Platform.isAndroid) {
        // On Android, you would use platform channels to enable PiP mode
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Picture-in-Picture mode would be activated')),
        );
      } else if (Platform.isIOS) {
        // On iOS, you would use AVPictureInPictureController
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Picture-in-Picture not supported on iOS for custom players')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Picture-in-Picture not supported on this platform')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PiP error: $e')),
      );
    }
  }

  void _setPlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    _videoController?.setPlaybackSpeed(speed);
  }

  void _showControlsWithTimeout() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(Duration(seconds: _controllerAutoHideTimeout), () {
      if (!_isControlsLocked) {
        setState(() {
          _showControls = false;
        });
        _controlsAnimationController.reverse();
      }
    });
  }

  void _showVideoSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Video Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('Playback Speed'),
              subtitle: Text('${_playbackSpeed}x'),
              onTap: _showSpeedOptions,
            ),
            ListTile(
              leading: const Icon(Icons.aspect_ratio),
              title: const Text('Video Zoom'),
              subtitle: Text(_videoZoom.name),
              onTap: _showZoomOptions,
            ),
            ListTile(
              leading: Icon(_isControlsLocked ? Icons.lock : Icons.lock_open),
              title: const Text('Lock Controls'),
              subtitle: Text(_isControlsLocked ? 'Locked' : 'Unlocked'),
              onTap: () {
                Navigator.pop(context);
                _toggleControlsLock();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSpeedOptions() {
    final speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Playback Speed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: speeds.map((speed) => ListTile(
            title: Text('${speed}x'),
            trailing: _playbackSpeed == speed ? const Icon(Icons.check) : null,
            onTap: () {
              _setPlaybackSpeed(speed);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showZoomOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Zoom'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: VideoZoom.values.map((zoom) => ListTile(
            title: Text(zoom.name),
            trailing: _videoZoom == zoom ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() {
                _videoZoom = zoom;
                switch (zoom) {
                  case VideoZoom.bestFit:
                    _videoScale = 1.0;
                    break;
                  case VideoZoom.crop:
                    _videoScale = 1.2;
                    break;
                  case VideoZoom.stretch:
                    _videoScale = 1.0;
                    break;
                  case VideoZoom.hundredPercent:
                    _videoScale = 1.5;
                    break;
                }
              });
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  // Overlay Widgets
  Widget _buildVolumeOverlay() {
    return AnimatedBuilder(
      animation: _volumeAnimationController,
      builder: (context, child) {
        if (_volumeAnimationController.value == 0) {
          return const SizedBox.shrink();
        }
        
        return Positioned(
          right: 20,
          top: 0,
          bottom: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _currentVolume == 0 ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_currentVolume * 100).round()}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrightnessOverlay() {
    return AnimatedBuilder(
      animation: _brightnessAnimationController,
      builder: (context, child) {
        if (_brightnessAnimationController.value == 0) {
          return const SizedBox.shrink();
        }
        
        return Positioned(
          left: 20,
          top: 0,
          bottom: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.brightness_6,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_currentBrightness * 100).round()}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeekOverlay() {
    return AnimatedBuilder(
      animation: _seekAnimationController,
      builder: (context, child) {
        if (_seekAnimationController.value == 0) {
          return const SizedBox.shrink();
        }
        
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.fast_forward,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _seekInfo,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpeedOverlay() {
    if (!_isLongPressing) return const SizedBox.shrink();
    
    return Positioned(
      top: 50,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fast_forward,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${_playbackSpeed}x',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class TrailerPlayerDialog extends StatelessWidget {
  final List<TrailerInfo> trailers;
  final int initialIndex;

  const TrailerPlayerDialog({
    super.key,
    required this.trailers,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: TrailerPlayerScreen(
        trailers: trailers,
        initialIndex: initialIndex,
      ),
    );
  }
}

class TrailerPlayerScreen extends StatefulWidget {
  final List<TrailerInfo> trailers;
  final int initialIndex;

  const TrailerPlayerScreen({
    super.key,
    required this.trailers,
    this.initialIndex = 0,
  });

  @override
  State<TrailerPlayerScreen> createState() => _TrailerPlayerScreenState();
}

class _TrailerPlayerScreenState extends State<TrailerPlayerScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trailers (${_currentIndex + 1}/${widget.trailers.length})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showDownloadOptions(context),
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Download',
          ),
          IconButton(
            onPressed: () => _shareTrailer(),
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share',
          ),
        ],
      ),
      body: Column(
        children: [
          // Video Player
          Expanded(
            flex: 3,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.trailers.length,
              itemBuilder: (context, index) {
                final trailer = widget.trailers[index];
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: CineMaterialVideoPlayer(
                    videoUrl: trailer.url,
                    trailerInfo: trailer,
                    autoPlay: index == _currentIndex,
                  ),
                );
              },
            ),
          ),
          
          // Trailer Info & Controls
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current trailer info
                  Text(
                    widget.trailers[_currentIndex].title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text(widget.trailers[_currentIndex].type.toUpperCase()),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(widget.trailers[_currentIndex].quality),
                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      ),
                      const Spacer(),
                      Text(
                        _formatDuration(widget.trailers[_currentIndex].duration),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Trailer selection
                  if (widget.trailers.length > 1) ...[
                    Text(
                      'Available Trailers',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.trailers.length,
                        itemBuilder: (context, index) {
                          final trailer = widget.trailers[index];
                          final isSelected = index == _currentIndex;
                          
                          return Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 12),
                            child: Material(
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : Theme.of(context).colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: () {
                                  _pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        trailer.type.toUpperCase(),
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isSelected 
                                              ? Theme.of(context).colorScheme.onPrimaryContainer
                                              : Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDuration(trailer.duration),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: isSelected 
                                              ? Theme.of(context).colorScheme.onPrimaryContainer
                                              : Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDownloadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Download Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.download_rounded),
              title: const Text('Download Current Trailer'),
              subtitle: Text(widget.trailers[_currentIndex].type),
              onTap: () async {
                Navigator.pop(context);
                await _downloadTrailer(widget.trailers[_currentIndex]);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_for_offline_rounded),
              title: const Text('Download All Trailers'),
              subtitle: Text('${widget.trailers.length} trailers'),
              onTap: () async {
                Navigator.pop(context);
                await _downloadAllTrailers();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadTrailer(TrailerInfo trailer) async {
    // Capture context references before async operations
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Downloading ${trailer.title}...'),
            ],
          ),
        ),
      );

      final filename = '${trailer.title}_${trailer.type}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final filePath = await DownloadService.downloadVideo(
        url: trailer.url,
        filename: filename,
      );

      navigator.pop(); // Close progress dialog

      if (filePath != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Downloaded: ${trailer.title}'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () {
                _openDownloadedFile(filePath);
              },
            ),
          ),
        );
      }
    } catch (e) {
      navigator.pop(); // Close progress dialog
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }

  Future<void> _downloadAllTrailers() async {
    // Capture context references before async operations
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Downloading all trailers...'),
                  const SizedBox(height: 8),
                  Text('0 of ${widget.trailers.length} completed'),
                ],
              ),
            );
          },
        ),
      );

      for (int i = 0; i < widget.trailers.length; i++) {
        final trailer = widget.trailers[i];
        final filename = '${trailer.title}_${trailer.type}_${DateTime.now().millisecondsSinceEpoch}.mp4';
        await DownloadService.downloadVideo(
          url: trailer.url,
          filename: filename,
        );
        // Progress is tracked by loop index i
      }

      navigator.pop(); // Close progress dialog

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Downloaded all ${widget.trailers.length} trailers')),
      );
    } catch (e) {
      navigator.pop(); // Close progress dialog
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }

  void _openDownloadedFile(String filePath) {
    try {
      // Navigate to a new screen with the downloaded video
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Downloaded Video'),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            backgroundColor: Colors.black,
            body: Center(
              child: CineMaterialVideoPlayer(
                localPath: filePath,
                autoPlay: true,
                allowFullScreen: true,
                enableGestures: true,
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }

  Future<void> _shareTrailer() async {
    // Capture context references before async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final trailer = widget.trailers[_currentIndex];
      await ShareService.shareTrailer(
        title: trailer.title,
        url: trailer.url,
        description: 'Check out this ${trailer.type} trailer!',
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
