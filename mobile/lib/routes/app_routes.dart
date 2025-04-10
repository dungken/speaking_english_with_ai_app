import 'package:get/get.dart';
import '../screen/splash_screen.dart';
import '../screen/login_screen.dart';
import '../screen/register_screen.dart';
import '../screen/home_screen.dart';
import '../screen/forgot_password_screen.dart';
import '../screen/onboarding_screen.dart';
import '../screen/feature/conversation/create_situation_screen.dart';
import '../screen/feature/conversation/conversation_screen.dart';
import '../screen/profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String forgotPassword = '/forgot-password';
  static const String createSituation = '/create-situation';
  static const String chat = '/chat';
  static const String onboarding = '/onboarding';
  static const String profile = '/profile';

  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: createSituation,
      page: () => CreateSituationScreen(
        token: Get.arguments['token'],
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: chat,
      page: () => ConversationScreen(
        conversationId: Get.arguments['conversationId'],
        token: Get.arguments['token'],
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      transition: Transition.fadeIn,
    ),
  ];
}
