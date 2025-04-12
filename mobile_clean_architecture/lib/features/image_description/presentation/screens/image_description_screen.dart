import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ImageDescriptionScreen extends StatefulWidget {
  const ImageDescriptionScreen({super.key});

  @override
  State<ImageDescriptionScreen> createState() => _ImageDescriptionScreenState();
}

class _ImageDescriptionScreenState extends State<ImageDescriptionScreen> {
  bool _isRecording = false;
  int _currentImageIndex = 5;
  final int _totalImages = 20;

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    // TODO: Implement actual recording logic
  }

  void _skipImage() {
    if (_currentImageIndex < _totalImages) {
      setState(() {
        _currentImageIndex++;
      });
    }
  }

  void _viewSuggestedAnswer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Suggested Description',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This is a sample suggested description of the image. It would include details about the objects, people, actions, and context visible in the image.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Description'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: LinearProgressIndicator(
              value: _currentImageIndex / _totalImages,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            '$_currentImageIndex/$_totalImages',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('Image Placeholder'),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Describe what you see in this image',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      heroTag: 'skip',
                      onPressed: _skipImage,
                      backgroundColor: Colors.grey[200],
                      child: Icon(
                        Icons.skip_next,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    FloatingActionButton.large(
                      heroTag: 'record',
                      onPressed: _toggleRecording,
                      backgroundColor: _isRecording
                          ? Colors.red
                          : Theme.of(context).primaryColor,
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        size: 32,
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: 'answer',
                      onPressed: _viewSuggestedAnswer,
                      backgroundColor: Colors.grey[200],
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
