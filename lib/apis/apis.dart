import 'dart:convert';
import 'dart:developer';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart';
import 'package:translator_plus/translator_plus.dart';

import '../helper/global.dart';

/// A class that provides various APIs for AI-related operations such as
/// generating text responses using Google Gemini AI, searching AI-generated
/// images, and translating text using Google Translate.
class APIs {
  /// Fetches an AI-generated response from **Google Gemini AI**.
  ///
  /// - [question]: The input query for the AI model.
  /// - Returns: The AI-generated response as a `String`.
  static Future<String> getAnswer(String question) async {
    try {
      log('API Key: $apiKey'); // Logs the API key for debugging.

      // Initializes the Gemini AI model with the specified API key.
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
      );

      // Prepares the content for AI processing.
      final content = [Content.text(question)];

      // Calls the AI model to generate content while enforcing safety settings.
      final res = await model.generateContent(content, safetySettings: [
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
      ]);

      log('Response: ${res.text}'); // Logs the AI-generated response.

      return res.text ?? 'No response received!';
    } catch (e) {
      log('Error in getAnswer: $e');
      return 'Something went wrong (Try again later)';
    }
  }

  /*
  // Alternative method to get an AI-generated response from **OpenAI ChatGPT**.
  // This method is currently commented out but can be used if required.

  static Future<String> getAnswer(String question) async {
    try {
      log('API Key: $apiKey');

      // Sends a request to OpenAI's chat completion API.
      final res = await post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        
        // Headers for authentication and content type.
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $apiKey'
        },
        
        // Body content including model name, max tokens, and user query.
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "max_tokens": 2000,
          "temperature": 0,
          "messages": [
            {"role": "user", "content": question},
          ]
        }),
      );

      // Parses the response data.
      final data = jsonDecode(res.body);
      log('Response: $data');

      // Extracts the AI-generated content.
      return data['choices'][0]['message']['content'];
    } catch (e) {
      log('Error in getAnswer (GPT): $e');
      return 'Something went wrong (Try again later)';
    }
  }
  */

  /// Searches for AI-generated images based on the given [prompt].
  ///
  /// - Uses Lexica API to search for AI-generated images related to the prompt.
  /// - Returns: A `List<String>` containing image URLs.
  static Future<List<String>> searchAiImages(String prompt) async {
    try {
      // Sends a GET request to the Lexica API with the provided prompt.
      final res =
          await get(Uri.parse('https://lexica.art/api/v1/search?q=$prompt'));

      // Decodes the JSON response.
      final data = jsonDecode(res.body);

      // Extracts and returns a list of image URLs.
      return List.from(data['images']).map((e) => e['src'].toString()).toList();
    } catch (e) {
      log('Error in searchAiImages: $e');
      return [];
    }
  }

  /// Translates the given [text] from the source language [from] to the target language [to].
  ///
  /// - Uses the `translator_plus` package for translation.
  /// - Returns: The translated text as a `String`.
  static Future<String> googleTranslate({
    required String from,
    required String to,
    required String text,
  }) async {
    try {
      // Uses GoogleTranslator to translate the given text.
      final res = await GoogleTranslator().translate(text, from: from, to: to);

      return res.text;
    } catch (e) {
      log('Error in googleTranslate: $e');
      return 'Something went wrong!';
    }
  }
}
