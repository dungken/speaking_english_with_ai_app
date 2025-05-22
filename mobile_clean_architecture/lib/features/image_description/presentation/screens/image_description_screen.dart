import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_clean_architecture/core/di/injection_container.dart';
import 'package:mobile_clean_architecture/core/theme/app_colors.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/entities/image_entity.dart';
import 'package:mobile_clean_architecture/features/image_description/presentation/cubit/image_description_cubit.dart';
import 'package:mobile_clean_architecture/features/image_description/presentation/widgets/demo_feedback_widget.dart';
import '../widgets/demo_feedback_widget.dart' show SimpleFeedbackWidget;

class ImageDescriptionScreen extends StatefulWidget {
  const ImageDescriptionScreen({super.key});

  @override
  State<ImageDescriptionScreen> createState() => _ImageDescriptionScreenState();
}

class _ImageDescriptionScreenState extends State<ImageDescriptionScreen>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  int _currentImageIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _showFeedback = false;
  List<ImageEntity> _images = [];
  String _currentDescription = '';

  // Using Cubit for state management
  final _imageCubit = sl<ImageDescriptionCubit>();

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

    // Load images from the API
    _imageCubit.loadPracticeImages();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      if (_isRecording) {
        _isRecording = false;
        _showFeedback = true;
        _animationController.stop();

        // When recording stops, submit the transcription for feedback
        if (_images.isNotEmpty) {
          _imageCubit.submitImageDescription(
            userId: 'current-user-id', // This should come from auth state
            imageId: _images[_currentImageIndex].id,
            description:
                _currentDescription, // This would come from the speech-to-text result
          );
        }
      } else {
        _isRecording = true;
        _showFeedback = false;
        _animationController.repeat(reverse: true);
      }
    });
    // TODO: Implement actual recording logic
  }

  void _skipImage() {
    if (_currentImageIndex < _images.length - 1) {
      setState(() {
        _currentImageIndex++;
        _showFeedback = false;
      });
    } else {
      // Show completion dialog or navigate back
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Perfect!'),
          content: const Text(
              'You have completed the description of all the images!'),
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
    if (_images.isEmpty) return;

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
              Text(
                _images[_currentImageIndex].detailDescription,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _imageCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Image Description'),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: BlocBuilder<ImageDescriptionCubit, ImageDescriptionState>(
            builder: (context, state) {
              if (state is ImageDescriptionInitial ||
                  state is ImageDescriptionLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ImageDescriptionLoaded) {
                _images = state.images;
                return _buildContent(context);
              } else if (state is ImageDescriptionError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.message}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _imageCubit.loadPracticeImages(),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              } else {
                // If we already loaded the images but are in another state (like ImageFeedbackLoaded)
                return _images.isNotEmpty
                    ? _buildContent(context)
                    : const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_images.isEmpty) {
      return const Center(child: Text('No practice images available'));
    }

    return SingleChildScrollView(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FutureBuilder<String?>(
                  future: _imageCubit
                      .getImageUrlById(_images[_currentImageIndex].id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData && snapshot.data != null) {
                      return Image.network(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                              child: Text('Error loading image'));
                        },
                      );
                    } else {
                      return const Center(child: Text('Image not available'));
                    }
                  },
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
                                      color: Colors.red.withOpacity(
                                          0.2 * (1.2 - _pulseAnimation.value)),
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
                                    color: (_isRecording
                                            ? Colors.red[500]!
                                            : AppColors.primary)
                                        .withOpacity(0.3),
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
          if (_showFeedback) ...[
            const SizedBox(height: 16),
            const SimpleFeedbackWidget(),
          ],
        ],
      ),
    );
  }
}
