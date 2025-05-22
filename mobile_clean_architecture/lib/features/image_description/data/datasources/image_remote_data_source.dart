import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_clean_architecture/core/constants/api_constants.dart';
import 'package:mobile_clean_architecture/core/error/exceptions.dart';
import 'package:mobile_clean_architecture/features/image_description/data/models/feedback_model.dart';
import 'package:mobile_clean_architecture/features/image_description/data/models/feedback_request.dart';
import 'package:mobile_clean_architecture/features/image_description/data/models/image_model.dart';

/// Data source interface for fetching image data from API
abstract class ImageRemoteDataSource {
  /// Get a list of practice images with descriptions
  Future<List<ImageModel>> getPracticeImages();

  /// Get image data by its ID
  Future<String> getImageUrl(String imageId);

  /// Submit user's description and get feedback
  Future<ImageFeedbackModel> getImageFeedback(ImageFeedbackRequest request);
}

/// Implementation of ImageRemoteDataSource that fetches data from a remote API
class ImageRemoteDataSourceImpl implements ImageRemoteDataSource {
  final http.Client client;

  /// Creates an ImageRemoteDataSourceImpl instance with an HTTP client
  ImageRemoteDataSourceImpl({required this.client});
  @override
  Future<List<ImageModel>> getPracticeImages() async {
    try {
      final response = await client
          .get(
            Uri.parse(
                ApiConstants.baseUrl + ApiConstants.imagesPracticeEndpoint),
            headers: ApiConstants.authHeaders,
          )
          .timeout(const Duration(seconds: ApiConstants.timeoutDuration));

      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to load practice images', statusCode: response.statusCode);
      }

      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => ImageModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to load practice images: ${e.toString()}');
    }
  }

  @override
  Future<String> getImageUrl(String imageId) async {
    // Since we're fetching an actual image file, we'll return the URL to be used
    // in an Image widget rather than fetching the binary data here
    return ApiConstants.baseUrl +
        ApiConstants.imageByIdEndpoint.replaceFirst('{image_id}', imageId);
  }
  @override
  Future<ImageFeedbackModel> getImageFeedback(
      ImageFeedbackRequest request) async {
    try {
      final response = await client
          .post(
            Uri.parse(
                ApiConstants.baseUrl + ApiConstants.imageFeedbackEndpoint),
            headers: ApiConstants.authHeaders,
            body: json.encode(request.toJson()),
          )
          .timeout(const Duration(seconds: ApiConstants.timeoutDuration));
          
      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to get image feedback', statusCode: response.statusCode);
      }

      final Map<String, dynamic> jsonData = json.decode(response.body);
      return ImageFeedbackModel.fromJson(jsonData);
    } catch (e) {
      throw ServerException(message: 'Failed to get image feedback: ${e.toString()}');
    }
  }
}
