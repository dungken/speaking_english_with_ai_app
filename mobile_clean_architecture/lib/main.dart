/// main.dart
///
/// This is the entry point of the Flutter application.
/// It sets up the core configuration and initializes the app with necessary providers.
///
/// Key components:
/// 1. MultiBlocProvider: Manages state management using BLoC pattern
/// 2. MaterialApp.router: Configures routing using GoRouter
/// 3. Theme configuration: Sets up light and dark themes
///
/// The app follows Clean Architecture principles with feature-based organization.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/authentication/data/models/user_model.dart';
import 'features/authentication/di/auth_module.dart';
import 'features/home/di/home_module.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';

/// Application entry point
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core dependencies
  await initDependencies();

  // Initialize feature modules
  initAuthModule();
  initHomeModule();

  runApp(const MyApp());
}

/// Initialize core dependencies
Future<void> initDependencies() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register User adapter
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserAdapter());
  }

  final box = await Hive.openBox<UserModel>('auth_box');
  GetIt.instance.registerLazySingleton<Box<UserModel>>(() => box);

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  GetIt.instance.registerLazySingleton<SharedPreferences>(() => prefs);
  GetIt.instance
      .registerLazySingleton<ThemeProvider>(() => ThemeProvider(prefs));
}

/// Root widget of the application
///
/// This widget:
/// - Sets up state management using BLoC
/// - Configures the app theme
/// - Initializes routing
/// - Provides global app settings
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GetIt.instance<ThemeProvider>(),
        ),
        BlocProvider<HomeCubit>(
          create: (context) => GetIt.instance<HomeCubit>(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => GetIt.instance<AuthBloc>(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Speaking English With AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
