import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helper/pref.dart';
import '../helper/logger.dart';

class ApiService {
  static const String baseUrl =
      'http://127.0.0.1:8000/api'; // For Android emulator
  // static const String baseUrl = 'http://localhost:8000/api'; // For iOS simulator

  // Login
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    const endpoint = '/users/login';
    final body = {
      'email': email,
      'password': password,
    };

    try {
      Logger.api('POST', endpoint, body: {'email': email});

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      Logger.api('POST', endpoint,
          response: data); // Log full response for debugging

      if (response.statusCode == 200) {
        // Store the token
        await Pref.setToken(data['access_token']);

        // Get user profile after successful login
        final userProfile = await getUserProfile();

        return {
          'access_token': data['access_token'],
          'user': userProfile['user'], // Use profile data for user info
        };
      } else {
        Logger.api('POST', endpoint, error: data['detail']);
        throw Exception(data['detail'] ?? 'Login failed');
      }
    } catch (e) {
      Logger.api('POST', endpoint, error: e.toString());
      throw Exception('Failed to login: $e');
    }
  }

  // Register
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    const endpoint = '/users/register';
    final body = {
      'name': name,
      'email': email,
      'password': password,
    };

    try {
      Logger.api('POST', endpoint, body: body);

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        Logger.api('POST', endpoint, response: data);
        // Store the token
        await Pref.setToken(data['access_token']);
        return data;
      } else {
        Logger.api('POST', endpoint, error: data['detail']);
        throw Exception(data['detail']);
      }
    } catch (e) {
      Logger.api('POST', endpoint, error: e.toString());
      throw Exception('Failed to register: $e');
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    const endpoint = '/users/me';

    try {
      final token = await Pref.getToken();
      if (token == null) throw Exception('No token found');

      Logger.api('GET', endpoint);

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Logger.api('GET', endpoint, response: data);
        return data;
      } else {
        Logger.api('GET', endpoint, error: data['detail']);
        throw Exception(data['detail']);
      }
    } catch (e) {
      Logger.api('GET', endpoint, error: e.toString());
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? avatar,
  }) async {
    const endpoint = '/users/update';
    final body = {
      'name': name,
      if (avatar != null) 'avatar': avatar,
    };

    try {
      final token = await Pref.getToken();
      if (token == null) throw Exception('No token found');

      Logger.api('PUT', endpoint, body: body);

      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Logger.api('PUT', endpoint, response: data);
        return data;
      } else {
        Logger.api('PUT', endpoint, error: data['detail']);
        throw Exception(data['detail']);
      }
    } catch (e) {
      Logger.api('PUT', endpoint, error: e.toString());
      throw Exception('Failed to update profile: $e');
    }
  }
}
