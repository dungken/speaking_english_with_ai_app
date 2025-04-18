import 'package:flutter/material.dart';
import '../utils/responsive_layout.dart';
import 'components/cards/coaching_tip_card.dart';
import 'components/cards/express_improve_card.dart';
import 'components/cards/streak_goal_card.dart';
import 'components/sections/practice_section.dart';
import 'components/sections/progress_section.dart';

/// HomeContent serves as the main content container for the home screen.
/// This widget organizes all major sections in the home screen and
/// manages the visibility state of components like coaching tips.
/// 
/// Implements responsive layout patterns to ensure proper display
/// across various device sizes and orientations.
class HomeContent extends StatefulWidget {
  final bool isDarkMode;

  const HomeContent({
    Key? key,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _showCoachingTip = true;

  void _dismissCoachingTip() {
    setState(() {
      _showCoachingTip = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate responsive spacing values based on screen size
    final sectionSpacing = ResponsiveLayout.getSectionSpacing(context);
    final padding = ResponsiveLayout.getScreenPadding(context);
    
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreakGoalCard(isDarkMode: widget.isDarkMode),
            SizedBox(height: sectionSpacing * 0.75),
            
            if (_showCoachingTip) ...[
              CoachingTipCard(
                isDarkMode: widget.isDarkMode,
                onDismiss: _dismissCoachingTip,
              ),
              SizedBox(height: sectionSpacing * 0.75),
            ],
            
            ExpressImproveCard(isDarkMode: widget.isDarkMode),
            SizedBox(height: sectionSpacing),
            
            _buildSectionTitle(context, 'Practice Activities'),
            SizedBox(height: sectionSpacing * 0.5),
            
            PracticeSection(isDarkMode: widget.isDarkMode),
            SizedBox(height: sectionSpacing),
            
            _buildSectionTitle(context, 'Your Learning Progress'),
            SizedBox(height: sectionSpacing * 0.5),
            
            ProgressSection(isDarkMode: widget.isDarkMode),
            SizedBox(height: ResponsiveLayout.getSpacing(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final titleSize = ResponsiveLayout.getTitleTextSize(context);
    
    return Text(
      title,
      style: TextStyle(
        fontSize: titleSize,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: widget.isDarkMode 
            ? Color(0xFFF0F4F8)  // Light blue-gray for dark mode
            : Color(0xFF2D3748),  // Dark slate for light mode
      ),
    );
  }
}
