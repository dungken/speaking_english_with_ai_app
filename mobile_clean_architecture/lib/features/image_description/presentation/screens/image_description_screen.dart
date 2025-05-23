import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../domain/entities/image_entity.dart';
import '../cubit/image_description_cubit.dart';
import '../widgets/image_display_widget.dart';
import '../widgets/image_recording_button.dart';
import '../widgets/demo_feedback_widget.dart';

/// Screen for image description practice
///
/// This screen allows users to:
/// - View practice images
/// - Record audio descriptions
/// - Receive feedback on their descriptions
class ImageDescriptionScreen extends StatefulWidget {
  const ImageDescriptionScreen({super.key});

  @override
  State<ImageDescriptionScreen> createState() => _ImageDescriptionScreenState();
}

class _ImageDescriptionScreenState extends State<ImageDescriptionScreen> {
  late final ImageDescriptionCubit _cubit;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _cubit = sl<ImageDescriptionCubit>();
    _cubit.loadPracticeImages();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
        backgroundColor: AppColors.getBackgroundColor(isDarkMode),
        appBar: _buildAppBar(context, isDarkMode),
        body: SafeArea(
          child: BlocConsumer<ImageDescriptionCubit, ImageDescriptionState>(
            listener: _stateListener,
            builder: (context, state) => _buildBody(context, state, isDarkMode),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
      title: Text(
        'Image Description Practice',
        style: TextStyles.h2(context, isDarkMode: isDarkMode),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.help_outline,
            color: AppColors.primary,
          ),
          onPressed: _showHelpDialog,
        ),
      ],
    );
  }

  Widget _buildBody(
      BuildContext context, ImageDescriptionState state, bool isDarkMode) {
    if (state is ImageDescriptionInitial || state is ImageDescriptionLoading) {
      return _buildLoadingState(context, isDarkMode);
    }

    if (state is ImageDescriptionError) {
      return _buildErrorState(context, state.message, isDarkMode);
    }

    final images = _getImagesFromState(state);
    if (images.isEmpty) {
      return _buildEmptyState(context, isDarkMode);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProgressSection(context, images),
          _buildImageSection(context, state, images, isDarkMode),
          _buildInstructionSection(context, isDarkMode),
          _buildRecordingSection(context, state, images),
          _buildActionButtonsSection(context, state, images, isDarkMode),
          _buildFeedbackSection(context, state),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: ResponsiveLayout.getSectionSpacing(context)),
          Text(
            'Loading practice images...',
            style: TextStyles.body(context, isDarkMode: isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, String message, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveLayout.getCardPadding(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            SizedBox(height: ResponsiveLayout.getSectionSpacing(context)),
            Text(
              'Something went wrong',
              style: TextStyles.h2(context, isDarkMode: isDarkMode),
            ),
            SizedBox(height: ResponsiveLayout.getElementSpacing(context)),
            Text(
              message,
              style: TextStyles.body(context, isDarkMode: isDarkMode),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveLayout.getSectionSpacing(context)),
            ElevatedButton(
              onPressed: () => _cubit.loadPracticeImages(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Try Again',
                style: TextStyles.button(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 80,
            color: AppColors.getTextSecondaryColor(isDarkMode),
          ),
          SizedBox(height: ResponsiveLayout.getSectionSpacing(context)),
          Text(
            'No practice images available',
            style: TextStyles.h2(context, isDarkMode: isDarkMode),
          ),
          SizedBox(height: ResponsiveLayout.getElementSpacing(context)),
          Text(
            'Please check back later',
            style: TextStyles.body(context, isDarkMode: isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, List<ImageEntity> images) {
    if (images.isEmpty) return const SizedBox.shrink();

    return ImageProgressWidget(
      currentIndex: _currentImageIndex,
      totalImages: images.length,
    );
  }

  Widget _buildImageSection(BuildContext context, ImageDescriptionState state,
      List<ImageEntity> images, bool isDarkMode) {
    if (_currentImageIndex >= images.length) return const SizedBox.shrink();

    final currentImage = images[_currentImageIndex];

    return FutureBuilder<String?>(
      future: _cubit.getImageUrlById(currentImage.id),
      builder: (context, snapshot) {
        return ImageDisplayWidget(
          imageUrl: snapshot.data,
          isLoading: snapshot.connectionState == ConnectionState.waiting,
          errorMessage: snapshot.hasError ? 'Failed to load image' : null,
          onRetry: () => setState(() {}), // Trigger rebuild to retry
        );
      },
    );
  }

  Widget _buildInstructionSection(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveLayout.getCardPadding(context),
        vertical: ResponsiveLayout.getElementSpacing(context),
      ),
      child: Text(
        'Describe what you see in this image',
        style: TextStyles.h3(context, isDarkMode: isDarkMode),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRecordingSection(BuildContext context,
      ImageDescriptionState state, List<ImageEntity> images) {
    return ImageRecordingButton(
      isRecording: state is ImageRecordingStarted,
      isProcessing: state is ImageTranscriptionProcessing,
      onRecordingStarted: _startRecording,
      onRecordingStopped: _stopRecording,
      onRecordingCancelled: _cancelRecording,
    );
  }

  Widget _buildActionButtonsSection(BuildContext context,
      ImageDescriptionState state, List<ImageEntity> images, bool isDarkMode) {
    // Only show action buttons when not recording or processing
    if (state is ImageRecordingStarted ||
        state is ImageTranscriptionProcessing) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveLayout.getCardPadding(context),
        vertical: ResponsiveLayout.getElementSpacing(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Skip button
          _buildActionButton(
            context: context,
            icon: Icons.skip_next,
            label: 'Skip',
            onPressed: _canSkip(images) ? _skipImage : null,
            isDarkMode: isDarkMode,
          ),
          // View answer button
          _buildActionButton(
            context: context,
            icon: Icons.lightbulb_outline,
            label: 'View Answer',
            onPressed: _viewSuggestedAnswer,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isDarkMode,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed != null
            ? AppColors.getSurfaceColor(isDarkMode)
            : Colors.grey.shade300,
        foregroundColor: onPressed != null ? AppColors.primary : Colors.grey,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(
      BuildContext context, ImageDescriptionState state) {
    if (state is ImageFeedbackReceived) {
      return FeedbackDisplayWidget(
        userTranscription: state.transcription,
        feedback: state.feedback,
        onNext: _canSkip(_getImagesFromState(state))
            ? _skipImage
            : _completeSession,
      );
    }

    if (state is ImageTranscriptionCompleted) {
      return FeedbackDisplayWidget(
        userTranscription: state.transcription,
        feedback: null, // Loading state
      );
    }

    return const SizedBox.shrink();
  }

  // Event handlers
  void _stateListener(BuildContext context, ImageDescriptionState state) {
    if (state is ImageDescriptionError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
    }
  }

  void _startRecording() {
    _cubit.startRecording();
  }

  void _stopRecording() {
    final images = _getImagesFromState(_cubit.state);
    if (images.isNotEmpty && _currentImageIndex < images.length) {
      final currentImage = images[_currentImageIndex];
      _cubit.stopRecording(currentImage.id);
    }
  }

  void _cancelRecording() {
    _cubit.cancelRecording();
  }

  void _skipImage() {
    final images = _getImagesFromState(_cubit.state);
    if (_currentImageIndex < images.length - 1) {
      setState(() {
        _currentImageIndex++;
      });
      // Reset cubit to loaded state for next image
      _cubit.emit(ImageDescriptionLoaded(images));
    } else {
      _completeSession();
    }
  }

  void _completeSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Great Job!'),
        content: const Text('You have completed all the image descriptions!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  void _viewSuggestedAnswer() {
    final images = _getImagesFromState(_cubit.state);
    if (images.isEmpty || _currentImageIndex >= images.length) return;

    final currentImage = images[_currentImageIndex];

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
          padding: EdgeInsets.all(ResponsiveLayout.getCardPadding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(
                      bottom: ResponsiveLayout.getElementSpacing(context)),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Suggested Description',
                style: TextStyles.h2(context),
              ),
              SizedBox(height: ResponsiveLayout.getElementSpacing(context)),
              Text(
                currentImage.detailDescription,
                style: TextStyles.body(context).copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Practice'),
        content: const Text('1. Look at the image carefully\n'
            '2. Tap the microphone to record your description\n'
            '3. Describe what you see in detail\n'
            '4. Stop recording when finished\n'
            '5. Review the feedback to improve your English'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<ImageEntity> _getImagesFromState(ImageDescriptionState state) {
    if (state is ImageDescriptionLoaded) return state.images;
    if (state is ImageRecordingStarted) return state.images;
    if (state is ImageTranscriptionProcessing) return state.images;
    if (state is ImageTranscriptionCompleted) return state.images;
    if (state is ImageFeedbackReceived) return state.images;
    return [];
  }

  bool _canSkip(List<ImageEntity> images) {
    return _currentImageIndex < images.length - 1;
  }
}
