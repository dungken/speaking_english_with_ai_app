import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/translate/translate_bloc.dart';
import '../../../application/translate/translate_event.dart';
import '../../../application/translate/translate_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_loading.dart';
import '../../widgets/language_sheet.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final _textController = TextEditingController();
  final _selectedLanguage = ''.obs;
  final _languages = [
    'English',
    'Vietnamese',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Russian',
    'Japanese',
    'Korean',
    'Chinese',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage.value = _languages[0];
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _showLanguageSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguageSheet(
        onLanguageSelected: (language) {
          context.read<TranslateBloc>().add(TranslateText(
                text: _textController.text,
                targetLanguage: language,
              ));
        },
        selectedLanguage: _selectedLanguage,
        languages: _languages,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translate'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: BlocConsumer<TranslateBloc, TranslateState>(
        listener: (context, state) {
          if (state is TranslateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _textController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Enter text to translate',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Translate to ${_selectedLanguage.value}',
                  onTap: () {
                    if (_textController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter text to translate'),
                        ),
                      );
                      return;
                    }
                    _showLanguageSheet();
                  },
                ),
                const SizedBox(height: 16),
                if (state is TranslateLoading)
                  const CustomLoading()
                else if (state is TranslateSuccess)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Translation:',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.translatedText,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
