import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'apis/app_write.dart';
import 'helper/ad_helper.dart';
import 'helper/global.dart';
import 'helper/pref.dart';
import 'screen/splash_screen.dart';
import 'screen/feature/conversation/create_situation_screen.dart';

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
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: Colors.cyan,
          secondary: Colors.cyanAccent,
          surface: const Color(0xFF1E1E1E),
          background: const Color(0xFF121212),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF1E1E1E),
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E1E),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyan,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),

      // ☀️ Light Theme Configuration
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.blue),
          titleTextStyle: TextStyle(
            color: Colors.blue,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Define routes
      getPages: [
        GetPage(
          name: '/create-situation',
          page: () => const CreateSituationScreen(),
        ),
      ],

      home: const SplashScreen(), // 🚀 Start with the splash screen
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
