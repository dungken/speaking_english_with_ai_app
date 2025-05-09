import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool _autoPlayAudio = true;
  bool _dailyReminder = true;
  String _englishLevel = 'intermediate';
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
                'Settings',
                style: TextStyles.h1(
                  context,
                  color: Colors.white,
                  isDarkMode: isDarkMode,
                ),
              ),
              elevation: 0,
            ),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: ListView(
                children: [
                  _buildSection(
                    'Account',
                    [
                      _buildSettingItem(
                        icon: Icons.person_outline,
                        iconColor: AppColors.primary,
                        title: 'Profile Information',
                        subtitle: 'Change name, email, photo',
                        onTap: () => context.push('/profile'),
                        isDarkMode: isDarkMode,
                      ),
                      _buildSettingItem(
                        icon: Icons.lock_outline,
                        iconColor: AppColors.primary,
                        title: 'Security',
                        subtitle: 'Change password, 2FA',
                        onTap: () => context.push('/security'),
                        isDarkMode: isDarkMode,
                      ),
                      _buildSettingItem(
                        icon: Icons.shield_outlined,
                        iconColor: AppColors.primary,
                        title: 'Privacy',
                        subtitle: 'Manage your data and permissions',
                        onTap: () => context.push('/privacy'),
                        isDarkMode: isDarkMode,
                      ),
                    ],
                    isDarkMode: isDarkMode,
                  ),
                  _buildSection(
                    'Learning Preferences',
                    [
                      _buildSettingItem(
                        icon: Icons.emoji_events_outlined,
                        iconColor: AppColors.streakPrimary,
                        title: 'English Level',
                        subtitle: 'Set your proficiency level',
                        trailing: DropdownButton<String>(
                          value: _englishLevel,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _englishLevel = value);
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                                value: 'beginner', child: Text('Beginner')),
                            DropdownMenuItem(
                                value: 'intermediate',
                                child: Text('Intermediate')),
                            DropdownMenuItem(
                                value: 'advanced', child: Text('Advanced')),
                          ],
                          underline: Container(),
                        ),
                        isDarkMode: isDarkMode,
                      ),
                      _buildSettingItem(
                        icon: Icons.language,
                        iconColor: AppColors.success,
                        title: 'Native Language',
                        subtitle: 'Customize feedback in your language',
                        onTap: () => context.push('/language'),
                        isDarkMode: isDarkMode,
                      ),
                      _buildSettingItem(
                        icon: Icons.storage_outlined,
                        iconColor: AppColors.accent,
                        title: 'Learning Focus',
                        subtitle: 'Prioritize specific skills',
                        onTap: () => context.push('/learning-focus'),
                        isDarkMode: isDarkMode,
                      ),
                    ],
                    isDarkMode: isDarkMode,
                  ),
                  _buildSection(
                    'Notifications',
                    [
                      _buildSettingItem(
                        icon: Icons.notifications_outlined,
                        iconColor: AppColors.warning,
                        title: 'Daily Reminder',
                        subtitle: 'Remind you to practice daily',
                        trailing: Switch(
                          value: _dailyReminder,
                          onChanged: (value) =>
                              setState(() => _dailyReminder = value),
                          activeColor: AppColors.success,
                        ),
                        isDarkMode: isDarkMode,
                      ),
                      _buildSettingItem(
                        icon: Icons.notifications_active_outlined,
                        iconColor: AppColors.warning,
                        title: 'More Notification Settings',
                        subtitle: 'Customize when we notify you',
                        onTap: () => context.push('/notifications'),
                        isDarkMode: isDarkMode,
                      ),
                    ],
                    isDarkMode: isDarkMode,
                  ),
                  _buildSection(
                    'App Settings',
                    [
                      _buildSettingItem(
                        icon: Icons.volume_up_outlined,
                        iconColor: AppColors.info,
                        title: 'Auto-Play Audio',
                        subtitle: 'Automatically play example audio',
                        trailing: Switch(
                          value: _autoPlayAudio,
                          onChanged: (value) =>
                              setState(() => _autoPlayAudio = value),
                          activeColor: AppColors.success,
                        ),
                        isDarkMode: isDarkMode,
                      ),
                      _buildSettingItem(
                        icon: Icons.dark_mode_outlined,
                        iconColor: AppColors.streakPrimary,
                        title: 'Dark Mode',
                        subtitle: 'Change app appearance',
                        trailing: Switch(
                          value: isDarkMode,
                          onChanged: (value) => themeProvider.toggleTheme(),
                          activeColor: AppColors.success,
                        ),
                        isDarkMode: isDarkMode,
                      ),
                      _buildSettingItem(
                        icon: Icons.storage_outlined,
                        iconColor: AppColors.primaryDark,
                        title: 'Storage & Data',
                        subtitle: 'Manage storage usage',
                        trailing: Text(
                          '25 MB used',
                          style: TextStyles.secondary(
                            context,
                            isDarkMode: isDarkMode,
                          ),
                        ),
                        onTap: () => context.push('/storage'),
                        isDarkMode: isDarkMode,
                      ),
                    ],
                    isDarkMode: isDarkMode,
                  ),
                  _buildSection(
                    'Help & Support',
                    [
                      _buildSettingItem(
                        icon: Icons.help_outline,
                        iconColor: AppColors.info,
                        title: 'Help Center',
                        subtitle: 'Get help using the app',
                        onTap: () => context.push('/help'),
                        isDarkMode: isDarkMode,
                      ),
                      _buildSettingItem(
                        icon: Icons.feedback_outlined,
                        iconColor: AppColors.info,
                        title: 'Send Feedback',
                        subtitle: 'Report issues or suggest features',
                        onTap: () => context.push('/feedback'),
                        isDarkMode: isDarkMode,
                      ),
                      _buildSettingItem(
                        icon: Icons.info_outline,
                        iconColor: AppColors.info,
                        title: 'About',
                        subtitle: 'App version and legal information',
                        onTap: () => context.push('/about'),
                        isDarkMode: isDarkMode,
                      ),
                    ],
                    isDarkMode: isDarkMode,
                  ),
                  _buildSection(
                    'Account Action',
                    [
                      _buildSettingItem(
                        icon: Icons.logout,
                        iconColor: Colors.red,
                        title: 'Sign Out',
                        subtitle: 'Log out from your account',
                        onTap: () {
                          // Show confirmation dialog before signing out
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Sign Out',
                                  style: TextStyles.h2(context,
                                      isDarkMode: isDarkMode)),
                              content: Text(
                                'Are you sure you want to sign out?',
                                style: TextStyles.body(context,
                                    isDarkMode: isDarkMode),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel',
                                      style: TextStyle(
                                          color: AppColors.getTextColor(
                                              isDarkMode))),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    context
                                        .read<AuthBloc>()
                                        .add(SignOutRequested());
                                    // Navigate back to login screen after sign out
                                    context.go('/auth');
                                  },
                                  child: const Text('Sign Out',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        isDarkMode: isDarkMode,
                      ),
                    ],
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<Widget> children, {
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: TextStyles.h2(
                context,
                isDarkMode: isDarkMode,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.getSurfaceColor(isDarkMode),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    required bool isDarkMode,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.h3(
                      context,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyles.secondary(
                      context,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (onTap != null && trailing == null)
              Icon(
                Icons.chevron_right,
                color: AppColors.getTextSecondaryColor(isDarkMode),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
