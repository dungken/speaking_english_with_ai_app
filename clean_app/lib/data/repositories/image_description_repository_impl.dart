import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/image_description.dart';
import '../../domain/repositories/image_description_repository.dart';

class ImageDescriptionRepositoryImpl implements ImageDescriptionRepository {
  final String baseUrl;
  final http.Client client;

  ImageDescriptionRepositoryImpl({
    this.baseUrl = 'https://api.example.com',
    http.Client? client,
  }) : client = client ?? http.Client();

  // Mock data for testing
  final List<ImageDescription> _mockImageDescriptions = [
    ImageDescription(
      id: '1',
      imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
      createdAt: DateTime.now(),
    ),
    ImageDescription(
      id: '2',
      imageUrl: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470',
      createdAt: DateTime.now(),
    ),
    ImageDescription(
      id: '3',
      imageUrl: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<ImageDescription>> getImageDescriptions() async {
    // Return mock data instead of making API call
    return _mockImageDescriptions;
  }

  @override
  Future<ImageDescription> getImageDescription(String id) async {
    // Return mock data instead of making API call
    final image = _mockImageDescriptions.firstWhere(
      (img) => img.id == id,
      orElse: () => throw Exception('Image not found'),
    );
    return image;
  }

  @override
  Future<ImageDescription> createImageDescription(
      ImageDescription imageDescription) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    return imageDescription;
  }

  @override
  Future<ImageDescription> updateImageDescription(
      ImageDescription imageDescription) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    return imageDescription;
  }

  @override
  Future<void> deleteImageDescription(String id) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<double> getAiScore(String description) async {
    // Simulate API call with random score
    await Future.delayed(const Duration(milliseconds: 500));
    return 7.5 + (DateTime.now().millisecond % 25) / 10;
  }

  @override
  Future<String> getAiFeedback(String description) async {
    // Simulate API call with mock feedback
    await Future.delayed(const Duration(milliseconds: 500));
    return 'Your description is good, but you could add more details about the colors and composition.';
  }

  @override
  Future<String> generateImage(String prompt) async {
    // Simulate API call with mock image URL
    await Future.delayed(const Duration(milliseconds: 1000));
    return 'https://images.unsplash.com/photo-1506744038136-46273834b3fb';
  }
}
