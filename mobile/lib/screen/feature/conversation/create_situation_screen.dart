// lib/screen/feature/conversation/create_situation_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/conversation_controller.dart';

class CreateSituationScreen extends StatefulWidget {
  final String token;

  const CreateSituationScreen({
    super.key,
    required this.token,
  });

  @override
  State<CreateSituationScreen> createState() => _CreateSituationScreenState();
}

class _CreateSituationScreenState extends State<CreateSituationScreen> {
  final TextEditingController _myRoleController = TextEditingController();
  final TextEditingController _aiRoleController = TextEditingController();
  final TextEditingController _situationController = TextEditingController();
  String _selectedGender = 'Nam';

  @override
  void dispose() {
    _myRoleController.dispose();
    _aiRoleController.dispose();
    _situationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConversationController(token: widget.token));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tạo tình huống giao\ntiếp của tôi',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // My Role Section
              const Text(
                'Nhân vật của tôi',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _myRoleController,
                  maxLength: 30,
                  decoration: InputDecoration(
                    hintText: 'Nhân viên bán hàng',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    counterText: '${_myRoleController.text.length}/30',
                    counterStyle: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // AI Role Section
              const Text(
                'Nhân vật AI',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _aiRoleController,
                  maxLength: 30,
                  decoration: InputDecoration(
                    hintText: 'Khách nước ngoài',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    counterText: '${_aiRoleController.text.length}/30',
                    counterStyle: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // AI Gender Section
              const Text(
                'Giới tính AI',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildGenderOption('Nam'),
                  const SizedBox(width: 16),
                  _buildGenderOption('Nữ'),
                ],
              ),
              const SizedBox(height: 24),

              // Situation Section
              const Text(
                'Tình huống',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _situationController,
                  maxLength: 100,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Tôi đang tư vấn khách hàng mua áo khoác',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    counterText: '${_situationController.text.length}/100',
                    counterStyle: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.createConversation(
                      _myRoleController.text,
                      _aiRoleController.text,
                      _situationController.text,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.grey[400],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'TẠO TÌNH HUỐNG',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              // Popular Situations Section
              const Text(
                'Các tình huống cá nhân hoá\nđược yêu thích nhất',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildPopularSituation(
                'Nhân vật của bạn',
                'Một nhân viên công ty',
                Icons.person_outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(String gender) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFF00BFA5) : Colors.grey,
                width: 2,
              ),
            ),
            child: isSelected
                ? const Center(
                    child: CircleAvatar(
                      backgroundColor: Color(0xFF00BFA5),
                      radius: 8,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            gender,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSituation(
      String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[100],
            child: Icon(icon, color: Colors.grey[600]),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
