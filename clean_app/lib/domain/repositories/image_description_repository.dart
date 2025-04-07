import '../models/image_description.dart';

abstract class ImageDescriptionRepository {
  Future<List<ImageDescription>> getImageDescriptions();
  Future<ImageDescription> getImageDescription(String id);
  Future<ImageDescription> createImageDescription(
      ImageDescription imageDescription);
  Future<ImageDescription> updateImageDescription(
      ImageDescription imageDescription);
  Future<void> deleteImageDescription(String id);
  Future<double> getAiScore(String description);
  Future<String> getAiFeedback(String description);
  Future<String> generateImage(String prompt);
}
