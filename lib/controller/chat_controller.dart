import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../apis/apis.dart';
import '../helper/my_dialog.dart';
import '../model/message.dart';

/// Controller class for managing chat functionality.
///
/// This class handles user input, sending messages to the AI,
/// updating the chat list, and controlling scrolling behavior.
class ChatController extends GetxController {
  /// Controller for handling text input.
  final textC = TextEditingController();

  /// Scroll controller to manage automatic scrolling in the chat UI.
  final scrollC = ScrollController();

  /// Observable list of messages to dynamically update the chat UI.
  final list = <Message>[
    // Initial bot message.
    Message(msg: 'Hello, How can I help you?', msgType: MessageType.bot)
  ].obs;

  /// Sends the user's question to the AI and updates the chat UI with the response.
  ///
  /// - If the user input is empty, it shows an alert using `MyDialog.info()`.
  /// - If the input is valid:
  ///   1. Adds the user's message to the chat.
  ///   2. Adds a placeholder message for the bot's response.
  ///   3. Calls the API to get a response from AI.
  ///   4. Replaces the placeholder with the actual AI response.
  ///   5. Scrolls to the latest message.
  Future<void> askQuestion() async {
    if (textC.text.trim().isNotEmpty) {
      // Add user message to the chat list.
      list.add(Message(msg: textC.text, msgType: MessageType.user));

      // Add an empty bot message as a placeholder.
      list.add(Message(msg: '', msgType: MessageType.bot));

      // Scroll to the latest message.
      _scrollDown();

      // Get AI response from the API.
      final res = await APIs.getAnswer(textC.text);

      // Remove the placeholder bot message.
      list.removeLast();

      // Add the AI response to the chat list.
      list.add(Message(msg: res, msgType: MessageType.bot));

      // Scroll again to show the AI response.
      _scrollDown();

      // Clear the text input field after sending.
      textC.text = '';
    } else {
      // Show a dialog if the input is empty.
      MyDialog.info('Ask Something!');
    }
  }

  /// Scrolls to the latest message in the chat UI.
  void _scrollDown() {
    scrollC.animateTo(
      scrollC.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }
}
