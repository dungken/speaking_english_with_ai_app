import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../helper/global.dart';

class ProfileFeature extends StatefulWidget {
  const ProfileFeature({super.key});

  @override
  State<ProfileFeature> createState() => _ProfileFeatureState();
}

class _ProfileFeatureState extends State<ProfileFeature> {
  // Mock user data - replace with actual user data from your backend
  final String _userName = "John Doe";
  final String _userEmail = "john.doe@example.com";
  final String _userAvatar =
      "https://ui-avatars.com/api/?name=John+Doe&background=0D8ABC&color=fff";
  final String _userBio =
      "English language enthusiast. Learning to speak fluently.";
  final String _userLevel = "Intermediate";
  final int _userPoints = 1250;
  final int _userStreak = 7;
  final int _userLessonsCompleted = 42;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // Edit mode state
  final _isEditMode = false.obs;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with current values
    _nameController.text = _userName;
    _emailController.text = _userEmail;
    _bioController.text = _userBio;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // Edit/Save button
          Obx(() => IconButton(
                icon: Icon(_isEditMode.value
                    ? Icons.save_outlined
                    : Icons.edit_outlined),
                onPressed: () {
                  if (_isEditMode.value) {
                    // Save changes
                    // In a real app, you would save to backend here
                    Get.snackbar(
                      'Success',
                      'Profile updated successfully',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green.shade100,
                      colorText: Colors.green.shade900,
                    );
                  }
                  _isEditMode.value = !_isEditMode.value;
                },
              )),
        ],
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
            // Profile Header
            _buildProfileHeader().animate().fadeIn(duration: 600.ms),

            const SizedBox(height: 24),

            // Stats Section
            _buildStatsSection()
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms),

            const SizedBox(height: 24),

            // Personal Information Section
            _buildSectionTitle('Personal Information')
                .animate()
                .fadeIn(duration: 600.ms, delay: 400.ms),

            // Name Field
            _buildInfoTile(
              icon: Icons.person_outline,
              title: 'Name',
              value: _userName,
              controller: _nameController,
              isEditMode: _isEditMode,
            ).animate().fadeIn(duration: 600.ms, delay: 500.ms),

            // Email Field
            _buildInfoTile(
              icon: Icons.email_outlined,
              title: 'Email',
              value: _userEmail,
              controller: _emailController,
              isEditMode: _isEditMode,
            ).animate().fadeIn(duration: 600.ms, delay: 600.ms),

            // Bio Field
            _buildInfoTile(
              icon: Icons.info_outline,
              title: 'Bio',
              value: _userBio,
              controller: _bioController,
              isEditMode: _isEditMode,
              isMultiline: true,
            ).animate().fadeIn(duration: 600.ms, delay: 700.ms),

            const SizedBox(height: 24),

            // Learning Information Section
            _buildSectionTitle('Learning Information')
                .animate()
                .fadeIn(duration: 600.ms, delay: 800.ms),

            // Level Field
            _buildInfoTile(
              icon: Icons.school_outlined,
              title: 'Level',
              value: _userLevel,
              isEditMode: _isEditMode,
              trailing: _buildLevelChip(_userLevel),
            ).animate().fadeIn(duration: 600.ms, delay: 900.ms),

            // Points Field
            _buildInfoTile(
              icon: Icons.stars_outlined,
              title: 'Points',
              value: _userPoints.toString(),
              isEditMode: _isEditMode,
              trailing: _buildPointsChip(_userPoints),
            ).animate().fadeIn(duration: 600.ms, delay: 1000.ms),

            // Streak Field
            _buildInfoTile(
              icon: Icons.local_fire_department_outlined,
              title: 'Streak',
              value: '$_userStreak days',
              isEditMode: _isEditMode,
              trailing: _buildStreakChip(_userStreak),
            ).animate().fadeIn(duration: 600.ms, delay: 1100.ms),

            // Lessons Completed Field
            _buildInfoTile(
              icon: Icons.check_circle_outline,
              title: 'Lessons Completed',
              value: _userLessonsCompleted.toString(),
              isEditMode: _isEditMode,
              trailing: _buildLessonsChip(_userLessonsCompleted),
            ).animate().fadeIn(duration: 600.ms, delay: 1200.ms),

            const SizedBox(height: 24),

            // Achievements Section
            _buildSectionTitle('Achievements')
                .animate()
                .fadeIn(duration: 600.ms, delay: 1300.ms),

            // Achievements Grid
            _buildAchievementsGrid()
                .animate()
                .fadeIn(duration: 600.ms, delay: 1400.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Build profile header
  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Avatar
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(_userAvatar),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Obx(
                () => _isEditMode.value
                    ? Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Name
        Obx(
          () => _isEditMode.value
              ? TextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                )
              : Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),

        const SizedBox(height: 4),

        // Email
        Obx(
          () => _isEditMode.value
              ? TextField(
                  controller: _emailController,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                )
              : Text(
                  _userEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
        ),

        const SizedBox(height: 16),

        // Bio
        Obx(
          () => _isEditMode.value
              ? TextField(
                  controller: _bioController,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                )
              : Text(
                  _userBio,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
        ),
      ],
    );
  }

  // Build stats section
  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.school_outlined,
            value: _userLevel,
            label: 'Level',
            color: Colors.amber,
          ),
          _buildStatItem(
            icon: Icons.stars_outlined,
            value: _userPoints.toString(),
            label: 'Points',
            color: Colors.blue,
          ),
          _buildStatItem(
            icon: Icons.local_fire_department_outlined,
            value: '$_userStreak',
            label: 'Streak',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  // Build stat item
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
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

  // Build info tile
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    TextEditingController? controller,
    required RxBool isEditMode,
    Widget? trailing,
    bool isMultiline = false,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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

            // Title and Value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => isEditMode.value && controller != null
                        ? TextField(
                            controller: controller,
                            maxLines: isMultiline ? 3 : 1,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          )
                        : Text(
                            value,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            // Trailing widget
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  // Build level chip
  Widget _buildLevelChip(String level) {
    Color chipColor;
    switch (level.toLowerCase()) {
      case 'beginner':
        chipColor = Colors.green;
        break;
      case 'intermediate':
        chipColor = Colors.amber;
        break;
      case 'advanced':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        level,
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Build points chip
  Widget _buildPointsChip(int points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars,
            color: Colors.blue.shade700,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            points.toString(),
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Build streak chip
  Widget _buildStreakChip(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: Colors.orange.shade700,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak days',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Build lessons chip
  Widget _buildLessonsChip(int lessons) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green.shade700,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            lessons.toString(),
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Build achievements grid
  Widget _buildAchievementsGrid() {
    // Mock achievements - replace with actual data
    final List<Map<String, dynamic>> achievements = [
      {'icon': Icons.emoji_events, 'title': 'First Lesson', 'unlocked': true},
      {'icon': Icons.emoji_events, 'title': '7 Day Streak', 'unlocked': true},
      {'icon': Icons.emoji_events, 'title': '100 Points', 'unlocked': true},
      {'icon': Icons.emoji_events, 'title': '30 Day Streak', 'unlocked': false},
      {'icon': Icons.emoji_events, 'title': '500 Points', 'unlocked': false},
      {'icon': Icons.emoji_events, 'title': 'Master Level', 'unlocked': false},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final bool isUnlocked = achievement['unlocked'] as bool;

        return Container(
          decoration: BoxDecoration(
            color: isUnlocked
                ? Colors.amber.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                achievement['icon'] as IconData,
                color: isUnlocked ? Colors.amber : Colors.grey,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                achievement['title'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color:
                      isUnlocked ? Colors.amber.shade900 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
