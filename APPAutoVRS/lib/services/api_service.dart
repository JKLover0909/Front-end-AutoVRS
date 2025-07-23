// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  static const Duration timeout = Duration(seconds: 10);

  // System APIs
  static Future<Map<String, dynamic>> getSystemStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/system/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load system status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/system/dashboard'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load dashboard data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Models APIs
  static Future<List<dynamic>> getModels() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/models/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load models: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> createModel(Map<String, dynamic> modelData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/models/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(modelData),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create model: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Lots APIs
  static Future<List<dynamic>> getLots() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lots/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load lots: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Boards APIs
  static Future<List<dynamic>> getBoards() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/boards/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load boards: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Defects APIs
  static Future<List<dynamic>> getDefects() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/defects/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load defects: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Config APIs
  static Future<List<dynamic>> getConfigs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/config/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load configs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> updateConfig(String configKey, Map<String, dynamic> configData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/config/$configKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(configData),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update config: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
