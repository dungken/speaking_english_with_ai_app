import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/describe_image_model.dart';
import '../screen/feature/describe_image_feedback_screen.dart';
import '../screen/feature/describe_image_history_screen.dart';

class DescribeImageController extends GetxController {
  final descriptionController = TextEditingController();
  final currentImage = Rx<File?>(null);
  final currentImageIndex = 0.obs;
  final isLiked = false.obs;
  
  // Feedback properties
  final showFeedback = false.obs;
  final aiScore = 0.0.obs;
  final mistakes = ''.obs;
  final suggestions = ''.obs;
  
  // Robot animation properties
  final isRobotPulsing = false.obs;
  final hasNewFeedback = false.obs;
  
  // History
  final history = <ImageDescription>[].obs;
  final showHistoryPanel = false.obs;
  
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
    
    // Simulate AI processing
    _simulateAIProcessing();
  }

  void _simulateAIProcessing() {
    // Show loading indicator
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );
    
    // Simulate processing delay
    Future.delayed(const Duration(seconds: 2), () {
      // Close loading dialog
      Get.back();
      
      // Generate mock feedback
      aiScore.value = 8.5;
      mistakes.value = 'Minor grammar issues in the third sentence.';
      suggestions.value = 'Try using more descriptive adjectives and vary your sentence structure.';
      
      // Add to history
      history.add(
        ImageDescription(
          id: '${history.length + 1}',
          imageUrl: 'https://example.com/image${currentImageIndex.value + 1}.jpg',
          userDescription: descriptionController.text,
          aiScore: aiScore.value,
          createdAt: DateTime.now(),
        ),
      );
      
      // Trigger robot animation
      hasNewFeedback.value = true;
      _startRobotPulsing();
    });
  }

  void _startRobotPulsing() {
    isRobotPulsing.value = true;
    
    // Stop pulsing after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      isRobotPulsing.value = false;
    });
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

  void showFeedbackScreen() {
    // Navigate to feedback screen
    Get.to(() => DescribeImageFeedbackScreen());
  }

  void retryCurrentImage() {
    // Clear the input but keep the same image
    descriptionController.clear();
    hasNewFeedback.value = false;
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

  void showHistory() {
    // Navigate to history screen
    Get.to(() => DescribeImageHistoryScreen());
  }

  void loadImageFromHistory(ImageDescription item) {
    // TODO: Implement loading image from history
    // For now, just show a snackbar
    Get.snackbar(
      'Info',
      'Loading image ${item.id} from history',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }
} 