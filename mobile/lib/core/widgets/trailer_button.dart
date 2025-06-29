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
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
