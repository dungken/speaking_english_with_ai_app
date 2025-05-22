/// Class representing the request for submitting feedback on an image description
class ImageFeedbackRequest {
  /// The user's ID
  final String userId;

  /// The ID of the image
  final String imageId;

  /// The user's transcription/description of the image
  final String userTranscription;

  /// Creates an ImageFeedbackRequest instance
  const ImageFeedbackRequest({
    required this.userId,
    required this.imageId,
    required this.userTranscription,
  });

  /// Converts this request to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'image_id': imageId,
      'user_transcription': userTranscription,
    };
  }
}
