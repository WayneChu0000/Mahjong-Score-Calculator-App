import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized environment configuration.
///
/// Values are resolved in order of priority:
/// 1. `--dart-define` compile-time flags (highest priority)
/// 2. `.env` file loaded at runtime via flutter_dotenv
/// 3. Fallback defaults (lowest priority)
///
/// Setup:
/// - Copy `.env.example` to `.env` and fill in real values.
/// - `.env` is git-ignored to prevent leaking secrets.
///
/// Example production build:
/// ```
/// flutter build apk \
///   --dart-define=VISION_API_KEY=your_key_here \
///   --dart-define=VISION_MODEL_URL=your_model_url
/// ```
class EnvConfig {
  /// Call once before accessing any values (typically in main()).
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }

  // ─── Vision AI Configuration ──────────────────────────────────────
  static String get visionApiUrl {
    const compileTime = String.fromEnvironment('VISION_API_URL');
    if (compileTime.isNotEmpty) return compileTime;
    return dotenv.env['VISION_API_URL'] ?? 'https://predict.ultralytics.com';
  }

  static String get visionApiKey {
    const compileTime = String.fromEnvironment('VISION_API_KEY');
    if (compileTime.isNotEmpty) return compileTime;
    return dotenv.env['VISION_API_KEY'] ?? '';
  }

  static String get visionModelUrl {
    const compileTime = String.fromEnvironment('VISION_MODEL_URL');
    if (compileTime.isNotEmpty) return compileTime;
    return dotenv.env['VISION_MODEL_URL'] ?? '';
  }

  static double get visionConf {
    const compileTime = String.fromEnvironment('VISION_CONF');
    if (compileTime.isNotEmpty) return double.tryParse(compileTime) ?? 0.25;
    return double.tryParse(dotenv.env['VISION_CONF'] ?? '') ?? 0.25;
  }

  static double get visionIou {
    const compileTime = String.fromEnvironment('VISION_IOU');
    if (compileTime.isNotEmpty) return double.tryParse(compileTime) ?? 0.7;
    return double.tryParse(dotenv.env['VISION_IOU'] ?? '') ?? 0.7;
  }

  static int get visionImgsz {
    const compileTime = String.fromEnvironment('VISION_IMGSZ');
    if (compileTime.isNotEmpty) return int.tryParse(compileTime) ?? 640;
    return int.tryParse(dotenv.env['VISION_IMGSZ'] ?? '') ?? 640;
  }
}
