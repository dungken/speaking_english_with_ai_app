import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';

/// Widget for displaying practice images with loading and error states
class ImageDisplayWidget extends StatelessWidget {
  final String? imageUrl;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ImageDisplayWidget({
    super.key,
    this.imageUrl,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final imageHeight = ResponsiveLayout.isLargeScreen(context) ? 350.0 : 300.0;

    return Container(
      height: imageHeight,
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveLayout.getCardPadding(context),
        vertical: ResponsiveLayout.getElementSpacing(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _buildImageContent(context, isDarkMode),
      ),
    );
  }

  Widget _buildImageContent(BuildContext context, bool isDarkMode) {
    if (isLoading) {
      return _buildLoadingState(context, isDarkMode);
    }

    if (errorMessage != null) {
      return _buildErrorState(context, isDarkMode);
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return _buildImageWidget(context, isDarkMode);
    }

    return _buildEmptyState(context, isDarkMode);
  }

  Widget _buildLoadingState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: ResponsiveLayout.getElementSpacing(context)),
          Text(
            'Loading image...',
            style: TextStyles.body(context, isDarkMode: isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveLayout.getCardPadding(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            SizedBox(height: ResponsiveLayout.getElementSpacing(context)),
            Text(
              'Image Error',
              style: TextStyles.h3(context, isDarkMode: isDarkMode),
            ),
            SizedBox(height: ResponsiveLayout.getElementSpacing(context)),
            Text(
              errorMessage ?? 'Failed to load image',
              style: TextStyles.body(context, isDarkMode: isDarkMode),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: ResponsiveLayout.getSectionSpacing(context)),
              ElevatedButton(
                onPressed: onRetry,
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
            Icons.image_outlined,
            size: 64,
            color: AppColors.getTextSecondaryColor(isDarkMode),
          ),
          SizedBox(height: ResponsiveLayout.getElementSpacing(context)),
          Text(
            'No image available',
            style: TextStyles.body(context, isDarkMode: isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(BuildContext context, bool isDarkMode) {
    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingState(context, isDarkMode);
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorState(context, isDarkMode);
      },
    );
  }
}

/// Widget that displays the progress indicator for multiple images
class ImageProgressWidget extends StatelessWidget {
  final int currentIndex;
  final int totalImages;

  const ImageProgressWidget({
    super.key,
    required this.currentIndex,
    required this.totalImages,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (totalImages <= 0) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveLayout.getCardPadding(context),
        vertical: ResponsiveLayout.getElementSpacing(context),
      ),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (currentIndex + 1) / totalImages,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          SizedBox(height: ResponsiveLayout.getElementSpacing(context)),
          Text(
            '${currentIndex + 1} of $totalImages',
            style: TextStyles.secondary(context, isDarkMode: isDarkMode),
          ),
        ],
      ),
    );
  }
}
