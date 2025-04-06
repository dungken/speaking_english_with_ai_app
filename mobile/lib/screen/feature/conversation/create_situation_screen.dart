// lib/screen/feature/conversation/create_situation_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/conversation_controller.dart';
import '../../../widgets/conversation/situation_form.dart';

class CreateSituationScreen extends StatelessWidget {
  final String token;

  const CreateSituationScreen({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConversationController(token: token));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Conversation'),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (controller.error.value != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red[100],
                  child: Text(
                    controller.error.value!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              SituationForm(
                onSubmit: controller.createConversation,
              ),
            ],
          ),
        );
      }),
    );
  }
}
