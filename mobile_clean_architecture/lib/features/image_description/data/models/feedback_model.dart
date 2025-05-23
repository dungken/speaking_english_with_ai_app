import 'package:mobile_clean_architecture/features/image_description/domain/entities/feedback_entity.dart';

/// ImageFeedbackModel represents feedback data returned from the API
class ImageFeedbackModel extends ImageFeedbackEntity {
  /// Creates an ImageFeedbackModel instance
  const ImageFeedbackModel({
    required super.betterVersion,
    required super.explanation,
  });

  /// Creates an ImageFeedbackModel instance from JSON data
  factory ImageFeedbackModel.fromJson(Map<String, dynamic> json) {
    return ImageFeedbackModel(
      betterVersion: json['better_version'] as String,
      explanation: json['explanation'] as String,
    );
  }

  /// Converts the ImageFeedbackModel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'better_version': betterVersion,
      'explanation': explanation,
    };
  }
}
