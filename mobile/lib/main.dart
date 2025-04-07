import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'apis/app_write.dart';
import 'helper/ad_helper.dart';
import 'helper/global.dart';
import 'helper/pref.dart';
import 'screen/splash_screen.dart';
import 'screen/feature/progress_tracking/Streak.dart';
import 'screen/feature/progress_tracking/Learning_Results.dart';


Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // ⚙️ Ensure widgets are initialized before running app

  // 🗄️ Initialize local storage (Hive)
  await Pref.initialize();

  // ☁️ Initialize AppWrite SDK for backend services
  AppWrite.init();

  // 📢 Initialize Facebook Ads SDK
  AdHelper.init();

  // 📱 Set immersive full-screen mode
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // 🔄 Lock screen orientation to portrait mode only
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // 🚀 Start the app
  runApp(const MyApp());
}

// 🎨 Main Application Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: appName, // 🏷️ App name from global constants
      debugShowCheckedModeBanner: false, // 🚫 Hide debug banner

      themeMode: Pref.defaultTheme, // 🌗 Set default theme mode

      // 🌙 Dark Theme Configuration
      darkTheme: ThemeData(
        useMaterial3: false,
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          elevation: 1, // 🏔️ Slight elevation for depth
          centerTitle: true, // 🎯 Center align title
          titleTextStyle: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w500, // 📝 Stylish font
          ),
        ),
      ),

      // ☀️ Light Theme Configuration
      theme: ThemeData(
        useMaterial3: false,
        appBarTheme: const AppBarTheme(
          elevation: 1, // 🏔️ Light shadow effect
          centerTitle: true,
          backgroundColor: Colors.white, // 🎨 White app bar background
          iconTheme: IconThemeData(color: Colors.blue), // 🔵 Blue icons
          titleTextStyle: TextStyle(
            color: Colors.blue, fontSize: 20,
            fontWeight: FontWeight.w500, // 📝 Blue app title
          ),
        ),
      ),

      home: const StreakScreen(), // 🚀 Start with the splash screen
    );
  }
}

// 🎨 Theme Extension for Custom Colors
extension AppTheme on ThemeData {
  // 🖌️ Define light text color based on theme mode
  Color get lightTextColor =>
      brightness == Brightness.dark ? Colors.white70 : Colors.black54;

  // 🎨 Define button color based on theme mode
  Color get buttonColor =>
      brightness == Brightness.dark ? Colors.cyan.withOpacity(.5) : Colors.blue;
}
