import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/text_styles.dart';
import '../../../utils/responsive_layout.dart';
import '../../../utils/ui_config.dart';

class FeatureHomeTemplate extends StatelessWidget {
  final String title;
  final Widget heroContent;
  final List<Widget> actionCards;
  final Widget contentSection;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  
  const FeatureHomeTemplate({
    Key? key,
    required this.title,
    required this.heroContent,
    required this.actionCards,
    required this.contentSection,
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
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(UIConfig.getHorizontalPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero section (40% of content)
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 200),
            child: heroContent,
          ),
          
          SizedBox(height: sectionSpacing),
          
          // Action cards section (20% of content)
          if (actionCards.isNotEmpty) ...[
            Column(
              children: actionCards,
            ),
            SizedBox(height: sectionSpacing),
          ],
          
          // Content section (40% of content)
          contentSection,
        ],
      ),
    );
  }
  
  Widget _buildLandscapeLayout(BuildContext context) {
    final sectionSpacing = ResponsiveLayout.getSectionSpacing(context);
    final horizontalPadding = UIConfig.getHorizontalPadding(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel (40% of screen) - Hero content
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(horizontalPadding),
            child: heroContent,
          ),
        ),
        
        // Right panel (60% of screen)
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action cards section in horizontal scrollable list
                if (actionCards.isNotEmpty) ...[
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: actionCards.map((card) {
                        return ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: card,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: sectionSpacing),
                ],
                
                // Content section
                contentSection,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
