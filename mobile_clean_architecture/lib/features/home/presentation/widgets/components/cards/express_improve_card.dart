import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_layout.dart';

/// A prominent card for the Express & Improve feature.
/// This card uses a gradient background and adaptive layout to create visual interest
/// and draw users to a key part of the application.
/// 
/// Implements responsive design patterns to ensure proper display across
/// different device sizes and orientations.
class ExpressImproveCard extends StatelessWidget {
  final bool isDarkMode;

  const ExpressImproveCard({
    Key? key,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen metrics for responsive sizing
    final screenSize = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final screenType = ResponsiveLayout.getScreenType(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [AppColors.primaryDark, Color(0xFF2E3584)]
              : [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use different layouts based on orientation and screen size
          if (orientation == Orientation.landscape && constraints.maxWidth > 500) {
            return _buildLandscapeLayout(context, constraints);
          } else {
            return _buildPortraitLayout(context, screenType);
          }
        },
      ),
    );
  }

  /// Portrait-oriented layout for the card
  Widget _buildPortraitLayout(BuildContext context, ScreenType screenType) {
    // Adjust spacing based on screen size
    final contentPadding = screenType == ScreenType.extraSmall 
        ? const EdgeInsets.all(16)
        : const EdgeInsets.all(20);
    
    return Stack(
      children: [
        // "New" badge
        Positioned(
          top: 0,
          right: 0,
          child: _buildNewBadge(),
        ),
        
        // Main content
        Padding(
          padding: contentPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(screenType),
              SizedBox(height: screenType == ScreenType.extraSmall ? 12 : 16),
              _buildTodayPractice(screenType),
              SizedBox(height: screenType == ScreenType.extraSmall ? 16 : 20),
              _buildActionButton(context),
            ],
          ),
        ),
      ],
    );
  }

  /// Landscape-oriented layout for the card
  Widget _buildLandscapeLayout(BuildContext context, BoxConstraints constraints) {
    return Stack(
      children: [
        // "New" badge
        Positioned(
          top: 0,
          right: 0,
          child: _buildNewBadge(),
        ),
        
        // Two-column layout
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left column: header
              Expanded(
                flex: 3,
                child: _buildCardHeader(ScreenType.medium),
              ),
              
              const SizedBox(width: 20),
              
              // Right column: practice info and button
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTodayPractice(ScreenType.medium),
                    const SizedBox(height: 16),
                    _buildActionButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewBadge() {
    return Container(
      margin: const EdgeInsets.only(right: 12, top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.new_releases_rounded,
            color: Colors.white,
            size: 12,
          ),
          SizedBox(width: 4),
          Text(
            'New!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(ScreenType screenType) {
    // Adjust icon and text sizes based on screen type
    final iconSize = screenType == ScreenType.extraSmall ? 18.0 : 20.0;
    final titleSize = screenType == ScreenType.extraSmall ? 16.0 : 18.0;
    final subtitleSize = screenType == ScreenType.extraSmall ? 13.0 : 14.0;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mic_rounded,
            color: Colors.white,
            size: iconSize,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Express & Improve',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Practice fixing your most common mistakes with focused exercises.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: subtitleSize,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodayPractice(ScreenType screenType) {
    // Adjust text sizes based on screen type
    final labelSize = screenType == ScreenType.extraSmall ? 12.0 : 13.0;
    final titleSize = screenType == ScreenType.extraSmall ? 14.0 : 15.0;
    final noteSize = screenType == ScreenType.extraSmall ? 12.0 : 13.0;
    
    return Container(
      padding: screenType == ScreenType.extraSmall 
          ? const EdgeInsets.all(12)
          : const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's practice:",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: labelSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Past tense in everyday situations',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: titleSize,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.flash_on_rounded,
                size: 14,
                color: AppColors.warning,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Based on 5 mistakes from your recent practice',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: noteSize,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    // Adjust button based on available width
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.push('/practice-mistakes'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.15),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.white.withOpacity(0.25),
              width: 1,
            ),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Start Practice Session',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}
