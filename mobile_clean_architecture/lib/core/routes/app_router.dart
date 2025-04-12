/// app_router.dart
///
/// This file defines the application's navigation structure using GoRouter.
/// It centralizes all route definitions and navigation logic in one place.
///
/// Key features:
/// - Defines all available routes in the app
/// - Sets the initial route (login page)
/// - Maps URL paths to their corresponding pages
/// - Uses GoRouter for declarative routing

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

/// Central router configuration for the application
///
/// This class:
/// - Defines all available routes
/// - Sets up navigation paths
/// - Maps routes to their corresponding pages
class AppRouter {
  /// The main router instance used throughout the app
  ///
  /// Routes defined:
  /// - /login: Authentication page
  /// - /register: User registration
  /// - /forgot-password: Password recovery
  /// - /home: Main app screen
  /// - /profile: User profile management
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}
