import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helper/api_config.dart';

/// Authentication API service that handles user login and registration.
///
/// This class provides methods to interact with the backend authentication endpoints.
/// For development purposes, it uses hardcoded credentials, but in production
/// it should use actual user input.
class AuthApi {
  final String baseUrl = ApiConfig.baseUrl;

  /// Authenticates a user with email and password.
  ///
  /// For development, uses hardcoded credentials:
  /// - email: "<email store in mongodb>"
  /// - password: "password store in mongodb"
  ///
  /// Returns a Map containing the authentication token and user data.
  /// Throws an exception if authentication fails.
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': "demo@gmail.com", // default value for development
          'password': "Nguyenminhnhatzzsi4@@", // default value for development
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

// TODO: Implement register API
  // Future<Map<String, dynamic>> register({
  //   required String name,
  //   required String email,
  //   required String password,
  // }) async {

  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/users/register'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'name': name,
  //         'email': email,
  //         'password': password,
  //       }),
  //     );

  //     if (response.statusCode == 201) {
  //       return jsonDecode(response.body);
  //     } else {
  //       throw Exception('Failed to register: ${response.body}');
  //     }
  //   } catch (e) {
  //     throw Exception('Network error: $e');
  //   }
  // }
}
