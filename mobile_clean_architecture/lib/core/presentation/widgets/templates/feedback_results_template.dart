import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/text_styles.dart';
import '../../../utils/responsive_layout.dart';
import '../../../utils/ui_config.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

class FeedbackResultsTemplate extends StatelessWidget {
  final String title;
  final Widget summarySection;
  final Widget detailedFeedbackSection;
  final String primaryActionLabel;
  final VoidCallback onPrimaryActionPressed;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryActionPressed;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  
  const FeedbackResultsTemplate({
    Key? key,
    required this.title,
    required this.summarySection,
    required this.detailedFeedbackSection,
    required this.primaryActionLabel,
    required this.onPrimaryActionPressed,
    this.secondaryActionLabel,
    this.onSecondaryActionPressed,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDarkMode),
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyles.h2(context, isDarkMode: isDarkMode),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: showBackButton 
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                tooltip: 'Back',
              )
            : null,
        actions: actions,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (ResponsiveLayout.isLargeScreen(context)) {
            return _buildLandscapeLayout(context);
          } else {
            return _buildPortraitLayout(context);
          }
        },
      ),
    );
  }
  
  Widget _buildPortraitLayout(BuildContext context) {
    final sectionSpacing = ResponsiveLayout.getSectionSpacing(context);
    final padding = UIConfig.getHorizontalPadding(context);
    
    return Column(
      children: [
        // Summary section (30% of screen)
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: summarySection,
          ),
        ),
        
        // Divider
        Container(
          height: 1,
          margin: EdgeInsets.symmetric(vertical: sectionSpacing * 0.5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.grey.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        
        // Detailed feedback section (50% of screen)
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: detailedFeedbackSection,
          ),
        ),
        
        // Action buttons (20% of screen)
        Container(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                text: primaryActionLabel,
                onPressed: onPrimaryActionPressed,
                isFullWidth: true,
              ),
              if (secondaryActionLabel != null && onSecondaryActionPressed != null) ...[
                const SizedBox(height: 8),
                SecondaryButton(
                  text: secondaryActionLabel!,
                  onPressed: onSecondaryActionPressed,
                  isFullWidth: true,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildLandscapeLayout(BuildContext context) {
    final padding = UIConfig.getHorizontalPadding(context);
    
    return Row(
      children: [
        // Left panel (40% of screen)
        Expanded(
          flex: 4,
          child: Column(
            children: [
              // Summary section
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(padding),
                  child: summarySection,
                ),
              ),
              
              // Action buttons
              Container(
                padding: EdgeInsets.all(padding),
                child: Row(
                  children: [
                    if (secondaryActionLabel != null && onSecondaryActionPressed != null)
                      Expanded(
                        child: SecondaryButton(
                          text: secondaryActionLabel!,
                          onPressed: onSecondaryActionPressed,
                          isFullWidth: true,
                        ),
                      ),
                    if (secondaryActionLabel != null && onSecondaryActionPressed != null)
                      const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        text: primaryActionLabel,
                        onPressed: onPrimaryActionPressed,
                        isFullWidth: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Vertical divider
        Container(
          width: 1,
          margin: EdgeInsets.symmetric(vertical: padding),
          color: Colors.grey.withOpacity(0.2),
        ),
        
        // Right panel (60% of screen) - Detailed feedback
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: detailedFeedbackSection,
          ),
        ),
      ],
    );
  }
}
