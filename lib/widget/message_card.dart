import '../main.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import '../helper/global.dart';
import '../model/message.dart';

class MessageCard extends StatelessWidget {
  final Message message; // 💬 Message model containing text & sender info

  const MessageCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    const r = Radius.circular(15); // 🔵 Rounded corners for message bubbles

    return message.msgType == MessageType.bot
        ? Row(
            children: [
              const SizedBox(width: 6), // 📏 Small spacing before bot avatar

              // 🤖 Bot Avatar (App Logo)
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Image.asset('assets/images/logo.png', width: 24),
              ),

              // 🟦 Bot Message Bubble
              Container(
                constraints:
                    BoxConstraints(maxWidth: mq.width * .6), // 📏 Set max width
                margin: EdgeInsets.only(
                    bottom: mq.height * .02,
                    left: mq.width * .02), // 🎨 Padding for spacing
                padding: EdgeInsets.symmetric(
                    vertical: mq.height * .01, horizontal: mq.width * .02),
                decoration: BoxDecoration(
                  border: Border.all(
                      color:
                          Theme.of(context).lightTextColor), // 🖌️ Border color
                  borderRadius: const BorderRadius.only(
                      topLeft: r,
                      topRight: r,
                      bottomRight: r), // 🔵 Rounded corners
                ),
                child: message.msg.isEmpty
                    ? AnimatedTextKit(animatedTexts: [
                        TypewriterAnimatedText(
                          ' Please wait... ', // ⏳ Animated typing effect when bot is thinking
                          speed: const Duration(milliseconds: 100),
                        ),
                      ], repeatForever: true)
                    : Text(
                        message.msg, // 📝 Display bot message
                        textAlign: TextAlign.center,
                      ),
              )
            ],
          )

        // 🧑‍💻 User Message Bubble
        : Row(
            mainAxisAlignment:
                MainAxisAlignment.end, // 📌 Align user messages to the right
            children: [
              // 🟩 User Message Bubble
              Container(
                constraints: BoxConstraints(maxWidth: mq.width * .6),
                margin: EdgeInsets.only(
                    bottom: mq.height * .02,
                    right: mq.width * .02), // 📏 Spacing for layout
                padding: EdgeInsets.symmetric(
                    vertical: mq.height * .01, horizontal: mq.width * .02),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context)
                          .lightTextColor), // 🎨 Message border
                  borderRadius: const BorderRadius.only(
                      topLeft: r,
                      topRight: r,
                      bottomLeft: r), // 🔵 Rounded corners
                ),
                child: Text(
                  message.msg, // 📩 Display user message
                  textAlign: TextAlign.center,
                ),
              ),

              // 👤 User Avatar (Default Profile Icon)
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue),
              ),

              const SizedBox(width: 6), // 📏 Small spacing after user avatar
            ],
          );
  }
}
