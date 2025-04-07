import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'application/topic/topic_bloc.dart';
import 'domain/repositories/topic_repository.dart';
import 'data/repositories/topic_repository_impl.dart';
import 'presentation/screens/topic_selection/topic_selection_screen.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/utils/shared_prefs.dart';
import 'data/repositories/ai_repository_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/image_description_repository_impl.dart';
import 'domain/repositories/ai_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/image_description_repository.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  await SharedPrefs.init();

  // Initialize ThemeController
  Get.put(ThemeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(),
        ),
        RepositoryProvider<AiRepository>(
          create: (context) => AiRepositoryImpl(
            apiKey: 'YOUR_OPENAI_API_KEY', // TODO: Replace with actual API key
          ),
        ),
        RepositoryProvider<ImageDescriptionRepository>(
          create: (context) => ImageDescriptionRepositoryImpl(),
        ),
        RepositoryProvider<TopicRepository>(
          create: (context) => TopicRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<TopicBloc>(
            create: (context) => TopicBloc(
              repository: context.read<TopicRepository>(),
            ),
          ),
        ],
        child: GetMaterialApp(
          title: 'Speaking English with AI',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splash,
          getPages: AppRoutes.pages,
          home: const TopicSelectionScreen(),
          routes: {
            '/topic-practice': (context) => const Placeholder(),
            '/lesson-view': (context) => const Placeholder(),
          },
        ),
      ),
    );
  }
}
