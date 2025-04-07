import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedVoice = 'Female';

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Japanese',
  ];

  final List<String> _voices = [
    'Female',
    'Male',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'General',
            [
              _buildSwitchTile(
                'Enable Notifications',
                'Receive practice reminders and updates',
                _notificationsEnabled,
                (value) => setState(() => _notificationsEnabled = value),
              ),
              _buildSwitchTile(
                'Dark Mode',
                'Use dark theme',
                _darkModeEnabled,
                (value) => setState(() => _darkModeEnabled = value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Language',
            [
              _buildDropdownTile(
                'App Language',
                'Select your preferred language',
                _selectedLanguage,
                _languages,
                (value) => setState(() => _selectedLanguage = value),
              ),
              _buildDropdownTile(
                'AI Voice',
                'Choose AI assistant voice',
                _selectedVoice,
                _voices,
                (value) => setState(() => _selectedVoice = value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Account',
            [
              _buildListTile(
                'Change Password',
                'Update your account password',
                Icons.lock_outline,
                () {
                  // TODO: Implement change password
                },
              ),
              _buildListTile(
                'Privacy Policy',
                'View our privacy policy',
                Icons.privacy_tip_outlined,
                () {
                  // TODO: Show privacy policy
                },
              ),
              _buildListTile(
                'Terms of Service',
                'View our terms of service',
                Icons.description_outlined,
                () {
                  // TODO: Show terms of service
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'About',
            [
              _buildListTile(
                'App Version',
                '1.0.0',
                Icons.info_outline,
                null,
              ),
              _buildListTile(
                'Rate App',
                'Share your feedback',
                Icons.star_outline,
                () {
                  // TODO: Implement app rating
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement logout
              Get.offAllNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    String value,
    List<String> items,
    ValueChanged<String> onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}
