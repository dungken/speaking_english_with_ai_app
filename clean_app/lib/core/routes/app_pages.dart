import 'package:get/get.dart';
import '../../domain/models/topic.dart';

import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/forgot_password/forgot_password_screen.dart';
import '../../presentation/screens/login/login_screen.dart';
import '../../presentation/screens/register/register_screen.dart';
import '../../presentation/screens/chat/chat_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/image_description/image_description_screen.dart';
import '../../presentation/screens/image_generation/image_generation_screen.dart';
import '../../presentation/screens/progress/progress_screen.dart';
import '../../presentation/screens/role_play/role_play_screen.dart';
import '../../presentation/screens/topic_practice/topic_practice_screen.dart';
import '../../presentation/screens/translate/translate_screen.dart';
import '../../presentation/screens/interactive_learning/interactive_learning_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/topic_selection/topic_selection_screen.dart';
import '../../presentation/screens/subtopics/subtopics_screen.dart';
import '../../presentation/screens/chunking_practice/chunking_practice_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatScreen(),
    ),
    GetPage(
      name: AppRoutes.translate,
      page: () => const TranslateScreen(),
    ),
    GetPage(
      name: AppRoutes.imageGeneration,
      page: () => const ImageGenerationScreen(),
    ),
    GetPage(
      name: AppRoutes.rolePlay,
      page: () => const RolePlayScreen(),
    ),
    GetPage(
      name: AppRoutes.topicPractice,
      page: () => const TopicPracticeScreen(),
    ),
    GetPage(
      name: AppRoutes.imageDescription,
      page: () => const ImageDescriptionScreen(),
    ),
    GetPage(
      name: AppRoutes.progress,
      page: () => const ProgressScreen(),
    ),
    GetPage(
      name: AppRoutes.interactiveLearning,
      page: () => const InteractiveLearningScreen(topicId: ''),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
    ),
    GetPage(
      name: AppRoutes.topicSelection,
      page: () => const TopicSelectionScreen(),
    ),
    GetPage(
      name: AppRoutes.subtopics,
      page: () => SubtopicsScreen(
        topic: Topic(
          id: '',
          title: '',
          description: '',
          level: '',
          isCompleted: false,
        ),
      ),
    ),
    GetPage(
      name: AppRoutes.chunkingPractice,
      page: () => const ChunkingPracticeScreen(topicId: ''),
    ),
  ];
}
