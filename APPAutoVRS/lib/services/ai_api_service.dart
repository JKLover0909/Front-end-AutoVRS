// lib/services/ai_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AIApiService {
  static const String baseUrl = 'http://localhost:8000/api';

  static Future<Map<String, dynamic>> uploadImage({
    required String imagePath,
    int? boardId,
    bool manualMode = true,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/ai/upload-image'),
      );

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('file', imagePath),
      );

      // Add parameters
      if (boardId != null) {
        request.fields['board_id'] = boardId.toString();
      }
      request.fields['manual_mode'] = manualMode.toString();

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        throw Exception('Upload failed: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }

  static Future<Map<String, dynamic>> runInference({
    required String imagePath,
    int? boardId,
    bool saveResults = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/run-inference'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'image_path': imagePath,
          'board_id': boardId,
          'save_results': saveResults,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Inference failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Inference error: $e');
    }
  }

  static Future<Map<String, dynamic>> runManualInspection({
    required String imagePath,
    int? boardId,
  }) async {
    try {
      print('[DEBUG] Starting manual inspection for: $imagePath');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/ai/manual-inspection'),
      );

      // Add file with explicit content type
      var file = await http.MultipartFile.fromPath(
        'file', 
        imagePath,
        contentType: MediaType('image', 'jpeg'), // Set explicit content type
      );
      request.files.add(file);

      // Add parameters
      if (boardId != null) {
        request.fields['board_id'] = boardId.toString();
      }

      print('[DEBUG] Sending request to: ${request.url}');
      print('[DEBUG] File content type: ${file.contentType}');
      var response = await request.send().timeout(const Duration(seconds: 60));
      var responseBody = await response.stream.bytesToString();

      print('[DEBUG] Response status: ${response.statusCode}');
      print('[DEBUG] Response body: $responseBody');

      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        throw Exception('Manual inspection failed: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      print('[ERROR] Manual inspection error: $e');
      throw Exception('Manual inspection error: $e');
    }
  }

  static Future<Map<String, dynamic>> getInferenceHistory(int boardId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ai/inference-history/$boardId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('History error: $e');
    }
  }

  static Future<Map<String, dynamic>> testAIInference() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ai/test-inference'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Test failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Test error: $e');
    }
  }

  static String getImageUrl(String filename) {
    return '$baseUrl/ai/images/$filename';
  }
}
