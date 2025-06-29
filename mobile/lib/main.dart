import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/utils/constants.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/localization_provider.dart';
import 'core/localization/app_localizations.dart';
import 'core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service (includes Hive initialization)
  await StorageService.init();
  
  // Set system UI overlay style for edge-to-edge display
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: CinemerApp(),
    ),
  );
}

class CinemerApp extends ConsumerWidget {
  const CinemerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themePreferences = ref.watch(themeProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // Use dynamic colors only if enabled in preferences
        final lightColorScheme = themePreferences.useDynamicColor ? lightDynamic : null;
        final darkColorScheme = themePreferences.useDynamicColor ? darkDynamic : null;
        
        // Select appropriate theme based on user preferences
        ThemeData lightTheme;
        ThemeData darkTheme;
        final seedColor = themePreferences.seedColor;
        
        if (themePreferences.shouldUseLightHighContrast) {
          lightTheme = AppTheme.lightHighContrastTheme(lightColorScheme, seedColor);
        } else {
          lightTheme = AppTheme.lightTheme(lightColorScheme, seedColor);
        }
        
        if (themePreferences.shouldUseAmoled) {
          darkTheme = AppTheme.amoledTheme(darkColorScheme, seedColor);
        } else if (themePreferences.shouldUseDarkHighContrast) {
          darkTheme = AppTheme.darkHighContrastTheme(darkColorScheme, seedColor);
        } else {
          darkTheme = AppTheme.darkTheme(darkColorScheme, seedColor);
        }
        
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          
          // Localization configuration
          locale: ref.watch(localizationProvider),
          localizationsDelegates: const [
            AppLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          
          theme: lightTheme,
          darkTheme: darkTheme,
          highContrastTheme: AppTheme.lightHighContrastTheme(lightColorScheme, seedColor),
          highContrastDarkTheme: AppTheme.darkHighContrastTheme(darkColorScheme, seedColor),
          themeMode: themeMode,
          routerConfig: router,
          builder: (context, child) {
            // Ensure proper text scaling and accessibility
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(
                  MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.3),
                ),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
