import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/describe_image_model.dart';

class DescribeImageController extends GetxController {
  final descriptionController = TextEditingController();
  final currentImage = Rx<File?>(null);
  final currentImageIndex = 0.obs;
  final isLiked = false.obs;
  
  // Mock data for testing - replace with actual data from backend
  final List<ImageDescription> mockImages = [
    ImageDescription(
      id: '1',
      imageUrl: 'https://example.com/image1.jpg',
      createdAt: DateTime.now(),
    ),
    ImageDescription(
      id: '2',
      imageUrl: 'https://example.com/image2.jpg',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    loadCurrentImage();
  }

  void loadCurrentImage() {
    // TODO: Replace with actual image loading from backend
    // For now, using mock data
    if (mockImages.isNotEmpty) {
      // Simulate loading image from URL
      // In real implementation, you would:
      // 1. Download the image
      // 2. Save it locally
      // 3. Set currentImage.value to the local file
    }
  }

  void clearInput() {
    descriptionController.clear();
  }

  void submitDescription() {
    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a description',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    // TODO: Implement submission logic
    // 1. Save description to backend
    // 2. Get AI feedback
    // 3. Update UI with feedback
  }

  void onLike() {
    isLiked.value = !isLiked.value;
    // TODO: Update like status in backend
  }

  void onDislike() {
    isLiked.value = !isLiked.value;
    // TODO: Update dislike status in backend
  }

  void onNext() {
    if (currentImageIndex.value < mockImages.length - 1) {
      currentImageIndex.value++;
      loadCurrentImage();
    } else {
      Get.snackbar(
        'Info',
        'You have reached the last image',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void onPrevious() {
    if (currentImageIndex.value > 0) {
      currentImageIndex.value--;
      loadCurrentImage();
    } else {
      Get.snackbar(
        'Info',
        'You are at the first image',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void showFeedback() {
    Get.dialog(
      AlertDialog(
        title: const Text('AI Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your description:'),
            const SizedBox(height: 8),
            Text(descriptionController.text),
            const SizedBox(height: 16),
            const Text('AI Score:'),
            const SizedBox(height: 8),
            const Text('8.5/10'),
            const SizedBox(height: 16),
            const Text('Feedback:'),
            const SizedBox(height: 8),
            const Text('Good description! You used appropriate vocabulary and grammar.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void generateImage() {
    // TODO: Implement image generation functionality
    // 1. Call AI image generation API
    // 2. Save generated image
    // 3. Update UI with new image
    Get.snackbar(
      'Info',
      'Image generation will be implemented with AI integration',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }
} 