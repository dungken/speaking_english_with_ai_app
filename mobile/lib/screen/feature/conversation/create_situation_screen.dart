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

  // Popular role suggestions
  final List<String> _popularMyRoles = [
    'Nhân viên bán hàng',
    'Nhân viên lễ tân',
    'Nhân viên phục vụ',
    'Nhân viên công ty',
  ];

  final List<String> _popularAIRoles = [
    'Khách nước ngoài',
    'Khách du lịch',
    'Đồng nghiệp',
    'Quản lý',
  ];

  final List<String> _popularSituations = [
    'Tôi đang tư vấn khách hàng mua áo khoác',
    'Tôi đang hướng dẫn khách check-in khách sạn',
    'Tôi đang phỏng vấn xin việc',
    'Tôi đang thuyết trình dự án',
  ];

  @override
  void dispose() {
    _myRoleController.dispose();
    _aiRoleController.dispose();
    _situationController.dispose();
    super.dispose();
  }

  void _selectMyRole(String role) {
    setState(() {
      _myRoleController.text = role;
    });
  }

  void _selectAIRole(String role) {
    setState(() {
      _aiRoleController.text = role;
    });
  }

  void _selectSituation(String situation) {
    setState(() {
      _situationController.text = situation;
    });
  }

  Widget _buildSuggestionChips(
      List<String> suggestions, Function(String) onSelected) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions
          .map((suggestion) => ActionChip(
                label: Text(suggestion),
                backgroundColor: Colors.blue.shade50,
                labelStyle: TextStyle(color: Colors.blue.shade700),
                onPressed: () => onSelected(suggestion),
              ))
          .toList(),
    );
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
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Nhân viên bán hàng',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF00BFA5), width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    counterText: '${_myRoleController.text.length}/30',
                    counterStyle: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildSuggestionChips(_popularMyRoles, _selectMyRole),
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
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Khách nước ngoài',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF00BFA5), width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    counterText: '${_aiRoleController.text.length}/30',
                    counterStyle: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildSuggestionChips(_popularAIRoles, _selectAIRole),
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
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tôi đang tư vấn khách hàng mua áo khoác',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF00BFA5), width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    counterText: '${_situationController.text.length}/100',
                    counterStyle: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildSuggestionChips(_popularSituations, _selectSituation),
              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_myRoleController.text.isNotEmpty &&
                        _aiRoleController.text.isNotEmpty &&
                        _situationController.text.isNotEmpty) {
                      controller.createConversation(
                        _myRoleController.text,
                        _aiRoleController.text,
                        _situationController.text,
                      );
                    } else {
                      Get.snackbar(
                        'Thông báo',
                        'Vui lòng điền đầy đủ thông tin',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
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
}
