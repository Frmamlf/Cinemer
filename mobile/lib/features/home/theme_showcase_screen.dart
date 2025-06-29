import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeShowcaseScreen extends StatefulWidget {
  const ThemeShowcaseScreen({super.key});

  @override
  State<ThemeShowcaseScreen> createState() => _ThemeShowcaseScreenState();
}

class _ThemeShowcaseScreenState extends State<ThemeShowcaseScreen> {
  String selectedView = 'grid';
  String selectedGenre = 'action';
  String selectedLanguage = 'en';
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Material 3 Theme Showcase',
          style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
        ),
        actions: [
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // View Type Selection
            _buildSectionTitle('View Type'),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'grid',
                    label: Text('Grid'),
                    icon: Icon(Icons.grid_view),
                  ),
                  ButtonSegment(
                    value: 'list',
                    label: Text('List'),
                    icon: Icon(Icons.view_list),
                  ),
                  ButtonSegment(
                    value: 'card',
                    label: Text('Cards'),
                    icon: Icon(Icons.view_module),
                  ),
                ],
                selected: {selectedView},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    selectedView = newSelection.first;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Genre Selection
            _buildSectionTitle('Genre Filter'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'action', label: Text('Action')),
                    ButtonSegment(value: 'comedy', label: Text('Comedy')),
                    ButtonSegment(value: 'drama', label: Text('Drama')),
                  ],
                  selected: {selectedGenre},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      selectedGenre = newSelection.first;
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // More Genre Options
            Wrap(
              spacing: 8,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'horror', label: Text('Horror')),
                    ButtonSegment(value: 'romance', label: Text('Romance')),
                    ButtonSegment(value: 'sci-fi', label: Text('Sci-Fi')),
                  ],
                  selected: const <String>{},
                  onSelectionChanged: (Set<String> newSelection) {
                    // Handle additional genre selection
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Language Selection
            _buildSectionTitle('Language'),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'en',
                    label: Text('English'),
                    icon: Icon(Icons.language),
                  ),
                  ButtonSegment(
                    value: 'ar',
                    label: Text('العربية'),
                    icon: Icon(Icons.translate),
                  ),
                  ButtonSegment(
                    value: 'ja',
                    label: Text('日本語'),
                    icon: Icon(Icons.translate),
                  ),
                ],
                selected: {selectedLanguage},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    selectedLanguage = newSelection.first;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Button Examples
            _buildSectionTitle('Button Styles'),
            const SizedBox(height: 16),
            
            // Primary Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Secondary Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.bookmark_border),
                    label: const Text('Bookmark'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Arabic Text Example
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'مرحباً بكم في تطبيق سينيمر',
                    style: GoogleFonts.rubik(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اكتشف أفضل الأفلام والمسلسلات والأنمي',
                    style: GoogleFonts.rubik(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // English Text Example
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Welcome to Cinemer',
                    style: GoogleFonts.rubik(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover the best movies, TV shows and anime with beautiful Material 3 design',
                    style: GoogleFonts.rubik(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Multiple FABs
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: "add",
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: "main",
            onPressed: () {},
            icon: const Icon(Icons.favorite),
            label: Text(
              'Add to Favorites',
              style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.rubik(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
