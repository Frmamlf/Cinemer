import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/loading_indicators.dart';
import '../widgets/animated_material_icon.dart';
import '../localization/app_localizations.dart';

class ExpressiveMovieCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String? subtitle;
  final double? rating;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool showRating;
  final bool isLoading;

  const ExpressiveMovieCard({
    super.key,
    required this.title,
    required this.imageUrl,
    this.subtitle,
    this.rating,
    this.onTap,
    this.width,
    this.height,
    this.showRating = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return CineMaterialLoading.shimmerCard(
        width: width,
        height: height ?? 280,
        borderRadius: BorderRadius.circular(12), // M3 Standard: 12dp radius
        context: context,
      );
    }

    return SizedBox(
      width: width,
      height: height ?? 280,
      child: Card(
        // Material 3 Card specifications
        elevation: 1, // M3 Standard: 1dp elevation for filled cards
        shadowColor: Theme.of(context).colorScheme.shadow,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // M3 Standard: 12dp corner radius
        ),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          // M3 Standard: State layer colors
          splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
          highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
          hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
          focusColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
          child: Stack(
            children: [
              // Main image
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: CineMaterialLoading.circular(
                        color: Theme.of(context).colorScheme.primary,
                        size: 24, // M3 Standard: 24dp for medium icons
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.movie_outlined,
                      size: 40, // M3 Standard: 40dp for large icons
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),

              // M3 Standard: Scrim overlay for readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Theme.of(context).colorScheme.scrim.withOpacity(0.4),
                        Theme.of(context).colorScheme.scrim.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.5, 0.8, 1.0],
                    ),
                  ),
                ),
              ),

              // M3 Standard: Badge component for rating
              if (showRating && rating != null)
                Positioned(
                  top: 8, // M3 Standard: 8dp padding
                  right: 8,
                  child: Badge(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    textColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14, // M3 Standard: 14dp for small icons in badges
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rating!.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500, // M3 Standard: Medium weight
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // M3 Standard: Text layout and typography
              Positioned(
                left: 16, // M3 Standard: 16dp margin
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500, // M3 Standard: Medium weight for titles
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                            color: Theme.of(context).colorScheme.scrim.withOpacity(0.6),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4), // M3 Standard: 4dp spacing
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w400, // M3 Standard: Regular weight
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                              color: Theme.of(context).colorScheme.scrim.withOpacity(0.6),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Large hero-style card for featured content
class ExpressiveHeroCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String? description;
  final double? rating;
  final List<String>? genres;
  final VoidCallback? onTap;
  final VoidCallback? onPlayTap;
  final bool isLoading;

  const ExpressiveHeroCard({
    super.key,
    required this.title,
    required this.imageUrl,
    this.description,
    this.rating,
    this.genres,
    this.onTap,
    this.onPlayTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return CineMaterialLoading.shimmerCard(
        height: 320,
        borderRadius: BorderRadius.circular(32), // Extra expressive radius
        context: context,
      );
    }

    return Container(
      height: 320,
      margin: const EdgeInsets.all(4),
      child: Material(
        elevation: 3,
        shadowColor: Theme.of(context).colorScheme.shadow,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(32), // Extra expressive radius
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: CineMaterialLoading.circular(
                        color: Theme.of(context).colorScheme.primary,
                        size: 48,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.movie_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),

              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Theme.of(context).colorScheme.scrim.withOpacity(0.4),
                        Theme.of(context).colorScheme.scrim.withOpacity(0.9),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // Content
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Genres
                    if (genres != null && genres!.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        children: genres!.take(3).map((genre) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16), // Expressive pill shape
                          ),
                          child: Text(
                            genre,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Title and rating
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700, // Extra bold for hero content
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (rating != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  rating!.toStringAsFixed(1),
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Description
                    if (description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Action buttons
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (onPlayTap != null) ...[
                          FilledButton.icon(
                            onPressed: onPlayTap,
                            icon: const AnimatedMaterialIcon(
                              outlineIcon: MaterialSymbols.play,
                              filledIcon: MaterialSymbols.playFilled,
                              isFilled: false,
                            ),
                            label: Text(AppLocalizations.of(context)?.play ?? 'Play'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        OutlinedButton.icon(
                          onPressed: onTap,
                          icon: const AnimatedMaterialIcon(
                            outlineIcon: MaterialSymbols.info,
                            filledIcon: MaterialSymbols.infoFilled,
                            isFilled: false,
                          ),
                          label: Text(AppLocalizations.of(context)?.details ?? 'Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white, width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
