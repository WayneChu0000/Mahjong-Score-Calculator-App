import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'services/settings_service.dart';
import 'services/score_service.dart'; 
import 'localization/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase first to avoid "No Firebase App" errors
  await Firebase.initializeApp();
  
  // Initialize other services
  _initializeOtherServices();
  
  runApp(const MyApp());
}

// Initialize other services in background
void _initializeOtherServices() async {
  try {
    await Future.wait([
      SettingsService.instance.init(),
      _initializeScoreService(),
    ]);
  } catch (e) {
    debugPrint('Service initialization warning: $e');
  }
}

Future<void> _initializeScoreService() async {
  // Lazy initialize ScoreService
  ScoreService();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SettingsService _settings = SettingsService.instance;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {});
  }

  ThemeMode _getThemeMode() {
    switch (_settings.theme) {
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
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.appTitle,
      themeMode: _getThemeMode(),
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        // cardTheme: const CardTheme(
        //   color: Color(0xFF2C2C2C),
        //   elevation: 4,
        // ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          foregroundColor: Colors.white,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.green.withOpacity(0.2),
          labelStyle: const TextStyle(color: Colors.white),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.dark(
          primary: Colors.green,
          secondary: Colors.amber,
          surface: Colors.grey.shade900,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}