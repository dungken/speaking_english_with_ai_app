import 'dart:convert';
import 'package:http/http.dart' as http;

/// API Client for handling network requests
class ApiClient {
  final String baseUrl;
  final Map<String, String> _headers;

  ApiClient({
    required this.baseUrl,
    Map<String, String>? headers,
  }) : _headers = headers ??
            {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            };

  /// Add authorization token to headers
  void setAuthToken(String token) {
    _headers['Authorization'] = 'Bearer $token';
  }

  /// Remove authorization token from headers
  void removeAuthToken() {
    _headers.remove('Authorization');
  }

  /// GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  /// POST request
  Future<Map<String, dynamic>> post(String endpoint,
      {Map<String, dynamic>? body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// PUT request
  Future<Map<String, dynamic>> put(String endpoint,
      {Map<String, dynamic>? body}) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  /// Handle API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }
}
