import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'services/settings_service.dart';
import 'services/score_service.dart'; // 添加這行

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 顯示啟動畫面，不阻塞 UI
  runApp(const MyApp());
  
  // 背景初始化 Firebase 和其他服務
  _initializeServicesInBackground();
}

// 在背景非阻塞地初始化服務
void _initializeServicesInBackground() async {
  try {
    // 並行初始化多個服務
    await Future.wait([
      _initializeFirebase(),
      SettingsService.instance.init(),
      _initializeScoreService(),
    ]);
  } catch (e) {
    // 記錄錯誤但不影響 App 啟動
    debugPrint('服務初始化警告: $e');
  }
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase 初始化失敗: $e');
  }
}

Future<void> _initializeScoreService() async {
  // 延遲初始化 ScoreService
  ScoreService();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '麻將計分器',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}