import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationProvider extends StateNotifier<Locale> {
  LocalizationProvider() : super(const Locale('en', 'US')) {
    _loadSavedLanguage();
  }

  static const String _languageKey = 'selected_language';

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      
      if (languageCode != null) {
        if (languageCode == 'ar') {
          state = const Locale('ar', 'SA');
        } else {
          state = const Locale('en', 'US');
        }
      }
    } catch (e) {
      // If there's an error loading, keep default English
      state = const Locale('en', 'US');
    }
  }

  Future<void> setLanguage(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
      state = locale;
    } catch (e) {
      // Handle error silently, keep current state
    }
  }

  Future<void> setEnglish() async {
    await setLanguage(const Locale('en', 'US'));
  }

  Future<void> setArabic() async {
    await setLanguage(const Locale('ar', 'SA'));
  }

  bool get isArabic => state.languageCode == 'ar';
  bool get isEnglish => state.languageCode == 'en';

  Future<void> toggleLanguage() async {
    if (isArabic) {
      await setEnglish();
    } else {
      await setArabic();
    }
  }
}

final localizationProvider = StateNotifierProvider<LocalizationProvider, Locale>(
  (ref) => LocalizationProvider(),
);
