import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../authentication/presentation/screens/auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      icon: Icons.mic,
      iconColor: AppColors.primary,
      title: 'Practice Speaking',
      description:
          'Improve your English speaking skills with AI-powered conversations and instant feedback',
    ),
    OnboardingItem(
      icon: Icons.school,
      iconColor: AppColors.accent,
      title: 'Learn Naturally',
      description:
          'Engage in real conversations, learn new vocabulary, and perfect your pronunciation',
    ),
    OnboardingItem(
      icon: Icons.trending_up,
      iconColor: AppColors.success,
      title: 'Track Progress',
      description:
          'Monitor your improvement with detailed feedback and personalized learning paths',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _OnboardingPage(
                      item: _items[index], isDarkMode: isDarkMode);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(
                ResponsiveLayout.getSectionSpacing(context),
              ),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _items.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: _getIndicatorColor(_currentPage),
                      dotColor: isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                    ),
                  ),
                  SizedBox(height: ResponsiveLayout.getSectionSpacing(context)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _items.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Future.microtask(() => context.go('/auth'));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: _getButtonColor(_currentPage),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        _currentPage < _items.length - 1
                            ? 'Next'
                            : 'Get Started',
                        style: TextStyles.button(context),
                      ),
                    ),
                  ),
                  if (_currentPage < _items.length - 1)
                    TextButton(
                      onPressed: () {
                        Future.microtask(() => context.go('/auth'));
                      },
                      child: Text(
                        'Skip',
                        style: TextStyles.button(context,
                            color: AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getButtonColor(int page) {
    switch (page) {
      case 0:
        return AppColors.primary;
      case 1:
        return AppColors.accent;
      case 2:
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  Color _getIndicatorColor(int page) {
    switch (page) {
      case 0:
        return AppColors.primary;
      case 1:
        return AppColors.accent;
      case 2:
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingItem item;
  final bool isDarkMode;

  const _OnboardingPage({
    required this.item,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveLayout.getSectionSpacing(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  item.iconColor.withOpacity(0.8),
                  item.iconColor,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: item.iconColor.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              item.icon,
              size: 48,
              color: Colors.white,
            ),
          ),
          SizedBox(height: ResponsiveLayout.getSectionSpacing(context) * 1.5),
          Text(
            item.title,
            style: TextStyles.h1(
              context,
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveLayout.getElementSpacing(context) * 2),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: TextStyles.body(
              context,
              color: isDarkMode
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  OnboardingItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });
}
