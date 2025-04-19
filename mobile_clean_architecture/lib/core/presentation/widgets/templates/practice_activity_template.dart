import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/text_styles.dart';
import '../../../utils/responsive_layout.dart';
import '../../../utils/ui_config.dart';

class PracticeActivityTemplate extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget instructionPanel;
  final Widget contentDisplay;
  final Widget interactionArea;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  
  const PracticeActivityTemplate({
    Key? key,
    required this.title,
    this.subtitle,
    required this.instructionPanel,
    required this.contentDisplay,
    required this.interactionArea,
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyles.h2(context, isDarkMode: isDarkMode),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyles.secondary(context, isDarkMode: isDarkMode),
              ),
          ],
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
        toolbarHeight: subtitle != null ? 70 : kToolbarHeight,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (ResponsiveLayout.isLargeScreen(context)) {
              return _buildLandscapeLayout(context, constraints);
            } else {
              return _buildPortraitLayout(context, constraints);
            }
          },
        ),
      ),
    );
  }
  
  Widget _buildPortraitLayout(BuildContext context, BoxConstraints constraints) {
    final elementSpacing = ResponsiveLayout.getElementSpacing(context);
    final padding = UIConfig.getHorizontalPadding(context);
    
    return Column(
      children: [
        // Instruction panel (10% of screen)
        Padding(
          padding: EdgeInsets.all(padding),
          child: instructionPanel,
        ),
        
        // Content display (60% of screen)
        Expanded(
          flex: 6,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: contentDisplay,
          ),
        ),
        
        SizedBox(height: elementSpacing),
        
        // Interaction area (30% of screen)
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: interactionArea,
          ),
        ),
      ],
    );
  }
  
  Widget _buildLandscapeLayout(BuildContext context, BoxConstraints constraints) {
    final elementSpacing = ResponsiveLayout.getElementSpacing(context);
    final padding = UIConfig.getHorizontalPadding(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left panel (60% for content)
        Expanded(
          flex: 6,
          child: Column(
            children: [
              // Instruction panel
              Padding(
                padding: EdgeInsets.all(padding),
                child: instructionPanel,
              ),
              
              // Content display
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: contentDisplay,
                ),
              ),
            ],
          ),
        ),
        
        // Vertical divider
        Container(
          width: 1,
          margin: EdgeInsets.symmetric(vertical: elementSpacing * 2),
          color: Colors.grey.withOpacity(0.2),
        ),
        
        // Right panel (40% for interaction)
        Expanded(
          flex: 4,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: interactionArea,
          ),
        ),
      ],
    );
  }
}
