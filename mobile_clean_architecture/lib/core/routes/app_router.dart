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

import '../../features/authentication/presentation/screens/auth_screen.dart';
import '../../features/conversations/presentation/screens/conversation_screen.dart';
import '../../features/conversations/presentation/screens/create_conversation_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/image_description/presentation/screens/image_description_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/practice_mistakes/presentation/screens/practice_mistakes_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

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
  /// - /: Onboarding screen
  /// - /auth: Auth screen
  /// - /home: Main app screen
  /// - /create-conversation: Create conversation screen
  /// - /conversation: Conversation screen
  /// - /image-description: Image description screen
  /// - /profile: Profile screen
  /// - /practice-mistakes: Practice mistakes screen
  /// - /settings: Settings screen
  static final GoRouter router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/create-conversation',
        builder: (context, state) => const CreateConversationScreen(),
      ),
      GoRoute(
        path: '/conversation',
        builder: (context, state) {
          final situationDescription =
              state.uri.queryParameters['situation'] ?? '';
          return ConversationScreen(situationDescription: situationDescription);
        },
      ),
      GoRoute(
        path: '/image-description',
        builder: (context, state) => const ImageDescriptionScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/practice-mistakes',
        builder: (context, state) => const PracticeMistakesScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
