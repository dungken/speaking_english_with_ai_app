import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/describe_image_controller.dart';
import '../../model/describe_image_model.dart';

class DescribeImageScreen extends StatelessWidget {
  final controller = Get.put(DescribeImageController());

  DescribeImageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Describe Image'),
        leading: IconButton(
          icon: const Icon(Icons.history),
          onPressed: () => controller.showHistoryPanel.value = !controller.showHistoryPanel.value,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.withOpacity(0.1),
              Colors.pink.shade100.withOpacity(0.2),
            ],
          ),
        ),
        child: Row(
          children: [
            // History panel
            Obx(() => controller.showHistoryPanel.value
                ? Container(
                    width: 250,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.purple.withOpacity(0.3),
                          Colors.blue.withOpacity(0.3),
                          Colors.red.shade900.withOpacity(0.2),
                        ],
                      ),
                      border: Border(
                        right: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // History header
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.black.withOpacity(0.5)
                                : Colors.white.withOpacity(0.9),
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'History',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => controller.showHistoryPanel.value = false,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                        // History list
                        Expanded(
                          child: Obx(() => controller.history.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No history yet',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: controller.history.length,
                                  itemBuilder: (context, index) {
                                    final item = controller.history[index];
                                    return _buildHistoryItem(context, item);
                                  },
                                )),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink()),
            
            // Main content
            Expanded(
              child: Column(
                children: [
                  // Image display area - limited to 50% of screen height
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Obx(() => controller.currentImage.value != null
                            ? Image.file(
                                controller.currentImage.value!,
                                fit: BoxFit.cover,
                              )
                            : const Center(
                                child: Text('No image loaded'),
                              )),
                      ),
                    ),
                  ),
                  
                  // Spacer to push input section to bottom
                  const Spacer(),
                  
                  // Input section with gradient background
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.purple.withOpacity(0.3),
                          Colors.blue.withOpacity(0.3),
                          Colors.red.shade900.withOpacity(0.2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Robot icon at the top-left of the input bar
                        Row(
                          children: [
                            Obx(() => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.smart_toy,
                                      size: 28,
                                      color: controller.hasNewFeedback.value
                                          ? Colors.green
                                          : Theme.of(context).iconTheme.color,
                                    ),
                                    onPressed: controller.showFeedbackScreen,
                                    tooltip: 'View Feedback',
                                  ),
                                  if (controller.hasNewFeedback.value)
                                    const Text(
                                      'Awesome! Let\'s check out the results!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                ],
                              ),
                            )),
                            const Spacer(),
                          ],
                        ),
                        
                        // Input field with icons
                        TextField(
                          controller: controller.descriptionController,
                          decoration: InputDecoration(
                            hintText: 'Describe the image...',
                            alignLabelWithHint: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.white.withOpacity(0.8),
                            prefixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Clear button
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: controller.clearInput,
                                  tooltip: 'Clear',
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  constraints: const BoxConstraints(),
                                ),
                                // Generate image button
                                IconButton(
                                  icon: const Icon(Icons.image, size: 20),
                                  onPressed: controller.generateImage,
                                  tooltip: 'Generate Image',
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Send button
                                IconButton(
                                  icon: const Icon(Icons.send, size: 20),
                                  onPressed: controller.submitDescription,
                                  tooltip: 'Send',
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                          maxLines: 3,
                          minLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, ImageDescription item) {
    return InkWell(
      onTap: () => controller.loadImageFromHistory(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Image #${item.id}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(item.aiScore),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${item.aiScore}/10',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              item.userDescription ?? 'No description',
              style: const TextStyle(fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(item.createdAt),
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
} 