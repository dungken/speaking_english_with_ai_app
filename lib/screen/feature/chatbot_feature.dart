import '../../main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/chat_controller.dart';
import '../../helper/global.dart';
import '../../widget/message_card.dart';

/// 📌 **ChatBotFeature Screen**
///
/// This screen allows users to interact with the AI-powered chatbot.
/// It provides a chat interface where users can type messages and receive responses.
class ChatBotFeature extends StatefulWidget {
  const ChatBotFeature({super.key});

  @override
  State<ChatBotFeature> createState() => _ChatBotFeatureState();
}

class _ChatBotFeatureState extends State<ChatBotFeature> {
  /// 🔹 **Chat Controller Instance**
  ///
  /// Manages the chat functionality, including handling user input and responses.
  final _c = ChatController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 📌 **App Bar**
      appBar: AppBar(
        title: const Text('Chat with AI Assistant'),
      ),

      // 📌 **Floating Action Button & Input Field**
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(children: [
          // 📝 **Text Input Field**
          Expanded(
            child: TextFormField(
              controller: _c.textC, // Controller for user input
              textAlign: TextAlign.center,
              onTapOutside: (e) => FocusScope.of(context)
                  .unfocus(), // Hide keyboard on tap outside
              decoration: InputDecoration(
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                filled: true,
                isDense: true,
                hintText: 'Ask me anything you want...', // Placeholder text
                hintStyle: const TextStyle(fontSize: 14),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
              ),
            ),
          ),

          // 🛑 **Spacing Between Input Field and Button**
          const SizedBox(width: 8),

          // 🚀 **Send Button**
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).buttonColor, // Button color
            child: IconButton(
              onPressed: _c.askQuestion, // Triggers chatbot response
              icon: const Icon(
                Icons.rocket_launch_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ]),
      ),

      // 📌 **Chat Message List**
      body: Obx(
        () => ListView(
          physics: const BouncingScrollPhysics(), // Smooth scrolling effect
          controller: _c.scrollC, // Scroll controller for automatic scrolling
          padding: EdgeInsets.only(
            top: mq.height * .02, // Top padding
            bottom: mq.height * .1, // Bottom padding to prevent overlap
          ),
          children: _c.list
              .map((e) => MessageCard(message: e))
              .toList(), // Display messages dynamically
        ),
      ),
    );
  }
}
