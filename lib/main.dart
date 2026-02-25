import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/env_config.dart';
import 'routes/app_routes.dart';
import 'routes/app_router.dart';
import 'services/settings_service.dart';
import 'services/score_service.dart'; 
import 'localization/app_localizations.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  await EnvConfig.init();
  
  // Initialize Firebase first to avoid "No Firebase App" errors
  await Firebase.initializeApp();
  
  // Initialize settings
  await SettingsService.instance.init();
  
  // Sync l10n with persisted language preference
  AppLocalizations.setLocale(SettingsService.instance.language);
  
  // Initialize score service
  ScoreService();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsService>.value(
          value: SettingsService.instance,
        ),
        ChangeNotifierProvider<ScoreService>.value(
          value: ScoreService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeMode _getThemeMode(SettingsService settings) {
    switch (settings.theme) {
      case 'Dark Mode':
        return ThemeMode.dark;
      case 'Light Mode':
        return ThemeMode.light;
      case 'Follow System':
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reactively rebuild when SettingsService changes (language, theme).
    final settings = context.watch<SettingsService>();

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: settings.language == 'Traditional Chinese'
          ? const Locale('zh')
          : const Locale('en'),
      themeMode: _getThemeMode(settings),
      theme: ThemeData(
        primarySwatch: AppColors.primarySwatch,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: AppColors.primarySwatch,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkScaffold,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkAppBar,
          foregroundColor: AppColors.onPrimary,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.primarySurfaceDark,
          labelStyle: const TextStyle(color: AppColors.white),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: Colors.grey.shade900,
        ),
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}