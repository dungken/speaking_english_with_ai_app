import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../apis/apis.dart';
import '../helper/my_dialog.dart';
import 'image_controller.dart';

/// Controller for handling language translation in the app.
/// Uses GetX for state management and interacts with external APIs for translations.
class TranslateController extends GetxController {
  /// Text field controller for user input text.
  final textC = TextEditingController();

  /// Text field controller for storing translated text.
  final resultC = TextEditingController();

  /// Stores the source language selected by the user.
  final from = ''.obs;

  /// Stores the target language selected by the user.
  final to = ''.obs;

  /// Tracks the translation status (e.g., loading, completed, none).
  final status = Status.none.obs;

  /// List of supported languages (keys from `jsonLang`).
  late final lang = jsonLang.keys.toList();

  /// Language code mappings for Google Translate API.
  final jsonLang = const {
    'Afrikaans': 'af',
    'Albanian': 'sq',
    'Amharic': 'am',
    'Arabic': 'ar',
    'Armenian': 'hy',
    'Assamese': 'as',
    'Aymara': 'ay',
    'Azerbaijani': 'az',
    'Bambara': 'bm',
    'Basque': 'eu',
    'Belarusian': 'be',
    'Bengali': 'bn',
    'Bhojpuri': 'bho',
    'Bosnian': 'bs',
    'Bulgarian': 'bg',
    'Catalan': 'ca',
    'Cebuano': 'ceb',
    'Chinese (Simplified)': 'zh-cn',
    'Chinese (Traditional)': 'zh-tw',
    'Corsican': 'co',
    'Croatian': 'hr',
    'Czech': 'cs',
    'Danish': 'da',
    'Dutch': 'nl',
    'English': 'en',
    'Esperanto': 'eo',
    'Estonian': 'et',
    'Filipino (Tagalog)': 'tl',
    'Finnish': 'fi',
    'French': 'fr',
    'Georgian': 'ka',
    'German': 'de',
    'Greek': 'el',
    'Gujarati': 'gu',
    'Haitian Creole': 'ht',
    'Hebrew': 'iw',
    'Hindi': 'hi',
    'Hungarian': 'hu',
    'Icelandic': 'is',
    'Indonesian': 'id',
    'Irish': 'ga',
    'Italian': 'it',
    'Japanese': 'ja',
    'Korean': 'ko',
    'Lao': 'lo',
    'Latin': 'la',
    'Latvian': 'lv',
    'Lithuanian': 'lt',
    'Malay': 'ms',
    'Malayalam': 'ml',
    'Maltese': 'mt',
    'Maori': 'mi',
    'Marathi': 'mr',
    'Mongolian': 'mn',
    'Nepali': 'ne',
    'Norwegian': 'no',
    'Persian': 'fa',
    'Polish': 'pl',
    'Portuguese': 'pt',
    'Punjabi': 'pa',
    'Romanian': 'ro',
    'Russian': 'ru',
    'Spanish': 'es',
    'Swahili': 'sw',
    'Swedish': 'sv',
    'Tamil': 'ta',
    'Telugu': 'te',
    'Thai': 'th',
    'Turkish': 'tr',
    'Ukrainian': 'uk',
    'Urdu': 'ur',
    'Vietnamese': 'vi',
    'Zulu': 'zu',
  };

  /// Validates user input before performing a translation.
  /// Returns `true` if valid, otherwise shows a dialog and returns `false`.
  bool _validateInput() {
    if (textC.text.trim().isEmpty) {
      MyDialog.info('Type something to translate!');
      return false;
    }
    if (to.isEmpty) {
      MyDialog.info('Select a target language!');
      return false;
    }
    return true;
  }

  /// Translates the input text using a custom AI translation API.
  Future<void> translate() async {
    if (!_validateInput()) return;

    status.value = Status.loading;

    // Construct the prompt based on available language selections
    String prompt = from.isNotEmpty
        ? 'Can you translate the given text from ${from.value} to ${to.value}:\n${textC.text}'
        : 'Can you translate the given text to ${to.value}:\n${textC.text}';

    log('Translation Request: $prompt');

    // Call API to get translation response
    final res = await APIs.getAnswer(prompt);
    resultC.text = utf8.decode(res.codeUnits);

    status.value = Status.complete;
  }

  /// Swaps the selected languages for translation.
  void swapLanguages() {
    if (from.isNotEmpty && to.isNotEmpty) {
      final temp = to.value;
      to.value = from.value;
      from.value = temp;
    }
  }

  /// Translates text using Google Translate API.
  Future<void> googleTranslate() async {
    if (!_validateInput()) return;

    status.value = Status.loading;

    // Get language codes for API request
    String fromLangCode = jsonLang[from.value] ?? 'auto';
    String toLangCode = jsonLang[to.value] ?? 'en';

    // Perform translation
    resultC.text = await APIs.googleTranslate(
      from: fromLangCode,
      to: toLangCode,
      text: textC.text,
    );

    status.value = Status.complete;
  }
}
