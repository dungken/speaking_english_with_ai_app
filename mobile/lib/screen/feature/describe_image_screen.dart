import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/describe_image_controller.dart';

class DescribeImageScreen extends StatelessWidget {
  const DescribeImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DescribeImageController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Describe Image'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue.shade900.withOpacity(0.3)
                  : Colors.blue.shade50,
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.purple.shade900.withOpacity(0.3)
                  : Colors.purple.shade50,
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.red.shade900.withOpacity(0.2)
                  : Colors.red.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            // Image display area - limited to 50% of screen height
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Obx(() => controller.currentImage.value != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          controller.currentImage.value!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        child: Text('No image selected'),
                      )),
              ),
            ),

            // Action icons row - rearranged order
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Obx(() => IconButton(
                        icon: Icon(
                          Icons.thumb_up,
                          color: controller.isLiked.value
                              ? Colors.green
                              : Colors.grey,
                        ),
                        onPressed: controller.onLike,
                      )),
                  Obx(() => IconButton(
                        icon: Icon(
                          Icons.thumb_down,
                          color: !controller.isLiked.value
                              ? Colors.red
                              : Colors.grey,
                        ),
                        onPressed: controller.onDislike,
                      )),
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: controller.onPrevious,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: controller.onNext,
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: controller.toggleFeedback,
                  ),
                ],
              ),
            ),

            // Feedback display area
            Obx(() => controller.showFeedback.value
                ? Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.purple.shade900.withOpacity(0.2)
                          : Colors.purple.shade100.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.purple.shade700.withOpacity(0.3)
                            : Colors.purple.shade300.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Feedback',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Score: ${controller.aiScore.value}/10',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Mistakes:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(controller.mistakes.value),
                        const SizedBox(height: 8),
                        const Text(
                          'Suggestions:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(controller.suggestions.value),
                      ],
                    ),
                  )
                : const Spacer()),

            // Input section with enhanced background
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.purple.shade900.withOpacity(0.3)
                    : Colors.purple.shade100.withOpacity(0.7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Input bar with vertically stacked icons
                  TextField(
                    controller: controller.descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Describe the image...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.white,
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: controller.clearInput,
                      ),
                      suffixIcon: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.image),
                            onPressed: controller.generateImage,
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: controller.submitDescription,
                          ),
                        ],
                      ),
                      contentPadding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: 16,
                      ),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 