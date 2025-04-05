import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/image_controller.dart';
import '../../controller/translate_controller.dart';
import '../../helper/global.dart';
import '../../widgets/custom_btn.dart';
import '../../widgets/custom_loading.dart';
import '../../widgets/language_sheet.dart';

/// 📌 **TranslatorFeature Screen**
///
/// A multilingual text translator where users can input text,
/// select source and target languages, and get translated results.
class TranslatorFeature extends StatefulWidget {
  const TranslatorFeature({super.key});

  @override
  State<TranslatorFeature> createState() => _TranslatorFeatureState();
}

class _TranslatorFeatureState extends State<TranslatorFeature> {
  /// 🔹 **Translate Controller Instance**
  ///
  /// Manages translation logic, selected languages, and UI updates.
  final _c = TranslateController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 📌 **App Bar**
      appBar: AppBar(
        title: const Text('Multi Language Translator'),
      ),

      // 📌 **Main Content Body**
      body: ListView(
        physics: const BouncingScrollPhysics(), // Smooth scrolling
        padding: EdgeInsets.only(top: mq.height * .02, bottom: mq.height * .1),
        children: [
          // 🔄 **Language Selection Row**
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🌍 **Source Language Selection**
              InkWell(
                onTap: () => Get.bottomSheet(LanguageSheet(c: _c, s: _c.from)),
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                child: Container(
                  height: 50,
                  width: mq.width * .4,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                  ),
                  child:
                      Obx(() => Text(_c.from.isEmpty ? 'Auto' : _c.from.value)),
                ),
              ),

              // 🔄 **Swap Languages Button**
              IconButton(
                onPressed: _c.swapLanguages,
                icon: Obx(
                  () => Icon(
                    CupertinoIcons.repeat,
                    color: _c.to.isNotEmpty && _c.from.isNotEmpty
                        ? Colors.blue
                        : Colors.grey,
                  ),
                ),
              ),

              // 🎯 **Target Language Selection**
              InkWell(
                onTap: () => Get.bottomSheet(LanguageSheet(c: _c, s: _c.to)),
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                child: Container(
                  height: 50,
                  width: mq.width * .4,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Obx(() => Text(_c.to.isEmpty ? 'To' : _c.to.value)),
                ),
              ),
            ],
          ),

          // 📝 **Text Input Field (User's Text to Translate)**
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: mq.width * .04,
              vertical: mq.height * .035,
            ),
            child: TextFormField(
              controller: _c.textC, // Input text controller
              minLines: 5,
              maxLines: null, // Allows unlimited lines
              onTapOutside: (e) => FocusScope.of(context)
                  .unfocus(), // Hide keyboard when tapping outside
              decoration: const InputDecoration(
                hintText: 'Translate anything you want...',
                hintStyle: TextStyle(fontSize: 13.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),

          // 📌 **Translation Result Display**
          Obx(() => _translateResult()),

          // 🔽 **Spacing Before Translate Button**
          SizedBox(height: mq.height * .04),

          // 🚀 **Translate Button**
          CustomBtn(
            onTap: _c.googleTranslate, // Calls Google Translate function
            text: 'Translate',
          ),
        ],
      ),
    );
  }

  /// 📌 **Translation Result Widget**
  ///
  /// Displays:
  /// - The translated text when translation is complete
  /// - A loading indicator while processing
  /// - Nothing if no translation has been requested yet
  Widget _translateResult() => switch (_c.status.value) {
        Status.none => const SizedBox(), // No translation yet
        Status.complete => Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .04),
            child: TextFormField(
              controller: _c.resultC, // Translated text controller
              maxLines: null, // Allows unlimited lines
              onTapOutside: (e) => FocusScope.of(context).unfocus(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
        Status.loading =>
          const Align(child: CustomLoading()), // Shows loading animation
      };
}
