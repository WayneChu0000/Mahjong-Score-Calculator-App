import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

class VisionService {
  static String get _url => EnvConfig.visionApiUrl;
  static String get _apiKey => EnvConfig.visionApiKey;
  static String get _modelUrl => EnvConfig.visionModelUrl;

  // Map model class names to app tile codes if necessary.
  // Assuming the model returns standard codes like '1m', '1s', '1z'.
  // We can add normalization here if the model returns things like 'bamboo_1'.

  static Future<List<String>> analyzeImage(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_url));
      request.headers['x-api-key'] = _apiKey;

      request.fields['model'] = _modelUrl;
      request.fields['imgsz'] = '640';
      request.fields['conf'] = '0.25';
      request.fields['iou'] = '0.45';

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // The response format from Ultralytics API usually contains an 'images' or 'data' array
        // containing detections.
        // Example structure:
        // { "images": [ { "results": [ { "name": "1m", "confidence": 0.9, ... } ] } ] }
        // We need to inspect the actual response structure to be sure,
        // but based on typical outputs we'll look for class names.

        List<String> detectedTiles = [];

        if (data is Map && data.containsKey('images')) {
          var images = data['images'];
          if (images is List && images.isNotEmpty) {
            var firstImage = images[0];
            if (firstImage is Map && firstImage.containsKey('results')) {
              var results = firstImage['results'];
              if (results is List) {
                for (var result in results) {
                  if (result is Map && result.containsKey('name')) {
                    detectedTiles.add(result['name'].toString());
                  }
                }
              }
            }
          }
        } else if (data is List) {
          // Sometimes it returns a direct list of results
          for (var item in data) {
            if (item is Map && item.containsKey('name')) {
              detectedTiles.add(item['name'].toString());
            }
          }
        }

        return detectedTiles;
      } else {
        throw Exception(
          'Vision API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to analyze image: $e');
    }
  }
}
