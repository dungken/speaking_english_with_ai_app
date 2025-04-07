import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageSheet extends StatefulWidget {
  final Function(String) onLanguageSelected;
  final RxString selectedLanguage;
  final List<String> languages;

  const LanguageSheet({
    super.key,
    required this.onLanguageSelected,
    required this.selectedLanguage,
    required this.languages,
  });

  @override
  State<LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<LanguageSheet> {
  final _search = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.04,
        right: MediaQuery.of(context).size.width * 0.04,
        top: MediaQuery.of(context).size.height * 0.02,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Column(
        children: [
          TextFormField(
            onChanged: (s) => _search.value = s.toLowerCase(),
            onTapOutside: (e) => FocusScope.of(context).unfocus(),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.translate_rounded, color: Colors.blue),
              hintText: 'Search Language...',
              hintStyle: TextStyle(fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final List<String> list = _search.isEmpty
                  ? widget.languages
                  : widget.languages
                      .where((e) => e.toLowerCase().contains(_search.value))
                      .toList();

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: list.length,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: 6,
                ),
                itemBuilder: (ctx, i) {
                  return InkWell(
                    onTap: () {
                      widget.selectedLanguage.value = list[i];
                      widget.onLanguageSelected(list[i]);
                      Get.back();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height * 0.02,
                      ),
                      child: Text(
                        list[i],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
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
