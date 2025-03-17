import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../helper/ad_helper.dart';
import '../helper/global.dart';
import '../helper/pref.dart';
import '../model/home_type.dart';
import '../widget/home_card.dart';

/// 📌 **Home Screen**
///
/// - Displays the main dashboard of the app
/// - Supports Dark Mode toggle
/// - Integrates Ads at the bottom
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// 🔹 **Dark Mode State**
  ///
  /// - Observes whether dark mode is enabled
  /// - Uses `Get.isDarkMode.obs` instead of `Pref.isDarkMode.obs` to avoid bugs
  final _isDarkMode = Get.isDarkMode.obs;

  @override
  void initState() {
    super.initState();

    // 🔄 **Enable Fullscreen Edge-to-Edge UI**
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // 🚀 **Disable Onboarding for Future Launches**
    Pref.showOnboarding = false;
  }

  @override
  Widget build(BuildContext context) {
    // 📌 **Initialize Device Size for Responsive UI**
    mq = MediaQuery.sizeOf(context);

    return Scaffold(
      // 📌 **App Bar**
      appBar: AppBar(
        title: const Text(appName),

        // 🌙 **Dark Mode Toggle Button**
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 10),
            onPressed: () {
              // 🔄 **Toggle Theme Mode**
              Get.changeThemeMode(
                _isDarkMode.value ? ThemeMode.light : ThemeMode.dark,
              );

              // 🔄 **Update Theme State & Save Preference**
              _isDarkMode.value = !_isDarkMode.value;
              Pref.isDarkMode = _isDarkMode.value;
            },
            icon: Obx(() => Icon(
                  _isDarkMode.value
                      ? Icons.brightness_2_rounded // 🌙 Dark Mode Icon
                      : Icons.brightness_5_rounded, // ☀️ Light Mode Icon
                  size: 26,
                )),
          ),
        ],
      ),

      // 📌 **Bottom Ad Banner**
      bottomNavigationBar: AdHelper.nativeBannerAd(),

      // 📌 **Main Body (List of Home Cards)**
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: mq.width * .04,
          vertical: mq.height * .015,
        ),
        children: HomeType.values.map((e) => HomeCard(homeType: e)).toList(),
      ),
    );
  }
}
