import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A widget that displays a Material Symbol icon with smooth fill animation
/// when tapped or when its state changes.
class AnimatedMaterialIcon extends StatefulWidget {
  /// The icon data for the outlined version
  final IconData outlineIcon;
  
  /// The icon data for the filled version
  final IconData filledIcon;
  
  /// Whether the icon should be in filled state
  final bool isFilled;
  
  /// Callback when the icon is tapped
  final VoidCallback? onTap;
  
  /// Size of the icon
  final double? size;
  
  /// Color of the icon
  final Color? color;
  
  /// Duration of the fill animation
  final Duration animationDuration;
  
  /// Whether the icon should be tappable
  final bool interactive;
  
  /// Tooltip message
  final String? tooltip;

  const AnimatedMaterialIcon({
    super.key,
    required this.outlineIcon,
    required this.filledIcon,
    this.isFilled = false,
    this.onTap,
    this.size,
    this.color,
    this.animationDuration = const Duration(milliseconds: 200),
    this.interactive = true,
    this.tooltip,
  });

  @override
  State<AnimatedMaterialIcon> createState() => _AnimatedMaterialIconState();
}

class _AnimatedMaterialIconState extends State<AnimatedMaterialIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    if (widget.isFilled) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedMaterialIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFilled != oldWidget.isFilled) {
      if (widget.isFilled) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outline icon (fades out)
            Opacity(
              opacity: 1.0 - _animation.value,
              child: Icon(
                widget.outlineIcon,
                size: widget.size,
                color: widget.color,
              ),
            ),
            // Filled icon (fades in)
            Opacity(
              opacity: _animation.value,
              child: Icon(
                widget.filledIcon,
                size: widget.size,
                color: widget.color,
              ),
            ),
          ],
        );
      },
    );

    if (widget.interactive && widget.onTap != null) {
      iconWidget = InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: iconWidget,
        ),
      );
    }

    if (widget.tooltip != null) {
      iconWidget = Tooltip(
        message: widget.tooltip!,
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}

/// A collection of Material Symbols icon pairs (outline and filled versions)
class MaterialSymbols {
  // Navigation
  static const IconData home = Symbols.home;
  static const IconData homeFilled = Symbols.home;
  
  static const IconData search = Symbols.search;
  static const IconData searchFilled = Symbols.search;
  
  static const IconData library = Symbols.video_library;
  static const IconData libraryFilled = Symbols.video_library;
  
  static const IconData person = Symbols.person;
  static const IconData personFilled = Symbols.person;
  
  // Actions
  static const IconData favorite = Symbols.favorite;
  static const IconData favoriteFilled = Symbols.favorite;
  
  static const IconData bookmark = Symbols.bookmark;
  static const IconData bookmarkFilled = Symbols.bookmark;
  
  static const IconData download = Symbols.download;
  static const IconData downloadFilled = Symbols.download;
  
  static const IconData share = Symbols.share;
  static const IconData shareFilled = Symbols.share;
  
  static const IconData add = Symbols.add;
  static const IconData addFilled = Symbols.add;
  
  static const IconData remove = Symbols.remove;
  static const IconData removeFilled = Symbols.remove;
  
  static const IconData check = Symbols.check_circle;
  static const IconData checkFilled = Symbols.check_circle;
  
  static const IconData star = Symbols.star;
  static const IconData starFilled = Symbols.star;
  
  // Media controls
  static const IconData play = Symbols.play_circle;
  static const IconData playFilled = Symbols.play_circle;
  
  static const IconData pause = Symbols.pause_circle;
  static const IconData pauseFilled = Symbols.pause_circle;
  
  static const IconData stop = Symbols.stop_circle;
  static const IconData stopFilled = Symbols.stop_circle;
  
  static const IconData skipNext = Symbols.skip_next;
  static const IconData skipNextFilled = Symbols.skip_next;
  
  static const IconData skipPrevious = Symbols.skip_previous;
  static const IconData skipPreviousFilled = Symbols.skip_previous;
  
  static const IconData volumeUp = Symbols.volume_up;
  static const IconData volumeUpFilled = Symbols.volume_up;
  
  static const IconData volumeOff = Symbols.volume_off;
  static const IconData volumeOffFilled = Symbols.volume_off;
  
  static const IconData fullscreen = Symbols.fullscreen;
  static const IconData fullscreenFilled = Symbols.fullscreen;
  
  static const IconData fullscreenExit = Symbols.fullscreen_exit;
  static const IconData fullscreenExitFilled = Symbols.fullscreen_exit;
  
  // Content types
  static const IconData movie = Symbols.movie;
  static const IconData movieFilled = Symbols.movie;
  
  static const IconData tv = Symbols.tv;
  static const IconData tvFilled = Symbols.tv;
  
  static const IconData theaters = Symbols.theaters;
  static const IconData theatersFilled = Symbols.theaters;
  
  // Settings and more
  static const IconData settings = Symbols.settings;
  static const IconData settingsFilled = Symbols.settings;
  
  static const IconData info = Symbols.info;
  static const IconData infoFilled = Symbols.info;
  
  static const IconData help = Symbols.help;
  static const IconData helpFilled = Symbols.help;
  
  static const IconData edit = Symbols.edit;
  static const IconData editFilled = Symbols.edit;
  
  static const IconData delete = Symbols.delete;
  static const IconData deleteFilled = Symbols.delete;
  
  static const IconData moreVert = Symbols.more_vert;
  static const IconData moreVertFilled = Symbols.more_vert;
  
  static const IconData moreHoriz = Symbols.more_horiz;
  static const IconData moreHorizFilled = Symbols.more_horiz;
  
  // Calendar and time
  static const IconData calendar = Symbols.calendar_today;
  static const IconData calendarFilled = Symbols.calendar_today;
  
  static const IconData schedule = Symbols.schedule;
  static const IconData scheduleFilled = Symbols.schedule;
  
  // Categories
  static const IconData category = Symbols.category;
  static const IconData categoryFilled = Symbols.category;
  
  static const IconData folder = Symbols.folder;
  static const IconData folderFilled = Symbols.folder;
  
  // Notifications
  static const IconData notifications = Symbols.notifications;
  static const IconData notificationsFilled = Symbols.notifications;
  
  static const IconData notificationsOff = Symbols.notifications_off;
  static const IconData notificationsOffFilled = Symbols.notifications_off;
}
