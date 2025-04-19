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

class _HomeContentState extends State<HomeContent> with SingleTickerProviderStateMixin {
  bool _showCoachingTip = true;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for smooth transitions
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start animation after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
    final orientation = MediaQuery.of(context).orientation;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: padding,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Use landscape layout for wide screens
              if (orientation == Orientation.landscape && screenWidth > 600) {
                return _buildLandscapeLayout(
                  context, 
                  sectionSpacing, 
                  constraints.maxWidth
                );
              } else {
                // Otherwise use portrait layout
                return _buildPortraitLayout(context, sectionSpacing);
              }
            },
          ),
        ),
      ),
    );
  }

  /// Layout optimized for portrait orientation
  Widget _buildPortraitLayout(BuildContext context, double sectionSpacing) {
    return Column(
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
    );
  }

  /// Layout optimized for landscape orientation on wider screens
  Widget _buildLandscapeLayout(BuildContext context, double sectionSpacing, double maxWidth) {
    // Calculate appropriate column widths with spacing in between
    final columnWidth = (maxWidth - sectionSpacing) / 2;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - Practice content
        SizedBox(
          width: columnWidth,
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
              SizedBox(height: ResponsiveLayout.getSpacing(context)),
            ],
          ),
        ),
        
        SizedBox(width: sectionSpacing),
        
        // Right column - Progress content
        SizedBox(
          width: columnWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'Your Learning Progress'),
              SizedBox(height: sectionSpacing * 0.5),
              
              ProgressSection(isDarkMode: widget.isDarkMode),
              SizedBox(height: ResponsiveLayout.getSpacing(context)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final titleSize = ResponsiveLayout.getTitleTextSize(context);
    
    return Semantics(
      header: true,
      child: Text(
        title,
        style: TextStyle(
          fontSize: titleSize,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: widget.isDarkMode 
              ? const Color(0xFFF0F4F8)  // Light blue-gray for dark mode
              : const Color(0xFF2D3748),  // Dark slate for light mode
        ),
      ),
    );
  }
}
