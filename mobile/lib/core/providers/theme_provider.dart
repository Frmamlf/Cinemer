import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum ThemeVariant {
  system,
  light,
  dark,
  amoled,
  lightHighContrast,
  darkHighContrast,
}

class ThemePreferences {
  final ThemeVariant themeVariant;
  final bool useDynamicColor;
  final bool useExpressiveComponents;
  final Color? seedColor;

  const ThemePreferences({
    this.themeVariant = ThemeVariant.system,
    this.useDynamicColor = true,
    this.useExpressiveComponents = true,
    this.seedColor,
  });

  ThemePreferences copyWith({
    ThemeVariant? themeVariant,
    bool? useDynamicColor,
    bool? useExpressiveComponents,
    Color? seedColor,
  }) {
    return ThemePreferences(
      themeVariant: themeVariant ?? this.themeVariant,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
      useExpressiveComponents: useExpressiveComponents ?? this.useExpressiveComponents,
      seedColor: seedColor ?? this.seedColor,
    );
  }

  // Convenience getters for theme checks
  bool get shouldUseAmoled => themeVariant == ThemeVariant.amoled;
  bool get shouldUseLightHighContrast => themeVariant == ThemeVariant.lightHighContrast;
  bool get shouldUseDarkHighContrast => themeVariant == ThemeVariant.darkHighContrast;

  Map<String, dynamic> toJson() {
    return {
      'themeVariant': themeVariant.index,
      'useDynamicColor': useDynamicColor,
      'useExpressiveComponents': useExpressiveComponents,
      'seedColor': seedColor?.value,
    };
  }

  factory ThemePreferences.fromJson(Map<String, dynamic> json) {
    return ThemePreferences(
      themeVariant: ThemeVariant.values[json['themeVariant'] ?? 0],
      useDynamicColor: json['useDynamicColor'] ?? true,
      useExpressiveComponents: json['useExpressiveComponents'] ?? true,
      seedColor: json['seedColor'] != null ? Color(json['seedColor']) : null,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemePreferences> {
  static const String _boxName = 'theme_preferences';
  static const String _key = 'preferences';
  
  late final Box _box;

  ThemeNotifier() : super(const ThemePreferences()) {
    _initHive();
  }

  Future<void> _initHive() async {
    _box = await Hive.openBox(_boxName);
    _loadPreferences();
  }

  void _loadPreferences() {
    final data = _box.get(_key);
    if (data != null) {
      try {
        state = ThemePreferences.fromJson(Map<String, dynamic>.from(data));
      } catch (e) {
        // If loading fails, keep default preferences
      }
    }
  }

  Future<void> _savePreferences() async {
    await _box.put(_key, state.toJson());
  }

  void setThemeVariant(ThemeVariant variant) {
    state = state.copyWith(themeVariant: variant);
    _savePreferences();
  }

  void setDynamicColor(bool enabled) {
    state = state.copyWith(useDynamicColor: enabled);
    _savePreferences();
  }

  void setExpressiveComponents(bool enabled) {
    state = state.copyWith(useExpressiveComponents: enabled);
    _savePreferences();
  }

  void setSeedColor(Color? color) {
    state = state.copyWith(seedColor: color);
    _savePreferences();
  }

  void clearSeedColor() {
    state = state.copyWith(seedColor: null);
    _savePreferences();
  }

  ThemeMode get themeMode {
    switch (state.themeVariant) {
      case ThemeVariant.light:
      case ThemeVariant.lightHighContrast:
        return ThemeMode.light;
      case ThemeVariant.dark:
      case ThemeVariant.amoled:
      case ThemeVariant.darkHighContrast:
        return ThemeMode.dark;
      case ThemeVariant.system:
        return ThemeMode.system;
    }
  }

  bool get shouldUseAmoled => state.themeVariant == ThemeVariant.amoled;
  bool get shouldUseLightHighContrast => state.themeVariant == ThemeVariant.lightHighContrast;
  bool get shouldUseDarkHighContrast => state.themeVariant == ThemeVariant.darkHighContrast;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemePreferences>((ref) {
  return ThemeNotifier();
});

// Helper provider for getting the current theme mode
final themeModeProvider = Provider<ThemeMode>((ref) {
  final themeNotifier = ref.watch(themeProvider.notifier);
  return themeNotifier.themeMode;
});
