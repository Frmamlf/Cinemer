import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CineMaterialLoading {
  // Linear progress indicator with Material 3 styling
  static Widget linear({
    double? value,
    Color? backgroundColor,
    Color? valueColor,
    double height = 4.0,
    BorderRadius? borderRadius,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(2.0),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(2.0),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: backgroundColor,
          valueColor: valueColor != null 
            ? AlwaysStoppedAnimation<Color>(valueColor)
            : null,
        ),
      ),
    );
  }

  // Circular progress indicator with Material 3 styling
  static Widget circular({
    double? value,
    Color? color,
    double strokeWidth = 4.0,
    double size = 40.0,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: value,
        color: color,
        strokeWidth: strokeWidth,
        strokeCap: StrokeCap.round, // Material 3 rounded stroke caps
      ),
    );
  }

  // Small circular for inline use
  static Widget circularSmall({
    double? value,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return SizedBox(
      width: 16.0,
      height: 16.0,
      child: CircularProgressIndicator(
        value: value,
        color: color,
        strokeWidth: strokeWidth,
        strokeCap: StrokeCap.round,
      ),
    );
  }

  // Material 3 Shimmer loading for cards
  static Widget shimmerCard({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    required BuildContext context,
  }) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      highlightColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
      child: Container(
        width: width,
        height: height ?? 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Full screen loading overlay with Material 3 design
  static Widget overlay({
    String? message,
    bool dimBackground = true,
    required BuildContext context,
  }) {
    return Container(
      color: dimBackground 
        ? Theme.of(context).colorScheme.scrim.withValues(alpha: 0.5)
        : Colors.transparent,
      child: Center(
        child: Card(
          elevation: 6,
          shadowColor: Theme.of(context).colorScheme.shadow,
          surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28), // Material 3 extra-large container
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                circular(
                  color: Theme.of(context).colorScheme.primary,
                  size: 48,
                  strokeWidth: 4,
                ),
                if (message != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Inline loading with Material 3 styling
  static Widget inline({
    required String text,
    double spacing = 12.0,
    MainAxisAlignment alignment = MainAxisAlignment.center,
    required BuildContext context,
  }) {
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        circularSmall(color: Theme.of(context).colorScheme.primary),
        SizedBox(width: spacing),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // Material 3 Loading button state
  static Widget button({
    required Widget child,
    required bool isLoading,
    VoidCallback? onPressed,
    ButtonStyle? style,
    required BuildContext context,
  }) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: circularSmall(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          )
        : child,
    );
  }

  // Material 3 Shimmer loading for list items
  static Widget listItem({
    double height = 88,
    EdgeInsets? padding,
    required BuildContext context,
  }) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      highlightColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
      child: Container(
        height: height,
        padding: padding ?? const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16), // Material 3 medium container
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Grid loading for movie/TV show grids
  static Widget gridItem({
    required BuildContext context,
    double aspectRatio = 2 / 3,
  }) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      highlightColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 60,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Loading state wrapper widget with Material 3 design
class LoadingStateWrapper extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Widget? loadingWidget;
  final String? loadingMessage;

  const LoadingStateWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingWidget,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          loadingWidget ?? 
          CineMaterialLoading.overlay(
            message: loadingMessage,
            context: context,
          ),
      ],
    );
  }
}
