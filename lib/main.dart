import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'services/settings_service.dart';
import 'services/score_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Show splash screen without blocking UI
  runApp(const MyApp());
  
  // Initialize Firebase and other services in background
  _initializeServicesInBackground();
}

// Initialize services in background non-blocking
void _initializeServicesInBackground() async {
  try {
    // Initialize multiple services in parallel
    await Future.wait([
      _initializeFirebase(),
      SettingsService.instance.init(),
      _initializeScoreService(),
    ]);
  } catch (e) {
    // Log error but don't affect app startup
    debugPrint('Service initialization warning: $e');
  }
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
}

Future<void> _initializeScoreService() async {
  // Lazy initialize ScoreService
  ScoreService();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mahjong Score Calculator',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}