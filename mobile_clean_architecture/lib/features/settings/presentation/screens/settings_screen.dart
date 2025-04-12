import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoPlayAudio = true;
  bool _dailyReminder = true;
  String _englishLevel = 'intermediate';

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDarkMode = themeProvider.isDarkMode;

        return Scaffold(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
          appBar: AppBar(
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.blue[500],
            title: const Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            elevation: 0,
          ),
          body: ListView(
            children: [
              _buildSection(
                'Account',
                [
                  _buildSettingItem(
                    icon: Icons.person_outline,
                    iconColor: Colors.blue,
                    title: 'Profile Information',
                    subtitle: 'Change name, email, photo',
                    onTap: () => context.push('/profile'),
                    isDarkMode: isDarkMode,
                  ),
                  _buildSettingItem(
                    icon: Icons.lock_outline,
                    iconColor: Colors.blue,
                    title: 'Security',
                    subtitle: 'Change password, 2FA',
                    onTap: () => context.push('/security'),
                    isDarkMode: isDarkMode,
                  ),
                  _buildSettingItem(
                    icon: Icons.shield_outlined,
                    iconColor: Colors.blue,
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
                    iconColor: Colors.amber,
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
                            value: 'intermediate', child: Text('Intermediate')),
                        DropdownMenuItem(
                            value: 'advanced', child: Text('Advanced')),
                      ],
                    ),
                    isDarkMode: isDarkMode,
                  ),
                  _buildSettingItem(
                    icon: Icons.language,
                    iconColor: Colors.green,
                    title: 'Native Language',
                    subtitle: 'Customize feedback in your language',
                    onTap: () => context.push('/language'),
                    isDarkMode: isDarkMode,
                  ),
                  _buildSettingItem(
                    icon: Icons.storage_outlined,
                    iconColor: Colors.purple,
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
                    iconColor: Colors.orange,
                    title: 'Daily Reminder',
                    subtitle: 'Remind you to practice daily',
                    trailing: Switch(
                      value: _dailyReminder,
                      onChanged: (value) =>
                          setState(() => _dailyReminder = value),
                      activeColor: Colors.green,
                    ),
                    isDarkMode: isDarkMode,
                  ),
                  _buildSettingItem(
                    icon: Icons.notifications_active_outlined,
                    iconColor: Colors.orange,
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
                    iconColor: Colors.blue,
                    title: 'Auto-Play Audio',
                    subtitle: 'Automatically play example audio',
                    trailing: Switch(
                      value: _autoPlayAudio,
                      onChanged: (value) =>
                          setState(() => _autoPlayAudio = value),
                      activeColor: Colors.green,
                    ),
                    isDarkMode: isDarkMode,
                  ),
                  _buildSettingItem(
                    icon: Icons.dark_mode_outlined,
                    iconColor: Colors.amber,
                    title: 'Dark Mode',
                    subtitle: 'Change app appearance',
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (value) => themeProvider.toggleTheme(),
                      activeColor: Colors.green,
                    ),
                    isDarkMode: isDarkMode,
                  ),
                  _buildSettingItem(
                    icon: Icons.storage_outlined,
                    iconColor: Colors.indigo,
                    title: 'Storage & Data',
                    subtitle: 'Manage storage usage',
                    trailing: Text(
                      '25 MB used',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
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
                    iconColor: Colors.blue,
                    title: 'Help Center',
                    subtitle: 'Get help using the app',
                    onTap: () => context.push('/help'),
                    isDarkMode: isDarkMode,
                  ),
                  _buildSettingItem(
                    icon: Icons.feedback_outlined,
                    iconColor: Colors.blue,
                    title: 'Feedback',
                    subtitle: 'Report issues or suggest features',
                    onTap: () => context.push('/feedback'),
                    isDarkMode: isDarkMode,
                  ),
                  _buildSettingItem(
                    icon: Icons.info_outline,
                    iconColor: Colors.blue,
                    title: 'About',
                    subtitle: 'App version and information',
                    trailing: Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    onTap: () => context.push('/about'),
                    isDarkMode: isDarkMode,
                  ),
                ],
                isDarkMode: isDarkMode,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(SignOutRequested());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children,
      {required bool isDarkMode}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 16),
                trailing,
              ],
              if (onTap != null && trailing == null) ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.chevron_right,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
