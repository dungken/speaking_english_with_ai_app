import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for page transitions
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Redirect to authentication screen if user is not authenticated
        if (state is Unauthenticated) {
          context.go('/auth');
        }
      },
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final isDarkMode = themeProvider.isDarkMode;

          return Scaffold(
            backgroundColor: AppColors.getBackgroundColor(isDarkMode),
            appBar: AppBar(
              backgroundColor:
                  isDarkMode ? AppColors.primaryDark : AppColors.primary,
              title: Text(
                'Profile',
                style: TextStyles.h1(
                  context,
                  color: Colors.white,
                  isDarkMode: isDarkMode,
                ),
              ),
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit Profile',
                  onPressed: () => context.push('/profile/edit'),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Settings',
                  onPressed: () => context.push('/settings'),
                ),
              ],
            ),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileHeader(context, isDarkMode),
                    const SizedBox(height: 24),
                    _buildStatsSection(context, isDarkMode),
                    const SizedBox(height: 24),
                    _buildAchievementsSection(context, isDarkMode),
                    const SizedBox(height: 24),
                    _buildRecentActivitySection(context, isDarkMode),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDarkMode),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor:
                    isDarkMode ? Colors.grey[700] : Colors.grey[200],
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.getSurfaceColor(isDarkMode),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'John Doe',
            style: TextStyles.h1(context, isDarkMode: isDarkMode),
          ),
          const SizedBox(height: 4),
          Text(
            'john.doe@example.com',
            style: TextStyles.secondary(context, isDarkMode: isDarkMode),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProfileBadge(
                isDarkMode: isDarkMode,
                icon: Icons.star,
                label: 'Intermediate',
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _buildProfileBadge(
                isDarkMode: isDarkMode,
                icon: Icons.trending_up,
                label: 'Active Learner',
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileBadge({
    required bool isDarkMode,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Stats',
            style: TextStyles.h2(context, isDarkMode: isDarkMode),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  isDarkMode: isDarkMode,
                  icon: Icons.timer,
                  iconColor: AppColors.info,
                  title: 'Practice Time',
                  value: '32h',
                  subtitle: 'Total',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  isDarkMode: isDarkMode,
                  icon: Icons.calendar_today,
                  iconColor: AppColors.streakPrimary,
                  title: 'Current Streak',
                  value: '5',
                  subtitle: 'Days',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  isDarkMode: isDarkMode,
                  icon: Icons.record_voice_over,
                  iconColor: AppColors.accent,
                  title: 'Recordings',
                  value: '47',
                  subtitle: 'Total',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  isDarkMode: isDarkMode,
                  icon: Icons.emoji_events,
                  iconColor: AppColors.success,
                  title: 'Achievements',
                  value: '12/30',
                  subtitle: 'Unlocked',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required bool isDarkMode,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyles.secondary(context, isDarkMode: isDarkMode),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyles.h1(context, isDarkMode: isDarkMode),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyles.caption(context, isDarkMode: isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: TextStyles.h2(context, isDarkMode: isDarkMode),
              ),
              TextButton(
                onPressed: () => context.push('/achievements'),
                child: Text(
                  'See All',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceColor(isDarkMode),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildAchievementItem(
                  context,
                  isDarkMode: isDarkMode,
                  icon: Icons.local_fire_department,
                  title: '5-Day Streak',
                  subtitle: 'Practice for 5 days in a row',
                  iconColor: AppColors.streakPrimary,
                  isCompleted: true,
                ),
                const Divider(),
                _buildAchievementItem(
                  context,
                  isDarkMode: isDarkMode,
                  icon: Icons.mic,
                  title: 'First Recording',
                  subtitle: 'Complete your first voice recording',
                  iconColor: AppColors.accent,
                  isCompleted: true,
                ),
                const Divider(),
                _buildAchievementItem(
                  context,
                  isDarkMode: isDarkMode,
                  icon: Icons.star,
                  title: 'Perfect Score',
                  subtitle: 'Get 100% on any practice session',
                  iconColor: AppColors.success,
                  isCompleted: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(
    BuildContext context, {
    required bool isDarkMode,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required bool isCompleted,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(isCompleted ? 0.1 : 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isCompleted ? iconColor : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.h3(context, isDarkMode: isDarkMode),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyles.secondary(context, isDarkMode: isDarkMode),
                ),
              ],
            ),
          ),
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? AppColors.success : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: TextStyles.h2(context, isDarkMode: isDarkMode),
              ),
              TextButton(
                onPressed: () => context.push('/activity'),
                child: Text(
                  'See All',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.getSurfaceColor(isDarkMode),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildActivityItem(
                  context,
                  isDarkMode: isDarkMode,
                  leadingIcon: Icons.mic,
                  leadingColor: AppColors.accent,
                  title: 'Pronunciation Practice',
                  time: '2 hours ago',
                  subtitle: 'Completed a vowel sounds session',
                ),
                _buildActivityItem(
                  context,
                  isDarkMode: isDarkMode,
                  leadingIcon: Icons.emoji_events,
                  leadingColor: AppColors.streakPrimary,
                  title: 'Achievement Unlocked',
                  time: 'Yesterday',
                  subtitle: 'First Recording',
                ),
                _buildActivityItem(
                  context,
                  isDarkMode: isDarkMode,
                  leadingIcon: Icons.assessment,
                  leadingColor: AppColors.info,
                  title: 'Progress Assessment',
                  time: '2 days ago',
                  subtitle: 'Completed weekly evaluation',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required bool isDarkMode,
    required IconData leadingIcon,
    required Color leadingColor,
    required String title,
    required String time,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: leadingColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              leadingIcon,
              size: 20,
              color: leadingColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyles.h3(context, isDarkMode: isDarkMode),
                    ),
                    Text(
                      time,
                      style:
                          TextStyles.caption(context, isDarkMode: isDarkMode),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyles.secondary(context, isDarkMode: isDarkMode),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
