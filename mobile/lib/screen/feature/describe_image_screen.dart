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
      body: Column(
        children: [
          // Image display area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
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

          // Action icons row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
                  icon: const Icon(Icons.more_vert),
                  onPressed: controller.showFeedback,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: controller.onNext,
                ),
                Obx(() => IconButton(
                      icon: Icon(
                        Icons.thumb_up,
                        color: controller.isLiked.value
                            ? Colors.green
                            : Colors.grey,
                      ),
                      onPressed: controller.onLike,
                    )),
              ],
            ),
          ),

          // Input section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Generate image button
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: controller.generateImage,
                  ),
                ),
                // Input bar
                TextField(
                  controller: controller.descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Describe the image...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: controller.clearInput,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: controller.submitDescription,
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 