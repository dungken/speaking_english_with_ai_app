import 'dart:developer';
import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../apis/apis.dart';
import '../helper/global.dart';
import '../helper/my_dialog.dart';

/// Enum representing the status of image generation and processing.
enum Status { none, loading, complete }

/// Controller for AI-generated image functionalities.
///
/// This class manages:
/// - AI image creation using OpenAI's API.
/// - Downloading generated images to the gallery.
/// - Sharing images via social media.
/// - Searching AI-generated images from external sources.
class ImageController extends GetxController {
  /// Controller for managing text input.
  final textC = TextEditingController();

  /// Observable status of the image generation process.
  final status = Status.none.obs;

  /// Observable variable to store the generated image URL.
  final url = ''.obs;

  /// Observable list to store search results for AI-generated images.
  final imageList = <String>[].obs;

  /// Generates an AI image based on user input.
  ///
  /// - Uses OpenAI's API with the given prompt from `textC.text`.
  /// - Updates the `status` to `loading` while fetching the image.
  /// - Stores the image URL in `url` after successful generation.
  /// - If the input is empty, it shows a warning dialog.
  Future<void> createAIImage() async {
    if (textC.text.trim().isNotEmpty) {
      OpenAI.apiKey = apiKey;
      status.value = Status.loading;

      try {
        // Request AI to generate an image
        OpenAIImageModel image = await OpenAI.instance.image.create(
          prompt: textC.text,
          n: 1,
          size: OpenAIImageSize.size512,
          responseFormat: OpenAIImageResponseFormat.url,
        );

        // Store the image URL
        url.value = image.data[0].url.toString();
        status.value = Status.complete;
      } catch (e) {
        log('createAIImageError: $e');
        MyDialog.error('Image generation failed. Try again later.');
        status.value = Status.none;
      }
    } else {
      MyDialog.info('Provide some beautiful image description!');
    }
  }

  /// Downloads the generated AI image to the gallery.
  ///
  /// - Fetches the image bytes from `url`.
  /// - Saves the image file to a temporary directory.
  /// - Moves the image to the device gallery using `GallerySaver`.
  /// - Shows a success or error dialog based on the result.
  void downloadImage() async {
    try {
      MyDialog.showLoadingDialog();

      log('Downloading image from URL: $url');

      final bytes = (await get(Uri.parse(url.value))).bodyBytes;
      final dir = await getTemporaryDirectory();
      final file = await File('${dir.path}/ai_image.png').writeAsBytes(bytes);

      log('Saved file path: ${file.path}');

      // Save the image to the gallery
      await GallerySaver.saveImage(file.path, albumName: appName)
          .then((success) {
        Get.back(); // Hide loading dialog
        MyDialog.success('Image Downloaded to Gallery!');
      });
    } catch (e) {
      Get.back();
      MyDialog.error('Something Went Wrong (Try again later)!');
      log('downloadImageError: $e');
    }
  }

  /// Shares the generated AI image via social media.
  ///
  /// - Downloads the image to a temporary file.
  /// - Uses `Share.shareXFiles` to share the image with a message.
  void shareImage() async {
    try {
      MyDialog.showLoadingDialog();

      log('Sharing image from URL: $url');

      final bytes = (await get(Uri.parse(url.value))).bodyBytes;
      final dir = await getTemporaryDirectory();
      final file = await File('${dir.path}/ai_image.png').writeAsBytes(bytes);

      log('Saved file path for sharing: ${file.path}');

      Get.back(); // Hide loading dialog

      await Share.shareXFiles([XFile(file.path)],
          text: 'Check out this Amazing Image created by AI Assistant App!');
    } catch (e) {
      Get.back();
      MyDialog.error('Something Went Wrong (Try again later)!');
      log('shareImageError: $e');
    }
  }

  /// Searches for AI-generated images from an external API.
  ///
  /// - Calls `APIs.searchAiImages` with the given prompt.
  /// - Updates `imageList` with the search results.
  /// - Sets `url` to the first result for display.
  /// - Displays an error dialog if no results are found.
  Future<void> searchAiImage() async {
    if (textC.text.trim().isNotEmpty) {
      status.value = Status.loading;

      imageList.value = await APIs.searchAiImages(textC.text);

      if (imageList.isEmpty) {
        MyDialog.error('No images found. Try again later.');
        status.value = Status.none;
        return;
      }

      url.value = imageList.first;
      status.value = Status.complete;
    } else {
      MyDialog.info('Provide some beautiful image description!');
    }
  }
}
