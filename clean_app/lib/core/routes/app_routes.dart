import 'package:flutter_bloc/flutter_bloc.dart' as bloc;
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/conversation_repository_impl.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../presentation/screens/chat/chat_screen.dart';
import '../../presentation/screens/conversation/create_situation_screen.dart';
import '../../presentation/screens/forgot_password/forgot_password_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/login/login_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/register/register_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/translate/translate_screen.dart';
import '../../presentation/screens/image_description/image_description_screen.dart';
import '../../presentation/screens/image_generation/image_generation_screen.dart';
import '../../presentation/screens/progress/progress_screen.dart';
import '../../presentation/screens/role_play/role_play_screen.dart';
import '../../presentation/screens/topic_practice/topic_practice_screen.dart';
import '../../presentation/screens/interactive_learning/interactive_learning_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/topic_selection/topic_selection_screen.dart';
import '../../presentation/screens/subtopics/subtopics_screen.dart';
import '../../presentation/screens/chunking_practice/chunking_practice_screen.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../application/translate/translate_bloc.dart';
import '../../domain/models/topic.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String translate = '/translate';
  static const String imageGeneration = '/image-generation';
  static const String rolePlay = '/role-play';
  static const String topicPractice = '/topic-practice';
  static const String imageDescription = '/image-description';
  static const String progress = '/progress';
  static const String interactiveLearning = '/interactive-learning';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String topicSelection = '/topic-selection';
  static const String subtopics = '/subtopics';
  static const String chunkingPractice = '/chunking-practice';
  static const String createSituation = '/create-situation';

  static final List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingScreen(),
      transition: Transition.rightToLeft,
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
      name: forgotPassword,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: createSituation,
      page: () => bloc.RepositoryProvider<ConversationRepository>(
        create: (context) => ConversationRepositoryImpl(),
        child: const CreateSituationScreen(),
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: chat,
      page: () => bloc.RepositoryProvider<ConversationRepository>(
        create: (context) => ConversationRepositoryImpl(),
        child: const ChatScreen(),
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: translate,
      page: () => bloc.BlocProvider(
        create: (context) => TranslateBloc(
          aiRepository: context.read<AiRepository>(),
        ),
        child: const TranslateScreen(),
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: imageGeneration,
      page: () => const ImageGenerationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: rolePlay,
      page: () => bloc.RepositoryProvider<ConversationRepository>(
        create: (context) => ConversationRepositoryImpl(),
        child: const RolePlayScreen(),
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: topicPractice,
      page: () => const TopicPracticeScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: imageDescription,
      page: () => const ImageDescriptionScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: progress,
      page: () => const ProgressScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: interactiveLearning,
      page: () => const InteractiveLearningScreen(topicId: ''),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: settings,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: topicSelection,
      page: () => const TopicSelectionScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: subtopics,
      page: () => SubtopicsScreen(
        topic: Topic(
          id: '',
          title: '',
          description: '',
          level: '',
          isCompleted: false,
        ),
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: chunkingPractice,
      page: () => const ChunkingPracticeScreen(topicId: ''),
      transition: Transition.rightToLeft,
    ),
  ];
}
