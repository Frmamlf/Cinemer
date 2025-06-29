import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'trailer_selection_sheet.dart';
import 'animated_material_icon.dart';
import '../localization/app_localizations.dart';

class TrailerButton extends ConsumerWidget {
  final String title;
  final String year;
  final String type; // 'movie' or 'tv'
  final VoidCallback? onPressed;

  const TrailerButton({
    super.key,
    required this.title,
    required this.year,
    this.type = 'movie',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
      onPressed: () => _showTrailerOptions(context),
      icon: const AnimatedMaterialIcon(
        outlineIcon: MaterialSymbols.play,
        filledIcon: MaterialSymbols.playFilled,
        isFilled: false,
      ),
      label: Text(AppLocalizations.of(context)?.watchTrailer ?? 'Watch Trailer'),
      style: FilledButton.styleFrom(
        // M3 Standard: Filled button styling
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        disabledBackgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // M3 Standard: 20dp for buttons
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10), // M3 Standard: 24/10 padding
        minimumSize: const Size(64, 40), // M3 Standard: 64x40 minimum size
        elevation: 0, // M3 Standard: 0dp elevation for filled buttons
        shadowColor: Colors.transparent,
        // M3 Standard: Text style
        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showTrailerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (context) => TrailerSelectionSheet(
        movieTitle: title,
        year: year,
        type: type,
      ),
    );
  }
}
