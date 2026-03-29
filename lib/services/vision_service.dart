import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

class VisionService {
  static String get _url => EnvConfig.visionApiUrl;
  static String get _apiKey => EnvConfig.visionApiKey;
  static String get _modelUrl => EnvConfig.visionModelUrl;
  static double get _conf => EnvConfig.visionConf;
  static double get _iou => EnvConfig.visionIou;
  static int get _imgsz => EnvConfig.visionImgsz;

  // Map model class names to app tile codes if necessary.
  // Assuming the model returns standard codes like '1m', '1s', '1z'.
  // We can add normalization here if the model returns things like 'bamboo_1'.

  static Future<List<String>> analyzeImage(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_url));
      if (_apiKey.isNotEmpty) {
        // Deployed endpoint uses Bearer auth; keep x-api-key for backward compatibility.
        request.headers['Authorization'] = 'Bearer $_apiKey';
        request.headers['x-api-key'] = _apiKey;
      }

      // Some endpoints require `model` (Ultralytics cloud), deployed endpoint may not.
      if (_modelUrl.isNotEmpty) {
        request.fields['model'] = _modelUrl;
      }
      request.fields['imgsz'] = _imgsz.toString();
      request.fields['conf'] = _conf.toString();
      request.fields['iou'] = _iou.toString();

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _extractDetectedTiles(data);
      } else {
        throw Exception(
          'Vision API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to analyze image: $e');
    }
  }

  static List<String> _extractDetectedTiles(dynamic data) {
    final detectedTiles = <String>[];

    // Format A: { images: [ { results: [ { name: ... } ] } ] }
    if (data is Map && data['images'] is List) {
      final images = data['images'] as List;
      if (images.isNotEmpty && images.first is Map) {
        final firstImage = images.first as Map;
        final results = firstImage['results'];
        if (results is List) {
          for (final result in results) {
            if (result is Map && result['name'] != null) {
              detectedTiles.add(result['name'].toString());
            }
          }
        }
      }
    }

    // Format B: { predictions: [ { name: ... } ] } or { data: [ { name: ... } ] }
    if (detectedTiles.isEmpty && data is Map) {
      final candidates = [data['predictions'], data['data'], data['results']];
      for (final candidate in candidates) {
        if (candidate is List) {
          for (final item in candidate) {
            if (item is Map && item['name'] != null) {
              detectedTiles.add(item['name'].toString());
            }
          }
          if (detectedTiles.isNotEmpty) break;
        }
      }
    }

    // Format C: direct list of detections
    if (detectedTiles.isEmpty && data is List) {
      for (final item in data) {
        if (item is Map && item['name'] != null) {
          detectedTiles.add(item['name'].toString());
        }
      }
    }

    return detectedTiles;
  }
}
