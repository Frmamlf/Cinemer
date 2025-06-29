import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Player settings provider (you can implement this based on your needs)
final playerSettingsProvider = StateNotifierProvider<PlayerSettingsNotifier, PlayerSettings>((ref) {
  return PlayerSettingsNotifier();
});

class PlayerSettings {
  final bool autoPlay;
  final bool showSubtitles;
  final double playbackSpeed;
  final String defaultQuality;
  final bool useHardwareDecoding;
  final bool enableGestures;
  final bool showSkipButtons;
  final int skipDuration;
  final bool pipOnBackground;
  final bool fullscreenOnRotate;

  const PlayerSettings({
    this.autoPlay = true,
    this.showSubtitles = false,
    this.playbackSpeed = 1.0,
    this.defaultQuality = 'auto',
    this.useHardwareDecoding = true,
    this.enableGestures = true,
    this.showSkipButtons = true,
    this.skipDuration = 10,
    this.pipOnBackground = false,
    this.fullscreenOnRotate = true,
  });

  PlayerSettings copyWith({
    bool? autoPlay,
    bool? showSubtitles,
    double? playbackSpeed,
    String? defaultQuality,
    bool? useHardwareDecoding,
    bool? enableGestures,
    bool? showSkipButtons,
    int? skipDuration,
    bool? pipOnBackground,
    bool? fullscreenOnRotate,
  }) {
    return PlayerSettings(
      autoPlay: autoPlay ?? this.autoPlay,
      showSubtitles: showSubtitles ?? this.showSubtitles,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      defaultQuality: defaultQuality ?? this.defaultQuality,
      useHardwareDecoding: useHardwareDecoding ?? this.useHardwareDecoding,
      enableGestures: enableGestures ?? this.enableGestures,
      showSkipButtons: showSkipButtons ?? this.showSkipButtons,
      skipDuration: skipDuration ?? this.skipDuration,
      pipOnBackground: pipOnBackground ?? this.pipOnBackground,
      fullscreenOnRotate: fullscreenOnRotate ?? this.fullscreenOnRotate,
    );
  }
}

class PlayerSettingsNotifier extends StateNotifier<PlayerSettings> {
  PlayerSettingsNotifier() : super(const PlayerSettings());

  void setAutoPlay(bool value) {
    state = state.copyWith(autoPlay: value);
  }

  void setShowSubtitles(bool value) {
    state = state.copyWith(showSubtitles: value);
  }

  void setPlaybackSpeed(double value) {
    state = state.copyWith(playbackSpeed: value);
  }

  void setDefaultQuality(String value) {
    state = state.copyWith(defaultQuality: value);
  }

  void setUseHardwareDecoding(bool value) {
    state = state.copyWith(useHardwareDecoding: value);
  }

  void setEnableGestures(bool value) {
    state = state.copyWith(enableGestures: value);
  }

  void setShowSkipButtons(bool value) {
    state = state.copyWith(showSkipButtons: value);
  }

  void setSkipDuration(int value) {
    state = state.copyWith(skipDuration: value);
  }

  void setPipOnBackground(bool value) {
    state = state.copyWith(pipOnBackground: value);
  }

  void setFullscreenOnRotate(bool value) {
    state = state.copyWith(fullscreenOnRotate: value);
  }
}

class PlayerSettingsScreen extends ConsumerWidget {
  const PlayerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(playerSettingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Playback Section
            _buildSection(
              context: context,
              title: 'Playback',
              children: [
                SwitchListTile(
                  value: settings.autoPlay,
                  onChanged: (value) {
                    ref.read(playerSettingsProvider.notifier).setAutoPlay(value);
                  },
                  secondary: const Icon(Icons.play_arrow),
                  title: const Text('Auto Play'),
                  subtitle: const Text('Automatically start playing videos'),
                ),
                SwitchListTile(
                  value: settings.useHardwareDecoding,
                  onChanged: (value) {
                    ref.read(playerSettingsProvider.notifier).setUseHardwareDecoding(value);
                  },
                  secondary: const Icon(Icons.memory),
                  title: const Text('Hardware Decoding'),
                  subtitle: const Text('Use GPU acceleration for better performance'),
                ),
                ListTile(
                  leading: const Icon(Icons.speed),
                  title: const Text('Default Playback Speed'),
                  subtitle: Text('${settings.playbackSpeed}x'),
                  trailing: DropdownButton<double>(
                    value: settings.playbackSpeed,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(playerSettingsProvider.notifier).setPlaybackSpeed(value);
                      }
                    },
                    items: [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
                        .map((speed) => DropdownMenuItem(
                              value: speed,
                              child: Text('${speed}x'),
                            ))
                        .toList(),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.hd),
                  title: const Text('Default Quality'),
                  subtitle: Text(settings.defaultQuality.toUpperCase()),
                  trailing: DropdownButton<String>(
                    value: settings.defaultQuality,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(playerSettingsProvider.notifier).setDefaultQuality(value);
                      }
                    },
                    items: ['auto', '480p', '720p', '1080p']
                        .map((quality) => DropdownMenuItem(
                              value: quality,
                              child: Text(quality.toUpperCase()),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Controls Section
            _buildSection(
              context: context,
              title: 'Controls',
              children: [
                SwitchListTile(
                  value: settings.enableGestures,
                  onChanged: (value) {
                    ref.read(playerSettingsProvider.notifier).setEnableGestures(value);
                  },
                  secondary: const Icon(Icons.touch_app),
                  title: const Text('Touch Gestures'),
                  subtitle: const Text('Double tap to seek, swipe for volume/brightness'),
                ),
                SwitchListTile(
                  value: settings.showSkipButtons,
                  onChanged: (value) {
                    ref.read(playerSettingsProvider.notifier).setShowSkipButtons(value);
                  },
                  secondary: const Icon(Icons.skip_next),
                  title: const Text('Skip Buttons'),
                  subtitle: const Text('Show skip forward/backward buttons'),
                ),
                ListTile(
                  leading: const Icon(Icons.fast_forward),
                  title: const Text('Skip Duration'),
                  subtitle: Text('${settings.skipDuration} seconds'),
                  trailing: DropdownButton<int>(
                    value: settings.skipDuration,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(playerSettingsProvider.notifier).setSkipDuration(value);
                      }
                    },
                    items: [5, 10, 15, 30]
                        .map((duration) => DropdownMenuItem(
                              value: duration,
                              child: Text('${duration}s'),
                            ))
                        .toList(),
                  ),
                ),
                SwitchListTile(
                  value: settings.showSubtitles,
                  onChanged: (value) {
                    ref.read(playerSettingsProvider.notifier).setShowSubtitles(value);
                  },
                  secondary: const Icon(Icons.subtitles),
                  title: const Text('Subtitles'),
                  subtitle: const Text('Show subtitles when available'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Behavior Section
            _buildSection(
              context: context,
              title: 'Behavior',
              children: [
                SwitchListTile(
                  value: settings.fullscreenOnRotate,
                  onChanged: (value) {
                    ref.read(playerSettingsProvider.notifier).setFullscreenOnRotate(value);
                  },
                  secondary: const Icon(Icons.screen_rotation),
                  title: const Text('Fullscreen on Rotate'),
                  subtitle: const Text('Enter fullscreen when device is rotated'),
                ),
                SwitchListTile(
                  value: settings.pipOnBackground,
                  onChanged: (value) {
                    ref.read(playerSettingsProvider.notifier).setPipOnBackground(value);
                  },
                  secondary: const Icon(Icons.picture_in_picture),
                  title: const Text('Picture in Picture'),
                  subtitle: const Text('Continue playing in PiP when app is backgrounded'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Reset Section
            _buildSection(
              context: context,
              title: 'Reset',
              children: [
                ListTile(
                  leading: Icon(
                    Icons.restore,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Reset to Defaults',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  subtitle: const Text('Restore all player settings to default values'),
                  onTap: () => _showResetDialog(context, ref),
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
            children: _addDividers(children),
          ),
        ),
      ],
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

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Player Settings'),
        content: const Text(
          'Are you sure you want to reset all player settings to their default values? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Reset to default settings
              final notifier = ref.read(playerSettingsProvider.notifier);
              notifier.setAutoPlay(true);
              notifier.setShowSubtitles(false);
              notifier.setPlaybackSpeed(1.0);
              notifier.setDefaultQuality('auto');
              notifier.setUseHardwareDecoding(true);
              notifier.setEnableGestures(true);
              notifier.setShowSkipButtons(true);
              notifier.setSkipDuration(10);
              notifier.setPipOnBackground(false);
              notifier.setFullscreenOnRotate(true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Player settings reset to defaults'),
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
