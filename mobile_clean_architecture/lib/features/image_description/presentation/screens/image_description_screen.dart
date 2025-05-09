import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_clean_architecture/features/image_description/presentation/widgets/demo_feedback_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/demo_feedback_widget.dart';

class ImageDescriptionScreen extends StatefulWidget {
  const ImageDescriptionScreen({super.key});

  @override
  State<ImageDescriptionScreen> createState() => _ImageDescriptionScreenState();
}

class _ImageDescriptionScreenState extends State<ImageDescriptionScreen> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  int _currentImageIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  
  final List<String> _images = [
    'assets/images/description5.png',
    'assets/images/description6.png',
    'assets/images/description7.png',
    'assets/images/description8.png',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    if (_isRecording) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
      }
    });
    // TODO: Implement actual recording logic
  }

  void _skipImage() {
    if (_currentImageIndex < _images.length - 1) {
      setState(() {
        _currentImageIndex++;
      });
    } else {
      // Show completion dialog or navigate back
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Perfect!'),
          content: const Text('You have completed the description of all the images!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Description'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: LinearProgressIndicator(
                value: (_currentImageIndex + 1) / _images.length,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              '${_currentImageIndex + 1}/${_images.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    _images[_currentImageIndex],
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
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
                    textAlign: TextAlign.center,
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
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(64),
                          onTap: _toggleRecording,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (_isRecording)
                                AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, child) {
                                    return Container(
                                      width: 64 * 1.15 * _pulseAnimation.value,
                                      height: 64 * 1.15 * _pulseAnimation.value,
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.2 * (1.2 - _pulseAnimation.value)),
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  },
                                ),
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: _isRecording
                                        ? [
                                            Colors.red[500]!,
                                            Colors.red[700]!,
                                          ]
                                        : [
                                            AppColors.primary,
                                            AppColors.primaryDark,
                                          ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isRecording ? Colors.red : AppColors.primary).withOpacity(0.3),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isRecording ? Icons.stop : Icons.mic,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
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
            // DemoFeedbackWidget(),
          ],
        ),
      ),
    );
  }
}
