import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/localization_provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/animated_material_icon.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePreferences = ref.watch(themeProvider);
    final locale = ref.watch(localizationProvider);
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settings ?? 'Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Section
            _buildSection(
              context: context,
              title: l10n?.language ?? 'Language',
              children: [
                _buildLanguageToggle(context, ref, locale),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Theme Mode Section
            _buildSection(
              context: context,
              title: l10n?.theme ?? 'Theme Mode',
              children: _addDividers([
                _buildThemeVariantOption(
                  context: context,
                  ref: ref,
                  variant: ThemeVariant.system,
                  title: l10n?.systemMode ?? 'System',
                  subtitle: 'Follow system theme',
                  icon: Icons.brightness_auto,
                  isSelected: themePreferences.themeVariant == ThemeVariant.system,
                ),
                _buildThemeVariantOption(
                  context: context,
                  ref: ref,
                  variant: ThemeVariant.light,
                  title: l10n?.lightMode ?? 'Light',
                  subtitle: 'Light theme',
                  icon: Icons.brightness_high,
                  isSelected: themePreferences.themeVariant == ThemeVariant.light,
                ),
                _buildThemeVariantOption(
                  context: context,
                  ref: ref,
                  variant: ThemeVariant.dark,
                  title: l10n?.darkMode ?? 'Dark',
                  subtitle: 'Dark theme',
                  icon: Icons.brightness_4,
                  isSelected: themePreferences.themeVariant == ThemeVariant.dark,
                ),
                _buildThemeVariantOption(
                  context: context,
                  ref: ref,
                  variant: ThemeVariant.amoled,
                  title: 'AMOLED Black',
                  subtitle: 'Pure black for OLED displays',
                  icon: Icons.brightness_2,
                  isSelected: themePreferences.themeVariant == ThemeVariant.amoled,
                ),
              ]),
            ),
            
            const SizedBox(height: 24),
            
            // Color Options Section
            _buildSection(
              context: context,
              title: 'Colors',
              children: _addDividers([
                // M3 Standard: Switch with proper styling
                SwitchListTile(
                  value: themePreferences.useDynamicColor,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).setDynamicColor(value);
                  },
                  secondary: Icon(
                    Icons.palette,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    'Dynamic Colors',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500, // M3 Standard: Medium weight
                    ),
                  ),
                  subtitle: Text(
                    'Use colors from wallpaper (Android 12+)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  // M3 Standard: Switch colors
                  activeColor: Theme.of(context).colorScheme.primary,
                  activeTrackColor: Theme.of(context).colorScheme.primaryContainer,
                  inactiveThumbColor: Theme.of(context).colorScheme.outline,
                  inactiveTrackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                SwitchListTile(
                  value: themePreferences.useExpressiveComponents,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).setExpressiveComponents(value);
                  },
                  secondary: Icon(
                    Icons.auto_awesome,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    'Expressive Components',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500, // M3 Standard: Medium weight
                    ),
                  ),
                  subtitle: Text(
                    'Enhanced Material 3 components',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  // M3 Standard: Switch colors
                  activeColor: Theme.of(context).colorScheme.primary,
                  activeTrackColor: Theme.of(context).colorScheme.primaryContainer,
                  inactiveThumbColor: Theme.of(context).colorScheme.outline,
                  inactiveTrackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ]),
            ),
            
            const SizedBox(height: 24),
            
            // Material You Color Palette
            if (!themePreferences.useDynamicColor) ...[
              _buildSection(
                context: context,
                title: 'Color Palette',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildColorPalette(context, ref),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
            ],
            
            // Preview Section
            _buildSection(
              context: context,
              title: 'Preview',
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildThemePreview(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageToggle(BuildContext context, WidgetRef ref, Locale locale) {
    final l10n = AppLocalizations.of(context);
    final isArabic = locale.languageCode == 'ar';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          AnimatedMaterialIcon(
            outlineIcon: MaterialSymbols.settings,
            filledIcon: MaterialSymbols.settingsFilled,
            isFilled: true,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.language ?? 'Language',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isArabic ? 'العربية' : 'English',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isArabic,
            onChanged: (value) async {
              final localizationNotifier = ref.read(localizationProvider.notifier);
              if (value) {
                await localizationNotifier.setArabic();
              } else {
                await localizationNotifier.setEnglish();
              }
            },
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveThumbColor: Theme.of(context).colorScheme.outline,
            inactiveTrackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeVariantOption({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeVariant variant,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected ? const Icon(Icons.check_circle) : null,
      onTap: () {
        ref.read(themeProvider.notifier).setThemeVariant(variant);
      },
    );
  }

  Widget _buildColorPalette(BuildContext context, WidgetRef ref) {
    final themePreferences = ref.watch(themeProvider);
    final colorOptions = [
      {'name': 'Blue', 'color': Colors.blue, 'seed': Colors.blue.value},
      {'name': 'Green', 'color': Colors.green, 'seed': Colors.green.value},
      {'name': 'Purple', 'color': Colors.purple, 'seed': Colors.purple.value},
      {'name': 'Orange', 'color': Colors.orange, 'seed': Colors.orange.value},
      {'name': 'Red', 'color': Colors.red, 'seed': Colors.red.value},
      {'name': 'Teal', 'color': Colors.teal, 'seed': Colors.teal.value},
      {'name': 'Pink', 'color': Colors.pink, 'seed': Colors.pink.value},
      {'name': 'Indigo', 'color': Colors.indigo, 'seed': Colors.indigo.value},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Choose a color scheme',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (themePreferences.seedColor != null)
              TextButton.icon(
                onPressed: () => _resetToDefaultColor(context, ref),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colorOptions.map((option) {
            final color = option['color'] as Color;
            final isSelected = themePreferences.seedColor?.value == color.value;
            return GestureDetector(
              onTap: () => _applySeedColor(context, ref, color, option['name'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected 
                      ? Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 3,
                        )
                      : Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          width: 1,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: isSelected ? 2 : 0,
                    ),
                  ],
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: color.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                        size: 24,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
        
        // Custom Color Picker
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _showCustomColorPicker(context, ref),
          icon: const Icon(Icons.color_lens),
          label: const Text('Custom Color'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  void _applySeedColor(BuildContext context, WidgetRef ref, Color color, String colorName) {
    // Apply the seed color
    ref.read(themeProvider.notifier).setSeedColor(color);
    
    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text('$colorName theme applied'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Theme.of(context).colorScheme.inversePrimary,
          onPressed: () => _resetToDefaultColor(context, ref),
        ),
      ),
    );
  }

  void _resetToDefaultColor(BuildContext context, WidgetRef ref) {
    ref.read(themeProvider.notifier).clearSeedColor();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reset to default colors'),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showCustomColorPicker(BuildContext context, WidgetRef ref) {
    final themePreferences = ref.watch(themeProvider);
    
    showDialog(
      context: context,
      builder: (context) => _CustomColorPickerDialog(
        initialColor: themePreferences.seedColor ?? Colors.blue,
        onColorSelected: (color) => _applySeedColor(context, ref, color, 'Custom'),
      ),
    );
  }

  List<Widget> _addDividers(List<Widget> children) {
    if (children.length <= 1) return children;
    
    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(const Divider(height: 1, indent: 72));
      }
    }
    return result;
  }

  Widget _buildThemePreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(
                      Icons.movie,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Movie Title',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Movie description',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton(
                    onPressed: () {},
                    child: const Text('Primary'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Secondary'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CustomColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorSelected;

  const _CustomColorPickerDialog({
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  State<_CustomColorPickerDialog> createState() => _CustomColorPickerDialogState();
}

class _CustomColorPickerDialogState extends State<_CustomColorPickerDialog> {
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom Color'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Choose a custom color for your theme:'),
          const SizedBox(height: 20),
          // Color preview
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: selectedColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
            ),
            child: Center(
              child: Text(
                'Preview',
                style: TextStyle(
                  color: selectedColor.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Simple color grid picker
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
              Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
              Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
              Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
              Colors.brown, Colors.grey, Colors.blueGrey,
            ].map((color) {
              final isSelected = selectedColor.value == color.value;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor = color;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          )
                        : Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                            width: 1,
                          ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: color.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onColorSelected(selectedColor);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
