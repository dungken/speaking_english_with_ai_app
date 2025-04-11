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

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';

/// Application entry point
void main() {
  runApp(const MyApp());
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
    return MultiBlocProvider(
      providers: [
        // Initialize authentication state management
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Speak AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
