import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/translate_controller.dart';
import '../helper/global.dart';

class LanguageSheet extends StatefulWidget {
  final TranslateController c; // 🌐 Controller for handling translations
  final RxString s; // 🔄 Reactive variable for selected language

  const LanguageSheet({super.key, required this.c, required this.s});

  @override
  State<LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<LanguageSheet> {
  final _search = ''.obs; // 🔍 Reactive variable for search query

  @override
  Widget build(BuildContext context) {
    return Container(
      height: mq.height * .5, // 📏 Set half-screen height
      padding: EdgeInsets.only(
          left: mq.width * .04, right: mq.width * .04, top: mq.height * .02),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .scaffoldBackgroundColor, // 🎨 Background color based on theme
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15), // 🔵 Rounded top-left corner
          topRight: Radius.circular(15), // 🔵 Rounded top-right corner
        ),
      ),
      child: Column(
        children: [
          // 🔍 Search Bar for Filtering Languages
          TextFormField(
            onChanged: (s) =>
                _search.value = s.toLowerCase(), // 🎯 Updates search query
            onTapOutside: (e) => FocusScope.of(context)
                .unfocus(), // ⛔ Hide keyboard when tapped outside
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.translate_rounded,
                  color: Colors.blue), // 🌐 Translate icon
              hintText: 'Search Language...', // 🔍 Placeholder text
              hintStyle: TextStyle(fontSize: 14), // 🔠 Font size for hint text
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(10)), // 🟦 Rounded input field
              ),
            ),
          ),

          // 📜 Language List
          Expanded(
            child: Obx(() {
              // 📌 Filter languages based on search query
              final List<String> list = _search.isEmpty
                  ? widget.c.lang
                  : widget.c.lang
                      .where((e) => e.toLowerCase().contains(_search.value))
                      .toList();

              return ListView.builder(
                physics:
                    const BouncingScrollPhysics(), // 🎢 Smooth scrolling effect
                itemCount: list.length,
                padding: EdgeInsets.only(top: mq.height * .02, left: 6),
                itemBuilder: (ctx, i) {
                  return InkWell(
                    onTap: () {
                      widget.s.value = list[i]; // ✅ Set selected language
                      log(list[i]); // 📝 Log selected language
                      Get.back(); // ⏪ Close bottom sheet
                    },
                    child: Padding(
                      padding: EdgeInsets.only(bottom: mq.height * .02),
                      child: Text(
                        list[i],
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500), // 🎨 Stylish text
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
