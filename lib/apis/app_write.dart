import 'dart:developer';

import 'package:appwrite/appwrite.dart';

import '../helper/global.dart';

/// A class that handles **AppWrite database operations**.
///
/// This class is responsible for initializing the **AppWrite client** and
/// retrieving the **API key** from the AppWrite database.
class AppWrite {
  /// AppWrite client instance.
  static final _client = Client();

  /// AppWrite database instance for interacting with stored documents.
  static final _database = Databases(_client);

  /// Initializes the AppWrite client by setting the API endpoint and project ID.
  ///
  /// This method configures the **AppWrite client** and calls `getApiKey()`
  /// to fetch the stored API key from the database.
  static void init() {
    _client
        .setEndpoint('https://cloud.appwrite.io/v1') // AppWrite API endpoint.
        .setProject('658813fd62bd45e744cd') // Your project ID.
        .setSelfSigned(
            status: true); // Allow self-signed certificates (for development).

    // Fetch API key from the database after initialization.
    getApiKey();
  }

  /// Retrieves the API key from the **AppWrite database**.
  ///
  /// - The API key is stored in the database under:
  ///   - **Database ID**: `'MyDatabase'`
  ///   - **Collection ID**: `'ApiKey'`
  ///   - **Document ID**: `'chatGptKey'`
  ///
  /// - Returns: The API key as a `String`. If an error occurs, returns an empty string.
  static Future<String> getApiKey() async {
    try {
      // Fetch document containing the API key.
      final d = await _database.getDocument(
        databaseId: 'MyDatabase',
        collectionId: 'ApiKey',
        documentId: 'chatGptKey',
      );

      // Extract API key from document data.
      apiKey = d.data['apiKey'];

      // Log API key for debugging.
      log('Retrieved API Key: $apiKey');

      return apiKey;
    } catch (e) {
      // Log the error if the API key retrieval fails.
      log('Error in getApiKey: $e');
      return '';
    }
  }
}
