import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../helper/global.dart';
import '../../helper/pref.dart';

class SettingsFeature extends StatefulWidget {
  const SettingsFeature({super.key});

  @override
  State<SettingsFeature> createState() => _SettingsFeatureState();
}

class _SettingsFeatureState extends State<SettingsFeature> {
  // Settings state
  final _isDarkMode = Get.isDarkMode.obs;
  final _notificationsEnabled = true.obs;
  final _soundEnabled = true.obs;
  final _autoPlayEnabled = false.obs;
  final _language = 'English'.obs;
  final _fontSize = 16.0.obs;

  // Available languages
  final List<String> _languages = [
    'English',
    'Vietnamese',
    'Spanish',
    'French',
    'German'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue.shade900.withOpacity(0.3)
                  : Colors.blue.shade50,
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.purple.shade900.withOpacity(0.3)
                  : Colors.purple.shade50,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: mq.width * .04,
            vertical: mq.height * .015,
          ),
          children: [
            // App Settings Section
            _buildSectionTitle('App Settings')
                .animate()
                .fadeIn(duration: 600.ms),

            // Dark Mode Toggle
            _buildSettingTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              trailing: Obx(() => Switch(
                    value: _isDarkMode.value,
                    onChanged: (value) {
                      _isDarkMode.value = value;
                      Get.changeThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                      Pref.isDarkMode = value;
                    },
                    activeColor: Colors.blue.shade700,
                  )),
            ).animate().fadeIn(duration: 600.ms, delay: 100.ms),

            // Language Selection
            _buildSettingTile(
              icon: Icons.language_outlined,
              title: 'Language',
              trailing: Obx(() => DropdownButton<String>(
                    value: _language.value,
                    underline: const SizedBox(),
                    items: _languages.map((String language) {
                      return DropdownMenuItem<String>(
                        value: language,
                        child: Text(language),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _language.value = newValue;
                      }
                    },
                  )),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

            // Font Size Slider
            _buildSettingTile(
              icon: Icons.text_fields_outlined,
              title: 'Font Size',
              trailing: SizedBox(
                width: 120,
                child: Obx(() => Slider(
                      value: _fontSize.value,
                      min: 12,
                      max: 24,
                      divisions: 6,
                      label: _fontSize.value.round().toString(),
                      onChanged: (value) {
                        _fontSize.value = value;
                      },
                    )),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 300.ms),

            const SizedBox(height: 24),

            // Notification Settings Section
            _buildSectionTitle('Notification Settings')
                .animate()
                .fadeIn(duration: 600.ms, delay: 400.ms),

            // Notifications Toggle
            _buildSettingTile(
              icon: Icons.notifications_outlined,
              title: 'Enable Notifications',
              trailing: Obx(() => Switch(
                    value: _notificationsEnabled.value,
                    onChanged: (value) {
                      _notificationsEnabled.value = value;
                    },
                    activeColor: Colors.blue.shade700,
                  )),
            ).animate().fadeIn(duration: 600.ms, delay: 500.ms),

            // Sound Toggle
            _buildSettingTile(
              icon: Icons.volume_up_outlined,
              title: 'Sound Effects',
              trailing: Obx(() => Switch(
                    value: _soundEnabled.value,
                    onChanged: (value) {
                      _soundEnabled.value = value;
                    },
                    activeColor: Colors.blue.shade700,
                  )),
            ).animate().fadeIn(duration: 600.ms, delay: 600.ms),

            // Auto-play Toggle
            _buildSettingTile(
              icon: Icons.play_circle_outline,
              title: 'Auto-play Audio',
              trailing: Obx(() => Switch(
                    value: _autoPlayEnabled.value,
                    onChanged: (value) {
                      _autoPlayEnabled.value = value;
                    },
                    activeColor: Colors.blue.shade700,
                  )),
            ).animate().fadeIn(duration: 600.ms, delay: 700.ms),

            const SizedBox(height: 24),

            // Account Settings Section
            _buildSectionTitle('Account Settings')
                .animate()
                .fadeIn(duration: 600.ms, delay: 800.ms),

            // Change Password
            _buildSettingTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                // Navigate to change password screen
                Get.toNamed('/change-password');
              },
            ).animate().fadeIn(duration: 600.ms, delay: 900.ms),

            // Privacy Policy
            _buildSettingTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {
                // Navigate to privacy policy screen
                Get.toNamed('/privacy-policy');
              },
            ).animate().fadeIn(duration: 600.ms, delay: 1000.ms),

            // Terms of Service
            _buildSettingTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () {
                // Navigate to terms of service screen
                Get.toNamed('/terms-of-service');
              },
            ).animate().fadeIn(duration: 600.ms, delay: 1100.ms),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ElevatedButton(
                onPressed: () {
                  // Show confirmation dialog
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Perform logout
                            Get.offAllNamed('/login');
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 1200.ms),
          ],
        ),
      ),
    );
  }

  // Build section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Build setting tile
  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.1)
          : Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Title
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Trailing widget (switch, dropdown, etc.)
              if (trailing != null) trailing,

              // Arrow icon (if no trailing widget)
              if (trailing == null && onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
