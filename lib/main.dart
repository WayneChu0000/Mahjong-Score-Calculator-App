import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'services/settings_service.dart';
import 'services/score_service.dart'; // 添加這行

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化 Firebase（Android 需要 google-services.json 已到位）
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // 初始化失敗時記錄，但不中斷 App 啟動，方便先跑其他功能
  }
  
  // 初始化設定服務
  await SettingsService.instance.init();
  
  // 確保 ScoreService 實例已創建
  ScoreService(); // 這將調用工廠建構函數，確保單例被創建
  
  runApp(const MyApp());
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
      home: const HomePage(),
    );
  }
}