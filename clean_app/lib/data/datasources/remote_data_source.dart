import 'dart:convert';
import 'package:http/http.dart' as http;

class RemoteDataSource {
  final String apiKey;

  RemoteDataSource({required this.apiKey});

  Future<Map<String, dynamic>> searchAiImages(String prompt) async {
    final response = await http.get(
      Uri.parse('https://lexica.art/api/v1/search?q=$prompt'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load images');
    }
  }
}
